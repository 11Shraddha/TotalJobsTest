
import Foundation
import Combine
import UIKit

enum NetworkError: Error {
    case noData
}

protocol NetworkingProtocol {
    @discardableResult
    func downloadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> URLSessionTask    // Add other methods required by the NetworkService
}


class NetworkManager {
    
    private let session = URLSession.shared
    
    // MARK: - Closures
    
    @discardableResult
    func get<Object: Codable>(
        url: String,
        resultType: Object.Type = Object.self,
        completion: @escaping (Result<Object, Error>) -> Void
    ) -> URLSessionDataTask {
        get(url: url) { data in
            let result: Result<Object, Error>
            defer { completion(result) }
            
            switch data {
            case .success(let data):
                do {
                    let object = try JSONDecoder().decode(Object.self, from: data)
                    result = .success(object)
                } catch {
                    result = .failure(error)
                }
            case .failure(let error):
                result = .failure(error)
            }
        }
    }
    
    @discardableResult
    func get(url: String, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask {
        let request = URLRequest(url: URL(string: url)!)
        let task = session.dataTask(with: request) { data, _, error in
            let result: Result<Data, Error>
            defer { completion(result) }
            
            // INGORE IT: simulating the slow internet
            sleep(.random(in: 0...1))
            
            if let error {
                result = .failure(error)
                return
            }
            
            guard let data else {
                result = .failure(NetworkError.noData)
                return
            }
            
            result = .success(data)
            
        }
        
        task.resume()
        return task
    }
    
    @discardableResult
    func downloadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> URLSessionTask {
        let task = session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(NetworkError.noData))
            }
        }
        task.resume()
        return task
    }
    
}

// MARK: - Combine

extension NetworkManager {
    func get<Object: Codable>(
        url: String,
        resultType: Object.Type = Object.self
    ) -> some Publisher<Object, Error> {
        session
            .dataTaskPublisher(for: URL(string: url)!)
            .map(\.data)
            .decode(type: Object.self, decoder: JSONDecoder())
    }
    
    func get(url: String) -> some Publisher<Data, Error> {
        session
            .dataTaskPublisher(for: URL(string: url)!)
            .map(\.data)
            .mapError { $0 as Error }
    }
}

// MARK: - Structured Concurrency

extension NetworkManager {
    func get<Object: Codable>(
        url: String,
        resultType: Object.Type = Object.self
    ) async throws -> Object {
        let data = try await session.data(for: URLRequest(url: URL(string: url)!)).0
        
        return try JSONDecoder().decode(Object.self, from: data)
    }
    
    func get(url: String) async throws -> Data {
        try await session.data(for: URLRequest(url: URL(string: url)!)).0
    }
}

