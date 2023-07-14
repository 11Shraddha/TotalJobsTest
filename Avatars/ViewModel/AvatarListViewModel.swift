// AvatarListViewModel.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import Foundation
import Combine

class AvatarListViewModel {
    
    private var githubUsers = [GitUser]()
    private var dataSource = [AvatarCellViewModel]()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: Input
    private var loadData: AnyPublisher<Void, Never> = PassthroughSubject<Void, Never>().eraseToAnyPublisher()
    
    // MARK: Output
    var numberOfRows: Int {
        dataSource.count
    }
    
    // Event
    var reloadUserList: AnyPublisher<Result<Void, NetworkError>, Never> {
        reloadUserListSubject.eraseToAnyPublisher()
    }
    
    var userSelected: AnyPublisher<GitUser, Never> {
        userSelectedSubject.eraseToAnyPublisher()
    }
    
    private let userSelectedSubject = PassthroughSubject<GitUser, Never>()
    private let reloadUserListSubject = PassthroughSubject<Result<Void, NetworkError>, Never>()
    
    
    init() { }
    
    func cellViewModel(indexPath: IndexPath) -> AvatarCellViewModel {
        let cellViewModel = dataSource[indexPath.row]
        return cellViewModel
    }
    
    func usersSelected(index: Int) {
        userSelectedSubject.send(githubUsers[index])
    }
    
    func attachViewEventListener(loadData: AnyPublisher<Void, Never>) {
        self.loadData = loadData
        self.loadData
            .setFailureType(to: NetworkError.self)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.githubUsers.removeAll()
            })
            .flatMap { _ -> AnyPublisher<[GitUser], NetworkError> in
                let userWebservice = NetworkService(request: URLSessionNetworkRequest())
                return userWebservice
                    .get(url: .githubUsersEndpoint, parameter: nil)
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dataSource.removeAll()
            })
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] users in
                self?.githubUsers.append(contentsOf: users)
                self?.dataSource = users.map {  return AvatarCellViewModel(user: $0) }
                self?.reloadUserListSubject.send(.success(()))
            })
            .store(in: &subscriptions)
    }
}
