//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Виктор Марусин on 04.05.2020.
//  Copyright © 2020 Виктор Марусин. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

// точка входа в БД
class StorageManager {
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    // метод удаления записи из БД
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
