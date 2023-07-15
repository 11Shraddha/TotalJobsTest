// AvatarLoader.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import Foundation
import UIKit
import Combine

public class AvatarDownloader {
    public static let shared = AvatarDownloader()
    private var loadingResponses = [URL: [(UIImage?) -> Void]]()
    private var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkServiceProtocol

    // Dependency injection of the network service
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func load(url: URL) -> AnyPublisher<(URL, UIImage?), Never> {
        let subject = PassthroughSubject<(URL, UIImage?), Never>()
        
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
                
        networkService.downloadImage(url: url.absoluteString)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Failed to load image: \(error.localizedDescription)")
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
