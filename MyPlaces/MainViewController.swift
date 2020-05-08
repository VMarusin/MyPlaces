//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 23.04.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var reversedSortingButton: UIBarButtonItem!
    
    //инициализируем нашу модель в которой есть функфия заполнения модели данными
    var places: Results<Place>! //Results это автообновляемы тим контейнера который возвращает запрашиваемые обьекты (аналог массива но для БД)
    var ascendingSorting = true //свойство отвечающее за обратную сортировку

    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self) //отображаем данные БД на экране инициализировав обьект places (запрашиваем данные в БД)
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count // кол-во ячеек равно кол-ву эл БД. Если БД пустая то возырвщает пусто
    }
    //наполнение ячеек
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell // as! CustomTableViewCell вставили специльно что бы привести к типу нашеve классу CustomTableViewCell

        let place = places[indexPath.row]

        // обращаемся к конкретному обьекту из массива places и передаем в лейбл CustomTableViewCell
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 //скругляем края (берем половину от высоты размера imageOfPlace) если нужно скугление от размера ячейки то imageOfPlace cell.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true // обрезаем изображение по границам закругления

        return cell
    }
    // MARK: - Table View delegate
    
    // в этом метод мы помещаем все действия доступны после свайпа строки влево
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let place = places[indexPath.row] //опрделяем обьект для удадления
//        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
//
//            StorageManager.deleteObject(place)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//        return [deleteAction]
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row] //опрделяем обьект для удадления
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // метод возвращает заданную высоту строки. Сейчас нам не нужен т.к высоту ячейки мы указали через интерфейс билдер
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 85
//    }
    
    
    //MARK: - Navigation
    
    //тапая по ячейки мы передаем обьект из этой ячейки на другой VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }// определяем индекс текущий ячейки
            let place = places[indexPath.row]//имея индекс текущей строки  мы можем извлечь обьект из массива Places по этому индексу
            let newPlaceVC = segue.destination as! NewPlaceViewController // создаем экземлпяр этого VC
            newPlaceVC.currentPlace = place//обращаемся к нашему экземпляру и передаем ему значение place
        }
    }
    
    //этот метод нужне что бы мы могли на него сослатся при создании выхода из режима добавления нового заведения
    @IBAction func unwindSegue(_  segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else  { return }
        
        newPlaceVC.savePlace() // создаем новый экзкмпляр
        tableView.reloadData() // обновляем tableView что бы отобразить новый ресторан
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        ascendingSorting.toggle() //меняет значание на противоположное для обратной сотрировки
        
        if ascendingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting() //вызываем метод сортировки
    }
   
    // метод сортировки
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 { // если в SegmentedContol выбран первый раздел то сортируем по дате
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }
}
