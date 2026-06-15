import XCTest
@testable import AUMSession

final class AUMSessionParserTests: XCTestCase {
    /// Load the committed golden `.aumproj` fixture (a generic, non-private
    /// example session) bundled with the test target.
    private func goldenData() throws -> Data {
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "golden-example", withExtension: "aumproj"),
            "golden-example.aumproj fixture missing from the test bundle"
        )
        return try Data(contentsOf: url)
    }

    /// The end-to-end contract: a real AUM project decodes into a full session
    /// map with channels and assigned MIDI mappings. Exact counts are pinned as
    /// a regression guard — if the bplist/graph walk drifts, these move.
    func testParsesGoldenSession() throws {
        let map = try AUMSessionParser.parse(data: try goldenData(), isMidiMap: false)

        XCTAssertGreaterThan(map.version, 0, "a real session carries a format version")
        XCTAssertEqual(map.channels.count, Expected.channels)
        XCTAssertEqual(map.mappings.count, Expected.mappings)

        // Every surfaced mapping is an assigned trigger (placeholders dropped)
        // with a resolved, non-"type<n>" label.
        for m in map.mappings {
            XCTAssertTrue(m.enabled)
            XCTAssertFalse(m.typeName.hasPrefix("type"), "unresolved label: \(m.typeName)")
            XCTAssertTrue((0...15).contains(m.channel), "0-based stored channel out of range: \(m.channel)")
        }
    }

    /// The specState (v13) and packed (v8/10) encodings use different type enums
    /// for the same musical message — the split the parser depends on.
    func testTypeLabelEncodingSplit() {
        XCTAssertEqual(MappingInfo.typeLabel(specState: true, type: 1, data1: 0), "Note")
        XCTAssertEqual(MappingInfo.typeLabel(specState: false, type: 5, data1: 0), "Note")
        XCTAssertEqual(MappingInfo.typeLabel(specState: true, type: 0, data1: 7), "CC")
        XCTAssertEqual(MappingInfo.typeLabel(specState: true, type: 3, data1: 1), "CHPRS")
        XCTAssertEqual(MappingInfo.typeLabel(specState: true, type: 3, data1: 0), "PBEND")
    }

    /// A non-archive blob is rejected, not silently parsed into an empty map.
    func testRejectsNonArchive() {
        XCTAssertThrowsError(try AUMSessionParser.parse(data: Data("not a plist".utf8), isMidiMap: false))
    }
}

private enum Expected {
    // Pinned from the committed golden-example.aumproj on first green run.
    static let channels = 3
    static let mappings = 51
}
