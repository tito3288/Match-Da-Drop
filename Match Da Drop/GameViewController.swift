//
//  GameViewController.swift
//  Match Da Drop
//
//  Created by Bryan Arambula on 4/20/22.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
//            if let scene = SKScene(fileNamed: "GameScene") {
//                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFit
//
//                // Present the scene
//                view.presentScene(scene)
//            }
                        
            let scene = LaunchScreenScene(size: CGSize(width: 1536, height: 2840))
            
            scene.scaleMode = .aspectFit
            
            view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true
            
//            view.showsFPS = true
//            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
