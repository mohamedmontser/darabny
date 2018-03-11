//
//  SideMenuViewController.swift
//  Darabny
//
//  Created by Wafaa Farrag on 2/4/18.
//  Copyright © 2018 muhammed gamal. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class SideMenuViewController: UIViewController {
    
   ///IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    
    ///Variable
    var userItems = [MenuItem]()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///init table veiw cell
        self.tableView.register(UINib(nibName: "SideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        initMenuItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUserData()
    }
    
    
    //MARK: - IBAction
    @IBAction func profileAction()
    {
        if User.shared.apiToken != "" {
            closeSideMenu()
            goToView(withId: "UserProfileViewController")}
        if Company.companyShared.apiToken != "" {
            closeSideMenu()
            goToView(withId: "UpdateCompanyInfoViewController")}
    }
}

extension SideMenuViewController
{
    
    /// init the side menu items, if you want to add any item to the side menu you should add it here
    func initMenuItems() {
        //add user items
        userItems.append(MenuItem(title: localizedSitringFor(key: "home"), icon: "home", screenId: "HomeViewController"))
         if User.shared.email != ""
        {
            userItems.append(MenuItem(title: localizedSitringFor(key: "submittedApplications"), icon: "time", screenId: "UserApplicationsViewController"))
        }
        if Company.companyShared.email != ""
        {
            userItems.append(MenuItem(title: localizedSitringFor(key: "archive"), icon: "Archives", screenId: "ArchiveViewController"))
        }
        userItems.append(MenuItem(title: localizedSitringFor(key: "aboutUs"), icon: "about us", screenId: "AboutUsViewController"))
        userItems.append(MenuItem(title: localizedSitringFor(key: "Suggestion&complaint"), icon: "Support", screenId: "ComplaintsAndSuggestionsViewController"))
        userItems.append(MenuItem(title: localizedSitringFor(key: "language"), icon: "Language", screenId: "Language"))
         userItems.append(MenuItem(title: localizedSitringFor(key: "Logout"), icon: "Logout", screenId: "WelcomeViewController"))
        self.tableView.reloadData()
    }
    
   
    ///use this function to set username and Image
    func updateUserData()
    {
        if User.shared.apiToken != ""
        {
            userImageView.sd_setImage(with: URL(string: User.shared.photoURL), placeholderImage: UIImage(named: "user-5"))
            userNameLabel.text = User.shared.name
        }
        if Company.companyShared.apiToken != ""
        {
            userImageView.sd_setImage(with: URL(string: Company.companyShared.logoURL), placeholderImage: UIImage(named: "user-5"))
            userNameLabel.text = Company.companyShared.name
        }
    }
    
    
    /// select menu item in user items
    ///
    /// - Parameter index: item index
    func selectUserItem(atIndex index:Int) {
        if index == 0 {
            closeSideMenu()
        }else if index == 4
        {
            changeLanguage()
            
        }
        else if index == 5
        {
            Company.companyShared.logout()
            User.shared.logout()
            pushToView(withId: "WelcomeViewController")
        }
        else{
             closeSideMenu()
            goToView(withId: userItems[index].screenId, fromController: self)
        }
    }
    
    
    /// close side menu
    func closeSideMenu() {
        if L102Language.currentAppleLanguage() == "en" {
            self.closeLeft()
        }else {
            self.closeRight()
        }
    }
    
    
    ///uses to switch between arabic and english languages
    func changeLanguage()
    {
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetController: UIAlertController = UIAlertController(title: "Please select", message: "choose language", preferredStyle: .actionSheet)
        actionSheetController.popoverPresentationController?.sourceView = self.view
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(cancelActionButton)
        
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: 0, y: screenHeight-80, width: screenWidth, height: 80)
        }
        
        let arabicButtonAction = UIAlertAction(title: "عربي", style: .default)
        { _ in
            if L102Language.currentAppleLanguage() == "ar" { return }
            L102Language.setAppleLAnguageTo(lang: "ar")
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            pushToView(withId: "HomeContainerViewController")
        }
        actionSheetController.addAction(arabicButtonAction)
        
        let englishButtonAction = UIAlertAction(title: "english", style: .default)
        { _ in
            if L102Language.currentAppleLanguage() == "en" { return }
            L102Language.setAppleLAnguageTo(lang: "en")
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            pushToView(withId: "HomeContainerViewController")
        }
        actionSheetController.addAction(englishButtonAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
}


//MARK: - UITableView delegate and data source
extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  userItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SideMenuTableViewCell
            cell.initWith(item: userItems[indexPath.row])
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            mainQueue {
                self.selectUserItem(atIndex: indexPath.row)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height:CGFloat = UIScreen.main.traitCollection.horizontalSizeClass == .regular ? 120 : 60
        return height
    }
}
