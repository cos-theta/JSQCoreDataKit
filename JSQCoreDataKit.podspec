Pod::Spec.new do |s|
   s.name = 'JSQCoreDataKit'
   s.version = '9.0.1'
   s.license = 'MIT'

   s.summary = 'A swifter Core Data stack'
   s.homepage = 'https://github.com/jessesquires/JSQCoreDataKit'
   s.documentation_url = 'https://jessesquires.github.io/JSQCoreDataKit'
   s.social_media_url = 'https://twitter.com/jesse_squires'
   s.author = 'Jesse Squires'

   s.source = { :git => 'https://github.com/jessesquires/JSQCoreDataKit.git', :tag => s.version }
   s.source_files = 'Source/*.swift'

   s.swift_version = '5.1'

   s.ios.deployment_target = '11.0'
   s.osx.deployment_target = '10.12'
   s.tvos.deployment_target = '11.0'
   s.watchos.deployment_target = '4.0'

   s.frameworks = 'CoreData'
   s.requires_arc = true
end
