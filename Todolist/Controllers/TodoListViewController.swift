//
//  ViewController.swift
//  Todolist
//
//  Created by Rajinikumar Rai on 08/07/2019.
//  Copyright © 2019 Rajinikumar Rai. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
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
    
      //to remove items from the list
        /*context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row) */
      
        //below line is to set/remove the tick mark when clicked
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
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
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
        
        do {
          try context.save()
        } catch {
            print("Error saving the context \(error)")
        }
           self.tableView.reloadData()
    }
    //MARK:- Load Items

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
       let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        
//
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
//
//          request.predicate = compoundPredicate
        do {
           itemArray = try context.fetch(request)
        } catch {
            print("Erro fetching data from context \(error)")
        }
    
         tableView.reloadData()
    }

}

//MARK: - Search bar methods


extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
    
      let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
       request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadItems(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}

