import XCTest
@testable import ImageProvide

final class ImageAskStepsTests: XCTestCase {
    private let askURL = URL(string: "https://image.tmdb.org/t/p/w1280/3iYQTLGoy7QnjcUYRJy4YrAgGvp.jpg")!
    
    func testStepsWithNoActions() {
        let ask = ImageAsk(url: askURL)
        let steps = ask.actionChain.steps
        XCTAssertEqual(1, steps.count)
    }

    func testStepsWithTwoActions() {
        let ask = ImageAsk(url: askURL)
                .scaled(to: .zero, mode: .aspectFill)
                .scaled(to: .zero, mode: .aspectFit)
                
        let steps = ask.actionChain.steps
        XCTAssertEqual(3, steps.count)
        
        XCTAssertEqual(0, steps[0].actionsCount)
        XCTAssertEqual(1, steps[1].actionsCount)
        XCTAssertEqual(2, steps[2].actionsCount)
    }
    
    func testPlacholderForwarded() {
        let ask = ImageAsk(url: askURL, placeholder: ImageAsk(url: URL(string: "placeholder://poster")!))
                .scaled(to: .zero, mode: .aspectFill)
        
        XCTAssertNotNil(ask.actionChain.steps.last?.placeholder)
    }
}
