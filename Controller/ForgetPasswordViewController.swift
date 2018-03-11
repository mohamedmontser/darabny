//
//  ForgetPasswordViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 1/29/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SwiftyJSON

class ForgetPasswordViewController: UIViewController {
    
    ///Outlet
    @IBOutlet var emailTextField:UITextField!

    ///CONSTANT
    let NETWORK = NetworkingHelper()
    
    //MARK: - IBActions
    @IBAction func nextAction()
    {
         NETWORK.deleget = self
         isValidEmail(emailTextField.text ?? "") ? forgetPasswordRequest():displayAlert(localizedSitringFor(key: "notValidEmail"))
    }
    
    
    @IBAction func BackAction()
    {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Networking
extension ForgetPasswordViewController: NetworkingHelperDeleget
{
    
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String)
    {
        handleForgetPassowrd(fromResponse: data)
    }
    
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String)
    {
        displayAlert(localizedSitringFor(key: "FAILURE"), forController: self)
    }
    
    
    /// uses for check about entered email if it registered in database or not
    func forgetPasswordRequest()
    {
        let parameters =
            [
                "email": emailTextField.text ?? ""
            ]
        NETWORK.connectTo(api: ApiNames.forgetPassword, withParameters: parameters, andIdentifier: "", withLoader: true, forController: self)
    }
    
    
    /// handle forgetPassword json response from server
    ///
    /// - Parameter response: server response
    func handleForgetPassowrd(fromResponse response: JSON)
    {
        switch response["status"].intValue {
        case 200:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
            vc.recivedParamters = emailTextField.text ?? ""
            self.present(vc, animated: true, completion: nil)
        case 408:
            displayAlert(localizedSitringFor(key: "notRegisteredEmail"), forController: self)
        case 401:
            displayAlert(localizedSitringFor(key: "notActiveAccount"), forController: self)
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
}
