//
//  PlayerScreenContainerVC.swift


import UIKit

protocol PlayerScreenContainerVCDelegate: class {
    func containerViewController(_ containerViewController: PlayerScreenContainerVC, indexDidUpdate currentIndex: Int)
}

class PlayerScreenContainerVC: BaseUIViewController, UIGestureRecognizerDelegate {

    weak var delegate: PlayerScreenContainerVCDelegate?
    
    private var pageViewController: UIPageViewController {
        return self.children[0] as! UIPageViewController
    }
    
    private var currentViewController: PlayerScreenVC {
        return self.pageViewController.viewControllers![0] as! PlayerScreenVC
    }
    
    // MARK: View Model
    var viewModel: PlayerScreenContainerVM!
    var currentIndex = 0
    var nextIndex: Int?
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var transitionController = ZoomTransitionController()
    

    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    private func initialSetup() {
        setupNavigationBar()
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWith(gestureRecognizer:)))
        self.panGestureRecognizer.delegate = self
        self.pageViewController.view.addGestureRecognizer(self.panGestureRecognizer)
       
        let vc = PlayerScreenVC.instantiate(fromAppStoryboard: .main)
        vc.viewModel = PlayerScreenVM(video: viewModel.videos[currentIndex], index: currentIndex)
        let viewControllers = [
            vc
        ]
        
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
    }
    
    private func setupNavigationBar() {
        setNavigationBar(clearBg: true)
        addLeftButtonToNavigation(image: AppImages.backWhite)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gestureRecognizer.velocity(in: self.view)
            
            var velocityCheck : Bool = false
            
            if UIDevice.current.orientation.isLandscape {
                velocityCheck = velocity.x < 0
            }
            else {
                velocityCheck = velocity.y < 0
            }
            if velocityCheck {
                return false
            }
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if otherGestureRecognizer == self.currentViewController.scrollView.panGestureRecognizer {
            if self.currentViewController.scrollView.contentOffset.y == 0 {
                return true
            }
        }
        
        return false
    }
    
    
    @objc func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.currentViewController.scrollView.isScrollEnabled = false
            self.transitionController.isInteractive = true
            let _ = self.navigationController?.popViewController(animated: true)
        case .ended:
            if self.transitionController.isInteractive {
                self.currentViewController.scrollView.isScrollEnabled = true
                self.transitionController.isInteractive = false
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        default:
            if self.transitionController.isInteractive {
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        }
    }

}

extension PlayerScreenContainerVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentIndex == 0 {
            return nil
        }
        let vc = PlayerScreenVC.instantiate(fromAppStoryboard: .main)
        vc.viewModel = PlayerScreenVM(video: viewModel.videos[currentIndex - 1], index: currentIndex - 1)
        return vc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == (self.viewModel.videos.count - 1) {
            return nil
        }
        
        let vc = PlayerScreenVC.instantiate(fromAppStoryboard: .main)
        vc.viewModel = PlayerScreenVM(video: viewModel.videos[currentIndex + 1], index: currentIndex + 1)
        return vc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let nextVC = pendingViewControllers.first as? PlayerScreenVC else {
            return
        }
        self.nextIndex = nextVC.viewModel.index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (completed && self.nextIndex != nil) {
            previousViewControllers.forEach { vc in
                let zoomVC = vc as! PlayerScreenVC
                zoomVC.scrollView.zoomScale = zoomVC.scrollView.minimumZoomScale
            }
            self.currentIndex = self.nextIndex!
            self.delegate?.containerViewController(self, indexDidUpdate: self.currentIndex)
        }
        
        self.nextIndex = nil
    }
    
}

extension PlayerScreenContainerVC: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        return self.currentViewController.imageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {        
        return self.currentViewController.scrollView.convert(self.currentViewController.imageView.frame, to: self.currentViewController.view)
    }
}
