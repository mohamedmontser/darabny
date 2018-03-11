//
//  VerifyCodeViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 1/29/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SwiftyJSON


class VerifyCodeViewController: UIViewController {

    ///IBOutlets
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var backView: UIView!
    @IBOutlet var pageTitleLabel: UILabel!
    
    ///CONSTANT
    let NETWORK = NetworkingHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flip(view: backView)
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setPageTitle()
    }
    
    
    //MARK: - IBActions
    @IBAction func nextAction()
    {
        NETWORK.deleget = self
        if checkValidateCode(){ sendCodeToServer()}
    }
    
    
    @IBAction func backAction()
    {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - HelperMethod
extension VerifyCodeViewController
{
    
    func storeData(fromResponse response: JSON)
    {
        if response["type"].stringValue == "user"
        {
            User.shared.apiToken = response["apiToken"].stringValue
            User.shared.cvURL = response["cvUrl"].stringValue
            User.shared.storeData()
            pushToView(withId: "HomeContainerViewController")
            
        }
        if response["type"].stringValue == "company"
        {
            Company.companyShared.apiToken = response["apiToken"].stringValue
            Company.companyShared.logoURL = response["imgUrl"].stringValue
            Company.companyShared.storeData()
            pushToView(withId: "HomeContainerViewController")
        }
        else if response["type"].stringValue == "type" && response["company"].stringValue == "company"
        {
            displayAlert(localizedSitringFor(key: "tryAgain"))
        }
    }
    
    /// Call this method after verify the code with server to navigate the user to the next screen based on the previous screen
    ///
    /// - Parameter response: the server response
    func codeVerifiedSuccessfully(fromResponse response: JSON) {
        guard let controller = self.presentingViewController else {
            print("cann't determine the previous view controller")
            return
        }
        
        switch controller {
        case is ForgetPasswordViewController:
            User.shared.apiToken = response["tmpToken"].string ?? ""
            goToView(withId: "ResetPasswordViewController")
        case is CompleteRegistrationViewController, is LoginViewController, is CompanyRegisterationViewController:
            storeData(fromResponse: response)
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"))
            
        }
    }
    
    
    /// set page title based on previous page
    func setPageTitle() {
        guard let controller = self.presentingViewController else {
            print("cann't determine the previous view controller")
            return
        }
        controller is ForgetPasswordViewController ? (pageTitleLabel.text = localizedSitringFor(key: "forgetPassword")):(pageTitleLabel.text = localizedSitringFor(key: "verificationCode"))
    }
    
    
    /// determind parameter sto send them to api
    ///
    /// - Returns: parameters which will be sent to api
    func getParameters() -> [String: Any]
    {
        guard let controller = self.presentingViewController else {
            print("cann't determine the previous view controller")
            return ["": ""]
        }
        
        var  parameters: [String: Any] =  ["code": convertNumsToEnglish(stringCode: codeTextField.text ?? "")]
        switch controller {
        case is CompanyRegisterationViewController, is LoginViewController, is ForgetPasswordViewController, is CompleteRegistrationViewController:
            if User.shared.email != ""
            {
                parameters["email"] = User.shared.email
                return parameters
            }
            if Company.companyShared.email != ""
            {
                parameters["email"] = Company.companyShared.email
                return parameters
            }
            else {return ["":""]}
        default:
            parameters["apiToken"] = User.shared.apiToken
            return parameters
        }
    }
    
    
    /// uses for checking about code
    ///
    /// - Returns: true if code if valid otherwsie return false
    func checkValidateCode() -> Bool
    {
        if codeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "EmptySMSCode"), forController: self)
            return false
        }
        
        if (codeTextField.text?.count ?? 0)  < 6 || (codeTextField.text?.count ?? 7) > 6
        {
            displayAlert(localizedSitringFor(key: "Code6Digit"), forController: self)
            return false
        }
        return true
    }
    
    
    /// to convert  arabic numbers to english
    ///
    /// - Parameter stringCode: the entred code in string format
     /// - Returns: code with english numbers
    func convertNumsToEnglish(stringCode:String) -> String  {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.locale = NSLocale(localeIdentifier: "EN") as Locale!
        return String(describing:formatter.number(from: stringCode)!)
    }
}


// MARK: - Networking
extension VerifyCodeViewController:NetworkingHelperDeleget
{
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        handleValidateCode(response: data)
    }
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        displayAlert(localizedSitringFor(key: "FAILURE"), forController: self)
    }
    
    
    /// send the code to server to verify it
    func sendCodeToServer() {
        NETWORK.connectTo(api: ApiNames.validateCode, withParameters: getParameters(), andIdentifier: "", withLoader: true)
    }
 
    
    /// handle validate code json response from server
    ///
    /// - Parameter response: server response
    func handleValidateCode(response:JSON) {
        switch response["status"].intValue {
        case 200:
            codeVerifiedSuccessfully(fromResponse: response)
        case 400:
            displayAlert(localizedSitringFor(key: "notRegisteredEmail"), forController: self)
        case 407:
            displayAlert(localizedSitringFor(key: "codeNotValid"), forController: self)
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
}
