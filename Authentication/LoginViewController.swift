//
//  LoginViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 1/29/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SwiftyJSON


class LoginViewController: UIViewController {

    ///IBOutlets
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var remmberMeImageView: UIImageView!
    @IBOutlet var backView: UIView!
   
    ///Variable
    var remmberMe: Bool = true
    {
        didSet{
            remmberMeImageView.image = UIImage(named: remmberMe ? "Check box": "check-box-empty")
        }
    }
    
    ///CONSTANT
    let NETWORK = NetworkingHelper()
    
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        flip(view: backView)
        NETWORK.deleget = self
    }
    
    
    //MARK: - IBActions
    @IBAction func loginAction()
    {
       if checkFieldsValidate()
       {
            loginRequest()
        }
    }
    
    
    @IBAction func backAction()
    {
        dismiss(animated: true, completion: nil)
      
    }
    
    
    @IBAction func changeRemmberMeImageAction()
    {
        remmberMe = !remmberMe
    }
}


//MARK: - Helper methods
extension LoginViewController
{
    
    /// to check the validation of email and password
    ///
    /// - Returns: true if user entered email and password correct and false if not
    func checkFieldsValidate() -> Bool
    {
        if !isValidEmail(emailTextField.text ?? "")
        {
            displayAlert(localizedSitringFor(key: "notValidEmail"))
            return false
        }
        if (self.passwordTextField.text?.count ?? 0) < 5
        {
            displayAlert(localizedSitringFor(key: "notValidPassword"), forController: self)
            return false
        }
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "emptyPassword"), forController: self)
            return false
        }
        return true
    }
    
    
    ///to check on type of the account that  enter the application is user account or company account
    func determineType(forResponse response: JSON){
       if response["type"].stringValue == "user"
       {
            User.shared.getData(fromResponse: response["user"])
            if remmberMe
            {
                User.shared.storeData()
            }
        }
        if response["type"].stringValue == "company"
        {
            Company.companyShared.getData(fromResponse: response["company"])
            if remmberMe
            {
                Company.companyShared.storeData()
            }
        }
        pushToView(withId: "HomeContainerViewController")
    }
}



//MARK: - Networking
extension LoginViewController: NetworkingHelperDeleget
{
    
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String)
    {
        handleLogin(forResponse: data)
    }
    
    
    func onHelper(getError error: String, fromApiName name:String , withIdentifier id: String)
    {
        displayAlert("FAILURE", forController: self)
    }
    
    
    /// uses for connecting to server and recive data
    func loginRequest()
    {
        let parameters: [String: Any] =
            [
                "email": emailTextField.text ?? "" ,
                "password": passwordTextField.text ?? ""
            ]
        NETWORK.connectTo(api: ApiNames.login, withParameters: parameters, withLoader: true, forController: self)
    }
    
    
    /// handle login json response from server
    ///
    /// - Parameter response: server response
    func handleLogin(forResponse response: JSON)
    {
        switch response["status"].intValue {
        case 200:
            determineType(forResponse: response)
        case 409:
           goToView(withId: "VerifyCodeViewController")
        case 403:
            displayAlert(localizedSitringFor(key: "notCorrectEmailAndPassword"), forController: self)
        case 401:
            displayAlert(localizedSitringFor(key: "notCorrectEmailAndPassword"), forController: self)
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
}
