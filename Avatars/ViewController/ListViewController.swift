
import UIKit
import Combine

class ListViewController: UICollectionViewController {
        
    // Note: Architecture Changes
    // I have made several architecture changes to improve the project's design

    // MVVM Approach
    //I have adopted the MVVM (Model-View-ViewModel) architecture to separate concerns and improve the reusability of the code. This allows for a clear separation between the presentation logic (ViewModel) and the user interface (View).

    // Combine Framework
    // To facilitate reactive programming and data binding between the ViewModel and View, I have integrated the Combine framework.

    // Dependency Injection
    //I have introduced a protocol to handle dependency injection in the network service class. By using protocols, we can easily replace dependencies with mocks or different implementations, improving testability in the future.

    // These architectural changes aim to enhance the maintainability, and testability, while also following to best practices in iOS app development.

    
    private var viewModel = AvatarListViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        
        // Bind users list updates to the view
        viewModel.githubUserListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                ActivityIndicator.sharedIndicator.hideActivityIndicator()
                self?.collectionView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.userSelected
            .sink(receiveCompletion: { completion in
                // Handle the error
            }) { [weak self] user in
                self?.navigateToUserDetailScreen(user)
            }
            .store(in: &subscriptions)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing: AvatarCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! AvatarCell
        cell.prepareCell(viewModel: viewModel.cellViewModel(indexPath: indexPath))
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.usersSelected(index: indexPath.row)
    }
}

// MARK: Routing
extension ListViewController {
    private func navigateToUserDetailScreen(_ user: GitUser) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        controller.github = user
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
    private var insets: UIEdgeInsets { UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0) }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.frame.width - 2 * insets.left, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
}
