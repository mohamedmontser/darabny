//
//  UserApplicationsViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 2/4/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//


import UIKit
import SwiftyJSON
import  SlideMenuControllerSwift


class UserApplicationsViewController: UIViewController {
    
    ///Outlet
    @IBOutlet var tableView: UITableView!
    
    ///Varaibles
    /// the current interns page
    var page: Int = 0
    
    ///internships array
    var interships = [Internship]()
    
    /// determine if the app can request for more interns
    var canLoadMoreInterns: Bool = true
    
    ///CONSTANTS
    let NETWORK = NetworkingHelper()
    
    /// the interns table view refresher
    let refresher: UIRefreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NETWORK.deleget = self
        commonTableViewInit()
        getInternsReqeust(withLoader: true)
    }
    @IBAction func backView()
    {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - HelperMethod
extension UserApplicationsViewController
{
    
    /// init the interns table view
    func commonTableViewInit() {
        tableView.register(UINib(nibName: "SubmittedInternshipsTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        tableView.estimatedRowHeight = UIScreen.main.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular ? 500:295
        
        if #available(iOS 10.0, *)
        {
            tableView.refreshControl = refresher
        }
        else
        {
            tableView.addSubview(refresher)
        }
        
        // Configure Refresh Control
        refresher.addTarget(self, action: #selector(self.updateInternsTable), for: .valueChanged)
    }
    
    
    /// get next page for the interns list
    ///
    /// - Parameter index: the current cell indexPath
    func getNextPageIfNeeded(fromIndex index: IndexPath) {
        if index.row == interships.count - 1 && canLoadMoreInterns {
            page += 1
            getInternsReqeust(withLoader: false)
        }
    }
    
    
    /// called when the user pull interns table to refresh the intern
    @objc func updateInternsTable() {
        page = 0
        getInternsReqeust(withLoader: false)
    }
}


// MARK: - UITableViewDelegate,UITableViewDataSource
extension UserApplicationsViewController: UITableViewDelegate, UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interships.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SubmittedInternshipsTableViewCell
        cell.setcomponent(withInternship: interships[indexPath.row])
        
        getNextPageIfNeeded(fromIndex: indexPath)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainQueue {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "InternshipDetailsViewController") as! InternshipDetailsViewController
            vc.internID = self.interships[indexPath.row].id
            self.present(vc, animated: true, completion: nil)
        }
    }
}



// MARK: - Networking
extension UserApplicationsViewController: NetworkingHelperDeleget
{
    
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        handleInterns(fromResponse: data)
    }
    
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        mainQueue {
            self.refresher.endRefreshing()
        }
        
        displayAlert(localizedSitringFor(key: "FAILURE"))
    }
    
    
    /// get interns from server request
    ///
    /// - Parameter withLoader: show loader until finishing the request if paramter equal to true otherwise do not show loader
    func getInternsReqeust(withLoader loader: Bool)  {
        let paramters: [String: Any] = [
            "apiToken": "YBRz982rKaVaFVXsKX3f9oaWIzAfrk3HOQRsvThxKYqbDLlJN3sDZ2UJIsQwUTTs",
            "page": page
        ]
        
        NETWORK.connectTo(api: ApiNames.userApplications, withParameters: paramters, andIdentifier: "", withLoader: loader,forController: self)
    }
    
    
    /// handle server response for get interns request
    ///
    /// - Parameter response: server response
    func handleInterns(fromResponse response: JSON)
    {
        switch response["status"].intValue {
        case 200:
            if page == 0
            {
                interships.removeAll()
                canLoadMoreInterns = true
            }
            response["interns"].arrayValue.forEach({ self.interships.append(Internship(fromResponse: $0))})
        case 204:
            canLoadMoreInterns = false
        default:
            displayAlert(localizedSitringFor(key: "unKnownError"), forController: self)
        }
        
        mainQueue {
            self.refresher.endRefreshing()
            self.tableView.reloadData()
        }
    }
}
