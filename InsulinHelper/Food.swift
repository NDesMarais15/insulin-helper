//
//  Food.swift
//  InsulinHelper
//
//  Created by Nick DesMarais on 10/28/17.
//  Copyright © 2017 Nick DesMarais. All rights reserved.
//

import Foundation

struct FoodDetail {
    let name : String
    let numCarbs : Double
    let numCalories : Double
    let numProteinGrams : Double
    let numSodiumGrams : Double
    let numFatGrams : Double
    let imageURL: String
}

struct Food {
    let name: String
    let itemID: String
    let imageURL: String
    let isBranded: Bool
}
