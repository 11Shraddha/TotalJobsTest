// AvatarListViewModel.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import Foundation
import Combine

class AvatarListViewModel {
    
    private var githubUsers = [GitUser]()
    private var dataSource = [AvatarCellViewModel]()
    private var subscriptions = Set<AnyCancellable>()
    private var githubUsersListSubject = PassthroughSubject<[GitUser], Never>()
    private let userSelectedSubject = PassthroughSubject<GitUser, Never>()
    
    // MARK: Output
    var numberOfRows: Int {
        dataSource.count
    }
    
    // Expose publishers to update the view
    var githubUserListPublisher: AnyPublisher<[GitUser], Never> {
        githubUsersListSubject.eraseToAnyPublisher()
    }
    
    var userSelected: AnyPublisher<GitUser, Never> {
        userSelectedSubject.eraseToAnyPublisher()
    }
    
    init() {
        loadDetails()
    }
    
    func loadDetails() {
        let networkService = NetworkService()
        
        let githubUserListPublisher = networkService.getAPI(url: .githubUsersEndpoint, resultType: [GitUser].self)
        
        githubUserListPublisher
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.githubUsers.removeAll()
                self?.dataSource.removeAll()
            })
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] users in
                self?.githubUsers.append(contentsOf: users)
                self?.dataSource = users.map {  return AvatarCellViewModel(user: $0) }
                self?.githubUsersListSubject.send(users)
            })
            .store(in: &subscriptions)
    }
    
    func cellViewModel(indexPath: IndexPath) -> AvatarCellViewModel {
        let cellViewModel = dataSource[indexPath.row]
        return cellViewModel
    }
    
    func usersSelected(index: Int) {
        userSelectedSubject.send(githubUsers[index])
    }
}
