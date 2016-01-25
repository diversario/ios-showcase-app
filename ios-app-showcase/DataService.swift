//
//  DataService.swift
//  ios-app-showcase
//
//  Created by Ilya Shaisultanov on 1/24/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import Foundation

import Firebase

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "https://ios-showcase-app.firebaseio.com")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
}