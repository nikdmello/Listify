//
//  ViewController.swift
//  Listify
//
//  Created by Nikhil D'Mello on 8/9/19.
//  Copyright © 2019 Nikhil D'Mello. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var bgColorHexCode: String = "FF5E4E"
    
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
        
       // registerForPreviewing(with: self, sourceView: CategoryViewController().view)
        
        
        // UI changes to search bar
        searchBar.barStyle = .blackTranslucent
        let searchTextField = searchBar.value(forKey: "searchField") as! UITextField
        searchTextField.textColor = FlatWhite()
//        let magnifyingGlassIcon = searchTextField.leftView as! UIImageView
//        magnifyingGlassIcon.tintColor = FlatWhite()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Changes navigation title to that of the Category
        title = selectedCategory?.categoryTitle
        
        guard let colorHex = selectedCategory?.color else {
            fatalError()
        }
        
        updateNavBar(withHexCode: colorHex)
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Updates nav bar color to the default background color
        updateNavBar(withHexCode: bgColorHexCode)
    }
    
    //MARK: - Navigation Bar Setup
    // Updates navigation bar color properties with the given hex code
    func updateNavBar(withHexCode hexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {
            return
        }
        
        guard let navBarColor = UIColor(hexString: hexCode) else {
            fatalError()
        }
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.barTintColor = navBarColor
        searchBar.barTintColor = navBarColor
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
    }
    
    //MARK: - TableView DataSource Methods
    
    // Returns number of Task objects as number of rows.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns one row if there are no Task objects
        return taskResults?.count ?? 1
    }
    
    // Inserts Task cell in a particular location of the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Reference to Cell created in superclass at current indexPath
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Updates cell properties to those of the specified Task
        if let task = taskResults?[indexPath.row] {
            cell.textLabel?.text = task.title
            
            // Updates cell color to that of its parent Category and creates a gradient
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(taskResults!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.tintColor = ContrastColorOf(color, returnFlat: true)
            }
            // Updates accessory type to display a checkmark
            cell.accessoryType = task.completed ? .checkmark : .none
        }
        else {
            // Inserts default text label if no Task objects
            cell.textLabel?.text = "Add new Task"
        }
        // Returns cell in tableview
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    // Notifies delegate that the specified row is now selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Generates haptic feedback for improved UX
        let feedback = UIImpactFeedbackGenerator(style: .light)
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
            textField.spellCheckingType = .yes
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
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
    
    // Deletes Task data
    override func updateModel(at indexPath: IndexPath) {
        if let task = self.taskResults?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(task)
                }
            }
            catch {
                print("Error deleting task, \(error)")
            }
        }
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
