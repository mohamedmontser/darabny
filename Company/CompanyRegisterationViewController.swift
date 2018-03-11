//
//  CompanyRegisterationViewController.swift
//  Darabny
//
//  Created by muhammed gamal on 2/4/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SwiftyJSON
import DropDown

class CompanyRegisterationViewController: UIViewController {

    ///Outlets
    @IBOutlet var companyNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var aboutTextView: UITextView!
    @IBOutlet var typeDropDownView: UIView!
    @IBOutlet var fieldDropDownView: UIView!
    @IBOutlet var sizeDropDownView: UIView!
    @IBOutlet var cityDropDownView: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var fieldLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var backView: UIView!
    
    ///Variables
    var newUserImage: UIImage? = nil
    var cities: [City] = []
    var types: [Type] = []
    var sizes: [Size] = []
    var industries: [Industry] = []
    var citiesDropDown = DropDown()
    var typesDropDown = DropDown()
    var sizesDropDown = DropDown()
    var industriesDropDown = DropDown()
    var selectedCity : City!
    var selectedType : Type!
    var selectedSize : Size!
    var selectedIndustry : Industry!
    
    ///CONSTANTS
    let network = NetworkingHelper()
    let imagePicker = UIImagePickerController()
    let REGISTER = "register"
    let GET_CITIES = "getCities"
    let GET_TYPES = "getTypes"
    let GET_SIZES = "getSizes"
    let GET_INDUSTRIES = "getIndustries"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        network.deleget = self
        dropDownsApis()
        displayDropDown()
        flip(view: backView)
    }
    
    
    //MARK: - IBActions
    @IBAction func addPhotoAction()
    {
        openImagePicker()
    }
    
    @IBAction func backAction()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func typeAction()
    {
        typesDropDown.show()
    }
    
    @IBAction func fieldAction()
    {
        industriesDropDown.show()
    }
    
    @IBAction func sizeAction()
    {
        sizesDropDown.show()
    }
    
    @IBAction func cityAction()
    {
        
        citiesDropDown.show()
    }
    
    @IBAction func loginAction()
    {
        if ValidateFields()
        {
            registerRequest()
        }
    }
}


//MARK: - Helpers
extension CompanyRegisterationViewController
{
    ///init dropDowns
    func displayDropDown()
    {
        initiate(dropDown: citiesDropDown, view: cityDropDownView)
        initiate(dropDown: typesDropDown, view: typeDropDownView)
        initiate(dropDown: sizesDropDown, view: sizeDropDownView)
        initiate(dropDown: industriesDropDown, view:fieldDropDownView)
        
    }
    
    ///call dropdDwons apis
    func dropDownsApis()
    {
        getCitiesRequest()
        getSizesRequest()
        getTypesRequest()
        getIndustriesRequest()
    }
    
    /// used to make drop downs get be ready to show
    func initiate( dropDown: DropDown,view:UIView)
    {
        self.view.layoutIfNeeded()
        dropDown.anchorView = view
        dropDown.dataSource = [localizedSitringFor(key: "loading")]
        dropDown.direction = .bottom
        if UIScreen.main.traitCollection.horizontalSizeClass == .regular
        {
            DropDown.appearance().cellHeight = 60
            DropDown.appearance().textFont = UIFont.systemFont(ofSize: 34)
        }
        else
        {
            DropDown.appearance().cellHeight = 40
            DropDown.appearance().textFont = UIFont.systemFont(ofSize: 17)
        }
        
        switch dropDown {
        case citiesDropDown:
            dropDown.selectionAction = selectCity(atIndex:withName:)
        case typesDropDown:
            dropDown.selectionAction = selectType(atIndex:withName:)
        case sizesDropDown:
            dropDown.selectionAction = selectSize(atIndex:withName:)
        case industriesDropDown:
            dropDown.selectionAction = selectIndustry(atIndex:withName:)
        default:
            return
        }
    }
    
