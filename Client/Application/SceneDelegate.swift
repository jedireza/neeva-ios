// Copyright Neeva. All rights reserved.

import Shared
import Storage
import SDWebImage
import Defaults

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var scene: UIScene?

    private var tabManager: TabManager!
    private var tabTrayController: TabTrayControllerV1!
    private var browserViewController: BrowserViewController!
    private var geigerCounter: KMCGeigerCounter?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        self.scene = scene
        
        guard let scene = (scene as? UIWindowScene) else { return }

        window = .init(windowScene: scene)
        window?.makeKeyAndVisible()

        setupRootViewController(scene)

        if Defaults[.enableGeigerCounter] {
            startGeigerCounter()
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        self.scene = scene
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        tabManager.preserveTabs()
    }
    
    private func setupRootViewController(_ scene: UIScene) {
        let profile = getAppDelegateProfile()

        self.tabManager = TabManager(profile: profile, scene: scene)
        self.browserViewController = BrowserViewController(profile: profile, tabManager: tabManager)
        self.tabTrayController = TabTrayControllerV1(tabManager: tabManager, profile: profile)

        browserViewController.edgesForExtendedLayout = []
        browserViewController.restorationIdentifier = NSStringFromClass(BrowserViewController.self)
        browserViewController.restorationClass = AppDelegate.self

        let navigationController = NavigationController(rootViewController: browserViewController)
        navigationController.delegate = self
        navigationController.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        window!.rootViewController = navigationController

        browserViewController.tabManager.selectedTab?.reload()
    }

    public func getBVC() -> BrowserViewController {
        return browserViewController
    }

    public func startGeigerCounter() {
        if let scene = self.scene as? UIWindowScene {
            geigerCounter = KMCGeigerCounter(windowScene: scene)
        }
    }
    public func stopGeigerCounter() {
        geigerCounter?.disable()
        geigerCounter = nil
    }

    // MARK: Get data from current scene
    static func getCurrentSceneDelegate() -> SceneDelegate {
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive || UIApplication.shared.connectedScenes.count == 1, let sceneDelegate = ((scene as? UIWindowScene)?.delegate as? SceneDelegate) {
                return sceneDelegate
            }
        }

        fatalError("Scene Delegate doesn't exist or is nil")
    }

    static func getForegroundTabTrayController() -> TabTrayControllerV1? {
        return getCurrentSceneDelegate().tabTrayController
    }

    static func getCurrentScene() -> UIScene {
        if let scene = getCurrentSceneDelegate().scene {
            return scene
        }

        fatalError("Scene doesn't exist or is nil")
    }

    static func getCurrentSceneId() -> String {
        return getCurrentScene().session.persistentIdentifier
    }
}

// MARK: - Root View Controller Animations
extension SceneDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return BrowserToTrayAnimator()
        case .pop:
            return TrayToBrowserAnimator()
        default:
            return nil
        }
    }
}
