//
//  DataStructures.swift
//  The Genetics of Diabetes
//
//  Created by David Nishimoto on 7/1/26.
//

import Foundation
import SwiftUI
import SceneKit

struct Nucleotide {

    let base: Character

    let strand: Int

    let index: Int

    let baseNode: SCNNode

    let sugarNode: SCNNode

    let phosphateNode: SCNNode

}

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
