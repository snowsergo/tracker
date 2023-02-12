import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
           super.viewDidLoad()

           let viewController = TrackersViewController()
           let navigationController = UINavigationController(rootViewController: viewController)
        
           let statisticsViewController = StatisticsViewController()

        navigationController.tabBarItem = UITabBarItem(
                    title: NSLocalizedString("Трэкеры", comment: ""),
                    image: UIImage(named: "tracker-icon"),
                    selectedImage: nil
                )
        statisticsViewController.tabBarItem = UITabBarItem(
                    title: NSLocalizedString("Статистика", comment: ""),
                    image: UIImage(named: "statistics-icon"),
                    selectedImage: nil
                )
        self.viewControllers = [navigationController, statisticsViewController]
       }
}
