//
//  ViewController.swift
//  ARDicee
//
//  Created by Harshit ‎ on 11/24/24.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints] // To detect the process of plane detection
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //        To display moon 🌕 in 3D
        
        //        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        //        let sphere = SCNSphere(radius: 0.2)
        //
        //        let material = SCNMaterial()
        //        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
        //        sphere.materials = [material]
        //
        //        let node = SCNNode()
        //        node.position = SCNVector3(x: 0.1, y: 0.1, z: -0.5)
        //        node.geometry = sphere
        //
        //        sceneView.scene.rootNode.addChildNode(node)
        //        sceneView.autoenablesDefaultLighting = true
        
        sceneView.autoenablesDefaultLighting = true
        
        
        // Create a new scene
        
        //        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        //        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
        //            diceNode.position = SCNVector3(0, 0, -0.1)
        //            sceneView.scene.rootNode.addChildNode(diceNode)
        //        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        
        configuration.planeDetection = .horizontal
        
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Dice Rendering Methods
    
    //    To detect touch (single touch)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first!.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if let hitResult = results.first {
            addDice(atLocation: hitResult)
            
        }
    }
    
    func addDice(atLocation location: ARHitTestResult) {
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(
                x:location.worldTransform.columns.3.x,
                y:location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z:location.worldTransform.columns.3.z
            )
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
        }
    }
    
    func rollAll() {
        if diceArray.isEmpty == false {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5)
        )
    }
    
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    
    //MARK: - ARSCNViewDelegateMethds
    
    //    To detect horizontal plane
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = cretePlaneWith(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
        
    }
    
    //MARK: - Plane Rendering Methods
    
    func cretePlaneWith(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        
        return planeNode
    }
    
}
