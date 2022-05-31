//
//  ViewController.swift
//  Todoey
//
//  Created by Fernando González on 25/05/22.
//

import UIKit

class ViewController: UITableViewController {
    
    var itemArray: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.itemArray.append(Item(title: "Find Mike", done: false))
        self.itemArray.append(Item(title: "Play Ratchet", done: false))
        self.itemArray.append(Item(title: "Learn about swift", done: false))
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
            self.itemArray.append(Item(title: textField.text ?? "New Item", done: false))
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
        
        // Updating tableView (calling UITableViewDataSource again)
        tableView.reloadData()
        
        // To deselect a row with animation
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



