require 'rubygems'
require 'cloudfiles'
require 'thread'
require 'set'

module CloudFilesContainerSync

  # Adapts the data stream to an IO interface to
  # copy one object into another
  class ReaderIO
    attr_reader :bytesize
    @eof = false

    def initialize(storage_object)
      @bytesize = storage_object.bytes
      @buffer = ""
      @m = Mutex.new
      @resource = ConditionVariable.new
      Thread.new do
        begin
          storage_object.data_stream do |chunk|
            @m.synchronize do
              @buffer +=  chunk
              @resource.signal
            end
          end
          @m.synchronize do
            @eof = true
            @resource.signal
          end
        rescue Exception => ex
          $stderr.puts("Exception: " + ex.to_s)
          raise ex
        end
      end
    end

    def read(length=nil, buf=nil)
      @m.synchronize do
        if @buffer.size == 0 and not @eof
          # Wait for more data
          @resource.wait(@m)
        end
        stop = if length.nil?
            -1
          else
            length
          end
        result = if @buffer.size == 0
            nil
          else
            @buffer[0..stop]
          end
        @buffer = @buffer[stop..-1] || ""
        buf = result unless buf.nil?
        result
      end
    end
  end
end

module CloudFiles
  class Container
   
    # Sync this container to the target container 
    # options:
    # :delete : if true files in the target that don't exist in source will be deleted
    # :fast : don't compare last modification date or size, assume files are never modified in the source.
    # :filter : a regexp to select which file to synchronize
    def sync_to(target, options={})
      filter = options[:filter] || //
      self.populate
      target.populate
      
      # Don't sync to same container
      if (self.connection == target.connection and self.name == target.name)
        raise "Can't sync to the same container: %s to %s" % [self.name, target.name]
      end

      target_objects = Set.new(target.objects())
      source_objects = Set.new(self.objects().select{|name| filter =~ name})
      source_objects.each do |object_name|
        # Unfreeze
        object_name = object_name.dup
        exists = target_objects.include?(object_name)
        begin
          next if exists and options[:fast] == true
          source_object = self.object(object_name)
          source_metadata = source_object.metadata
          content_type = source_object.content_type
          target_object = target.create_object(object_name)
          if !exists or (options[:fast] != true and (target_object.last_modified.nil? or target_object.last_modified < source_object.last_modified or target_object.bytes != source_object.bytes)) then 
            begin
              print("Syncing #{object_name}.. ")
              if source_object.container.connection == target_object.container.connection
                # Same connection, use the copy function
                source_object.copy(:container => target.name)
                print("done (using copy).\n")     
              else
                # Download and upload the data to copy
                io = CloudFilesContainerSync::ReaderIO.new(source_object)
                target_object.write(io, { 'Content-Type' => content_type })
                # Copy the metadata too
                target_object.set_metadata(source_metadata)
                print("done (downloaded/uploaded).")
              end
            ensure
              print("\n")
            end
          end
        rescue NoSuchObjectException => ex
          $stderr.print("Failed syncing %s: No such object.\n" % [object_name])
        end
      end

      if options[:delete] then
        # Delete files that don't exist in the source container
        to_delete = target_objects - source_objects
        to_delete.each do |object_name|
          begin
            target.delete_object(object_name)
            print("Deleted %s\n" % [object_name])
          rescue NoSuchObjectException => ex
            $stderr.print("Failed deleting %s: No such object.\n" % [object_name])
          end
        end
      end
    end
  end
end


