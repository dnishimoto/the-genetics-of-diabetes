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

