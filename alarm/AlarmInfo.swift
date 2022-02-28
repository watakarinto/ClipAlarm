//
//  alarmInfo.swift
//  alarm
//
//  Created by Rei on 2021/09/27.
//

import Foundation
import UIKit

class AlarmInfo: Codable {
    var time: Date // アラームのセットした時間
    var name: String // アラーム名
    var state: Bool // スイッチの状態
    var num: Int // アラームの表示順
    var url: URL!
    var musicTitle: String // 設定した曲名
    var musicStart: Double!
    var musicEnd: Double!
    
    init() {
        time = Date()
        name = "アラーム"
        state = true
        num = 0
        url = URL(fileURLWithPath: Bundle.main.path(forResource: "alarm01", ofType: "mp3")!)
        musicTitle = "alart01"
        musicStart = 0.0
        musicEnd = 16.0
    }
    
    // 時間のセッター
    func setTime(_ time: Date) {
        self.time = time
    }
    // アラーム名のセッター
    func setAlarmName(_ name: String) {
        self.name = name
    }
    // アラームのスイッチのセッター
    func setState(_ state: Bool) {
        self.state = state
        if(state) {
            if(time < Date()) {
                let formatter = DateFormatter()
                // 設定されていた時間を取得
                formatter.dateFormat = "HH:mm"
                let oldTime = formatter.string(from: time)
                // 現在の日付を取得
                formatter.dateFormat = "yyyy-MM-dd"
                let nowTime = formatter.string(from: Date())
                // 結合
                let newTime = nowTime + " " + oldTime
                // 更新
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                time = formatter.date(from: newTime)!
            }
            setNotice()
        } else {
            deleteNotice()
        }
    }
    // アラームの表示順のセッター
    func setNum(_ num: Int) {
        self.num = num
    }
    // 曲のURLのセッター
    func setURL(_ url: URL) {
        self.url = url
    }
    // 曲名のセッター
    func setMusicTitle(_ musicTitle: String) {
        self.musicTitle = musicTitle
    }
    // ミュージックの再生位置のセッター
    func setMusicStart(_ musicStart: Double) {
        self.musicStart = musicStart
    }
    // ミュージックの終了位置のセッター
    func setMusicEnd(_ musicEnd: Double) {
        self.musicEnd = musicEnd
    }
    // 通知処理のセッター
    func setNotice() {
        // 通知のリクエスト変数
        var request:UNNotificationRequest!
        // 日時を設定
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        // 通知コンテンツの作成
        let content = UNMutableNotificationContent()
        content.title = name
        content.body = getTime()
        // 通知リクエストの作成
        request = UNNotificationRequest.init(
            identifier: "AlarmNotification\(getNum())",
            content: content,
            trigger: trigger
        )
        // 通知リクエストの登録
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
    
    
    
    // 時間のゲッター
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm"
        let result = formatter.string(from: time)
        return result
    }
    // 名前のゲッター
    func getAlarmName() -> String {
        return name
    }
    // アラームのスイッチの状態のゲッター
    func getState() -> Bool {
        return state
    }
    // アラームの表示順のゲッター
    func getNum() -> Int {
        return num
    }
    // 曲のURLのゲッター
    func getURL() -> URL {
        return url
    }
    // 曲名のゲッター
    func getMusicTitle() -> String {
        return musicTitle
    }
    // ミュージックの再生位置のゲッター
    func getMusicStart() -> Double {
        return musicStart
    }
    // ミュージックの終了位置のゲッター
    func getMusicEnd() -> Double {
        return musicEnd
    }
    // 通知の削除処理
    func deleteNotice() {
        let identifiers = ["AlarmNotification\(getNum())"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
