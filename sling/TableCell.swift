//
//  TableCell.swift
//  sling
//
//  Created by Avi Chad-Friedman on 10/23/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
import UIKit
class TableCell: UITableViewCell{

    var convo : Conversation = Conversation(sender : PFUser.currentUser()!)
    let tableCell = UIView()
    
    @IBOutlet weak var timePosted: UILabel!
    @IBOutlet weak var lastMessage: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.addSubview(tableCell)
    }
    
    func displayUserPics(users : NSMutableArray){
        var i : Int = 0
        for user in users{
            let userObject = user as! PFObject
            if(userObject["picture"] != nil){
                let imageFile : PFFile = user["picture"] as! PFFile
                    imageFile.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        if !(error != nil) {
                            let image = UIImage(data:imageData!)
                            let width = 25 as UInt
                            let userAvatar  = JSQMessagesAvatarImageFactory.circularAvatarImage(image, withDiameter: width)
                            let imageView = UIImageView(image: userAvatar)
                            imageView.alpha = 0.8
                            let value : Int = i*25 + 30
                            let x = CGFloat(value)
                            imageView.frame = CGRectMake(x, 30, 25, 25)
                            self.tableCell.addSubview(imageView)
                            
                        }
                }
            }
                
            else{
                let image = UIImage(named: "anon.jpg")
                let width = 25 as UInt
                //var selectionImage : UserSelectionImageView = UserSelectionImageView(image: image)
                let userAvatar  = JSQMessagesAvatarImageFactory.circularAvatarImage(image, withDiameter: width)
                let imageView = UIImageView(image: userAvatar)
                imageView.alpha = 0.8
                let value : Int = i*25 + 30
                let x = CGFloat(value)
                imageView.frame = CGRectMake(x, 30, 25, 25)
                self.tableCell.addSubview(imageView)
            }
            i++
        }
    }
    
    
    
}