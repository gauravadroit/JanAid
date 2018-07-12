//
//  UIView+Extension.swift
//  Phase
//
//  Created by Mahabir on 06/03/18.
//  Copyright © 2018 Mahabir. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func dropShawdow() {
        self.backgroundColor = UIColor.white
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowColor = UIColor.black.cgColor
        self.clipsToBounds = false
        self.layer.shadowOpacity = 0.3
    }
}


extension UIView {
    func takeScreenshot() -> UIImage {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleToFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleToFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
