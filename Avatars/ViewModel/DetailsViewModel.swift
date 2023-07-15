import Combine
import UIKit

class DetailsViewModel {
    private var cancellables = Set<AnyCancellable>()
    private var avatarImageSubject = PassthroughSubject<UIImage?, Never>()
    private var followersSubject = PassthroughSubject<[String], Never>()
    private var followingSubject = PassthroughSubject<[String], Never>()
    private var repositoriesSubject = PassthroughSubject<[String], Never>()
    private var gistsSubject = PassthroughSubject<[String], Never>()
    
    // Expose publishers to update the view
    var avatarImagePublisher: AnyPublisher<UIImage?, Never> {
        avatarImageSubject.eraseToAnyPublisher()
    }
    
    var followersPublisher: AnyPublisher<[String], Never> {
        followersSubject.eraseToAnyPublisher()
    }
    
    var followingPublisher: AnyPublisher<[String], Never> {
        followingSubject.eraseToAnyPublisher()
    }
    
    var repositoriesPublisher: AnyPublisher<[String], Never> {
        repositoriesSubject.eraseToAnyPublisher()
    }
    
    var gistsPublisher: AnyPublisher<[String], Never> {
        gistsSubject.eraseToAnyPublisher()
    }
    
    var github: GitUser
    
    init(github: GitUser) {
        self.github = github
    }
    
    func loadDetails(github: GitUser) {
        let networkService = NetworkService()
        
        let avatarPublisher = networkService.downloadImage(url: github.avatar_url)
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
        
        avatarPublisher
            .sink { [weak self] image in
                self?.avatarImageSubject.send(image)
            }
            .store(in: &cancellables)
        
        let followersPublisher = networkService.getAPI(url: github.followers_url, resultType: [GitUser].self)
        let followingPublisher = networkService.getAPI(url: github.following_url, resultType: [GitUser].self)
        let repositoriesPublisher = networkService.getAPI(url: github.repos_url, resultType: [Repo].self)
        let gistsPublisher = networkService.getAPI(url: github.gists_url, resultType: [Gist].self)
        
        followersPublisher
            .map { ["Followers: \($0.count)"] }
            .replaceError(with: ["Followers: N/A"])
            .sink { [weak self] followers in
                self?.followersSubject.send(followers)
            }
            .store(in: &cancellables)
        
        followingPublisher
            .map { ["Following: \($0.count)"] }
            .replaceError(with: ["Following: N/A"])
            .sink { [weak self] following in
                self?.followingSubject.send(following)
            }
            .store(in: &cancellables)
        
        repositoriesPublisher
            .map { ["Repositories count: \($0.count)"] }
            .replaceError(with: ["Repositories count: N/A"])
            .sink { [weak self] repositories in
                self?.repositoriesSubject.send(repositories)
            }
            .store(in: &cancellables)
        
        gistsPublisher
            .map { ["Gists count: \($0.count)"] }
            .replaceError(with: ["Gists count: N/A"])
            .sink { [weak self] gists in
                self?.gistsSubject.send(gists)
            }
            .store(in: &cancellables)
    }
}
