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
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {       
        super.viewDidLoad()
        var user : PFUser = PFUser.currentUser()
        if(user["picture"] != nil){
            var imageFile : PFFile = user["picture"] as PFFile
            imageFile.getDataInBackgroundWithBlock {
                (imageData: NSData!, error: NSError!) -> Void in
                if !(error != nil) {
                    let image = UIImage(data:imageData)
                    let width = 50 as UInt
                    //let userAvatar  = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: width)
                    //self.userPic.image = userAvatar
                }
            }
        }
        else{
            var image = UIImage(named: "anon.jpg")
            let width = 100 as UInt
            //let userAvatar  = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: width)
            //self.userPic.image = userAvatar
        }
        if(user["realName"] != nil){
            var name : String = user.objectForKey("realName") as String
            self.userNameLabel.text = name
        }
        else{
            self.userNameLabel.text = "Anonymous"
        }
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
                var segue = FriendsSegue(identifier: "LoginView@Main", source: self, destination: self)
                segue.perform()
            }
        }
        else if(indexPath.row == 1){
            var storyBoard : UIStoryboard = UIStoryboard(name: "Messages", bundle: nil)
            var scene = storyBoard.instantiateViewControllerWithIdentifier("MessagesView") as InboxTableViewController
            var segue = FriendsSegue(identifier: "InitialView@Profile", source: scene, destination: self)
            segue.perform()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier : NSString = menuItems.objectAtIndex(indexPath.row) as NSString
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as UITableViewCell
        return cell
        
    }
}