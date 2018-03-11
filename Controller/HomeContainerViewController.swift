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
        
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserHomeViewController")
            {
                    self.mainViewController = controller
            }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuViewController") {
                self.rightViewController = controller
            }
            
            SlideMenuOptions.leftViewWidth = screenWidth * 0.7
            SlideMenuOptions.rightViewWidth = screenWidth * 0.7
        super.awakeFromNib()

    }
        
        
}
