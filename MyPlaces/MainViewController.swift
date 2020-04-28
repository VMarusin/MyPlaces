//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 23.04.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    //инициализируем нашу модель в которой есть функфия заполнения модели данными
    let places = Place.getPlaces()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count // кол-во ячеек равно кол-ву эл массива
    }
    //наполнение ячеек
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell // as! CustomTableViewCell вставили специльно что бы привести к типу нашеve классу CustomTableViewCell
        
        // обращаемся к конкретному обьекту из массива places и передаем в лейбл CustomTableViewCell
        cell.nameLabel.text = places[indexPath.row].name
        cell.locationLabel.text = places[indexPath.row].location
        cell.typeLabel.text = places[indexPath.row].type
        cell.imageOfPlace.image = UIImage(named: places[indexPath.row].image)
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 //скругляем края (берем половину от высоты размера imageOfPlace) если нужно скугление от размера ячейки то imageOfPlace cell.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true // обрезаем изображение по границам закругления

        return cell
    }
    
    // MARK: - Table View delegate
    
    // метод возвращает заданную высоту строки. Сейчас нам не нужен т.к высоту ячейки мы указали через интерфейс билдер
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 85
//    }

}
