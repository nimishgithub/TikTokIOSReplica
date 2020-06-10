//
//  PlayerScreenVC.swift

import UIKit
import AVFoundation

class PlayerScreenVC: BaseUIViewController {
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playerView: UIView! // player container
    
    var avPlayer: AVPlayer?

    var viewModel: PlayerScreenVM!
 
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopVideo()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as AnyObject? === avPlayer, let avPlayer = self.avPlayer {
            if keyPath == "status" {
                if avPlayer.status == .readyToPlay {
                    avPlayer.play()
                }
            } else if keyPath == "timeControlStatus" {
                if avPlayer.timeControlStatus == .playing {
                    imageView.alpha = 0
                } else {
                    imageView.alpha = 1
                }
            }
        }
    }

    //    MARK: Private Methods
    private func initialSetup() {
//        self.scrollView.delegate = self
        self.scrollView.contentInsetAdjustmentBehavior = .never
        let thumbnail = viewModel.video.media.thumbnail({ [weak self] thumbnail in
            self?.imageView.image = thumbnail
        })
        self.imageView.image = thumbnail
        self.imageView.frame = view.frame
    }
    
  
    private func playVideo() {
        let url = URL(string: viewModel.video.media.encodeURL)!
        let avPlayer = AVPlayer(playerItem: AVPlayerItem(url: url))
        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = playerView.bounds
        avPlayerLayer.videoGravity = .resizeAspectFill
        playerView.layer.insertSublayer(avPlayerLayer, at: 0)
        avPlayer.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        avPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        self.avPlayer = avPlayer
        
    }
    
    private func stopVideo() {
        avPlayer?.pause()
        playerView.layer.sublayers?.removeAll(where: {$0.isKind(of: AVPlayerLayer.self)})
        avPlayer?.removeObserver(self, forKeyPath: "status")
        avPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
        avPlayer = nil
    }
    
    
}
