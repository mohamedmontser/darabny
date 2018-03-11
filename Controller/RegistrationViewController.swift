//
//  RegistrationViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 1/29/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SwiftyJSON
import DropDown


class RegistrationViewController: UIViewController {

    ///IBOutlets
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var dropDownView: UIView!
    
    
    ///Variables
    var cities = [City]()
    var selectedCity:City?
   
    ///CONSTANTS
    let NETWORK = NetworkingHelper()
    let dropDown = DropDown()
    let GETCITIES = "GETCITIES"
    let REGISTER = "REGISTER"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NETWORK.deleget = self
        initCitiesDropDown()
        getCitiesRequest()
    }
    
    
    //MARK: - IBactions
    @IBAction func showCitiesDropDownAction()
    {
        dropDown.show()
    }
    
    @IBAction func loginAction()
    {
        if ValidateFields(){registerRequest()}
    }
    
    @IBAction func backView()
    {
        dismiss(animated: true, completion: nil)
    }
}

extension RegistrationViewController{
    
    /// init the city drop down
    func initCitiesDropDown()
    {
        self.view.layoutIfNeeded()
        dropDown.anchorView = dropDownView
        dropDown.dataSource = [localizedSitringFor(key: "loading")]
        dropDown.direction = .bottom
        dropDown.selectionAction = {[unowned self] (index:Int,item:String) in
            self.cityLabel.text = item
            self.selectedCity = self.cities[index]
        }
    }
    
    
    /// to check the validation of all text fields
    ///
    /// - Returns: true if user entered correct data
    func ValidateFields() -> Bool
    {
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "emptyName"), forController: self)
            return false
        }
        
        if addressTextField.text?.trimmingCharacters(in: (.whitespacesAndNewlines)).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "emptyAddress"), forController: self)
        }
        
        if cityLabel.text == "City"
        {
            displayAlert(localizedSitringFor(key: "enterCity"), forController: self)
            return false
        }
        if !isValidEmail(emailTextField.text ?? "")
        {
            displayAlert(localizedSitringFor(key: "notValidEmail"))
            return false
        }
        if phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "emptyPhone"), forController: self)
            return false
        }
        
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "notValidPassword"), forController: self)
            return false
        }
        
        if (passwordTextField.text?.count ?? 0) < 7
        {
            displayAlert(localizedSitringFor(key: "notValidPassword"), forController: self)
            return false
        }
        
        return true
    }
}


extension RegistrationViewController:NetworkingHelperDeleget {

    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        if id == GETCITIES { handleGetCities(fromResponse: data)}
        if id == REGISTER { handleRegister(fromResponse: data)}
        
    }
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        displayAlert(localizedSitringFor(key: "FAILURE"))
    }
    
    
    /// connect to api and recieve data
    func getCitiesRequest()
    {
        let parameters  =
            [ "lang": L102Language.currentAppleLanguage() ]
        
        NETWORK.connectTo(api: ApiNames.cities, withParameters: parameters, andIdentifier: GETCITIES, withLoader: false, forController: self)
    }

    ///connect to api to send data to server to save data
    func registerRequest()
    {
        let paramters : [String: Any] = [
            "name": nameTextField.text ?? "",
            "email": emailTextField.text ?? "",
            "password": passwordTextField.text ?? "",
            "address": addressTextField.text ?? "",
            "phone": phoneTextField.text ?? "",
            "city_id": selectedCity?.id ?? 0
            
            ]
        
        NETWORK.connectTo(api: ApiNames.register, withParameters: paramters, andIdentifier: REGISTER, withLoader: true, forController: self)
        
    }
    
    /// handle cities and towns json8response from server
    ///
    /// - parameter response : server response
    func handleGetCities(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            cities.removeAll()
            response["cities"].arrayValue.forEach({self.cities.append(City(fromJson: $0))})
            dropDown.dataSource = cities.flatMap({return $0.name})
            dropDown.reloadAllComponents()
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
    
    
    /// handle cities and towns json8response from server
    ///
    /// - parameter response : server response
    func handleRegister(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            goToView(withId: "CompleteRegistrationViewController")
        case 405:
            displayAlert(localizedSitringFor(key: "storedEmail"), forController: self)
        case 406:
            displayAlert(localizedSitringFor(key: "storedPhone"), forController: self)
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
}
