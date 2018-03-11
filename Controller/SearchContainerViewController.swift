//
//  SearchContainerViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 2/4/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift


class SearchContainerViewController: SlideMenuController
{
    override func awakeFromNib() {
        
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "SearchIntershipViewController")
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
