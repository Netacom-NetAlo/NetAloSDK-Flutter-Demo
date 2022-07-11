//
//  ContainNetaloViewController.swift
//  DemoChatSDK
//
//  Created by Hieu Bui Van  on 11/17/20.
//

import UIKit
import NetaloUISDK

class ContainNetaloViewController: UIViewController {
    @IBOutlet weak var containNetaloView: UIView!
    var netaloUISDK: NetaloUISDK!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.containNetaloView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        self.modalPresentationStyle = .fullScreen
        
        let vc = ConversationVC.instance()
        self.embed(vc, inView: self.containNetaloView)
        
        print("INIT - ContainNetaloViewController")
    }
    
    deinit {
        print("DE-INIT - ContainNetaloViewController")
    }
    
//    @IBAction func closeAction(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
}

//MARK: -ContainNetaloViewController
extension ContainNetaloViewController {
    static func instantiate(sdk: NetaloUISDK) -> ContainNetaloViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContainNetaloViewController") as! ContainNetaloViewController
        vc.netaloUISDK = sdk
        return vc
    }
}


//MARK: -UIView
extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11, *) {
            self.clipsToBounds = true
            self.layer.cornerRadius = radius
            var masked = CACornerMask()
            if corners.contains(.topLeft) { masked.insert(.layerMinXMinYCorner) }
            if corners.contains(.topRight) { masked.insert(.layerMaxXMinYCorner) }
            if corners.contains(.bottomLeft) { masked.insert(.layerMinXMaxYCorner) }
            if corners.contains(.bottomRight) { masked.insert(.layerMaxXMaxYCorner) }
            self.layer.maskedCorners = masked
        }
        else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}


//MARK: -UIViewController
extension UIViewController {
    func embed(_ viewController:UIViewController, inView view:UIView){
        viewController.willMove(toParent: self)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
}
