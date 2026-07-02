import SwiftUI
import Combine

// MARK: - Optional narration hook
// Drop-in extension point matching the MasterMonitor pattern used across other
// Louise AI projects. If a MasterMonitor-conforming object is supplied, it can
// override or augment the static narrative text below (e.g. with a live AI
// explanation). If nil, the built-in narrative strings are used as-is.
protocol PipelineNarrationSource: AnyObject {
    func narration(for stage: PipelineStage) -> [String]?
}

// MARK: - Pipeline Stage Model

enum PipelineStage: Int, CaseIterable, Identifiable {
    case crisprCorrection = 0
    case reprogramming
    case differentiation
    case transplantation
    case distribution

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .crisprCorrection: return "Step 1 · Genetic Correction"
        case .reprogramming:    return "Step 2 · Reprogramming"
        case .differentiation:  return "Step 3 · Differentiation"
        case .transplantation:  return "Step 4 · Transplantation"
        case .distribution:     return "Step 5 · Distribution"
        }
    }

    var subtitle: String {
        switch self {
        case .crisprCorrection: return "CRISPR correction of TCF7L2 regulatory variants"
        case .reprogramming:    return "Skin Cell → induced Pluripotent Stem Cell (iPSC)"
        case .differentiation:  return "iPSC → Pancreatic Beta Cell"
        case .transplantation:  return "Encapsulation, implantation & anti-fibrotic co-therapy"
        case .distribution:     return "Autologous therapy vs. Universal Cell Bank"
        }
    }

    var accentColor: Color {
        switch self {
        case .crisprCorrection: return .purple
        case .reprogramming:    return .orange
        case .differentiation:  return .cyan
        case .transplantation:  return .blueGrayCompat
        case .distribution:     return .mint
        }
    }

    /// Condensed narrative explanation shown beneath the animation for this stage.
    /// Each string is one scroll-panel line, mirroring the TCF7L2NarrativeOverlay format.
    var narrative: [String] {
        switch self {
        case .crisprCorrection:
            return [
                "TCF7L2 is the strongest common genetic risk factor for type 2 diabetes. Its risk variants sit in noncoding regulatory regions, not the protein-coding sequence.",
                "A guide RNA is designed to match the exact regulatory sequence, then paired with Cas9 (or a base/prime editor) to form the correction complex.",
                "The complex is delivered into the cell, locates the target region, and either cuts for template-guided repair or rewrites the base directly without cutting both strands.",
                "Expression is measured after editing — not just presence of the fix — because both too little and too much TCF7L2 activity impair beta cell function.",
                "Goal: normalize TCF7L2 to its healthy functional range before this cell is carried forward into reprogramming."
            ]
        case .reprogramming:
            return [
                "A genetically corrected skin cell is exposed to reprogramming factors that reset its identity.",
                "Because this cell is the patient's own, it is genetically identical to the patient — the basis for low immune-rejection risk later in the pipeline.",
                "Over time the cell converts from a skin cell into an induced pluripotent stem cell (iPSC), capable of becoming nearly any cell type.",
                "Note: the reprogramming method itself matters — viral methods can leave the cell more immunogenic than non-viral (episomal) methods, even though the DNA is unchanged."
            ]
        case .differentiation:
            return [
                "The iPSC is guided through a second transformation into a pancreatic beta cell.",
                "As differentiation completes, the cell should begin actively secreting insulin — the functional signature of a true beta cell, not just a structural resemblance.",
                "This is where the earlier TCF7L2 correction pays off directly: a properly corrected cell line should show normal insulin transcription and secretion here.",
                "An uncorrected cell line can differentiate structurally but still show impaired glucose-stimulated insulin secretion."
            ]
        case .transplantation:
            return [
                "Mature beta cells are loaded into an encapsulation device that shields them from immune attack while letting insulin diffuse outward.",
                "The device itself triggers a foreign body response — fibrotic scar tissue can wall it off and starve the enclosed cells of oxygen and nutrients over time.",
                "Co-encapsulating mesenchymal stem cells (MSCs) suppresses this fibrotic response and has improved graft survival and function in animal studies.",
                "Other strategies: capsules engineered to slow-release anti-fibrotic signals, or macrodevices with an active oxygen reservoir to keep cells alive despite scarring.",
                "As of early 2026, human trials (e.g. Encellin, Phase 1) are actively testing device survival and fibrosis outcomes in real patients."
            ]
        case .distribution:
            return [
                "Two different strategies solve the same rejection problem in different ways — this is a branch point, not a continuation.",
                "Autologous: this patient's own corrected cell line, used only for this patient. Low rejection risk by genetic identity, but slow and made fresh per patient.",
                "Universal: one donor-derived, corrected cell bank distributed to many patients. Fast and scalable, but genetically foreign to everyone but the original donor.",
                "Universal cells typically need additional immune-evasion edits (e.g. knocking out HLA Class I/II) to avoid rejection, since genetic correction alone doesn't make them 'invisible.'",
                "Both paths converge on the same goal: a functional, non-rejected, insulin-secreting beta cell in the patient."
            ]
        }
    }
}

