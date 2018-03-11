//
//  ComplaintsAndSuggestionsViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 1/29/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class ComplaintsAndSuggestionsViewController: UIViewController {

    ///IBOutlets
    @IBOutlet var messageTextView:UITextView!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var backView: UIView!
    
    ///CONSTANT
    let NETWORK = NetworkingHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flip(view: backView)
        prepareStyle()
         doDelegate()
        contactInfoRequest()
    }
    
    
    //MARK: - IBActions
    @IBAction func sendMessageRequest()
    {
        if checkAboutTextField(){ contactRequest()}
    }
    
    
    @IBAction func backAction()
    {
        dismiss(animated: true, completion: nil)
    }
}


//MARK:HelperMethods
extension ComplaintsAndSuggestionsViewController
{
    
    ///uses for seting message textfield placeholder and color
    func prepareStyle()
    {
        messageTextView.text = localizedSitringFor(key: "typeYourMessage")
        messageTextView.textColor = UIColor.lightGray
    }
    
    
    /// do delagate for network and text view
    func doDelegate()
    {
        messageTextView.delegate = self
        NETWORK.deleget = self
    }
    
    
    /// determine if the user enter message and display if the user didnt enter anything
    ///
    /// - Returns: true if user entered all required data and false if not
    func checkAboutTextField() -> Bool
    {
        if messageTextView.text == localizedSitringFor(key: "typeYourMessage")
        {
            displayAlert(localizedSitringFor(key: "enterYourMessage"))
            return false
        }
        if messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "enterYourMessage"), forController: self)
            return false
        }
        return true
    }
    
    
    ///determine email if user email or company email
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



extension ComplaintsAndSuggestionsViewController: NetworkingHelperDeleget {
    
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        if id == "CONTACT" {handleContact(fromResponse: data)}
        if id == "CONTACTINFO" {handleContactInfo(fromResponse: data)}
    }
    
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
      displayAlert(localizedSitringFor(key: "FAILURE"))
    }
    
    
    /// send message to server
    func contactRequest()
    {
        let parameters : Parameters =
            [ "apiToken" : determineEmail(),
              "message" : messageTextView.text ?? ""
            ]
        
        NETWORK.connectTo(api: ApiNames.contact, withParameters: parameters, andIdentifier: "CONTACT", withLoader: true, forController: self)
    }
    
    
    func contactInfoRequest()
    {
        let parameters : Parameters =
            [ "apiToken": determineEmail()]
        
        NETWORK.connectTo(api: ApiNames.contactInfo, withParameters: parameters, andIdentifier: "CONTACTINFO", withLoader: true, forController: self)
    }
    
    
    /// handle server response for contact request
    ///
    /// - parameter response : server response
    func handleContact(fromResponse response:JSON)
    {
        switch response["status"].intValue
        {
        case 200:
            displayAlert(localizedSitringFor(key: "MessageSent"))
            
        case 404:
            displayAlert(localizedSitringFor(key: "unknownError"), forController: self)
            
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
    
    /// handle server response for contact request
    ///
    /// - parameter response : server response
    func handleContactInfo(fromResponse response:JSON)
    {
        switch response["status"].intValue
        {
        case 200:
           emailLabel.text = response["email"].stringValue
            phoneLabel.text = response["phone"].stringValue
        case 404:
            displayAlert(localizedSitringFor(key: "unKnownError"), forController: self)
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
}


//MARK: - text view Delegate
extension ComplaintsAndSuggestionsViewController: UITextViewDelegate
{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if messageTextView.textColor == UIColor.lightGray {
            messageTextView.text = nil
            messageTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if messageTextView.text.isEmpty {
            messageTextView.textColor = UIColor.lightGray
            messageTextView.text = localizedSitringFor(key: "typeYourMessage")
            
        }
    }
}

