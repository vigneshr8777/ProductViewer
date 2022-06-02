//
//  ProductListCell.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import UIKit

struct ColorTheme {
    enum ProductList {
        static let borderColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1.0)
    }
}

protocol ListCellViewModel {
    var ID : String {get}
    var title: String {get}
    var profilePicturePath: String? {get}
    var price: String {get}
    var aisleInfo: String {get}
}

final class ProductListCell : UITableViewCell {
    
    struct ViewModel: ListCellViewModel {
        var aisleInfo: String
        var ID: String
        let title: String
        let profilePicturePath: String?
        var price: String
    }
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var aisleInfoLabel: UILabel!
    private var profilePicturePath: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 10.0
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = ColorTheme.ProductList.borderColor.cgColor
        
        profileImageView.clipsToBounds = true
        selectionStyle = .none
    }
    
    func configureCell(withViewModel viewModel: ListCellViewModel) {
        self.productNameLabel.text = viewModel.title
        self.productPrice.text = viewModel.price
        self.aisleInfoLabel.text = viewModel.aisleInfo
        
        if let path = viewModel.profilePicturePath {
            profilePicturePath = path
            ImageDownloader.sharedImageDownloader.download(path: path) { [weak self] (image) in
                guard let self = self else {
                    return
                }
                var imageToDisplay = image
                if image == nil {
                    imageToDisplay = UIImage(named: Image.ProductList.profilePicturePlaceHolder)
                }
                if self.profilePicturePath == path {
                    self.profileImageView.image = imageToDisplay
                }
            }
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(named: Image.ProductList.profilePicturePlaceHolder)
    }
}
extension ProductListCell.ViewModel {
    
    init(product: Product) {
        self.ID = "\(product.id)"
        self.title = product.title
        self.price =  product.regularPrice.displayString
        self.profilePicturePath = product.imageURL
        self.aisleInfo = product.aisle
    }
    
    init(product: ProductInfo) {
        self.ID = "\(product.productID)"
        self.title = product.title ?? ""
        self.price =  product.price ?? ""
        self.profilePicturePath = product.imageURL
        self.aisleInfo = product.aisle ?? ""
    }
}
