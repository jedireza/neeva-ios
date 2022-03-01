# `Confetti Swift UI`

This file is an adaptation of [ConfettiSwiftUI](https://github.com/simibac/ConfettiSwiftUI).
Almost all animation code and timings were kept intact and mainly the SwiftUI pieces were refactored. Notably:

- `ConfettiConfig` is turned into a Struct and all `StateObject` uses were turned into constants
- `ConfettiType` was removed to get rid of all casts to `AnyView`
- Small changes to remove unused parameters
