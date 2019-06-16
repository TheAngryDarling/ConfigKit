import XCTest
@testable import ConfigKit

final class ConfigKitTests: XCTestCase {
    
    
    static let packageRootPath: String = String(URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst())
    
    static let testPackageRootPath: String = packageRootPath + "/Tests"
    static let testPackagePath: String = String(URL(fileURLWithPath: #file).pathComponents.dropLast().joined(separator: "/").dropFirst())
    static let testPackageResourcePath: String = testPackageRootPath + "/resources"
    
    
    static let config_str: String = "{}"
    
    static let CONFIG_PATH: String =  testPackageResourcePath.appending("/unit_test_config.json")
    
    
    func testGenerateConnection() {
        let config = Config()
        let conn = Config.Connection(name: "Test", uri: "http://...", credentials: .apikey(key: "blahAPIKEYblah"))
        config.addConnection(conn)
        print(config)
    }
    func testLoadConfigFromString() {
        do {
            let config = try Config().load(fromString: ConfigKitTests.config_str, usingDecoderType: .json).loadFromEnv { key in
                return key.hasPrefix("SWIFT")
            }
            print(config)
        } catch {
            XCTFail("Exception Thrown \(error)")
        }
    }
    func testCreateConfig() {
        do {
            let config = try Config().load(fromFile: ConfigKitTests.CONFIG_PATH).loadFromEnv { key in
                return key.hasPrefix("SWIFT")
            }
            print(config)
        } catch {
            XCTFail("Exception Thrown \(error)")
        }
    }


    static var allTests = [
        ("testCreateConfig", testCreateConfig),
    ]
}
