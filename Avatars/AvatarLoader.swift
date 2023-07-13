// AvatarLoader.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import Foundation
import UIKit

public class ImageCache {
    
    public static let shared = ImageCache()
    private var loadingResponses = [NSURL: [(ImageItem, UIImage?) -> Swift.Void]]()
    
    /// - Tag: cache
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    final func load(url: NSURL, item: ImageItem, networkService: NetworkService, completion: @escaping (ImageItem, UIImage?) -> Swift.Void) {
        
        // Check if the image is available in the cache
        if let  cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url as URL)),
           let image = UIImage(data: cachedResponse.data) {
            completion(item, image)
        }
        //         In case there are more than one requestor for the image, we append their completion block.
        if loadingResponses[url] != nil {
            loadingResponses[url]?.append(completion)
            return
        } else {
            loadingResponses[url] = [completion]
        }
        
        networkService.downloadImage(from: url.absoluteString ?? "") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    
                    let blocks = self.loadingResponses[url] ?? []
                    // Iterate over each requestor for the image and pass it back.
                    for block in blocks {
                        DispatchQueue.main.async {
                            block(item, image)
                        }
                        return
                    }
                    
                case .failure(let error):
                    print("Failed to load image: \(error)")
                    DispatchQueue.main.async {
                        completion(item, nil)
                    }
                    
                }
            }
        }.resume()
    }
}
