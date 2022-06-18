//
//  GameScene.swift
//  QuickShooter
//
//  Created by Andres Marquez on 2022-06-13.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let targets = ["penguinEvil", "penguinGood"]
    var gameTimer: Timer?

    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)

        score = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
        
        physicsWorld.contactDelegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let bullets = SKSpriteNode(imageNamed: "hammer")
        bullets.size = CGSize(width: 50, height: 50)
        bullets.name = "bullet"
        bullets.position = CGPoint(x: 50, y: location.y)
        bullets.physicsBody = SKPhysicsBody(texture: bullets.texture!, size: bullets.size)
        bullets.physicsBody?.velocity = CGVector(dx: 1500, dy: 0)
        bullets.physicsBody?.categoryBitMask = 1
        bullets.physicsBody!.contactTestBitMask = bullets.physicsBody!.collisionBitMask
        addChild(bullets)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Figure out which one is the bullet and which one the target,  and call collisionBetween function
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if contact.bodyA.node?.name == "bullet" {
            collisionBetween(bullet: nodeA, target: nodeB)
        } else if contact.bodyB.node?.name == "bullet" {
            collisionBetween(bullet: nodeB, target: nodeA)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        // Remove the nodes once they are invisible
        for node in children {
            if node.position.x < -300 || node.position.y < -300 {
                node.removeFromParent()
            }
        }
    }
    
    @objc func createTarget() {
        // Assigns either a good or a bad penguin
        guard let target = targets.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: target)
        sprite.position = CGPoint(x: Int.random(in: 400...1000), y: 720)
        sprite.name = target
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: 0, dy: -500)
    }
    
    func collisionBetween(bullet: SKNode, target: SKNode) {
        // Update score based on whether good or bad penguin was hitted
        if target.name == "penguinGood" {
            score += 1
        } else if target.name == "penguinEvil"{
            score -= 1
        }
        // Call destroy for both target and bullet
        destroy(bullet: bullet, target: target)
    }
    
    func destroy(bullet: SKNode, target: SKNode) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = target.position
        addChild(explosion)
        
        bullet.removeFromParent()
        target.removeFromParent()
    }
}
