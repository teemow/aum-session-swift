# aum-session-swift

A standalone, on-device **reader for [AUM](https://kymatica.com/apps/aum) projects** —
`.aumproj` sessions and `.aum_midimap` standalone MIDI mappings — in pure Swift.

It decodes the binary-plist / `NSKeyedArchiver` object graph an AUM file is and
walks it into a flat [`AUMSessionMap`](Sources/AUMSession/AUMSessionModels.swift):
mixer channels, hosted plugin nodes, assigned MIDI mappings, and the MIDI
routing matrix. No daemon, no `NSKeyedUnarchiver` (which would need AUM's private
classes registered), no SwiftUI — just `Foundation`, so it builds and tests on
Linux and Apple platforms alike.

This is a faithful port of the Go read model in `mcp-midi-controller`
(`internal/aum`); the Go library stays the source of truth for the format, this
is the read-only subset a host app needs on-device.

## Install

Swift Package Manager:

```swift
.package(url: "https://github.com/teemow/aum-session-swift.git", from: "0.1.0"),
```

then add `AUMSession` to your target's dependencies.

## Use

```swift
import AUMSession

let data = try Data(contentsOf: aumprojURL)
let map = try AUMSessionParser.parse(data: data, isMidiMap: false)

print(map.version, map.tempo ?? 0)
for channel in map.channels {
    print(channel.title ?? "—", channel.nodes?.count ?? 0)
}
for mapping in map.mappings where mapping.enabled {
    print(mapping.collection, mapping.target, mapping.valueLabel, "ch \(mapping.channel + 1)")
}
```

`parse(data:isMidiMap:)` auto-detects a full session (it carries `channels` /
`midiCtrlState`) from a standalone collection; `isMidiMap` only tips the
ambiguous case (an empty/odd root).

### What you get

- **`AUMSessionMap`** — `version`, `tempo`, `channels`, `mappings`, `routes`.
- **`ChannelInfo`** — one mixer strip, with its `NodeInfo` chain.
- **`NodeInfo`** — one plugin / built-in node; `component` carries the
  AUv3 `AudioUnitComponent` identity (type/subtype/manufacturer) for hosted
  plugins. Note `slot` is a raw archive index, **not** signal-chain order.
- **`MappingInfo`** — one assigned MIDI control: `type` / `typeName`
  (`CC`/`Note`/`PC`/`PBEND`/`CHPRS`), `data1`, 0-based `channel`, range.
  Unassigned placeholder leaves are dropped.
- **`MidiRoute`** — one source→destination edge of AUM's MIDI matrix.

The two on-disk mapping encodings (specState in v13 / packed in v8–10) use
different type enums for the same message; `MappingInfo.typeLabel(specState:…)`
resolves both.

## Privacy

Session titles, channel names, node component sets and endpoint names are an
installation snapshot. Render them in-UI if you like, but **never log or commit
them**.

## Build & test

```sh
swift build
swift test
```

The test suite parses a committed, generic golden session and pins its decoded
shape as a regression guard.

## License

See [LICENSE](LICENSE).
