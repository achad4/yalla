//
//  FriendTableView.swift
//  sling
//
//  Created by Avi Chad-Friedman on 2/27/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class FriendTableViewController : UITableViewController, UISearchBarDelegate{
    //let collation = UILocalizedIndexedCollation.currentCollation() as UILocalizedIndexedCollation
    var sectionTitles = NSMutableArray()
    var messageText : String = ""
    var users : NSMutableArray = NSMutableArray()
    var filteredUsers : NSMutableArray = NSMutableArray()
    var isSearching : Bool!
    var sections : NSMutableArray = NSMutableArray()
    //var segment : Int = 0 //threads = 1 people = 2
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        isSearching = false
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(PFUser.currentUser() != nil){
            self.loadData()
        }
    }
    
    
    //load users and organize them into alphabetized sections
    func loadData(){
        users.removeAllObjects()
        
        let friendsRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        friendsRequest.startWithCompletionHandler({(connection, result, error:NSError!) -> Void in
            if(error == nil){
                
                let resultdict = result as! NSDictionary
                let friends : NSArray = resultdict.objectForKey("data") as! NSArray
                let friendIDs = NSMutableArray()
                print(friends.count)
                for friend in friends as! [NSDictionary]{
                    friendIDs.addObject(friend["id"]!)
                }
                
                let findTimeLineData:PFQuery = PFQuery(className: "_User")
                findTimeLineData.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
                findTimeLineData.whereKey("fbID", containedIn: friendIDs as [AnyObject])
                findTimeLineData.findObjectsInBackgroundWithBlock{
                    (objects:[AnyObject]!, error:NSError!)->Void in
                    if !(error != nil){
                        for object in objects{
                            let pdf = object as! PFObject
                            self.users.addObject(pdf)
                        }
                        //self.sections.addObject(self.users)
                    }
                    
                    self.users.sortUsingComparator({ (user1, user2) -> NSComparisonResult in
                        let pdf1 = user1 as! PFUser
                        let pdf2 = user2 as! PFUser
                        let name1 = pdf1["realName"] as! NSString
                        let name2 = pdf2["realName"] as! NSString
                        return name1.compare(name2 as String)
                    })
                    var prefix = "a" as NSString
                    var currentSection = NSMutableArray()
                    for user in self.users as [AnyObject] {
                        let pdf = user as! PFUser
                        let name = pdf["realName"] as! NSString
                        let firstLetter = name.substringToIndex(1)
                        if(firstLetter == prefix){
                            currentSection.addObject(user)
                        }
                        else{
                            self.sections.addObject(currentSection)
                            self.sectionTitles.addObject(firstLetter)
                            currentSection = NSMutableArray()
                        }
                        prefix = firstLetter
                    }
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! UserTableCell
            let parentViewController = self.parentViewController as! FriendParentViewController
            if(parentViewController.groupSegmentedControl.selectedSegmentIndex == 1){
                let convo = parentViewController.groupConvo
                if(cell.userImage.alpha == 0.5){
                    cell.userImage.alpha = 1
                    convo.addRecipient(cell.user, isOwner: false)
                }
                else{
                    cell.userImage.alpha = 0.5
                    convo.removeRecipient(cell.user)
                }
            }
            else{
                if(cell.userImage.alpha == 0.5){
                    cell.userImage.alpha = 1
                    let convo = Conversation(sender: PFUser.currentUser()!)
                    convo.addRecipient(cell.user, isOwner: false)
                    parentViewController.convos.addObject(convo)
                }
                else{
                    cell.userImage.alpha = 0.5
                }
                
            }
            
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // Return the number of sections.
        if(isSearching == true){
            return self.filteredUsers.count
        }
        return self.users.count
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.sectionTitles as AnyObject as! [String]
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.sectionTitles.indexOfObject(title)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return self.sectionTitles[section] as! String
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserTableCell
        var users : NSMutableArray = self.sections.objectAtIndex(indexPath.section) as! NSMutableArray
        var user : PFObject = self.users.objectAtIndex(indexPath.row) as! PFObject
        if(isSearching == true){
            user = self.filteredUsers.objectAtIndex(indexPath.row) as! PFObject
        }
        cell.user = user
        
        for next in cell.userCellView.subviews as [UIView]{
            next.removeFromSuperview()
        }
        
        var X : CGFloat = cell.frame.origin.x
        var Y : CGFloat = 0
        var centerX = cell.frame.origin
        //cell.userCellView.frame = CGRectMake(X, Y, self.view.bounds.size.width - 10, 70)
        //cell.userCellView.center = CGPointMake(X + cell.frame.size.width/2, Y + cell.frame.height/2)
        cell.userName = UILabel(frame: CGRectMake(0, 0, 200, 70))
        cell.userName.center = CGPointMake(175, 32.5)
        cell.userName.text = user.objectForKey("realName") as? String
        
        if(user["picture"] != nil){
            let imageFile : PFFile = user["picture"] as! PFFile
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
            let image = UIImage(named: "anon.jpg")
            let width = 50 as UInt
            let circleImage = JSQMessagesAvatarImageFactory.circularAvatarHighlightedImage(image, withDiameter: width)
            cell.userImage = UIImageView(image: circleImage)
            cell.userCellView.addSubview(cell.userImage)
        }
        
        var parentViewController = self.parentViewController as! FriendParentViewController
        
        //cell.convo = parentViewController.convo
        cell.messageText = self.messageText
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