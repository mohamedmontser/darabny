//
//  InternshipDetailsViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 1/30/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage


class InternshipDetailsViewController: UIViewController {

    ///Outlets
    @IBOutlet var fieldLabel:UILabel!
    @IBOutlet var cityLabel:UILabel!
    @IBOutlet var internshipDurationLabel:UILabel!
    @IBOutlet var internshipDescriptionLabel:UILabel!
    @IBOutlet var stratDateLabel:UILabel!
    @IBOutlet var endDateLabel:UILabel!
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var departmentLabel:UILabel!
    @IBOutlet var logoImageView:UIImageView!
    @IBOutlet var applyButton:UIButton!
    
    ///Varaibles
    var internID: Int = 0
   
    ///CONSTANTS
    let NETWORK = NetworkingHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NETWORK.deleget = self
        showLoaderForController(self)
        getMajorsRequest()
    }
    
    @IBAction func applyActin()
    {
        applyRequest()
        applyButton.isEnabled = false
    }
    
    @IBAction func backView()
    {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - HelperMethods
extension InternshipDetailsViewController
{
    
    ///set the details of internship
    ///
    /// - Parameter internDetail: internshipDetails
    func setInternshipDetails(internDetails:JSON)
    {
        fieldLabel.text = internDetails["comany_name"].stringValue
        titleLabel.text = internDetails["title"].stringValue
        cityLabel.text = internDetails["cityName"].stringValue
        stratDateLabel.text = "\(localizedSitringFor(key: "From:"))\(internDetails["start"].stringValue)"
        endDateLabel.text =  "\(localizedSitringFor(key: "To:"))\(internDetails["end"].stringValue)"
        internshipDescriptionLabel.text = internDetails["description"].stringValue
        departmentLabel.text = internDetails["department"].stringValue
        logoImageView.sd_setImage(with: URL(string:internDetails["logoUrl"].stringValue), placeholderImage: UIImage(named:""))
        internshipDurationLabel.text = "\(durationOfInternship(formStartDate: internDetails["start"].stringValue, toEndDate: internDetails["end"].stringValue)) \(localizedSitringFor(key: "days"))"
        hideLoaderForController(self)
        checkInternshipStatus(forStatus: internDetails["app_status"].stringValue)
    }
    
    
    /// calcuate the date of the duration
    ///
    /// - Parameters:
    ///   - startDate: the start of internship
    ///   - endDate: the end of internship
    /// - Returns: the duration of intership
    func durationOfInternship(formStartDate startDate: String, toEndDate endDate: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate:Date = dateFormatter.date(from: startDate)!
        let endDate:Date = dateFormatter.date(from: endDate)!
        let newdate =  Calendar.current.dateComponents([.day], from: startDate, to: endDate).day
        return String(describing:newdate!)
    }
    
    
    /// check about user if him applied before or not and if him applied before which status
    ///
    /// - Parameter status:internship status
    func checkInternshipStatus(forStatus status:String) {
        switch status {
        case "waiting":
            applyButton.isEnabled = false
            applyButton.backgroundColor = UIColor.yellow
            applyButton.setTitle(localizedSitringFor(key: "waiting"), for: .normal)
        case "approved":
            applyButton.setTitle(localizedSitringFor(key: "approved"),for: .normal)
            applyButton.isEnabled = false
            applyButton.backgroundColor = UIColor.green
        case "rejected":
            applyButton.setTitle(localizedSitringFor(key: "rejected"),for: .normal)
            applyButton.isEnabled = false
            applyButton.backgroundColor = UIColor.red
        default:
            break
        }
    }
}

//MARK: - Networking
extension InternshipDetailsViewController:NetworkingHelperDeleget {
    
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        if id == "MAJORS" {handleInternshipDetails(fromResponse: data)}
        if id == "APPLY" {handleApply(fromResponse: data)}
    }
    
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        displayAlert(localizedSitringFor(key: "FAILURE"), forController: self)
    }
    
    
    /// connect to api and recieve data
    func getMajorsRequest()
    {
        let parameters: [String: Any] =
            [ "lang" : L102Language.currentAppleLanguage(),
              "apiToken": User.shared.apiToken,
              "intern_id": internID
           ]
        
        NETWORK.connectTo(api: ApiNames.internshipDetails, withParameters: parameters, andIdentifier: "MAJORS", withLoader: false, forController: self)
    }
    
    
    /// connect to api and recieve data
    func applyRequest()
    {
        let parameters: [String: Any] =
            ["apiToken": User.shared.apiToken,
             "intern_id": internID
        ]
        
        NETWORK.connectTo(api: ApiNames.userApply, withParameters: parameters, andIdentifier: "APPLY", withLoader: false, forController: self)
    }
    
    /// handle intershipDetials response
    ///
    /// - parameter response : server response
    func handleInternshipDetails(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            setInternshipDetails(internDetails: response["intern"])
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
    
    /// handle intershipDetials response
    ///
    /// - parameter response : server response
    func handleApply(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            applyButton.setTitle("youApplied", for: .normal)
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
}
