//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 29.04.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import UIKit
import Cosmos

class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place! //свойство куда мы можем передать обьект в типом Place (для отображения в режиме редактирования)
    var imageIsChanged = false //обьявляем флаг использвал ли пользователь свое изобразение или не использовал что бы поставить дефлтное
    
    var currentRaiting = 0.0
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet var raitingControl: RaitingControl!
    @IBOutlet var cosmosView: CosmosView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        DispatchQueue.main.async { // делаем синхронизацию БД в фоновом режиме во измбеждании фризов и блокировки доступв БД на лету без обновления интерфейса
//            self.newPlace.savePlaces()
//        }
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1)) // убираем разлиновку ячеек заменяя ее обычным View там где нет ячеек
        saveButton.isEnabled = false //отелючанм кнопку Save пока не будет введено название рестрана
        placeName.addTarget(self, action: #selector(teхtFieldChanged), for: .editingChanged) //метод будет вызыватся при редактировании поля placeName
        setupEditScreen() // запускаем метод передачи данных из Place в VC для редактирования
        
        //альтернативный вариант отображения звезд спомощью Framework Cosmos
        cosmosView.settings.fillMode = .full //указываем как будем заполнять звезды (поностью/половина/точечно)
        cosmosView.didTouchCosmos = { raiting in // в raitin сохраняется текущий рейтинг
            self.currentRaiting = raiting //сохряняем в переменной текущий рейтинг
        }
    }
    
    //MARK: TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //3 варианта для выбора действий с картинкой
        if indexPath.row == 0 { //если тапаем по 1 ячейке то включает Alert для добавления картинки
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            
            let camera  = UIAlertAction(title: "Camera", style: .default) {_ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image") //позволяет установить значение любого типа по опред ключу. Меняем иконку
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment") //форматируем текст
            
            let photo = UIAlertAction(title: "Photo", style: .default) {_ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image") // меняем иконку на свою
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment") //форматируем текст
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            //добавляем в наш ALert пункты
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet,animated: true) // выводим Alert
            
        } else {// если тапаем за пределами 1 ячейки то скрываем клавиатуру
            view.endEditing(true)
        }
    }
    // метод записи нового ресторана
    func savePlace() {
        
        var image: UIImage?
        //если изображение было изменено пользователем то присваиваем значение из palceImage иначе присваевам дефолтное изображение
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
        let imageData = image?.pngData() //конвертируем изображение из формата Data в формат image
        
        //инициализируем экземпляр класса
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData,
                            // raiting: Double(raitingControl.raiting))
                             raiting: currentRaiting)
        //сохраняем в БД данные если мы находися в режиме редактирования
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.raiting = newPlace.raiting
            }
        } else {
            StorageManager.saveObject(newPlace) // записываем в БД
        }
    }
    
    //метод вызывается при редактировании заведения
    private func setupEditScreen() {
        if currentPlace != nil { //будет редкатировать только если текущий Place имеет значания. Т.е мы находимся в окне редактирования записи
            
            setupNavigationBar() //вызываем метод для разблокировки кнопок т.к мы находится на экране редактирования записи
            imageIsChanged = true // изобржаение не будет менятся на дефолтное если мы находися в режиме редкатирования 
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }// создаем свойство data и присваиваем ему значание катинки в формате Data. Если это получается то создаем свойство image куда передаем фото
            //передаем данные VC в аутлеты
            placeImage.image = image
            placeImage.contentMode = .scaleToFill //масштабируем картинку под размер imageview
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            //raitingControl.raiting = Int(currentPlace.raiting)
            cosmosView.rating = currentPlace.raiting
        }
    }
    
    private func setupNavigationBar() {
        
        //удаляем заголовок кнопки возврата на предидущий экран при редактировании
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil //убираем кнопку Cancel
        title = currentPlace?.name//передаем в заголовок текущее наименование заведения
        saveButton.isEnabled = true//включаем кнопку Save т.к данные у нас по умолчанию всегда заполнены
    }
    
    // Action выгрузки из памяти экрана NewPlace и выхода по нажати кнопи Cancel
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

// MARK: TextField Delegate

extension NewPlaceViewController: UITextFieldDelegate {
    
    //Скрывае клавиатуру по нажанию на Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // проверяем пустоли ли поле palceName и сключаем или выключаем кнопку Save
    @objc private func teхtFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

//MARK: Work with Image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) { //проверяем доступность источника изображения
            let imagePicker = UIImagePickerController() // создаем экземляр UIImagePickerController
            imagePicker.delegate = self //назначаем делегата
            imagePicker.allowsEditing = true //позволяет пользователю редактировать изображение (масштаб и тд)
            imagePicker.sourceType = source // выбираем источник
            present(imagePicker, animated: true) //выводим
        }
    }
    //присваиваем аутлету ImageOfPlace изображение
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage// берем значение по ключу и привелие его к типу UIImage. Данное значение повзоляет присвоить отредактированное пользователем изображение
        placeImage.contentMode = .scaleAspectFill // масштабирует изображение по размеру UIImage
        placeImage.clipsToBounds = true // обрезаем изображение по границе
        
        imageIsChanged = true
        dismiss(animated: true)
    }
}
