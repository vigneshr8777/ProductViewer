//
//  NoDataView.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import UIKit

final class NoDataView : UIView {
    
    @IBOutlet weak var noDataImageView: UIImageView!
    @IBOutlet weak var retryLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configureData(image : String,title : String,description : String) {
        noDataImageView.image = UIImage(named: image)
        descLabel.text = description
        retryLabel.text = title
    }
}
