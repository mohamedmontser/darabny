//
//  CompanyHomeViewController.swift
//  Darabny
//
//  Created by muhammed gamal on 2/4/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SwiftyJSON

class CompanyHomeViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var page:Int = 0
    var canLoadMoreInterns:Bool = true
    var interns:[Intern] = []
    
    ///CONSTANTS
    let refresher:UIRefreshControl = UIRefreshControl()
    let network = NetworkingHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        network.deleget = self
        commonTableViewInit()
        getInternsRequest(withLoader:true)
    }
    
    @IBAction func menuAction()
    {
        
    }
    
}

//MARK: - Helpers
extension CompanyHomeViewController
{
    /// init the interns table view
    func commonTableViewInit() {
        self.tableView.register(UINib(nibName:"CompanyHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeCell")
        
        tableView.estimatedRowHeight = 60.0
        
        // Add refresher to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresher
        } else {
            tableView.addSubview(refresher)
        }
        
        // Configure Refresh Control
        refresher.addTarget(self, action: #selector(self.updateInternsTable), for: .valueChanged)
    }
    
    /// get next page for the interns list
    ///
    /// - Parameter index: the current cell indexPath
    func getNextPageIfNeeded(fromIndex index:IndexPath) {
        if index.row == interns.count - 1 && canLoadMoreInterns {
            page += 1
            getInternsRequest(withLoader: false)
        }
    }
    
    /// called when the user pull interns table to refresh the notifications
    @objc func updateInternsTable() {
        page = 0
        canLoadMoreInterns = true
        getInternsRequest(withLoader: false)
    }
}


//MARK: - TableView delegate and data source
extension CompanyHomeViewController: UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! CompanyHomeTableViewCell
        cell.initWith(intern: interns[indexPath.row], forController: self)
        getNextPageIfNeeded(fromIndex: indexPath)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "IntenshipPageViewController") as! IntenshipPageViewController
        vc.internId = interns[indexPath.row].id
        vc.Description = interns[indexPath.row].description
        vc.Title = interns[indexPath.row].title
        vc.start = interns[indexPath.row].start
        vc.end = interns[indexPath.row].end
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - Networking
extension CompanyHomeViewController:NetworkingHelperDeleget
{
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        handleGetInterns(response: data)
    }
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        mainQueue {
            self.refresher.endRefreshing()
        }
         displayAlert(localizedSitringFor(key: "FAILURE"), forController: self)
    }
    
    /// get interns from server request
    ///
    /// - Parameter withLoader: show loader until finishing the request
    func getInternsRequest(withLoader:Bool)
    {
        User.shared.apiToken = "zcsgjbmfXAIqAdbEopNXwWaRlDP7OWpAEfQ25ntZAHJVE2umSIsbUD5bzm2lTzTs"
        network.connectTo(api: Config.BASEURL+"company/interns", withParameters: ["apiToken":User.shared.apiToken, "page":page,"is_active":1], withLoader: true, forController: self)
    }
    
    /// handle server response for get notifications request
    ///
    /// - Parameter response: server response
    func handleGetInterns(response:JSON)  {
        switch response["status"] {
        case 200:
            if page == 0
            {
                interns.removeAll()
            }
            response["interns"].arrayValue.forEach({ self.interns.append(Intern(fromJSON: $0)) })
            tableView.reloadData()
        case 204:
            self.canLoadMoreInterns = false
        default:
           displayAlert(localizedSitringFor(key: "tryAgain"), forController: self)
        }
        
        mainQueue {
            self.refresher.endRefreshing()
            self.tableView.reloadData()
        }
        
    }
}
