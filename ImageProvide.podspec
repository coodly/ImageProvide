Pod::Spec.new do |s|
  s.name = 'ImageProvide'
  s.version = '0.5.0'
  s.license = 'Apache 2'
  s.summary = 'Simple image cache'
  s.homepage = 'https://github.com/coodly/ImageProvide'
  s.authors = { 'Jaanus Siim' => 'jaanus@coodly.com' }
  s.source = { :git => 'git@github.com:coodly/ImageProvide.git', :tag => s.version }

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'Source/ImageProvide/*.swift'

  s.requires_arc = true
end
