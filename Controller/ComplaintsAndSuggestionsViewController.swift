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

    ///Outlets
    @IBOutlet var messageTextView:UITextView!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    
    /// variables
    var placeholderLabel : UILabel!
    
    ///CONSTANTS
    let NETWORK = NetworkingHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doDelegate()
        contactInfoRequest()
        makePlaceholder(forTextView: messageTextView, andMessage: localizedSitringFor(key: "TypeYourMessage"))
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
        if messageTextView.text == localizedSitringFor(key: "Message")
        {
            displayAlert(localizedSitringFor(key: "enter your massage"))
            return false
        }
        if messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "enter your massage"), forController: self)
            return false
        }
    return true
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
            [ "apiToken" : User.shared.apiToken,
              "message" : messageTextView.text!
            ]
        
        NETWORK.connectTo(api: ApiNames.contact, withParameters: parameters, andIdentifier: "CONTACT", withLoader: true, forController: self)
    }
    
    
    func contactInfoRequest()
    {
        let parameters : Parameters =
            [ "apiToken": " FnIseN1PdHIJlbZChJsfujufCUi2MV4k5iAXSmsMPjO8VSGCj1HfxoHnOWTKHGwo"]
        
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
extension ComplaintsAndSuggestionsViewController : UITextViewDelegate
{
    
    /// to add placeholder and its color to text view
    ///
    /// - Parameter textview: the text view contain the placeholder
    /// - Parameter string: the text that will be aplaceholder
    func makePlaceholder(forTextView textView:UITextView , andMessage text:String)
    {
        placeholderLabel = UILabel()
        placeholderLabel.text = text
        placeholderLabel.font = UIFont.boldSystemFont(ofSize: (textView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 10, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    
    /// func to hide and show placeholder when user write in textView
    ///
    /// - Parameter textfield: the text view
    func textViewDidChange(_ textView: UITextView)
    {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

