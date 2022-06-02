//
//  ProductDetailViewController.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import UIKit

final class ProductDetailViewController : UIViewController,CentralSpinnerProtocol {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var centralSpinner: UIActivityIndicatorView?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var addToListButton: UIButton!
    
    private var viewModel : ProductDetailViewModel!
    
    static func prepareVC(withDependency dependency:ProductDetailDependency) -> ProductDetailViewController {
        let viewController = ProductDetailViewController(nibName: "ProductDetailViewController", bundle: nil)
        let viewModel = ProductDetailViewModel(withDependency: dependency)
        viewModel.delegate = viewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        initCenterSpinner()
        fetchProductDetails()
    }
    private func configureSubviews() {
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        self.profileImageView.image = UIImage(named: Image.ProductList.profilePicturePlaceHolder)
    }
    private func fetchProductDetails() {
        self.viewModel.fetchProductDetail()
    }
    @IBAction func addToCartButtonAction(_ sender: Any) {
        self.viewModel.addToCart { (result) in
            switch result {
            case .success(let message):
                UIAlertController.showAlert(message: message, parentVC: self)
            case .failure(_):
                UIAlertController.showAlert(message: "Error in adding to the cart", parentVC: self)
            }
        }
    }
    
    private func populateData() {
        if let imageURL = self.viewModel.detailContentViewModel?.imageURL {
            ImageDownloader.sharedImageDownloader.download(path: imageURL) { [weak self] (image) in
                guard let self = self else {
                    return
                }
                var imageToDisplay = image
                if image == nil {
                    imageToDisplay = UIImage(named: Image.ProductList.profilePicturePlaceHolder)
                }
                self.profileImageView.image = imageToDisplay
            }
        }
        self.productPrice.text = self.viewModel.detailContentViewModel?.price
        self.productDescription.text = self.viewModel.detailContentViewModel?.productDescription
        self.navigationItem.title = self.viewModel.detailContentViewModel?.title
    }
}
extension ProductDetailViewController: DetailViewStateDelegate {
    func onStateChange(_ state: DetailViewState) {
        switch state {
        case .loading:
            self.animateCentralSpinner()
        case .requestSuccess:
            self.stopAnimatingCentralSpinner()
            populateData()
        case .requestFailure(let error):
            self.stopAnimatingCentralSpinner()
            UIAlertController.showAlert(message: error, parentVC: self)
        case .networkFailure(let error):
            self.stopAnimatingCentralSpinner()
            UIAlertController.showAlert(message: error, parentVC: self)
        }
    }
}
