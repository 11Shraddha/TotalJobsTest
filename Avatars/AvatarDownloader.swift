
import UIKit

class AvatarDownloader {
    private enum Constants {
        static let endpoint = "https://i.pravatar.cc"
    }

    func downloadAvatar(avatarID: String, size: Int, completion: @escaping (Result<UIImage, Error>) -> Void) {
        var componenets = URLComponents(string: Constants.endpoint + "/" + "\(size)")
        componenets?.queryItems = [
            URLQueryItem(name: "img", value: avatarID)
        ]
        guard let imageUrl = componenets?.url else { return }

        let request = URLRequest(url: imageUrl)
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error as NSError? {
                completion(.failure(error))
            } else if let data, let image = UIImage(data: data) {
                completion(.success(image))
            }
        }
        dataTask.resume()
    }
}
