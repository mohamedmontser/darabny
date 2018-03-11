//
//  UpdatePasswordViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 2/3/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SwiftyJSON

class UpdatePasswordViewController: UIViewController {

    @IBOutlet var oldPasswordTextField: UITextField!
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    let NETWORK = NetworkingHelper()
    
    @IBAction func updatePasswordAction()
    {
        NETWORK.deleget = self
        if checkPasswords()
        {
            updatePassword()
        }
    }
    
    @IBAction func backAction()
    {
        dismiss(animated: true, completion: nil)
    }
}

extension UpdatePasswordViewController
{
    func checkPasswords() ->Bool
    {
        if oldPasswordTextField.text?.isEmpty ?? true{
            displayAlert(localizedSitringFor(key: "EnterPassword"))
            return false
        }
        if oldPasswordTextField.text?.count ?? 0 < 5
        {
            displayAlert(localizedSitringFor(key: "notValidPassword"))
            return false
        }
        if newPasswordTextField.text?.isEmpty ?? true{
            displayAlert(localizedSitringFor(key: "emptyNewPassword"))
            return false
        }
        if newPasswordTextField.text?.count ?? 0 < 5
        {
            displayAlert(localizedSitringFor(key: "notValidPassword"))
            return false
        }
        if newPasswordTextField.text != confirmPasswordTextField.text{
            displayAlert(localizedSitringFor(key: "notEqualPassword"))
            return false
        }
    return true
    }
    
}


//MARK: - Networking
extension UpdatePasswordViewController: NetworkingHelperDeleget
{
    
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        handleUpdatePassword(forResponse: data)
    }
    
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        displayAlert(localizedSitringFor(key:"FAILURE"), forController: self)
    }
    
    
    /// connect to server to change password if paramters  are valid
    func updatePassword()
    {
        let parameters: [String: Any] = [
            "oldPassword": oldPasswordTextField.text ?? "",
            "newPassword": confirmPasswordTextField.text ?? "",
               "apiToken": "YBRz982rKaVaFVXsKX3f9oaWIzAfrk3HOQRsvThxKYqbDLlJN3sDZ2UJIsQwUTTs"
        ]
        NETWORK.connectTo(api: ApiNames.userUpdatePassword, withParameters: parameters, withLoader: true, forController: self)
    }
    
    
    /// handle updatePassword json response from server
    ///
    /// - Parameter response: server response
    func handleUpdatePassword(forResponse response: JSON)
    {
        switch response["status"].intValue {
        case 200:
            pushToView(withId: "LoginViewController")
        case 401:
            displayAlert(localizedSitringFor(key: "notActiveAccount"), forController: self)
        case 400:
            displayAlert(localizedSitringFor(key: "notValidPassword"), forController: self)
        default:
            displayAlert(localizedSitringFor(key:"tryAgain"), forController: self)
            
        }
    }
}
