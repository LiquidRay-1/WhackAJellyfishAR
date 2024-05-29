//
//  ViewController.swift
//  whackAJellyfish
//
//  Created by Liquid on 25/5/24.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    var timer = Each(1).seconds
    var countdown = 10
    var score = 0
    var level = 1
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var play: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    
    let configuration = ARWorldTrackingConfiguration()
    var enemyTypes = ["basketball", "medusa"]
    
    override func viewDidLoad() {
            super.viewDidLoad()
            self.sceneView.session.run(configuration)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }

        @IBAction func play(_ sender: Any) {
            self.setTimer()
            self.addNode()
            self.play.isEnabled = false
        }

        @IBAction func reset(_ sender: Any) {
            self.timer.stop()
            self.restoreTimer()
            self.score = 0
            self.level = 1
            self.updateScore()
            self.play.isEnabled = true
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
            }
        }

        func addNode() {
            var enemyScene: SCNScene?
            var enemyNode: SCNNode?
            if level % 5 == 0 {
                // Boss level
                enemyScene = SCNScene(named: "art.scnassets/therock.scn")
                enemyNode = enemyScene?.rootNode.childNode(withName: "therock", recursively: false)
            } else {
                let enemyType = enemyTypes.randomElement()!
                enemyScene = SCNScene(named: "art.scnassets/\(enemyType).scn")
                enemyNode = enemyScene?.rootNode.childNode(withName: enemyType, recursively: false)
            }
            enemyNode?.position = SCNVector3(randomNumbers(firstNum: -1, secondNum: 1), randomNumbers(firstNum: -1, secondNum: 1), randomNumbers(firstNum: -1, secondNum: 1))
            self.sceneView.scene.rootNode.addChildNode(enemyNode!)
        }

        @objc func handleTap(sender: UITapGestureRecognizer) {
            let sceneViewTappedOn = sender.view as! SCNView
            let touchCoordinates = sender.location(in: sceneViewTappedOn)
            let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
            if (hitTest.isEmpty) {
                print("No se tocó nada")
            } else {
                if (countdown > 0) {
                    let results = hitTest.first!
                    let node = results.node
                    if node.animationKeys.isEmpty {
                        SCNTransaction.begin()
                        self.animateNode(node: node)
                        SCNTransaction.completionBlock = {
                            node.removeFromParentNode()
                            self.addNode()
                            self.restoreTimer()
                            self.score += 1
                            if self.score % 5 == 0 {
                                self.level += 1
                            }
                            self.updateScore()
                        }
                        SCNTransaction.commit()
                    }
                }
            }
        }

        func animateNode(node: SCNNode) {
            let spin = CABasicAnimation(keyPath: "position")
            spin.fromValue = node.presentation.position
            spin.toValue = SCNVector3(node.presentation.position.x - 0.2, node.presentation.position.y - 0.2,node.presentation.position.z - 0.2)
            spin.duration = 0.07
            spin.autoreverses = true
            spin.repeatCount = 5
            node.addAnimation(spin, forKey: "position")
        }

        func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
            return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
        }

        func setTimer() {
            self.timer.perform { () -> NextStep in
                self.countdown -= 1
                self.timerLabel.text = String(self.countdown)
                if self.countdown == 0 {
                    self.timerLabel.text = "Perdiste"
                    return .stop
                }
                return .continue
            }
        }

        func restoreTimer() {
            self.countdown = 10
            self.timerLabel.text = String(self.countdown)
        }
        
        func updateScore() {
            self.scoreLabel.text = "Score: \(self.score)"
        }
    }
