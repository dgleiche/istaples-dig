# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'staplesgotclass' do
	pod 'Google/Analytics'
	pod 'Google/SignIn'
	pod 'Alamofire'
       	pod 'Parse'
       	pod 'SDWebImage'
  	pod 'RealmSwift'
	pod 'KDCircularProgress'
	pod 'MLPAutoCompleteTextField'
  	pod 'HTMLEntities', :git => 'https://github.com/IBM-Swift/swift-html-entities.git'
	pod 'SWXMLHash'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.2'
    end
  end
end

