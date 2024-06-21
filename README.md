
## DaisyNet

![](https://img.shields.io/badge/support-swift%204%2B-green.svg)   ![](https://img.shields.io/cocoapods/v/DaisyNet.svg?style=flat)

对[Alamofire](https://github.com/Alamofire/Alamofire)与[Cache](https://github.com/hyperoslo/Cache)的封装实现对网络数据的缓存，可以存储JSON，String，Data.


<p align="center">
<img src="https://github.com/MQZHot/DaisyNet/raw/master/Picture/get.gif">
</p>

## 使用

* 缓存数据需要调用`.cacheIdentifier(identifier)`，不调用或者`.cacheIdentifier(nil)`不缓存
* 确保`identifier`是唯一的

```swift
/// 缓存标识
let identifier = "home"

/// 网络请求
DaisyNet.request(urlStr, params: params).cacheIdentifier(identifier).responseString(queue: .main) { result in
    switch result {
    case .success(let string):
        self.textView.text = string
        print(Thread.current)
    case .failure(let error):
        print(error)
    }
}
```

* 读取缓存

```swift
/// 缓存标识
let identifier = "home"

/// 读取缓存
let cacheString = DaisyNet.cacheString(with: identifier)
let cacheData = DaisyNet.cacheData(with: identifier)
let cacheJson = DaisyNet.cacheJson(with: identifier)
```

* 缓存过期时间
```swift
    func cacheExpiryConfig(expiry: DaisyExpiry)
```

* 清除缓存
```swift
/// 清除所有缓存
func removeAllCache(completion: ((_ isSuccess: Bool) -> ())? = nil) 
/// 根据identifier清除缓存
func removeCache(with identifier: String?, completion: ((_ isSuccess: Bool) -> ())? = nil)
```

## Install
```
1.pod 'DaisyNet'

2.pod install / pod update
```

## Author

* Email: mqz1228@163.com

## LICENSE

DaisyNet is released under the MIT license. See [LICENSE](https://github.com/MQZHot/DaisyNet/blob/master/LICENSE) for details.

