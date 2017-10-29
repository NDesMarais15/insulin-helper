//
//  FavoritesViewController.swift
//  InsulinHelper
//
//  Created by Nick DesMarais on 10/28/17.
//  Copyright © 2017 Nick DesMarais. All rights reserved.
//

import Foundation
import UIKit

class FavoritesController: UITableViewController {
    
    var favorites = [Food]()
    
    var sqlObj = SQL()
    
    @IBOutlet var favoritesTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesTable.dataSource = self
        favoritesTable.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getFavorites()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = favorites[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let db = sqlObj.openDatabase()
            var statement: OpaquePointer? = nil
            let sql = "DELETE FROM Favorites WHERE name = '\(favorites[indexPath.row].name)'"
            print(sql)
            if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
                sqlite3_step(statement)
                favorites.remove(at: indexPath.row)
                self.favoritesTable.reloadData()
            }
            else {
                print("deletion failed")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FavoriteSelected" {
            let nextController = segue.destination as? FoodViewController
            let indexPath = favoritesTable.indexPathForSelectedRow
            nextController?.food = favorites[(indexPath?.row)!]
        }
    }
    
    func getFavorites() {
        let db = sqlObj.openDatabase()
        var statement: OpaquePointer? = nil
        let sql = "SELECT * FROM Favorites"
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let rowName = sqlite3_column_text(statement, 1)
                let rowImage = sqlite3_column_text(statement, 2)
                let rowIsBranded = sqlite3_column_int(statement, 3)
                let rowItemID = sqlite3_column_text(statement, 4)
                let rowInt = Int(rowIsBranded)
                let rowBool = rowInt == 1 ? true : false
                
                let foodObj = Food(name: String(cString: rowName!), itemID: String(cString: rowItemID!), imageURL: String(cString: rowImage!), isBranded: rowBool)
                
                
                
                var itemExists: Bool = false
                for favorite in favorites {
                    if foodObj.name == favorite.name {
                        itemExists = true
                        break
                    }
                }
                
                if itemExists {
                    itemExists = false
                    continue
                }
                
                favorites.append(foodObj)
            }
        }
        self.favoritesTable.reloadData()
    }
    
}
