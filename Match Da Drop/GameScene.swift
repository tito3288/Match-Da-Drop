//
//  GameScene.swift
//  Match Da Drop
//
//  Created by Bryan Arambula on 4/20/22.
//

import SpriteKit
import GameplayKit
import AudioToolbox
import AVFoundation

var scores = 0
var difficultyLevel = 0


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    struct PhysicsbodyCategories{
        let none: UInt32 = 0x1 << 0
        let player: UInt32 = 0x1 << 1
        let enemy: UInt32 = 0x1 << 2
        let point:UInt32 = 0x1 << 3
        let obstacle:UInt32 = 0x1 << 4
        let bottom: UInt32 = 0x1 << 5
        let wallObstacle: UInt32 = 0x1 << 6
        let getLife: UInt32 = 0x1 << 7
    }
    
    let physicsbodyCategories = PhysicsbodyCategories()
    var enemyTimer = Timer()
    var pointTimer = Timer()
    var lives = 10
    let difficultyLevelLabel = SKLabelNode()
    let lifeLabel = SKLabelNode()
    let scoreLabel = SKLabelNode()
    var lifeTimer = Timer()
    
    let getPointSound = SKAction.playSoundFileNamed("game-point-click", waitForCompletion: false)
    let loseLifeSound = SKAction.playSoundFileNamed("lose-life", waitForCompletion: false)
    let gainLifeSound = SKAction.playSoundFileNamed("mixkit-gain-life", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
                
        scores = 0
        difficultyLevel = 0
        
        let backGroundMusic = SKAudioNode(fileNamed: "mixkit-deep-urban")
        self.addChild(backGroundMusic)
        
        self.physicsWorld.contactDelegate = self
        
        self.backgroundColor = .white
        
        label(label: scoreLabel, text: "Score: 0", position: CGPoint(x: self.size.width*0.15, y: self.size.height*0.85))
        
        label(label: lifeLabel, text: "Lives: 10", position: CGPoint(x: self.size.width*0.85, y: self.size.height*0.9))
        
        label(label: difficultyLevelLabel, text: "Level: 1", position: CGPoint(x: self.size.width*0.15, y: self.size.height*0.9))
        
        let leftWall = SKSpriteNode(color: UIColor.gray, size: CGSize(width: 50, height: self.frame.size.height*1.2))
        leftWall.position = CGPoint(x: self.frame.minX, y: self.size.height/2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        leftWall.physicsBody!.isDynamic = false
        leftWall.physicsBody?.categoryBitMask = physicsbodyCategories.wallObstacle
        leftWall.physicsBody?.collisionBitMask = physicsbodyCategories.point
        leftWall.physicsBody?.collisionBitMask = physicsbodyCategories.point
        self.addChild(leftWall)
        
        let rightWall = SKSpriteNode(color: .gray, size: CGSize(width: 50, height: self.frame.size.height*1.2))
        rightWall.position = CGPoint(x: self.frame.maxX , y: self.size.height/2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.categoryBitMask = physicsbodyCategories.wallObstacle
        rightWall.physicsBody?.collisionBitMask = physicsbodyCategories.point
        rightWall.physicsBody?.contactTestBitMask = physicsbodyCategories.point
        self.addChild(rightWall)
        
        let bottomWall = SKSpriteNode(color: .white, size: CGSize(width: self.frame.size.width, height: 100 ))
        bottomWall.position = CGPoint(x: self.size.width/2, y: self.frame.minY)
        self.addChild(bottomWall)
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.physicsBody?.affectedByGravity = false
        
        bottomWall.physicsBody?.categoryBitMask = physicsbodyCategories.bottom
        bottomWall.physicsBody?.collisionBitMask = physicsbodyCategories.point
        bottomWall.physicsBody?.contactTestBitMask = physicsbodyCategories.point

        enemyDifficultyLevel()
        spawnPoint()
        
    }
    
    func spawnlifeRandom(time:TimeInterval){
        
        let spawn = SKAction.run(spawnLife)
        let waitDuration = SKAction.wait(forDuration: time)
        let sequence = SKAction.sequence([waitDuration,spawn])
        let loop = SKAction.repeatForever(sequence)
        self.run(loop)
    }
    
    func spawnLife(){
        
        let startRandomX = random(min: self.frame.minX, max: self.frame.maxX)
        let endRandomX = random(min: self.frame.minX, max: self.frame.maxX)
        
        let startPoint = CGPoint(x: startRandomX, y: self.size.height*1.1)
        let endPoint = CGPoint(x: endRandomX, y: -self.size.height*0.2)
        
        lifeElement(startPosition: startPoint, endPosition: endPoint)
    }
    
    func spawnPoint(){
        
        let spawn = SKAction.run(self.spawnRandomPoint)
        let wait = SKAction.wait(forDuration: 2)
        let sequence = SKAction.sequence([wait,spawn])
        let loop = SKAction.repeatForever(sequence)
        self.run(loop)
        
    }

    func enemyDifficultyLevel(){
        //Player/Obstacles added or removed at levels
        difficultyLevel = difficultyLevel + 1
        
        difficultyLevelLabel.text = "Level: \(difficultyLevel)"
        
        var levelDuration = TimeInterval()
        
        switch difficultyLevel {
        case 1:
            levelDuration = 1.5
            circlePlayer(name: "player", color: .red, position: CGPoint(x: self.size.width/2, y: self.size.height*0.1))
        case 2:
            levelDuration = 1.4
            self.enumerateChildNodes(withName: "player") { player, stop in
                player.removeFromParent()
                player.removeAllActions()
                
                self.trianglePlayer(name: "player", position: player.position, color: .green)
            }
            
            imageObstacle(name: "circle1", position: CGPoint(x: self.size.width/2, y: self.size.height/2))//Obstacle
            
        case 3:
            levelDuration = 1.3
            
            spawnlifeRandom(time: 10)

            self.enumerateChildNodes(withName: "player") { player, stop in
                player.removeFromParent()
                player.removeAllActions()
                
                self.circlePlayer(name: "player", color: .orange, position: player.position)
            }
            
            imageObstacle(name: "circle2", position: CGPoint(x: self.size.width*0.3, y: self.size.height*0.7))
            imageObstacle(name: "circle3", position: CGPoint(x: self.size.width*0.7, y: self.size.height*0.7))//obstacles
        case 4:
            levelDuration = 1
            self.enumerateChildNodes(withName: "player") { player, stop in
                player.removeFromParent()
                player.removeAllActions()
                
                self.squarePlayer(color: .yellow, name: "player", position: player.position)
            }
            self.enumerateChildNodes(withName: "circle1") { circle, stop in
                circle.removeFromParent()
            }
            self.enumerateChildNodes(withName: "circle2") { circle, stop in
                circle.removeFromParent()
            }
            self.enumerateChildNodes(withName: "circle3") { circle, stop in
                circle.removeFromParent()
            }
            
            imageObstacle(name: "circle4", position: CGPoint(x: self.size.width/2, y: self.size.height*0.8))
            imageObstacle(name: "circle5", position: CGPoint(x: self.size.width/2, y: self.size.height*0.6))
            imageObstacle(name: "circle6", position: CGPoint(x: self.size.width/2, y: self.size.height*0.4))

        case 5:
            levelDuration = 0.8
            self.enumerateChildNodes(withName: "player") { player, stop in
                player.removeFromParent()
                player.removeAllActions()
                
                self.trianglePlayer(name: "player", position: player.position, color: .purple)

            }
            self.enumerateChildNodes(withName: "circle1") { circle, stop in
                circle.removeFromParent()
            }
            self.enumerateChildNodes(withName: "circle2") { circle, stop in
                circle.removeFromParent()
            }
            self.enumerateChildNodes(withName: "circle3") { circle, stop in
                circle.removeFromParent()
            }
            self.enumerateChildNodes(withName: "circle4") { circle, stop in
                circle.removeFromParent()
            }
            self.enumerateChildNodes(withName: "circle5") { circle, stop in
                circle.removeFromParent()
            }
            self.enumerateChildNodes(withName: "circle6") { circle, stop in
                circle.removeFromParent()
            }
            
            imageObstacle(name: "circle7", position: CGPoint(x: self.size.width*0.3, y: self.size.height*0.7))
            imageObstacle(name: "circle8", position: CGPoint(x: self.size.width*0.7, y: self.size.height*0.7))
            imageObstacle(name: "circle9", position: CGPoint(x: self.size.width/2, y: self.size.height/2))
            imageObstacle(name: "circle10", position: CGPoint(x: self.size.width*0.3, y: self.size.height*0.3))
            imageObstacle(name: "cirlce11", position: CGPoint(x: self.size.width*0.7, y: self.size.height*0.3))
            
        default:
            return
        }
        
        let spawn = SKAction.run(spawnRandomenemy)
        let wait = SKAction.wait(forDuration: levelDuration)
        let sequence = SKAction.sequence([spawn,wait])
        let loop = SKAction.repeatForever(sequence)
        self.run(loop)
    }
    
    func spawnRandomPoint(){
        //Point elements added at levels
        let randomXPosition = random(min: self.frame.minX, max: self.frame.maxX)
        let startPoint = CGPoint(x: randomXPosition, y: self.size.height * 1.1)
        let endPoint = CGPoint(x: randomXPosition, y: -self.size.height * 0.2)
        
        
        circlePoint(name: "point", color: .red, startPosition: startPoint, endPositon: endPoint, size: 3)
        
        if difficultyLevel == 2{
            self.enumerateChildNodes(withName: "point") { point, stop in
                point.removeFromParent()
                point.removeAllActions()
                //Maybe add scale down to transition player smoothly 
            }
            
            trianglePoint(name: "point2", color: .green, startPosition: startPoint, endPositon: endPoint, size: 2)
            
        }
        if difficultyLevel == 3{
            self.enumerateChildNodes(withName: "point2") { point, stop in
                point.removeFromParent()
                point.removeAllActions()
            }
            self.enumerateChildNodes(withName: "point") { point, stop in
                point.removeFromParent()
                point.removeAllActions()
            }
            
            circlePoint(name: "point3", color: .orange, startPosition: startPoint, endPositon: endPoint, size: 1.5)
        }
        
        if difficultyLevel == 4{
            self.enumerateChildNodes(withName: "point") { point, stop in
                point.removeFromParent()
                point.removeAllActions()
            }
            self.enumerateChildNodes(withName: "point2") { point, stop in
                point.removeFromParent()
                point.removeAllActions()
            }
            self.enumerateChildNodes(withName: "point3") { point, stop in
                point.removeFromParent()
                point.removeAllActions()
            }
            
            squarePoint(color: .yellow, name: "point4", startPosition: startPoint, endPosition: endPoint, size: 2)
            
            
        }
        
        if difficultyLevel == 5{
            self.enumerateChildNodes(withName: "point1") { point, stop in
                point.removeFromParent()
                point.removeAllActions()
            }
            self.enumerateChildNodes(withName: "point2") { point, stop in
                point.removeFromParent()
                point.removeAllActions()
            }
            self.enumerateChildNodes(withName: "point3") { point, stop in
                point.removeFromParent()
                point.removeAllActions()
            }
            self.enumerateChildNodes(withName: "point4") { point, stop in
                point.removeFromParent()
                point.removeAllActions()
            }
            
            trianglePoint(name: "point5", color: .purple, startPosition: startPoint, endPositon: endPoint, size: 2)
        }
        
        
    }
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    func spawnRandomenemy(){
        
        let randomXStart = random(min: self.frame.minX, max: self.frame.maxX)
        let randomXEnd = random(min: self.frame.minX, max: self.frame.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        //Enemies
        if difficultyLevel == 1{
            switch arc4random_uniform(5) {
            case 0:
                triangleEnemy(name: "green triangle", color: .green, startPosition: startPoint, endPositon: endPoint, size: 2)
            case 1:
                triangleEnemy(name: "orange triangle", color: .orange, startPosition: startPoint, endPositon: endPoint, size: 2)
            case 2:
                squareEnemy(name: "purple square", color: .purple, startPosition: startPoint, endPosition: endPoint, size: 2)
            case 3:
                squareEnemy(name: "red square", color: .red, startPosition: startPoint, endPosition: endPoint, size: 2)
                
            default:
                circleEnemy(name: "link circle", color: .link, startPosition: startPoint, endPositon: endPoint, size: 3)
            }
        }
        //Enemies
        if difficultyLevel == 2{
            switch arc4random_uniform(5) {
            case 0:
                self.enumerateChildNodes(withName: "green triangle") { orangeTriangle, stop in
                    orangeTriangle.removeFromParent()
                    //                    orangeTriangle.removeAllActions()
                }
                
                triangleEnemy(name: "link triangle", color: .link, startPosition: startPoint, endPositon: endPoint, size: 2)
                
            case 1:
                self.enumerateChildNodes(withName: "orange triangle") { orangeTriangle, stop in
                    orangeTriangle.removeFromParent()
                    //                    orangeTriangle.removeAllActions()
                }
                
                triangleEnemy(name: "red triangle", color: .red, startPosition: startPoint, endPositon: endPoint, size: 2)
            case 2:
                self.enumerateChildNodes(withName: "purple square") { purpleSquare, stop in
                    purpleSquare.removeFromParent()
                    //                    purpleSquare.removeAllActions()
                }
                
                squareEnemy(name: "brown square", color: .brown, startPosition: startPoint, endPosition: endPoint, size: 2)
            case 3:
                self.enumerateChildNodes(withName: "red square") { redSquare, stop in
                    redSquare.removeFromParent()
                    //                    redSquare.removeAllActions()
                }
                squareEnemy(name: "green square", color: .green, startPosition: startPoint, endPosition: endPoint, size: 2)
            default:
                self.enumerateChildNodes(withName: "link circle") { linkCircle, stop in
                    linkCircle.removeFromParent()
                }
                
                circleEnemy(name: "purple circle", color: .purple, startPosition: startPoint, endPositon: endPoint, size: 3)
                
            }
        }
        
        if difficultyLevel == 3{
            switch arc4random_uniform(5) {
            case 0:
                self.enumerateChildNodes(withName: "link triangle") { linkTriangle, stop in
                    linkTriangle.removeFromParent()
                    //                    linkTriangle.removeAllActions()
                }
                triangleEnemy(name: "brown triangle", color: .brown, startPosition: startPoint, endPositon: endPoint, size: 2.5)
            case 1:
                self.enumerateChildNodes(withName: "red triangle") { redTriangle, stop in
                    redTriangle.removeFromParent()
                }
                triangleEnemy(name: "yellow triangle", color: .yellow, startPosition: startPoint, endPositon: endPoint, size: 2.5)
            case 2:
                self.enumerateChildNodes(withName: "brown square") { brownSquare, stop in
                    brownSquare.removeFromParent()
                }
                squareEnemy(name: "purple square2", color: .purple, startPosition: startPoint, endPosition: endPoint, size: 2.5)
            case 3:
                self.enumerateChildNodes(withName: "green square") { greenSquare, stop in
                    greenSquare.removeFromParent()
                }
                squareEnemy(name: "red square2", color: .red, startPosition: startPoint, endPosition: endPoint, size: 2.5)
            default:
                self.enumerateChildNodes(withName: "purple circle") { purpleCircle, stop in
                    purpleCircle.removeFromParent()
                }
                
                circleEnemy(name: "link circle", color: .black, startPosition: startPoint, endPositon: endPoint, size: 3)
                
            }
        }
        
        if difficultyLevel == 4{
            switch arc4random_uniform(5) {
            case 0:
                self.enumerateChildNodes(withName: "brown triangle") { brownTriangle, stop in
                    brownTriangle.removeFromParent()
                }
                triangleEnemy(name: "light gray triangle", color: .lightGray, startPosition: startPoint, endPositon: endPoint, size: 2.5)
            case 1:
                self.enumerateChildNodes(withName: "red triangle") { redTriangle, stop in
                    redTriangle.removeFromParent()
                }
                triangleEnemy(name: "blue triangle", color: .blue, startPosition: startPoint, endPositon: endPoint, size: 2.5)
            case 2:
                self.enumerateChildNodes(withName: "purple square2") { purpleSqaure, stop in
                    purpleSqaure.removeFromParent()
                }
                squareEnemy(name: "black square", color: .black, startPosition: startPoint, endPosition: endPoint, size: 2)
            case 3:
                self.enumerateChildNodes(withName: "red square2") { redSquare, stop in
                    redSquare.removeFromParent()
                }
                squareEnemy(name: "teal square", color: .systemTeal, startPosition: startPoint, endPosition: endPoint, size: 2)
                
            default:
                self.enumerateChildNodes(withName: "link circle") { linkCircle, stop in
                    linkCircle.removeFromParent()
                }
                circleEnemy(name: "yellow circle", color: .yellow, startPosition: startPoint, endPositon: endPoint, size: 3)
                
            }
        }
        
        if difficultyLevel == 5{
            switch arc4random_uniform(5) {
            case 0:
                self.enumerateChildNodes(withName: "light gray triangle") { brownTriangle, stop in
                    brownTriangle.removeFromParent()
                }
                triangleEnemy(name: "blue triangle2", color: .blue, startPosition: startPoint, endPositon: endPoint, size: 2.5)
            case 1:
                self.enumerateChildNodes(withName: "blue triangle") { redTriangle, stop in
                    redTriangle.removeFromParent()
                }
                triangleEnemy(name: "black triangle", color: .black, startPosition: startPoint, endPositon: endPoint, size: 2.5)
            case 2:
                self.enumerateChildNodes(withName: "black square") { purpleSqaure, stop in
                    purpleSqaure.removeFromParent()
                }
                squareEnemy(name: "orange square", color: .orange, startPosition: startPoint, endPosition: endPoint, size: 2)
            case 3:
                self.enumerateChildNodes(withName: "teal square2") { redSquare, stop in
                    redSquare.removeFromParent()
                }
                squareEnemy(name: "gray square", color: .gray, startPosition: startPoint, endPosition: endPoint, size: 2)
                
            default:
                self.enumerateChildNodes(withName: "yellow circle") { linkCircle, stop in
                    linkCircle.removeFromParent()
                }
                circleEnemy(name: "teal circle", color: .systemTeal, startPosition: startPoint, endPositon: endPoint, size: 3)
                
            
            
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let dragged = touch.location(in: self)
            
            self.enumerateChildNodes(withName: "player") { player, stop in
                player.run(SKAction.moveTo(x: dragged.x, duration: 0.1))
                
            }
        }
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1: SKPhysicsBody
        var body2: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == physicsbodyCategories.player && body2.categoryBitMask == physicsbodyCategories.getLife{
         
            gainLife()
            gainLifeAnimation(animationPosition: CGPoint(x: self.size.width*0.85, y: self.size.height*0.9))
            body2.node?.removeFromParent()
        }
        
        if body1.categoryBitMask == physicsbodyCategories.player && body2.categoryBitMask == physicsbodyCategories.enemy{
            
            loseLive()
            body2.node?.removeFromParent()
            
        }
        
        if body1.categoryBitMask == physicsbodyCategories.player && body2.categoryBitMask == physicsbodyCategories.point{
            
            addScore()
            body2.node?.removeFromParent()
        }
        
        if body1.categoryBitMask == physicsbodyCategories.point && body2.categoryBitMask == physicsbodyCategories.obstacle{
            
            let scaleUp = SKAction.scale(to: 1, duration: 0.2)
            let scaledown = SKAction.scale(to: 0.8, duration: 0.2)
            let sequence = SKAction.sequence([scaleUp,scaledown])
            body2.node?.run(sequence)
 
        //separate walls from obstacle physicbody so that they dont scale up and down too
        }
        
        if body1.categoryBitMask == physicsbodyCategories.point && body2.categoryBitMask == physicsbodyCategories.bottom{
            
            loseLive()
            body1.node?.removeFromParent()
        }
        
        if body1.categoryBitMask == physicsbodyCategories.point && body2.categoryBitMask == physicsbodyCategories.wallObstacle{
            
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1, duration: 0.2)
            let sequence = SKAction.sequence([scaleUp,scaleDown])
            body2.node?.run(sequence)
            
        }
        
    }
    
    func changeScene(){
        
        let sceneToChange = GameoverScene(size: self.size)
        sceneToChange.scaleMode = self.scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToChange, transition: transition)
        
    }
    
    func gameOver(){
        
        let sceneChange = SKAction.run(changeScene)
        let waitChangeScene = SKAction.wait(forDuration: 1)
        let changeSequence = SKAction.sequence([waitChangeScene,sceneChange])
        self.run(changeSequence)
        
    }
    
    func gainLife(){
        lives = lives + 1
        lifeLabel.text = "Lives: \(lives)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let vibration = SKAction.run(vibration)
        let scaleSequence = SKAction.sequence([vibration,gainLifeSound,scaleUp,scaleDown])
        lifeLabel.run(scaleSequence)
        
        if lives == 10{
            lives = 10
            lifeLabel.text = "Lives: 10"
        }
    }
    
    func loseLive(){
        lives = lives - 1
        lifeLabel.text = "Lives: \(lives)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([loseLifeSound,scaleUp,scaleDown])
        lifeLabel.run(scaleSequence)
        
        if lives <= 0{
            lives = 0
            lifeLabel.text = "Lives: 0"
            gameOver()
        }
        
    }
    
    func vibration(){
        let vibration = UIImpactFeedbackGenerator(style: .heavy)
        vibration.prepare()
        vibration.impactOccurred()
        
    }
    
    func addScore(){
        scores = scores + 1
        scoreLabel.text = "Score: \(scores)"
        let vibration = SKAction.run(vibration)
        let sequence = SKAction.sequence([vibration,getPointSound])
        scoreLabel.run(sequence)
        
        if scores == 10 || scores == 20 || scores == 30 || scores == 40 || scores == 50{
            enemyDifficultyLevel()
        }

    }
    
    func squareEnemy(name:String, color:UIColor, startPosition: CGPoint, endPosition:CGPoint, size:CGFloat){
        
        let squareEnemy = SKSpriteNode(color: color, size: CGSize(width: 50, height: 50))
        squareEnemy.zPosition = 1
        squareEnemy.name = name
        squareEnemy.setScale(size)
        squareEnemy.position = startPosition
        squareEnemy.physicsBody = SKPhysicsBody(rectangleOf: squareEnemy.size)
        squareEnemy.physicsBody?.isDynamic = true
        squareEnemy.physicsBody?.categoryBitMask = physicsbodyCategories.enemy
        squareEnemy.physicsBody?.collisionBitMask = physicsbodyCategories.none
        squareEnemy.physicsBody?.contactTestBitMask = physicsbodyCategories.player
        self.addChild(squareEnemy)
        
        let spawn = SKAction.move(to: endPosition, duration: 1)
        let delete = SKAction.removeFromParent()
        let sequence = SKAction.sequence([spawn,delete])
        squareEnemy.run(sequence)
    }
    
    func circleEnemy(name:String, color:UIColor, startPosition: CGPoint, endPositon:CGPoint, size: CGFloat){
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint.zero, radius: 15, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        let circleEnemy = SKShapeNode(path: path.cgPath)
        circleEnemy.fillColor = color
        circleEnemy.name  = name
        circleEnemy.lineWidth = 1
        circleEnemy.strokeColor = color
        circleEnemy.zPosition = 1
        circleEnemy.setScale(size)
        circleEnemy.position = startPosition
        circleEnemy.physicsBody = SKPhysicsBody(rectangleOf: circleEnemy.frame.size)
        circleEnemy.physicsBody?.categoryBitMask = physicsbodyCategories.enemy
        circleEnemy.physicsBody?.collisionBitMask = physicsbodyCategories.none
        circleEnemy.physicsBody?.contactTestBitMask = physicsbodyCategories.player | physicsbodyCategories.obstacle
        circleEnemy.physicsBody?.isDynamic = true
        self.addChild(circleEnemy)
        
        let spawn = SKAction.move(to: endPositon, duration: 1)
        let delete = SKAction.removeFromParent()
        let sequnce = SKAction.sequence([spawn,delete])
        circleEnemy.run(sequnce)
    }
    
    func triangleEnemy(name:String, color:UIColor, startPosition: CGPoint, endPositon:CGPoint, size: CGFloat){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 50.0))
        path.addLine(to: CGPoint(x: 50.0, y: -36.0))
        path.addLine(to: CGPoint(x: -50.0, y: -36.0))
        path.addLine(to: CGPoint(x: 0, y: 50.0))
        
        let triangleEnemy = SKShapeNode(path: path.cgPath)
        triangleEnemy.fillColor = color
        triangleEnemy.name = name
        triangleEnemy.strokeColor = color
        triangleEnemy.glowWidth = 0.5
        triangleEnemy.lineWidth = 1
        triangleEnemy.position = startPosition
        triangleEnemy.zPosition = 1
        triangleEnemy.setScale(size)
        triangleEnemy.physicsBody = SKPhysicsBody(rectangleOf: triangleEnemy.frame.size)
        triangleEnemy.physicsBody?.isDynamic = true
        triangleEnemy.physicsBody?.categoryBitMask = physicsbodyCategories.enemy
        triangleEnemy.physicsBody?.collisionBitMask = physicsbodyCategories.none
        triangleEnemy.physicsBody?.contactTestBitMask = physicsbodyCategories.player
        self.addChild(triangleEnemy)
        
        let spawn = SKAction.move(to: endPositon, duration: 1)
        let delete = SKAction.removeFromParent()
        let sequence = SKAction.sequence([spawn,delete])
        triangleEnemy.run(sequence)
        
    }
    
    func squarePoint(color:UIColor, name:String, startPosition:CGPoint, endPosition:CGPoint, size:CGFloat){
        
        let squarePoint = SKSpriteNode(color: color, size: CGSize(width: 50, height: 50))
        squarePoint.zPosition = 1
        squarePoint.position = startPosition
        squarePoint.name = name
        squarePoint.setScale(2)
        squarePoint.physicsBody = SKPhysicsBody(rectangleOf: squarePoint.size)
        squarePoint.physicsBody?.isDynamic = true
        squarePoint.physicsBody?.restitution = 1
        squarePoint.physicsBody?.categoryBitMask = physicsbodyCategories.point
        squarePoint.physicsBody?.collisionBitMask = physicsbodyCategories.obstacle | physicsbodyCategories.bottom | physicsbodyCategories.wallObstacle
        squarePoint.physicsBody?.contactTestBitMask = physicsbodyCategories.player | physicsbodyCategories.obstacle | physicsbodyCategories.wallObstacle
        self.addChild(squarePoint)
        
        if squarePoint.position == endPosition{
            squarePoint.removeFromParent()
        }
        
    }
    
    
    func circlePoint(name:String, color:UIColor, startPosition: CGPoint, endPositon:CGPoint, size:CGFloat){
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint.zero, radius: 15, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        let circlePoint = SKShapeNode(path: path.cgPath)
        circlePoint.lineWidth = 1
        circlePoint.name = name
        circlePoint.position = startPosition
        circlePoint.fillColor = color
        circlePoint.strokeColor = color
        circlePoint.glowWidth = 0.5
        circlePoint.zPosition = 1
        circlePoint.setScale(3)
        circlePoint.physicsBody = SKPhysicsBody(rectangleOf: circlePoint.frame.size)
        circlePoint.physicsBody?.isDynamic = true
        circlePoint.physicsBody?.friction = 0
        circlePoint.physicsBody?.restitution = 1
        circlePoint.physicsBody?.categoryBitMask = physicsbodyCategories.point
        circlePoint.physicsBody?.collisionBitMask = physicsbodyCategories.obstacle | physicsbodyCategories.bottom | physicsbodyCategories.wallObstacle
        circlePoint.physicsBody?.contactTestBitMask = physicsbodyCategories.player | physicsbodyCategories.obstacle | physicsbodyCategories.wallObstacle
        self.addChild(circlePoint)
        
        if circlePoint.position == endPositon{
            circlePoint.removeFromParent()
        }
    }
    
    func trianglePoint(name:String, color:UIColor, startPosition: CGPoint, endPositon:CGPoint, size:CGFloat){
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 50.0))
        path.addLine(to: CGPoint(x: 50.0, y: -36.0))
        path.addLine(to: CGPoint(x: -50.0, y: -36.0))
        path.addLine(to: CGPoint(x: 0, y: 50.0))
        
        let trianglePoint = SKShapeNode(path: path.cgPath)
        trianglePoint.lineWidth = 1
        trianglePoint.name = name
        trianglePoint.position = startPosition
        trianglePoint.fillColor = color
        trianglePoint.strokeColor = color
        trianglePoint.glowWidth = 0.5
        trianglePoint.zPosition = 1
        trianglePoint.physicsBody?.restitution = 1
        trianglePoint.setScale(1.5)
        trianglePoint.physicsBody = SKPhysicsBody(rectangleOf: trianglePoint.frame.size)
        trianglePoint.physicsBody?.isDynamic = true
        trianglePoint.physicsBody?.friction = 0
        trianglePoint.physicsBody?.restitution = 1
        trianglePoint.physicsBody?.categoryBitMask = physicsbodyCategories.point
        trianglePoint.physicsBody?.collisionBitMask = physicsbodyCategories.obstacle | physicsbodyCategories.bottom | physicsbodyCategories.wallObstacle
        trianglePoint.physicsBody?.contactTestBitMask = physicsbodyCategories.player | physicsbodyCategories.obstacle | physicsbodyCategories.wallObstacle
        self.addChild(trianglePoint)
        
        if trianglePoint.position == endPositon{
            trianglePoint.removeFromParent()
        }
    }
    
    func squarePlayer(color:UIColor, name:String, position:CGPoint){
        
       let squarePlayer = SKSpriteNode(color: color, size: CGSize(width: 50, height: 50))
        squarePlayer.zPosition = 1
        squarePlayer.position = position
        squarePlayer.name = name
        squarePlayer.setScale(2)
        squarePlayer.physicsBody = SKPhysicsBody(rectangleOf: squarePlayer.size)
        squarePlayer.physicsBody?.isDynamic = false
        squarePlayer.physicsBody?.affectedByGravity = false
        squarePlayer.physicsBody?.categoryBitMask = physicsbodyCategories.player
        squarePlayer.physicsBody?.collisionBitMask = physicsbodyCategories.none
        squarePlayer.physicsBody?.contactTestBitMask = physicsbodyCategories.point | physicsbodyCategories.getLife 
        self.addChild(squarePlayer)
        
        let scaleUp = SKAction.scale(to: 4, duration: 0.2)
        let scaleDown = SKAction.scale(to: 2, duration: 0.2)
        let sequence = SKAction.sequence([scaleUp,scaleDown])
        squarePlayer.run(sequence)

        
    
    }
    
    func trianglePlayer(name:String, position:CGPoint, color:UIColor){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 50.0))
        path.addLine(to: CGPoint(x: 50.0, y: -36.0))
        path.addLine(to: CGPoint(x: -50.0, y: -36.0))
        path.addLine(to: CGPoint(x: 0, y: 50.0))
        
        let trianglePlayer = SKShapeNode(path: path.cgPath)
        trianglePlayer.fillColor = color
        trianglePlayer.name = name
        trianglePlayer.strokeColor = color
        trianglePlayer.lineWidth = 1
        trianglePlayer.glowWidth = 0.5
        trianglePlayer.position = position
        trianglePlayer.zPosition = 1
        trianglePlayer.setScale(1.5)
        trianglePlayer.physicsBody = SKPhysicsBody(rectangleOf: trianglePlayer.frame.size)
        trianglePlayer.physicsBody?.isDynamic = false
        trianglePlayer.physicsBody?.affectedByGravity = false
        trianglePlayer.physicsBody?.categoryBitMask = physicsbodyCategories.player
        trianglePlayer.physicsBody?.contactTestBitMask = physicsbodyCategories.point | physicsbodyCategories.getLife
        trianglePlayer.physicsBody?.collisionBitMask = physicsbodyCategories.none
        self.addChild(trianglePlayer)
        
        let scaleUp = SKAction.scale(to: 3, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.5, duration: 0.2)
        let sequence = SKAction.sequence([scaleUp,scaleDown])
        trianglePlayer.run(sequence)
        
        
    }
    
    func circlePlayer(name:String, color:UIColor , position: CGPoint){
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint.zero, radius: 15, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        let circlePlayer = SKShapeNode(path: path.cgPath)
        
        circlePlayer.zPosition = 1
        circlePlayer.setScale(4)
        circlePlayer.name = name
        circlePlayer.lineWidth = 1
        circlePlayer.fillColor = color
        circlePlayer.strokeColor = color
        circlePlayer.glowWidth = 0.5
        circlePlayer.position = position
        circlePlayer.physicsBody = SKPhysicsBody(rectangleOf: circlePlayer.frame.size)
        circlePlayer.physicsBody?.isDynamic = false
        circlePlayer.physicsBody?.affectedByGravity = false
        circlePlayer.physicsBody?.categoryBitMask = physicsbodyCategories.player
        circlePlayer.physicsBody?.collisionBitMask = physicsbodyCategories.none
        circlePlayer.physicsBody?.contactTestBitMask = physicsbodyCategories.point | physicsbodyCategories.getLife
        self.addChild(circlePlayer)
        
        let scaleUp = SKAction.scale(to: 6, duration: 0.2)
        let scaleDown = SKAction.scale(to: 4, duration: 0.2)
        let sequence = SKAction.sequence([scaleUp,scaleDown])
        circlePlayer.run(sequence)
        
    }
    
    func imageObstacle(name:String, position:CGPoint){
        
        let circleImage = SKTexture(imageNamed: "Match'em ball")
        let circleRadious = SKSpriteNode(texture: circleImage)
        circleRadious.name = name
        circleRadious.zPosition = 1
        circleRadious.position = position
        circleRadious.setScale(0.8)
        circleRadious.physicsBody = SKPhysicsBody(circleOfRadius: max(circleRadious.size.width/2, circleRadious.size.height/2))
        circleRadious.physicsBody?.isDynamic = false
        circleRadious.physicsBody?.affectedByGravity = false
        circleRadious.physicsBody?.categoryBitMask = physicsbodyCategories.obstacle
        circleRadious.physicsBody?.collisionBitMask = physicsbodyCategories.point
        circleRadious.physicsBody?.contactTestBitMask = physicsbodyCategories.point
        self.addChild(circleRadious)
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.2)
        let sequence = SKAction.sequence([scaleUp,scaleDown])
        circleRadious.run(sequence)
    }
    
    func label(label:SKLabelNode, text:String, position:CGPoint){
        label.text = text
        label.zPosition = 1
        label.position = position
        label.fontName = "ChalkboardSE-Bold"
        label.fontColor = .black
        label.fontSize = 80
        self.addChild(label)
    }
    
    func gainLifeAnimation(animationPosition:CGPoint){
        
        let lifeImage = SKSpriteNode(imageNamed: "Match'em life")
        lifeImage.zPosition = 2
        lifeImage.setScale(0)
        lifeImage.position = animationPosition
        lifeImage.physicsBody = SKPhysicsBody(rectangleOf: lifeImage.size)
        lifeImage.physicsBody?.categoryBitMask = physicsbodyCategories.getLife
        lifeImage.physicsBody?.contactTestBitMask = physicsbodyCategories.point
        lifeImage.physicsBody?.collisionBitMask = physicsbodyCategories.point
        self.addChild(lifeImage)
        
        let scalUp = SKAction.scale(to: 0.7, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let delete = SKAction.removeFromParent()
        let sequence = SKAction.sequence([scalUp,fadeOut,delete])
        lifeImage.run(sequence)
        
    }
    
    func lifeElement(startPosition: CGPoint, endPosition: CGPoint){
        
        let lifeImage = SKSpriteNode(imageNamed: "Match'em life")
        lifeImage.zPosition = 1
        lifeImage.setScale(0.3)
        lifeImage.position = startPosition
        lifeImage.physicsBody = SKPhysicsBody(rectangleOf: lifeImage.size)
        lifeImage.physicsBody?.categoryBitMask = physicsbodyCategories.getLife
        lifeImage.physicsBody?.contactTestBitMask = physicsbodyCategories.point
        lifeImage.physicsBody?.collisionBitMask = physicsbodyCategories.point
        self.addChild(lifeImage)
        
        let spawn = SKAction.move(to: endPosition, duration: 1.5)
        let delete = SKAction.removeFromParent()
        let sequence = SKAction.sequence([spawn,delete])
        lifeImage.run(sequence)
        
    }
    

}




