// swift-tools-version: 6.0
import PackageDescription

// aum-session-swift: a standalone, on-device reader for AUM (Audio Unit Mixer)
// projects — `.aumproj` sessions and `.aum_midimap` standalone mappings.
//
// It decodes the bplist/NSKeyedArchiver graph an AUM file is and walks it into a
// flat `AUMSessionMap` (channels, nodes, MIDI mappings, routing). Pure Foundation
// — no daemon, no NSKeyedUnarchiver (which would need AUM's private classes), no
// SwiftUI. It builds and tests on Linux and Apple platforms alike.
//
// This is a faithful port of the Go read model in mcp-midi-controller
// (internal/aum: archive.go, session.go, spec.go, midimap.go); the Go library
// stays the source of truth for the format, this is the read-only subset.
let package = Package(
    name: "aum-session-swift",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "AUMSession", targets: ["AUMSession"]),
    ],
    targets: [
        .target(name: "AUMSession"),
        .testTarget(
            name: "AUMSessionTests",
            dependencies: ["AUMSession"],
            resources: [.copy("Fixtures/golden-example.aumproj")]
        ),
    ],
    // The session model types intentionally mirror a Swift 5 wire contract; the
    // parser bridges a binary format with no concurrency. Pin Swift 5 mode so a
    // consumer on either language mode links the same semantics.
    swiftLanguageModes: [.v5]
)
