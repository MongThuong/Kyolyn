project 'Kiolyn.xcodeproj'

# ignore all warnings from all pods
inhibit_all_warnings!

# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Kiolyn' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Kiolyn
  pod 'Dip'
  pod 'couchbase-lite-ios', '~> 1.4.1'
  pod 'Alamofire', '~> 4.5'
  pod 'AlamofireImage', '~> 3.3'
  pod 'AlamofireObjectMapper', '~> 5.0'
  pod 'SnapKit', '~> 4.0'
  pod 'RxSwift', '~> 4.0'
  pod 'Material', '~> 2.12'
  pod 'XCGLogger', '~> 6.0'
  pod 'MMLanScan', '~> 3.0'
  pod 'FontAwesomeKit'
  pod 'RxOptional', '~> 3.3'
  pod 'DropDown', '~> 2.3'
  pod 'RxGesture', '~> 1.2'
  pod 'RxDataSources', '~> 3.0'
  pod 'JTAppleCalendar', '~> 7.1'
  pod 'Fabric'
  pod 'Crashlytics', '~> 3.10'
  pod 'DRPLoadingSpinner'
  pod 'SwiftyUserDefaults', '~> 3.0.1'
  pod 'SwiftWebSocket'
  pod 'MaterialComponents/Slider'
  pod 'Swifter', '~> 1.4.1'
  pod 'BRPtouchPrinterKit', :git => 'https://github.com/chinhnguyen/BRPtouchPrinterKit.git'
  pod 'AwaitKit', :git => 'https://github.com/chinhnguyen/AwaitKit.git', :tag => '6.0.0'

  target 'KiolynTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxTest', '~> 4.1'
    pod 'Quick', '~> 1.2'
    pod 'Nimble', '~> 7.1'
    pod 'SwiftyUserDefaults', '~> 3.0.1'
    pod 'RxExpect', '~> 1.1.0'
  end

  target 'KiolynUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  post_install do |installer|
    project = installer.pods_project
    project.targets.each do |target|
       if target.name == "DropDown" then
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '3.2'
        end
      end
    end
  end

end
