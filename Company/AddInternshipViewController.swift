//
//  AddInternshipViewController.swift
//  Darabny
//
//  Created by muhammed gamal on 2/12/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import DropDown
import SwiftyJSON

class AddInternshipViewController: UIViewController {

    ///Outlets
    @IBOutlet var internshipNameTextField: UITextField!
    @IBOutlet var descrptionTextView: UITextView!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDataLabel: UILabel!
    @IBOutlet var cityDropDownView: UIView!
    @IBOutlet var departmentDropDownView: UIView!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var departmentLabel: UILabel!
    @IBOutlet var backView: UIView!
    
    ///Variables
    var isStartButton = true
    var citiesDropDown = DropDown()
    var departmentsDropDown = DropDown()
    var cities:[City] = []
    var departments:[Department] = []
    var selectedCity : City!
    var selectedDepartment:Department!
    var startDate:Double!
    var endDate:Double!

    
    ///CONSTANTS
    let network = NetworkingHelper()
    let GET_CITIES = "getCities"
    let GET_DEPARTMENT = "getDepartment"
    let ADD_INTERN = "addIntern"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationUpdate()
        network.deleget = self
        dropDownsApis()
        displayDropDown()
        flip(view: backView)
    }
    
    //MARK: - IBActions
    @IBAction func selectStartDate()
    {
        isStartButton = true
        let view = DatePickerView.getInstance(forController: self, isToChange: false)
        self.view.addSubview(view)

    }
    
    @IBAction func selectEndDate()
    {
        isStartButton = false
        let view = DatePickerView.getInstance(forController: self, isToChange: false)
        self.view.addSubview(view)

    }
    
    @IBAction func backAction()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cityDropDownAction()
    {
        citiesDropDown.show()
    }
    
    @IBAction func departmentDropDownAction()
    {
        departmentsDropDown.show()
    }
    
    @IBAction func calendarAction()
    {
        let view = DatePickerView.getInstance(forController: self, isToChange: true)
        self.view.addSubview(view)
    }
    
    @IBAction func addAction()
    {
        if ValidateFields()
        {
            sendAddInternRequest()
        }
    }
}


//MARK: - Helpers
extension AddInternshipViewController
{
    /// to notify the label to change
    func notificationUpdate()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLabelDate), name: NSNotification.Name(rawValue: "date"), object: nil)
    }
    
    /// to update date label with the new value
    @objc func refreshLabelDate()
    {
        if isStartButton
        {
            startDate = Time.shared.date
            startDateLabel.text = ESDate.getDate(fromSeconds: startDate, withFormat: "dd/MM/yyyy")
        }
            
        else
        {
            endDate = Time.shared.date
            endDataLabel.text = ESDate.getDate(fromSeconds: endDate, withFormat: "dd/MM/yyyy")
        }
    }
    
     /// to init the all dropDown views 
    func displayDropDown()
    {
        initiate(dropDown: departmentsDropDown, view: departmentDropDownView)
        initiate(dropDown: citiesDropDown, view: cityDropDownView)
    }
    
    /// to send all the dropDown apis requests
    func dropDownsApis()
    {
        getCitiesRequest()
        getDepartmentRequest()
    }
    
    /// used to make drop downs get be ready to show
    func initiate( dropDown: DropDown,view:UIView)
    {
        self.view.layoutIfNeeded()
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
        dropDown.anchorView = view
        dropDown.dataSource = [localizedSitringFor(key: "loading")]
        dropDown.direction = .bottom
        
        switch dropDown {
        case citiesDropDown:
            dropDown.selectionAction = selectCity(atIndex:withName:)
        case departmentsDropDown:
            dropDown.selectionAction = selectDepartment(atIndex:withName:)
        default:
            return
        }
        
    }
    
    func selectCity(atIndex index:Int, withName name:String)
    {
        guard cities.count > 0 else {return}
        self.cityLabel.text = name
        self.cityLabel.textColor = UIColor.black
        self.selectedCity = self.cities[index]
    }
    
    func selectDepartment(atIndex index:Int, withName name:String)
    {
        guard departments.count > 0 else {return}
        self.departmentLabel.text = name
        self.departmentLabel.textColor = UIColor.black
        self.selectedDepartment = self.departments[index]
    }
   
    /// reload cities dropd down data
    func reloadCitiesDropDownData()
    {
        citiesDropDown.dataSource = cities.flatMap({ return $0.name })
        citiesDropDown.reloadAllComponents()
    }
    
    /// reload departments dropd down data
    func reloadDepartmentsDropDownData()
    {
        departmentsDropDown.dataSource = departments.flatMap({ return $0.name })
        departmentsDropDown.reloadAllComponents()
    }
    
    
    /// to check the validation of all text fields
    ///
    /// - Returns: true if user entered correct data
    func ValidateFields() -> Bool
    {
        if internshipNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "emptyName"), forController: self)
            return false
        }
        
        if (internshipNameTextField.text?.count ?? 0) < 5
        {
            displayAlert(localizedSitringFor(key: "notvalidname"), forController: self)
            return false
        }
        if cityLabel.text == ""
        {
            displayAlert(localizedSitringFor(key: "enterCity"), forController: self)
            return false
        }
        
        if departmentLabel.text == ""
        {
            displayAlert(localizedSitringFor(key: "enterDepartment"), forController: self)
            return false
        }
        
        if descrptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "emptydescrption"), forController: self)
            return false
        }
        if startDate > endDate
        {
            displayAlert(localizedSitringFor(key: "errorDate"), forController: self)
             return false
        }
        return true
    }
}


//MARK: - Networking
extension AddInternshipViewController:NetworkingHelperDeleget
{
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        switch id {
        case GET_DEPARTMENT:
            handleGetDepartments(fromResponse: data)
        case GET_CITIES:
            handleGetCities(fromResponse: data)
        case ADD_INTERN:
            handleAddIntern(fromResponse: data)
        default:
            displayAlert(localizedSitringFor(key: "FAILURE"))
        }
    }
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        displayAlert(localizedSitringFor(key: "FAILURE"), forController: self)
    }
    
    /// connect to api and send data
    func sendAddInternRequest()
    {
        network.connectTo(api: ApiNames.ADD_INTERN, withParameters: ["apiToken":Company.companyShared.apiToken,"title":internshipNameTextField.text!,"start":startDate,"end":endDate,"city_id":selectedCity!.id,"department_id":selectedDepartment!.id,"description":descrptionTextView.text!],andIdentifier: ADD_INTERN, withLoader: true, forController: self)
    }
    
    /// connect to api and recieve data
    func getCitiesRequest()
    {
        network.connectTo(api: ApiNames.cities, withParameters: [ "lang": L102Language.currentAppleLanguage() ], andIdentifier: GET_CITIES, withLoader: false, forController: self)
    }
    
    /// connect to api and recieve data
    func getDepartmentRequest()
    {
        network.connectTo(api: ApiNames.departments, withParameters: [ "lang": L102Language.currentAppleLanguage() ], andIdentifier: GET_DEPARTMENT, withLoader: false, forController: self)
    }
    
    /// handle add intern json response from server
    ///
    /// - parameter response : server response
    func handleAddIntern(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            displayAlert(localizedSitringFor(key: "addIntern"), forController: self)
            pushToView(withId: "HomeContainerViewController")
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
    
    /// handle Departments json response from server
    ///
    /// - parameter response : server response
    func handleGetDepartments(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            departments.removeAll()
            response["departments"].arrayValue.forEach({self.departments.append(Department(fromJson: $0))})
            reloadDepartmentsDropDownData()
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
}
