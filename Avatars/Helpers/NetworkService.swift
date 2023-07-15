
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
    @discardableResult func getAPI<Object: Decodable>(url: String, resultType: Object.Type) -> AnyPublisher<Object, NetworkError>
}

class NetworkService: NetworkServiceProtocol {
    
    func getAPI<Object>(url: String, resultType: Object.Type) -> AnyPublisher<Object, NetworkError> where Object : Decodable {
        guard let escapedAddress = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
              let url = URL(string: escapedAddress) else {
            return Fail(error: NetworkError.requestNotFormed).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        //        if let requestBodyParams = parameter {
        //            do {
        //                request.httpBody = try JSONSerialization.data(withJSONObject: requestBodyParams, options: .prettyPrinted)
        //            } catch {
        //                return Fail(error: NetworkError.requestNotFormed).eraseToAnyPublisher()
        //            }
        //        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.0 }
            .decode(type: Object.self, decoder: JSONDecoder())
            .catch { _ in Fail(error: NetworkError.requestNotFormed).eraseToAnyPublisher() }
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    func downloadImage(url: String) -> AnyPublisher<UIImage?, Error> {
        guard let escapedAddress = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
              let url = URL(string: escapedAddress) else {
            return Fail(error: NetworkError.requestNotFormed).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { UIImage(data: $0.data) }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
