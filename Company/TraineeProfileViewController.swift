//
//  TraineeProfileViewController.swift
//  Darabny
//
//  Created by muhammed gamal on 2/13/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SwiftyJSON

class TraineeProfileViewController: UIViewController {
    
    ///IBOutlets
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var universityLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var majorLabel: UILabel!
    @IBOutlet var coursesLabel: UILabel!
    @IBOutlet var certificatesLabel: UILabel!
    @IBOutlet var acceptButton: UIButton!
    @IBOutlet var rejectButton: UIButton!
    @IBOutlet var backView: UIView!
    
    ///Variables
    var userId = 0
    var internId = 0
    var application = Application (id: 0, name: "", date: 0, appStatus: "")
    
    ///CONSTANTS
    let network = NetworkingHelper()
    let USER_PROFILE = "userProfile"
    let ACCEPT = "accept"
    let REJECT = "reject"
    let viewer: DocumentViewer = DocumentViewer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        network.deleget = self
        getUserData()
        hideButtons()
        flip(view: backView)
    }

    
    //MARK: - IBActions
    @IBAction func backAction()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func acceptAction()
    {
        acceptUser()
    }
    
    
    @IBAction func rejectAction()
    {
        rejectUser()
    }
    
    
    @IBAction func downloadAction()
    {
        viewer.showFile(withURL: User.shared.cvURL, andLoader: true, forController: self)
    }
}


//MARK: - Helpers
extension TraineeProfileViewController
{
    ///update user data based on user defaults
    func displayLabelsData()
    {
        User.shared.apiToken = ""
        nameLabel.text = User.shared.name
        universityLabel.text = User.shared.faculty
        yearLabel.text = "\(User.shared.graduation)"
        majorLabel.text = User.shared.major.name
        if User.shared.courses == ""
        {
            coursesLabel.text = "Courses"
        }
            
        else
        {
            coursesLabel.text = User.shared.courses
        }
        
        if User.shared.certifications == ""
        {
            certificatesLabel.text = "Certifications"
        }
            
        else
        {
            certificatesLabel.text = User.shared.certifications
        }
        profileImage.sd_setImage(with: URL(string: User.shared.photoURL), placeholderImage: UIImage(named: "user-5"))        
        if User.shared.isStudent
        {
            typeLabel.text = "Student"
        }
        else
        {
            typeLabel.text = "Graduted"
        }
    }
    
    
    ///uses for hiding buttons based on application status
    func hideButtons() {
        if application.appStatus == "rejected"
        {
            acceptButton.isHidden = true
            rejectButton.isHidden = true
        }
        else if application.appStatus == "approved"
        {
            acceptButton.isHidden = true
            rejectButton.isHidden = true
        }
    }
}

//MARK: - Networking
extension TraineeProfileViewController:NetworkingHelperDeleget
{
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        switch id {
        case USER_PROFILE:
            handleUserData(fromResponse: data)
        case ACCEPT:
            handleAcceptUser(fromResponse: data)
        case REJECT:
            handleRejectUser(fromResponse: data)
        default:
            displayAlert(localizedSitringFor(key: "FAILURE"))
        }
    }
    
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        displayAlert(localizedSitringFor(key: "FAILURE"), forController: self)
    }
    
    
    /// to get the user data
    func getUserData()
    {
        network.connectTo(api: ApiNames.USER_PROFILE, withParameters: [ "apiToken": Company.companyShared.apiToken,"userId": userId], andIdentifier: USER_PROFILE, withLoader: true, forController: self)
    }
    
    
    /// connect to api and send data
    func acceptUser()
    {
        network.connectTo(api: ApiNames.ACCEPT_USER, withParameters: [ "apiToken": Company.companyShared.apiToken,"userId": userId,"internId":internId], andIdentifier: ACCEPT, withLoader: true, forController: self)
    }
    
   
    /// connect to api and send data
    func rejectUser()
    {
        network.connectTo(api: ApiNames.REJECT_USER, withParameters: [ "apiToken": Company.companyShared.apiToken,"userId": userId,"internId":internId], andIdentifier: REJECT, withLoader: true, forController: self)
    }
    

    /// handle user data json response from server
    ///
    /// - parameter response : server response
    func handleUserData(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            User.shared.getData(fromResponse: response["user"])
            displayLabelsData()
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
    
    
    /// handle user data json response from server
    ///
    /// - parameter response : server response
    func handleAcceptUser(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            self.dismiss(animated: true, completion: nil)
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
    
    
    /// handle user data json response from server
    ///
    /// - parameter response : server response
    func handleRejectUser(fromResponse response:JSON)
    {
        switch response["status"].intValue {
        case 200:
            self.dismiss(animated: true, completion: nil)
        default:
            displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
    }
}


