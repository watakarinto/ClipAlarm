//
//  UserDefaultsChange.swift
//  alarm
//
//  Created by Rei on 2021/09/28.
//

import Foundation


class UDController {
    // Int型データの保存
    func saveDataInt(_ data: Int, _ dataName: String) {
        UserDefaults.standard.set(data, forKey: dataName)
    }
    // Int型データの読み込み
    func readDataInt(_ dataName: String) -> Int {
        return UserDefaults.standard.integer(forKey: dataName)
    }
    // エンコード
    func saveAlarm(_ data: [AlarmInfo]) {
        let saveData = data
        if let encodedValue = try? JSONEncoder().encode(saveData) {
            UserDefaults.standard.set(encodedValue, forKey: "alarm")
        }
    }
    // デコード
    func readAlarm() -> [AlarmInfo] {
        var result: [AlarmInfo] = []
        if let savedData = UserDefaults.standard.data(forKey: "alarm") {
            if let value = try? JSONDecoder().decode([AlarmInfo].self, from: savedData) {
                result = value
            }
        } else {
            print("値がない")
        }
        return result
    }
     
}
