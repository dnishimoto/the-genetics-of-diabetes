//
//  GeneRepairView.swift
//  The Genetics of Diabetes
//
//  Created by David Nishimoto on 7/1/26.
//
//  Updated: DNA now uses editable base-pair nodes and Step 5 zooms into
//  the local repair site so Cas9, Cas3, and guide RNA/sgRNA can be shown
//  as a step-by-step molecular process.
//

import SwiftUI
import SceneKit

struct GeneRepair3DView: View {

    struct NucleotideNode {
        let index: Int
        let leftBase: String
        let rightBase: String
        let leftNode: SCNNode
        let rightNode: SCNNode
        let leftBackbone: SCNNode
        let rightBackbone: SCNNode
        let rung: SCNNode
        let y: Float
    }

    @State private var scene = SCNScene()

    @State private var cameraNode = SCNNode()
    @State private var lookTargetNode = SCNNode()

    @State private var helixNode = SCNNode()
    @State private var helixNode2 = SCNNode()

    @State private var targetSiteNode = SCNNode()
    @State private var pamNode = SCNNode()
    @State private var guideRNANode = SCNNode()
    @State private var cas9Node = SCNNode()
    @State private var cas3Node = SCNNode()
    @State private var helicaseNode = SCNNode()
    @State private var surveillanceNode = SCNNode()

    @State private var donorCas9Node = SCNNode()
    @State private var donorCas3Node = SCNNode()

    @State private var hiddenCas9Nodes: [SCNNode] = []
    @State private var hiddenCas3Nodes: [SCNNode] = []

    @State private var backboneNodes: [SCNNode] = []
    @State private var nucleotideNodes: [NucleotideNode] = []

    @State private var stepIndex: Int = 0
    @State private var isRunningSequence: Bool = false
    @State private var manualAdvance: Bool = true
    @State private var stepWorkItem: DispatchWorkItem?

    struct StepInfo: Identifiable {
        let id = UUID()
        let title: String
        let activity: String?
        let description: String
        let duration: Double
    }

