// AvatarListViewModel.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import Foundation

class AvatarListViewModel {
    private let networkService = NetworkService()
    private var githubUsers = [GitUser]()
    
    var reloadData: (() -> Void)?
    var showError: ((String) -> Void)?
    
    func fetchGithubUsers() {
        networkService.get(url: .githubUsersEndpoint, resultType: [GitUser].self) { result in
            switch result {
            case .failure(let error):
                self.showError?(error.localizedDescription)
                self.githubUsers = []
            case .success(let users):
                self.githubUsers = users
            }
            self.reloadData?()
        }
    }
    
    func getGithubUser(at index: Int) -> GitUser {
        return githubUsers[index]
    }
    
    func getGithubUserCount() -> Int {
        return githubUsers.count
    }
    
}
