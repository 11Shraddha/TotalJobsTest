
import Foundation
import Combine
import UIKit

enum NetworkError: Error {
    case noData
    case requestNotFormed
    
    var errorDescription: String? {
        switch self {
        case .requestNotFormed: return "Unable to form the request."
        case .noData:
            return "No data"
        }
    }
}

// Protocol defining the networking service requirements
protocol NetworkServiceProtocol {
    func downloadImage(url: String) -> AnyPublisher<UIImage?, Error>
}


protocol URLRequestProtocol {
    func getAPI<T: Decodable>(url: String, parameter: [String: AnyObject]?) -> AnyPublisher<T, NetworkError>
    func downloadImage(url: String) -> AnyPublisher<UIImage?, Error>
}

class URLSessionNetworkRequest: URLRequestProtocol {
    
    private let session = URLSession.shared
    
    func getAPI<T: Decodable>(url: String, parameter: [String: AnyObject]?) -> AnyPublisher<T, NetworkError> {
        
        guard let escapedAddress = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
              let url = URL(string: escapedAddress) else {
            return Fail(error: NetworkError.requestNotFormed).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let requestBodyParams = parameter {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBodyParams, options: .prettyPrinted)
            } catch {
                return Fail(error: NetworkError.requestNotFormed).eraseToAnyPublisher()
            }
        }
        
        return session.dataTaskPublisher(for: request)
            .map { $0.0 }
            .decode(type: T.self, decoder: JSONDecoder())
            .catch { _ in Fail(error: NetworkError.requestNotFormed).eraseToAnyPublisher() }
            .eraseToAnyPublisher()
    }
    
    func downloadImage(url: String) -> AnyPublisher<UIImage?, Error> {
        guard let escapedAddress = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
              let url = URL(string: escapedAddress) else {
            return Fail(error: NetworkError.requestNotFormed).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return session.dataTaskPublisher(for: request)
            .map { UIImage(data: $0.data) }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

class NetworkService: NetworkServiceProtocol {
    
    private let request: URLRequestProtocol
    
    init(request: URLRequestProtocol) {
        self.request = request
    }
    
    @discardableResult
    func get<Object: Codable>(url: String, parameter: [String: AnyObject]? = nil, resultType: Object.Type = Object.self) -> AnyPublisher<Object, NetworkError> {
        return self.request.getAPI(url: url, parameter: parameter)
    }
    
    @discardableResult
    func downloadImage(url: String) -> AnyPublisher<UIImage?, Error> {
        return self.request.downloadImage(url: url)
    }
}
