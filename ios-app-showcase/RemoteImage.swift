//
//  RemoteImage.swift
//  ios-app-showcase
//
//  Created by Ilya Shaisultanov on 1/27/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import UIKit

class RemoteImage: UIImageView {
    func loadUrl(url: String) {
        DataService.ds.fetchImage(url) { err, image in
            if image != nil {
                self.image = image
            }
        }
    }
}
