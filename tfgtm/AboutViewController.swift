//
//  About.swift
//  tfgtm
//
//  Created by Ghislain Fortin on 06/07/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var aboutWebView: UIWebView!
    
    @IBOutlet weak var background: UIImageView!
    
    let urlGEP = "http://www.groupe-ecolepratique.com"
    
     //     self.window.title = "A propos"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = "À propos..."
        
        
        //self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
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
        
        
        
        var tryPage = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("webTFGTM", ofType:"html",inDirectory: "web")!)
        
        let reqPage = NSURLRequest(URL: tryPage!)
        var requestPage = NSURLRequest(URL: tryPage!)

        // === Swift 2 ===============================
        //let reqPage = NSURLRequest(URL: tryPage)
        //var requestPage = NSURLRequest(URL: tryPage)

        
        
        aboutWebView.loadRequest(requestPage)

        // let requestURL = NSURL(string:urlGEP)
        // let request = NSURLRequest(URL: requestURL!)
        // aboutWebView.loadRequest(request)
        
    }
    
    
}