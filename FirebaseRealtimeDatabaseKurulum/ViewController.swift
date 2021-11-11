//
//  ViewController.swift
//  FirebaseRealtimeDatabaseKurulum
//
//  Created by Gülşah Alan on 26.10.2021.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase

class ViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var itemArray: [String] = []
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    private var keyArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        ref = Database.database().reference()
        loadItem()
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

//MARK: - Tableview DataSource & Delegate Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            getAllKeys()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.deleteItem(at: indexPath)
                self.itemArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - Add Button Method
extension ViewController {
    @IBAction private func addButtonTapped(_ sender: UIBarButtonItem) {

        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: .none)
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            
            let newItem = textfield.text
            
            self.writeItem(with: newItem ?? "")
            DispatchQueue.main.async {
                self.loadItem()
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        alert.addAction(dismissAction)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Type Something"
            textfield = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
}
}

//MARK: - Firebase Methods
extension ViewController {
    func writeItem(with item: String) {
        ref?.child("ItemsList").childByAutoId().setValue(["itemName": item])
    }
    
    func loadItem() {
        self.itemArray = []
        self.ref.child("ItemsList").observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let value = child.value as? NSDictionary
                let itemName = value?["itemName"] as? String ?? ""
                let newItem = itemName
                self.itemArray.append(newItem)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    func getAllKeys() {
        ref.child("ItemsList").observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let key = child.key
                self.keyArray.append(key)
            }
        }
    }
    
    func deleteItem(at index: IndexPath) {
        ref.child("ItemsList").child(self.keyArray[index.row]).removeValue()
    }
}
