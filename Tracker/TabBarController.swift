import UIKit

final class TabBarController: UITabBarController {
    var onboarding: UIViewController?

    init(onboarding: UIViewController?) {
        self.onboarding = onboarding
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let store = Store()
        let analyticsServices = AnalyticsServices(services: [AppMetrica(key: Const.appMetricaApiKey)])
        let viewController = TrackersViewController(store: store, analyticsServices: analyticsServices)
        let navigationController = UINavigationController(rootViewController: viewController)

        let statisticsViewController = UINavigationController(
            rootViewController: StatisticsViewController(
                viewModel: StatisticsViewModel(
                    model: StatisticsService(
                        store: store
                    )
                )
            )
        )

        navigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers", comment: ""),
            image: UIImage(named: "tracker-icon"),
            selectedImage: nil
        )
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics", comment: ""),
            image: UIImage(named: "statistics-icon"),
            selectedImage: nil
        )
        self.viewControllers = [navigationController, statisticsViewController]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentOnboarding()
    }
}


private extension TabBarController {
    func presentOnboarding() {
        if let onboarding {
            onboarding.modalPresentationStyle = .overFullScreen
            present(onboarding, animated: false)
            self.onboarding = nil
        }
    }
}
