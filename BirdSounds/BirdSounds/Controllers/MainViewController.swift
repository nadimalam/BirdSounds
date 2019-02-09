//
//  ViewController.swift
//  BirdSounds
//
//  Created by Nadim Alam on 04/02/2019.
//  Copyright © 2019 Nadim Alam. All rights reserved.
//

import UIKit

enum State {
    case loading
    case populated([Recording])
    case empty
    case error(Error)
    case paging([Recording], next: Int)
    
    var currentRecordings: [Recording] {
        switch self {
        case .populated(let recordings):
            return recordings
        case .paging(let recordings, _):
            return recordings
        default:
            return []
        }
    }
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorView: UIView!
    
    let searchController = UISearchController(searchResultsController: nil)
    let networkingService = NetworkingService()
    let darkRed = UIColor(red: 208/255, green: 58/255, blue: 49/255, alpha: 1)
    var state = State.loading {
        didSet {
            setFooterView()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bird Sounds"
        activityIndicator.color = darkRed
        prepareNavigationBar()
        prepareSearchBar()
        prepareTableView()
        loadRecordings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.searchBar.becomeFirstResponder()
    }
    
    func setFooterView() {
        switch state {
            case .loading:
                tableView.tableFooterView = loadingView
            case .error(let error):
                errorLabel.text = error.localizedDescription
                tableView.tableFooterView = errorView
            case .empty:
                tableView.tableFooterView = emptyView
            case .populated:
                tableView.tableFooterView = nil
            case .paging:
                tableView.tableFooterView = loadingView
        }
    }
    
    // MARK: - Loading recordings
    
    @objc func loadRecordings() {
        state = .loading
        loadPage(1)
    }
    
    func update(response: RecordingsResult) {
        if let error = response.error {
            state = .error(error)
            return
        }
        
        guard let newRecordings = response.recordings,
            !newRecordings.isEmpty else {
                state = .empty
                return
        }
        
        var allRecordings = state.currentRecordings
        allRecordings.append(contentsOf: newRecordings)
        
        if response.hasMorePages {
            state = .paging(allRecordings, next: response.nextPage)
        } else {
            state = .populated(allRecordings)
        }
    }
    
    func loadPage(_ page: Int) {
        let query = searchController.searchBar.text
        networkingService.fetchRecordings(matching: query, page: page) { [weak self] response in
            
            guard let `self` = self else {
                return
            }
            
            self.searchController.searchBar.endEditing(true)
            self.update(response: response)
        }
    }
    
    // MARK: - View Configuration
    
    func prepareSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        
        let whiteTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let textFieldInSearchBar = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        textFieldInSearchBar.defaultTextAttributes = whiteTitleAttributes
        
        // Change the placeholder text color in Searchbar
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: darkRed])
        
        navigationItem.searchController = searchController
        searchController.searchBar.becomeFirstResponder()
    }
    
    func prepareNavigationBar() {
        navigationController?.navigationBar.barTintColor = darkRed
        
        let whiteTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = whiteTitleAttributes
    }
    
    func prepareTableView() {
        tableView.dataSource = self
        
        let nib = UINib(nibName: BirdSoundTableViewCell.NibName, bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: BirdSoundTableViewCell.ReuseIdentifier)
    }
}

// MARK: - UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar,
                   selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(loadRecordings),
                                               object: nil)
        
        perform(#selector(loadRecordings), with: nil, afterDelay: 0.5)
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return state.currentRecordings.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BirdSoundTableViewCell.ReuseIdentifier)
            as? BirdSoundTableViewCell else {
                return UITableViewCell()
        }
        cell.load(recording: state.currentRecordings[indexPath.row])
        
        if case .paging(_, let nextPage) = state,
            indexPath.row == state.currentRecordings.count - 1 {
            loadPage(nextPage)
        }
        
        return cell
    }
}
