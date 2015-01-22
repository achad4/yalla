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
    
    @IBAction func addSection(sender: AnyObject) {
        
    }
    /*
    @IBAction func send(sender: AnyObject) {
        //var messageText:String        = postText.text
        var message:PFObject           = PFObject(className: "Message")
        message["text"] = messageText;
        var query1 = PFUser.query();
        var query2 = PFUser.query();
        var sentToRelation = message.relationForKey("sentTo")
        //var senderRelation = message.relationForKey("sender")
        //senderRelation.addObject(PFUser.currentUser())
        message["inConvo"] = convo.convo as PFObject
        message["sender"] = PFUser.currentUser()
        self.convo.save()
        message.saveInBackgroundWithTarget(nil, selector: nil)
    
    }
    */
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.collectionView?.layer.borderWidth = 3
        isSearching = false
        if(PFUser.currentUser() != nil){
            self.loadData(1)
        }
    }
    
    
    func loadData(order: Int){
        //for var i = 0; i<3; i++ {
            users.removeAllObjects()
            var findTimeLineData:PFQuery = PFQuery(className: "_User")
            if(order == 0){
                findTimeLineData.orderByDescending("createdAt")
            }
            findTimeLineData.findObjectsInBackgroundWithBlock{
                (objects:[AnyObject]!, error:NSError!)->Void in
                if !(error != nil){
                    for object in objects{
                        let pdf = object as PFObject
                        self.users.addObject(pdf)
                    }
                    self.sections.addObject(self.users)
                    println(self.sections.count)
                    
                }
                println(self.sections.count)
                self.collectionView?.reloadData()
            }
        //}
        
        
        
    }
    
    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath){
            var cell = collectionView.cellForItemAtIndexPath(indexPath) as UserCell
            var parentViewController = self.parentViewController as FriendParentViewController
            parentViewController.convo.addRecipient(cell.user)
            parentViewController.convo.save()
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UserCell
        var users : NSMutableArray = self.sections.objectAtIndex(indexPath.section) as NSMutableArray
        var user : PFObject = self.users.objectAtIndex(indexPath.row) as PFObject
        if(isSearching == true){
            user = self.filteredUsers.objectAtIndex(indexPath.row) as PFObject
        }
        cell.layer.cornerRadius = 50
        println(cell.layer.cornerRadius)
        cell.backgroundColor = UIColor.whiteColor()
        cell.user = user
        cell.userName.text = user.objectForKey("username") as NSString
        if(user["picture"] != nil){
            var imageFile : PFFile = user["picture"] as PFFile
            imageFile.getDataInBackgroundWithBlock {
                (imageData: NSData!, error: NSError!) -> Void in
                if !(error != nil) {
                    let image = UIImage(data:imageData)
                    let width = 50 as UInt
                    let userAvatar  = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: width)
                    //self.avatarImages[sender.username] = userAvatar
                    //cell.userPic.image = userAvatar
                    cell.userButton.setBackgroundImage(userAvatar, forState: UIControlState.Normal)
                }
            }
        }
        else{
            var image = UIImage(named: "anon.jpg")
            //let width = UInt(self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
            let width = 50 as UInt
            
            //self.avatarImages[sender.username] = userAvatar
            //cell.userPic.image = UserSelectionImageView(userAvatar)
            var selectionImage : UserSelectionImageView = UserSelectionImageView(image: image)
            let userAvatar  = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: width)
            //cell.userPic = selectionImage
            //cell.userPic.image = userAvatar
            cell.userButton.setBackgroundImage(userAvatar, forState: UIControlState.Normal)
           
        }
        cell.userButton.alpha = 0.5
        var parentViewController = self.parentViewController as FriendParentViewController
        cell.convo = parentViewController.convo
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let reusableView:UICollectionReusableView = self.collectionView?.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as UICollectionReusableView
        println(indexPath.section)
        return reusableView
    }

    
    
    
}