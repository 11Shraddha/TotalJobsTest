
import UIKit


class AvatarCell: UICollectionViewCell {
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var githubLabel: UILabel!
    
    private var imageLoadingTask: URLSessionTask?
    private var viewModel: AvatarCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .lightGray.withAlphaComponent(0.2)
        contentView.layer.cornerRadius = 5.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadingTask?.cancel()
        imageView.image = nil
    }
    
    func configure(with viewModel: AvatarCellViewModel, networkService: NetworkService) {
        self.viewModel = viewModel
        loginLabel.text = viewModel.login
        githubLabel.text = viewModel.github
        self.activityIndicator.startAnimating()
        ImageCache.shared.load(url: viewModel.imageItem.url as NSURL, item: viewModel.imageItem, networkService: networkService) { (fetchedItem, image) in
            if let img = image, img != fetchedItem.image {                self.imageView.image = image
                self.activityIndicator.stopAnimating()
                self.layoutSubviews()
            }
        }
    }
}
