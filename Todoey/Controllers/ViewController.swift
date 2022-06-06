//
//  ViewController.swift
//  Todoey
//
//  Created by Fernando González on 25/05/22.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    let context: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    var itemArray: [Item] = []
    
    // Attribute that gets the value from the CategoryViewController (throgh segue)
    var selectedCategory: Category? {
        didSet { // once this attribute has a value, execute all into brackets
            self.loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Data Manipulation Methods
    
    /// This function allows to save a new Item into CoreData model
    /// ```
    /// print(hello("World")) // Hello, World!
    /// ```
    /// - Warning: The returned string is not localized.
    /// - Parameter subject: The subject to be welcomed.
    /// - Parameter alfa: This is a dummy parameter
    /// - Returns: A hello string to the `subject`.
    private func saveItem() {
        do {
            try self.context!.save()
        } catch {
            print("Error saving item into DataModel \(error)")
        }
        self.tableView.reloadData()
    }
    
    /// This function allows to read items from the CoreDate model throgh a fetch request
    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        // If this method is called without argument, Item.fetchRequest() is the default fetch request and gets all elements in the DB (without filters or sortDesription)
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", self.selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            self.itemArray = try self.context!.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Add New Item
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        // Creating local variable
        var textField = UITextField()
        
        // Creating alert message
        let alert = UIAlertController(title: "Add new Todoy Item", message: "", preferredStyle: .alert)
        
        // Creating action button for the alert
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            // Adding the new value to the itemsArray and reloading data
            let item: Item = Item(context: self.context!)
            item.title = textField.text!
            item.done = false
            item.parentCategory = self.selectedCategory
            self.itemArray.append(item)
            
            DispatchQueue.main.async {
                self.saveItem()
            }
        }
        
        // Creating textField into alert body
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        // Adding the button action to alert dialog
        alert.addAction(action)
        
        // Showing the alert dialog
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - UITableViewDataSource
    // UITableViewDataSource is responsible to fill the tableView with the information cells when tableView.reloadData() is trigged
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        
        let item: Item = itemArray[indexPath.row]
        
        var content = itemCell.defaultContentConfiguration()
        content.text = item.title
        itemCell.contentConfiguration = content
        
        itemCell.accessoryType = (item.done == true ? .checkmark : .none)
        
        return itemCell
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Changing the done flag
        self.itemArray[indexPath.row].done = !self.itemArray[indexPath.row].done
        
        // Updating done attribute for current item
        self.saveItem()
        
        // To deselect a row with animation
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let item = searchBar.text {
            // This method is called when users taps magnifier icon or serach button into keyboard is pressed
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            
            // We need to specify how should show the results using filter. If you want te get result with case sensitive use only CONTAINS, for the other hand, use CONTAINS[cd]
            let predicate: NSPredicate = NSPredicate(format: "title CONTAINS[cd] %@", item)
            
            // Adding query for the request
            request.predicate = predicate
            
            // Sorting results from the request
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            
            request.sortDescriptors = [sortDescriptor]
            
            // Fetching data from the context (BD) with the filter
            self.loadItems(with: request)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // This method will triggered each there is a change into UISearchBarView
        if searchBar.text?.count == 0 {
            // Loading items again
            self.loadItems()
            
            // For quit focus (cursor) from the searchBar and hide the keyboard
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            
        }
    }
}