    private let steps: [StepInfo] = [
        StepInfo(
            title: "Step 1 — Identify the Regulatory Variant",
            activity: "CRISPR Activity: None",
            description: "Analyze the DNA sequence to locate rs7903146, a single-letter regulatory variant (SNP) in an intronic region of TCF7L2—a master gene controlling the Wnt signaling pathway and the single strongest common genetic risk factor for Type 2 diabetes (Grant et al., 2006; Nature Genetics). Correcting its dysregulation directly restores healthy insulin output in targeted pancreatic cells.",
            duration: 3.0
        ),
        StepInfo(
            title: "Step 2 — Understand the Regulatory Region",
            activity: "CRISPR Activity: None",
            description: "Determine how this non-coding intronic/enhancer region acts as a faulty dimmer switch, impairing transcription-factor landing pads and TCF7L2 gene expression (Zhou et al., 2014; Human Molecular Genetics). Targeting this control region allows researchers to restore healthy gene levels without altering the essential protein blueprint.",
            duration: 3.0
        ),
        StepInfo(
            title: "Step 3 — Select the Editing Strategy",
            activity: nil,
            description: "Cas9 acts like a fine-tipped pen to fix single-letter mutations like rs7903146 while leaving neighboring control architecture intact (Jinek et al., 2012; Science). Cas3 works with a Cascade surveillance scout complex as a DNA shredder to erase broad functional zones for research (Sinkunas et al., 2011; EMBO Journal).",
            duration: 3.0
        ),
        StepInfo(
            title: "Step 4 — Locate the TCF7L2 Regulatory Region",
            activity: nil,
            description: "Cas9 searches the genome for a PAM safety lock sequence before opening the DNA and pairing with the sgRNA molecular GPS (Sternberg et al., 2014; Nature). Cas3 requires the Cascade scout complex to find and bind the exact chromosomal coordinates first (Makarova et al., 2011; Nature Reviews Microbiology).",
            duration: 3.0
        ),
        StepInfo(
            title: "Step 5 — DNA Base-Pair Repair",
            activity: nil,
            description: "The sgRNA pairs with target DNA adjacent to the PAM like a key in a lock, directing base editing machinery (deaminase enzymes) to chemically rewrite the rs7903146 risk letter without creating double-strand breaks or unpredictable insertions/deletions (Nishimasu et al., 2014; Cell; Komor et al., 2016; Nature).",
            duration: 5.0
        ),
        StepInfo(
            title: "Step 6 — DNA Modification",
            activity: nil,
            description: "Cas9 holds the site steady for precise point-mutation repair (Komor et al., 2016; Nature). Cas3 uses helicase and nuclease activity to unzip and processively chew up thousands of DNA base pairs, deleting the full enhancer region (Dolan et al., 2019; Molecular Cell).",
            duration: 3.0
        ),
        StepInfo(
            title: "Step 7 — Cellular Response",
            activity: nil,
            description: "Following Cas9 base editing, cellular repair pathways seal the edit to restore physiological TCF7L2 expression (Cox et al., 2015; Nature Medicine). Cas3 deletions permanently remove the targeted regulatory segment to probe its functional role (Dolan et al., 2019; Molecular Cell).",
            duration: 2.5
        ),
        StepInfo(
            title: "Step 8 — Functional Evaluation",
            activity: "CRISPR Activity: None",
            description: "Assess TCF7L2 expression and downstream Wnt signaling in pancreatic beta cells to verify that glucose-responsive insulin secretion is restored when blood sugar rises—the ultimate functional metric for reversing diabetes risk (Lyssenko et al., 2007; Journal of Clinical Investigation).",
            duration: 3.0
        )
    ]
    var body: some View {
        ZStack(alignment: .topLeading) {
            SceneView(scene: scene, pointOfView: cameraNode, options: [.allowsCameraControl, .autoenablesDefaultLighting])
                .onAppear {
                    setupScene()
                    startSequence()
                }
                .onDisappear {
                    stopSequence()
                }

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 4) {
                    let step = steps[stepIndex]

                    Text(step.title)
                        .font(.subheadline)
                        .foregroundColor(.white)

                    if let activity = step.activity {
                        Text(activity)
                            .font(.default)
                            .foregroundColor(.white.opacity(0.85))
                    }

                    Text(step.description)
                        .font(.default)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 4) {
                        ForEach(steps.indices, id: \.self) { i in
                            Circle()
                                .fill(i == stepIndex ? Color.accentColor : Color.white.opacity(0.3))
                                .frame(width: i == stepIndex ? 7 : 5, height: i == stepIndex ? 7 : 5)
                        }
                    }
                    .padding(.top, 2)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: 110)
            .background(Color.black.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { advanceStepManually() }) {
                        Label(stepIndex < steps.count - 1 ? "Next" : "Restart",
                              systemImage: stepIndex < steps.count - 1 ? "arrow.right.circle.fill" : "gobackward")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.55))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(12)
                }
            }
        }
    }

    // MARK: - Scene Setup

    private func setupScene() {
        stopSequence()

        scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }

        hiddenCas9Nodes.removeAll()
        hiddenCas3Nodes.removeAll()
        backboneNodes.removeAll()
        nucleotideNodes.removeAll()

        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 28)
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 200
        scene.rootNode.addChildNode(cameraNode)

        lookTargetNode = SCNNode()
        lookTargetNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(lookTargetNode)

        let lookAt = SCNLookAtConstraint(target: lookTargetNode)
        lookAt.isGimbalLockEnabled = true
        cameraNode.constraints = [lookAt]

        let omniLight = SCNLight()
        omniLight.type = .omni
        omniLight.intensity = 900
        let lightNode = SCNNode()
        lightNode.light = omniLight
        lightNode.position = SCNVector3(10, 10, 20)
        scene.rootNode.addChildNode(lightNode)

        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 300
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        let background = SCNFloor()
        background.firstMaterial?.diffuse.contents = UIColor.black
        background.firstMaterial?.isDoubleSided = true
        let floorNode = SCNNode(geometry: background)
        floorNode.position = SCNVector3(0, -18, 0)
        floorNode.opacity = 0.12
        scene.rootNode.addChildNode(floorNode)

        helixNode = SCNNode()
        helixNode2 = SCNNode()
        buildEditableDoubleHelix()

        scene.rootNode.addChildNode(helixNode)
        scene.rootNode.addChildNode(helixNode2)

        targetSiteNode = makeMarkerNode(color: .systemRed, radius: 0.45)
        targetSiteNode.position = SCNVector3(0, -2, 4)
        scene.rootNode.addChildNode(targetSiteNode)

        pamNode = makeLabelNode(text: "PAM", color: .systemYellow, size: 0.55)
        pamNode.position = SCNVector3(1.2, -2, 3.9)
        scene.rootNode.addChildNode(pamNode)

        guideRNANode = makeLabelNode(text: "sgRNA", color: .systemCyan, size: 0.6)
        guideRNANode.position = SCNVector3(-10, -2, 1)
        scene.rootNode.addChildNode(guideRNANode)

        let cas9 = SCNSphere(radius: 0.7)
        cas9.firstMaterial?.diffuse.contents = UIColor.systemPurple
        cas9.firstMaterial?.emission.contents = UIColor.systemPurple.withAlphaComponent(0.18)
        cas9Node = SCNNode(geometry: cas9)
        cas9Node.position = SCNVector3(-12, -2, 0)
        scene.rootNode.addChildNode(cas9Node)

        let cas3 = SCNSphere(radius: 0.7)
        cas3.firstMaterial?.diffuse.contents = UIColor.systemOrange
        cas3.firstMaterial?.emission.contents = UIColor.systemOrange.withAlphaComponent(0.18)
        cas3Node = SCNNode(geometry: cas3)
        cas3Node.position = SCNVector3(12, 2, 0)
        cas3Node.opacity = 0.0
        scene.rootNode.addChildNode(cas3Node)

        let helicase = SCNSphere(radius: 0.5)
        helicase.firstMaterial?.diffuse.contents = UIColor.systemTeal
        helicase.firstMaterial?.emission.contents = UIColor.systemTeal.withAlphaComponent(0.18)
        helicaseNode = SCNNode(geometry: helicase)
        helicaseNode.position = SCNVector3(4, -5, 2)
        helicaseNode.opacity = 0.0
        scene.rootNode.addChildNode(helicaseNode)

        let surveillance = SCNSphere(radius: 0.45)
        surveillance.firstMaterial?.diffuse.contents = UIColor.systemGray
        surveillance.firstMaterial?.emission.contents = UIColor.systemGray.withAlphaComponent(0.12)
        surveillanceNode = SCNNode(geometry: surveillance)
        surveillanceNode.position = SCNVector3(10, 2, 0)
        surveillanceNode.opacity = 0.0
        scene.rootNode.addChildNode(surveillanceNode)

        let spin = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0.6, z: 0, duration: 4))
        helixNode.runAction(spin)
        helixNode2.runAction(spin)
    }

    private func buildEditableDoubleHelix() {
        let turns = 20
        let pairs = [
            ("A", "T"), ("C", "G"), ("T", "A"), ("G", "C"), ("A", "T"),
            ("T", "A"), ("C", "G"), ("G", "C"), ("A", "T"), ("T", "A"),
            ("C", "G"), ("G", "C"), ("A", "T"), ("T", "A"), ("C", "G"),
            ("G", "C"), ("A", "T"), ("T", "A"), ("C", "G"), ("G", "C")
        ]

        for i in 0..<turns {
            let t = Float(i) * 0.45
            let x = sin(t) * 2.4
            let y = (Float(i) - Float(turns) / 2) * 0.75
            let z = cos(t) * 2.4

            let leftBase = pairs[i].0
            let rightBase = pairs[i].1

            let leftNode = makeBaseNode(base: leftBase, color: colorForBase(leftBase), radius: 0.2)
            leftNode.position = SCNVector3(x, y, z)
            helixNode.addChildNode(leftNode)

            let rightNode = makeBaseNode(base: rightBase, color: colorForBase(rightBase), radius: 0.2)
            rightNode.position = SCNVector3(-x, y, -z)
            helixNode2.addChildNode(rightNode)

            let leftBackbone = makeBackboneNode()
            leftBackbone.position = SCNVector3(x * 0.55, y, z * 0.55)
            helixNode.addChildNode(leftBackbone)

            let rightBackbone = makeBackboneNode()
            rightBackbone.position = SCNVector3(-x * 0.55, y, -z * 0.55)
            helixNode2.addChildNode(rightBackbone)

            let rung = makeRungNode(color: UIColor.white.withAlphaComponent(0.55), length: CGFloat(abs(x) * 2.0 + abs(z) * 2.0))
            rung.eulerAngles = SCNVector3(0, t, 0)
            rung.position = SCNVector3(0, y, 0)
            scene.rootNode.addChildNode(rung)

            nucleotideNodes.append(
                NucleotideNode(
                    index: i,
                    leftBase: leftBase,
                    rightBase: rightBase,
                    leftNode: leftNode,
                    rightNode: rightNode,
                    leftBackbone: leftBackbone,
                    rightBackbone: rightBackbone,
                    rung: rung,
                    y: y
                )
            )

            backboneNodes.append(leftBackbone)
            backboneNodes.append(rightBackbone)
        }
    }

    private func makeBaseNode(base: String, color: UIColor, radius: CGFloat) -> SCNNode {
        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.diffuse.contents = color
        sphere.firstMaterial?.emission.contents = color.withAlphaComponent(0.18)
        let node = SCNNode(geometry: sphere)
        node.name = base
        return node
    }

    private func makeBackboneNode() -> SCNNode {
        let cyl = SCNCylinder(radius: 0.06, height: 0.9)
        cyl.firstMaterial?.diffuse.contents = UIColor.systemGray.withAlphaComponent(0.7)
        let node = SCNNode(geometry: cyl)
        node.eulerAngles.x = .pi / 2
        return node
    }

    private func makeRungNode(color: UIColor, length: CGFloat) -> SCNNode {
        let cyl = SCNCylinder(radius: 0.045, height: max(length, 0.15))
        cyl.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: cyl)
        node.eulerAngles.z = .pi / 2
        return node
    }

    private func colorForBase(_ base: String) -> UIColor {
        switch base.uppercased() {
        case "A": return .systemGreen
        case "T": return .systemRed
        case "C": return .systemBlue
        case "G": return .systemYellow
        default: return .white
        }
    }

    private func makeMarkerNode(color: UIColor, radius: CGFloat) -> SCNNode {
        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.diffuse.contents = color
        sphere.firstMaterial?.emission.contents = color.withAlphaComponent(0.25)
        return SCNNode(geometry: sphere)
    }

    private func makeLabelNode(text: String, color: UIColor, size: CGFloat) -> SCNNode {
        let textGeo = SCNText(string: text, extrusionDepth: 0.05)
        textGeo.font = UIFont.systemFont(ofSize: 4, weight: .bold)
        textGeo.flatness = 0.2
        textGeo.firstMaterial?.diffuse.contents = color
        textGeo.firstMaterial?.emission.contents = color.withAlphaComponent(0.2)

        let node = SCNNode(geometry: textGeo)
        let (minB, maxB) = textGeo.boundingBox
        let width = maxB.x - minB.x
        let height = maxB.y - minB.y
        //let scale = Float(size) / max(width, height)
        let scale = (Float(size) / max(width, height)) * 0.7
        node.scale = SCNVector3(scale, scale, scale)
        node.pivot = SCNMatrix4MakeTranslation((minB.x + maxB.x) / 2, minB.y, 0)
        return node
    }

    // MARK: - Sequencing

    private func startSequence() {
        guard !isRunningSequence else { return }
        isRunningSequence = true
        stepIndex = 0
        runStep(at: 0)
    }

    private func stopSequence() {
        isRunningSequence = false
        stepWorkItem?.cancel()
        stepWorkItem = nil
    }

    private func restartSequence() {
        stopSequence()
        stepIndex = 0
        setupScene()
        startSequence()
    }

    private func runStep(at index: Int) {
        guard index < steps.count else {
            isRunningSequence = false
            return
        }

        stepIndex = index
        stepWorkItem?.cancel()

        cas9Node.removeAllActions()
        cas3Node.removeAllActions()
        helicaseNode.removeAllActions()
        targetSiteNode.removeAllActions()
        pamNode.removeAllActions()
        guideRNANode.removeAllActions()
        surveillanceNode.removeAllActions()
        donorCas9Node.removeAllActions()
        donorCas3Node.removeAllActions()

        switch index {
        case 0:
            focusCamera(to: SCNVector3(0, 0, 24), lookAt: targetSiteNode.position, duration: 1.0)
            targetSiteNode.opacity = 1.0
            pamNode.opacity = 1.0
            guideRNANode.opacity = 0.0
            cas9Node.opacity = 0.25
            cas3Node.opacity = 0.0
            helicaseNode.opacity = 0.0
            surveillanceNode.opacity = 0.0

            let pulse = SCNAction.sequence([
                SCNAction.scale(to: 1.18, duration: 0.35),
                SCNAction.scale(to: 1.0, duration: 0.35)
            ])
            targetSiteNode.runAction(SCNAction.repeat(pulse, count: 2))

        case 1:
            focusCamera(to: SCNVector3(0, -0.5, 20), lookAt: targetSiteNode.position, duration: 1.0)
            targetSiteNode.opacity = 1.0
            pamNode.opacity = 1.0
            guideRNANode.opacity = 0.35
            cas9Node.opacity = 0.25
            cas3Node.opacity = 0.0
            helicaseNode.opacity = 0.0
            surveillanceNode.opacity = 0.0

            if let mat = targetSiteNode.geometry?.firstMaterial {
                let original = mat.emission.contents
                mat.emission.contents = UIColor.systemYellow.withAlphaComponent(0.7)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    mat.emission.contents = original
                }
            }

            let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1.2, z: 0, duration: 1.2))
            guideRNANode.runAction(rotate)

        case 2:
            let cas9Destination = SCNVector3(-6, -2, 2)
            let cas3Destination = SCNVector3(8, 2, 1)
            let midpoint = SCNVector3((cas9Destination.x + cas3Destination.x) / 2,
                                      (cas9Destination.y + cas3Destination.y) / 2,
                                      (cas9Destination.z + cas3Destination.z) / 2 + 1.0)
            focusCamera(to: SCNVector3(0, 0, 20), lookAt: midpoint, duration: 1.0)

            cas9Node.opacity = 1.0
            cas3Node.opacity = 1.0
            helicaseNode.opacity = 0.0
            guideRNANode.opacity = 0.9
            pamNode.opacity = 1.0

            cas9Node.runAction(SCNAction.move(to: cas9Destination, duration: 0.8))
            cas3Node.runAction(SCNAction.move(to: cas3Destination, duration: 0.8))

            let cas9Pulse = SCNAction.repeatForever(SCNAction.sequence([
                SCNAction.scale(to: 1.12, duration: 0.35),
                SCNAction.scale(to: 1.0, duration: 0.35)
            ]))
            cas9Node.runAction(cas9Pulse)

        case 3:
            let finalScanPoint = SCNVector3(-2.1, -2, 3.0)
            focusCamera(to: SCNVector3(-1, -1, 15), lookAt: finalScanPoint, duration: 1.1)

            cas9Node.opacity = 1.0
            cas3Node.opacity = 1.0
            helicaseNode.opacity = 1.0
            surveillanceNode.opacity = 0.7
            guideRNANode.opacity = 1.0
            pamNode.opacity = 1.0

            let cas9Scan = SCNAction.sequence([
                SCNAction.move(to: SCNVector3(-5.8, -2, 4), duration: 0.7),
                SCNAction.move(to: SCNVector3(-3.8, -2, 2.3), duration: 0.5),
                SCNAction.move(to: finalScanPoint, duration: 0.5)
            ])
            cas9Node.runAction(cas9Scan)

            let helicaseSpin = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 3.5, z: 0, duration: 0.8))
            helicaseNode.runAction(helicaseSpin)

            surveillanceNode.runAction(SCNAction.fadeOpacity(to: 1.0, duration: 0.6))

            let guidePath = SCNAction.sequence([
                SCNAction.move(to: SCNVector3(-4, -2, 3.2), duration: 0.7),
                SCNAction.move(to: SCNVector3(-2, -2, 3.0), duration: 0.5)
            ])
            guideRNANode.runAction(guidePath)

        case 4:
            let dockingPoint = SCNVector3(-0.9, -2, 2.3)
            focusCamera(to: SCNVector3(-0.5, -1.5, 11), lookAt: dockingPoint, duration: 1.0)

            cas9Node.opacity = 1.0
            cas3Node.opacity = 1.0
            helicaseNode.opacity = 1.0
            guideRNANode.opacity = 1.0
            pamNode.opacity = 1.0

            let moveToSite = SCNAction.move(to: SCNVector3(-1.0, -2, 2.2), duration: 0.8)
            let glow = SCNAction.run { _ in
                self.targetSiteNode.geometry?.firstMaterial?.diffuse.contents = UIColor.systemYellow
                self.targetSiteNode.geometry?.firstMaterial?.emission.contents = UIColor.systemYellow.withAlphaComponent(0.25)
            }
            cas9Node.runAction(SCNAction.sequence([moveToSite, glow]))

            let guideDock = SCNAction.move(to: SCNVector3(-0.8, -2, 2.4), duration: 0.8)
            guideRNANode.runAction(guideDock)

            let helicasePulse = SCNAction.sequence([
                SCNAction.scale(to: 1.15, duration: 0.25),
                SCNAction.scale(to: 1.0, duration: 0.25)
            ])
            helicaseNode.runAction(SCNAction.repeat(helicasePulse, count: 2))

        case 5:
            runDetailedRepairSequence()

        case 6:
            focusCamera(to: SCNVector3(0, -1, 13), lookAt: targetSiteNode.position, duration: 1.0)

            let torus = SCNTorus(ringRadius: 1.2, pipeRadius: 0.05)
            torus.firstMaterial?.diffuse.contents = UIColor.systemGreen.withAlphaComponent(0.6)
            let halo = SCNNode(geometry: torus)
            halo.position = targetSiteNode.position
            halo.opacity = 0.0
            scene.rootNode.addChildNode(halo)

            halo.runAction(SCNAction.sequence([
                SCNAction.fadeIn(duration: 0.2),
                SCNAction.wait(duration: 0.6),
                SCNAction.fadeOut(duration: 0.4)
            ])) {
                halo.removeFromParentNode()
            }

            let restorePulse = SCNAction.sequence([
                SCNAction.scale(to: 1.12, duration: 0.25),
                SCNAction.scale(to: 1.0, duration: 0.25)
            ])
            targetSiteNode.runAction(restorePulse)

        case 7:
            focusCamera(to: SCNVector3(0, 2, 26), lookAt: SCNVector3(0, 0, 0), duration: 1.2)
            targetSiteNode.opacity = 1.0
            pamNode.opacity = 1.0
            guideRNANode.opacity = 1.0
            cas9Node.opacity = 0.35
            cas3Node.opacity = 0.35
            helicaseNode.opacity = 0.2
            surveillanceNode.opacity = 0.0

            let calm = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0.4, z: 0, duration: 4))
            helixNode.runAction(calm)
            helixNode2.runAction(calm)

        default:
            break
        }

        guard manualAdvance == false else { return }

        let delay = steps[index].duration
        let item = DispatchWorkItem {
            let next = index + 1
            if next < steps.count {
                runStep(at: next)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    restartSequence()
                }
            }
        }

        stepWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }

    // MARK: - Step 5 detailed repair sequence

    private func runDetailedRepairSequence() {
        //focusCamera(to: SCNVector3(0, -1.0, 3.3), lookAt: targetSiteNode.position, duration: 1.0)
        
        focusCamera(to: SCNVector3(0, -1.0, 6.5), lookAt: targetSiteNode.position, duration: 1.0)
        
        guideRNANode.opacity = 0.55
        cas9Node.opacity = 0.75
        cas3Node.opacity = 0.55
        helicaseNode.opacity = 0.45
        surveillanceNode.opacity = 0.35

        guideRNANode.renderingOrder = 10
        cas9Node.renderingOrder = 11
        cas3Node.renderingOrder = 12
        helicaseNode.renderingOrder = 13
        surveillanceNode.renderingOrder = 14

        hideMostOfHelix(aroundY: targetSiteNode.position.y, visibleWindow: 3)
        showLocalNucleotidesDetailed(aroundY: targetSiteNode.position.y)

        guideRNANode.runAction(
            SCNAction.sequence([
                SCNAction.move(to: SCNVector3(-1.1, -2.0, 2.8), duration: 0.7),
                SCNAction.scale(to: 1.15, duration: 0.15),
                SCNAction.scale(to: 1.0, duration: 0.15)
            ])
        )

        cas9Node.runAction(
            SCNAction.sequence([
                SCNAction.move(to: SCNVector3(-0.5, -2.0, 2.4), duration: 0.7),
                SCNAction.scale(to: 1.12, duration: 0.15),
                SCNAction.scale(to: 1.0, duration: 0.15)
            ])
        )

        cas3Node.runAction(
            SCNAction.sequence([
                SCNAction.fadeOpacity(to: 0.9, duration: 0.5),
                SCNAction.move(to: SCNVector3(1.6, -2.0, 2.2), duration: 0.8)
            ])
        )

        helicaseNode.runAction(
            SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 4.0, z: 0, duration: 0.5))
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.markPairingWindow()
            self.openLocalBackbone()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.80) {
            self.showGuideRNAAlignment()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.10) {
            self.removeDamagedLocalPair()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.60) {
            self.insertCorrectedDonorPair()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.20) {
            self.resealLocalBackbone()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.80) {
            self.closeLocalBackbone()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.20) {
            self.targetSiteNode.geometry?.firstMaterial?.diffuse.contents = UIColor.systemGreen
            self.targetSiteNode.geometry?.firstMaterial?.emission.contents = UIColor.systemGreen.withAlphaComponent(0.35)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.60) {
            self.showFullHelixAgain()
        }
    }

    private func hideMostOfHelix(aroundY centerY: Float, visibleWindow: Int) {
        let sortedA = helixNode.childNodes.sorted { abs($0.position.y - centerY) < abs($1.position.y - centerY) }
        let sortedB = helixNode2.childNodes.sorted { abs($0.position.y - centerY) < abs($1.position.y - centerY) }

        let keepA = Set(sortedA.prefix(visibleWindow).map { ObjectIdentifier($0) })
        let keepB = Set(sortedB.prefix(visibleWindow).map { ObjectIdentifier($0) })

        for node in helixNode.childNodes where !keepA.contains(ObjectIdentifier(node)) {
            node.opacity = 0.08
        }
        for node in helixNode2.childNodes where !keepB.contains(ObjectIdentifier(node)) {
            node.opacity = 0.08
        }
    }

    private func showLocalNucleotidesDetailed(aroundY centerY: Float) {
        let localA = helixNode.childNodes.filter { abs($0.position.y - centerY) < 1.6 }
        let localB = helixNode2.childNodes.filter { abs($0.position.y - centerY) < 1.6 }

        for node in localA + localB {
            node.runAction(SCNAction.fadeOpacity(to: 1.0, duration: 0.2))
        }

        for nuc in nucleotideNodes where abs(nuc.y - centerY) < 1.6 {
            nuc.leftNode.runAction(SCNAction.scale(to: 1.25, duration: 0.12))
            nuc.rightNode.runAction(SCNAction.scale(to: 1.25, duration: 0.12))
        }
    }

    private func markPairingWindow() {
        let centerY = targetSiteNode.position.y
        for nuc in nucleotideNodes where abs(nuc.y - centerY) < 1.0 {
            nuc.leftNode.geometry?.firstMaterial?.emission.contents = UIColor.systemYellow.withAlphaComponent(0.35)
            nuc.rightNode.geometry?.firstMaterial?.emission.contents = UIColor.systemYellow.withAlphaComponent(0.35)
            nuc.rung.geometry?.firstMaterial?.diffuse.contents = UIColor.systemYellow.withAlphaComponent(0.6)
        }
    }

    private func openLocalBackbone() {
        let centerY = targetSiteNode.position.y
        let local = nucleotideNodes.filter { abs($0.y - centerY) < 1.0 }

        for nuc in local {
            nuc.leftNode.runAction(SCNAction.moveBy(x: -0.18, y: 0, z: 0.08, duration: 0.2))
            nuc.rightNode.runAction(SCNAction.moveBy(x: 0.18, y: 0, z: -0.08, duration: 0.2))
        }

        guideRNANode.opacity = 1.0
        cas9Node.opacity = 1.0
    }

    private func showGuideRNAAlignment() {
        let centerY = targetSiteNode.position.y
        for nuc in nucleotideNodes where abs(nuc.y - centerY) < 0.8 {
            nuc.leftNode.geometry?.firstMaterial?.emission.contents = UIColor.systemGreen.withAlphaComponent(0.45)
            nuc.rightNode.geometry?.firstMaterial?.emission.contents = UIColor.systemGreen.withAlphaComponent(0.45)
        }
    }

    private func removeDamagedLocalPair() {
        let centerY = targetSiteNode.position.y
        guard let damaged = nucleotideNodes.min(by: { abs($0.y - centerY) < abs($1.y - centerY) }) else { return }

        damaged.leftNode.runAction(
            SCNAction.sequence([
                SCNAction.moveBy(x: -0.35, y: 0.15, z: 0.1, duration: 0.2),
                SCNAction.fadeOut(duration: 0.18),
                SCNAction.removeFromParentNode()
            ])
        )

        damaged.rightNode.runAction(
            SCNAction.sequence([
                SCNAction.moveBy(x: 0.35, y: -0.15, z: -0.1, duration: 0.2),
                SCNAction.fadeOut(duration: 0.18),
                SCNAction.removeFromParentNode()
            ])
        )

        damaged.rung.runAction(
            SCNAction.sequence([
                SCNAction.fadeOut(duration: 0.18),
                SCNAction.removeFromParentNode()
            ])
        )
    }

    private func insertCorrectedDonorPair() {
        let centerY = targetSiteNode.position.y

        let left = makeBaseNode(base: "C", color: .systemBlue, radius: 0.2)
        left.position = SCNVector3(-0.55, centerY, 0.14)
        left.opacity = 0.0
        scene.rootNode.addChildNode(left)

        let right = makeBaseNode(base: "G", color: .systemYellow, radius: 0.2)
        right.position = SCNVector3(0.55, centerY, -0.14)
        right.opacity = 0.0
        scene.rootNode.addChildNode(right)

        left.runAction(
            SCNAction.sequence([
                SCNAction.move(to: SCNVector3(-0.92, centerY, 0.10), duration: 0.30),
                SCNAction.fadeIn(duration: 0.12),
                SCNAction.move(to: SCNVector3(-0.82, centerY, 0.05), duration: 0.18)
            ])
        )

        right.runAction(
            SCNAction.sequence([
                SCNAction.move(to: SCNVector3(0.92, centerY, -0.10), duration: 0.30),
                SCNAction.fadeIn(duration: 0.12),
                SCNAction.move(to: SCNVector3(0.82, centerY, -0.05), duration: 0.18)
            ])
        )

        let backboneLeft = makeBackboneNode()
        backboneLeft.position = SCNVector3(-0.38, centerY, 0.0)
        scene.rootNode.addChildNode(backboneLeft)

        let backboneRight = makeBackboneNode()
        backboneRight.position = SCNVector3(0.38, centerY, 0.0)
        scene.rootNode.addChildNode(backboneRight)

        backboneLeft.runAction(SCNAction.sequence([
            .scale(to: 1.15, duration: 0.15),
            .scale(to: 1.0, duration: 0.15)
        ]))

        backboneRight.runAction(SCNAction.sequence([
            .scale(to: 1.15, duration: 0.15),
            .scale(to: 1.0, duration: 0.15)
        ]))
    }

    private func resealLocalBackbone() {
        let centerY = targetSiteNode.position.y

        for node in helixNode.childNodes where abs(node.position.y - centerY) < 1.6 {
            node.runAction(SCNAction.moveBy(x: 0.12, y: 0, z: 0, duration: 0.25))
        }
        for node in helixNode2.childNodes where abs(node.position.y - centerY) < 1.6 {
            node.runAction(SCNAction.moveBy(x: -0.12, y: 0, z: 0, duration: 0.25))
        }

        let localBackbones = backboneNodes.filter { abs($0.position.y - centerY) < 1.6 }
        for node in localBackbones {
            node.runAction(SCNAction.fadeOpacity(to: 1.0, duration: 0.2))
        }
    }

    private func closeLocalBackbone() {
        let centerY = targetSiteNode.position.y

        for nuc in nucleotideNodes where abs(nuc.y - centerY) < 1.0 {
            nuc.leftNode.runAction(SCNAction.moveBy(x: 0.10, y: 0, z: -0.04, duration: 0.2))
            nuc.rightNode.runAction(SCNAction.moveBy(x: -0.10, y: 0, z: 0.04, duration: 0.2))
        }
    }

    private func showFullHelixAgain() {
        for node in helixNode.childNodes {
            node.runAction(SCNAction.fadeOpacity(to: 1.0, duration: 0.3))
        }
        for node in helixNode2.childNodes {
            node.runAction(SCNAction.fadeOpacity(to: 1.0, duration: 0.3))
        }
    }

    private func hideHelixNodes(aroundY centerY: Float, maxPerStrand: Int, storeIn: inout [SCNNode]) {
        let aSorted = helixNode.childNodes.sorted { abs($0.position.y - centerY) < abs($1.position.y - centerY) }
        let bSorted = helixNode2.childNodes.sorted { abs($0.position.y - centerY) < abs($1.position.y - centerY) }
        let toHide = Array(aSorted.prefix(maxPerStrand)) + Array(bSorted.prefix(maxPerStrand))
        for node in toHide {
            node.opacity = 0.05
            storeIn.append(node)
        }
    }

    private func advanceStepManually() {
        let next = stepIndex + 1
        if next < steps.count {
            runStep(at: next)
        } else {
            restartSequence()
        }
    }

    private func focusCamera(to position: SCNVector3, lookAt: SCNVector3, duration: TimeInterval) {
        cameraNode.removeAllActions()
        lookTargetNode.removeAllActions()

        let move = SCNAction.move(to: position, duration: duration)
        move.timingMode = .easeInEaseOut
        cameraNode.runAction(move)

        let retarget = SCNAction.move(to: lookAt, duration: duration)
        retarget.timingMode = .easeInEaseOut
        lookTargetNode.runAction(retarget)
    }
}

#Preview {
    GeneRepair3DView()
}
