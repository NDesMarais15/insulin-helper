//
//  SQL.swift
//  InsulinHelper
//
//  Created by Nick DesMarais on 10/28/17.
//  Copyright © 2017 Nick DesMarais. All rights reserved.
//

import Foundation

class SQL {
    
    
    func openDatabase() -> OpaquePointer? {
        
        let fm = FileManager.default
        var urlTry : URL?
        
        do {
            let baseUrl = try
                fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            urlTry = baseUrl.appendingPathComponent("swift.sqlite")
            
        } catch {
            print(error)
        }
        var db: OpaquePointer? = nil
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        let status = sqlite3_open_v2(urlTry?.absoluteString.cString(using: String.Encoding.utf8)!,&db, flags, nil)
            if status == SQLITE_OK {
                let errorMessage: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>? = nil
                let sql = "CREATE TABLE if not exists Favorites (ID INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, imageURL TEXT, isBranded TEXT, itemID TEXT)"
                if sqlite3_exec(db, sql, nil, nil, errorMessage) == SQLITE_OK {
                }
                else {
                    print(errorMessage!)
                }
            }
            
         else {
            print("Unable to open database.")
        }
        
        return db
    }

}
