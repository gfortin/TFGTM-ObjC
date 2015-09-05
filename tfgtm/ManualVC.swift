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


    override func viewDidLoad() {
            super.viewDidLoad()

            self.title = "Manuel"
    
        /*
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
        */
        
        //var tryPage = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("DocUtil", ofType:"html",inDirectory: "web")!)

        //var tryPage = NSURL(string: "https://sway.com/NcTGBiPAElN26VHe")

        
        var tryPage = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("1710-Documentation utilisateur iPhone", ofType:"pdf",inDirectory: "web")!)
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad)
        {
            tryPage = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("1710-Documentation utilisateur", ofType:"pdf",inDirectory: "web")!)
        }
        
        let reqPage = NSURLRequest(URL: tryPage!)
        var requestPage = NSURLRequest(URL: tryPage!)
        
        // === Swift 2 ===============================
        //let reqPage = NSURLRequest(URL: tryPage)
        //var requestPage = NSURLRequest(URL: tryPage)
        
        
        
        manualWebView.loadRequest(requestPage)
        
        
        
    }
    
    
}