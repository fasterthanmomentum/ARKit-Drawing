import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var selectNode: SCNNode?
    var placedNodes = [SCNNode]()
    var planeNodes = [SCNNode]()
    var objectMode:  ObjectPlacementMode = .freeform {
     didSet {
        reloadConfiguration(removeAnchors: false)
        }
    }
    var lastObjectPlacedPoint: CGPoint?
    let touchDistanceThreshold:CGFloat = 40.0
    
    //var objectMode:  ObjectPlacementMode = .freeform {
    //   didSet {
    //     reloadConfiguration()
    //}
    
    let configuration = ARWorldTrackingConfiguration()
    
    enum ObjectPlacementMode {
        case freeform, plane, image
    }
    
   // var objectMode: ObjectPlacementMode = .freeform
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
           reloadConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     
       reloadConfiguration()
        //.sceneView.session.pause()
    }
    func reloadConfiguration(removeAnchors: Bool = true) {
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.detectionImages = (objectMode == .image) ?
            ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) : nil
        let options: ARSession.RunOptions
        if removeAnchors {
            options = [.removeExistingAnchors]
            for node in placedNodes {
                node.removeFromParentNode()
            }
            placedNodes.removeAll()
        } else {
            options = []
        }
        sceneView.session.run(configuration)
    }
    
    
    
    
    
    

    @IBAction func changeObjectMode(_ sender: UISegmentedControl) {

        
        
        
        
        switch sender.selectedSegmentIndex {
        case 0:
            objectMode = .freeform
        case 1:
            objectMode = .plane
        case 2:
            objectMode = .image
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOptions" {
            let optionsViewController = segue.destination as! OptionsContainerViewController
            optionsViewController.delegate = self
        }
    }
    
    func addNodeToSceneRoot(_ node: SCNNode) {
        let cloneNode = node.clone()
        sceneView.scene.rootNode.addChildNode(cloneNode)
        placedNodes.append(cloneNode)
        
    }
    
    
    func addNodeInFront(_ node: SCNNode) {
        guard let currentFrame = sceneView.session.currentFrame
            else { return }
        //set transform of node to be 20 cm in front of the camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        node.simdTransform =
        matrix_multiply(currentFrame.camera.transform, translation)
        addNodeToSceneRoot(node)
    }
       // let cloneNode = node.clone()
        ////sceneView.scene.rootNode.addChildNode(cloneNode)
        
 //   }


override func touchesBegan(_ touches: Set<UITouch>, with event:
    UIEvent?) {
    super.touchesBegan(touches, with: event)
    guard let node = selectNode, let touch =
        touches.first else { return }
    
    switch objectMode {
    case .freeform:
        addNodeInFront(node)
    case .plane:
        let touchPoint = touch.location(in: sceneView)
        addNode(node, toPlaneUsingPoint: touchPoint)
    case .image:
        break
    }
}
    func addNode(_ node: SCNNode, toPlaneUsingPoint point: CGPoint) {
        let results = sceneView.hitTest(point, types:
        [.existingPlaneUsingExtent])
        if let match = results.first {
            let t = match.worldTransform
            node.position = SCNVector3(x: t.columns.3.x, y:
                t.columns.3.y, z: t.columns.3.z)
            addNodeToSceneRoot(node)
            lastObjectPlacedPoint = point
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with
        event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard objectMode == .plane,
        let node = selectNode,
        let touch = touches.first,
            let lastTouchPoint = lastObjectPlacedPoint else {
                return
        }
        let newTouchPoint = touch.location(in: sceneView)
        //addNode(node, toPlaneUsingPoint: newTouchPoint)
        let distance = sqrt(pow((newTouchPoint.x -
        lastTouchPoint.x), 2.0) + pow((newTouchPoint.y - lastTouchPoint.y), 2.0))
        if distance > touchDistanceThreshold {
            addNode(node, toPlaneUsingPoint: newTouchPoint)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        lastObjectPlacedPoint = nil
    }














}
















extension ViewController: OptionsViewControllerDelegate {
   

    
    
    
    
    func objectSelected(node: SCNNode) {
        dismiss(animated: true, completion: nil)
        selectNode = node
    }
    
    func togglePlaneVisualization() {
        dismiss(animated: true, completion: nil)
        //var objectMode:  ObjectPlacementMode = .freeform {
        //   didSet {
        //     reloadConfiguration()
        //}
        var showPlaneOverlay = false {
            didSet {
                for node in planeNodes {
                    node.isHidden = !showPlaneOverlay
                }
            }
        }
        
        showPlaneOverlay = !showPlaneOverlay
    }
    
    func undoLastObject() {
        if let lastNode = placedNodes.last {
            lastNode.removeFromParentNode()
            placedNodes.removeLast()
        }
        
    }
    
    func resetScene() {
        dismiss(animated: true, completion: nil)
        reloadConfiguration()
    }

    
    
    
    
    
    
    
}

