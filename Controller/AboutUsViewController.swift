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
    
    ///Outlets
    @IBOutlet var textView:UITextView!
   
    ///CONSTANTS
    let NETWORK = NetworkingHelper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
