import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(neeva_ios_supportTests.allTests),
    ]
}
#endif
