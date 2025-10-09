import XCTest
@testable import TripPlanner

/// Example XCTest file to demonstrate XCTest framework support
/// This is just for demonstration - your actual tests use Swift Testing
class ExampleXCTestTests: XCTestCase {
    
    var sut: TripViewModel!
    
    override func setUp() {
        super.setUp()
        // Setup code here
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testExampleXCTest() {
        XCTAssertTrue(true, "This should pass")
    }
    
    func testAnotherXCTestMethod() {
        let result = 2 + 2
        XCTAssertEqual(result, 4, "Math should work")
    }
    
    func testXCTestAsyncMethod() async {
        // Async test
        let value = await someAsyncFunction()
        XCTAssertNotNil(value)
    }
    
    // This is a helper method and should NOT be detected as a test
    func helperMethod() {
        // Helper code
    }
    
    private func someAsyncFunction() async -> String {
        return "test"
    }
}
