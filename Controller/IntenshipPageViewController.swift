//
//  IntenshipPageViewController.swift
//  Darabny
//
//  Created by muhammed gamal on 2/6/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit

class IntenshipPageViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var descrptionTextView: UITextView!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var Title:String!
    var internId:Int!
    var Description:String!
    var start:Double!
    var end:Double!
    
    
    
    let network = NetworkingHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func backAction()
    {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelAction()
    {
        
    }
    
}
