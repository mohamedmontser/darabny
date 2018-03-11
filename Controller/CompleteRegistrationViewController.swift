//
//  CompleteRegistrationViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 1/29/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//


import UIKit
import SwiftyJSON
import Alamofire
import DropDown
import MobileCoreServices

class CompleteRegistrationViewController: UIViewController {

    ///IBOutlets
    @IBOutlet var coursesTextView:UITextView!
    @IBOutlet var certificationTextView:UITextView!
    @IBOutlet var gradautionYearTextField:UITextField!
    @IBOutlet var ageTextField:UITextField!
    @IBOutlet var collegeTexrField:UITextField!
    @IBOutlet var majorLabel:UILabel!
    @IBOutlet var dropDownView:UIView!
    @IBOutlet var graduatedImageView:UIImageView!
    @IBOutlet var studentImageView:UIImageView!
    @IBOutlet var femaleImageView:UIImageView!
    @IBOutlet var maleImageView:UIImageView!
    
    ///Varaibles
    var isFemale = false
    var isStudent = false
    var majors = [Major]()
    var selectedMajor: Major?
    
    ///CONSTANTS
    let dropDown = DropDown()
    let GETMAJORS = "GETMAJORS"
    let REGISTER = "REGISTER"
    let NETWORK = NetworkingHelper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NETWORK.deleget = self
        initMajorsDropDown()
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
        case 3:
            imageSwap(forfirstimage: maleImageView , andSecondImage: femaleImageView)
            isFemale = false
        case 4:
            imageSwap(forfirstimage: femaleImageView, andSecondImage: maleImageView)
            isFemale = true
        default:
            break
        }
    }
    
    @IBAction func showDropDownAction()
    {
        dropDown.show()
    }
    
    @IBAction func pickFileAction()
    {
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    @IBAction func backAction(){
        dismiss(animated: true, completion: nil)
    }
}


extension CompleteRegistrationViewController
{
    /// init the city drop down
    func initMajorsDropDown()
    {
        self.view.layoutIfNeeded()
        dropDown.anchorView = dropDownView
        dropDown.dataSource = [localizedSitringFor(key: "loading")]
        dropDown.direction = .bottom
        dropDown.selectionAction = {[unowned self] (index:Int,item:String) in
            self.majorLabel.text = item
            self.selectedMajor = self.majors[index]
        }
    }
    
    func imageSwap(forfirstimage firstImageView: UIImageView,andSecondImage secondImageView: UIImageView)
    {
        firstImageView.image = UIImage(named: "Radio button")
        secondImageView.image = UIImage(named: "Radio button 2")
        
    }
}


extension CompleteRegistrationViewController:NetworkingHelperDeleget {
    
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        if id == GETMAJORS { handleGetMajors(fromResponse: data)}
        if id == REGISTER { handleRegister(fromResponse: data)}
        
    }
    
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        displayAlert(localizedSitringFor(key: "FAILURE"))
    }
    
    
    /// connect to api and recieve data
    func getMajorsRequest()
    {
        let parameters  =
            [ "lang": L102Language.currentAppleLanguage() ]
        
        NETWORK.connectTo(api: ApiNames.majors, withParameters: parameters, andIdentifier: GETMAJORS, withLoader: false, forController: self)
    }
    
    
    ///connect to api to send data to server to save data
    func registerRequest()
    {
        let paramters = ["":""]
        
        NETWORK.connectTo(api: ApiNames.register, withParameters: paramters, andIdentifier: REGISTER, withLoader: true, forController: self)
        
    }
    
    
    /// handle cities and towns json8response from server
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
    
    
    /// handle cities and towns json8response from server
    ///
    /// - parameter response : server response
    func handleRegister(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            goToView(withId: "CompleteRegistrationViewController")
        case 405:
            displayAlert(localizedSitringFor(key: "StoredEmail"), forController: self)
        case 406:
            displayAlert(localizedSitringFor(key: "StoredPhone"), forController: self)
        default:
            displayAlert(localizedSitringFor(key: "TryـAgain"), forController: self)
        }
    }
}



extension CompleteRegistrationViewController:UIDocumentMenuDelegate,UIDocumentPickerDelegate,UINavigationControllerDelegate{
    @available(iOS 8.0, *)
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        
        let cico = url as URL
        print("The Url is : /(cico)")
        
        
        //optional, case PDF -> render
        //displayPDFweb.loadRequest(NSURLRequest(url: cico) as URLRequest)
        
        
        
        
    }
    
    @available(iOS 8.0, *)
    public func documentMenu(_ documentMenu:     UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
        
    }
    
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        print("we cancelled")
        
        dismiss(animated: true, completion: nil)
        
        
    }
}

