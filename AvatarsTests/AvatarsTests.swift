import XCTest
import Combine

class MockNetworkService: NetworkServiceProtocol {
    
    var imageResult: Result<UIImage?, Error>?
    var apiResult: Result<Data, Error>?

    func downloadImage(url: String) -> AnyPublisher<UIImage?, Error> {
        if let result = imageResult {
            return Result.Publisher(result).eraseToAnyPublisher()
        } else {
            return Fail(error: NetworkError.noData).eraseToAnyPublisher()
        }
    }
    
    func getAPI<Object: Decodable>(url: String, resultType: Object.Type) -> AnyPublisher<Object, NetworkError> {
        if let result = apiResult {
            return Result.Publisher(result)
                .decode(type: Object.self, decoder: JSONDecoder())
                .mapError { _ in NetworkError.requestNotFormed }
                .eraseToAnyPublisher()
        } else {
            return Fail(error: NetworkError.requestNotFormed).eraseToAnyPublisher()
        }
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
        mockNetworkService = MockNetworkService()
        
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
        mockNetworkService = MockNetworkService()
        
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
