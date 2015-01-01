//
//  FriendCollectionViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 12/31/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class FriendCollectionViewController : UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    var convo : Conversation = Conversation(sender: PFUser.currentUser())
    var users : NSMutableArray = NSMutableArray()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        if(PFUser.currentUser() != nil){
            self.loadData(1)
        }
    }
    
    
    func loadData(order: Int){
        println("loaded")

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
                    println("yeappp")
                    self.users.addObject(pdf)
                }
                self.collectionView?.reloadData()
            }
        }
    }

    
    
    
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.users.count
    }
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.users.count
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UserCell
        let user : PFObject = self.users.objectAtIndex(indexPath.row) as PFObject
        cell.backgroundColor = UIColor.whiteColor()
        cell.user = user
        cell.userName.text = user.objectForKey("username") as NSString
        return cell
    }
    
}