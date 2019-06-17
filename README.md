# ConfigKit
![swift >= 4.0](https://img.shields.io/badge/swift-%3E%3D4.0-brightgreen.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)

Structure for loading configuration details from file, environment, or command line

## Usage
```Swift
var config: Config = Config().load(fromFile: "/.../global_settings.json").load(fromFile: "~/.../local_settings.json")

if let connection = config.getConnection(withName: "web service") {
    let uri = conncetion.uri
    
}

```

## Dependancies
* **VersionKit** - Used for reference of the version of this package *ConfigKit.version* - [VersionKit](https://github.com/TheAngryDarling/SwiftVersionKit)

## Authors

* **Tyler Anger** - *Initial work* - [TheAngryDarling](https://github.com/TheAngryDarling)

## License

This project is licensed under Apache License v2.0 - see the [LICENSE.md](LICENSE.md) file for details

