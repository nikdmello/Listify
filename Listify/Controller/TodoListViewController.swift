//
//  ViewController.swift
//  Listify
//
//  Created by Nikhil D'Mello on 8/9/19.
//  Copyright © 2019 Nikhil D'Mello. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    // Instantiates a Realm database
    let realm = try! Realm()
    
    // Represents a collecton of Results of Tasks
    var taskResults: Results<Task>?
    
    // Updates when category is selected and loads tasks of that parent category
    var selectedCategory : Category? {
        didSet {
            loadTaskData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    //MARK: - TableView DataSource Methods
    
    // Returns number of Task objects as number of rows.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns one row if there are no Task objects
        return taskResults?.count ?? 1
    }
    
    // Inserts Task cell in a particular location of the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        
        // Updates cell properties to those of the specified Task
        if let task = taskResults?[indexPath.row] {
            cell.textLabel?.text = task.title
            // Updates accessory type to display a checkmark
            cell.accessoryType = task.completed ? .checkmark : .none
            cell.tintColor = UIColor.blue
        }
        else {
            // Inserts default text label if no Task objects
            cell.textLabel?.text = "Add new Task"
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    // Notifies delegate that the specified row is now selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Generates haptic feedback for improved UX
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()

        // Updates whether or not the Task object is completed as part of the checkmark functionality
        if let task = taskResults?[indexPath.row] {
            do {
                try realm.write {
                    task.completed = !task.completed
                }
            }
            catch {
                print("Error updating task, \(error)")
            }
        }
        
        tableView.reloadData()
        
        // Provides a smooth animation for deselecting a row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add Task Button
    @IBAction func AddTaskButton(_ sender: UIBarButtonItem) {
        
        // Receives text from alert controller's text field
        var textField = UITextField()

        // An object that displays an alert message to the user.
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)

        // An action that cancels the alert.
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        // An action that can be taken when the user taps a button in an alert.
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            // Adds new Task to realm
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        // Instantiates new Task
                        let newTask = Task()
                        newTask.title = textField.text!
                        newTask.dateCreated = Date()
                        // Appends new Task to the List<Task> of currentCategory
                        currentCategory.tasks.append(newTask)
                }
            }
                catch {
                    print("Error writing task, \(error)")
                }
            }
            self.tableView.reloadData()
        }

        // Displays text field in UIAlertController
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter task"
            textField = alertTextField
         }
        
        // Adds actions to alert
        alert.addAction(action)
        alert.addAction(cancelAction)

        // Animates alert
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    // Retrieves alphabetically sorted List<Task> from selectedCategory from realm
    func loadTaskData() {
        
        taskResults = selectedCategory?.tasks.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }

}

//MARK: - SearchBar Methods
extension TodoListViewController: UISearchBarDelegate {

    // Notifies delegate that the search button was clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // Filters taskResults with predicate such that Task title contains the search bar text field
        // Sorts results by date of creation
        taskResults = taskResults?.filter("title CONTAINS[cd] %a", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }


    // Notifies delegate that search bar text is updated
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        // Retrieves all taskResults
        if searchBar.text!.isEmpty {
            loadTaskData()
            // Resigns search bar on the main thread
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}
