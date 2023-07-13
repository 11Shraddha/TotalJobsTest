// AvatarCellViewModel.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import Foundation
import UIKit

class AvatarCellViewModel {
    let login: String
    let github: String
    let imageUrl: String?
    let imageItem: ImageItem!
    let networkService: NetworkService
    
    init(user: GitUser, networkService: NetworkService) {
        self.login = user.login
        self.github = user.html_url
        self.imageUrl = user.avatar_url
        self.networkService = networkService
        imageItem = ImageItem(image: nil, url: NSURL(string: user.avatar_url)!)
    }
    
    func loadImage(using networkService: NetworkService, completion: @escaping (UIImage?) -> Void) {
        guard imageUrl != nil, let url = URL(string: imageUrl ?? "") else {
            completion(nil)
            return
        }
        // Check if the image is available in the cache
        if let  cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)),
           let image = UIImage(data: cachedResponse.data) {
            completion(image)
        }
        
        networkService.downloadImage(from: imageUrl!) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    completion(image)
                case .failure(let error):
                    print("Failed to load image: \(error)")
                    completion(nil)
                }
            }
        }
    }
}


class ImageItem: Hashable {
    
    var image: UIImage?
    let url: NSURL!
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(image: UIImage?, url: NSURL) {
        self.image = image
        self.url = url
    }
}
