//
//  GameScene.swift
//  Flappy Ghost
//
//  Created by KHH on 10/8/2019.
//  Copyright © 2019 Kwan Hiu Hong. All rights reserved.
//

import SpriteKit
//import GameplayKit

struct physicsCategory {
    //0x1 is hexadeciaml presentation, it means 1, also means 0001 in decimal representation, << 1 means to shift the position to left by 1 unit
    static let ghost: UInt32 = 0x1 << 1 //0001 changes to 0010 = 2
    static let ground: UInt32 = 0x1 << 2 //0001 changes to 0100 = 4
    static let wall: UInt32 = 0x1 << 3 //0001 changes to 1000 = 8
}

class GameScene: SKScene {

    var ground = SKSpriteNode()
    var ghost = SKSpriteNode()
    var wallPair = SKNode()
    var wallPairWidth = CGFloat()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    
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
        createPhysicsBodyWithCircle(ghost, physicsCategory.ghost, physicsCategory.ground | physicsCategory.wall, physicsCategory.ground | physicsCategory.wall, false, true)
        ghost.zPosition = 2

        self.addChild(ghost)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false {
            //the run here is previously called runBlock : a block is a group of instructions we want to do when this is called. "() in" means essentially what we write inside the block here will be run when the spawn is called
            gameStarted = true
            ghost.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                () in
                
                self.createWalls()
              
            })
            
            //delay is the time interval between your first wall and second, second and third...
            //this also implies the distance between each wall
            let delay = SKAction.wait(forDuration: 2.5)
            //we now apply the delay and the walls to a sequence, first spawn then delay
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            //now here we run the action
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPairWidth)
            print ("the distance is \(distance)")
            let movePipes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.006 * distance))
            let removePipes = SKAction.removeFromParent()
            self.moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: self.frame.maxY * 0.55))
        } else {
            //when we press the screen, it's gonna to make the velocity to be 0, so it's not gonna moving anymore
            ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            //then we applied the impulse so that it jumps up
            ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: self.frame.maxY * 0.55))
        }
    }

    func createWalls(){
        wallPair = SKNode()
        
        //we are going to add out top and bottom wall into that wall pair and to edit the position of wallPair it self
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.maxX, y: self.frame.midY + self.frame.maxY * 0.8)
        bottomWall.position = CGPoint(x: self.frame.maxX, y: self.frame.midY - self.frame.maxY * 0.8)
        
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
        wallPairWidth = topWall.frame.width * 4
        
        let randomPosition = CGFloat.random(min: -300, max: 300)
        wallPair.position.y = wallPair.position.y + randomPosition
        
        wallPair.run(moveAndRemove)

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
