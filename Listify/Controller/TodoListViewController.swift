//
//  ViewController.swift
//  Listify
//
//  Created by Nikhil D'Mello on 8/9/19.
//  Copyright © 2019 Nikhil D'Mello. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    // Reference to the context for the persistent container
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Represents an array of Task objects
    var taskArray = [Task]()
    
    // Updates when category is selected and loads tasks of that parent category
    var selectedCategory : Category? {
        didSet {
            loadTaskData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    //MARK: - TableView DataSource Methods
    
    // Tells the data source to return the number of rows in a given section of a table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // Asks the data source for a cell to insert in a particular location of the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        let task = taskArray[indexPath.row]
        
        cell.textLabel?.text = task.title
        
        // Updates accessory type to display a checkmark
        cell.accessoryType = task.completed ? .checkmark : .none

        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    // Tells the delegate that the specified row is now selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Updates whether or not the Task object is completed as part of the checkmark functionality
        taskArray[indexPath.row].completed = !taskArray[indexPath.row].completed
        
        saveTask()
 
        // Provides a smooth animation for deselecting a row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add Task Button
    @IBAction func AddItemButton(_ sender: UIBarButtonItem) {
        
        // A textfield to be displayed in the UIAlertController
        var textField = UITextField()
        
        // An object that displays an alert message to the user.
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
        
        // An action that can be taken when the user taps a button in an alert.
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newTask = Task(context: self.context)
            newTask.title = textField.text!
            newTask.completed = false
            newTask.parentCategory = self.selectedCategory
            
            self.taskArray.append(newTask)
            
            self.saveTask()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter task"
            textField = alertTextField
         }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    // Saves Tasks using Core Data
    func saveTask() {

        do {
            try context.save()
        }
        catch {
            print("Error saving context, \(error)")
        }
        self.tableView.reloadData()
    }
    
    // Retrieves Tasks array from persistent store with specified fetch request
    // Default value retrieves the entire Task array
    func loadTaskData(with request: NSFetchRequest<Task> = Task.fetchRequest(), predicate: NSPredicate? =  nil) {
        
        // Filters the tasks under the appropriate parent category
        let categoryPredicate = NSPredicate(format: "parentCategory.categoryTitle MATCHES %@", selectedCategory!.categoryTitle!)
        
        // Optional binding to ensure that only the category predicate is applied if the title predicate is nil
        if let titleContainsPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, titleContainsPredicate])
        }
        else {
            request.predicate = categoryPredicate
        }
        
        // Updates task array with the data from the fetch request
        do {
            taskArray = try context.fetch(request)
        }
        catch {
            print("Error fetching data")
        }
        tableView.reloadData()
    }

}

//MARK: - SearchBar Methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Creates request to read from context
        let request : NSFetchRequest<Task> = Task.fetchRequest()
        
        // Uses a 'title contains' predicate to narrow request
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // Uses sortDescriptors for alphabetical ordering
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadTaskData(with: request, predicate: titlePredicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Retrieves Task array without any search criteria
        if searchBar.text!.isEmpty {
            loadTaskData()
            // Resigns search bar on the main thread
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}