    ///cities selected action
    func selectCity(atIndex index:Int, withName name:String)
    {
        guard cities.count > 0 else {return}
        self.cityLabel.text = name
        self.cityLabel.textColor = UIColor.black
        self.selectedCity = self.cities[index]
    }
    
    ///types selected action
    func selectType(atIndex index:Int, withName name:String)
    {
        guard types.count > 0 else {return}
        self.typeLabel.text = name
        self.typeLabel.textColor = UIColor.black
        self.selectedType = self.types[index]
    }
    
    ///sizes selected action
    func selectSize(atIndex index:Int, withName name:String)
    {
        guard sizes.count > 0 else {return}
        self.sizeLabel.text = name
        self.sizeLabel.textColor = UIColor.black
        self.selectedSize = self.sizes[index]
    }
    
    ///industries selected action
    func selectIndustry(atIndex index:Int, withName name:String)
    {
        guard industries.count > 0 else {return}
        self.fieldLabel.text = name
        self.fieldLabel.textColor = UIColor.black
        self.selectedIndustry = self.industries[index]
    }
    
    /// reload cities dropd down data
    func reloadCitiesDropDownData()
    {
        citiesDropDown.dataSource = cities.flatMap({ return $0.name })
        citiesDropDown.reloadAllComponents()
    }
    
    /// reload Types dropd down data
    func reloadTypesDropDownData()
    {
        typesDropDown.dataSource = types.flatMap({ return $0.name })
        typesDropDown.reloadAllComponents()
    }
    
    /// reload Sizes dropd down data
    func reloadSizesDropDownData()
    {
        sizesDropDown.dataSource = sizes.flatMap({ return "\($0.size)" })
        sizesDropDown.reloadAllComponents()
    }
    
    /// reload Industries dropd down data
    func reloadIndustriesDropDownData()
    {
        industriesDropDown.dataSource = industries.flatMap({ return $0.name })
        industriesDropDown.reloadAllComponents()
    }
    
    /// open image picker to select new image from photo library
    func openImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    /// to check the validation of all text fields
    ///
    /// - Returns: true if user entered correct data
    func ValidateFields() -> Bool
    {
        if newUserImage == nil
        {
            displayAlert(localizedSitringFor(key: "pickImage"), forController: self)
            return false
        }
        
        if companyNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
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
        
        if typeLabel.text == "Company Type"
        {
            displayAlert(localizedSitringFor(key: "enterType"), forController: self)
            return false
        }
        
        if sizeLabel.text == "Company Size"
        {
            displayAlert(localizedSitringFor(key: "enterSize"), forController: self)
            return false
        }
        
        if fieldLabel.text == "Field"
        {
            displayAlert(localizedSitringFor(key: "enterField"), forController: self)
            return false
        }
        
        if !isValidEmail(emailTextField.text ?? "")
        {
            displayAlert(localizedSitringFor(key: "notValidEmail"))
            return false
        }
       
        
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "notValidPassword"), forController: self)
            return false
        }
        
        if (passwordTextField.text?.count ?? 0) < 5
        {
            displayAlert(localizedSitringFor(key: "notValidPassword"), forController: self)
            return false
        }
        
        if aboutTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "emptySummary"), forController: self)
            return false
        }
        return true
    }
    
    
    ///store user data
    func storeUserData(forResponse response:JSON) {
        Company.companyShared.email = self.emailTextField.text ?? ""
        Company.companyShared.address = self.addressTextField.text ?? ""
        Company.companyShared.summary = self.aboutTextView.text ?? ""
        Company.companyShared.name = self.companyNameTextField.text ?? ""
        Company.companyShared.city = selectedCity ?? City()
        Company.companyShared.industry =  selectedIndustry ?? Industry()
        Company.companyShared.size =  selectedSize ?? Size()
        Company.companyShared.type =  selectedType ?? Type()
        Company.companyShared.storeData()
    }
}


