# cloudfiles-container-sync

  Synchronizes files from a Rackspace Cloudfiles container to another.
  
  [![Dependency Status][2]][1]
  
  [1]: https://gemnasium.com/tech-angels/cloudfiles-container-sync
  [2]: https://gemnasium.com/tech-angels/cloudfiles-container-sync.png

## Getting started

Install the cloudfiles-container-sync gem:

    gem install cloudfiles-container-sync

Use the sync_to method it adds to your Cloudfiles container objects:

    cf = CloudFiles::Connection.new(:username => "your username", :api_key => "your api key")
    container_source = cf.container('source')
    container_destination = cf.container('destination')

    container_source.sync_to(container_destination)


## Method arguments

You can pass arguments to the method through an hash.

- fast: if true, only files missing in the destination are copied. Good if your files are never updated.

- filter: a regexp to select files to copy.

- delete: if true, files in the destination that are not present in the source will be deleted.


## Credits

  Gilbert Roulot @ Tech-angels - http://www.tech-angels.com/
  
  [![Tech-Angels](http://media.tumblr.com/tumblr_m5ay3bQiER1qa44ov.png)](http://www.tech-angels.com)