// Small compatibility color so this file has no external color-asset dependency.
extension Color {
    static var blueGrayCompat: Color { Color(red: 0.38, green: 0.45, blue: 0.53) }
}

// MARK: - Pipeline Controller

final class PipelineController: ObservableObject {
    @Published var stage: PipelineStage = .crisprCorrection
    @Published var progress: Double = 0.0          // 0...1 within the current stage
    @Published var isPlaying: Bool = true
    @Published var distributionMode: DistributionMode = .autologous

    enum DistributionMode: String, CaseIterable, Identifiable {
        case autologous = "Autologous"
        case universal = "Universal Bank"
        var id: String { rawValue }
    }

    /// Optional AI narration source (MasterMonitor-style plug-in point).
    weak var narrationSource: PipelineNarrationSource?

    private var timer: Timer?
    private let stepDuration: Double = 5.0
    private let frameInterval: Double = 1.0 / 60.0

    func narrative(for stage: PipelineStage) -> [String] {
        narrationSource?.narration(for: stage) ?? stage.narrative
    }

    func start() {
        stop()
        guard isPlaying else { return }
        timer = Timer.scheduledTimer(withTimeInterval: frameInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let increment = frameInterval / stepDuration
        let newProgress = progress + increment
        if newProgress >= 1.0 {
            progress = 1.0
            advanceStage()
        } else {
            progress = newProgress
        }
    }

    func advanceStage() {
        stop()
        isPlaying = false

        guard let next = PipelineStage(rawValue: stage.rawValue + 1) else {
            // Reached the end of the pipeline.
            progress = 1.0
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            stage = next
            progress = 0.0
        }
    }

    func previousStage() {
        guard let prev = PipelineStage(rawValue: stage.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            stage = prev
            progress = 0.0
        }
    }

    func togglePlay() {
        isPlaying.toggle()
        isPlaying ? start() : stop()
    }

    func jump(to newStage: PipelineStage) {
        withAnimation(.easeInOut(duration: 0.3)) {
            stage = newStage
            progress = 0.0
        }
    }
}

// MARK: - Canvas Renderer

struct CellTherapyCanvas: View {
    let stage: PipelineStage
    let progress: Double            // 0...1
    let distributionMode: PipelineController.DistributionMode

    var body: some View {
        Canvas { context, size in
            switch stage {
            case .crisprCorrection:
                drawCrisprCorrection(context: context, size: size, value: progress)
            case .reprogramming:
                drawReprogramming(context: context, size: size, value: progress)
            case .differentiation:
                drawDifferentiation(context: context, size: size, value: progress)
            case .transplantation:
                drawTransplantation(context: context, size: size, value: progress)
            case .distribution:
                drawDistribution(context: context, size: size, value: progress, mode: distributionMode)
            }
        }
    }

    // MARK: Stage 1 — CRISPR correction of TCF7L2

