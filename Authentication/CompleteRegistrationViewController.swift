//
//  CompleteRegistrationViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 1/29/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//


import UIKit
import SwiftyJSON
import DropDown
import MobileCoreServices

class CompleteRegistrationViewController: UIViewController {

    ///IBOutlets
    @IBOutlet var coursesTextView: UITextView!
    @IBOutlet var certificationTextView: UITextView!
    @IBOutlet var gradautionYearTextField: UITextField!
    @IBOutlet var collegeTexrField: UITextField!
    @IBOutlet var majorLabel: UILabel!
    @IBOutlet var dropDownView: UIView!
    @IBOutlet var graduatedImageView: UIImageView!
    @IBOutlet var studentImageView: UIImageView!
    @IBOutlet var cvURLLabel: UILabel!  
    @IBOutlet var backView:UIView!
    @IBOutlet var loginButton:UIButton!
    
    ///Variables
    var isFemale: Bool?
    var isStudent: Bool?
    var majors = [Major]()
    var selectedMajor: Major?
    var fileURL: URL?
    
    ///CONSTANTS
    let dropDown = DropDown()
    let GETMAJORS = "GETMAJORS"
    let REGISTER = "REGISTER"
    let NETWORK = NetworkingHelper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        prepareStyle()
        doDelegate()
        getMajorsRequest()
    }
    
    
    ///IBActions
    @IBAction func changeRadioButton(sender:UIButton)
    {
        switch sender.tag {
        case 1:
            imageSwap(forfirstimage: graduatedImageView, andSecondImage: studentImageView)
            isStudent = false
        case 2:
            imageSwap(forfirstimage: studentImageView, andSecondImage: graduatedImageView)
            isStudent = true
        default:
            break
        }
    }
    
    
    @IBAction func registerAction()
    {
        if validateFields() {
            registerRequest()
            loginButton.isEnabled = false
            
        }
    }
    
    
    @IBAction func showDropDownAction()
    {
        dropDown.show()
    }
    
    
    @IBAction func pickFileAction()
    {
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypeCompositeContent)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        if let popoverController = importMenu.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: 0, y: screenHeight - 40, width: screenWidth, height:40)
        }
        self.present(importMenu, animated: true, completion: nil)
    }
    
    
    @IBAction func backAction(){
        dismiss(animated: true, completion: nil)
    }
}


extension CompleteRegistrationViewController
{
    ///uses for setting message textfield placeholder and color
    func prepareStyle()
    {
        flip(view: backView)
        coursesTextView.text = localizedSitringFor(key: "courses")
        coursesTextView.textColor = UIColor.lightGray
        certificationTextView.text = localizedSitringFor(key: "certifications")
        certificationTextView.textColor = UIColor.lightGray
        initMajorsDropDown()
    }
    
    
    /// init the city drop down
    func initMajorsDropDown()
    {
        self.view.layoutIfNeeded()
        dropDown.anchorView = dropDownView
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
        dropDown.selectionAction = {[unowned self] (index:Int,item:String) in
          if item != localizedSitringFor(key: "loading")
          {
                self.majorLabel.text = item
                self.selectedMajor = self.majors[index]
            }
        }
    }
    
    
    ///do delgate for networking and text fields
    func doDelegate()
    {
        NETWORK.deleget = self
        coursesTextView.delegate = self
        certificationTextView.delegate = self
    }
    

    /// uses for swabing between two images
    ///
    /// - Parameters:
    ///   - firstImageView: first image which will be swabed with anthor one
    ///   - secondImageView: second one
    func imageSwap(forfirstimage firstImageView: UIImageView,andSecondImage secondImageView: UIImageView)
    {
        firstImageView.image = UIImage(named: "Radio button")
        secondImageView.image = UIImage(named: "RadioButtonEmpty")
        
    }
    
    
    /// to check the validation of all text fields
    ///
    /// - Returns: true if user entered correct data
    func validateFields() -> Bool
    {
        if isStudent != true && isStudent != false
        {
            displayAlert(localizedSitringFor(key: "studentOrGraduated"))
            return false
        }
        if collegeTexrField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "emptyFaculty"), forController: self)
            return false
        }
        
        if gradautionYearTextField.text?.trimmingCharacters(in: (.whitespacesAndNewlines)).isEmpty == true
        {
            displayAlert(localizedSitringFor(key: "emptyGraduatuionYear"), forController: self)
            return false
        }
        if majorLabel.text == "Major"
        {
            displayAlert(localizedSitringFor(key: "emptyMajor"))
            return false
        }
        if cvURLLabel.text == localizedSitringFor(key: "uploadCV")
        {
            displayAlert(localizedSitringFor(key: "chooseCV"))
            return false
        }
        
        return true
    }
    
    
    ///store user data
    func storeUserData() {
        User.shared.faculty = self.collegeTexrField.text ?? ""
        User.shared.graduation = Int(self.gradautionYearTextField.text ?? "") ?? 0
        if coursesTextView.text != localizedSitringFor(key: "courses") && coursesTextView.text != ""
        {
            User.shared.courses = coursesTextView.text
            
        }
        if certificationTextView.text != localizedSitringFor(key: "certifications") && certificationTextView.text != ""
        {
            User.shared.certifications = certificationTextView.text
        }
        User.shared.major = selectedMajor ?? Major()
        User.shared.storeData()
    }
}


