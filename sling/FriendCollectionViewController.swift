//
//  FriendCollectionViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 12/31/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class FriendCollectionViewController : UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate{
    var convo : Conversation = Conversation(sender: PFUser.currentUser())
    var messageText : String = "";
    var users : NSMutableArray = NSMutableArray()
    var filteredUsers : NSMutableArray = NSMutableArray()
    var isSearching : Bool!
    var sections : NSMutableArray = NSMutableArray()
    
    @IBAction func addSection(sender: AnyObject) {
        
    }
    
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
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        isSearching = false
        if(PFUser.currentUser() != nil){
            self.loadData(1)
        }
    }
    
    
    func loadData(order: Int){
        for var i = 0; i<3; i++ {
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
        }
        
        
        
    }
    
    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath){
            var cell = collectionView.cellForItemAtIndexPath(indexPath) as UserCell
            self.convo.addRecipient(cell.user)
            self.convo.save()
            cell.backgroundColor = UIColor.blueColor()
            cell.userName.backgroundColor = UIColor.whiteColor()
            
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
        return 3
    }
    /*
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text.isEmpty{
            isSearching = false
            self.collectionView?.reloadData()
        } else {
            isSearching = true
            filteredUsers.removeAllObjects()
            for var index = 0; index < users.count; index++
            {
                var currentUser = users.objectAtIndex(index) as PFObject
                var currentString = currentUser.objectForKey("username") as String
                if currentString.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
                    filteredUsers.addObject(currentUser)
                }
            }
            self.collectionView?.reloadData()
        }
    }
*/
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UserCell
        var users : NSMutableArray = self.sections.objectAtIndex(indexPath.section) as NSMutableArray
        //println("section loaded")
        //var user : PFObject = self.users.objectAtIndex(indexPath.row) as PFObject
        var user : PFObject = self.users.objectAtIndex(indexPath.row) as PFObject
        if(isSearching == true){
            user = self.filteredUsers.objectAtIndex(indexPath.row) as PFObject
        }
        cell.backgroundColor = UIColor.whiteColor()
        cell.user = user
        cell.userName.text = user.objectForKey("username") as NSString
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let reusableView:UICollectionReusableView = self.collectionView?.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as UICollectionReusableView
        println(indexPath.section)
        return reusableView
    }

    
    
    
}