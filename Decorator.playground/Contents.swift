// Design Patterns: Decorator

import Foundation

// Helpers (may be not include in blog post)

func encryptString(_ string: String, with encryptionKey: String) -> String {
    let stringBytes = [UInt8](string.utf8)
    let keyBytes = [UInt8](encryptionKey.utf8)
    var encryptedBytes: [UInt8] = []
    
    for stringByte in stringBytes.enumerated() {
        encryptedBytes.append(stringByte.element ^ keyBytes[stringByte.offset % encryptionKey.count])
    }
    
    return String(bytes: encryptedBytes, encoding: .utf8)!
}

func decryptString(_ string: String, with encryptionKey: String) -> String {
    let stringBytes = [UInt8](string.utf8)
    let keyBytes = [UInt8](encryptionKey.utf8)
    var decryptedBytes: [UInt8] = []
    
    for stringByte in stringBytes.enumerated() {
        decryptedBytes.append(stringByte.element ^ keyBytes[stringByte.offset % encryptionKey.count])
    }
    
    return String(bytes: decryptedBytes, encoding: .utf8)!
}

// Services

protocol DataSource: class {
    func writeData(_ data: Any)
    func readData() -> Any
}

class UserDefaultsDataSource: DataSource {
    private let userDefaultsKey: String
    
    init(userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
    }
    
    func writeData(_ data: Any) {
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
    
    func readData() -> Any {
        return UserDefaults.standard.value(forKey: userDefaultsKey)!
    }
}

// Decorators

class DataSourceDecorator: DataSource {
    let wrappee: DataSource
    
    init(wrappee: DataSource) {
        self.wrappee = wrappee
    }
    
    func writeData(_ data: Any) {
        wrappee.writeData(data)
    }
    
    func readData() -> Any {
        return wrappee.readData()
    }
}

class EncodingDecorator: DataSourceDecorator {
    private let encoding: String.Encoding
    
    init(wrappee: DataSource, encoding: String.Encoding) {
        self.encoding = encoding
        super.init(wrappee: wrappee)
    }
    
    override func writeData(_ data: Any) {
        let stringData = (data as! String).data(using: encoding)!
        wrappee.writeData(stringData)
    }
    
    override func readData() -> Any {
        let data = wrappee.readData() as! Data
        return String(data: data, encoding: encoding)!
    }
}

class EncryptionDecorator: DataSourceDecorator {
    private let encryptionKey: String
    
    init(wrappee: DataSource, encryptionKey: String) {
        self.encryptionKey = encryptionKey
        super.init(wrappee: wrappee)
    }
    
    override func writeData(_ data: Any) {
        let encryptedString = encryptString(data as! String, with: encryptionKey)
        wrappee.writeData(encryptedString)
    }
    
    override func readData() -> Any {
        let encryptedString = wrappee.readData() as! String
        return decryptString(encryptedString, with: encryptionKey)
    }
}

// Usage

var source: DataSource = UserDefaultsDataSource(userDefaultsKey: "decorator")
source = EncodingDecorator(wrappee: source, encoding: .utf8)
source = EncryptionDecorator(wrappee: source, encryptionKey: "secret")
source.writeData("Design Patterns")
source.readData() as! String

// Result:
// Design Patterns
