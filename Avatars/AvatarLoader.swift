// AvatarLoader.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import Foundation
import UIKit
import Combine

public class ImageCache {
    public static let shared = ImageCache()
    private var loadingResponses = [NSURL: [(UIImage?) -> Void]]()
    private var cancellables = Set<AnyCancellable>()
    
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    func load(url: NSURL, networkService: NetworkService) -> AnyPublisher<(NSURL, UIImage?), Never> {
        let subject = PassthroughSubject<(NSURL, UIImage?), Never>()
        
        // In case there are more than one requestor for the image, we append their completion block.
        if loadingResponses[url] != nil {
            loadingResponses[url]?.append { image in
                subject.send((url, image))
            }
        } else {
            loadingResponses[url] = [{ image in
                subject.send((url, image))
            }]
        }
        
        networkService.downloadImage(url: url.absoluteString ?? "")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Failed to load image: \(error)")
                    subject.send((url, nil))
                    subject.send(completion: .finished)
                case .finished:
                    break
                }
            }, receiveValue: { image in
                if let image = image {
                    let blocks = self.loadingResponses[url] ?? []
                    // Iterate over each requestor for the image and pass it back.
                    for block in blocks {
                        block(image)
                    }
                    self.loadingResponses[url] = nil
                }
            })
            .store(in: &cancellables)
        
        return subject.eraseToAnyPublisher()
    }
}
