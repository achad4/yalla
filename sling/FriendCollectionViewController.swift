//
//  FriendCollectionViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 12/31/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class FriendCollectionViewController : UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate{
    //var convo : Conversation = Conversation(sender: PFUser.currentUser())
    var messageText : String = ""
    var users : NSMutableArray = NSMutableArray()
    var filteredUsers : NSMutableArray = NSMutableArray()
    var isSearching : Bool!
    var sections : NSMutableArray = NSMutableArray()
    //var segment : Int = 0 //threads = 1 people = 2
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //self.collectionView?.layer.borderWidth = 3
        self.collectionView?.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        var widthConstraint = NSLayoutConstraint(item: self.collectionView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.parentViewController, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 95)
        self.collectionView?.addConstraint(widthConstraint)
        isSearching = false
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(PFUser.currentUser() != nil){
            self.loadData()
        }
    }
    
    func loadData(){
        users.removeAllObjects()
        var friendsRequest : FBRequest = FBRequest.requestForMyFriends()
        friendsRequest.startWithCompletionHandler{(connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            if(error == nil){
                let resultdict = result as NSDictionary
                let friends : NSArray = resultdict.objectForKey("data") as NSArray
                var friendIDs = NSMutableArray()
                for friend in friends as [NSDictionary]{
                    friendIDs.addObject(friend["id"]!)
                }
                
                var findTimeLineData:PFQuery = PFQuery(className: "_User")
                findTimeLineData.whereKey("objectId", notEqualTo: PFUser.currentUser().objectId)
                //findTimeLineData.whereKey("fbID", containedIn: friendIDs)
                findTimeLineData.findObjectsInBackgroundWithBlock{
                    (objects:[AnyObject]!, error:NSError!)->Void in
                    if !(error != nil){
                        for object in objects{
                            let pdf = object as PFObject
                            self.users.addObject(pdf)
                        }
                        self.sections.addObject(self.users)
                    }
                    self.users.sortUsingComparator({ (user1, user2) -> NSComparisonResult in
                        let pdf1 = user1 as PFUser
                        let pdf2 = user2 as PFUser
                        let name1 = pdf1["realName"] as NSString
                        let name2 = pdf2["realName"] as NSString
                        return name1.compare(name2)
                    })
                    self.collectionView?.reloadData()
                }

                
            }
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath){
            var cell = collectionView.cellForItemAtIndexPath(indexPath) as UserCell
            var parentViewController = self.parentViewController as FriendParentViewController
            if(parentViewController.groupSegmentedControl.selectedSegmentIndex == 1){
                var convo = parentViewController.convos[0] as Conversation
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
                    var convo = Conversation(sender: PFUser.currentUser())
                    convo.addRecipient(cell.user, isOwner: false)
                    parentViewController.convos.addObject(convo)
                }
                else{
                    cell.userImage.alpha = 0.5
                }

            }
            
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if(isSearching == true){
            return self.filteredUsers.count
        }
        return self.users.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if(isSearching == true){
            return 1
        }
        return 1
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserCell", forIndexPath: indexPath) as UserCell
        var users : NSMutableArray = self.sections.objectAtIndex(indexPath.section) as NSMutableArray
        var user : PFObject = self.users.objectAtIndex(indexPath.row) as PFObject
        if(isSearching == true){
            user = self.filteredUsers.objectAtIndex(indexPath.row) as PFObject
        }
        cell.user = user
        for next in cell.userCellView.subviews as [UIView]{
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
            var imageFile : PFFile = user["picture"] as PFFile
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
        
        var parentViewController = self.parentViewController as FriendParentViewController
        
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        
        let width:CGFloat = self.view.bounds.size.width
        let height:CGFloat = 75
        
        return CGSizeMake(width, height)
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let reusableView:UICollectionReusableView = self.collectionView?.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as UICollectionReusableView
        return reusableView
    }

    
    
    
}