// MARK: - Networking
extension CompleteRegistrationViewController: NetworkingHelperDeleget {
    
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        loginButton.isEnabled = true
        if id == GETMAJORS { handleGetMajors(fromResponse: data)}
        if id == REGISTER { handleRegister(fromResponse: data)}
        
    }
    
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        displayAlert(localizedSitringFor(key: "FAILURE"))
        loginButton.isEnabled = true
    }
    
    
    /// connect to api and recieve data
    func getMajorsRequest()
    {
        NETWORK.connectTo(api: ApiNames.majors, withParameters: [ "lang": L102Language.currentAppleLanguage() ], andIdentifier: GETMAJORS, withLoader: false, forController: self)
    }
    
    
    ///connect to api to send data to server to save data
    func registerRequest()
    {
        var file: [File] = []
        
        if let url = self.fileURL {
            file.append(File(url: url, parameterName: "CV", image: nil))
        }
        
        var paramters : [String:String] = ["email": User.shared.email,"age": "25", "graduation": gradautionYearTextField.text ?? "", "faculty": collegeTexrField.text ?? "", "major_id": String(describing: selectedMajor?.id ?? 0)]
        paramters["isStudent"] = isStudent == true ? "1": "0"
        paramters["gender"] =  isFemale == false ? "male": "female"
        if coursesTextView.text != localizedSitringFor(key: "courses") && coursesTextView.text != ""
        {
            paramters["courses"] = coursesTextView.text

        }
        if coursesTextView.text != localizedSitringFor(key: "certifications") && coursesTextView.text != ""
        {
            paramters["certifications"] = certificationTextView.text
        }
        
        NETWORK.connectToUpload(files: file, toApi: ApiNames.userProfile, withParameters:paramters, andIdentifier: REGISTER, withLoader: true, forController: self)
    }
    
    
    /// handle Majors json response from server
    ///
    /// - parameter response : server response
    func handleGetMajors(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            majors.removeAll()
            response["majors"].arrayValue.forEach({self.majors.append(Major(fromJson: $0))})
            dropDown.dataSource = majors.flatMap({return $0.name})
            dropDown.reloadAllComponents()
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
    
    
    /// handle register json response from server
    ///
    /// - parameter response : server response
    func handleRegister(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            storeUserData()
            goToView(withId: "VerifyCodeViewController")
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
}



// MARK: - UIDocument deleget and picker delegate and navigationController delegate
extension CompleteRegistrationViewController:UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate{
   
    @available(iOS 8.0, *)
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        fileURL = url
        cvURLLabel.text = fileURL?.lastPathComponent ?? localizedSitringFor(key: "uploadCV")
    }
    
    
    @available(iOS 8.0, *)
    public func documentMenu(_ documentMenu:     UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


//MARK: - text view Delegate
extension CompleteRegistrationViewController : UITextViewDelegate
{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.tag == 1
        {
            if coursesTextView.textColor == UIColor.lightGray {
                coursesTextView.text = nil
                coursesTextView.textColor = UIColor.black
            }
        }
        if textView.tag == 2
        {
            if certificationTextView.textColor == UIColor.lightGray {
                certificationTextView.text = nil
                certificationTextView.textColor = UIColor.black
            }
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
    
        if coursesTextView.text.isEmpty {
            coursesTextView.textColor = UIColor.lightGray
            coursesTextView.text = localizedSitringFor(key: "courses")
            }
        
        if certificationTextView.text.isEmpty {
            certificationTextView.textColor = UIColor.lightGray
            certificationTextView.text = localizedSitringFor(key: "certifications")
            }
    }
}
