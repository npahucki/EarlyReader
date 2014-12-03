//
//  RewardScreenViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 12/3/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import AVFoundation


class RewardScreenViewController: UIViewController,AVAudioPlayerDelegate {

    @IBOutlet weak var animalImageView: UIImageView!
    @IBOutlet weak var rewardPhraseLabel: UILabel!

    private var audioPlayer : AVAudioPlayer!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cheerSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("applause-01", ofType: "mp3")!)
        audioPlayer = AVAudioPlayer(contentsOfURL: cheerSound, error: nil)
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        let rewardImageName = "RewardScreen\(Int(arc4random_uniform(11) + 1))"
        animalImageView.image = UIImage(named: rewardImageName)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
   }

    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        audioPlayer.play()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        self.parentViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion:nil)
    }
    

 
    
    
    
}
