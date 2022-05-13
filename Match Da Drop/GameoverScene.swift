//
//  GameoverViewController.swift
//  Match Da Drop
//
//  Created by Bryan Arambula on 4/26/22.
//

import UIKit
import SpriteKit

class GameoverScene: SKScene{
    
    let restartLabel = SKLabelNode()
    let startButton = SKSpriteNode(imageNamed: "Match'em button")
    let physicsBodyCategory = PhysicsBodyCategory()
    
    let reviewService = ReviewService.shared

    
    override func didMove(to view: SKView) {
        
        let deadLine = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: deadLine) {
            [weak self] in
            self?.reviewService.requestReview()
        }
        
        let backGroundMusic = SKAction.playSoundFileNamed("mixkit-player-losing-or-failing-2042", waitForCompletion: false)
        self.run(backGroundMusic)
        
        self.backgroundColor = .white
        
        bottomFloor()
        triangleDrop(color: .green, position: CGPoint(x: self.size.width/2, y: self.size.height/2))
        circleDrop(color: .link, position: CGPoint(x: self.size.width*0.4, y: self.size.height/2))
        squareDrop(color: .red, position: CGPoint(x: self.size.width*0.3, y: self.size.height/2))
        circleDrop(color: .yellow, position: CGPoint(x: self.size.width*0.2, y: self.size.height/2))
        triangleDrop(color: .purple, position: CGPoint(x: self.size.width*0.1, y: self.size.height/2))
        circleDrop(color: .red, position: CGPoint(x: self.size.width*0, y: self.size.height/2))
        squareDrop(color: .orange, position: CGPoint(x: self.size.width*0.6, y: self.size.height/2))
        triangleDrop(color: .red, position: CGPoint(x: self.size.width*0.7, y: self.size.height/2))
        circleDrop(color: .systemTeal, position: CGPoint(x: self.size.width*0.8, y: self.size.height/2))
        squareDrop(color: .yellow, position: CGPoint(x: self.size.width*0.9, y: self.size.height/2))
        circleDrop(color: .green, position: CGPoint(x: self.size.width*1, y: self.size.height/2))
        let gameOverImage = SKSpriteNode(imageNamed: "GameOver")
        gameOverImage.zPosition = 1
        gameOverImage.position = CGPoint(x: self.size.width/2, y: self.size.height*0.6)
        gameOverImage.setScale(3)
        self.addChild(gameOverImage)
        
        let yourScoreLabel = SKLabelNode()
        yourScoreLabel.fontName = "ChalkboardSE-Bold"
        yourScoreLabel.text = "Your Score: \(scores)"
        yourScoreLabel.fontColor = .black
        yourScoreLabel.fontSize = 55
        yourScoreLabel.zPosition = 2
        yourScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        self.addChild(yourScoreLabel)
        
        let yourScoreImage = SKSpriteNode(imageNamed: "Green Restart")
        yourScoreImage.zPosition = 1
        yourScoreImage.setScale(1)
        yourScoreImage.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        self.addChild(yourScoreImage)
        
        let defaults = UserDefaults.standard
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        if scores > highScoreNumber{
            highScoreNumber = scores
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        let highScoreLabel = SKLabelNode()
        highScoreLabel.text = "Best Score: \(highScoreNumber)"
        highScoreLabel.fontColor = .black
        highScoreLabel.fontName = "ChalkboardSE-Bold"
        highScoreLabel.fontSize = 55
        highScoreLabel.zPosition = 2
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.2)
        self.addChild(highScoreLabel)
        
        let highScoreImage = SKSpriteNode(imageNamed: "Match'em score Image")
        highScoreImage.zPosition = 1
        highScoreImage.setScale(1)
        highScoreImage.position = CGPoint(x: self.size.width/2, y: self.size.height*0.2)
        self.addChild(highScoreImage)
        