    private func drawCrisprCorrection(context: GraphicsContext, size: CGSize, value: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        // DNA double helix as two sine-wave strands.
        var strandA = Path()
        var strandB = Path()
        let amplitude: CGFloat = 22
        let waveLength: CGFloat = 40
        for x in stride(from: CGFloat(0), through: size.width, by: 2) {
            let phase = x / waveLength
            let yA = center.y + amplitude * CGFloat(sin(phase))
            let yB = center.y + amplitude * CGFloat(sin(phase + .pi))
            if x == 0 {
                strandA.move(to: CGPoint(x: x, y: yA))
                strandB.move(to: CGPoint(x: x, y: yB))
            } else {
                strandA.addLine(to: CGPoint(x: x, y: yA))
                strandB.addLine(to: CGPoint(x: x, y: yB))
            }
        }
        context.stroke(strandA, with: .color(.blue.opacity(0.8)), lineWidth: 2)
        context.stroke(strandB, with: .color(.blue.opacity(0.4)), lineWidth: 2)

        // Target site (the TCF7L2 regulatory variant) sits at a fixed x position.
        let targetX = size.width * 0.5
        let targetY = center.y

        // The Cas9 + guide-RNA complex approaches the target from the left,
        // arrives by the midpoint, then "corrects" (site glows and clears).
        let approachProgress = min(value / 0.6, 1.0)
        let complexX = size.width * 0.1 + (targetX - size.width * 0.1) * approachProgress
        let complexPos = CGPoint(x: complexX, y: targetY)

        // Cas9 complex body.
        let complexRect = CGRect(x: complexPos.x - 14, y: complexPos.y - 14, width: 28, height: 28)
        context.fill(Path(ellipseIn: complexRect), with: .color(.purple.opacity(0.85)))
        drawLabel(context: context, text: "Cas9 + gRNA", at: CGPoint(x: complexPos.x, y: complexPos.y - 26), color: .purple)

        // Target site marker: red while uncorrected, green once corrected.
        let correctionProgress = max(0, (value - 0.6) / 0.4) // 0.6 -> 1.0 maps to correction
        let siteColor = Color.interpolate(from: .red, to: .green, fraction: correctionProgress)
        let siteRect = CGRect(x: targetX - 6, y: targetY - 6, width: 12, height: 12)
        context.fill(Path(ellipseIn: siteRect), with: .color(siteColor))
        drawLabel(
            context: context,
            text: correctionProgress < 0.5 ? "Risk Variant" : "Corrected",
            at: CGPoint(x: targetX, y: targetY + 22),
            color: siteColor
        )

        // Once corrected, a soft expanding ring signals "expression normalized."
        if correctionProgress > 0.3 {
            let ringRadius: CGFloat = 20 + CGFloat(correctionProgress) * 40
            let ringOpacity = (1.0 - correctionProgress) * 0.6 + 0.1
            let ringRect = CGRect(
                x: targetX - ringRadius, y: targetY - ringRadius,
                width: ringRadius * 2, height: ringRadius * 2
            )
            context.stroke(
                Path(ellipseIn: ringRect),
                with: .color(.green.opacity(ringOpacity)),
                lineWidth: 2
            )
        }

        drawCenteredCaption(context: context, size: size, text: "TCF7L2 Regulatory Region", color: .white)
    }

    // MARK: Stage 2 — Reprogramming (Skin Cell -> iPSC)

