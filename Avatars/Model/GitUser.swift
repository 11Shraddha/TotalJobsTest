
import Foundation

struct GitUser: Codable {
    let login: String
    let id: Int
    let avatar_url: String
    let url: String
    let repos_url: String
    let html_url: String
    let followers_url: String
    var following_url: String {
        return "\(url)/following"
    }
    var gists_url: String {
        return "\(url)/gists"
    }
}
