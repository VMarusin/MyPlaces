//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 28.04.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import RealmSwift

//описываем модель ресторана (наследуемся от класса Object для работы Realm
class Place: Object {
    
    //все поля опциональны кроме name т.к оно обязательно
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?) { //назначенный инициализатор что бы инциализировать все свойства предоставленне классом
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
    }
}
