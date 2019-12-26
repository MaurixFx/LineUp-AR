//
//  ViewController.swift
//  lineupAR
//
//  Created by Mauricio Figueroa olivares on 24-08-18.
//  Copyright © 2018 Mauricio Figueroa olivares. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var playerNodes = [SCNNode]()
    
    let screenPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "himno", withExtension: "mp4", subdirectory: "art.scnassets") else {
            print("Could not find video file")
            return AVPlayer()
        }
        return AVPlayer(url: url)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/lineup.scn")!
        let screenNode = scene.rootNode.childNode(withName: "screen", recursively: true)
        screenNode?.geometry?.firstMaterial?.diffuse.contents = screenPlayer
        screenPlayer.play()
        screenPlayer.volume = 1.0
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //1. Get The Current Touch Location
        guard let currentTouchLocation = touches.first?.location(in: sceneView) else { return }
        //2. Get The Results Of The SCNHitTest
        let hitTestResults = sceneView.hitTest(currentTouchLocation, options: nil)
        //3. Loop Through Them And Handle The Result
        for result in hitTestResults{
            print(result.node)
            print(result.node.childNodes)
            print(result.node.position)
            if result.node.name == "screen" {
                result.node.geometry?.firstMaterial?.diffuse.contents = screenPlayer
                screenPlayer.play()
                screenPlayer.volume = 1.0
            } else {
                
                UIView.animate(withDuration: 2.5) {
                    self.removePlayersNode()
                    let newPlane = SCNPlane(width: 0.3, height: 0.3)
                    newPlane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
                    guard let positionName = result.node.name else { return }
                    guard let imagePlayer = self.getImagePlayerNode(positionPlayer: positionName) else { return }
                    newPlane.firstMaterial?.diffuse.contents = imagePlayer
                    let newNode = SCNNode(geometry: newPlane)
                    newNode.geometry?.firstMaterial?.isDoubleSided = true
                    newNode.position = SCNVector3(CGFloat(result.node.position.x), CGFloat(result.node.position.y + 0.25), CGFloat(result.node.position.z))
                    newNode.eulerAngles.x = -.pi
                    
                    //BOX CON ESTADISTICAS
                    let skScene = SKScene(size:CGSize(width: 300, height: 200))
                    skScene.backgroundColor = UIColor.clear
                    
                    var corners: UIRectCorner = []
                    corners = [corners, .topRight]
                    corners = [corners, .topLeft]
                    corners = [corners, .bottomRight]
                    corners = [corners, .bottomLeft]
                    let rect = CGRect(x: 0, y: 0, width: skScene.frame.size.width, height: skScene.frame.size.height)
                    let cornerSize = CGSize(width: 10, height: 10)
                    
                    let shape = SKShapeNode()
                    shape.fillColor = UIColor.black
                    shape.path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: cornerSize).cgPath
                    shape.strokeColor = SKColor.red
                    shape.lineWidth = 2
                    skScene.addChild(shape)
                    
                    //the label we can update anytime we want
                    let labelNode = SKLabelNode(fontNamed:"Menlo-Bold")
                    labelNode.fontSize = 25
                    labelNode.fontColor = UIColor.white
                    labelNode.horizontalAlignmentMode = .left
                    labelNode.verticalAlignmentMode = .center
                    labelNode.position = CGPoint(x: 10, y: skScene.frame.size.height - 30)
                    labelNode.text = self.getNamePlayer(positionPlayer: positionName)
                    skScene.addChild(labelNode)
                    
                    let labelNumber = SKLabelNode(fontNamed:"Menlo-Bold")
                    labelNumber.fontSize = 25
                    labelNumber.fontColor = UIColor.white
                    labelNumber.horizontalAlignmentMode = .left
                    labelNumber.verticalAlignmentMode = .center
                    labelNumber.position = CGPoint(x: 10, y: labelNode.position.y - 30)
                    labelNumber.text = self.getNumberPlayer(positionPlayer: positionName)
                    skScene.addChild(labelNumber)
                    
                    let labelMatchPlayed = SKLabelNode(fontNamed:"Menlo-Bold")
                    labelMatchPlayed.fontSize = 25
                    labelMatchPlayed.fontColor = UIColor.white
                    labelMatchPlayed.horizontalAlignmentMode = .left
                    labelMatchPlayed.verticalAlignmentMode = .center
                    labelMatchPlayed.position = CGPoint(x: 10, y: labelNumber.position.y - 30)
                    labelMatchPlayed.text = self.getNumberMatchsPlayed(positionPlayer: positionName)
                    skScene.addChild(labelMatchPlayed)
                    
                    let labelGoals = SKLabelNode(fontNamed:"Menlo-Bold")
                    labelGoals.fontSize = 25
                    labelGoals.fontColor = UIColor.white
                    labelGoals.horizontalAlignmentMode = .left
                    labelGoals.verticalAlignmentMode = .center
                    labelGoals.position = CGPoint(x: 10, y: labelMatchPlayed.position.y - 30)
                    labelGoals.text = self.getNumberGoalsPlayer(positionPlayer: positionName)
                    skScene.addChild(labelGoals)
                    
                    let labelYellowCards = SKLabelNode(fontNamed:"Menlo-Bold")
                    labelYellowCards.fontSize = 25
                    labelYellowCards.fontColor = UIColor.white
                    labelYellowCards.horizontalAlignmentMode = .left
                    labelYellowCards.verticalAlignmentMode = .center
                    labelYellowCards.position = CGPoint(x: 10, y: labelGoals.position.y - 30)
                    labelYellowCards.text = self.getNumberYellowCardsPlayer(positionPlayer: positionName)
                    skScene.addChild(labelYellowCards)
                    
                    let labelRedCards = SKLabelNode(fontNamed:"Menlo-Bold")
                    labelRedCards.fontSize = 25
                    labelRedCards.fontColor = UIColor.white
                    labelRedCards.horizontalAlignmentMode = .left
                    labelRedCards.verticalAlignmentMode = .center
                    labelRedCards.position = CGPoint(x: 10, y: labelYellowCards.position.y - 30)
                    labelRedCards.text = self.getNumberRedCardsPlayer(positionPlayer: positionName)
                    skScene.addChild(labelRedCards)
                    
                    //create a plane to put the skScene on
                    let plane = SCNPlane(width: 0.2, height: 0.1)
                    let material = SCNMaterial()
                    material.lightingModel = SCNMaterial.LightingModel.constant
                    material.isDoubleSided = true
                    material.diffuse.contents = skScene
                    plane.materials = [material]
                    
                    //Add plane to a node, and node to the SCNScene
                    let hudNode = SCNNode(geometry: plane)
                    hudNode.name = "HUD"
                    hudNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 3.14159265)
                    hudNode.position = SCNVector3(x: newNode.position.x + 0.15, y: newNode.position.y + 0.1, z: newNode.position.z)
                    
                    self.sceneView.scene.rootNode.addChildNode(newNode)
                    self.sceneView.scene.rootNode.addChildNode(hudNode)
                    self.playerNodes.append(newNode)
                    self.playerNodes.append(hudNode)
                }
            }
        }
    }
    
    func getVideoPlayer(positionPlayer: String) -> URL? {
        switch positionPlayer {
        case "arquero":
            return Bundle.main.url(forResource: "orion", withExtension: "mp4", subdirectory: "art.scnassets")
        default:
            break
        }
        return nil
    }
    
    func getImagePlayerNode(positionPlayer: String) -> UIImage? {
        switch positionPlayer {
        case "mco":
            return UIImage(named: "valdivia")
        case "dcr":
            return UIImage(named: "paredes")
        case "dcl":
            return UIImage(named: "lucas")
        case "md":
            return UIImage(named: "opazo")
        case "mcl":
            return UIImage(named: "carmona")
        case "mcr":
            return UIImage(named: "baeza")
        case "mi":
            return UIImage(named: "damianperez")
        case "dfi":
            return UIImage(named: "insaurralde")
        case "dfc":
            return UIImage(named: "barroso")
        case "dfd":
            return UIImage(named: "zaldivia")
        case "arquero":
            return UIImage(named: "orion")
        default:
            break
        }
        return nil
    }
    
    func getNamePlayer(positionPlayer: String) -> String {
        switch positionPlayer {
        case "mco":
            return "JORGE VALDIVIA"
        case "dcr":
            return "ESTEBAN PAREDES"
        case "dcl":
            return "LUCAS BARRIOS"
        case "md":
            return "OSCAR OPAZO"
        case "mcl":
            return "CARLOS CARMONA"
        case "mcr":
            return "CLAUDIO BAEZA"
        case "mi":
            return "DAMIAN PEREZ"
        case "dfi":
            return "JUAN MANUEL INSAURRALDE"
        case "dfc":
            return "JULIO ALBERTO BARROSO"
        case "dfd":
            return "MATIAS ZALDIVIA"
        case "arquero":
            return "AGUSTIN ORION"
        default:
            break
        }
        return ""
    }
    
    func getNumberPlayer(positionPlayer: String) -> String {
        switch positionPlayer {
        case "mco":
            return "CAMISETA: 10"
        case "dcr":
            return "CAMISETA: 7"
        case "dcl":
            return "CAMISETA: 33"
        case "md":
            return "CAMISETA: 16"
        case "mcl":
            return "CAMISETA: 8"
        case "mcr":
            return "CAMISETA: 23"
        case "mi":
            return "CAMISETA: 15"
        case "dfi":
            return "CAMISETA: 6"
        case "dfc":
            return "CAMISETA: 5"
        case "dfd":
            return "CAMISETA: 4"
        case "arquero":
            return "CAMISETA: 1"
        default:
            break
        }
        return ""
    }
    
    func getNumberMatchsPlayed(positionPlayer: String) -> String {
        switch positionPlayer {
        case "mco":
            return "PARTIDOS: 5"
        case "dcr":
            return "PARTIDOS: 18"
        case "dcl":
            return "PARTIDOS: 5"
        case "md":
            return "PARTIDOS: 18"
        case "mcl":
            return "PARTIDOS: 15"
        case "mcr":
            return "PARTIDOS: 17"
        case "mi":
            return "PARTIDOS: 6"
        case "dfi":
            return "PARTIDOS: 18"
        case "dfc":
            return "PARTIDOS: 8"
        case "dfd":
            return "PARTIDOS: 19"
        case "arquero":
            return "PARTIDOS: 19"
        default:
            break
        }
        return ""
    }
    
    func getNumberGoalsPlayer(positionPlayer: String) -> String {
        switch positionPlayer {
        case "mco":
            return "GOLES: 1"
        case "dcr":
            return "GOLES: 16"
        case "dcl":
            return "GOLES: 2"
        case "md":
            return "GOLES: 0"
        case "mcl":
            return "GOLES: 0"
        case "mcr":
            return "GOLES: 1"
        case "mi":
            return "GOLES: 0"
        case "dfi":
            return "GOLES: 3"
        case "dfc":
            return "GOLES: 0"
        case "dfd":
            return "GOLES: 1"
        case "arquero":
            return "GOLES: 0"
        default:
            break
        }
        return ""
    }
    
    func getNumberYellowCardsPlayer(positionPlayer: String) -> String {
        switch positionPlayer {
        case "mco":
            return "AMARILLAS: 6"
        case "dcr":
            return "AMARILLAS: 4"
        case "dcl":
            return "AMARILLAS: 0"
        case "md":
            return "AMARILLAS: 2"
        case "mcl":
            return "AMARILLAS: 7"
        case "mcr":
            return "AMARILLAS: 7"
        case "mi":
            return "AMARILLAS: 1"
        case "dfi":
            return "AMARILLAS: 6"
        case "dfc":
            return "AMARILLAS: 0"
        case "dfd":
            return "AMARILLAS: 6"
        case "arquero":
            return "AMARILLAS: 1"
        default:
            break
        }
        return ""
    }
    
    func getNumberRedCardsPlayer(positionPlayer: String) -> String {
        switch positionPlayer {
        case "mco":
            return "ROJAS: 0"
        case "dcr":
            return "ROJAS: 0"
        case "dcl":
            return "ROJAS: 0"
        case "md":
            return "ROJAS: 2"
        case "mcl":
            return "ROJAS: 0"
        case "mcr":
            return "ROJAS: 0"
        case "mi":
            return "ROJAS: 0"
        case "dfi":
            return "ROJAS: 0"
        case "dfc":
            return "ROJAS: 0"
        case "dfd":
            return "ROJAS: 1"
        case "arquero":
            return "ROJAS 0"
        default:
            break
        }
        return ""
    }
    
    func removePlayersNode() {
        if playerNodes.count > 0 {
            playerNodes.forEach { (nodeToRemove) in
                nodeToRemove.removeFromParentNode()
            }
        }
    }
    
    func addLabel(text: String) -> SCNMaterial {
        let sk = SKScene(size: CGSize(width: 200, height: 200))
        sk.backgroundColor = UIColor.clear
        
        let rectangle = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 200, height: 200), cornerRadius: 10)
        rectangle.fillColor = UIColor.black
        rectangle.strokeColor = UIColor.white
        rectangle.lineWidth = 5
        rectangle.alpha = 0.5
        
        let lbl = SKLabelNode(text: text)
        lbl.fontSize = 160
        lbl.numberOfLines = 0
        lbl.fontColor = UIColor.white
        lbl.fontName = "Helvetica-Bold"
        lbl.position = CGPoint(x:100,y:100)
        lbl.preferredMaxLayoutWidth = 190
        lbl.horizontalAlignmentMode = .center
        lbl.verticalAlignmentMode = .center
        lbl.zRotation = .pi
        
        sk.addChild(rectangle)
        sk.addChild(lbl)
        
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = sk
        return material
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
