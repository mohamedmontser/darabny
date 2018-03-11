//
//  UpdateCompanyInfoViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 2/13/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import DropDown
import SwiftyJSON

class UpdateCompanyInfoViewController: UIViewController {
   
    ///IBOutlets
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var industryLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var typesDropDownView: UIView!
    @IBOutlet var cityDropDownView: UIView!
    @IBOutlet var sizeDropDownView: UIView!
    @IBOutlet var industriesDropDownView: UIView!
    @IBOutlet var summaryTextView: UITextView!
    @IBOutlet var backView: UIView!
    
    ///Variables
    var cities = [City]()
    var sizes = [Size]()
    var types = [Type]()
    var industries = [Industry]()
    var selectedCity: City?
    var selectedSize: Size?
    var selectedIndustry: Industry?
    var selectedType: Type?
    var newUserImage: UIImage? = nil
    
    ///CONSTANTS
    let imagePicker = UIImagePickerController()
    let CITIES = "CITIES"
    let SIZES = "SIZES"
    let INDUSTRIES = "INDUSTRIES"
    let TYPES = "TYPES"
    let NETWORK = NetworkingHelper()
    let CITIESDROPDOWN = DropDown()
    let TYPESDROPDOWN = DropDown()
    let SIZESDROPDOWN = DropDown()
    let INDUSTRIESDROPDOWN = DropDown()
    
   
    override func viewDidLoad(){
        super.viewDidLoad()
        
        flip(view: backView)
        updateUserPrfile()
        doDelegate()
        initDropDowns()
        dropDownsApis()
    }
    
    
    //MARK: - IBActions
    @IBAction func showDropDown(sender: UIButton)
    {
        switch sender.tag {
        case 1:
            TYPESDROPDOWN.show()
        case 2:
            INDUSTRIESDROPDOWN.show()
        case 3:
            CITIESDROPDOWN.show()
        case 4:
            SIZESDROPDOWN.show()
        default:
            break
        }
    }
    
    
    @IBAction func pickAnImage(_ sender: Any)
    {
        openImagePicker()
    }
    
    
    @IBAction func backAction()
    {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func updateProfileAction()
    {
        if validateFields(){updateInfoRequest()}
    }
}



//MARK: - HelperMethods
extension UpdateCompanyInfoViewController{

