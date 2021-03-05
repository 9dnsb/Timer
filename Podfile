# Uncomment the next line to define a global platform for your project
  platform :ios, '14.1'

target 'Timer' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Timer
  pod 'SwiftReorder', '~> 7.2'
  pod 'SwiftyStoreKit'
  pod 'McPicker'
  pod 'MKColorPicker'
  pod 'BetterSegmentedControl', '~> 1.3'
  pod 'CoreStore', '~> 7.0'
  pod 'PKHUD', '~> 5.0'
  pod 'Eureka'
  pod 'Google-Mobile-Ads-SDK'
  pod 'ColorCompatibility'
  pod 'SwiftRater'
  pod 'MarqueeLabel'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Firebase/Crashlytics'
  pod 'Colorful', '~> 3.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end

  target 'TimerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TimerUITests' do
    # Pods for testing
  end



end
