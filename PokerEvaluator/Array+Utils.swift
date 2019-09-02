//
//  Array+Utils.swift
//  PokerEvaluator
//
//  Created by Joao Paulo Aquino on 01/09/19.
//  Copyright © 2019 Joao Paulo Aquino. All rights reserved.
//

import Foundation

   extension Array where Element: Equatable {

    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }

}
