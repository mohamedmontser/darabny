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

    ///Outlet
    @IBOutlet var codeTextField: UITextField!
    
    ///Varaible
    var recivedParamters: String = ""
    
    ///CONSTANT
    let NETWORK = NetworkingHelper()
    
    //MARK: - IBActions
    @IBAction func nextAction()
    {
        NETWORK.deleget = self
        if checkValidateCode(){ sendCodeToServer()}
    }
    
    
    @IBAction func BackAction()
    {
        dismiss(animated: true, completion: nil)
    }
}

extension VerifyCodeViewController
{
    
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
        case is RegistrationViewController, is LoginViewController :
            User.shared.apiToken = response["apiToken"].string ?? ""
            User.shared.storeData()
            goToView(withId: "HomeViewController", andStoryboard: "Main", fromController:
                self)
       
        default:
            //here for Update phone
            goToView(withId: "HomeViewController", andStoryboard: "Main", fromController: self)
            
        }
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
        
        var  parameters: [String: Any] =  ["code": codeTextField.text ?? ""]
        switch controller {
        case is RegistrationViewController, is LoginViewController, is ForgetPasswordViewController:
            parameters["email"] = recivedParamters
            return parameters
        default:
            parameters["apiToken"] = User.shared.apiToken
            return parameters
        }
    }
    
    
    /// uses for checking code
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
}


// MARK: - Networking
extension VerifyCodeViewController:NetworkingHelperDeleget
{
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        handleValidateCode(response: data)
    }
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        
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
