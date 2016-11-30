use_frameworks!

def shared_pods
  pod 'OAuthSwift', '~> 1.1.0'
  pod 'DCKeyValueObjectMapping', '~> 1.5'
  pod 'SAMKeychain', '~> 1.5.2'
end

target 'Withings-SDK-iOS' do
  platform :ios, '8.0'
  shared_pods
end

target 'Withings-SDK-iOSTests' do

end

target 'Withings-SDK-iOS-Demo' do
  platform :ios, '8.0'
  shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
