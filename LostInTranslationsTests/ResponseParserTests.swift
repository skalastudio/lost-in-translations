import Testing
@testable import LostInTranslations

/// Tests for ResponseParser behavior.
struct ResponseParserTests {
    /// Parses a minimal valid JSON response.
    @Test
    func parsesValidJSON() throws {
        let json = """
        {"results":[{"language":"EN","text":"Hello"},{"language":"PT","text":"Ola"}]}
        """
        let results = try ResponseParser.parse(json)
        #expect(results.count == 2)
        #expect(results.first?.text == "Hello")
    }
}
