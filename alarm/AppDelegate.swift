//
//  AppDelegate.swift
//  alarm
//
//  Created by Rei on 2021/09/26.
//

import UIKit
import AVFoundation


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // ファイル間のデータ共有変数
    var musicState: Bool! // アラームが鳴っているかどうか
    var musicUrl: URL! // ミュージックの場所
    var musicTitle: String! // ミュージックのタイトル
    var musicStart: Double! // ミュージックの再生位置
    var musicEnd: Double! // ミュージックの終了位置
    var musicPlayer: AVAudioPlayer!
    var indexPathRow: Int!

    // AppDelegateで使う変数
    var BGProcess: AVAudioPlayer!
    var BGProcessState = false
    var BGTimer: Timer!
    var start: Double! // 再生位置
    var end: Double! // 終了位置


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // 通知の許可を依頼
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            // [.alert, .badge, .sound]はアラート、バッジ、サウンドに対しての許可
            if granted {
                // 「許可」が押された場合
                UNUserNotificationCenter.current().delegate = self
            } else {
                // 「許可しない」が押された場合
                print("通知が許可されていません")
            }
        }
        
        // バックグラウンドでのミュージック再生できるように設定
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        
        return true
        
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
    
    
    
    // バックグラウンド移行時の処理
    func applicationWillResignActive(_ application: UIApplication) {
        // アラームのデータを読み込む
        let UDChange = UDController()
        let alarmData = UDChange.readAlarm()
        
        // オンになっているアラームがあればバックグラウンド処理をする
        for date in alarmData {
            if(date.getState()) {
                let  url = URL(fileURLWithPath: Bundle.main.path(forResource: "BGProcess", ofType: "mp3")!)
                do {
                    BGProcess = try AVAudioPlayer(contentsOf: url)
                    BGProcess.numberOfLoops = -1 // 無限にループさせる
                    BGProcess.play()
                    BGProcessState = true

                    BGTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkAlarm), userInfo: nil, repeats: true)
                } catch {
                    BGProcess = nil
                    print("BGProcess:エラー")
                }
                break
            }
        }
    }
    
    
    // フォアグラウンドになった時の処理
    func applicationDidBecomeActive(_ application: UIApplication) {
        if(BGProcessState) {
            BGProcess.stop()
            // タイマーを停止する
            if let workingTimer = BGTimer {
                workingTimer.invalidate()
            }
        }
        if(musicState) {
            musicPlayer.stop()
        }
    }
    
    
    
    
    @objc func checkAlarm() {
        // アラームのデータを読み込む
        let UDChange = UDController()
        let alarmData = UDChange.readAlarm()
        // アラーム発生時の時刻を取得
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm"
        let nowTime = formatter.string(from: Date())

        // メソッドが実行された時のアラームを探しその曲の場所を格納
        for date in alarmData {
            if (date.getTime() == nowTime) && date.getState() {
                // 再生位置を取得
                start = date.getMusicStart()
                end = date.getMusicEnd()
                // スイッチをオフにする
                date.setState(false)
                UDChange.saveAlarm(alarmData)
                
                do {
                    musicPlayer = try AVAudioPlayer(contentsOf: date.getURL())
                    //曲の再生
                    musicPlayer.numberOfLoops = -1 // 無限にループさせる
                    musicPlayer.currentTime = start
                    musicPlayer.play()
                    musicState = true
                } catch {
                    musicPlayer = nil
                    print("エラー：曲の取得に失敗")
                }
            }
        }
        
        // ミュージックの終端になったら先頭からループ
        if(musicState && end <= musicPlayer.currentTime) {
            musicPlayer.stop()
            musicPlayer.numberOfLoops = -1 // 無限にループさせる
            musicPlayer.currentTime = start
            musicPlayer.play()
        }
    
    }
}




// 通知を受け取ったときの処理
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // アプリ起動時も通知を行う
        if #available(iOS 14.0, *) {
            completionHandler([[.banner, .list, .sound]])
        } else {
            completionHandler([[.alert, .sound]])
        }
    }
}

