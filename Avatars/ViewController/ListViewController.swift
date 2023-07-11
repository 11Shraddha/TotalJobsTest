
import UIKit

class ListViewController: UICollectionViewController {
    
    private let viewModel = AvatarListViewModel()
    
    let networkService = NetworkService(request: URLSessionNetworkRequest())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        viewModel.fetchGithubUsers(networkService: networkService)
    }
    
    private func setupBindings() {
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        viewModel.showError = { [weak self] error in
            // Handle error presentation
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getGithubUserCount()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing: AvatarCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! AvatarCell
        
        let githubUser = viewModel.getGithubUser(at: indexPath.row, networkService: networkService)
        cell.configure(with: githubUser, networkService: networkService)
        return cell
    }
    //
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        guard let cell = sender as? AvatarCell, let githubUser = cell.githubUser else { return }
    //        guard let profileViewController = segue.destination as? DetailsViewController else { return }
    //
    //        profileViewController.networkService = networkService
    //        profileViewController.github = githubUser
    //    }
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
