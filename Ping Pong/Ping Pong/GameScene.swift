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
    var scoreSound : AVAudioPlayer?

    var ballHitSoundDir = Bundle.main.path(forResource: "ballHit", ofType: "wav")
    var paddleHitSoundDir = Bundle.main.path(forResource: "paddleHit", ofType: "wav")
    var scoreSoundDir = Bundle.main.path(forResource: "score", ofType: "wav")

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
        player1.physicsBody?.contactTestBitMask = 2
        player1.name = "player1"
        
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
        player2.physicsBody?.contactTestBitMask = 2
        player2.name = "player2"
        
        gameBall = SKShapeNode(circleOfRadius: CGFloat(35))
        gameBall.fillColor = .red
        gameBall.position = initLocationBall
        gameBall.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(35))
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
        if ((childNode(withName: "gameball")) == nil){
            self.addChild(gameBall)
        }
        gameBall.physicsBody?.applyImpulse(CGVector(dx: 275, dy: 0))
        
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
        let firstContact = contact.bodyA.node?.name
        let secondContact = contact.bodyB.node?.name
                
        if ((firstContact == "gameBall" && (secondContact == "player1" || secondContact == "player2")) || ((firstContact == "player1" || firstContact == "player2") && secondContact == "gameBall")) {
            soundEffect(type: "paddleHit")
        }

        else if (firstContact == "gameBall" && secondContact == "gameArea" || firstContact == "gameArea" && secondContact == "gameBall") {
            
            if (gameBall.position.x < initLocationP1.x) {
                gameBall.removeFromParent()
                soundEffect(type: "scoreSound")
                player2ScoreInt += 1
                player2Label.text = String(player2ScoreInt)
                if (player2ScoreInt == targetScore){
                    endGame(player: "player2")
                } else {
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.resetBall), userInfo: ["player":"player2"], repeats: true)
                }
            }
            
            else if (gameBall.position.x > initLocationP2.x) {
                gameBall.removeFromParent()
                soundEffect(type: "scoreSound")
                player1ScoreInt += 1
                player1Label.text = String(player1ScoreInt)
                if (player1ScoreInt == targetScore){
                    endGame(player: "player1")
                } else {
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.resetBall), userInfo: ["player":"player1"], repeats: true)
                }
            }
            
            else {
                soundEffect(type: "ballHit")
            }
        }
    }
    
    @objc func resetBall(sender:Timer){
        guard let players = sender.userInfo as? [String: String] else { return }
        let player = players["player", default: "Anonymous"]
        time = time - 1
        if (time == 0){
            gameBall.position = initLocationBall
            if ((childNode(withName: "gameball")) == nil){
                self.addChild(gameBall)
            }
            
            
            if (player == "player1") {
                gameBall.physicsBody?.applyImpulse(CGVector(dx: 275, dy: 0))
            } else {
                gameBall.physicsBody?.applyImpulse(CGVector(dx: -275, dy: 0))
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
            winnerLabel.position = CGPoint(x: 0, y: 0)
            winnerLabel.text = "player1 won"
        } else if (player == "player2"){
            winnerLabel.position = CGPoint(x: 0, y: 0)
            winnerLabel.text = "player2 won"
        }
    }
    
    @objc func soundEffect(type:String) {
        switch type {
        case "ballHit":
            do {  // SOUND ANIMATION PLAY
                ballHitSound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.ballHitSoundDir!))
                guard let ballHitSound = ballHitSound else {
                    return
                }
                ballHitSound.play()

            } catch {
                print("Error while playing the ball hit sound.")
            }
        case "paddleHit":
            do {
                paddleHitSound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.paddleHitSoundDir!))
                guard let paddleHitSound = paddleHitSound else {
                    return
                }
                paddleHitSound.play()

            } catch {
                print("Error while playing the paddle hit sound.")
            }
        case "scoreSound":
            do {
                scoreSound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.scoreSoundDir!))
                guard let scoreSound = scoreSound else {
                    return
                }
                scoreSound.play()

            } catch {
                print("Error while playing the paddle hit sound.")
            }
        default:
            print("Sound has no type")
            break
        }
    }
    
}
