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
    
    var messages = [Message]()
    // var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleGreenColor())
    var batchMessages = true
    var convo : PFObject = PFObject(className: "Conversation")
    var timeLineData : NSMutableArray = NSMutableArray()
    
    func loadData(order: Int){
        println("loadData called")
        timeLineData.removeAllObjects()
        var findTimeLineData:PFQuery = PFQuery(className: "Message")
        if(order == 0){
            findTimeLineData.orderByDescending("createdAt")
        }
        // Filtering questions to only see those posted by current user
        var currentUser = PFUser.currentUser()
        /*
        findTimeLineData.whereKey("inConvo", equalTo: self.convo)
        findTimeLineData.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                for object in objects{
                    let pdf = object as PFObject
                    self.timeLineData.addObject(pdf)
                }
            }
        }
*/

    }
    func sortByScore(){
        println("sortByScore called")
    }
    @IBAction func postQuestion(sender: AnyObject) {
    
    }

    func sendMessage(var text: String!, var sender: String!) {
        println("sendMessage called")
        //let message = Message(text: text, sender: sender)
        var message:PFObject = PFObject(className: "Message")
        message["text"] = text
        var query1 = PFUser.query();
        var query2 = PFUser.query();
        var sentToRelation = message.relationForKey("sentTo")
        var senderRelation = message.relationForKey("sender")
        senderRelation.addObject(PFUser.currentUser())
        message["inConvo"] = self.convo as PFObject
        convo.save()
        message.save()
    }
    
    func tempSendMessage(text: String!, sender: String!) {
        println("tempSendMessage called")
        let message = Message(text: text, sender: sender)
        messages.append(message)
    }
    
    override func viewDidLoad() {
        println("viewDidLoad called")
        super.viewDidLoad()
        if(PFUser.currentUser() != nil) {
            self.loadData(1)
        }
        inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        
        sender = (sender != nil) ? sender : "Anonymous"
        
    }
    
    override func viewDidAppear(animated: Bool) {
        println("viewDidDisappear called")
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        println("viewWillDisappear called")
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
        println("collectionView 1")
        //let message = Message(text: text, sender: sender)
        // self.append(message)
        return messages[indexPath.item]
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        println("collectionView 2")
        let message = messages[indexPath.item]
        
        if message.sender() == sender {
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("collectionView 3")
        return messages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        println("collectionView 4")
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.sender() == sender {
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes

        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        println("collectionView 5")
        let message = messages[indexPath.item];
                if message.sender() == sender {
            return nil;
        }
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.sender())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        println("collectionView 6")
        let message = messages[indexPath.item]
        
        if message.sender() == sender {
            return CGFloat(0.0);
        }
        
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}

