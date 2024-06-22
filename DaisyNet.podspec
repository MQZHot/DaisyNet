
Pod::Spec.new do |s|
  s.name         = "DaisyNet"
  s.version      = "1.1.1"
  s.summary      = "Alamofire与Cache封装, 更容易存储请求数据"
  s.homepage     = "https://github.com/MQZHot/DaisyNet"
  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "MQZHot" => "mqz1228@163.com" }
  s.platform     = :ios, "14.0"
  s.source       = { :git => "https://github.com/MQZHot/DaisyNet.git", :tag => s.version }
  s.source_files = ["Source/*.swift"]
  s.requires_arc = true
  
  s.swift_versions = ['5.0', '5.1', '5.2']
  
  s.dependency 'Cache',       '~> 6.0.0'
  s.dependency 'Alamofire',   '~> 5.9.1'
end
