import Foundation

enum AppLinks: String {
    case privacyPolicy = "https://www.termsfeed.com/live/05f2db88-cc29-4fdd-98d3-c5857eb1d7c3"
    case termsOfUse = "https://www.termsfeed.com/live/ec0738bb-3503-4e86-90c0-b85711d92f52"

    var url: URL? {
        URL(string: rawValue)
    }
}
