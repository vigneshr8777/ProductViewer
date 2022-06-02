//
//  ViewController.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 10/03/21.
//

import UIKit

protocol CartListViewControllerDelegate: class {
    func didChooseProductFromCart(productID : String,nav : UINavigationController)
}

protocol ProductListViewControllerDelegate: class {
    func didChooseProduct(productID : String)
    func showCartScreen()
}

final class ProductListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate,CentralSpinnerProtocol {
    
    var centralSpinner: UIActivityIndicatorView?
    private var viewModel : ListViewModel!
    @IBOutlet weak var productListTableView: UITableView!
    weak var listViewControllerDelegate: ProductListViewControllerDelegate?
    var refreshControl = UIRefreshControl()
    
    static func prepareVC(withDependency dependency:ProductListDependency) -> ProductListViewController {
        let viewController = ProductListViewController(nibName: "ProductListViewController", bundle: nil)
        let viewModel = ProductListViewModel(withDependency: dependency)
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
        setupNavigationBar()
        initCenterSpinner()
        setupTableView()
        fetchProducts()
    }
    private func setupNavigationBar() {
        self.navigationItem.title = "Products"
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44.0, height: 44.0))
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "cart_icon"), for: .normal)
        button.addTarget(self, action: #selector(showCart), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc func showCart() {
        self.listViewControllerDelegate?.showCartScreen()
    }
    private func fetchProducts() {
        viewModel.fetchItems()
    }
    
    private func setupTableView() {
        productListTableView.register(UINib(nibName: String(describing: ProductListCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ProductListCell.self))
        productListTableView.separatorStyle = .none
        productListTableView.delegate = self
        productListTableView.dataSource = self
        productListTableView.tableFooterView = UIView.init(frame: .zero)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        productListTableView.addSubview(refreshControl)
    }
    @objc func refresh(_ sender: AnyObject) {
       fetchProducts()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProductListCell.self), for: indexPath)
        if let cell = cell as? ProductListCell {
            cell.configureCell(withViewModel: self.viewModel.getCellViewModel(atIndex:  indexPath.row, inSection:  indexPath.section))
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.listViewControllerDelegate?.didChooseProduct(productID: self.viewModel.getCellViewModel(atIndex:  indexPath.row, inSection:  indexPath.section).ID)
    }

}
extension ProductListViewController: ListViewStateDelegate {

    func onStateChange(_ state: ListViewState) {
        
        self.productListTableView.backgroundView = nil
        switch state {
        case .loading:
            self.animateCentralSpinner()
        case .requestSuccess:
            self.stopAnimatingCentralSpinner()
            refreshControl.endRefreshing()
            productListTableView.reloadData()
        case .requestFailure(let error):
            handleFailure(error: error)
        case .networkFailure(let error):
            handleFailure(error: error)
        }
    }
    private func handleFailure(error : String) {
        refreshControl.endRefreshing()
        self.stopAnimatingCentralSpinner()
        addNoDataView(error: error)
    }
    private func addNoDataView(error : String) {
        if let view = Bundle.main.loadNibNamed("NoDataView", owner: self, options: nil)?.last as? NoDataView {
            view.configureData(image: "no_data", title: "", description: error)
            self.productListTableView.backgroundView = view
        }
    }
}



