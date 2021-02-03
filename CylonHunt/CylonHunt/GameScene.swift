//
//  GameScene.swift
//  CylonHunt
//
//  Created by Onur Mavitas on 27.01.2021.
//

import CoreMotion
import SpriteKit

//an enum to describe all the collision types
enum CollisionType: UInt32 {
    case player = 1
    case playerWeapon = 2
    case enemy = 4
    case enemyWeapon = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let motionManager = CMMotionManager()
    let player = SKSpriteNode(imageNamed: "player")
    
    let waves = Bundle.main.decode([Wave].self, from: "Waves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "EnemyTypes.json")
    
    var isPlayerAlive = true
    var levelNumber = 0
    var waveNumber = 0
    var playerShields = 7 //player health
    
    //stride is like a for loop using a jump each time: total array of y positions we wanna create enemies at
    let positions = Array(stride(from: -320, through: 320, by: 80))
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero //kill gravity as this is a space game
        physicsWorld.contactDelegate = self //tell "me" when collisions happen
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: 1000, y: 0)
            particles.zPosition = -1
            particles.advanceSimulationTime(60)
            addChild(particles)
        }
        
        player.name = "player"
        player.position.x = frame.minX + 70
        player.zPosition = 1 //bring player above other things
        player.size = CGSize(width: 100, height: 100)
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        //categoryBitMask: what kind of thing this is in the physics world
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        //collisionBitMask describes what it bumps into in a physics engine
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        //contactBitMask: when things collide do we want to be told about
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        player.physicsBody?.isDynamic = false //no gravity
        
        //start reading the motion tracking device
        motionManager.startAccelerometerUpdates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        //this method is called before everytime the scene is drawn.
        //60 times or 100 times per sec etc depending on our device
        
        if let accelerometerData = motionManager.accelerometerData {
            //we use X acceData because device is tilted right and x becomes y
            //we multiply by 50 to make it a stronger movement
            player.position.y += CGFloat(accelerometerData.acceleration.x * 50)
            
            if player.position.y < frame.minY {
                //stop the player if it goes off screen
                player.position.y = frame.minY
            } else if player.position.y > frame.maxY { //player at the other side of the screen
                player.position.y = frame.maxY
            }
        }

        //if enemies are out of the screen, we'll get rid of them
        for child in children {
            if child.frame.maxX < 0 { //at least half the way off screen
                if !frame.intersects(child.frame) { //if we're not overlapping
                    child.removeFromParent()
                }
            }
        }
        let activeEnemies = children.compactMap { $0 as? EnemyNode }
        
        if activeEnemies.isEmpty {
            //only create a wave when there are no enemies left on the screen
            createWave()
        }
        
        for enemy in activeEnemies {
            guard frame.intersects(enemy.frame) else {continue} //checks if the enemy is on screen
            
            if enemy.lastFireTime + 1 < currentTime {
                enemy.lastFireTime = currentTime
                
                if Int.random(in: 0...3) == 0 { //1/4 chance of firing
                    enemy.fire()
                }
            }
        }
    }
    
    func createWave() {
        //if the player isn't alive, don't create a wave
        guard isPlayerAlive else { return }
        
        //are we at the limit of our waves
        if waveNumber == waves.count {
            levelNumber += 1
            waveNumber = 0
        }
        let currentWave = waves[waveNumber]
        waveNumber += 1
        
        //enemyTypes.count is 3, max levelNumber+1 is 3. if levelNumber is smaller, we're using smaller enemies
        let maximumEnemyType = min(enemyTypes.count, levelNumber + 1)
        let enemyType = Int.random(in: 0..<maximumEnemyType)
        
        //enemyOffsetX: how far we're gonna push the spaceships back to make the formations
        let enemyOffsetX: CGFloat = 100
        let enemyStartX = 600 //just off the screen, no offset at start
        
        //no enemies left = random wave now
        if currentWave.enemies.isEmpty {
            for (index, position) in positions.shuffled().enumerated() {
                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: position), xOffSet: enemyOffsetX * CGFloat(index*3), moveStraight: true)
                addChild(enemy)
            }
        } else { //we have predefined enemies
            for enemy in currentWave.enemies {
                let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: positions[enemy.position]), xOffSet: enemyOffsetX * enemy.xOffset, moveStraight: enemy.moveStraight)
                addChild(node) //add it to the gamescene
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlayerAlive else { return } //nothing should happen if the player is dead
        
        //shoot when the screen is tapped (do the opposite of enemy shots)
        let shot = SKSpriteNode(imageNamed: "player-weapon")
        shot.name = "playerWeapon"
        shot.position = player.position
        
        shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
        shot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
        shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        addChild(shot)
        
        let movement = SKAction.move(to: CGPoint(x: 2000, y: shot.position.y), duration: 7) //goes far right of the screen, takes 7 secs to move
        let sequence =  SKAction.sequence([movement, .removeFromParent()])
        shot.run(sequence)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //what to do when nodeA hits nodeB
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        //we don't know which node is player, if we remove it and try to call, app will crash
        //to overcome this we sort them as enemy, enemyWeapon, player, playerWeapon
        //now I know that if the player is one of nodeA or B, it will be nodeB
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? ""}
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        if secondNode.name == "player" { //if it collides with the player
            //first make sure the player is alive
            guard isPlayerAlive else {return}
            
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = firstNode.position //not the player's pos, enemy's position
                addChild(explosion)
            }
            playerShields -= 1 //player health
            
            if playerShields == 0 {
                gameOver()
                secondNode.removeFromParent()
            }
            
            firstNode.removeFromParent() //regardless of player's death, remove the 1st node
            
        } else if let enemy = firstNode as? EnemyNode { //if the first node is enemy
            //used if let here (typecasting) instead of name checking to work with the EnemyNode itself
            //because I wanna substract 1 from enemy shield
            enemy.shields -= 1
            if enemy.shields == 0 {
                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                    explosion.position = enemy.position
                    addChild(explosion)
                }
                enemy.removeFromParent()
            }
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = enemy.position
                addChild(explosion)
            }
            secondNode.removeFromParent() //this won't remove the player cuz player was handled above
            //this would work when player's weapon hits the enemy for example
            
        } else { //when other things like player&enemy weapons collide
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = secondNode.position
                addChild(explosion)
            }
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
        
    }
    
    func gameOver() {
        isPlayerAlive = false
        
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        let gameOver = SKSpriteNode(imageNamed: "game-over")
        addChild(gameOver)
    }
}
