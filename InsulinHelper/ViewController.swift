//
//  ViewController.swift
//  InsulinHelper
//
//  Created by Nick DesMarais on 10/27/17.
//  Copyright © 2017 Nick DesMarais. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet var foodTable: UITableView!
    
    let generalURL = "https://trackapi.nutritionix.com/v2/natural/nutrients"
    
    let baseURL = "https://trackapi.nutritionix.com/v2/search/instant?"
    
    let sectionLabels = ["Common", "Branded"]

    var commonTableData = [Food]()
    
    var brandedTableData = [Food]()


    override func viewDidLoad() {
        super.viewDidLoad()
        foodTable.dataSource = self
        foodTable.delegate = self
        searchBar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        commonTableData = []
        brandedTableData = []
        if let query = searchBar.text {
            sendSearchRequest(path: baseURL, query: query)
        }
        self.foodTable.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if indexPath.section == 0 {
            cell.textLabel?.text = commonTableData[indexPath.row].name
        }
        else {
            cell.textLabel?.text = brandedTableData[indexPath.row].name
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        if commonTableData.count != 0 {
            count+=1
        }
        if brandedTableData.count != 0 {
            count+=1
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "FoodSelected", sender: self)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var count = 0
        if commonTableData.count != 0 {
            count+=1
        }
        if brandedTableData.count != 0 {
            count+=1
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if section == 0 {
            if commonTableData.count < 3 {
                rowCount = commonTableData.count
            }
            else {
                rowCount = 3
            }
        }
            
        else if section == 1 {
            if brandedTableData.count < 10 {
                rowCount = brandedTableData.count
            }
            else {
                rowCount = 10
            }
        }
        return rowCount
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var commonHasData = false
        var brandedHasData = false
        if commonTableData.count != 0 {
            commonHasData = true
        }
        if brandedTableData.count != 0 {
            brandedHasData = true
        }
        if section == 0 {
            if !commonHasData {
                return sectionLabels[section+1]
            }
            else {
                return sectionLabels[section]
            }
        }
        else {
            return sectionLabels[section]
        }
    }

    func sendSearchRequest(path: String, query: String) {
        if let url = URL(string: path + "query=" + query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!) {
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("911e98a1", forHTTPHeaderField: "x-app-id")
            request.addValue("282364a0541e11cb254e28054713c4e7", forHTTPHeaderField: "x-app-key")
            let urlResponse: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
            let httpResponse = try? NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: urlResponse)
            if let responseJSON = try? JSON(data: httpResponse!) {
                let commonFoods = responseJSON["common"].arrayValue
                for foodJSON in commonFoods {
                    var isInTable = false
                    for foodItem in commonTableData {
                        if foodItem.itemID == foodJSON["tag_id"].stringValue {
                            isInTable = true
                        }
                    }
                    if isInTable {
                        continue
                    }
                    if foodJSON["photo"]["thumb"] != JSON.null{
                        let food = Food(name: foodJSON["food_name"].stringValue, itemID: foodJSON["tag_id"].stringValue, imageURL: foodJSON["photo"]["thumb"].stringValue, isBranded: false)
                        commonTableData.append(food)
                    }
                    else {
                        let food = Food(name: foodJSON["food_name"].stringValue, itemID: foodJSON["tag_id"].stringValue, imageURL: "placeholder", isBranded: false)
                        commonTableData.append(food)
                    }
                }
                let brandedFoods = responseJSON["branded"].arrayValue
                for foodJSON in brandedFoods {
                    var isInTable = false
                    for foodItem in brandedTableData {
                        if foodItem.itemID == foodJSON["tag_id"].stringValue {
                            isInTable = true
                            break
                        }
                    }
                    if isInTable {
                        continue
                    }
                    if foodJSON["photo"]["thumb"] != JSON.null{
                        let food = Food(name: foodJSON["brand_name_item_name"].stringValue, itemID: foodJSON["nix_item_id"].stringValue, imageURL: foodJSON["photo"]["thumb"].stringValue, isBranded: true)
                        brandedTableData.append(food)
                    }
                    else {
                        let food = Food(name: foodJSON["brand_name_item_name"].stringValue, itemID: foodJSON["nix_item_id"].stringValue, imageURL: "placeholder", isBranded: true)
                        brandedTableData.append(food)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FoodSelected" {
            let nextController = segue.destination as? FoodViewController
            let indexPath = foodTable.indexPathForSelectedRow
            if indexPath?.section == 0 {
                nextController?.food = commonTableData[(indexPath?.row)!]
            }
            else {
                nextController?.food = brandedTableData[(indexPath?.row)!]
            }
        }
    }
    
}


