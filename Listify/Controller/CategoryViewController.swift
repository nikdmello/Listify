//
//  CategoryViewController.swift
//  Listify
//
//  Created by Nikhil D'Mello on 8/17/19.
//  Copyright © 2019 Nikhil D'Mello. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    // Instantiates Realm database
    let realm = try! Realm()
    
    // Results container of Category objects
    var categoryResults: Results<Category>?
    
    // Loads all Category objects upon launch
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Registers VC to participate with 3D Touch preview (peek) and commit (pop).
        registerForPreviewing(with: self, sourceView: tableView)

        loadCategoryData()
    }

    //MARK: - Add Category Button
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        
        // Receives text from alert controller's text field
        var textField = UITextField()
        
        // An object that displays an alert message to the user.
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        // An action that cancels adding new category operation
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // An action that can be taken when the user taps a button in an alert.
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            // Instantiates new Category
            let newCategory = Category()
            newCategory.categoryTitle = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
            
        }
                
        // Displays text field in UIAlertController
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter category name"
            textField = alertTextField
            textField.spellCheckingType = .yes
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - TableView Datasource Methods
    
    // Returns number of Category objects as number of rows.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns 1 cell if optional is nil
        return categoryResults?.count ?? 1
    }
    
    // Inserts Category cell in a particular location of the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Reference to Cell created in superclass at current indexPath
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Reference to Category at a certain index path
        if let category = categoryResults?[indexPath.row] {
            
            // Updates cell text to that of the Category title
            cell.textLabel?.text = category.categoryTitle
        
            guard let cellColor = UIColor(hexString: category.color) else {
                fatalError()
            }
            
            cell.backgroundColor = cellColor
            cell.textLabel?.textColor = ContrastColorOf(cellColor, returnFlat: true)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 19)
            
        }
        
        // Returns cell in tableview
        return cell
        
    }
    
    //MARK: - TableView Delegate Methods
    // Notifies delegate that the specified row is now selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Performs segue to the TodoListViewController
        performSegue(withIdentifier: "goToTaskList", sender: self)
    }
    
    // Sets data on the destination view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Instantiates destination view controller
        let destinationVC = segue.destination as! TodoListViewController
        
        // Updates selectedCategory to display the respective tasks of the selected category
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryResults?[indexPath.row]
        }
    }
    
    
    //MARK: - Data Manipulation Methods
    // Saves Category
    func save(category: Category) {
        
        do {
            // Enables to commit changes to realm within write transaction
            try realm.write {
                realm.add(category)
            }
        }
        catch {
            print("Error saving category, \(error)")
        }
        self.tableView.reloadData()
    }
    
    // Fetches all Category objects from realm by specifying Category data type
     func loadCategoryData() {
        
        categoryResults = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    // Deletes Category data
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categoryResults?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
            }
            catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}

// Handles 3D Touch peek and pop actions.
extension CategoryViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        if let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) {
            previewingContext.sourceRect = tableView.convert(cell.frame, to: self.tableView)
            
            guard let detailViewController = storyboard?.instantiateViewController(withIdentifier: "todoList") as? TodoListViewController else {
                return nil
            }
            
            if let category = categoryResults?[indexPath.row] {
                detailViewController.selectedCategory = category
            }
            
            return detailViewController
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
