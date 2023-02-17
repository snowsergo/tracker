import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

            func scene(
                _ scene: UIScene,
                willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
            ) {
                guard let scene = (scene as? UIWindowScene) else { return }
                let window = UIWindow(windowScene: scene)
                let rootViewController = TabBarController(onboarding: OnboardingViewController())
                window.rootViewController = rootViewController
                window.makeKeyAndVisible()
                self.window = window
            }
}
