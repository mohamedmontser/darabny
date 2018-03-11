//
//  TraineeOrCompanyViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 2/12/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit

class TraineeOrCompanyViewController: UIViewController {
   
    @IBOutlet var backView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        flip(view: backView)
    }
    
    
    @IBAction func backAction()
    {
        dismiss(animated: true, completion: nil)
    }
}
