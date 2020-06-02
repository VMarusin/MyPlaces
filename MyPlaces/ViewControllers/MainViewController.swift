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
    
    private var searchController = UISearchController(searchResultsController: nil) //свойство UISearchController для реализации поиска
    //инициализируем нашу модель в которой есть функфия заполнения модели данными. nil означает что для отображения результатов поиска мы не хотим создавать новый view а отображаем его во view где происходит поиск
    private var places: Results<Place>! //Results это автообновляемы тим контейнера который возвращает запрашиваемые обьекты (аналог массива но для БД)
    private var filteredPlaces: Results<Place>! // в коллекцию будем помещать отфильтрованные записи
    private var ascendingSorting = true //свойство отвечающее за обратную сортировку
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else  { return false }// возвращает true если строка будет пустой
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var reversedSortingButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self) //отображаем данные БД на экране инициализировав обьект places (запрашиваем данные в БД)
        
        //здесь производим настройку UISearchController
        searchController.searchResultsUpdater = self  //указываем что получателем информации об изменении текстов в поисковой строке будет наш класс
        searchController.obscuresBackgroundDuringPresentation = false  //VC с результатами поиска не позволяет взаимодействовать с отображаемым. Мы это выключаем и работаем как с основным (можем смотреть результаты исправлять их и удалять)
        searchController.searchBar.placeholder = "Search" //указываем отображение плейсхолдера строки поиска
        navigationItem.searchController = searchController// строка поиска будет интегрирована в navigationbar
        definesPresentationContext = true //позволяет отпустить строку поиска при переходе на другой экран!!
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPlaces.count
        }
        return places.count // кол-во ячеек равно кол-ву эл БД. Если БД пустая то возырвщает пусто
    }
    //наполнение ячеек
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell // as! CustomTableViewCell вставили специльно что бы привести к типу нашеve классу CustomTableViewCell
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]

        // обращаемся к конкретному обьекту из массива places и передаем в лейбл CustomTableViewCell
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.raiting

        return cell
    }
    // MARK: - Table View delegate
    
    //отключаем визуально выделение ячеек
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // в этом метод мы помещаем все действия доступны после свайпа строки влево
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
            
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
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

extension MainViewController: UISearchResultsUpdating {
    // метод фильтации контента в соответствии с запросом
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearhText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearhText(_ searchText: String) {
        filteredPlaces  = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)//заполняем коллекцию отфильтрованными обьектами массива Places. Фильтруем по значанению. CONTAINS[c] - не смотрим на регистр символов
        tableView.reloadData()
    }
}
