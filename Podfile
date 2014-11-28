platform :ios, '7.1'
source 'https://github.com/CocoaPods/Specs.git'

target 'EarlyReader' do
  pod 'Heap','2.0.5'
  pod 'Mixpanel','2.5.4'
  pod 'AppsFlyer-SDK', '2.5.3.10'
  pod 'UXCam', '1.0.7'
  pod 'Facebook-iOS-SDK', '3.20.0'
end

# Bug in cocoapods and Swift projects...n order for bridging header to compile for the tests, we need to include this here..it's messy but it works until there is a real fix. 
target 'EarlyReaderTests' do
  pod 'Mixpanel','2.5.4'
end




