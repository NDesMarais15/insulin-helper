//
//  FoodViewController.swift
//  InsulinHelper
//
//  Created by Nick DesMarais on 10/27/17.
//  Copyright © 2017 Nick DesMarais. All rights reserved.
//

import Foundation
import UIKit

class FoodViewController: UIViewController {
    
    @IBOutlet weak var carbValue: UILabel!
    
    @IBOutlet weak var insulinValue: UILabel!
    
    @IBOutlet weak var calorieValue: UILabel!
    
    @IBOutlet weak var proteinValue: UILabel!
    
    var food: Food = Food(name: "", itemID: "", imageURL: "", isBranded: false)
    
    let nutrientsURL = "https://trackapi.nutritionix.com/v2/natural/nutrients"
    let brandedURL = "https://trackapi.nutritionix.com/v2/search/item"
    
    @IBOutlet weak var foodName: UILabel!
    
    @IBOutlet weak var foodImage: UIImageView!
    
    var sqlObj = SQL()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        setupView()
    }
    
    func setupView() {

        if (food.imageURL == "placeholder") {
            foodImage.image = UIImage(named: "image-not-found")
            // put placeholder image
            // not doing anything for now
        }
        else {
            // get the image
            let urlTry = URL(string: food.imageURL)
            if let url = urlTry {
                let data = try? Data(contentsOf: url)
                if let imageData = data {
                    foodImage.image = UIImage(data: imageData)
                }
            }
        }
        getNutritionInfo()
    }
    
    
    func getNutritionInfo () {
        let url: URL?
        let request: NSMutableURLRequest
        
        
        let ud = UserDefaults.standard
        var carbRatio = ud.object(forKey: "insulinToCarbs") as? Double
        
        if carbRatio == nil {
            carbRatio = 13.0
        }
        
        
        if food.isBranded {
            url = URL(string: "\(brandedURL)?nix_item_id=\(food.itemID)")
            if url == nil {
                return
            }
            request = NSMutableURLRequest(url: url!)
            request.httpMethod = "GET"
        }
        else {
            url = URL(string: nutrientsURL)
            if url == nil {
                return
            }
            request = NSMutableURLRequest(url: url!)
            request.httpMethod = "POST"
            let jsonRequest = ["query": food.name]
            request.httpBody = try? JSONSerialization.data(withJSONObject: jsonRequest, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        request.addValue("911e98a1", forHTTPHeaderField: "x-app-id")
        request.addValue("282364a0541e11cb254e28054713c4e7", forHTTPHeaderField: "x-app-key")
        let urlResponse: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
        let httpResponse = try? NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: urlResponse)
        if let responseJSON = try? JSON(data: httpResponse!) {
            carbValue.text = String(format: "%.1f", responseJSON["foods"][0]["nf_total_carbohydrate"].doubleValue)
            insulinValue.text = String(format: "%.1f", responseJSON["foods"][0]["nf_total_carbohydrate"].doubleValue/carbRatio!)
            calorieValue.text = String(responseJSON["foods"][0]["nf_calories"].intValue)
            proteinValue.text = String(responseJSON["foods"][0]["nf_protein"].intValue)
        }
    }
    
    @IBAction func addToFavorites(_ sender: UIButton) {
        var statement: OpaquePointer? = nil
        let isBrandedInt = food.isBranded ? "1" : "0"
 
        let db = sqlObj.openDatabase()
        
        let escapedName = food.name.replacingOccurrences(of: "'", with: "''")
        
        let insertStatement = "INSERT INTO Favorites (name, imageURL, isBranded, itemID) VALUES ('\(escapedName)', '\(food.imageURL)', '\(isBrandedInt)', '\(food.itemID)')"
        if sqlite3_prepare_v2(db, insertStatement, -1, &statement, nil) == SQLITE_OK {
            print("insert prepared")
        }
        if sqlite3_step(statement) == SQLITE_DONE {
            print("inserted")
        } else {
            print(sqlite3_step(statement))
            print(sqlite3_extended_errcode(db))
            print("not inserted")
        }
        sqlite3_finalize(statement)
    }
}
