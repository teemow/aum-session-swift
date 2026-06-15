import Foundation

/// The AudioComponentDescription identity of an audio unit referenced by an AUM
/// session node. `type` / `subtype` / `manufacturer` are FourCharCode (`OSType`)
/// values rendered as 4-character strings (e.g. "aumu", "aufx"); the parser
/// decodes these three from a node's `audioComponentDescription` blob. The
/// remaining fields exist so a host that already knows an AU's human metadata
/// (manufacturer/version/type names, tags) can carry it on the same identity —
/// they are never populated by the parser itself.
///
/// This mirrors the same identity the mcp-midi-controller wire contract uses
/// (Go `device.ProbeComponent`); each repo pins its own copy of the contract.
public struct AudioUnitComponent: Codable, Equatable {
    public var type: String
    public var subtype: String
    public var manufacturer: String
    public var manufacturerName: String?
    public var version: String?
    /// Human-readable component type (e.g. "Instrument", "Effect").
    public var typeName: String?
    /// Component tags (e.g. "Effects", "Distortion"). Omitted when empty.
    public var tags: [String]?

    public init(type: String, subtype: String, manufacturer: String,
                manufacturerName: String? = nil, version: String? = nil,
                typeName: String? = nil, tags: [String]? = nil) {
        self.type = type
        self.subtype = subtype
        self.manufacturer = manufacturer
        self.manufacturerName = manufacturerName
        self.version = version
        self.typeName = typeName
        self.tags = tags
    }
}
