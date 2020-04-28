//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 23.04.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count // кол-во ячеек равно кол-ву эл массива
    }
    //наполнение ячеек
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell // as! CustomTableViewCell вставили специльно что бы привести к типу нашеve классу CustomTableViewCell
        
        cell.nameLabel.text = restaurantNames[indexPath.row] // текстовое содержание ячейки передаем в лейбл CustomTableViewCell
        cell.imageOfPlace.image = UIImage(named: restaurantNames[indexPath.row]) //изображение ячейки из массива в лейбл CustomTableViewCell
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 //скругляем края (берем половину от высоты размера imageOfPlace) если нужно скугление от размера ячейки то imageOfPlace cell.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true // обрезаем изображение по границам закругления

        return cell
    }
    
    // MARK: - Table View delegate
    
    // метод возвращает заданную высоту строки
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

}
