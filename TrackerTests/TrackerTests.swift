import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testHomeViewControllerLight() {
        //isRecording = true
        let vc = UINavigationController(
            rootViewController: TrackersViewController(store: Store())
        )

        assertSnapshots(matching: vc, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }

    func testHomeViewControllerDark() {
        //isRecording = true
        let vc = UINavigationController(
            rootViewController: TrackersViewController(store: Store())
        )

        assertSnapshots(matching: vc, as: [.image(traits: .init(userInterfaceStyle: .dark))])
    }
}
