//
//  BaseUIViewController.swift

import UIKit

class BaseUIViewController: UIViewController {
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Can be overridden
    @objc func leftBarButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func rightBarButtonTapped(){
        
    }
    
    // MARK: Public Methods
    final func setNavigationBar(title: String = "",
                                largeTitles: Bool = false,
                                clearBg: Bool = false) {
        self.navigationItem.title = title
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.black]
        self.applyTransparentBackgroundToTheNavigationBar(0)
        self.navigationController?.navigationBar.barTintColor = clearBg ? .clear : AppColors.appTheme
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.prefersLargeTitles = largeTitles
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30), NSAttributedString.Key.foregroundColor: UIColor.black]
  
    }

    func addRightButtonToNavigation(title : String? = nil, titleColor: UIColor = .black, image: UIImage? = nil, font: UIFont? = nil){
        let rightButton = UIButton(type: .custom)
        if let title = title{
            rightButton.setTitle(title, for: .normal)
        }
        rightButton.setTitleColor(titleColor, for: .normal)
        if let providedFont = font {
            rightButton.titleLabel?.font = providedFont
        } else {
            rightButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        }
        if let image = image{
            rightButton.setImage(image, for: .normal)
        }
        rightButton.addTarget(self, action: #selector(rightBarButtonTapped), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func addLeftButtonToNavigation(title : String? = nil, titleColor: UIColor = .black, image: UIImage? = nil, font: UIFont? = nil){
        let leftButton = UIButton(type: .custom)
        if let title = title{
            leftButton.setTitle(title, for: .normal)
        }
        leftButton.setTitleColor(titleColor, for: .normal)
        if let providedFont = font {
            leftButton.titleLabel?.font = providedFont
        } else {
            leftButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        }
        if let image = image{
            leftButton.setImage(image, for: .normal)
        }
        
        if title != nil, image != nil {
            leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
            leftButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        }
        leftButton.addTarget(self, action: #selector(leftBarButtonTapped), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    /** Taken from apple reference code
     Configures the navigation bar to use a transparent background
     (see-through but without any blur).
     */
    final func applyTransparentBackgroundToTheNavigationBar(_ opacity: CGFloat) {
        guard let navController = self.navigationController else {return}
        
        
        var transparentBackground: UIImage
        
        /*    The background of a navigation bar switches from being translucent
         to transparent when a background image is applied. The intensity of
         the background image's alpha channel is inversely related to the
         transparency of the bar. That is, a smaller alpha channel intensity
         results in a more transparent bar and vis-versa.
         
         Below, a background image is dynamically generated with the desired opacity.
         */
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1),
                                               false,
                                               navController.navigationBar.layer.contentsScale)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: opacity)
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        transparentBackground = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        /*    You should use the appearance proxy to customize the appearance of
         UIKit elements. However changes made to an element's appearance
         proxy do not effect any existing instances of that element currently
         in the view hierarchy. Normally this is not an issue because you
         will likely be performing your appearance customizations in
         -application:didFinishLaunchingWithOptions:. However, this example
         allows you to toggle between appearances at runtime which necessitates
         applying appearance customizations directly to the navigation bar.
         */
        //let navigationBarAppearance =
        //      UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self])
        let navigationBarAppearance = self.navigationController!.navigationBar
        
        navigationBarAppearance.setBackgroundImage(transparentBackground, for: .default)
    }

}
