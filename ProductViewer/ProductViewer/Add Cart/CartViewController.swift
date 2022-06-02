//
//  CartViewController.swift
//  ProductViewer
//
//  Created by Vignesh Radhakrishnan on 11/03/21.
//

import UIKit

final class CartViewController : UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var cartTableView: UITableView!
    private var viewModel : ListViewModel!
    weak var delegate: CartListViewControllerDelegate?
    
    static func prepareVC(withDependency dependency:CardDependencyProtocol) -> CartViewController {
        let viewController = CartViewController(nibName: "CartViewController", bundle: nil)
        let viewModel = CartViewModel(withDependency: dependency)
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
        self.title = "Cart"
        setupNavBar()
        setupTableView()
        fetchItems()
    }
    private func fetchItems() {
        self.viewModel.fetchItems()
    }
    private func setupNavBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonAction))
    }
    @objc func closeButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    private func setupTableView() {
        cartTableView.register(UINib(nibName: String(describing: ProductListCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ProductListCell.self))
        cartTableView.separatorStyle = .none
        cartTableView.delegate = self
        cartTableView.dataSource = self
        cartTableView.tableFooterView = UIView.init(frame: .zero)
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
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
        {
            return true
        }
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
        {
            if editingStyle == .delete {
                self.viewModel.deleteCart(indexPath: indexPath) { (result) in
                    switch result {
                    case .success(_):
                        self.cartTableView.beginUpdates()
                        self.cartTableView.deleteRows(at: [indexPath], with: .fade)
                        self.handleSuccess()
                        self.cartTableView.endUpdates()
                        UIAlertController.showAlert(message: "This Product deleted successfully", parentVC: self)
                    case .failure(_):
                        UIAlertController.showAlert(message: "Unable to delete", parentVC: self)
                    }
                }
            }
        }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let nav = self.navigationController {
            self.delegate?.didChooseProductFromCart(productID: self.viewModel.getCellViewModel(atIndex:  indexPath.row, inSection:  indexPath.section).ID, nav: nav)
        }
    }
}
extension CartViewController: ListViewStateDelegate {
    private func handleSuccess() {
        if self.viewModel.numberOfItems() > 0 {
            cartTableView.reloadData()
        } else {
            self.addNoDataView(error: "No cart items")
        }
    }
    func onStateChange(_ state: ListViewState) {
        
        self.cartTableView.backgroundView = nil
        switch state {
        case .loading:
            break;
        case .requestSuccess:
            handleSuccess()
        case .requestFailure(let error):
            addNoDataView(error: error)
        case .networkFailure(let error):
            addNoDataView(error: error)
        }
    }
   
    private func addNoDataView(error : String) {
        if let view = Bundle.main.loadNibNamed("NoDataView", owner: self, options: nil)?.last as? NoDataView {
            view.configureData(image: "no_data", title: "", description: error)
            self.cartTableView.backgroundView = view
        }
    }
}
