Gem::Specification.new do |s|
  s.platform                    = Gem::Platform::RUBY
  s.name                        = 'cloudfiles-container-sync'
  s.version                     = '0.1.0'
  s.summary                     = 'Adds a method to Rackspace Cloudfiles containers to synchronize files from a container to another.'
  s.description                 = 'Adds a method to Rackspace Cloudfiles containers to synchronize files from a container to another.'
  s.homepage			= 'https://github.com/tech-angels/cloudfiles-container-sync'
  s.license			= 'MIT'

  s.author                      = 'Gilbert Roulot'
  s.email                       = 'gilbert.roulot@tech-angels.com'

  s.add_dependency                'cloudfiles',    '~> 1.5.0.1'

  s.files                       = Dir['README.md', 'cloudfiles-container-sync.rb']
  s.require_path                = '.'
end

