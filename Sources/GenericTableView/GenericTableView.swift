
#if os(iOS)
import UIKit
#endif

public class GenericListTableViewController<T, Cell: UITableViewCell>: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var items: [T]
    var filteredItems: [T] = []
    
    var configure: (Cell, T) -> Void
    var selectHandler: (T) -> Void
    var searchHandler: ((String, [T]) -> Void)?
    
    var searchController: UISearchController?
    
    var isSearchable: Bool = false {
        didSet {
            if isSearchable == true {
                setupSearchView()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   public init(items: [T], configure: @escaping (Cell, T) -> Void, selectHandler: @escaping (T) -> Void) {
        self.items = items
        self.configure = configure
        self.selectHandler = selectHandler
        super.init(style: .plain)
        self.tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
    }
    
   public func refereshTableView() {
        self.tableView.reloadData()
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredItems.count
        }
        return items.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        
        if isFiltering() {
            let item = filteredItems[indexPath.row]
            configure(cell, item)
        }
        else {
            let item = items[indexPath.row]
            configure(cell, item)
        }
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isFiltering() {
            let item = filteredItems[indexPath.row]
            selectHandler(item)
        }
        else {
            let item = items[indexPath.row]
            selectHandler(item)
        }
        self.searchController?.isActive = false
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        if let handler = searchHandler {
            filteredItems.removeAll()
            handler(searchController.searchBar.text!, items)
        }
    }
    
    private func setupSearchView() {
        searchController = UISearchController(searchResultsController: nil)
        
        if let controller = searchController {
            controller.searchResultsUpdater = self
            controller.searchBar.autocapitalizationType = .none
            controller.searchBar.autocorrectionType = .no
            controller.searchBar.barStyle = .default
            controller.searchBar.placeholder = "Search"
            controller.dimsBackgroundDuringPresentation = false
            if #available(iOS 11.0, *) {
                // For iOS 11 and later, place the search bar in the navigation bar.
                navigationItem.searchController = searchController
                navigationItem.hidesSearchBarWhenScrolling = false
            } else {
                // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
                tableView.tableHeaderView = controller.searchBar
            }
            
            controller.delegate = self
            controller.searchBar.delegate = self // Monitor when the search button is tapped.
        }
    }
}

private extension GenericListTableViewController {
    func isFiltering() -> Bool {
        if let controller = searchController, controller.isActive == true, searchBarIsEmpty() == false {
            return true
        }
        
        return false
    }
    
    func searchBarIsEmpty() -> Bool {
        if let controller = searchController {
            return controller.searchBar.text?.isEmpty ?? true
        }
        
        return true
    }
}
