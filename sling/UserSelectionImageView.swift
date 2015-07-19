//
//  UserSelectionImageView.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/21/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
//
//  ThreadBubble.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/8/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class UserSelectionImageView : UIImageView {    
//    init() {
//        super.init(image: self.image)
//        self.userInteractionEnabled = true
//        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapped:"))
//    }
    
    func tapped(nizer: UITapGestureRecognizer){
        print("user image tapped")
        self.highlighted = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(image: UIImage?) {
        print("image init")
        super.init(image: image)
        self.userInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapped:"))
    }
}