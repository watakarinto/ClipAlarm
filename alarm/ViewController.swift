//
//  ViewController.swift
//  alarm
//
//  Created by Rei on 2021/09/26.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    // AppDelegateの読み込み
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    // UserDefalutsに独自クラスのインスタンスを保存できるように変換
    let UDChange = UDController()
    let UDParam = UDController()
    // アラームデータ格納変数
    var alarmData: [AlarmInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // アプリがActiveになるときに投げられる
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.didBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        // 紐付け
        tableView.dataSource = self
        tableView.delegate = self
        // データがないセルを非表示
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // データの読み込み
        alarmData = UDChange.readAlarm()
        // appDelegateの変数を初期化
        appDelegate.musicState = false
        appDelegate.musicUrl = nil
        appDelegate.musicTitle = nil
        appDelegate.indexPathRow = -1
        // 再表示
        tableView.reloadData()
    }
    
    @objc func didBecomeActiveNotification() {
        // アラーム停止メッセージを出すかどうか
        if(appDelegate.musicState) {
            // アラートコントローラーを作成する。
            let alert = UIAlertController(title: "アラートを停止", message: "おはようございます。\n今日の天気は晴れです!(適当)", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.appDelegate.musicPlayer.stop()
                self.appDelegate.musicState = false
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            alarmData = UDChange.readAlarm() // データの読み込み
            tableView.reloadData() // 再表示
        }
    }
       
}



// セクションや行の値
extension ViewController: UITableViewDataSource {
    // 行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmData.count
    }
    // 行に表示するcellを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath)
        // Tag番号でUILabelインスタンスの生成
        let alarmLabel = cell.viewWithTag(1) as! UILabel
        alarmLabel.text = alarmData[indexPath.row].getTime()
        
        // UISwitchをcellのアクセサリービューに追加
        let switchView = UISwitch()
        cell.accessoryView = switchView
        switchView.isOn = alarmData[indexPath.row].getState()
        // スイッチのタグにindexPath.rowを入れる
        switchView.tag = indexPath.row
        // スイッチが押された時の処理
        switchView.addTarget(self, action: #selector(uiSwitchChange(_:)), for: UIControl.Event.valueChanged)
        
        return cell
    }
    
    // UISwitchの処理
    @objc func uiSwitchChange(_ sender: UISwitch) {
        if(sender.isOn) {
            // 通知オン
            alarmData[sender.tag].setState(true)
            UDChange.saveAlarm(alarmData)
        } else {
            // 通知オフ
            alarmData[sender.tag].setState(false)
            UDChange.saveAlarm(alarmData)
        }
    }
}



// テーブルのイベント
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cellがタップされた時の処理
        // indexPath.rowを保存
        appDelegate.indexPathRow = indexPath.row
    }
    
    // cellをスライドした時の処理
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 削除処理
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") {
            (action, view, completionHandler) in
            // 削除処理
            // 通知を削除する
            self.alarmData[indexPath.row].deleteNotice()
            // 配列から削除
            self.alarmData.remove(at : indexPath.row)
            self.UDChange.saveAlarm(self.alarmData)
            // viewに反映
            tableView.reloadData()
            // 実行結果に関わらず記述
            completionHandler(true)
        }
        deleteAction.backgroundColor = UIColor.red // 背景色
        
        // 定義したアクションをセット
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
}

