//
//  GameScene.swift
//  Ping Pong
//
//  Created by Berk Çohadar on 10/13/21.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate{
    var player1: SKShapeNode!
    var player2: SKShapeNode!
    var gameBall: SKShapeNode!
    var player1Label: SKLabelNode!
    var player2Label: SKLabelNode!
    
    var initLocationBall = CGPoint(x: 0, y: 0)
    var initLocationP1 = CGPoint(x: 0, y: 0)
    var initLocationP2 = CGPoint(x: 0, y: 0)
    
    var player1ScoreInt: Int = 0; // player1Score score value as int
    var player2ScoreInt: Int = 0; // player2Score score value as int
    
    var timer = Timer()
    var time = 2
    
    var targetScore = 10
    var winnerLabel: SKLabelNode!
    
    var ballHitSound : AVAudioPlayer?
    var paddleHitSound : AVAudioPlayer?
    var ballHitSoundDir = Bundle.main.path(forResource: "ballHit", ofType: "wav")
    var paddleHitSoundDir = Bundle.main.path(forResource: "paddleHit", ofType: "wav")

    override func didMove(to view: SKView) {
        player1Label = (self.childNode(withName: "player1ScoreLabel") as! SKLabelNode)
        player2Label = (self.childNode(withName: "player2ScoreLabel") as! SKLabelNode)

        winnerLabel = (self.childNode(withName: "winnerLabel") as! SKLabelNode)
        
        initLocationP1 = CGPoint(x: (self.size.width/2)/3 * -2.5, y: 0)
        initLocationP2 = CGPoint(x: (self.size.width/2)/3 * 2.5, y: 0)
        
        player1 = SKShapeNode(circleOfRadius: CGFloat(120))
        player1.position = initLocationP1
        player1.fillColor = .systemGreen
        player1.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(120))
        player1.physicsBody!.affectedByGravity = false
        player1.physicsBody?.isDynamic = false
        player1.physicsBody?.collisionBitMask = 2
        player1.physicsBody?.categoryBitMask = 1
        player1.physicsBody?.angularDamping = 0
        player1.physicsBody?.linearDamping = 0
        player1.physicsBody?.friction = 0
        player1.physicsBody?.restitution = 1
        player1.name = "player11"
        
        player2 = SKShapeNode(circleOfRadius: CGFloat(120))
        player2.position = initLocationP2
        player2.fillColor = .systemPink
        player2.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(120))
        player2.physicsBody!.affectedByGravity = false
        player2.physicsBody?.isDynamic = false
        player2.physicsBody?.collisionBitMask = 2
        player2.physicsBody?.categoryBitMask = 1
        player2.physicsBody?.angularDamping = 0
        player2.physicsBody?.linearDamping = 0
        player2.physicsBody?.friction = 0
        player2.physicsBody?.restitution = 1
        player2.name = "player22"
        
        gameBall = SKShapeNode(circleOfRadius: CGFloat(50))
        gameBall.fillColor = .red
        gameBall.position = initLocationBall
        gameBall.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(50))
        gameBall.physicsBody!.affectedByGravity = false
        gameBall.physicsBody?.collisionBitMask = 1
        gameBall.physicsBody?.categoryBitMask = 2
        gameBall.physicsBody?.angularDamping = 0
        gameBall.physicsBody?.linearDamping = 0
        gameBall.physicsBody?.friction = 0
        gameBall.physicsBody?.restitution = 1
        gameBall.physicsBody?.allowsRotation = true
        gameBall.physicsBody?.isDynamic = true
        gameBall.zRotation = CGFloat.pi / 2
        gameBall.name = "gameBall"
        
        let border = SKPhysicsBody(edgeLoopFrom: (view.scene?.frame)!)
        border.friction = 0
        self.physicsBody = border
        self.physicsBody?.contactTestBitMask = 2
        self.physicsWorld.contactDelegate = self
        self.name = "gameArea"
        
        self.addChild(player1)
        self.addChild(player2)
        self.addChild(gameBall)
        gameBall.physicsBody?.applyImpulse(CGVector(dx: 600, dy: 0))
        
    }
    

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            let radius = (self.size.width/2)/3
            if (loc.x < 0) {
                player1.position.y = loc.y
                if(loc.x <= radius * -1) {
                    player1.position.x = loc.x
                }
            }
            else {
                player2.position.y = loc.y
                if(loc.x >= radius) {
                    player2.position.x = loc.x
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // SOUND ANIMATION PLAY
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            ballHitSound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.ballHitSoundDir!))
            guard let ballHitSound = ballHitSound else {
                return
            }
            ballHitSound.play()

        } catch {
            print("Error while playing the ball hit sound.")
        }
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            paddleHitSound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.paddleHitSoundDir!))
            guard let paddleHitSound = paddleHitSound else {
                return
            }
            paddleHitSound.play()

        } catch {
            print("Error while playing the paddle hit sound.")
        }
        
        
        let firstContact = contact.bodyA.node?.name
        let secondContact = contact.bodyB.node?.name
        
        if (firstContact == "gameBall" && secondContact == "gameArea" || firstContact == "gameArea" && secondContact == "gameBall") {
            if (gameBall.position.x < initLocationP1.x) {
                print("GOAL - PLAYER2")
                gameBall.removeFromParent()
                player2ScoreInt += 1
                player2Label.text = String(player2ScoreInt)
                if (player2ScoreInt == targetScore){
                    endGame(player: "player2")
                } else {
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.resetBall), userInfo: ["player":"player2"], repeats: true)
                }
            }
            
            if (gameBall.position.x > initLocationP2.x) {
                print("GOAL - PLAYER1")
                gameBall.removeFromParent()
                player1ScoreInt += 1
                player1Label.text = String(player1ScoreInt)
                if (player1ScoreInt == targetScore){
                    endGame(player: "player1")
                } else {
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.resetBall), userInfo: ["player":"player1"], repeats: true)
                }
            }
        }
    }
    
    @objc func resetBall(sender:Timer){
        guard let players = sender.userInfo as? [String: String] else { return }
        let player = players["player", default: "Anonymous"]
        time = time - 1
        if (time == 0){
            print("RESET")
            gameBall.position = initLocationBall
            self.addChild(gameBall)
            
            if (player == "player1") {
                gameBall.physicsBody?.applyImpulse(CGVector(dx: 600, dy: 0))
            } else {
                gameBall.physicsBody?.applyImpulse(CGVector(dx: -600, dy: 0))
            }
            
            player1.position = initLocationP1
            player2.position = initLocationP2
            
            timer.invalidate()
            time = 2
        }
    }
    
    @objc func endGame(player:String){
        player1.position = initLocationP1
        player2.position = initLocationP2
        
        player1ScoreInt = 0
        player1Label.text = String(player1ScoreInt)
        
        player2ScoreInt = 0
        player2Label.text = String(player2ScoreInt)
        
        if (player == "player1"){
            print("player1 won")
            winnerLabel.position = CGPoint(x: 0, y: 0)
            winnerLabel.text = "player1 won"
        } else if (player == "player2"){
            print("player2 won")
            winnerLabel.position = CGPoint(x: 0, y: 0)
            winnerLabel.text = "player2 won"
        }
    }
    
}