//MARK: - Networking
extension CompanyRegisterationViewController:NetworkingHelperDeleget
{
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        switch id {
        case REGISTER:
            handleRegister(response: data)
        case GET_CITIES:
            handleGetCities(fromResponse: data)
        case GET_TYPES:
            handleGetTypes(fromResponse: data)
        case GET_SIZES:
            handleGetSizes(fromResponse: data)
        case GET_INDUSTRIES:
            handleGetIndustries(fromResponse: data)
        default:
            displayAlert(localizedSitringFor(key: "FAILURE"))
        }
    }
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        displayAlert(localizedSitringFor(key: "FAILURE"), forController: self)
    }
    
    /// send login request to server
    func registerRequest()
    {
        network.connectToUpload(images: ["logo" : [newUserImage ?? UIImage()]], toApi: ApiNames.COMPANY_REGISTER, withParameters: ["name" : companyNameTextField.text!, "email":emailTextField.text!, "password":passwordTextField.text!,"address":addressTextField.text!, "Summary":aboutTextView.text ,"city_id":"\(selectedCity!.id)","type_id":"\(selectedType!.id)", "size_id":"\(selectedSize!.id)", "industry_id":"\(selectedIndustry!.id)"], andIdentifier: REGISTER)
    }
    
    /// connect to api and recieve data
    func getCitiesRequest()
    {
        network.connectTo(api: ApiNames.cities, withParameters: [ "lang": L102Language.currentAppleLanguage() ], andIdentifier: GET_CITIES, withLoader: false, forController: self)
    }
    
    /// connect to api and recieve data
    func getTypesRequest()
    {
        network.connectTo(api: ApiNames.TYPES, withParameters:  [ "lang": L102Language.currentAppleLanguage() ], andIdentifier: GET_TYPES, withLoader: false, forController: self)
    }
    
    /// connect to api and recieve data
    func getSizesRequest()
    {
        network.connectTo(api: ApiNames.SIZES, withParameters: [ "lang": L102Language.currentAppleLanguage()], andIdentifier: GET_SIZES, withLoader: false, forController: self)
    }
    
    /// connect to api and recieve data
    func getIndustriesRequest()
    {
        network.connectTo(api: ApiNames.INDUSTRIES, withParameters: [ "lang": L102Language.currentAppleLanguage()], andIdentifier: GET_INDUSTRIES, withLoader: false, forController: self)
    }
    
    /// handle server response for register request
    ///
    /// - Parameter response: server response
    func handleRegister(response:JSON)
    {
        switch response["status"].intValue
        {
            case 200:
                storeUserData(forResponse: response)
                goToView(withId: "VerifyCodeViewController")
            case 405:
                displayAlert(localizedSitringFor(key: "storedEmail"), forController: self)
            case 406:
                displayAlert(localizedSitringFor(key: "storedPhone"), forController: self)
            default:
                displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
    
    /// handle cities json response from server
    ///
    /// - parameter response : server response
    func handleGetCities(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            cities.removeAll()
            response["cities"].arrayValue.forEach({self.cities.append(City(fromJson: $0))})
            reloadCitiesDropDownData()
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
    
    /// handle types json response from server
    ///
    /// - parameter response : server response
    func handleGetTypes(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            types.removeAll()
            response["types"].arrayValue.forEach({self.types.append(Type(fromJson: $0))})
            reloadTypesDropDownData()
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
    
    /// handle types json response from server
    ///
    /// - parameter response : server response
    func handleGetSizes(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            sizes.removeAll()
            response["sizes"].arrayValue.forEach({self.sizes.append(Size(fromJson: $0))})
            reloadSizesDropDownData()
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
    
    /// handle types json response from server
    ///
    /// - parameter response : server response
    func handleGetIndustries(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            industries.removeAll()
            response["industries"].arrayValue.forEach({self.industries.append(Industry(fromJson: $0))})
            reloadIndustriesDropDownData()
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
}

//MARK: - Image Picker delegate
extension CompanyRegisterationViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            displayAlert(localizedSitringFor(key: "cannotPickImage"), forController: self)
            return
        }
        profileImage.image = image
        newUserImage = image
    }
}
