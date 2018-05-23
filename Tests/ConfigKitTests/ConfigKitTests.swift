import XCTest
@testable import ConfigKit

final class ConfigKitTests: XCTestCase {
    
    static let config_str: String = "{}"
    static let CONFIG_PATH: String = "~/development/swift/config/unit_test_config.json"
    
    
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