   ///init all dropdowns
    func initDropDowns()
    {
        
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
        DropDown.appearance().semanticContentAttribute = .forceLeftToRight
        initCitiesDropDown()
        initSizesDropDown()
        initIndustriesDropDown()
        initTypesDropDown()
    }
    
    
    ///update user data based on user defaults
    func updateUserPrfile()
    {
        emailTextField.text = Company.companyShared.email
        addressTextField.text = Company.companyShared.address
        summaryTextView.text = Company.companyShared.summary
        nameTextField.text = Company.companyShared.name
         profileImageView.sd_setImage(with: URL(string: Company.companyShared.logoURL), placeholderImage: UIImage(named: "user"))
    }
    
    
    /// call dropDowns apis
    func dropDownsApis()
    {
        getCitiesRequest()
        getSizesRequest()
        getTypesRequest()
        getIndustriesRequest()
    }
    
    
    /// open image picker to select new image from photo library
    func openImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    /// init the majors drop down
    func initCitiesDropDown()
    {
        self.view.layoutIfNeeded()
        CITIESDROPDOWN.anchorView = cityDropDownView
        CITIESDROPDOWN.dataSource = [localizedSitringFor(key: "loading")]
        CITIESDROPDOWN.direction = .any
        CITIESDROPDOWN.selectionAction = {[unowned self] (index:Int,item:String) in
            if self.cities.count > 0
            {
                self.selectedCity = self.cities[index]
                self.cityLabel.text = self.cities[index].name
            }
        }
    }
    
    
    /// init the majors drop down
    func initTypesDropDown()
    {
        self.view.layoutIfNeeded()
        TYPESDROPDOWN.anchorView = typesDropDownView
        TYPESDROPDOWN.dataSource = [localizedSitringFor(key: "loading")]
        TYPESDROPDOWN.direction = .any
        TYPESDROPDOWN.selectionAction = {(index:Int,item:String) in
            if self.types.count > 0
            {
                self.selectedType = self.types[index]
                self.typeLabel.text = self.types[index].name
            }
        }
    }
    
    
    /// init the  size  drop down
    func initSizesDropDown()
    {
        self.view.layoutIfNeeded()
        SIZESDROPDOWN.anchorView = sizeDropDownView
        SIZESDROPDOWN.dataSource = [localizedSitringFor(key: "loading")]
        SIZESDROPDOWN.direction = .any
        SIZESDROPDOWN.selectionAction = {[unowned self] (index:Int,item:String) in
            if self.sizes.count > 0
            {
                self.selectedSize = self.sizes[index]
                self.sizeLabel.text = String(describing: self.sizes[index].size)
            }
        }
    }
    
    
    /// init the  industries  drop down
    func initIndustriesDropDown()
    {
        self.view.layoutIfNeeded()
        INDUSTRIESDROPDOWN.anchorView = industriesDropDownView
        INDUSTRIESDROPDOWN.dataSource = [localizedSitringFor(key: "loading")]
        INDUSTRIESDROPDOWN.direction = .any
        INDUSTRIESDROPDOWN.selectionAction = {[unowned self] (index:Int,item:String) in
            if self.industries.count > 0
            {
                self.selectedIndustry = self.industries[index]
                self.industryLabel.text = self.industries[index].name
            }
        }
    }
    
    
    /// do delagate for network and text view
    func doDelegate()
    {
        summaryTextView.delegate = self
        NETWORK.deleget = self
    }
    
    
    /// to check the validation of all text fields
    ///
    /// - Returns: true if user entered correct data
    func validateFields() -> Bool
    {
        if nameTextField.text?.isEmpty == true {
            displayAlert(localizedSitringFor(key: "emptyName"), forController: self)
            return false
        }
        if nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 1 {
            displayAlert(localizedSitringFor(key: "notValidName"), forController: self)
            return false
        }
        
        if summaryTextView.text?.isEmpty == true{
            displayAlert(localizedSitringFor(key: "emptySummary"), forController: self)
            return false
        }
        if summaryTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 4 {
            displayAlert(localizedSitringFor(key: "notValidSummary"), forController: self)
            return false
        }
        if addressTextField.text?.isEmpty == true{
            displayAlert(localizedSitringFor(key: "emptyAddress"), forController: self)
            return false
        }
        if addressTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 4 {
            displayAlert(localizedSitringFor(key: "notValidAddress"), forController: self)
            return false
        }
        
        if emailTextField.text?.isEmpty == true {
            displayAlert(localizedSitringFor(key: "emptyEmail"), forController: self)
            return false
        }
        
        if !isValidEmail(emailTextField.text!) {
            displayAlert(localizedSitringFor(key: "notValidEmail"), forController: self)
            return false
        }
        
        ///check if user update data or not 
        if ( emailTextField.text == Company.companyShared.email &&
            addressTextField.text == Company.companyShared.address
            && nameTextField.text == Company.companyShared.name &&
            summaryTextView.text == Company.companyShared.summary && Company.companyShared.city.id == cities[(cities.index(where: {$0.name == cityLabel.text}))!].id && Company.companyShared.industry.id == industries[(industries.index(where: {$0.name == industryLabel.text}))!].id && Company.companyShared.type.id == types[(types.index(where: {$0.name == typeLabel.text}))!].id && newUserImage == nil && Company.companyShared.size.id == sizes[(sizes.index(where: {String(describing: $0.size) == sizeLabel.text}))!].id)
        {
            displayAlert(localizedSitringFor(key: "noChanges"))
            return false
        }
        return true
    }
    
    
    
