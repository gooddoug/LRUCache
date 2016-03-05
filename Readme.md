# LRUCache

LRUCache is a library for a Least Recently Used (LRU) Cache. It is useful for caching items in a key value store that can only grow to a certain size. For example, say we want to cache images we've downloaded from the internet. We don't want to cache an unlimited number of images, and we want to only keep those images in the cache that we have most recent used in the cache. After you reach a certian size, we want to remove the least recently used item from the cache.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Installing
[Carthage](https://github/com/carthage/carthage) is the recommended way to install this. Add the following to your cartfile:
```ruby
github "gooddoug/MultiPartMimeHelper"
```

Optionally, you can copy the LRUCache.swift file into your project and not worry about frameworks at all.

## Usage
```swift
let urlImageCache<NSURL, UIImage>(maxSize: 64)

guard let image = urlImageCache.itemForKey(someURL) else { kickOffDownloadImageForURL(url) }

func kickOffDownloadImageForURL(url: NSURL) {
    downloadImageForURL(url, callback: { (url: NSURL, image: UIImage?) in
        if let anImage = image {
            urlImageCache.setItem(anImage, forKey: url)
        }
        ...
    })
}

```

## Contributing
Please use pull requests if you know how to fix the issue you are having. If you can't fix the issue, please file a ticket.

## License
MIT License, see the 'LICENSE' file for details
