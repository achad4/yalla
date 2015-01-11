//
//  ConvoViewController.swift
//  sling
//
//  Created by Nick De Heras on 1/6/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MessagesViewController : JSQMessagesViewController {
    
    var messageArray : NSMutableArray = NSMutableArray()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleGreenColor())
    var batchMessages = true
    var convo : PFObject = PFObject(className: "Conversation")
    var avatarImages = Dictionary<String, UIImage>()
    var isAnon : Bool?
    
    
    func loadData(order: Int){
        println("loading messages")
        //smessageArray.removeAllObjects()
        var findTimeLineData:PFQuery = PFQuery(className: "Message")
        if(order == 0){
            findTimeLineData.orderByAscending("createdAt")
        }

        var currentUser = PFUser.currentUser()
        
        findTimeLineData.whereKey("inConvo", equalTo: self.convo)
        findTimeLineData.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                for object in objects{
                    let pdf = object as PFObject
                    let text = pdf.objectForKey("text") as String
                    let sender = pdf["sender"].fetchIfNeeded() as PFUser
                    if(sender["picture"] != nil){
                        var imageFile : PFFile = sender["picture"] as PFFile
                        imageFile.getDataInBackgroundWithBlock {
                            (imageData: NSData!, error: NSError!) -> Void in
                            if !(error != nil) {
                                let image = UIImage(data:imageData)
                                let width = UInt(self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
                                let userAvatar  = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: width)
                                self.avatarImages[sender.username] = userAvatar
                            }
                        }
                    }
                    else{
                        var image = UIImage(named: "anon.jpg")
                        let width = UInt(self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
                        let userAvatar  = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: width)
                        self.avatarImages[sender.username] = userAvatar
                    }
                    self.messageArray.addObject(Message(text: text, sender: sender))
                }
            }
            self.collectionView?.reloadData()
        }


    }
    func sortByScore(){
        println("sortByScore called")
    }
    @IBAction func postQuestion(sender: AnyObject) {
    
    }

    func sendMessage(var text: String!, var sender: String!) {
        if(self.isAnon == true){
            self.isAnon = false
            self.convo["isAnon"] = false as NSNumber
        }
        var message:PFObject = PFObject(className: "Message")
        message["text"] = text
        var query1 = PFUser.query();
        var query2 = PFUser.query();
        var sentToRelation = message.relationForKey("sentTo")
        message["inConvo"] = self.convo as PFObject
        message["sender"] = PFUser.currentUser()
        self.convo.saveInBackgroundWithTarget(nil, selector: nil)
        message.saveInBackgroundWithTarget(nil, selector: nil)
        self.appendMessage(text, sender: PFUser.currentUser())
        self.loadData(0)
    }
    
    func appendMessage(text: String!, sender: PFUser!) {
        println("tempSendMessage called")
        let message = Message(text: text, sender: sender)
        messageArray.addObject(message)
    }
    
    override func viewDidLoad() {
        //println("viewDidLoad called")
        super.viewDidLoad()
        if(PFUser.currentUser() != nil) {
            self.loadData(0)
        }
        inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        
        sender = (sender != nil) ? sender : "Anonymous"
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //println("viewDidDisappear called")
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        //println("viewWillDisappear called")
        super.viewWillDisappear(animated)

    }
    

    func receivedMessagePressed(sender: UIBarButtonItem) {
        println("rMessagePressed called")
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!) {
        println("didPressSendButton called")
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        sendMessage(text, sender: sender)

        finishSendingMessage()
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messageArray.objectAtIndex(indexPath.item) as Message
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messageArray.objectAtIndex(indexPath.item) as Message
        let currentUser = PFUser.currentUser().objectForKey("username") as String
        if message.sender() == currentUser {
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        let message = messageArray.objectAtIndex(indexPath.item) as Message
        let currentUser = PFUser.currentUser().objectForKey("username") as String
        if message.sender() == currentUser {
            println(sender)
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes

        return cell
    }
    override func collectionView(collectionView: UICollectionView, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath) -> UIImageView? {
        let message = self.messageArray.objectAtIndex(indexPath.item) as Message
        let user = message.user() as PFUser!
        if(isAnon == false){
            let username = user.username
            return UIImageView(image: self.avatarImages[username])
        }
        var image = UIImage(named: "unknown.jpg")
        let width = UInt(self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        let userAvatar  = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: width)
        return UIImageView(image: userAvatar)
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messageArray.objectAtIndex(indexPath.item) as Message
        if message.sender() == sender {
            return nil;
        }
        
        if indexPath.item > 0 {
            let previousMessage = messageArray.objectAtIndex(indexPath.item-1) as Message;
            if previousMessage.sender() == message.sender() {
                return nil;
            }
        }
        if(isAnon != true){
            return NSAttributedString(string:message.sender())
        }
        return NSAttributedString(string: "Anonymous")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messageArray.objectAtIndex(indexPath.item) as Message
        let currentUser = PFUser.currentUser().objectForKey("username") as String
        if message.sender() == sender {
            return CGFloat(0.0);
        }
        
        if indexPath.item > 0 {
            let previousMessage = messageArray.objectAtIndex(indexPath.item-1) as Message;
            if previousMessage.sender() == message.sender() {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}

