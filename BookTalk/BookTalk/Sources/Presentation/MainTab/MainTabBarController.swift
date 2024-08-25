//
//  MainTabBarController.swift
//  BookTalk
//
//  Created by RAFA on 7/23/24.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }
    
    // MARK: - Helpers
    
    private func configureViewControllers() {
        let homeViewModel = HomeViewModel(
            userData: UserData.shared,
            bookService: BookService()
        )
        
        let home = createNavigationController(
            title: "홈",
            unselectedImage: "house",
            selectedImage: "house.fill",
            rootViewController: HomeViewController(viewModel: homeViewModel)
        )
        
        let category = createNavigationController(
            title: "카테고리",
            unselectedImage: "square.grid.2x2",
            selectedImage: "square.grid.2x2.fill",
            rootViewController: FirstCategoryViewController()
        )
        
        let openTalkViewModel = OpenTalkViewModel()
        let openTalk = createNavigationController(
            title: "오픈톡",
            unselectedImage: "message",
            selectedImage: "message.fill",
            rootViewController: OpenTalkViewController(viewModel: openTalkViewModel)
        )
        
        // TODO: 목표 탭 추가
//        let goalViewModel = GoalViewModel()
//        let goal = createNavigationController(
//            title: "목표",
//            unselectedImage: "chart.xyaxis.line",
//            selectedImage: "chart.xyaxis.line",
//            rootViewController: GoalViewController(viewModel: goalViewModel)
//        )
        
        let my = createNavigationController(
            title: "마이",
            unselectedImage: "person",
            selectedImage: "person.fill",
            rootViewController: MyViewController()
        )
        
        viewControllers = [home, category, openTalk, my]
    }
    
    private func createNavigationController(
        title: String,
        unselectedImage: String,
        selectedImage: String,
        rootViewController: UIViewController
    ) -> UINavigationController {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .accentOrange
        
        let tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: unselectedImage),
            selectedImage: UIImage(systemName: selectedImage)
        )
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem = tabBarItem
        navigationController.navigationBar.tintColor = .black
        navigationController.navigationBar.topItem?.title = ""
        
        return navigationController
    }
}
