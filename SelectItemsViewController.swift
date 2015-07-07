//
//  SelectItemsViewController.swift
//  tfgtm
//
//  Created by Ghislain Fortin on 07/07/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

import UIKit

class SelectItemsViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    

    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var categoryName: UILabel!

    let pickerData = [
        "  🍎  Fruits et légumes",
        "  🍗  Viandes et poissons",
        "  🍞  Pains et pâtisseries",
        "  🍦  Produits laitiers",
        "  🍚  Pâtes, riz et céréales",
        "  🌱  Épices et condiments",
        "  🍵  Boissons",
        "  🍭  Snacks et friandises",
        "  ❓  Autres"]
    
    //     self.window.title = "A propos"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        // let requestURL = NSURL(string:urlGEP)
        // let request = NSURLRequest(URL: requestURL!)
        // aboutWebView.loadRequest(request)
        
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryName.text = "Articles de" + pickerData[row] + " :"
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Arial", size: 20.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }
    
}
