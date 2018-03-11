//
//  ResetPasswordViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 1/29/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import  SwiftyJSON

class ResetPasswordViewController: UIViewController {

    ///IBOutlets
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var backView: UIView!

    ///CONSTANT
    let NETWORK = NetworkingHelper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flip(view: backView)
    }
    
    
    //MARK: - IBActions
    @IBAction func nextAction()
    {
        NETWORK.deleget = self
        if checkPassword() { changePassword()}
    }
    
    
    @IBAction func backAction()
    {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - HelperMethod
extension ResetPasswordViewController
{
    
    /// use this function to check on entered data in new password and confirm password
    ///
    /// - Returns: return true if the user enter valid password , new password and confirm password are  indentical
    func checkPassword() -> Bool
    {
        if newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "emptyNewPassword"), forController: self)

        }
        if newPasswordTextField.text?.count ?? 0 < 5
        {
            displayAlert(localizedSitringFor(key: "notValidPassword"), forController: self)
            return false
        }
        if confirmPasswordTextField.text == ""
        {
            displayAlert(localizedSitringFor(key: "emptyConfirmPassword"), forController: self)
            return false
        }
        if confirmPasswordTextField.text != newPasswordTextField.text
        {
            displayAlert(localizedSitringFor(key: "notEqualPassword"), forController: self)
            return false
        }
        return true
    }
}


//MARK: - Networking
extension ResetPasswordViewController:NetworkingHelperDeleget
{
    
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        handleChangePassword(forResponse: data)
    }
    
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        displayAlert(localizedSitringFor(key:"FAILURE"), forController: self)
    }
    
    
    /// connect to server to change password if paramters  are valid
    func changePassword()
    {
        let parameters = [
            "newPassword": confirmPasswordTextField.text ?? "",
            "tmpToken" : User.shared.apiToken
        ]
        NETWORK.connectTo(api: ApiNames.changePassword, withParameters: parameters, withLoader: true, forController: self)
    }
    
    
    /// handle changePassword json response from server
    ///
    /// - Parameter response: server response
    func handleChangePassword(forResponse response: JSON)
    {
        switch response["status"].intValue {
        case 200:
            pushToView(withId: "WelcomeViewController")
        case 401:
            displayAlert(localizedSitringFor(key: "notActiveAccount"), forController: self)
        case 400:
            displayAlert(localizedSitringFor(key: "notValidPassword"), forController: self)
        default:
            displayAlert(localizedSitringFor(key:"tryAgain"), forController: self)
            
        }
    }
}
