//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 29.04.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView() // убираем разлиновку ячеек заменяя ее обычным View там где нет ячеек
    }
    
    //MARK: TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 { //если тапаем по 1 ячейке то
            
        } else {// если тапаем за пределами 1 ячейки то скрываем клавиатуру
            view.endEditing(true)
        }
    }
}
    
    // MARK: TextField Delegate
    
    extension NewPlaceViewController: UITextFieldDelegate {
        
        //Скрывае клавиатуру по нажанию на Done
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
    }
}

