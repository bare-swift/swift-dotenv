# swift-dotenv

Sendable, Foundation-free `.env` parser for Swift 6 with `${VAR}` expansion.

The `.env` format has no formal spec; this package implements the de facto behavior codified by the [`dotenvy`](https://crates.io/crates/dotenvy) Rust crate (which is shared with Node `dotenv`, Ruby `dotenv`, and Python `python-dotenv`).

Part of the [bare-swift](https://github.com/bare-swift) ecosystem.

## Install

Add to your `Package.swift`:

```swift
.package(url: "https://github.com/bare-swift/swift-dotenv.git", from: "0.1.0")
```

Then depend on the `DotEnv` product:

```swift
.product(name: "DotEnv", package: "swift-dotenv")
```

## Usage

```swift
import DotEnv

let source = """
# Twelve-factor demo
DATABASE_URL=postgres://localhost/app
PORT=8080
GREETING="Hello, ${USER}!"
SECRET='literal $string with no expansion'
export FEATURE_FLAGS=fast,quiet
"""

let entries = try DotEnv.parse(source, baseEnvironment: ["USER": "world"])
for e in entries {
    print("\(e.key)=\(e.value)  // line \(e.line)")
}

// Last-wins flatten:
let env = entries.dictionary
print(env["GREETING"]!)  // Hello, world!
```

File I/O is left to the caller — read the file with whatever you already use:

```swift
import Foundation
let raw = try String(contentsOfFile: ".env", encoding: .utf8)
let entries = try DotEnv.parse(raw, baseEnvironment: ProcessInfo.processInfo.environment)
```

## Documentation

Full DocC documentation: <https://bare-swift.github.io/swift-dotenv/>

## Source

Translated from the Rust crate [`dotenvy`](https://crates.io/crates/dotenvy).

## License

Apache 2.0 with LLVM exception. See [LICENSE](./LICENSE) and [NOTICE](./NOTICE).
