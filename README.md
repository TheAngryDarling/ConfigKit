# ConfigKit

Structure for loading configuration details from file, environment, or commaind line

## Usage
```Swift
var config: Config = Config().load(fromFile: "/.../global_settings.json").load(fromFile: "~/.../local_settings.json")

if let connection = config.getConnection(withName: "web service") {
    let uri = conncetion.uri
    
}

```

## Dependancies
* **VersionKit** - Used for reference of the version of this package *ConfigKit.version* - [VersionKit](https://github.com/TheAngryDarling/VersionKit)

## Authors

* **Tyler Anger** - *Initial work* - [TheAngryDarling](https://github.com/TheAngryDarling)

## License

This project is licensed under Apache License v2.0 - see the [LICENSE.md](LICENSE.md) file for details

