//
//  ViewController.swift
//  Practise Application
//
//  Created by 葉家均 on 2022/8/20.
//

import UIKit
import MediaPlayer
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var imgMusic: UIImageView!
    @IBOutlet weak var txtMusicName: UILabel!
    @IBOutlet weak var musicProgress: UISlider!
    @IBOutlet weak var txtAuthor: UILabel!
    @IBOutlet weak var volumSlider: UISlider!
    @IBOutlet weak var txtMusicTime: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnBackward: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var txtProgressTime: UILabel!
    private var progressTimer: Timer?
    
    private let musicTitle = "Square Fate"
    private let musicAuthor = "三月のパンタシア"
    
    private var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        addActinsToControlsCenter()
    }
    
    private func addActinsToControlsCenter() {
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(toggleStop))
        
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(self, action: #selector(toggleStop))
        
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = true
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget(handler: { sender in
            let event = sender as! MPChangePlaybackPositionCommandEvent
            self.audioPlayer.currentTime = event.positionTime
            self.musicProgress.value = Float((self.audioPlayer.currentTime * 100.0 / self.audioPlayer.duration))
            
            let minutes = Int(self.audioPlayer.currentTime / 60)
            let second = String.init(format: "%02d", Int(Int(self.audioPlayer.currentTime) - minutes * 60))
            self.txtProgressTime.text = "\(minutes):\(second)"
            
            if self.audioPlayer.currentTime == 0 {
                self.btnPlay.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                self.progressTimer?.invalidate()
            }
            return .success
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let alertController = UIAlertController(title: "Loading...", message: nil, preferredStyle: .alert)
        present(alertController, animated: true)
        
        downloadMusic(completion: {
            self.setUI(data: $0)
            alertController.dismiss(animated: true)
        })
    }
    
    private func downloadMusic(completion: @escaping (Data) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let url = URL(string: "https://pythonserver.yjj940604.repl.co/test/demo.mp3")!
            let data = (try? Data(contentsOf: url)) ?? Data()
            DispatchQueue.main.sync {
                completion(data)
            }
        }
    }
    
    private func setUI(data: Data) {
        // music image
        imgMusic.layer.borderColor = UIColor.black.cgColor
        imgMusic.layer.borderWidth = 1
        imgMusic.image = UIImage(named: "demo.jpeg")
        
        do {
            audioPlayer = try AVAudioPlayer.init(data: data)
            audioPlayer.play()
            
            updateMediaInfo()
        } catch {
            print("\(error)")
        }
        
        // volume slider
        volumSlider.value = 20
        audioPlayer.volume = 20
        
        // total time text
        let minutes = Int(audioPlayer.duration / 60)
        let second = Int(Int(audioPlayer.duration) - minutes * 60)
        txtMusicTime.text = "\(minutes):\(second)"
        
        // progress bar
        musicProgress.isUserInteractionEnabled = true
        progressTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(progressTimerEvent), userInfo: nil, repeats: true)
        
        txtMusicName.text = musicTitle
        txtAuthor.text = musicAuthor
    }
    
    private func updateMediaInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle:musicTitle,
            MPMediaItemPropertyArtist: musicAuthor,
            MPMediaItemPropertyRating: audioPlayer.rate,
            MPMediaItemPropertyPlaybackDuration: audioPlayer.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: audioPlayer.currentTime,
            MPMediaItemPropertyArtwork: MPMediaItemArtwork.init(image: UIImage(named: "demo.jpeg") ?? UIImage())
        ]
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        exit(0)
    }
    
    @IBAction func btnStopClick(_ sender: Any) {
        btnPlay.setBackgroundImage(UIImage(systemName: !audioPlayer.isPlaying ? "pause" : "play.circle.fill"), for: .normal)
        
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            progressTimer?.invalidate()
            progressTimer = nil
            updateMediaInfo()
        } else {
            updateMediaInfo()
            audioPlayer.play()
        }
        
        if progressTimer == nil {
            progressTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(progressTimerEvent), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func toggleStop() -> MPRemoteCommandHandlerStatus {
        btnStopClick(0)
        return .success
    }
    
    @IBAction func musicProgressChange(_ sender: Any) {
        audioPlayer.currentTime = (Double(musicProgress.value) * audioPlayer.duration / 100)
        updateMediaInfo()
    }
    
    @IBAction func volumeSlicerChange(_ sender: Any) {
        audioPlayer.volume = volumSlider.value
    }
    
    @objc private func progressTimerEvent() {
        musicProgress.value = Float((audioPlayer.currentTime * 100.0 / audioPlayer.duration))
        
        let minutes = Int(audioPlayer.currentTime / 60)
        let second = String.init(format: "%02d", Int(Int(audioPlayer.currentTime) - minutes * 60))
        txtProgressTime.text = "\(minutes):\(second)"
        
        if audioPlayer.currentTime == 0 {
            btnPlay.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            progressTimer?.invalidate()
        }
    }
    
    @IBAction func btnForwardClick(_ sender: Any) {
        
    }
    
    @IBAction func btnBackwardClick(_ sender: Any) {
        performSegue(withIdentifier: "goCompass", sender: sender)
    }
}