    private func drawReprogramming(context: GraphicsContext, size: CGSize, value: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = size.width / 4

        let skinColor = Color.interpolate(from: Color(red: 1.0, green: 0.8, blue: 0.6), to: .green, fraction: value)
        let cellRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        context.fill(Path(ellipseIn: cellRect), with: .color(skinColor))

        // Four reprogramming factors spiral inward toward the cell.
        for i in 0..<4 {
            let angle = Double(i) * .pi / 2 + value * 2 * .pi
            let distance = (1.0 - value) * Double(radius) * 2
            let factorPos = CGPoint(
                x: center.x + CGFloat(cos(angle) * distance),
                y: center.y + CGFloat(sin(angle) * distance)
            )
            let factorRect = CGRect(x: factorPos.x - 5, y: factorPos.y - 5, width: 10, height: 10)
            context.fill(Path(ellipseIn: factorRect), with: .color(.purple))
            drawLabel(context: context, text: "Factor", at: CGPoint(x: factorPos.x, y: factorPos.y - 15), color: .purple)
        }

        drawCenteredCaption(context: context, size: size, text: value < 0.5 ? "Skin Cell" : "iPSC", color: .white)
        drawLabel(
            context: context,
            text: value < 0.5 ? "Skin Cell (autologous)" : "iPSC",
            at: CGPoint(x: center.x, y: center.y + radius + 18),
            color: value < 0.5 ? .orange : .green
        )
    }

    // MARK: Stage 3 — Differentiation (iPSC -> Beta Cell)

    private func drawDifferentiation(context: GraphicsContext, size: CGSize, value: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = size.width / 4

        let cellColor = Color.interpolate(from: .green, to: .cyan, fraction: value)
        let cellRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        context.fill(Path(ellipseIn: cellRect), with: .color(cellColor))

        if value > 0.5 {
            let insulinOpacity = (value - 0.5) * 2
            for i in 0..<5 {
                let angle = Double(i) * 2 * .pi / 5 + value * .pi
                let distance = Double(radius) + insulinOpacity * 30
                let pos = CGPoint(
                    x: center.x + CGFloat(cos(angle) * distance),
                    y: center.y + CGFloat(sin(angle) * distance)
                )
                let dotRect = CGRect(x: pos.x - 3, y: pos.y - 3, width: 6, height: 6)
                context.fill(Path(ellipseIn: dotRect), with: .color(.yellow.opacity(insulinOpacity)))
                if i == 0 && value > 0.7 {
                    drawLabel(context: context, text: "Insulin", at: CGPoint(x: pos.x, y: pos.y - 12), color: .yellow)
                }
            }
        }

        drawCenteredCaption(context: context, size: size, text: value < 0.5 ? "iPSC" : "Beta Cell", color: .white)
        drawLabel(
            context: context,
            text: value < 0.5 ? "iPSC" : "Beta Cell",
            at: CGPoint(x: center.x, y: center.y + radius + 18),
            color: value < 0.5 ? .green : .cyan
        )
    }

    // MARK: Stage 4 — Transplantation with anti-fibrotic co-therapy

