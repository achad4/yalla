//
//  ConvoViewController.swift
//  sling
//
//  Created by Nick De Heras on 1/6/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
import UIKit


class MessagesViewController : JSQMessagesViewController, JSQMessagesCollectionViewDelegateFlowLayout  {
    
    var messageArray : NSMutableArray = NSMutableArray()
    var outgoingBubbleImageView:JSQMessagesBubbleImage!
    var incomingBubbleImageView:JSQMessagesBubbleImage!
    var batchMessages = true
    var convo : Conversation!
    var avatarImages = Dictionary<String, UIImage>()
    var isAnon : Bool?
    var newMessgae : Bool?
    var addedParticipants : Bool?
    var messageText : String!
    var segue : FriendsSegue!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "FriendsView@Friends"){
            var convo : Conversation = Conversation(sender: PFUser.currentUser())
            self.convo = convo
            self.convo.save()
        }
    }
    
    func senderDisplayName() -> NSString {
        return PFUser.currentUser().username
    }
    
    func senderId() -> String! {
        return PFUser.currentUser().objectId
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(order: Int){
        var findTimeLineData:PFQuery = PFQuery(className: "Message")
        if(order == 0){
            findTimeLineData.orderByAscending("createdAt")
        }

        var currentUser = PFUser.currentUser()
        
        findTimeLineData.whereKey("inConvo", equalTo: self.convo.convo)
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
                                self.avatarImages[sender.objectId] = image
                            }
                        }
                    }
                    else{
                        var image = UIImage(named: "anon.jpg")
                        self.avatarImages[sender.objectId] = image
                    }
                    self.messageArray.addObject(JSQMessage(senderId: sender.objectId, displayName: sender.username, text: text))
                }
            }
            self.finishReceivingMessage()
        }


    }
    
    
    
    func sendMessage(var text: String!) {
        //user is starting new conversation
        if(self.newMessgae != false){
            self.messageText = text
            var convo : Conversation = Conversation(sender: PFUser.currentUser())
            self.convo = convo
            self.convo.save()
            self.segue.perform()
        }
        //conversation exists-- let user send new message
        else{
            
            if(self.convo.participants.count == 1){
                    var alert : UIAlertController = UIAlertController(title: "Send failed", message: "You must send this message to at least one user", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Add users", style: UIAlertActionStyle.Default, handler: {
                        alertAction in
                        self.messageText = text
                        self.performSegueWithIdentifier("FriendsView@Friends", sender: self)
                        }))
                    self.presentViewController(alert, animated: true, completion: nil)
            }
            
            else{
                if((self.isAnon != true) && ((PFUser.currentUser().objectId != self.convo.convo["owner"].fetchIfNeeded().objectId))){
                    self.isAnon = false
                    self.convo.convo["isAnon"] = false as NSNumber
                }
                var message:PFObject = PFObject(className: "Message")
                message["text"] = text
                var sentToRelation = message.relationForKey("sentTo")
                message["inConvo"] = self.convo.convo as PFObject
                message["sender"] = PFUser.currentUser()
                self.convo.save()
                message.saveInBackgroundWithTarget(nil, selector: nil)
                self.appendMessage(text, sender: PFUser.currentUser())
                let testmessage: NSString = text as NSString
                var data = [ "title": "Some Title",
                    "alert": testmessage]
                var relation = self.convo.convo.relationForKey("participant")
                var innerQuery = relation.query()
                var query: PFQuery = PFInstallation.query()
                query.whereKey("user", matchesQuery: innerQuery)
                var push: PFPush = PFPush()
                push.setQuery(query)
                push.setData(data)
                push.sendPushInBackground()
            }
            
        }
    }
    
    func appendMessage(text: String!, sender: PFUser!) {
        let message = JSQMessage(senderId: sender.objectId, displayName: sender.username, text: text)
        messageArray.addObject(message)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        //find a way to only count once
        var count : Int = PFQuery(className: "Question").countObjects()
        var query : PFQuery = PFQuery(className: "Question")
        query.limit = 1
        //query.skip = Int(arc4random(count))
        query.skip  = Int(arc4random_uniform(UInt32(count)))
        query.getFirstObjectInBackgroundWithBlock {
            (object:PFObject!, error:NSError!) -> Void in
            if(object != nil){
                if (object["text"] != nil) {
                    self.inputToolbar.contentView.textView.text = object["text"] as String
                    self.inputToolbar.toggleSendButtonEnabled()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputToolbar.contentView.textView.placeHolder = "<-- Lost for words?"
        self.inputToolbar.contentView.leftBarButtonItem = JSQMessagesToolbarButtonFactory.defaultAccessoryButtonItem()
        self.incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        self.outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        self.senderId = PFUser.currentUser().objectId
        self.senderDisplayName = PFUser.currentUser().username
        self.segue = FriendsSegue(identifier: "FriendsView@Friends", source: self, destination: self)
        automaticallyScrollsToMostRecentMessage = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(PFUser.currentUser() != nil && self.newMessgae != true) {
            self.loadData(0)
        }
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    func receivedMessagePressed(sender: UIBarButtonItem) {
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        //JSQSystemSoundPlayer.jsq_playMessageSentSound()
        sendMessage(text)
        finishSendingMessage()
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messageArray.objectAtIndex(indexPath.item) as JSQMessage
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let msg = messageArray.objectAtIndex(indexPath.item) as JSQMessage
        if(msg.senderId == PFUser.currentUser().objectId){
            return self.outgoingBubbleImageView
        }else{
            return self.incomingBubbleImageView
        }
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        let message = messageArray.objectAtIndex(indexPath.item) as JSQMessage
        let currentUser = PFUser.currentUser()
        if message.senderId == currentUser.objectId {
            cell.textView.textColor = UIColor.whiteColor()
        } else {
            cell.textView.textColor = UIColor.blackColor()
        }
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource! {
        
        let message = self.messageArray.objectAtIndex(indexPath.item) as JSQMessage
        let user = message.senderId
        let width = UInt(self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        if(isAnon == false){
            if(self.avatarImages[user] != nil){
                return JSQMessagesAvatarImageFactory.avatarImageWithImage(self.avatarImages[user], diameter: width)
            }
        }
        var image = UIImage(named: "unknown.jpg")
        return JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: width)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messageArray.objectAtIndex(indexPath.item) as JSQMessage
        if message.senderId == PFUser.currentUser().objectId {
            return nil;
        }
        
        if indexPath.item > 0 {
            let previousMessage = messageArray.objectAtIndex(indexPath.item-1) as JSQMessage;
            if previousMessage.senderId == message.senderId {
                return nil;
            }
        }
        if(isAnon == false){
            return NSAttributedString(string:message.senderDisplayName)
        }
        return NSAttributedString(string: "Anonymous")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }

    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messageArray.objectAtIndex(indexPath.item) as JSQMessage
        let currentUser = PFUser.currentUser().objectForKey("username") as String
        if message.senderId == PFUser.currentUser().objectId {
            return CGFloat(0.0);
        }
        if indexPath.item > 0 {
            let previousMessage = messageArray.objectAtIndex(indexPath.item-1) as JSQMessage;
            if previousMessage.senderId == message.senderId {
                return CGFloat(0.0);
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}

