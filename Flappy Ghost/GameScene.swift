//
//  GameScene.swift
//  Flappy Ghost
//
//  Created by KHH on 10/8/2019.
//  Copyright © 2019 Kwan Hiu Hong. All rights reserved.
//

import SpriteKit
import GameplayKit

struct physicsCategory {
    static let ghost: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let wall: UInt32 = 0x1 << 3
}

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var ground = SKSpriteNode()
    var ghost = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        //add the ground
        ground = SKSpriteNode(imageNamed: "Ground")
        //size of our ground, which is 1080 by 100, if 0.5, then it's 540 by 50
        ground.setScale(1)
        //we would like to set the ground to the bottom, and x represents the mid point of the width of your ground (so we want the ground to be placed in the middle of the game scene) and y represents the mid point of the height of your ground (we want to place the ground on the bottom of the scene, however if y is the bottom coordinate only, the ground will be cut by half by the game scene
        ground.position = CGPoint(x: self.frame.midX, y: self.frame.minY + ground.frame.height / 2)
        
        createPhysicsBodyWithReactangle(ground, physicsCategory.ground, physicsCategory.ghost, physicsCategory.ghost)
        ground.zPosition = 3
        self.addChild(ground)
        
        //add the ghost
        ghost = SKSpriteNode(imageNamed: "Ghost")
        ghost.size = CGSize(width: 120, height: 140)
        //place the ghost slightly left from the middle of the game scene
        ghost.position = CGPoint(x: self.frame.midX - ghost.frame.width, y: self.frame.midY)
        
        //add the physics to ghost
        //as the ghost has a round head, we don't want it hitting things that are not there, so use circle instead of rectangle
        createPhysicsBodyWithCircle(ghost, physicsCategory.ghost, physicsCategory.ground | physicsCategory.wall, physicsCategory.ground | physicsCategory.wall, true, true)
        ghost.zPosition = 2

        self.addChild(ghost)
        
        createWalls()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //when we press the screen, it's gonna to make the velocity to be 0, so it's not gonna moving anymore
        ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        //then we applied the impulse so that it jumps up
        ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 540))
    }

    func createWalls(){
        let wallPair = SKNode()
        
        //we are going to add out top and bottom wall into that wall pair and to edit the position of wallPair it self
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 640)
        bottomWall.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 640)
        
        topWall.setScale(1)
        bottomWall.setScale(1)
        
        createPhysicsBodyWithReactangle(topWall, physicsCategory.wall, physicsCategory.ghost, physicsCategory.ghost)
        createPhysicsBodyWithReactangle(bottomWall, physicsCategory.wall, physicsCategory.ghost, physicsCategory.ghost)
        
        //Change the topWall upside down, we are working on radians so 180 degrees essentially is a pi
        topWall.zRotation = CGFloat(Double.pi)
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        
        //I would like to give order to different objects, especially how the walls and grounds order
        //so now walls are below everything
        wallPair.zPosition = 1
        
        self.addChild(wallPair)
    }
    
    func createPhysicsBodyWithReactangle(_ object: SKSpriteNode, _ categoryBitMask: UInt32, _ collisionObject: UInt32, _ contactTestObject: UInt32, affectedByGravity: Bool = false, isDynamic: Bool = false){
        //add the physics to the object
        object.physicsBody = SKPhysicsBody(rectangleOf: object.size)
        //this tells whether we are colliding and what not
        object.physicsBody?.categoryBitMask = categoryBitMask
        //wanna test what we are colliding with, coz, say, we don't want the ground to collide the wall, so all we need to collide with is the ghost
        //the collisionBitMask is: when two objects collide, we just want them to collide
        object.physicsBody?.collisionBitMask = collisionObject
        //contactTestBitMask tests whether they have collided, coz we will do something when two objects collide in the future
        object.physicsBody?.contactTestBitMask = contactTestObject
        object.physicsBody?.affectedByGravity = affectedByGravity
        //dynamic = false means if the ground is hit by something it will not move
        object.physicsBody?.isDynamic = isDynamic
    }
    
    func createPhysicsBodyWithCircle(_ object: SKSpriteNode, _ categoryBitMask: UInt32, _ collisionObject: UInt32, _ contactTestObject: UInt32, _ affectedByGravity: Bool = false, _ isDynamic: Bool = false){
        object.physicsBody = SKPhysicsBody(circleOfRadius: object.frame.height / 2)
        object.physicsBody?.categoryBitMask = categoryBitMask
        object.physicsBody?.collisionBitMask = collisionObject
        object.physicsBody?.contactTestBitMask = contactTestObject
        object.physicsBody?.affectedByGravity = affectedByGravity
        object.physicsBody?.isDynamic = isDynamic
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}
