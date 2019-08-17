//
//  CategoryViewController.swift
//  Listify
//
//  Created by Nikhil D'Mello on 8/17/19.
//  Copyright © 2019 Nikhil D'Mello. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    // Array of Categories
    var categoryArray = [Category]()
    
    // Reference to the context for the persistent container 
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategoryData()

    }

    //MARK: - Add Category Button
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        
        // A textfield to be displayed in the UIAlertController
        var textField = UITextField()
        
        // An object that displays an alert message to the user.
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        // An action that cancels adding new category operation
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // An action that can be taken when the user taps a button in an alert.
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.categoryTitle = textField.text!
            
            self.categoryArray.append(newCategory)
            
            self.saveCategory()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter category name"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Creates a reusable cell to be added to the table at the index path
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.categoryTitle
        
        return cell
        
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTaskList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    
    
    //MARK: - Data Manipulation Methods
    // Saves Tasks using Core Data
    func saveCategory() {
        
        do {
            try context.save()
        }
        catch {
            print("Error saving context, \(error)")
        }
        self.tableView.reloadData()
    }
    
    // Retrieves Tasks array from persistent store with specified fetch request
    // Default value retrieves the entire Category array
    func loadCategoryData(with request : NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            // Updates category array with the data from the fetch request
            categoryArray = try context.fetch(request)
        }
        catch {
            print("Error fetching category data")
        }
        tableView.reloadData()
    }
    
}
