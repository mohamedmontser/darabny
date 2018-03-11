//  HomeContainerViewController.swift
//  Reading
//
//  Created by muhammed gamal on 1/29/18.
//  Copyright © 2018 MacPro. All rights reserved.
//
    
import Foundation
import UIKit
import SlideMenuControllerSwift
    
class HomeContainerViewController: SlideMenuController
{
    override func awakeFromNib() {
        if User.shared.email != ""
        {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserHomeViewController")
                {
                        self.mainViewController = controller
                }
        }
        if Company.companyShared.email != ""
        {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "CompanyHomeViewController")
            {
                self.mainViewController = controller
            }
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuViewController") {
            if L102Language.currentAppleLanguage() == "en" { self.leftViewController = controller} else { self.rightViewController = controller }
        }
            
        SlideMenuOptions.leftViewWidth = screenWidth * 0.7
        SlideMenuOptions.rightViewWidth = screenWidth * 0.7
        SlideMenuOptions.hideStatusBar = false
        
        super.awakeFromNib()
    }
        
        
}
