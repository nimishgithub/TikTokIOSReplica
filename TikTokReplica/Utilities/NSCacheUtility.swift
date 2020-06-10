//
//  NSCacheUtility.swift
//  By Nimish Sharma

import Foundation
import AVKit

fileprivate let cache: NSCache<NSString, AnyObject> = {
    let cache = NSCache<NSString, AnyObject>()
    cache.countLimit = NSIntegerMax
    cache.totalCostLimit = NSIntegerMax
    return cache
}()

fileprivate let thumbnailFetchQueue = DispatchQueue(label: "thumbnailFetchQueue", qos: .userInteractive, attributes: .concurrent)

extension UIImageView {
    
    func setThumbnail(_ url: URL,
                      placeholderImage: UIImage? = nil,
                      originalIndex: IndexPath?,
                      completion: @escaping((UIImage, IndexPath?)->Void)) {
        
        let originalInd: IndexPath? = originalIndex
        
        if let placeHolder = placeholderImage  {
            self.image = placeHolder
        }
        NSCacheUtility.cacheMediaThumbnail(url) { (thumbnail) in
            completion(thumbnail ?? placeholderImage ?? UIImage(), originalInd)
        }
    }
    
}

final class NSCacheUtility {
    
    @discardableResult
    static func getThumbnailIfCached(_ url: URL, completion: @escaping (_ thumbnail: UIImage?)->Void) -> UIImage {
        if let thumbnail = cache.object(forKey: url.absoluteString as NSString) as? UIImage {
            completion(thumbnail)
            return thumbnail
        } else {
            cacheMediaThumbnail(url, completion: completion)
            return AppImages.placeHolder
        }
    }
    
    static func cacheMediaThumbnail(_ url: URL, completion: @escaping (_ thumbnail: UIImage?)->Void) {
        if let thumbnail = cache.object(forKey: url.absoluteString as NSString) as? UIImage {
            // image if already cached
            DispatchQueue.main.async {
                completion(thumbnail)
            }
        }
        thumbnailFetchQueue.async {
            NSCacheUtility.retriveThumbnail(url: url, completion: { thumbnail in
                guard let thumbnail = thumbnail else {return}
                cache.setObject(thumbnail, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            })
        }
    }
    
    private static func retriveThumbnail(url: URL, completion: @escaping (_ image: UIImage?)->Void) {
        let asset = AVURLAsset(url: url, options: nil)
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        avAssetImageGenerator.appliesPreferredTrackTransform = true
        let fullscreenSize = UIScreen.main.bounds.size
        avAssetImageGenerator.maximumSize = fullscreenSize
        let thumnailTime = CMTimeMake(value: 1, timescale: 600)
        let times = [NSValue(time: thumnailTime)]
        avAssetImageGenerator.generateCGImagesAsynchronously(forTimes: times) { (_, image, _, result, error) in
            if let image = image {
                completion(UIImage(cgImage: image))
            } else if let error = error {
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
}