    private func drawTransplantation(context: GraphicsContext, size: CGSize, value: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let deviceRect = CGRect(x: center.x - size.width * 0.3, y: center.y - 30, width: size.width * 0.6, height: 60)
        let devicePath = Path(roundedRect: deviceRect, cornerRadius: 15)
        context.stroke(devicePath, with: .color(.blueGrayCompat.opacity(0.6)), lineWidth: 3)
        drawLabel(context: context, text: "Encapsulation Device", at: CGPoint(x: center.x, y: deviceRect.minY - 18), color: .blueGrayCompat)

        // Beta cells migrating in.
        let progress = min(value * 2, 1.0)
        for i in 0..<5 {
            let startX = size.width * 1.2
            let endX = center.x - size.width * 0.2 + CGFloat(i) * size.width * 0.1
            let cellX = startX + (endX - startX) * CGFloat(progress)
            if value * 2 < 1.5 {
                let cellRect = CGRect(x: cellX - 8, y: center.y - 8, width: 16, height: 16)
                context.fill(Path(ellipseIn: cellRect), with: .color(.cyan))
                if i == 0 {
                    drawLabel(context: context, text: "Beta Cell", at: CGPoint(x: cellX, y: center.y - 18), color: .cyan)
                }
            }
        }

        // Co-encapsulated MSCs actively suppressing fibrosis — a soft green
        // halo around the device whose strength grows with progress, plus a
        // few small MSC markers along the device wall.
        let mscStrength = min(value * 1.4, 1.0)
        let haloRect = deviceRect.insetBy(dx: -10 - 10 * CGFloat(mscStrength), dy: -10 - 10 * CGFloat(mscStrength))
        context.stroke(
            Path(roundedRect: haloRect, cornerRadius: 22),
            with: .color(.green.opacity(0.25 * mscStrength)),
            lineWidth: 4
        )
        if mscStrength > 0.3 {
            for i in 0..<4 {
                let mx = deviceRect.minX + deviceRect.width * (CGFloat(i) / 3.0)
                let my = deviceRect.maxY + 14
                let mscRect = CGRect(x: mx - 4, y: my - 4, width: 8, height: 8)
                context.fill(Path(ellipseIn: mscRect), with: .color(.green.opacity(mscStrength)))
            }
            drawLabel(context: context, text: "MSC (anti-fibrotic)", at: CGPoint(x: center.x, y: deviceRect.maxY + 30), color: .green)
        }

        // Insulin release once cells have settled.
        if value > 0.5 {
            let insulinOpacity = (value - 0.5) * 2
            for i in 0..<10 {
                let posX = deviceRect.minX + (CGFloat(i) / 10.0) * deviceRect.width
                let startY = center.y + 30
                let endY = startY + 50 * CGFloat(insulinOpacity)
                let dotRect = CGRect(x: posX - 2, y: endY - 2, width: 4, height: 4)
                context.fill(Path(ellipseIn: dotRect), with: .color(.yellow.opacity(insulinOpacity)))
                if i == 0 && value > 0.7 {
                    drawLabel(context: context, text: "Insulin", at: CGPoint(x: posX, y: endY + 12), color: .yellow)
                }
            }
        }
    }

    // MARK: Stage 5 — Distribution (Autologous vs. Universal Bank)

    private func drawDistribution(context: GraphicsContext, size: CGSize, value: Double, mode: PipelineController.DistributionMode) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        switch mode {
        case .autologous:
            // A single closed loop: patient -> corrected cell line -> back to the same patient.
            let patientPos = CGPoint(x: center.x, y: size.height * 0.85)
            let bankPos = CGPoint(x: center.x, y: size.height * 0.2)

            let bankRect = CGRect(x: bankPos.x - 55, y: bankPos.y - 25, width: 110, height: 50)
            context.fill(Path(bankRect), with: .color(.blueGrayCompat))
            drawCenteredText(context: context, text: "Corrected iPSC Line", at: bankPos, color: .white)
            drawLabel(context: context, text: "Patient-specific", at: CGPoint(x: bankPos.x, y: bankRect.minY - 18), color: .blueGrayCompat)

            let patientRect = CGRect(x: patientPos.x - 22, y: patientPos.y - 22, width: 44, height: 44)
            context.fill(Path(ellipseIn: patientRect), with: .color(.white))
            drawLabel(context: context, text: "Same Patient", at: CGPoint(x: patientPos.x, y: patientPos.y + 32), color: .white)

            // Traveling cell along the single line.
            let travelY = bankPos.y + (patientPos.y - bankPos.y) * CGFloat(value)
            let cellRect = CGRect(x: center.x - 8, y: travelY - 8, width: 16, height: 16)
            context.fill(Path(ellipseIn: cellRect), with: .color(.cyan))
            if value > 0.15 {
                drawLabel(context: context, text: "Beta Cell", at: CGPoint(x: center.x, y: travelY - 18), color: .cyan)
            }

        case .universal:
            let bankPos = CGPoint(x: center.x, y: size.height * 0.2)
            let bankRect = CGRect(x: bankPos.x - 55, y: bankPos.y - 25, width: 110, height: 50)
            context.fill(Path(bankRect), with: .color(.blueGrayCompat))
            drawCenteredText(context: context, text: "Universal Cell Bank", at: bankPos, color: .white)
            drawLabel(context: context, text: "Hypo-immune, HLA-edited", at: CGPoint(x: bankPos.x, y: bankRect.minY - 18), color: .blueGrayCompat)

            for i in 0..<3 {
                let angle = Double.pi + Double(i - 1) * (Double.pi / 4)
                let startY = Double(size.height) * 0.2 + 25
                let endY = Double(size.height) * 0.8
                let currentY = startY + (endY - startY) * value
                let cellPos = CGPoint(
                    x: center.x + CGFloat(cos(angle) * (currentY * 0.5)),
                    y: CGFloat(currentY)
                )
                let cellRect = CGRect(x: cellPos.x - 15, y: cellPos.y - 15, width: 30, height: 30)
                context.fill(Path(ellipseIn: cellRect), with: .color(.cyan))
                if value > 0.2 {
                    drawLabel(context: context, text: "Beta Cell", at: CGPoint(x: cellPos.x, y: cellPos.y - 18), color: .cyan)
                }

                let patientPos = CGPoint(
                    x: center.x + CGFloat(cos(angle) * (CGFloat(endY) * 0.5)),
                    y: CGFloat(endY)
                )
                let patientRect = CGRect(x: patientPos.x - 20, y: patientPos.y - 20, width: 40, height: 40)
                context.fill(Path(ellipseIn: patientRect), with: .color(.white))
                drawCenteredText(context: context, text: "Patient \(i + 1)", at: CGPoint(x: patientPos.x, y: patientPos.y + 25), color: .white70Compat)
                drawLabel(context: context, text: "Patient", at: CGPoint(x: patientPos.x, y: patientPos.y - 28), color: .white)
            }
        }
    }

