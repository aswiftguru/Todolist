//
//  ViewController.swift
//  Todolist
//
//  Created by Rajinikumar Rai on 08/07/2019.
//  Copyright © 2019 Rajinikumar Rai. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadItems()
    }

    //MARK: TableView datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
    
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
    
        //Ternary operator
        //value = condition ? valueIfTrue : valueIfFalse
        
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        /* below replaces above one line
        if item.done == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        */
        
        return cell
    }
    
    //MARK: - tableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
    
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
       
        saveItems()
        /*
        if itemArray[indexPath.row].done ==  false{
            itemArray[indexPath.row].done = true
        }else {
            itemArray[indexPath.row].done = false
        }
        */
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
    
    let alert = UIAlertController(title: "Add a new ToDoList item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add a new item", style: .default) { (action) in
            
            let newItem = Item()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem)
           
            self.saveItems()
            //self.defaults.set(self.itemArray, forKey: "ToDoListArray")/
         
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create a new item"
            textField = alertTextField
          
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    
    
    }
    
    //MARK: - Model manipulationMethods
    func saveItems() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
           self.tableView.reloadData()
    }
    //MARK:- Load Items
    
    func loadItems() {
    
        if let data = try?  Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding the array \(error)")
            }
        }
        
    }

}

