# ``DotEnv``

Sendable, Foundation-free `.env` parser for Swift 6 with `${VAR}` expansion.

## Overview

`DotEnv.parse(_:baseEnvironment:)` takes a `.env` file's contents as a
`String` and returns ordered ``DotEnv/Entry`` values. File I/O and
process-environment loading are intentionally out of scope — caller policy.

```swift
import DotEnv

let entries = try DotEnv.parse("""
DATABASE_URL=postgres://localhost/app
PORT=8080
GREETING="Hello, ${USER}!"
""", baseEnvironment: ["USER": "world"])

for e in entries { print("\(e.key)=\(e.value)") }
```

`${VAR}` and `$VAR` references resolve against, in order: previously-seen
entries in the same input, the supplied `baseEnvironment`, otherwise the
empty string. Single-quoted values are literal. Double-quoted values
support escape sequences and expansion.

## Topics

### Parsing

- ``DotEnv/parse(_:baseEnvironment:)``
- ``DotEnv/Entry``

### Errors

- ``DotEnvError``
