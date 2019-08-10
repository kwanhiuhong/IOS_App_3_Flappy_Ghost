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
    static let score: UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    var ground = SKSpriteNode()
    var ghost = SKSpriteNode()
    var wallPair = SKNode()
    var wallPairWidth = CGFloat()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var score = Int()
    let scoreLbl = SKLabelNode()
    var died = Bool()
    var restartBtn = SKSpriteNode()
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    func createScene(){
        //this is to handle or delegate any physics contact that goes on
        self.physicsWorld.contactDelegate = self
        
        //create background for the app
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Background")
            //background.anchorPoint = CGPoint(x: 0, y: 0)
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = "background"
            //background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        scoreLbl.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 300)
        print ("the x coordinate is : \(scoreLbl.frame.midX), y is \(scoreLbl.frame.midY)")
        scoreLbl.text = "\(score)"
        scoreLbl.fontName = "04b_19"
        scoreLbl.zPosition = 4
        scoreLbl.fontColor = SKColor.white
        scoreLbl.fontSize = 200
        self.addChild(scoreLbl)
        
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
        createPhysicsBodyWithCircle(ghost, physicsCategory.ghost, physicsCategory.ground
            | physicsCategory.wall, physicsCategory.ground | physicsCategory.wall | physicsCategory.score, false, true)
        ghost.zPosition = 2
        
        self.addChild(ghost)
    }
    
    override func didMove(to view: SKView) {
        createScene()
    }
    
    func createBtn(){
        restartBtn = SKSpriteNode(imageNamed: "RestartBtn")
        restartBtn.size = CGSize(width: self.frame.width / 3.0, height: self.frame.height / 10.0)
        restartBtn.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        restartBtn.zPosition = 5
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    //what stores inside this contact is what elements have collided with each other
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        //if the ghost hits the hidden score line, then we increase the score
        if firstBody.categoryBitMask == physicsCategory.score && secondBody.categoryBitMask == physicsCategory.ghost {
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == physicsCategory.ghost && secondBody.categoryBitMask == physicsCategory.score {
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        }
        
        //if the ghost hits the wall, it will die
        if firstBody.categoryBitMask == physicsCategory.ghost && secondBody.categoryBitMask == physicsCategory.wall
            || firstBody.categoryBitMask == physicsCategory.wall && secondBody.categoryBitMask == physicsCategory.ghost {

            //this will freeze everything moving after the ghost hits the wall, including the restartBtn
            //self.scene?.speed = 0
            enumerateChildNodes(withName: "wallPair", using: ({
                //the node here will be all the wall pair nodes that we pick up in the scene
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if died == false {
                died = true
                createBtn()
            }
        }
        
        //if the ghost hits the wall, it will die
        if firstBody.categoryBitMask == physicsCategory.ghost && secondBody.categoryBitMask == physicsCategory.ground
            || firstBody.categoryBitMask == physicsCategory.ground && secondBody.categoryBitMask == physicsCategory.ghost {
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if died == false {
                died = true
                createBtn()
            }
        }
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
            let delay = SKAction.wait(forDuration: 1.3)
            //we now apply the delay and the walls to a sequence, first spawn then delay
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            //now here we run the action
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPairWidth + 100)
            let movePipes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.003 * distance))
            let removePipes = SKAction.removeFromParent()
            self.moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: self.frame.maxY * 0.55))
        } else {
            if died == true {
            } else {
                //when we press the screen, it's gonna to make the velocity to be 0, so it's not gonna moving anymore
                ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                //then we applied the impulse so that it jumps up
                ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: self.frame.maxY * 0.55))
            }
        }
        
        //check if the restart button is tapped or not
        for touch in touches{
            let location = touch.location(in: self)
            if died == true {
                if restartBtn.contains(location){
                    restartScene()
                }
            }
        }
    }

    func createWalls(){
        
        //this part shows score that you get at the end of the game
        let scoreNode = SKSpriteNode(imageNamed: "Coin")
        scoreNode.size = CGSize(width: 100, height: 100)
        scoreNode.position = CGPoint(x: self.frame.maxX + 25, y: self.frame.midY)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        createPhysicsBodyWithReactangle(scoreNode, physicsCategory.score, 0, physicsCategory.ghost)
        scoreNode.color = SKColor.white
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        //we are going to add out top and bottom wall into that wall pair and to edit the position of wallPair it self
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.maxX + 25, y: self.frame.midY + self.frame.maxY * 0.8)
        bottomWall.position = CGPoint(x: self.frame.maxX + 25, y: self.frame.midY - self.frame.maxY * 0.8)

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
        wallPairWidth = topWall.frame.width
        
        let randomPosition = CGFloat.random(min: -300, max: 300)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.addChild(scoreNode)
        
        wallPair.run(moveAndRemove)

        self.addChild(wallPair)
    }
    
    func createPhysicsBodyWithReactangle(_ object: SKSpriteNode, _ categoryBitMask: UInt32, _ collisionObject: UInt32,
                                         _ contactTestObject: UInt32, affectedByGravity: Bool = false, isDynamic: Bool = false){
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
    
    func createPhysicsBodyWithCircle(_ object: SKSpriteNode, _ categoryBitMask: UInt32, _ collisionObject: UInt32,
                                     _ contactTestObject: UInt32, _ affectedByGravity: Bool = false, _ isDynamic: Bool = false){
        object.physicsBody = SKPhysicsBody(circleOfRadius: object.frame.height / 2)
        object.physicsBody?.categoryBitMask = categoryBitMask
        object.physicsBody?.collisionBitMask = collisionObject
        object.physicsBody?.contactTestBitMask = contactTestObject
        object.physicsBody?.affectedByGravity = affectedByGravity
        object.physicsBody?.isDynamic = isDynamic
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameStarted == true {
            if died == false {
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: 0)
                    print ("the x is \(bg.position.x), y is \(bg.position.y) ")
                    if bg.position.x <= -bg.size.width{
                        bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: 0)
                        print ("****** \(bg.position.x)")
                    }
                }))
            }
        }
    }
}