    // MARK: Shared drawing helpers

    private func drawLabel(context: GraphicsContext, text: String, at point: CGPoint, color: Color) {
        var context = context
        context.addFilter(.shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 0))

        let resolved = context.resolve(
            Text(text)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
        )

        context.draw(resolved, at: point, anchor: .center)
    }


    private func drawCenteredText(context: GraphicsContext, text: String, at point: CGPoint, color: Color) {
        let resolved = context.resolve(
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(color)
        )
        context.draw(resolved, at: point, anchor: .center)
    }

    private func drawCenteredCaption(context: GraphicsContext, size: CGSize, text: String, color: Color) {
        let resolved = context.resolve(
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(color)
        )
        context.draw(resolved, at: CGPoint(x: size.width / 2, y: size.height / 2), anchor: .center)
    }
}

extension Color {
    static var white70Compat: Color { Color.white.opacity(0.7) }

    /// Simple RGB linear interpolation between two colors, resolved via UIColor
    /// so it behaves consistently across platforms without SwiftUI's own
    /// (occasionally inconsistent) Color.lerp availability.
    static func interpolate(from: Color, to: Color, fraction: Double) -> Color {
        let f = min(max(fraction, 0), 1)
        #if canImport(UIKit)
        let uiFrom = UIColor(from)
        let uiTo = UIColor(to)
        var fr: CGFloat = 0, fg: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
        var tr: CGFloat = 0, tg: CGFloat = 0, tb: CGFloat = 0, ta: CGFloat = 0
        uiFrom.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
        uiTo.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)
        return Color(
            red: Double(fr + (tr - fr) * CGFloat(f)),
            green: Double(fg + (tg - fg) * CGFloat(f)),
            blue: Double(fb + (tb - fb) * CGFloat(f)),
            opacity: Double(fa + (ta - fa) * CGFloat(f))
        )
        #else
        return f < 0.5 ? from : to
        #endif
    }
}

// MARK: - Narrative Overlay (per stage)

struct StageNarrativeOverlay: View {
    let stage: PipelineStage
    let lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stage.title)
                .font(.headline)
                .foregroundColor(stage.accentColor)
            Text(stage.subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
            Divider().background(Color.white.opacity(0.3))
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                        HStack(alignment: .top, spacing: 6) {
                            Circle()
                                .fill(stage.accentColor)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            Text(line)
                                .font(.footnote)
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .frame(maxHeight: 160)
        }
        .padding(16)
        .background(Color.black.opacity(0.6))
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }
}

