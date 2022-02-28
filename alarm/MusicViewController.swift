//
//  musicViewController.swift
//  alarm
//
//  Created by Rei on 2021/10/17.
//

import UIKit
import MediaPlayer
import AVFoundation
import WARangeSlider

class MusicViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    // スライダーの作成
    var musicSlider: UISlider!
    var rangeSlider: RangeSlider!
    // ラベルの作成
    var musicSliderLowLabel: UILabel!
    var musicSliderUppLabel: UILabel!
//    var rangeSliderLowLabel: UILabel!
//    var rangeSliderUppLabel: UILabel!
    
    // AppDelegateの読み込み
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let UDChange = UDController()
    var alarmData: [AlarmInfo] = []
    var indexPathRow: Int!
    // MediaPlayerのインスタンスを作成
    var musicPlayer: AVAudioPlayer!
    var musicUrl: URL! // ミュージックの場所を格納
    var musicTitle: String! // ミュージック名を格納
    var pushButtonState = false // ミュージックの再生状況

    override func viewDidLoad() {
        super.viewDidLoad()
        // データの読み込み
        alarmData = UDChange.readAlarm()
        indexPathRow = appDelegate.indexPathRow
        // 画面の大きさ
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        // ナビゲーションバーのボタンを設定
        let backButton = UIBarButtonItem(title: "戻る", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.goBack))
        let saveButton = UIBarButtonItem(title: "完了", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.save))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = saveButton

        // ミュージックのアートワーク
        imageView.frame(forAlignmentRect: CGRect(x: 30, y: (viewHeight/2)-(viewWidth-60), width: viewWidth-60, height: viewWidth-60))
        // ミュージックスライダー
        musicSlider = UISlider(frame: CGRect(x: 30, y: viewHeight/2+(viewHeight/5)-60, width: viewWidth-60, height: 20))
        musicSlider.isEnabled = false
        musicSlider.layer.masksToBounds = false
        musicSlider.addTarget(self, action: #selector(musicSliderValueChaged), for: .valueChanged)
        view.addSubview(musicSlider)
        // ミュージックスライダーの時間ラベル(Low)
        musicSliderLowLabel = UILabel()
        musicSliderLowLabel.frame = CGRect(x: 30, y: viewHeight/2+(viewHeight/5)-40, width: 50, height: 20)
        musicSliderLowLabel.text = "0:00"
        musicSliderLowLabel.font = UIFont.systemFont(ofSize: 10)
        view.addSubview(musicSliderLowLabel)
        // ミュージックスライダーの時間ラベル(Upp)
        musicSliderUppLabel = UILabel()
        musicSliderUppLabel.frame = CGRect(x: viewWidth-50, y: viewHeight/2+(viewHeight/5)-40, width: 50, height: 20)
        musicSliderUppLabel.text = "0:00"
        musicSliderUppLabel.font = UIFont.systemFont(ofSize: 10)
        view.addSubview(musicSliderUppLabel)
        // レンジスライダー
        rangeSlider = RangeSlider(frame: CGRect(x: 30, y: viewHeight/2+(viewHeight/5), width: viewWidth-60, height: 20))
        rangeSlider.isEnabled = false
        rangeSlider.trackHighlightTintColor = UIColor.systemBlue.withAlphaComponent(0.2) // ツマミの間のトラックの色
        rangeSlider.thumbTintColor = UIColor.white // ツマミの色
        rangeSlider.curvaceousness = 0.2 // ツマミの丸さ具合
        rangeSlider.thumbBorderWidth = 4.0 // ツマミの枠の大きさ
        rangeSlider.thumbBorderColor = UIColor.gray // ツマミの枠の色
        rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
        view.addSubview(rangeSlider)
        // 再生ボタン
        playButton.frame = CGRect(x: viewWidth/2-50, y: viewHeight/2+(viewHeight/4), width: 100, height: 100)
        playButton.isEnabled = false
        playButton.setImage(UIImage(named: "playButton"), for: .normal)
        
        // 新規でないならミュージックを取得
        if(indexPathRow >= 0) {
            // スライダーの初期位置を読み込む
            rangeSlider.lowerValue = alarmData[indexPathRow].getMusicStart()
            rangeSlider.upperValue = alarmData[indexPathRow].getMusicEnd()
            // ミュージックの場所とタイトルを読み込む
            musicUrl = alarmData[indexPathRow].getURL()
            musicTitle = alarmData[indexPathRow].getMusicTitle()
            // 再生を有効化
            setMusic(musicUrl)
        }
    }

    
    // 再生を有効化するメソッド
    func setMusic(_ url: URL) {
        // スライダーを有効化
        musicSlider.isEnabled = true
        rangeSlider.isEnabled = true
        // スライダーの色
        rangeSlider.trackHighlightTintColor = UIColor.systemBlue
        rangeSlider.thumbTintColor = UIColor.white
        // ボタンの有効化
        playButton.isEnabled = true
        // ミュージックをセット
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicSlider.maximumValue = Float(musicPlayer.duration)
            rangeSlider.maximumValue = musicPlayer.duration
            rangeSlider.upperValue = musicPlayer.duration
            // スライダーラベルの時間
            musicSliderUppLabel.text = String(Int(musicPlayer.duration/60)) + ":" + String(Int(musicPlayer.duration.truncatingRemainder(dividingBy: 60)))
        } catch {
            musicPlayer = nil
            print("エラー：ミュージックの取得に失敗")
        }
        // ミュージックスライダーの更新イベント
        var timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(musicSliderValueAutoChaged), userInfo: nil, repeats: true)
    }
    
    // ミュージックスライダーの手動更新
    @objc func musicSliderValueChaged() {
        musicPlayer.currentTime = TimeInterval(musicSlider.value)
        // lowラベルの値を更新
        let lowMin = Int(musicPlayer.currentTime/60)
        let lowSec = Int(musicPlayer.currentTime.truncatingRemainder(dividingBy: 60))
        musicSliderLowLabel.text = String(lowMin) + (lowSec<10 ? ":0" : ":") + String(lowSec)
        // uppラベルの値を更新
        let uppValue = musicPlayer.duration - musicPlayer.currentTime
        let uppMin = Int(uppValue/60)
        let uppSec = Int(uppValue.truncatingRemainder(dividingBy: 60))
        musicSliderUppLabel.text = String(uppMin) + (uppSec<10 ? ":0" : ":") + String(uppSec)
    }
    // ミュージックスライダーの自動更新
    @objc func musicSliderValueAutoChaged() {
        let low = floor(Float(rangeSlider.lowerValue))
        let upp = floor(Float(rangeSlider.upperValue))
        let MS = floor(musicSlider.value)
        if(MS > upp) {
            pushButtonState = false
            pushPlay()
            musicSlider.value = upp
            musicPlayer.currentTime = rangeSlider.upperValue
        } else if(MS < low) {
            musicSlider.value = low
            musicPlayer.currentTime = rangeSlider.lowerValue
        } else {
            musicSlider.value = Float(musicPlayer.currentTime)
        }
        // lowラベルの値を更新
        let lowMin = Int(musicPlayer.currentTime/60)
        let lowSec = Int(musicPlayer.currentTime.truncatingRemainder(dividingBy: 60))
        musicSliderLowLabel.text = String(lowMin) + (lowSec<10 ? ":0" : ":") + String(lowSec)
        // uppラベルの値を更新
        let uppValue = musicPlayer.duration - musicPlayer.currentTime
        let uppMin = Int(uppValue/60)
        let uppSec = Int(uppValue.truncatingRemainder(dividingBy: 60))
        musicSliderUppLabel.text = String(uppMin) + (uppSec<10 ? ":0" : ":") + String(uppSec)
    }
    // レンジスライダーの更新
    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) -> Void {
        let low = rangeSlider.lowerValue
        let upp = rangeSlider.upperValue
        if(low > Double(musicSlider.value)) {
            musicPlayer.currentTime = low
            musicSliderValueAutoChaged()
        }
        if(upp < Double(musicSlider.value)) {
            musicPlayer.currentTime = upp
            musicSliderValueAutoChaged()
        }
    }

    // 戻るボタンの処理
    @objc func goBack() {
        if(pushButtonState) {
            pushButtonState = false
            pushPlay()
        }
        // 戻る処理
        self.navigationController?.popViewController(animated: true)
    }
    // 完了ボタンの処理
    @objc func save() {
        if(pushButtonState) {
            pushButtonState = false
            pushPlay()
        }
        // AppDelegateに保存
        appDelegate.musicUrl = musicUrl // ミュージックの場所
        appDelegate.musicTitle = musicTitle // ミュージックタイトル
        appDelegate.musicStart = rangeSlider.lowerValue // ミュージックの再生位置
        appDelegate.musicEnd = rangeSlider.upperValue // ミュージックの終了位置
        
        if(appDelegate.musicUrl != nil) {
            let nav = self.navigationController
            // 一つ前のEditViewControllerを取得する
            let editView = nav?.viewControllers[(nav?.viewControllers.count)!-2] as! EditViewController
            // 値を渡す
            editView.saveMusicInfo()
        }
        // 戻る処理
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // ミュージックの選択画面を出す
    @IBAction func selectSongs(_ sender: UIButton) {
        let controller = MPMediaPickerController(mediaTypes: .music)
        // 複数選択を不可にする
        controller.allowsPickingMultipleItems = false
        controller.popoverPresentationController?.sourceView = sender
        // デリゲートの設定
        controller.delegate = self
        // 表示
        present(controller, animated: true)
        // ボタンを戻す
        playButton.setImage(UIImage(named: "startButton"), for: .normal)
    }
    // ミュージック選択完了時に呼び出される
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
                     didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        // ミュージック情報を取得
        let musicInfo = mediaItemCollection.items
        //アートワーク
        let artWork = musicInfo[0].artwork
        // 角丸にする
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.03
        imageView.clipsToBounds = true
        imageView.image = artWork?.image(at: imageView.bounds.size)
        
        musicUrl = musicInfo[0].assetURL
        musicTitle = musicInfo[0].title
        setMusic(musicUrl)
        // 選択画面を閉じる
        mediaPicker.dismiss(animated: true)
//        let musicArtist = musicInfo[0].artist // アーチスト名
//        let albumTitle = musicInfo[0].albumTitle // アルバムタイトル
//        let albunArtist = musicInfo[0].albumArtist // アルバムアーチスト名
    }
    // 選択がキャンセルされた時に呼び出される
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // 選択画面を閉じる
        mediaPicker.dismiss(animated: true)
    }
    

    
    // 再生・停止処理
    func pushPlay() {
        if(pushButtonState) {
            playButton.setImage(UIImage(named: "stopButton"), for: .normal)
            musicPlayer.play()
            pushButtonState = true
        } else {
            playButton.setImage(UIImage(named: "playButton"), for: .normal)
            musicPlayer.stop()
            pushButtonState = false
        }
    }
    
    // 再生ボタンの処理
    @IBAction func playButton(sender: AnyObject) {
        if(pushButtonState) {
            playButton.setImage(UIImage(named: "playButton"), for: .normal)
            musicPlayer.stop()
            pushButtonState = false
        } else {
            playButton.setImage(UIImage(named: "stopButton"), for: .normal)
            musicPlayer.play()
            pushButtonState = true
        }
    }
}

