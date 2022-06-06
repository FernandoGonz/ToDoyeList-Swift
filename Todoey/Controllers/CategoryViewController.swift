//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Fernando González on 06/06/22.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    let context: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    var categoryArray: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadCategories()
    }
    
    //MARK: - Add a New Category
    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert: UIAlertController = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action: UIAlertAction = UIAlertAction(title: "Add Category", style: .default) { action in
            let category: Category = Category(context: self.context!)
            category.name = textField.text!
            self.categoryArray.append(category)
            
            DispatchQueue.main.async {
                self.saveCategory()
            }
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    private func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            self.categoryArray = try self.context!.fetch(request)
        } catch  {
            print("Error fetching data from context \(error)")
        }
        self.tableView.reloadData()
    }
    
    private func saveCategory() {
        do {
            try self.context?.save()
        } catch {
            print("Error saving category into DataModel \(error)")
        }
        self.tableView.reloadData()
    }
    
    //MARK: - TableViewDataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellIdentifier, for: indexPath)
        
        let category: Category = self.categoryArray[indexPath.row]
        
        var content = categoryCell.defaultContentConfiguration()
        content.text = category.name
        
        categoryCell.contentConfiguration = content
        categoryCell.accessoryType = .disclosureIndicator
        
        return categoryCell
    }
    
    //MARK: - TableViewDelegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segueGoToItems, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ViewController
        
        // This line gets the curren selected row index
        if let indexPath = self.tableView.indexPathForSelectedRow {
            // Sending the category object to the next ViewController (see ViewController)
            destinationVC.selectedCategory = self.categoryArray[indexPath.row]
            
        }
    }
    
}
