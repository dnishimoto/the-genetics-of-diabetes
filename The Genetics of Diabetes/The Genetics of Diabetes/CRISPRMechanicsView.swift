//
//  CRISPRMechanicsView.swift
//  The Genetics of Diabetes
//
//  Created by David Nishimoto on 7/1/26.
//

import Foundation
import SwiftUI

struct CRISPRMechanicsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    mechanicsSection(
                        title: "Step 1 — Identify the Regulatory Variant",
                        activity: "CRISPR Activity: None",
                        bodyLines: [
                            "Scan the DNA sequence to locate the diabetes-risk variant rs7903146 within the TCF7L2 gene (Grant et al., 2006; Nature Genetics)."
                        ])

                    mechanicsSection(
                        title: "Step 2 — Understand the Regulatory Region",
                        activity: "CRISPR Activity: None",
                        bodyLines: [
                            "Determine how this non-coding DNA section acts like a dimmer switch to control TCF7L2 gene expression and insulin regulation in pancreatic beta cells (Zhou et al., 2014; Human Molecular Genetics)."
                        ])

                    Group {
                        Text("Step 3 — Select the Editing Strategy")
                            .font(.headline)
                        subsection(
                            subtitle: "Cas9 (Precision Editing)",
                            lines: [
                                "Acts like a fine-tipped pen: locks onto a single DNA site to swap out a single letter without affecting surrounding code (Jinek et al., 2012; Science).",
                                "Ideal for precise, single-letter corrections or base editing."
                            ])
                        subsection(
                            subtitle: "Cas3 (Targeted Deletion)",
                            lines: [
                                "Acts like a DNA shredder: unwinds and degrades large sections of DNA rather than making single-letter tweaks (Sinkunas et al., 2011; EMBO Journal).",
                                "Best suited for deleting full regulatory regions in functional gene research."
                            ])
                    }

                    Group {
                        Text("Step 4 — Locate the TCF7L2 Regulatory Region")
                            .font(.headline)
                        subsection(
                            subtitle: "Cas9 Mechanics",
                            lines: [
                                "Glides along DNA → checks for a bookmark sequence (PAM) → opens the DNA → pairs with guide RNA (Sternberg et al., 2014; Nature)."
                            ])
                        subsection(
                            subtitle: "Cas3 Mechanics",
                            lines: [
                                "A surveillance scout complex finds the target site first and then recruits Cas3 to attach (Makarova et al., 2011; Nature Reviews Microbiology)."
                            ])
                    }

                    Group {
                        Text("Step 5 — DNA Recognition")
                            .font(.headline)
                        subsection(
                            subtitle: "Cas9",
                            lines: [
                                "Guide RNA pairs with the target DNA like a key in a lock, triggering structural changes that activate the cutting domains (Nishimasu et al., 2014; Cell)."
                            ])
                        subsection(
                            subtitle: "Cas3",
                            lines: [
                                "The scout complex confirms the target sequence and signals Cas3 to begin unwinding the DNA strands (Huo et al., 2014; Nature Structural & Molecular Biology)."
                            ])
                    }

                    Group {
                        Text("Step 6 — DNA Modification")
                            .font(.headline)
                        subsection(
                            subtitle: "Cas9",
                            lines: [
                                "Holds the target site steady while base editors swap out the risk letter, keeping the rest of the genetic code intact (Komor et al., 2016; Nature)."
                            ])
                        subsection(
                            subtitle: "Cas3",
                            lines: [
                                "Unzips and chews up long stretches of DNA, creating large structural deletions (Dolan et al., 2019; Molecular Cell)."
                            ])
                    }

                    mechanicsSection(
                        title: "Step 7 — Cellular Response",
                        activity: nil,
                        bodyLines: [
                            "Cas9 Fix: The cell's repair team seals the precise edit, restoring normal TCF7L2 expression levels (Cox et al., 2015; Nature Medicine).",
                            "Cas3 Removal: The cell seals the remaining ends together, resulting in the permanent removal of that regulatory DNA segment."
                        ])

                    mechanicsSection(
                        title: "Step 8 — Functional Evaluation",
                        activity: "CRISPR Activity: None",
                        bodyLines: [
                            "Measure TCF7L2 levels and verify that pancreatic beta cells release insulin properly when blood sugar rises (Lyssenko et al., 2007; Journal of Clinical Investigation)."
                        ])

                    Group {
                        Text("Mechanical Comparison")
                            .font(.headline)
                        bulletComparison(
                            title: "Cas9",
                            bullets: [
                                "Primary function: localized, targeted editing and base replacement (Jinek et al., 2012; Science).",
                                "Recognition: guide RNA + PAM sequence (Sternberg et al., 2014; Nature).",
                                "DNA effect: single-site sequence modification.",
                                "Precision: high accuracy for single-letter edits (Komor et al., 2016; Nature).",
                                "Typical use: correcting specific mutations or disease variants.",
                                "Suitability for TCF7L2 variant correction: ideal for restoring single-base regulatory function."
                            ])
                            
                        bulletComparison(
                            title: "Cas3",
                            bullets: [
                                "Primary function: progressive DNA degradation post-recruitment (Sinkunas et al., 2011; EMBO Journal).",
                                "Recognition: Cascade surveillance complex recruits Cas3 (Makarova et al., 2011; Nature Reviews Microbiology).",
                                "DNA effect: extended DNA deletion (Dolan et al., 2019; Molecular Cell).",
                                "Precision: low for single-letter changes.",
                                "Typical use: deleting full gene regions or probing regulatory elements.",
                                "Suitability for TCF7L2 variant correction: less aligned; primarily used for research-based gene knockouts."
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

