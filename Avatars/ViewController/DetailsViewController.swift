import UIKit
import Combine

class DetailsViewController: UIViewController {
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var usernameLabel: UILabel!
    @IBOutlet weak private var githubLabel: UILabel!
    @IBOutlet weak private var detailsStackView: UIStackView!

    private var cancellables = Set<AnyCancellable>()
    private var viewModel: DetailsViewModel!
    var github: GitUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        loadDetails()
    }

    private func setupViewModel() {
        viewModel = DetailsViewModel(github: github)
        githubLabel.text = viewModel.github.url
        usernameLabel.text = viewModel.github.login
        // Bind avatar image updates to the imageView
        viewModel.avatarImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.imageView.image = image
            }
            .store(in: &cancellables)
        
        // Bind followers updates to the view
        viewModel.followersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] followers in
                self?.updateDetails(with: followers)
            }
            .store(in: &cancellables)
        
        // Bind following updates to the view
        viewModel.followingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] following in
                self?.updateDetails(with: following)
            }
            .store(in: &cancellables)
        
        // Bind repositories updates to the view
        viewModel.repositoriesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] repositories in
                self?.updateDetails(with: repositories)
            }
            .store(in: &cancellables)
        
        // Bind gists updates to the view
        viewModel.gistsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gists in
                self?.updateDetails(with: gists)
            }
            .store(in: &cancellables)
    }

    func loadDetails() {
        viewModel.loadDetails(github: github)
    }
    
    private func updateDetails(with details: [String]) {
        let labels = details.map(makeLabel)
        labels.forEach { detailsStackView.addArrangedSubview($0) }
    }

    private func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        return label
    }
}
