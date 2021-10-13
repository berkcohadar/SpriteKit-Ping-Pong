//
//  GameScene.swift
//  Ping Pong
//
//  Created by Berk Çohadar on 10/13/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var pong:    SKSpriteNode!
    
    override func didMove(to view: SKView) {
        pong = (self.childNode(withName: "pong") as! SKSpriteNode)
        player1 = (self.childNode(withName: "player1") as! SKSpriteNode)
        player2 = (self.childNode(withName: "player2") as! SKSpriteNode)
        
        pong.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 50))
        let border = SKPhysicsBody(edgeLoopFrom: (view.scene?.frame)!)
        border.friction = 0
        self.physicsBody = border
    }
}
