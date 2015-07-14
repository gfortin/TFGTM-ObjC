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
    
    let urlGEP = "http://www.groupe-ecolepratique.com"
    
     //     self.window.title = "A propos"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
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