    ///user for update the user date after user update his data
    func updateUserDefaults()
    {
        Company.companyShared.email = emailTextField.text ?? Company.companyShared.email
        Company.companyShared.name = nameTextField.text ?? Company.companyShared.name
        Company.companyShared.address = addressTextField.text ?? Company.companyShared.address
        Company.companyShared.summary = summaryTextView.text ?? Company.companyShared.summary
        Company.companyShared.city.id = selectedCity?.id ?? Company.companyShared.city.id
        Company.companyShared.industry.id = selectedIndustry?.id ?? Company.companyShared.industry.id
        Company.companyShared.size.id = selectedSize?.id ?? Company.companyShared.size.id
        Company.companyShared.type.id = selectedType?.id ?? Company.companyShared.type.id
        Company.companyShared.storeData()
    }
}



// MARK: - Networking
extension UpdateCompanyInfoViewController: NetworkingHelperDeleget
{
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        if id == CITIES {handleGetCities(fromResponse: data)}
        if id == SIZES {handleGetSizes(fromResponse: data)}
        if id == INDUSTRIES {handleGetIndustries(fromResponse: data)}
        if id == TYPES {handleGetTypes(fromResponse: data)}
        if id == "REGISTER" {handleUpdateInfo(response: data)}
    }
    
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        displayAlert(localizedSitringFor(key: "FIALURE"))
    }
    
    
    /// connect to api and recieve data
    func getCitiesRequest()
    {
        NETWORK.connectTo(api: ApiNames.cities, withParameters: [ "lang": L102Language.currentAppleLanguage() ], andIdentifier: CITIES, withLoader: false, forController: self)
    }

    
    /// connect to api and recieve data
    func getSizesRequest()
    {
        NETWORK.connectTo(api: ApiNames.SIZES, withParameters: [ "lang": L102Language.currentAppleLanguage()], andIdentifier: SIZES, withLoader: false, forController: self)
    }
    
    
    /// connect to api and recieve data
    func getIndustriesRequest()
    {
        NETWORK.connectTo(api: ApiNames.INDUSTRIES, withParameters: [ "lang": L102Language.currentAppleLanguage()], andIdentifier: INDUSTRIES, withLoader: false, forController: self)
    }
    
    /// connect to api and recieve data
    func getTypesRequest()
    {
        NETWORK.connectTo(api: ApiNames.TYPES, withParameters:  [ "lang": L102Language.currentAppleLanguage() ], andIdentifier: TYPES, withLoader: false, forController: self)
    }
    
    
    /// uses for updating user in dataBase info which user updated
    func updateInfoRequest()
    {
         var files: [File] = []
        if let image = self.newUserImage {
            files.append(File(url: nil, parameterName: "photo", image: image))
        }
        var paramters: [String: String] = ["apiToken":Company.companyShared.apiToken,"name" : nameTextField.text ?? "","address": addressTextField.text ?? "", "Summary":summaryTextView.text,"city_id": String(describing: cities[cities.index(where: {$0.name == cityLabel.text}) ?? 0].id),"type_id": String(describing: types[types.index(where: {$0.name == typeLabel.text}) ?? 0].id),"size_id": String(describing: sizes[sizes.index(where: {String(describing: $0.size) == sizeLabel.text}) ?? 0].id)]
        if emailTextField.text != Company.companyShared.email
        {
            paramters["email"] =  emailTextField.text
        }
        
        NETWORK.connectToUpload(files: files, toApi: ApiNames.companyUpdateInfo, withParameters:paramters, andIdentifier: "REGISTER", withLoader: true, forController: self)
    }
    
   
    /// handle server response for register request
    ///
    /// - Parameter response: server response
    func handleUpdateInfo(response:JSON)
    {
        switch response["status"].intValue
        {
        case 200:
            updateUserDefaults()
            newUserImage = nil
            displayAlert(localizedSitringFor(key: "changesSucceed"))
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
            CITIESDROPDOWN.dataSource = cities.flatMap({ return "\($0.name)" })
            cityLabel.text = cities[cities.index(where: {$0.id == Company.companyShared.city.id}) ?? 0].name
            CITIESDROPDOWN.reloadAllComponents()
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
            SIZESDROPDOWN.dataSource = sizes.flatMap({ return "\($0.size)" })
            sizeLabel.text = String(describing: sizes[sizes.index(where: {$0.id == Company.companyShared.size.id}) ?? 0].size)
            SIZESDROPDOWN.reloadAllComponents()
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
            INDUSTRIESDROPDOWN.dataSource = industries.flatMap({ return "\($0.name)" })
            industryLabel.text = industries[industries.index(where: {$0.id == Company.companyShared.industry.id}) ?? 0].name
            INDUSTRIESDROPDOWN.reloadAllComponents()
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
            TYPESDROPDOWN.dataSource = types.flatMap({ return "\($0.name)" })
            typeLabel.text = types[types.index(where: {$0.id == Company.companyShared.type.id}) ?? 0].name
            TYPESDROPDOWN.reloadAllComponents()
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
}


//MARK: - Image Picker delegate
extension UpdateCompanyInfoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate
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
        
        profileImageView.image = image
        newUserImage = image
    }
}


//MARK: - text view Delegate
extension UpdateCompanyInfoViewController: UITextViewDelegate
{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if summaryTextView.textColor == UIColor.lightGray {
            summaryTextView.text = nil
            summaryTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if summaryTextView.text.isEmpty {
            summaryTextView.textColor = UIColor.lightGray
            summaryTextView.text = localizedSitringFor(key: "typeYourMessage")
            
        }
    }
}
