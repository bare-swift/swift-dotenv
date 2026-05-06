// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Sendable, Foundation-free `.env` parser with `${VAR}` expansion.
///
/// Pure function: feed a string of `.env` contents, get back ordered
/// ``DotEnv/Entry`` values. File I/O and process-environment mutation are
/// intentionally out of scope.
public enum DotEnv: Sendable {}
