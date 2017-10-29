//
//  SettingsViewController.swift
//  InsulinHelper
//
//  Created by Nick DesMarais on 10/28/17.
//  Copyright © 2017 Nick DesMarais. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var carbToInsulin: UITextField!
    
    @IBAction func buttonClicked(_ sender: Any) {
        let ud = UserDefaults.standard
        
        if let text = carbToInsulin.text {
            var doubleVal = Double(text)
            print(doubleVal!)
            let newDub = doubleVal!
            if doubleVal != nil {
                if doubleVal! <= 0.0 {
                    print("here")
                    let alert = UIAlertController(title: "Error", message: "Sorry, please enter a number greater than 0.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    ud.set(doubleVal, forKey: "insulinToCarbs")
                }
            }
            else {
                let alert = UIAlertController(title: "Error", message:
                    "Sorry, please enter a number.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ud = UserDefaults.standard

        if let object = ud.object(forKey: "insulinToCarbs") {
            carbToInsulin.text = String(describing: object)
        }
        else {
            carbToInsulin.text = "13"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
