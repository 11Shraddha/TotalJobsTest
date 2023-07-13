//
//import Foundation
//import Combine
//
//enum NetworkError: Error {
//    case noData
//}
//
//class NetworkService {
//
//    private let session = URLSession.shared
//
//    // MARK: - Closures
//
//    @discardableResult
//    func get<Object: Codable>(
//        url: String,
//        resultType: Object.Type = Object.self,
//        completion: @escaping (Result<Object, Error>) -> Void
//    ) -> URLSessionDataTask {
//        get(url: url) { data in
//            let result: Result<Object, Error>
//            defer { completion(result) }
//
//            switch data {
//            case .success(let data):
//                do {
//                    let object = try JSONDecoder().decode(Object.self, from: data)
//                    result = .success(object)
//                } catch {
//                    result = .failure(error)
//                }
//            case .failure(let error):
//                result = .failure(error)
//            }
//        }
//    }
//
//    @discardableResult
//    func get(url: String, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask {
//        let request = URLRequest(url: URL(string: url)!)
//        let task = session.dataTask(with: request) { data, _, error in
//            let result: Result<Data, Error>
//            defer { completion(result) }
//
//            // INGORE IT: simulating the slow internet
//            sleep(.random(in: 0...1))
//
//            if let error {
//                result = .failure(error)
//                return
//            }
//
//            guard let data else {
//                result = .failure(NetworkError.noData)
//                return
//            }
//
//            result = .success(data)
//
//        }
//
//        task.resume()
//        return task
//    }
//}
//
//// MARK: - Combine
//
//extension NetworkService {
//    func get<Object: Codable>(
//        url: String,
//        resultType: Object.Type = Object.self
//    ) -> some Publisher<Object, Error> {
//        session
//            .dataTaskPublisher(for: URL(string: url)!)
//            .map(\.data)
//            .decode(type: Object.self, decoder: JSONDecoder())
//    }
//
//    func get(url: String) -> some Publisher<Data, Error> {
//        session
//            .dataTaskPublisher(for: URL(string: url)!)
//            .map(\.data)
//            .mapError { $0 as Error }
//    }
//}
//
//// MARK: - Structured Concurrency
//
//extension NetworkService {
//    func get<Object: Codable>(
//        url: String,
//        resultType: Object.Type = Object.self
//    ) async throws -> Object {
//        let data = try await session.data(for: URLRequest(url: URL(string: url)!)).0
//
//        return try JSONDecoder().decode(Object.self, from: data)
//    }
//
//    func get(url: String) async throws -> Data {
//        try await session.data(for: URLRequest(url: URL(string: url)!)).0
//    }
//}
//

import Foundation
import Combine
import UIKit


enum NetworkError: Error {
    case noData
}

protocol NetworkRequestProtocol {
    @discardableResult
    func get(url: String, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask
}

class URLSessionNetworkRequest: NetworkRequestProtocol {
    
    private let session = URLSession.shared
    
    @discardableResult
    func get(url: String, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask {
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { data, response, error in
            print(response)
            let result: Result<Data, Error>
            defer { completion(result) }
            
            // IGNORE IT: simulating the slow internet
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
}

class NetworkService {
    
    private let request: NetworkRequestProtocol
    
    init(request: NetworkRequestProtocol) {
        self.request = request
    }
    
    @discardableResult
    func get<Object: Codable>(
        url: String,
        resultType: Object.Type = Object.self,
        completion: @escaping (Result<Object, Error>) -> Void
    ) -> URLSessionDataTask {
        request.get(url: url) { [weak self] data in
            guard self != nil else { return }
            
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
    func downloadImage(from url: String, completion: @escaping (Result<UIImage?, Error>) -> Void) -> URLSessionTask {
        request.get(url: url) { [weak self] data in
            guard self != nil else { return }
            
            let result: Result<UIImage?, Error>
            defer { completion(result) }
            
            switch data {
            case .success(let data):
                result = .success(UIImage(data: data))
            case .failure(let error):
                result = .failure(error)
            }
        }
    }
}
