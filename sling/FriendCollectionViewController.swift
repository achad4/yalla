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
    var users : NSMutableArray = NSMutableArray()
    var filteredUsers : NSMutableArray = NSMutableArray()
    var isSearching : Bool!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        isSearching = false
        if(PFUser.currentUser() != nil){
            self.loadData(1)
        }
    }
    
    
    func loadData(order: Int){
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
        return 1
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        println("here")
        if searchBar.text.isEmpty{
            isSearching = false
            self.collectionView?.reloadData()
        } else {
            println(" search text %@ ",searchBar.text as NSString)
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

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UserCell
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
        println("Footer subivews: \(reusableView.subviews.count)") // 0
        return reusableView
    }
    
    
    
    
}