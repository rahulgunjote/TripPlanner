import XCTest
@testable import TripPlanner

class MathServiceTests: XCTestCase {
    
    var sut: MathService!
    
    override func setUp() {
        super.setUp()
        sut = MathService.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Addition Tests
    
    func testAddPositiveNumbers() {
        let result = sut.add(5, 3)
        XCTAssertEqual(result, 8.0)
    }
    
    func testAddNegativeNumbers() {
        let result = sut.add(-5, -3)
        XCTAssertEqual(result, -8.0)
    }
    
    func testAddMixedNumbers() {
        let result = sut.add(-5, 10)
        XCTAssertEqual(result, 5.0)
    }
    
    func testAddZero() {
        let result = sut.add(5, 0)
        XCTAssertEqual(result, 5.0)
    }
    
    func testAddDecimals() {
        let result = sut.add(1.5, 2.3)
        XCTAssertEqual(result, 3.8, accuracy: 0.0001)
    }
    
    // MARK: - Subtraction Tests
    
    func testSubtractPositiveNumbers() {
        let result = sut.subtract(10, 3)
        XCTAssertEqual(result, 7.0)
    }
    
    func testSubtractNegativeNumbers() {
        let result = sut.subtract(-5, -3)
        XCTAssertEqual(result, -2.0)
    }
    
    func testSubtractMixedNumbers() {
        let result = sut.subtract(5, -3)
        XCTAssertEqual(result, 8.0)
    }
    
    func testSubtractToNegative() {
        let result = sut.subtract(3, 10)
        XCTAssertEqual(result, -7.0)
    }
    
    func testSubtractZero() {
        let result = sut.subtract(5, 0)
        XCTAssertEqual(result, 5.0)
    }
    
    // MARK: - Multiplication Tests
    
    func testMultiplyPositiveNumbers() {
        let result = sut.multiply(5, 3)
        XCTAssertEqual(result, 15.0)
    }
    
    func testMultiplyNegativeNumbers() {
        let result = sut.multiply(-5, -3)
        XCTAssertEqual(result, 15.0)
    }
    
    func testMultiplyMixedNumbers() {
        let result = sut.multiply(-5, 3)
        XCTAssertEqual(result, -15.0)
    }
    
    func testMultiplyByZero() {
        let result = sut.multiply(5, 0)
        XCTAssertEqual(result, 0.0)
    }
    
    func testMultiplyDecimals() {
        let result = sut.multiply(2.5, 4.0)
        XCTAssertEqual(result, 10.0)
    }
    
    // MARK: - Division Tests
    
    func testDividePositiveNumbers() {
        let result = sut.divide(10, 2)
        XCTAssertEqual(result, 5.0)
    }
    
    func testDivideNegativeNumbers() {
        let result = sut.divide(-10, -2)
        XCTAssertEqual(result, 5.0)
    }
    
    func testDivideMixedNumbers() {
        let result = sut.divide(-10, 2)
        XCTAssertEqual(result, -5.0)
    }
    
    func testDivideByZeroReturnsNil() {
        let result = sut.divide(10, 0)
        XCTAssertNil(result)
    }
    
    func testDivideZeroByNumber() {
        let result = sut.divide(0, 5)
        XCTAssertEqual(result, 0.0)
    }
    
    func testDivideDecimals() {
        let result = sut.divide(7.5, 2.5)
        XCTAssertEqual(result, 3.0)
    }
    
    // MARK: - Power Tests
    
    func testPowerPositiveExponent() {
        let result = sut.power(2, 3)
        XCTAssertEqual(result, 8.0)
    }
    
    func testPowerZeroExponent() {
        let result = sut.power(5, 0)
        XCTAssertEqual(result, 1.0)
    }
    
    func testPowerNegativeExponent() {
        let result = sut.power(2, -2)
        XCTAssertEqual(result, 0.25)
    }
    
    func testPowerDecimalExponent() {
        let result = sut.power(4, 0.5)
        XCTAssertEqual(result, 2.0, accuracy: 0.0001)
    }
    
    // MARK: - Square Root Tests
    
    func testSquareRootPositiveNumber() {
        let result = sut.squareRoot(9)
        XCTAssertEqual(result, 3.0)
    }
    
    func testSquareRootZero() {
        let result = sut.squareRoot(0)
        XCTAssertEqual(result, 0.0)
    }
    
    func testSquareRootNegativeReturnsNil() {
        let result = sut.squareRoot(-9)
        XCTAssertNil(result)
    }
    
    func testSquareRootDecimal() {
        let result = sut.squareRoot(2.25)
        XCTAssertEqual(result, 1.5, accuracy: 0.0001)
    }
    
    // MARK: - Absolute Value Tests
    
    func testAbsolutePositiveNumber() {
        let result = sut.absolute(5)
        XCTAssertEqual(result, 5.0)
    }
    
    func testAbsoluteNegativeNumber() {
        let result = sut.absolute(-5)
        XCTAssertEqual(result, 5.0)
    }
    
    func testAbsoluteZero() {
        let result = sut.absolute(0)
        XCTAssertEqual(result, 0.0)
    }
    
    // MARK: - Rounding Tests
    
    func testRoundToZeroPlaces() {
        let result = sut.round(3.7, toPlaces: 0)
        XCTAssertEqual(result, 4.0)
    }
    
    func testRoundToOnePlace() {
        let result = sut.round(3.14159, toPlaces: 1)
        XCTAssertEqual(result, 3.1)
    }
    
    func testRoundToTwoPlaces() {
        let result = sut.round(3.14159, toPlaces: 2)
        XCTAssertEqual(result, 3.14)
    }
    
    func testRoundNegativeNumber() {
        let result = sut.round(-3.14159, toPlaces: 2)
        XCTAssertEqual(result, -3.14)
    }
    
    // MARK: - Percentage Tests
    
    func testPercentageCalculation() {
        let result = sut.percentage(25, of: 100)
        XCTAssertEqual(result, 25.0)
    }
    
    func testPercentageOverHundred() {
        let result = sut.percentage(150, of: 100)
        XCTAssertEqual(result, 150.0)
    }
    
    func testPercentageOfZeroReturnsNil() {
        let result = sut.percentage(25, of: 0)
        XCTAssertNil(result)
    }
    
    func testPercentageDecimal() {
        let result = sut.percentage(33.33, of: 100)
        XCTAssertEqual(result, 33.33, accuracy: 0.01)
    }
    
    // MARK: - Max Tests
    
    func testMaxPositiveNumbers() {
        let result = sut.max(5, 10)
        XCTAssertEqual(result, 10.0)
    }
    
    func testMaxNegativeNumbers() {
        let result = sut.max(-5, -10)
        XCTAssertEqual(result, -5.0)
    }
    
    func testMaxMixedNumbers() {
        let result = sut.max(-5, 3)
        XCTAssertEqual(result, 3.0)
    }
    
    func testMaxEqualNumbers() {
        let result = sut.max(5, 5)
        XCTAssertEqual(result, 5.0)
    }
    
    // MARK: - Min Tests
    
    func testMinPositiveNumbers() {
        let result = sut.min(5, 10)
        XCTAssertEqual(result, 5.0)
    }
    
    func testMinNegativeNumbers() {
        let result = sut.min(-5, -10)
        XCTAssertEqual(result, -10.0)
    }
    
    func testMinMixedNumbers() {
        let result = sut.min(-5, 3)
        XCTAssertEqual(result, -5.0)
    }
    
    func testMinEqualNumbers() {
        let result = sut.min(5, 5)
        XCTAssertEqual(result, 5.0)
    }
    
    // MARK: - Average Tests
    
    func testAveragePositiveNumbers() {
        let result = sut.average([1, 2, 3, 4, 5])
        XCTAssertEqual(result, 3.0)
    }
    
    func testAverageMixedNumbers() {
        let result = sut.average([-5, 0, 5, 10])
        XCTAssertEqual(result, 2.5)
    }
    
    func testAverageSingleNumber() {
        let result = sut.average([5])
        XCTAssertEqual(result, 5.0)
    }
    
    func testAverageEmptyArrayReturnsNil() {
        let result = sut.average([])
        XCTAssertNil(result)
    }
    
    func testAverageDecimals() {
        let result = sut.average([1.5, 2.5, 3.5])
        XCTAssertEqual(result, 2.5, accuracy: 0.0001)
    }
    
    // MARK: - Sum Tests
    
    func testSumPositiveNumbers() {
        let result = sut.sum([1, 2, 3, 4, 5])
        XCTAssertEqual(result, 15.0)
    }
    
    func testSumNegativeNumbers() {
        let result = sut.sum([-1, -2, -3])
        XCTAssertEqual(result, -6.0)
    }
    
    func testSumMixedNumbers() {
        let result = sut.sum([-5, 10, -3, 8])
        XCTAssertEqual(result, 10.0)
    }
    
    func testSumEmptyArray() {
        let result = sut.sum([])
        XCTAssertEqual(result, 0.0)
    }
    
    func testSumSingleNumber() {
        let result = sut.sum([5])
        XCTAssertEqual(result, 5.0)
    }
    
    // MARK: - Singleton Tests
    
    func testSingletonReturnsSameInstance() {
        let instance1 = MathService.shared
        let instance2 = MathService.shared
        XCTAssertTrue(instance1 === instance2)
    }
}
