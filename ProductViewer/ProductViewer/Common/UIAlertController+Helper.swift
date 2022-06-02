//
//  UIAlertController+Helper.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 11/03/21.
//

import UIKit

extension UIAlertController {
    class func showAlert(message : String,parentVC : UIViewController) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            return
        })
        alert.addAction(confirmAction)
        parentVC.present(alert, animated: true, completion: nil)
    }
}
