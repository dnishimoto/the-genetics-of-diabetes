import SwiftUI
import Combine
import SceneKit


protocol PipelineNarrationSource: AnyObject {
    func narration(for stage: PipelineStage) -> [String]?
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
    
    enum GeneRegulationMode: String, CaseIterable, Identifiable {
        case healthy = "Corrected (normal TCF7L2)"
        case risk = "Risk Variant (dysregulated)"
        var id: String { rawValue }
    }

    @Published var geneMode: GeneRegulationMode = .healthy

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
    let geneMode: PipelineController.GeneRegulationMode

    var body: some View {
        Group {
            if stage == .crisprCorrection {
                // Render the 3D view directly for the CRISPR correction stage
                GeneRepair3DView()
            } else {
                // Use Canvas-based drawing for the remaining stages
                Canvas { context, size in
                    switch stage {
                    case .reprogramming:
                        drawReprogramming(context: context, size: size, value: progress)
                    case .differentiation:
                        drawDifferentiation(context: context, size: size, value: progress, geneMode: geneMode)
                    case .transplantation:
                        drawTransplantation(context: context, size: size, value: progress, geneMode: geneMode)
                    case .distribution:
                        drawDistribution(context: context, size: size, value: progress, mode: distributionMode)
                    case .crisprCorrection:
                        // Handled above; no Canvas drawing needed here.
                        break
                    }
                }
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

    private func drawDifferentiation(context: GraphicsContext, size: CGSize, value: Double, geneMode: PipelineController.GeneRegulationMode) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = size.width / 4

        let cellColor = Color.interpolate(from: .green, to: .cyan, fraction: value)
        let cellRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        context.fill(Path(ellipseIn: cellRect), with: .color(cellColor))

        let insulinScale: Double = (geneMode == .healthy) ? 1.0 : 0.45

        if value > 0.5 {
            let insulinOpacity = ((value - 0.5) * 2) * insulinScale
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
            if geneMode == .risk && value > 0.7 {
                drawLabel(context: context, text: "Impaired secretion", at: CGPoint(x: center.x, y: center.y + radius + 36), color: .yellow.opacity(0.8))
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

    private func drawTransplantation(context: GraphicsContext, size: CGSize, value: Double, geneMode: PipelineController.GeneRegulationMode) {
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

        let insulinScale: Double = (geneMode == .healthy) ? 1.0 : 0.45

        // Insulin release once cells have settled.
        if value > 0.5 {
            let insulinOpacity = ((value - 0.5) * 2) * insulinScale
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
            if geneMode == .risk && value > 0.7 {
                drawLabel(context: context, text: "Reduced insulin due to dysregulated TCF7L2", at: CGPoint(x: deviceRect.midX, y: deviceRect.minY - 28), color: .yellow)
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
    
    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isPadLike: Bool { hSizeClass == .regular }

    var body: some View {
        VStack(alignment: .leading, spacing: isPadLike ? 12 : 8) {
            Text(stage.title)
                .font(isPadLike ? .title2 : .headline)
                .foregroundColor(stage.accentColor)
            Text(stage.subtitle)
                .font(isPadLike ? .body : .subheadline)
                .foregroundColor(.white.opacity(0.85))
            Divider().background(Color.white.opacity(0.3))

            VStack(alignment: .leading, spacing: isPadLike ? 10 : 6) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    HStack(alignment: .top, spacing: isPadLike ? 10 : 6) {
                        Circle()
                            .fill(stage.accentColor)
                            .frame(width: isPadLike ? 8 : 6, height: isPadLike ? 8 : 6)
                            .padding(.top, isPadLike ? 7 : 6)
                        Text(line)
                            .font(isPadLike ? .callout : .footnote)
                            .foregroundColor(.white)
                            .lineSpacing(isPadLike ? 3 : 2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(isPadLike ? 22 : 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}

struct GlucoseIndicatorView: View {
    let stage: PipelineStage
    let progress: Double
    let geneMode: PipelineController.GeneRegulationMode
    
    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isPadLike: Bool { hSizeClass == .regular }

    private func estimatedGlucose() -> Double {
        // Crude model: insulin potential rises in differentiation/transplantation; risk mode reduces it.
        let insulinScale: Double = (geneMode == .healthy) ? 1.0 : 0.45
        switch stage {
        case .differentiation, .transplantation:
            let phase = max(0.0, progress - 0.5) * 2 // 0..1 after mid-phase
            let insulin = min(1.0, max(0.0, phase * insulinScale))
            let glucose = 1.0 - insulin * 0.8 // more insulin → lower glucose
            return min(1.0, max(0.0, glucose))
        default:
            return 0.6 // neutral during other stages
        }
    }

    var body: some View {
        let g = estimatedGlucose()
        VStack(alignment: .leading, spacing: isPadLike ? 8 : 6) {
            HStack {
                Text("Estimated Glucose")
                    .font(isPadLike ? .callout : .caption)
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
                Text(String(format: "%.0f%%", g * 100))
                    .font(isPadLike ? .caption : .caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            ZStack(alignment: .leading) {
                GeometryReader { geo in
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: geo.size.width, height: isPadLike ? 10 : 8)
                    Capsule()
                        .fill(Color.interpolate(from: .green, to: .red, fraction: g))
                        .frame(width: max(geo.size.width * CGFloat(max(0.05, g)), isPadLike ? 16 : 12), height: isPadLike ? 10 : 8)
                }
            }
            .frame(height: isPadLike ? 10 : 8)
        }
    }
}


// MARK: - Stage Progress Indicator

struct StageProgressBar: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isPadLike: Bool { hSizeClass == .regular }
    
    let current: PipelineStage
    let onSelect: (PipelineStage) -> Void

    var body: some View {
        HStack(spacing: isPadLike ? 12 : 8) {
            ForEach(PipelineStage.allCases) { stage in
                Button {
                    onSelect(stage)
                } label: {
                    Circle()
                        .fill(stage == current ? stage.accentColor : Color.white.opacity(0.25))
                        .frame(width: stage == current ? (isPadLike ? 14 : 12) : (isPadLike ? 10 : 8),
                               height: stage == current ? (isPadLike ? 14 : 12) : (isPadLike ? 10 : 8))
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
    
    @State private var showAbout: Bool = false

    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isPadLike: Bool { hSizeClass == .regular }

    var body: some View {
        NavigationStack
        {
            ZStack {
                LinearGradient(
                    colors: [Color.black, controller.stage.accentColor.opacity(0.25)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    if isPadLike {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
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
                            
                            HStack(alignment: .top, spacing: 24) {
                                // Left column: visualization and transport controls
                                VStack(alignment: .leading, spacing: 16) {
                                    CellTherapyCanvas(
                                        stage: controller.stage,
                                        progress: controller.progress,
                                        distributionMode: controller.distributionMode,
                                        geneMode: controller.geneMode
                                    )
                                    .frame(height: 480)
                                    .padding(.horizontal, 8)
                                    
                                    controlBar
                                }
                                .frame(maxWidth: .infinity, alignment: .top)
                                
                                // Right column: narrative and configuration
                                VStack(alignment: .leading, spacing: 16) {
                                    StageNarrativeOverlay(
                                        stage: controller.stage,
                                        lines: controller.narrative(for: controller.stage)
                                    )
                                    
                                    Picker("TCF7L2 Regulation", selection: $controller.geneMode) {
                                        ForEach(PipelineController.GeneRegulationMode.allCases) { mode in
                                            Text(mode.rawValue).tag(mode)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    
                                    GlucoseIndicatorView(stage: controller.stage, progress: controller.progress, geneMode: controller.geneMode)
                                    
                                    if controller.stage == .distribution {
                                        Picker("Mode", selection: $controller.distributionMode) {
                                            ForEach(PipelineController.DistributionMode.allCases) { mode in
                                                Text(mode.rawValue).tag(mode)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .top)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 16)
                            .frame(maxWidth: 1200)
                        }
                    } else {
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
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
                                distributionMode: controller.distributionMode,
                                geneMode: controller.geneMode
                            )
                            .frame(height: 320)
                            .padding(.horizontal, 8)
                            
                            Picker("TCF7L2 Regulation", selection: $controller.geneMode) {
                                ForEach(PipelineController.GeneRegulationMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                            
                            GlucoseIndicatorView(stage: controller.stage, progress: controller.progress, geneMode: controller.geneMode)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 6)
                            
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
                        .padding(.horizontal, 16)
                    }
                }
            } .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("About")
                }
            }
        }
       
                    .sheet(isPresented: $showAbout) {
                        AboutView()
                    }
        //.onAppear { controller.start() }
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

