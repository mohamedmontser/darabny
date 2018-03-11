//
//  WelcomeViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 2/3/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import  SwiftyJSON
import Alamofire


class WelcomeViewController: UIViewController {

    ///Outlets
    @IBOutlet var aboutUsLabel:UILabel!
    
    ///CONSTANTS
    let NETWORK = NetworkingHelper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NETWORK.deleget = self
        getDataRequest()
    }
}


//MARK: - Networking
extension WelcomeViewController: NetworkingHelperDeleget
{
    
    
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String)
    {
        if data["status"].intValue == 200
        {
            self.aboutUsLabel.text = data["message"].stringValue
        }
        else
        {
            displayAlert(localizedSitringFor(key: "unKnownError"), forController: self)
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
              "apiToken" : User.shared.apiToken
        ]
        
        NETWORK.connectTo(api: ApiNames.aboutUs, withParameters: parameters, andIdentifier: "", withLoader: true, forController: self)
    }
}
