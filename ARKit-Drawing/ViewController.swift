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
            reloadConfiguration()
        }
    }
    var showPlaneOverlay = false {
        didSet{
        for node in planeNodes {
        node.isHidden = !showPlaneOverlay
        }
    }
}
    
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
     
        sceneView.session.pause()
    }
    func reloadConfiguration() {
        configuration.detectionImages = (objectMode == .image) ?
            ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) : nil
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
        break
    case .image:
        break
    }
}
}











extension ViewController: OptionsViewControllerDelegate {
    
    func objectSelected(node: SCNNode) {
        dismiss(animated: true, completion: nil)
        selectNode = node
    }
    
    func togglePlaneVisualization() {
        dismiss(animated: true, completion: nil)
        showPlaneOverlay = !showPlaneOverlay
    }
    
    func undoLastObject() {
        
    }
    
    func resetScene() {
        dismiss(animated: true, completion: nil)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node:
        SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            nodeAdded(node, for: imageAnchor)
        } else if let planeAnchor = anchor as? ARPlaneAnchor {
            nodeAdded(node, for: planeAnchor)
        }
    }
   
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node:
        SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
        let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane else {
                return
        }
        planeNode.position = SCNVector3(planeAnchor.center.x, 0,
        planeAnchor.center.z)
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        let geometry = SCNPlane(width:
            CGFloat(planeAnchor.extent.x), height:
            CGFloat(planeAnchor.extent.z))
        node.geometry = geometry
        node.eulerAngles.x = -Float.pi / 2
        node.opacity = 0.25
        
        return node
    }
    
    
    
    
    
    
    func nodeAdded(_ node: SCNNode, for anchor: ARPlaneAnchor) {
        let floor = createFloor(planeAnchor: anchor)
        floor.isHidden = !showPlaneOverlay
        node.addChildNode(floor)
        planeNodes.append(floor)
    }
    
 
    
    
    func nodeAdded(_ node: SCNNode, for anchor: ARImageAnchor) {
        if let selectNode = selectNode {
            addNode(selectNode, toImageUsingParentNode: node)
        }
    }
    
    func addNode(_ node: SCNNode, toImageUsingParentNode parentNode: SCNNode) {
        let cloneNode = node.clone()
        parentNode.addChildNode(cloneNode)
        placedNodes.append(cloneNode)
    }

    
    
    
    
    
    
    
    
    
    
}
