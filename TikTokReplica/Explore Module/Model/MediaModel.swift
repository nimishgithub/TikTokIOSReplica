//
//  MediaModel.swift

import UIKit

// MARK: - Element
struct CategoryModel: Codable, Hashable {

    let id = UUID()
    let title: String
    let videos: [Video]
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case videos = "nodes"
    }
    
    static func == (lhs: CategoryModel, rhs: CategoryModel) -> Bool {
        lhs.id == rhs.id
    }
    
}

// MARK: - Node
struct Video: Codable, Hashable {
    let media: Media
    
    enum CodingKeys: String, CodingKey {
        case media = "video"
    }
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        lhs.media.encodeURL == rhs.media.encodeURL
    }
}

// MARK: - Video
struct Media: Codable, Hashable {
    
    let encodeURL: String
    
    // Use it only you you are sure that the url string is correct
    func thumbnail(_ completion: ((UIImage)->Void)? = nil) -> UIImage {
        let result = NSCacheUtility.getThumbnailIfCached(URL(string: encodeURL)!, completion: { thumbnail in
            completion?(thumbnail ?? AppImages.placeHolder)
        })
        return result
    }
    
    enum CodingKeys: String, CodingKey {
        case encodeURL = "encodeUrl"
    }
    
    func fetchThumbnail(_ thumbnail: @escaping(UIImage?)->Void) {
        if let url = URL(string: encodeURL) {
            NSCacheUtility.cacheMediaThumbnail(url) { (image) in
                if let aImage = image {
                    thumbnail(aImage)
                }
            }
        }
    }
    
}
