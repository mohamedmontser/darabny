//
//  ArchiveViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 2/13/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SwiftyJSON


class ArchiveViewController: UIViewController {
    
    
    ///IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backView: UIView!
    
    ///Variables
    var page:Int = 0
    var canLoadMoreInterns:Bool = true
    var interns:[Internship] = []
    
    ///CONSTANTS
    let refresher:UIRefreshControl = UIRefreshControl()
    let NETWORK = NetworkingHelper()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NETWORK.deleget = self
        commonTableViewInit()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "delete"), object: nil)
        flip(view: backView)
        getInternsRequest(withLoader:true)
    }
    
    
    ///MARK: - IBActions
    @IBAction func backAction()
    {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Helpers
extension ArchiveViewController
{
    
    /// init the interns table view
    func commonTableViewInit() {
        self.tableView.register(UINib(nibName:"ArchiveTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
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
        getInternsRequest(withLoader: false)
    }
    
    
    ///to reload table view data
    @objc func loadList()
    {
        tableView.reloadData()
    }
}


//MARK: - TableView delegate and data source
extension ArchiveViewController: UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for inter in interns{print(inter.isDeleted)}
        return interns.filter({$0.isDeleted == false}).count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArchiveTableViewCell
        cell.setcomponent(withInternship: interns[indexPath.row], controller: self)
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
        vc.internshipName = interns[indexPath.row].title
        vc.start = interns[indexPath.row].start
        vc.end = interns[indexPath.row].end
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - Networking
extension ArchiveViewController:NetworkingHelperDeleget
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
        NETWORK.connectTo(api: ApiNames.COMAPNY_INTERNS, withParameters: ["apiToken":Company.companyShared.apiToken, "page":page,"is_active":0], withLoader: true, forController: self)
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
            response["interns"].arrayValue.forEach({ self.interns.append(Internship(fromResponse: $0)) })
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

