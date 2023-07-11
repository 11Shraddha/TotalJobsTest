
import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var usernameLabel: UILabel!
    @IBOutlet weak private var githubLabel: UILabel!
    @IBOutlet weak private var detailsStackView: UIStackView!

    var github: GitUser!
    var networkService: NetworkService!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        loadDetails()
    }

    func loadDetails() {
        networkService.get(url: github.avatar_url) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.imageView.image = UIImage(data: data)
                case .failure:
                    break
                }
            }
        }

        usernameLabel.text = github.login
        githubLabel.text = "GitHub:\n\(github.html_url)"

        var detailLabels = [UILabel]()
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        networkService.get(url: github.followers_url, resultType: [GitUser].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let followers):
                    detailLabels.append(self.makeLabel(text: "Followers: \(followers.count)"))
                case .failure:
                    detailLabels.append(self.makeLabel(text: "Followers: N/A"))
                }

                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        networkService.get(url: github.following_url, resultType: [GitUser].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let followers):
                    detailLabels.append(self.makeLabel(text: "Following: \(followers.count)"))
                case .failure:
                    detailLabels.append(self.makeLabel(text: "Following: N/A"))
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        networkService.get(url: github.repos_url, resultType: [Repo].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let repositories):
                    detailLabels.append(self.makeLabel(text: "Repositories count: \(repositories.count)"))
                case .failure:
                    detailLabels.append(self.makeLabel(text: "Repositories count: N/A"))
                }
            }
        }

        dispatchGroup.enter()
        networkService.get(url: github.gists_url, resultType: [Gist].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let gists):
                    detailLabels.append(self.makeLabel(text: "Gists count: \(gists.count)"))
                case .failure:
                    detailLabels.append(self.makeLabel(text: "Gists count: N/A"))
                }
            }
            dispatchGroup.leave()
        }

        dispatchGroup.wait()

        detailLabels.forEach { label in
            detailsStackView.addArrangedSubview(label)
        }
    }

    func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0

        return label
    }
}
