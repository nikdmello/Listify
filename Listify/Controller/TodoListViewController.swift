//
//  ViewController.swift
//  Listify
//
//  Created by Nikhil D'Mello on 8/9/19.
//  Copyright © 2019 Nikhil D'Mello. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    // Provides interface to file system
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Tasks.plist")
    
    // Represents an array of Task objects
    var taskArray = [Task]()
    
    // Access to UserDefaults
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let task1 = Task()
//        task1.title = "walk fudge"
//        taskArray.append(task1)

        
//        if let tasks = defaults.array(forKey: "ListArrays") as? [Task] {
//            taskArray = tasks
//        }
        
        loadTaskData()
    }
    
    //MARK - TableView DataSource Methods
    
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
    
    //MARK - TableView Delegate Methods
    
    // Tells the delegate that the specified row is now selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Updates whether or not the Task object is completed as part of the checkmark functionality
        taskArray[indexPath.row].completed = !taskArray[indexPath.row].completed
        
        // Encodes the updated completed variable in the plist
        saveTask()
        
        // TableView calls its datasource methods again
        tableView.reloadData()
 
        // Provides a smooth animation for deselecting a row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add Task Button
    @IBAction func AddItemButton(_ sender: UIBarButtonItem) {
        
        // A textfield to be displayed in the UIAlertController
        var textField = UITextField()
        
        // An object that displays an alert message to the user.
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
        
        // An action that can be taken when the user taps a button in an alert.
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newTask = Task()
            newTask.title = textField.text!
            
            self.taskArray.append(newTask)
            
            self.saveTask()
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter task"
            textField = alertTextField
         }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manipulation Methods
    // Writes data to dataFilePath by encoding data
    func saveTask() {
        
        // Encodes data into an array of Tasks (custom objects/dictionaries) in dataFilePath
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(taskArray)
            try data.write(to: dataFilePath!)
        }
        catch {
            print("Error encoding task array")
        }
    }
    
    // Reads data from dataFilePath by decoding data in plist
    func loadTaskData() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                taskArray = try decoder.decode([Task].self, from: data)
            }
            catch {
                print("Error decoding task array")
            }
        }
    }

}

