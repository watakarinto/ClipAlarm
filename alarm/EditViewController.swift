//
//  EditViewController.swift
//  alarm
//
//  Created by Rei on 2021/09/26.
//

import UIKit
import MediaPlayer

class EditViewController: UIViewController {
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var editTableView: UITableView!
    // AppDelegateの読み込み
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let UDChange = UDController()
    let UDParam = UDController()
    var alarmData: [AlarmInfo] = []
    let newAlarm = AlarmInfo() // アラームのインスタンス生成
    var indexPathRow: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 紐付け
        editTableView.dataSource = self
        editTableView.delegate = self
        // データの読み込み
        alarmData = UDChange.readAlarm()
        indexPathRow = appDelegate.indexPathRow
    }
    
    // 画面再表示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 編集から来た場合設定済みの曲を保持
        if(indexPathRow >= 0) {
            timePicker.date =  alarmData[indexPathRow].time
            // 曲の取得
            if(appDelegate.musicTitle == nil) {
                newAlarm.setURL(alarmData[indexPathRow].getURL())
                newAlarm.setMusicTitle(alarmData[indexPathRow].getMusicTitle())
                newAlarm.setMusicStart(alarmData[indexPathRow].getMusicStart())
                newAlarm.setMusicEnd(alarmData[indexPathRow].getMusicEnd())
            } else {
                // appDelegateから読み込み
                newAlarm.setURL(appDelegate.musicUrl)
                newAlarm.setMusicTitle(appDelegate.musicTitle)
            }
        }
        // 再表示
        editTableView.reloadData()
    }
    
    // キャンセルボタンを押した時の処理
    @IBAction func cancelButton(_ sender: Any) {
        // Present Modallyを閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    // 保存ボタンを押した時の処理
    @IBAction func saveButton(_ sender: Any) {
        // アラームの編集から来た場合は一旦削除
        if indexPathRow >= 0 {
            alarmData.remove(at: indexPathRow)
        }
        newAlarm.setTime(timePicker.date)
        var count = 0
        if alarmData.count != 0 {
            // newAlarmの挿入位置を決める
            for i in 0 ..< alarmData.count {
                if newAlarm.time < alarmData[i].time {
                    break
                }
                count += 1
            }
        }
        // 表示順をセット
        newAlarm.setNum(count)
        // アラーム通知をセット
        newAlarm.setNotice()
        // 保存
        alarmData.insert(newAlarm, at: count)
        UDChange.saveAlarm(alarmData)
        // Present Modallyを閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    // ミュージック選択画面から呼び出す
    func saveMusicInfo() {
        newAlarm.setURL(appDelegate.musicUrl)
        newAlarm.setMusicTitle(appDelegate.musicTitle)
        newAlarm.setMusicStart(appDelegate.musicStart)
        newAlarm.setMusicEnd(appDelegate.musicEnd)
    }
}



// セクションや行の値
extension EditViewController: UITableViewDataSource {
    // 行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    // 行に表示するcellを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
        // セルの右側に「>」を設定
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        switch indexPath.row {
        case 0:
            // Tag番号でUILabelインスタンスの生成
            let alarmLabel1 = cell.viewWithTag(1) as! UILabel
            alarmLabel1.text = "アラーム"
            let alarmLabel2 = cell.viewWithTag(2) as! UILabel
            alarmLabel2.textColor = UIColor.systemGray
            alarmLabel2.text = newAlarm.getAlarmName()
            alarmLabel2.lineBreakMode = .byTruncatingTail // 省略形式 「あいうえ..」
        case 1:
            // Tag番号でUILabelインスタンスの生成
            let alarmLabel1 = cell.viewWithTag(1) as! UILabel
            alarmLabel1.text = "サウンド"
            let alarmLabel2 = cell.viewWithTag(2) as! UILabel
            alarmLabel2.textColor = UIColor.systemGray
            alarmLabel2.text = newAlarm.getMusicTitle()
            alarmLabel2.lineBreakMode = .byTruncatingTail // 省略形式 「あいうえ..」
        default:
            print()
        }
        
        return cell
    }
}


// テーブルのイベント
extension EditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cellがタップされた時の処理
        switch indexPath.row {
        case 0:
            print()
        case 1:
            // ミュージック選択画面に遷移
            let selectMusicView = self.storyboard?.instantiateViewController(withIdentifier: "toSelectMusic") as! MusicViewController
                self.navigationController?.pushViewController(selectMusicView, animated: true)
        default:
            print()
//            // アラーム名変更画面に遷移
//            let changeNameView = self.storyboard?.instantiateViewController(withIdentifier: "toChangeName") as! NameViewController
//            self.navigationController?.pushViewController(changeNameView, animated: true)
            
        }
    }
}
