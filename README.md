
## DaisyNet

![](https://img.shields.io/badge/support-swift%204%2B-green.svg)   ![](https://img.shields.io/cocoapods/v/DaisyNet.svg?style=flat)

对[Alamofire](https://github.com/Alamofire/Alamofire)与[Cache](https://github.com/hyperoslo/Cache)的封装实现对网络数据的缓存，可以存储JSON，String，Data.


<p align="center">
<img src="https://github.com/MQZHot/DaisyNet/raw/master/Picture/get.gif">
</p>

## 使用

***注意： 如果你的参数中带有时间戳、token等变化的参数，这些参数需要写在`dynamicParams`参数中，避免无法读取缓存***
```swift
func request(
    _ url: String,
    method: HTTPMethod = .get,
    params: Parameters? = nil,
    dynamicParams: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil)
    -> RequestTaskManager
```

* 缓存数据只需要调用`.cache(true)`，不调用或者`.cache(false)`则不缓存
* 调用`responseCacheAndString`可以先读取缓存数据，再读取网络数据
* 通过`isCacheData`属性可以区分缓存数据还是网络数据
```swift
DaisyNet.request(url, params: params).cache(true).responseCacheAndJson { value in
    switch value.result {
    case .success(let json):
        if value.isCacheData {
            print("我是缓存的")
        } else {
            print("我是网络的")
        }
    case .failure(let error):
        print(error)
    }
}
```

* 你也可以分别读取缓存数据和网络数据，如下代码
* 调用`cacheJson`方法获取缓存数据，调用`responseJson`获取网络数据

```swift
DaisyNet.request(url, params: params).cache(true).cacheJson { json in
        print("我是缓存的")
    }.responseJson { response in
    print("我是网络的")
}
```
* 如果你不需要缓存，可以直接调用`responseJson`方法
```swift
DaisyNet.request(url).responseString { response in
    switch response {
    case .success(let value): print(value)
    case .failure(let error): print(error)
    }
}
```

* 同理，如果你要缓存`Data`或者`String`，与`JSON`是相似的
```swift
/// 先读取缓存，再读取网络数据
DaisyNet.request(url).cache(true).responseCacheAndString { value in }
DaisyNet.request(url).cache(true).responseCacheAndData { value in }
```
```swift
/// 分别获取缓存和网络数据
DaisyNet.request(url).cache(true).cacheString { string in
        print("我是缓存的")
    }.responseString { response in
    print("我是网络的")
}
```
* 取消请求
```swift
DaisyNet.cancel(url, params: params)
```

* 清除缓存
```swift
/// 清除所有缓存
func removeAllCache(completion: @escaping (Bool)->())
/// 根据url和params清除缓存
func removeObjectCache(_ url: String, params: [String: Any]? = nil, completion: @escaping (Bool)->())
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

