
import UIKit

class AvatarCell: UICollectionViewCell {
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var githubLabel: UILabel!
    
    private var networkService: NetworkServiceProtocol!


    func loadImage(from imageUrl: String, using networkService: NetworkServiceProtocol) {
        guard let url = URL(string: imageUrl) else {
            return
        }
        activityIndicator.startAnimating()
        networkService.downloadImage(from: url) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                switch result {
                case .success(let image):
                    self.imageView.image = image
                case .failure(let error):
                    print("Failed to load image: \(error)")
                    break
                }
            }
        }
    }
    
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
}