struct CRISPRMechanicsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    mechanicsSection(
                        title: "Step 1 — Identify the Regulatory Variant",
                        activity: "CRISPR Activity: None",
                        bodyLines: [
                            "Analyze the DNA sequence to determine whether a diabetes-associated regulatory variant is present."
                        ])

                    mechanicsSection(
                        title: "Step 2 — Understand the Regulatory Region",
                        activity: "CRISPR Activity: None",
                        bodyLines: [
                            "Determine how the region influences TCF7L2 expression (e.g., enhancer activity, transcription-factor binding)."
                        ])

                    Group {
                        Text("Step 3 — Select the Editing Strategy")
                            .font(.headline)
                        subsection(
                            subtitle: "Cas9",
                            lines: [
                                "Associates with a guide RNA; PAM + guide recognition confers specificity.",
                                "Locally unwinds DNA; activates nuclease domains upon sufficient complementarity.",
                                "Suitable for precise editing at a chosen locus."
                            ])
                        subsection(
                            subtitle: "Cas3",
                            lines: [
                                "Part of a surveillance complex; recruited after recognition.",
                                "Helicase unwinds DNA; nuclease degrades DNA processively.",
                                "Suited for removing larger DNA regions, not single-base corrections."
                            ])
                    }

                    Group {
                        Text("Step 4 — Locate the TCF7L2 Regulatory Region")
                            .font(.headline)
                        subsection(
                            subtitle: "Cas9 Mechanics",
                            lines: [
                                "Genome → PAM recognition → DNA opening → guide pairing → verification → activation.",
                                "Remains bound on sufficient complementarity; otherwise dissociates."
                            ])
                        subsection(
                            subtitle: "Cas3 Mechanics",
                            lines: [
                                "Surveillance complex recognizes DNA → recruits Cas3 → unwinding → progressive degradation."
                            ])
                    }

                    Group {
                        Text("Step 5 — DNA Recognition")
                            .font(.headline)
                        subsection(
                            subtitle: "Cas9",
                            lines: [
                                "Guide RNA + DNA base pairing triggers conformational changes and nuclease activation."
                            ])
                        subsection(
                            subtitle: "Cas3",
                            lines: [
                                "Recognition by surveillance complex; Cas3 is recruited post-recognition."
                            ])
                    }

                    Group {
                        Text("Step 6 — DNA Modification")
                            .font(.headline)
                        subsection(
                            subtitle: "Cas9",
                            lines: [
                                "Cas9 binds target DNA; editing machinery (e.g., base/prime editor) modifies the site.",
                                "Cellular repair processes resolve the edit; preserves surrounding regulatory architecture."
                            ])
                        subsection(
                            subtitle: "Cas3",
                            lines: [
                                "Helicase activity unwinds DNA; nuclease degrades exposed DNA.",
                                "Deletions can extend over long stretches rather than single-base corrections."
                            ])
                    }

                    mechanicsSection(
                        title: "Step 7 — Cellular Response",
                        activity: nil,
                        bodyLines: [
                            "After Cas9-based editing, DNA maintenance pathways are engaged.",
                            "Verify sequence change and restoration of TCF7L2 regulation toward physiological range.",
                            "Cas3-driven deletions typically produce loss of targeted regions (more for research use)."
                        ])

                    mechanicsSection(
                        title: "Step 8 — Functional Evaluation",
                        activity: "CRISPR Activity: None",
                        bodyLines: [
                            "Assess TCF7L2 expression, downstream regulation, beta-cell characteristics, and glucose-responsive insulin secretion."
                        ])

                    Group {
                        Text("Mechanical Comparison")
                            .font(.headline)
                        bulletComparison(
                            title: "Cas9",
                            bullets: [
                                "Primary function: localized, targeted editing/cleavage.",
                                "Recognition: guide RNA + PAM.",
                                "DNA effect: localized modification.",
                                "Precision: high for single-site changes.",
                                "Typical use: correcting/modifying a specific sequence.",
                                "Suitability for TCF7L2 variant correction: well aligned with precision goals."
                            ])
                        bulletComparison(
                            title: "Cas3",
                            bullets: [
                                "Primary function: progressive DNA degradation post-recruitment.",
                                "Recognition: surveillance complex; Cas3 is recruited.",
                                "DNA effect: extended DNA removal.",
                                "Precision: low for single-base changes.",
                                "Typical use: deleting larger regions or probing regulatory element function.",
                                "Suitability for TCF7L2 variant correction: less aligned; more for deletions in research."
                            ])
                    }
                }
                .padding(16)
            }
            .navigationTitle("CRISPR Mechanics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func mechanicsSection(title: String, activity: String?, bodyLines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            if let activity {
                Text(activity)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            ForEach(bodyLines, id: \.self) { line in
                HStack(alignment: .top, spacing: 8) {
                    Circle().fill(Color.accentColor).frame(width: 6, height: 6).padding(.top, 6)
                    Text(line).font(.body)
                }
            }
        }
    }

    private func subsection(subtitle: String, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.accentColor)
            ForEach(lines, id: \.self) { line in
                HStack(alignment: .top, spacing: 8) {
                    Circle().fill(Color.accentColor.opacity(0.6)).frame(width: 5, height: 5).padding(.top, 6)
                    Text(line).font(.callout)
                }
            }
        }
    }

    private func bulletComparison(title: String, bullets: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).foregroundColor(.accentColor)
            ForEach(bullets, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    RoundedRectangle(cornerRadius: 1).fill(Color.secondary).frame(width: 6, height: 2).padding(.top, 8)
                    Text(item).font(.callout)
                }
            }
        }
    }
}

