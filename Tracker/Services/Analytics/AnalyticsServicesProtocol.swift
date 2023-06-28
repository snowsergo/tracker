import Foundation

protocol AnalyticsServicesProtocol {
    var isActivated: [Bool] { get }
    func openScreen(screen: String)
    func closeScreen(screen: String)
    func tapOn(screen: String, item: String)
}
