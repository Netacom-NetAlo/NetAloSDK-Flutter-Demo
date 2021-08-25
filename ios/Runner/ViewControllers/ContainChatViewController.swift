//
//  ContainChatViewController.swift
//  Runner
//
//  Created by Hieu Bui Van  on 11/23/20.
//

import UIKit
import NetaloUISDK

class ContainChatViewController: UIViewController {
    @IBOutlet weak var containNetaloView: UIView!
    var data : [String: Any]?
    var netaloUISDK: NetaloUISDK!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containNetaloView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)

        let userChat = UserHolder(id: Int64(data?["id"] as! String) ?? 0,
                                phoneNumber: formatPhone(phone: data?["phone"] as? String),
                                email: "",
                                fullName: data?["username"] as? String ?? "",
                                avatarUrl: data?["avatar"] as? String ?? "",
                                session: "")
        
        if let vc = netaloUISDK?.buildChatViewController(userChat, type: 3) {
            self.embed(vc, inView: self.containNetaloView)
        }
    }
//    
//    @IBAction func closeAction(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
    
    func formatPhone(phone:String?) -> String{
        if (phone==nil || phone?.isEmpty==true)
        {
            return "";
        }
        var result = phone!
        if (phone!.starts(with: "0")){
            result = phone!.replacingCharacters(in: ...phone!.startIndex, with: "+84")
        }
    return result
    }
}


//MARK: -ContainNetaloViewController
extension ContainChatViewController {
    static func instantiate(sdk: NetaloUISDK) -> ContainChatViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContainChatViewController") as! ContainChatViewController
        vc.netaloUISDK = sdk
        return vc
    }
}
