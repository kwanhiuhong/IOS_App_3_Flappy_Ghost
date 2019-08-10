//
//  GameScene.swift
//  Flappy Ghost
//
//  Created by KHH on 10/8/2019.
//  Copyright © 2019 Kwan Hiu Hong. All rights reserved.
//

import SpriteKit
import GameplayKit

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
        self.addChild(ground)
        
        //add the ghost
        ghost = SKSpriteNode(imageNamed: "Ghost")
        ghost.size = CGSize(width: 120, height: 140)
        //place the ghost slightly left from the middle of the game scene
        ghost.position = CGPoint(x: self.frame.midX - ghost.frame.width, y: self.frame.midY)
        self.addChild(ghost)
    }
    
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
