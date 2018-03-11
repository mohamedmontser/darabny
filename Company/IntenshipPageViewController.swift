//
//  IntenshipPageViewController.swift
//  Darabny
//
//  Created by muhammed gamal on 2/6/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SwiftyJSON

class IntenshipPageViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var backView: UIView!
    
    var internshipName:String!
    var internId:Int!
    var Description:String!
    var start:Double!
    var end:Double!
    var page:Int = 0
    var canLoadMoreInterns:Bool = true
    var apps:[Application] = []
    var startDate:String!
    var endDate:String!
    
    let network = NetworkingHelper()
    let refresher:UIRefreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        network.deleget = self
        commonTableViewInit()
        getInternAppsRequest()
        flip(view: backView)
    }
    
    //MARK: - IBActions
    @IBAction func backAction()
    {
        self.dismiss(animated: true, completion: nil)
    }

}


//MARK: - Helpers
extension IntenshipPageViewController
{
    /// to init the view controller
    func convertDoubleDateToString()
    {
        startDate = ESDate.getDate(fromSeconds: start, withFormat: "dd/MM/yyyy")
        endDate = ESDate.getDate(fromSeconds: end, withFormat: "dd/MM/yyyy")
    }
    
    /// init the interns table view
    func commonTableViewInit() {
        self.tableView.register(UINib(nibName:"TraineeNamesTableViewCell", bundle: nil), forCellReuseIdentifier: "TraineeCell")
        self.tableView.register(UINib(nibName:"InternshipHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "InternshipHeaderCell")
        
        tableView.estimatedRowHeight = UIScreen.main.traitCollection.horizontalSizeClass == .regular ? 400 : 200
        
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
        if index.row == apps.count - 1 && canLoadMoreInterns {
            page += 1
            getInternAppsRequest()
        }
    }
    
    /// called when the user pull interns table to refresh the notifications
    @objc func updateInternsTable() {
        page = 0
        getInternAppsRequest()
    }
    
}


//MARK: - TableView delegate and data source
extension IntenshipPageViewController: UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : apps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return indexPath.section == 0 ? getInternshipHeaderCell(forIndexPath: indexPath): getTraineeNameCell(forIndexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? nil : Bundle.main.loadNibNamed("TraineeHeaderView", owner: self, options: nil)?.first as? UIView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : UIScreen.main.traitCollection.horizontalSizeClass == .regular ? 70 : 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0
        {
            return
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TraineeProfileViewController") as! TraineeProfileViewController
        vc.userId = apps[indexPath.row].id
        vc.internId = internId
        vc.application = apps[indexPath.row]
        self.present(vc, animated: true, completion: nil)
    }
    
    
    /// get Trainee Name cell
    ///
    /// - Parameter indexPath: current index path for this cell
    /// - Returns: PostTableViewCell
    func getTraineeNameCell(forIndexPath indexPath: IndexPath) -> TraineeNamesTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TraineeCell", for: indexPath) as! TraineeNamesTableViewCell
        cell.initWith(app: apps[indexPath.row], forController: self)
        getNextPageIfNeeded(fromIndex: indexPath)
        return cell
    }
    
    /// get Trainee Name cell
    ///
    /// - Parameter indexPath: current index path for this cell
    /// - Returns: PostTableViewCell
    func getInternshipHeaderCell(forIndexPath indexPath: IndexPath) -> InternshipHeaderTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InternshipHeaderCell", for: indexPath) as! InternshipHeaderTableViewCell
        convertDoubleDateToString()
        cell.initWith(id: internId, internshipName: internshipName, descrption: Description, startDate: startDate, endDate: endDate, forController: self)
        return cell
    }
}


//MARK: - Networking
extension IntenshipPageViewController:NetworkingHelperDeleget
{
    func onHelper(getData data: JSON, fromApiName name: String, withIdentifier id: String) {
        handleInternApps(response: data)
    }
    
    func onHelper(getError error: String, fromApiName name: String, withIdentifier id: String) {
        mainQueue {
            self.refresher.endRefreshing()
        }
        displayAlert(localizedSitringFor(key: "FAILURE"), forController: self)
    }
    
    func getInternAppsRequest()
    {
        network.connectTo(api: ApiNames.INTERNS_APP, withParameters: ["apiToken":Company.companyShared.apiToken, "page":page,"internId":internId], withLoader: true, forController: self)
    }
    
    func handleInternApps(response:JSON) {
            switch response["status"] {
            case 200:
                response["apps"].arrayValue.forEach({ self.apps.append(Application(fromJSON: $0)) })
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
