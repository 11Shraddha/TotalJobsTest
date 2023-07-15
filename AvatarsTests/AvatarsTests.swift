import XCTest
import Combine

class MockNetworkService: NetworkServiceProtocol {
    let result: Result<UIImage?, Error>
    
    init(result: Result<UIImage?, Error>) {
        self.result = result
    }
    
    func downloadImage(url: String) -> AnyPublisher<UIImage?, Error> {
        return Result.Publisher(result)
            .eraseToAnyPublisher()
    }
}

class AvatarDownloaderTests: XCTestCase {
    var downloader: AvatarDownloader!
    var mockNetworkService: MockNetworkService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        downloader = AvatarDownloader.shared
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        downloader = nil
        mockNetworkService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testLoadImage_Success() {
        let url = URL(string: "https://avatars.githubusercontent.com/u/1?v=4")!
        let image = UIImage(named: "avatar.png")
        let expectedResult: Result<UIImage?, Error> = .success(image)
        mockNetworkService = MockNetworkService(result: expectedResult)
        
        let expectation = XCTestExpectation(description: "Image loaded")
        
        downloader.load(url: url)
            .sink { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Unexpected error: \(error.localizedDescription)")
                }
            } receiveValue: { (receivedUrl, receivedImage) in
                XCTAssertEqual(receivedUrl, url)
                XCTAssertEqual(receivedImage, image) // Potential issue here
            }
            .store(in: &cancellables)
    }
    
    func testLoadImage_Failure() {
        let url = URL(string: "https://invalid-url.com")!
        let expectedFailureResult: Result<UIImage?, Error> = .failure(NetworkError.noData)
        mockNetworkService = MockNetworkService(result: expectedFailureResult)
        
        let expectation = XCTestExpectation(description: "Image load failed")
        
        var cancellables: Set<AnyCancellable> = []
        
        downloader.load(url: url)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail("Expected failure, but received completion")
                case .failure(let error as NetworkError):
                    XCTAssertEqual(error, NetworkError.noData)
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Unexpected error: \(error.localizedDescription)")
                }
            } receiveValue: { (_, _) in
                XCTFail("Expected failure, but received image")
            }
            .store(in: &cancellables)
    }
}
