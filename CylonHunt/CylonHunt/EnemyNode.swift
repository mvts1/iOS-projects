//
//  EnemyNode.swift
//  CylonHunt
//
//  Created by Onur Mavitas on 28.01.2021.
//

import SpriteKit

class EnemyNode: SKSpriteNode {
    var type: EnemyType
    var lastFireTime: Double = 0 //last time it fires the weapon
    var shields: Int
    
    init(type: EnemyType, startPosition: CGPoint, xOffSet: CGFloat, moveStraight: Bool) {
        self.type = type
        shields = self.type.shields
        
        let texture = SKTexture(imageNamed: type.name)
        //create the main SpriteNode using the current sprite
        super.init(texture: texture, color: .white, size: texture.size())
        
        //assign the default physics body so it'll have the right shape for the enemy type
        physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        //bounce off the player of player's weapon
        physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        name = "enemy"
        position = CGPoint(x: startPosition.x, y: startPosition.y)
        
        configureMovement(moveStraight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureMovement(_ moveStraight: Bool)  {
        let path = UIBezierPath()
        path.move(to: .zero)
        
        if moveStraight {
            //just flies straight ahead and all the way to the left (-10000)
            path.addLine(to: CGPoint(x: -10000, y: 0))
        } else {
            //flies in a curve using control points
            path.addCurve(to: CGPoint(x: -3500, y: 0), controlPoint1: CGPoint(x: 0, y: -position.y*4), controlPoint2: CGPoint(x: -1000, y: -position.y))
        }
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: type.speed)
        //destroy the thing as soon as the movement is finished
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        run(sequence)
    }
    
    func fire() {
        let weaponType = "\(type.name)weapon"
        
        let weapon = SKSpriteNode(imageNamed: weaponType)
        weapon.name = "enemyWeapon"
        weapon.position = position
        weapon.zRotation = zRotation //weapon pointing at the rotation of the enemy
        addChild(weapon) //addChild before applying force on the object
        
        weapon.physicsBody = SKPhysicsBody(rectangleOf:  weapon.size)
        weapon.physicsBody?.categoryBitMask = CollisionType.enemyWeapon.rawValue
        weapon.physicsBody?.collisionBitMask = CollisionType.player.rawValue
        weapon.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        //lasers should have small mass and fly the same speed. Normally, spritekit determines mass based on size
        weapon.physicsBody?.mass = 0.001
        
        //need to "push" the weapon towards that direction
        let speed: CGFloat = 1
        let adjustedRotation = zRotation + (CGFloat.pi / 2)
        
        let dx = speed * cos(adjustedRotation)
        let dy = speed * sin(adjustedRotation)
        
        //give it a push
        weapon.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        
    }
}
