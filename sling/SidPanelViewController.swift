//
//  SidPanelViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/16/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class SidePanelViewController : UITableViewController, UITableViewDelegate, UITableViewDataSource{
    var menuItems : NSArray = ["Logout", "Profile", "Settings"]
    
    override func viewDidLoad() {
        println("side panel")
       
        super.viewDidLoad()
        self.tableView.reloadData()
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 1
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            if(PFUser.currentUser() != nil){
                PFUser.logOut()
                self.performSegueWithIdentifier("LoginView@Main", sender: self)
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier : NSString = menuItems.objectAtIndex(indexPath.row) as NSString
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as UITableViewCell
        return cell
        
    }
}