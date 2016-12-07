Pod::Spec.new do |s|
  s.name = 'Withings-SDK-iOS'
  s.version = '0.2.2'
  s.license = 'MIT'
  s.summary = 'Provides an Objective-C interface for integrating iOS apps with the Withings API'
  s.homepage = 'https://github.com/jdrevet/Withings-SDK-iOS'
  s.authors = { 'Johan Drevet' => ''}
  s.source = { :git => 'https://github.com/jdrevet/Withings-SDK-iOS.git', :tag => s.version }

  s.public_header_files = 'Withings-SDK-iOS/*.h'
  s.source_files = 'Withings-SDK-iOS/*.{m,h}','Withings-SDK-iOS/internal/*.{m,h}'

  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.dependency 'OAuthSwift', '~> 1.1.0'
  s.dependency 'DCKeyValueObjectMapping', '~> 1.5'
  s.dependency 'SAMKeychain', '~> 1.5.2'

end
