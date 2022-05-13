//
//  LaunchScreenScene.swift
//  Match Da Drop
//
//  Created by Bryan Arambula on 4/28/22.
//

import Foundation
import SpriteKit
import CoreData

class LaunchScreenScene: SKScene{
    
    
    let physicsBodyCategories = PhysicBodyCategories()
    let startButton = SKSpriteNode(imageNamed: "Match'em button")
    
    override func didMove(to view: SKView) {
        
        
        let backGroundMusic = SKAudioNode(fileNamed: "mixkit-deep-urban")
        self.addChild(backGroundMusic)

        self.backgroundColor = .white
        
        let logo = SKTexture(imageNamed: "Match'em logo")
        let poligonialLogo = SKSpriteNode(texture: logo)
        poligonialLogo.physicsBody = SKPhysicsBody(circleOfRadius: max(poligonialLogo.size.width / 2, poligonialLogo.size.height / 2))
        poligonialLogo.position = CGPoint(x: self.size.width/2, y: self.size.height*0.6)
        poligonialLogo.setScale(3)
        poligonialLogo.zPosition = 1
        poligonialLogo.physicsBody?.categoryBitMask = physicsBodyCategories.logo
        poligonialLogo.physicsBody?.collisionBitMask = physicsBodyCategories.figures
        poligonialLogo.physicsBody?.contactTestBitMask = physicsBodyCategories.figures
        poligonialLogo.physicsBody?.isDynamic = false
        poligonialLogo.physicsBody?.affectedByGravity = false
        self.addChild(poligonialLogo)
        
        startButton.zPosition = 1
        startButton.position = CGPoint(x: self.size.width/2, y: self.size.height*0.2)
        startButton.setScale(1)
        startButton.physicsBody = SKPhysicsBody(rectangleOf: startButton.size)
        startButton.physicsBody?.categoryBitMask = physicsBodyCategories.logo
        startButton.physicsBody?.collisionBitMask = physicsBodyCategories.figures
        startButton.physicsBody?.contactTestBitMask = physicsBodyCategories.figures
        startButton.physicsBody?.isDynamic = false
        startButton.physicsBody?.affectedByGravity = false
        self.addChild(startButton)
 
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint.zero, radius: 15, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        let smallBall = SKShapeNode(path: path.cgPath)
        smallBall.position = CGPoint(x: self.size.width/2, y: self.size.height*0.4)
        smallBall.fillColor = .red
        smallBall.strokeColor = .red
        smallBall.lineWidth = 1
        smallBall.glowWidth = 0.5
        smallBall.zPosition = 1
        smallBall.setScale(2)
        smallBall.physicsBody = SKPhysicsBody(rectangleOf: smallBall.frame.size)
        smallBall.physicsBody?.categoryBitMask = physicsBodyCategories.figures
        smallBall.physicsBody?.collisionBitMask = physicsBodyCategories.logo
        smallBall.physicsBody?.contactTestBitMask = physicsBodyCategories.logo
        smallBall.physicsBody?.isDynamic = true
        smallBall.physicsBody?.restitution = 1
        self.addChild(smallBall)
        
        let defaults = UserDefaults.standard

        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")

        if scores > highScoreNumber{
            highScoreNumber = scores
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        let highScoreLabel = SKLabelNode()
        highScoreLabel.text = "Best Score: \(highScoreNumber)"
        highScoreLabel.zPosition = 2
        highScoreLabel.fontSize = 55
        highScoreLabel.fontName = "ChalkboardSE-Bold"
        highScoreLabel.fontColor = .black
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.1)
        self.addChild(highScoreLabel)
        
        let highScoreImageLabel = SKSpriteNode(imageNamed: "Match'em score Image")
        highScoreImageLabel.zPosition = 1
        highScoreImageLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.1)
        highScoreImageLabel.setScale(1)
        self.addChild(highScoreImageLabel)
        
        
      dropFigures()
        

    }
    
    func vibration(){
        let vibration = UISelectionFeedbackGenerator()
        vibration.selectionChanged()
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
    
    func dropFigures(){
        
        let drop = SKAction.run(spawnFigures)
        let wait = SKAction.wait(forDuration: 0.2)
        let sequence = SKAction.sequence([drop,wait])
        let loop = SKAction.repeatForever(sequence)
        self.run(loop)
    }
    
    func spawnFigures(){
        
        let randomXStart = random(min: self.frame.minX, max: self.frame.maxX)
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.1)
        let endPoint = CGPoint(x: randomXStart, y: -self.size.height * 0.2)
        
        switch arc4random_uniform(6) {
        case 1:
            triangle(color: .link, name: "link triangle", startPosition: startPoint, endPosition: endPoint)
        case 2:
            square(color: .yellow, name: "yellow square", startPosition: startPoint, endPosition: endPoint)
        case 3:
            circle(name: "red circle", color: .red, startPosition: startPoint, endPositon: endPoint)
        case 4:
            triangle(color: .link, name: "link triangle", startPosition: startPoint, endPosition: endPoint)
        case 5:
            square(color: .green, name: "green square", startPosition: startPoint, endPosition: endPoint)
        default:
            return
        }
    }
    
    
    
    func random()->CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min:CGFloat, max:CGFloat)->CGFloat{
        return random() * (max - min) + min
    }
    
    func square(color:UIColor, name:String, startPosition:CGPoint, endPosition:CGPoint){
        
        let square = SKSpriteNode(color: color, size: CGSize(width: 50, height: 50))
        square.zPosition = 1
        square.position = startPosition
        square.name = name
        square.setScale(2)
        square.physicsBody = SKPhysicsBody(rectangleOf: square.size)
        square.physicsBody?.isDynamic = true
        square.physicsBody?.restitution = 1
        square.physicsBody?.categoryBitMask = physicsBodyCategories.figures
        square.physicsBody?.collisionBitMask = physicsBodyCategories.logo
        square.physicsBody?.contactTestBitMask = physicsBodyCategories.logo
        self.addChild(square)
        
        if square.position == endPosition{
            square.removeFromParent()
        }
        
    }
    
    func circle(name:String, color:UIColor, startPosition: CGPoint, endPositon:CGPoint){
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint.zero, radius: 15, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        let cirlce = SKShapeNode(path: path.cgPath)
        cirlce.lineWidth = 1
        cirlce.name = name
        cirlce.position = startPosition
        cirlce.fillColor = color
        cirlce.strokeColor = color
        cirlce.glowWidth = 0.5
        cirlce.zPosition = 1
        cirlce.setScale(3)
        cirlce.physicsBody = SKPhysicsBody(rectangleOf: cirlce.frame.size)
        cirlce.physicsBody?.isDynamic = true
        cirlce.physicsBody?.friction = 0
        cirlce.physicsBody?.restitution = 1
        cirlce.physicsBody?.categoryBitMask = physicsBodyCategories.figures
        cirlce.physicsBody?.collisionBitMask = physicsBodyCategories.logo
        cirlce.physicsBody?.contactTestBitMask = physicsBodyCategories.logo
        self.addChild(cirlce)
        
        if cirlce.position == endPositon{
            cirlce.removeFromParent()
        }
    }
    
    func triangle(color:UIColor, name:String, startPosition:CGPoint, endPosition:CGPoint){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 50.0))
        path.addLine(to: CGPoint(x: 50.0, y: -36.0))
        path.addLine(to: CGPoint(x: -50.0, y: -36.0))
        path.addLine(to: CGPoint(x: 0, y: 50))
        
        let triangle = SKShapeNode(path: path.cgPath)
        triangle.setScale(1.5)
        triangle.position = startPosition
        triangle.fillColor = color
        triangle.strokeColor = color
        triangle.physicsBody?.restitution = 1
        triangle.lineWidth = 1
        triangle.glowWidth = 0.5
        triangle.zPosition = 1
        triangle.name = name
        triangle.physicsBody = SKPhysicsBody(rectangleOf: triangle.frame.size)
        triangle.physicsBody?.categoryBitMask = physicsBodyCategories.figures
        triangle.physicsBody?.collisionBitMask = physicsBodyCategories.logo
        triangle.physicsBody?.contactTestBitMask = physicsBodyCategories.logo
        triangle.physicsBody?.isDynamic = true
        self.addChild(triangle)
        
        if triangle.position == endPosition{
            triangle.removeFromParent()
            self.removeFromParent()
        }
        



    }
    
    
    struct PhysicBodyCategories{
        
        let figures: UInt32 = 0x1 << 0
        let logo: UInt32 = 0x1 << 1
        
    }
    
    
    
}