// MARK: - Stage Progress Indicator

struct StageProgressBar: View {
    let current: PipelineStage
    let onSelect: (PipelineStage) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(PipelineStage.allCases) { stage in
                Button {
                    onSelect(stage)
                } label: {
                    Circle()
                        .fill(stage == current ? stage.accentColor : Color.white.opacity(0.25))
                        .frame(width: stage == current ? 12 : 8, height: stage == current ? 12 : 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Main Pipeline View

struct CellTherapyPipelineView: View {
    @StateObject private var controller = PipelineController()
    @State private var isShowingMechanics = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, controller.stage.accentColor.opacity(0.25)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        isShowingMechanics = true
                    } label: {
                        Label("CRISPR Mechanics", systemImage: "info.circle")
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)

                StageProgressBar(current: controller.stage) { stage in
                    controller.jump(to: stage)
                }

                CellTherapyCanvas(
                    stage: controller.stage,
                    progress: controller.progress,
                    distributionMode: controller.distributionMode
                )
                .frame(height: 320)
                .padding(.horizontal, 8)

                if controller.stage == .distribution {
                    Picker("Mode", selection: $controller.distributionMode) {
                        ForEach(PipelineController.DistributionMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 4)
                }

                StageNarrativeOverlay(
                    stage: controller.stage,
                    lines: controller.narrative(for: controller.stage)
                )

                Spacer(minLength: 8)

                controlBar
                    .padding(.bottom, 16)
            }
        }
        .onAppear { controller.start() }
        .onDisappear { controller.stop() }
        .sheet(isPresented: $isShowingMechanics) {
            CRISPRMechanicsView()
                .presentationDetents([.medium, .large])
        }
    }

    private var controlBar: some View {
        HStack(spacing: 28) {
            Button {
                controller.previousStage()
            } label: {
                Image(systemName: "backward.end.fill")
            }
            .disabled(controller.stage == .crisprCorrection)

            Button {
                controller.togglePlay()
            } label: {
                Image(systemName: controller.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 40))
            }

            Button {
                controller.advanceStage()
            } label: {
                Image(systemName: "forward.end.fill")
            }
        }
        .foregroundColor(.white)
        .font(.system(size: 22))
    }
}

// MARK: - Preview

#Preview {
    CellTherapyPipelineView()
}