        startButton.zPosition = 1
        startButton.position = CGPoint(x: self.size.width/2, y: self.size.height*0.4)
        startButton.setScale(1)
        self.addChild(startButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let currentTouch = touch.location(in: self)
            
            if startButton.contains(currentTouch){
                let changeScene = GameScene(size: self.size)
                changeScene.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 1)
                let vibration = SKAction.run(vibration)
                self.run(vibration)
                self.view!.presentScene(changeScene, transition: transition)
            }
        }
    }
    
    func vibration(){
        let touchHeptic = UISelectionFeedbackGenerator()
        touchHeptic.selectionChanged()
    }
    
    func squareDrop(color:UIColor, position:CGPoint){
        let square = SKSpriteNode(color: color, size: CGSize(width: 50, height: 50))
        square.zPosition = 3
        square.position = position
        square.setScale(2)
        square.physicsBody = SKPhysicsBody(rectangleOf: square.size)
        square.physicsBody?.restitution = 0.7
        square.physicsBody?.categoryBitMask = physicsBodyCategory.dropedElement
        square.physicsBody?.contactTestBitMask = physicsBodyCategory.floorElement
        square.physicsBody?.collisionBitMask = physicsBodyCategory.floorElement
        self.addChild(square)
    }
    
    func triangleDrop(color:UIColor, position:CGPoint){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 50.0))
        path.addLine(to: CGPoint(x: 50.0, y: -36.0))
        path.addLine(to: CGPoint(x: -50.0, y: -36.0))
        path.addLine(to: CGPoint(x: 0, y: 50.0))
        
        let triangle = SKShapeNode(path: path.cgPath)
        triangle.fillColor = color
        triangle.strokeColor = color
        triangle.lineWidth = 1
        triangle.glowWidth = 0.5
        triangle.zPosition = 3
        triangle.setScale(2)
        triangle.position = position
        triangle.physicsBody = SKPhysicsBody(rectangleOf: triangle.frame.size)
        triangle.physicsBody?.affectedByGravity = true
        triangle.physicsBody?.isDynamic = true
        triangle.physicsBody?.restitution = 0.7
        triangle.physicsBody?.categoryBitMask = physicsBodyCategory.dropedElement
        triangle.physicsBody?.contactTestBitMask = physicsBodyCategory.floorElement
        triangle.physicsBody?.collisionBitMask = physicsBodyCategory.floorElement
        self.addChild(triangle)

    }
    
    func circleDrop(color:UIColor, position:CGPoint){
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint.zero, radius: 15, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        let circle = SKShapeNode(path: path.cgPath)
        circle.fillColor = color
        circle.strokeColor = color
        circle.lineWidth = 1
        circle.glowWidth = 0.5
        circle.zPosition = 3
        circle.position = position
        circle.setScale(3)
        circle.physicsBody = SKPhysicsBody(rectangleOf: circle.frame.size)
        circle.physicsBody?.isDynamic = true
        circle.physicsBody?.restitution = 0.7
        circle.physicsBody?.categoryBitMask = physicsBodyCategory.dropedElement
        circle.physicsBody?.contactTestBitMask = physicsBodyCategory.floorElement
        circle.physicsBody?.collisionBitMask = physicsBodyCategory.floorElement
        self.addChild(circle)
    }
    
    func bottomFloor(){
        let floor = SKSpriteNode(color: .black, size: CGSize(width: self.frame.width, height: 100))
        floor.zPosition = 3
        floor.position = CGPoint(x: self.size.width/2, y: self.frame.minY)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.affectedByGravity = false
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = physicsBodyCategory.floorElement
        floor.physicsBody?.contactTestBitMask = physicsBodyCategory.dropedElement
        floor.physicsBody?.collisionBitMask = physicsBodyCategory.dropedElement
        self.addChild(floor)
    }
    

}


struct PhysicsBodyCategory{
    let dropedElement: UInt32 = 0x1 << 0
    let floorElement:UInt32 = 0x1 << 1
}
