//
//  AboutUsViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 1/29/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire


class AboutUsViewController: UIViewController {
    
    ///IBOutlets
    @IBOutlet var textView:UITextView!
    @IBOutlet var backView: UIView!
    
    ///CONSTANT
    let NETWORK = NetworkingHelper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flip(view: backView)
        NETWORK.deleget = self
        getDataRequest()
    }
    
    
    ///MARK: - IBActions
    @IBAction func shareAction()
    {
         share(items: ["projectURL"], forController: self, excludedActivityTypes: [.addToReadingList, .airDrop, .assignToContact, .saveToCameraRoll, .print])
    }
    
    
    @IBAction func BackAction()
    {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - HelperMethods
extension AboutUsViewController
{
    
    
    func determineEmail()->String {
        if User.shared.email != ""
        {
            return User.shared.apiToken
        }
        if Company.companyShared.email != ""
        {
            return Company.companyShared.apiToken
        }
        return ""
    }
}



//MARK: - Networking
extension AboutUsViewController: NetworkingHelperDeleget
{
    
    
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String)
    {
        if data["status"].intValue == 200
        {
            self.textView.text = data["message"].stringValue
        }
        else
        {
            displayAlert(localizedSitringFor(key: "FAILURE"), forController: self)
        }
    }
    
    
    func onHelper(getError error:String,fromApiName name:String , withIdentifier id:String)
    {
        displayAlert(localizedSitringFor(key: "FAILURE"), forController: self)
    }
    
    
    /// get app message from server
    func getDataRequest()
    {
        let parameters : Parameters =
            [ "lang" : L102Language.currentAppleLanguage() ,
              "apiToken" : determineEmail()            ]
        
        NETWORK.connectTo(api: ApiNames.aboutUs, withParameters: parameters, andIdentifier: "", withLoader: true, forController: self)
    }
}
