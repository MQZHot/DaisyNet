
Pod::Spec.new do |s|
  s.name         = "DaisyNet"
  s.version      = "1.0.2"
  s.summary      = "Alamofire与Cache封装, 更容易存储请求数据"
  s.homepage     = "https://github.com/MQZHot/DaisyNet"
  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "MQZHot" => "mqz1228@163.com" }
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/MQZHot/DaisyNet.git", :tag => s.version }
  s.source_files = "DaisyNet/DaisyNet", "DaisyNet/DaisyNet/*.swift"
  s.requires_arc = true
  s.dependency 'Cache', '>= 5.6.2'
  s.dependency 'Alamofire', '>= 6.0.0'
  s.pod_target_xcconfig = { "SWIFT_VERSION" => "5.0" }
  s.swift_version = '5.0'
end
