//
//  ManualVC.swift
//  tfgtm
//
//  Created by Ghislain Fortin on 31/08/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

import UIKit


class ManualVC: UIViewController {

    @IBOutlet var manualWebView: UIWebView!
    @IBOutlet var background: UIImageView!

    override func viewDidLoad() {
            super.viewDidLoad()

            self.title = "Manuel"
    
        // Set vertical effect
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
            type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -30
        verticalMotionEffect.maximumRelativeValue = 30
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
            type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -30
        horizontalMotionEffect.maximumRelativeValue = 30
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        background.addMotionEffect(group)
        
        
    }
    
    
}