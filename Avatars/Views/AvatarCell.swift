
import UIKit
import Combine

class AvatarCell: UICollectionViewCell {
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var githubLabel: UILabel!
    
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel: AvatarCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .lightGray.withAlphaComponent(0.2)
        contentView.layer.cornerRadius = 5.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func prepareCell(viewModel: AvatarCellViewModel) {
        self.viewModel = viewModel
        loginLabel.text = viewModel.login
        githubLabel.text = viewModel.gitUrl
        
        guard let url = URL(string: viewModel.avtarUrl) else { return }
        // Check if the image is available in the cache
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)),
           let image = UIImage(data: cachedResponse.data) {
            self.imageView.image = image
            self.setNeedsLayout()
        } else {
            activityIndicator.startAnimating()
            ImageCache.shared.load(url: url as NSURL, networkService: NetworkService(request: URLSessionNetworkRequest()))
                .sink { completion in
                    // Handle completion as needed
                    self.activityIndicator.stopAnimating()
                } receiveValue: { item, image in
                    // Update the cellViewModel with the loaded image
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.imageView.image = image
                        self.layoutSubviews()
                    }
                }
                .store(in: &subscriptions)
        }
    }
}
