import Foundation

/// A service that provides basic mathematical operations
class MathService {
    
    // MARK: - Singleton
    static let shared = MathService()
    
    private init() {}
    
    // MARK: - Basic Operations
    
    /// Adds two numbers
    /// - Parameters:
    ///   - a: First number
    ///   - b: Second number
    /// - Returns: Sum of a and b
    func add(_ a: Double, _ b: Double) -> Double {
        return a + b
    }
    
    /// Subtracts second number from first
    /// - Parameters:
    ///   - a: First number
    ///   - b: Second number
    /// - Returns: Difference of a and b
    func subtract(_ a: Double, _ b: Double) -> Double {
        return a - b
    }
    
    /// Multiplies two numbers
    /// - Parameters:
    ///   - a: First number
    ///   - b: Second number
    /// - Returns: Product of a and b
    func multiply(_ a: Double, _ b: Double) -> Double {
        return a * b
    }
    
    /// Divides first number by second
    /// - Parameters:
    ///   - a: Numerator
    ///   - b: Denominator
    /// - Returns: Quotient of a and b, or nil if b is zero
    func divide(_ a: Double, _ b: Double) -> Double? {
        guard b != 0 else {
            return nil
        }
        return a / b
    }
    
    // MARK: - Advanced Operations
    
    /// Calculates the power of a number
    /// - Parameters:
    ///   - base: Base number
    ///   - exponent: Exponent
    /// - Returns: base raised to the power of exponent
    func power(_ base: Double, _ exponent: Double) -> Double {
        return pow(base, exponent)
    }
    
    /// Calculates the square root of a number
    /// - Parameter number: Number to calculate square root of
    /// - Returns: Square root, or nil if number is negative
    func squareRoot(_ number: Double) -> Double? {
        guard number >= 0 else {
            return nil
        }
        return sqrt(number)
    }
    
    /// Calculates the absolute value of a number
    /// - Parameter number: Number to get absolute value of
    /// - Returns: Absolute value
    func absolute(_ number: Double) -> Double {
        return abs(number)
    }
    
    /// Rounds a number to specified decimal places
    /// - Parameters:
    ///   - number: Number to round
    ///   - places: Number of decimal places
    /// - Returns: Rounded number
    func round(_ number: Double, toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return Darwin.round(number * multiplier) / multiplier
    }
    
    /// Calculates percentage
    /// - Parameters:
    ///   - value: Part value
    ///   - total: Total value
    /// - Returns: Percentage, or nil if total is zero
    func percentage(_ value: Double, of total: Double) -> Double? {
        guard total != 0 else {
            return nil
        }
        return (value / total) * 100
    }
    
    /// Finds the maximum of two numbers
    /// - Parameters:
    ///   - a: First number
    ///   - b: Second number
    /// - Returns: The larger number
    func max(_ a: Double, _ b: Double) -> Double {
        return Swift.max(a, b)
    }
    
    /// Finds the minimum of two numbers
    /// - Parameters:
    ///   - a: First number
    ///   - b: Second number
    /// - Returns: The smaller number
    func min(_ a: Double, _ b: Double) -> Double {
        return Swift.min(a, b)
    }
    
    /// Calculates average of an array of numbers
    /// - Parameter numbers: Array of numbers
    /// - Returns: Average, or nil if array is empty
    func average(_ numbers: [Double]) -> Double? {
        guard !numbers.isEmpty else {
            return nil
        }
        let sum = numbers.reduce(0, +)
        return sum / Double(numbers.count)
    }
    
    /// Calculates sum of an array of numbers
    /// - Parameter numbers: Array of numbers
    /// - Returns: Sum of all numbers
    func sum(_ numbers: [Double]) -> Double {
        return numbers.reduce(0, +)
    }
}
