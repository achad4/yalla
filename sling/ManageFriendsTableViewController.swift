//
//  ManageFriendsTableViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 2/21/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class ManageFriendsTableViewController : UITableViewController{
    
    var friendSegmentedControl : UISegmentedControl!
    var users : NSMutableArray = NSMutableArray()
    var filteredUsers : NSMutableArray = NSMutableArray()
    var isSearching : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var items = ["Friends", "Pending", "Add"]
        self.friendSegmentedControl = UISegmentedControl(items: items)
        self.navigationItem.titleView = self.friendSegmentedControl
        self.friendSegmentedControl.selectedSegmentIndex = 0
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.loadData()
    }
    func loadData(){
        users.removeAllObjects()
        //find users friends
        if(self.friendSegmentedControl.selectedSegmentIndex == 0){
            var friendQuery1 = PFQuery(className: "Friend")
            friendQuery1.whereKey("fromUser", equalTo: PFUser.currentUser())
            friendQuery1.whereKey("status", equalTo: "approved")
            var friendQuery2 = PFQuery(className: "Friend")
            friendQuery2.whereKey("toUser", equalTo: PFUser.currentUser())
            friendQuery2.whereKey("status", equalTo: "approved")
            var friendQuery3 = PFQuery.orQueryWithSubqueries([friendQuery1, friendQuery2])
            friendQuery3.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]!, error : NSError!) -> Void in
                if(error == nil){
                    for object in objects{
                        let pdf = object as! PFObject
                        self.users.addObject(pdf)
                    }
                    self.tableView.reloadData()
                }
            })
        }
        //find users friend requests
        else if(self.friendSegmentedControl.selectedSegmentIndex == 1){
            var friendQuery = PFQuery(className: "Friend")
            friendQuery.whereKey("toUser", equalTo: PFUser.currentUser())
            friendQuery.whereKey("status", equalTo: "pending")
            friendQuery.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]!, error : NSError!) -> Void in
                if(error == nil){
                    for object in objects{
                        let pdf = object as! PFObject
                        self.users.addObject(pdf)
                    }
                    self.tableView.reloadData()
                }
            })
        }
        //show everyone
        else{
            var friendQuery = PFQuery(className: "_User")
            friendQuery.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]!, error : NSError!) -> Void in
                if(error == nil){
                    for object in objects{
                        let pdf = object as! PFObject
                        self.users.addObject(pdf)
                    }
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ManageUserTableCell
        var users : NSMutableArray = self.users.objectAtIndex(indexPath.section) as! NSMutableArray
        var user : PFObject = self.users.objectAtIndex(indexPath.row) as! PFObject
        if(isSearching == true){
            user = self.filteredUsers.objectAtIndex(indexPath.row) as! PFObject
        }
        cell.user = user
        for next in cell.userCellView.subviews as! [UIView]{
            next.removeFromSuperview()
        }
        var X : CGFloat = cell.frame.origin.x
        var Y : CGFloat = 0
        var centerX = cell.frame.origin
        cell.userCellView.frame = CGRectMake(X, Y, self.view.bounds.size.width - 10, 70)
        cell.userCellView.center = CGPointMake(X + cell.frame.size.width/2, Y + cell.frame.height/2)
        cell.userName = UILabel(frame: CGRectMake(0, 0, 200, 70))
        cell.userName.center = CGPointMake(175, 32.5)
        cell.userName.text = user.objectForKey("realName") as? String
        
        if(user["picture"] != nil){
            var imageFile : PFFile = user["picture"] as! PFFile
            imageFile.getDataInBackgroundWithBlock {
                (imageData: NSData!, error: NSError!) -> Void in
                if !(error != nil) {
                    let image = UIImage(data:imageData)
                    let width = 50 as UInt
                    let circleImage = JSQMessagesAvatarImageFactory.circularAvatarHighlightedImage(image, withDiameter:width)
                    cell.userImage = UIImageView(image: circleImage)
                    cell.userCellView.addSubview(cell.userImage)
                    cell.userImage.alpha = 0.5
                    cell.userImage.center = CGPointMake(35, 35)
                }
            }
        }
        else{
            var image = UIImage(named: "anon.jpg")
            let width = 50 as UInt
            let circleImage = JSQMessagesAvatarImageFactory.circularAvatarHighlightedImage(image, withDiameter: width)
            cell.userImage = UIImageView(image: circleImage)
            cell.userCellView.addSubview(cell.userImage)
        }
        
        var parentViewController = self.parentViewController as! FriendParentViewController
        
        //cell.convo = parentViewController.convo
        cell.userCellView.addSubview(cell.userName)
        //cell.userCellView.addSubview(cell.userButton)
        cell.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        
        
        // Convo cell appearance
        cell.userCellView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        //cell.userCellView.layer.cornerRadius  = 4.0
        
        cell.userCellView.layer.shadowColor   = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7).CGColor
        cell.userCellView.layer.shadowOffset  = CGSizeMake(0, 2)
        cell.userCellView.layer.shadowOpacity = 0.5
        cell.userCellView.layer.shadowRadius  = 4.0
        
        return cell
    }

    
    
    
    
    
    
    

    
    

}