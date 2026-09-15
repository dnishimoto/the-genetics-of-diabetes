//
//  AboutView 2.swift
//  The Genetics of Diabetes
//
//  Created by David Nishimoto on 9/15/26.
//


//
//  AboutView.swift
//  Genetics of Diabetes
//
//  TCF7L2 Expression & β-Cell Insulin Response
//

import SwiftUI

struct AboutView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    header

                    whyTCF7L2Matters

                    functionalPipeline

                    tcf7l2Expression

                    betaCellResponse

                    analogy

                    diabetesConnection

                    interpretation

                    scientificNote
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("TCF7L2 & β-Cell Function")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {

            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 42))
                .foregroundStyle(.blue)

            Text("TCF7L2 Expression")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            Text("From gene regulation to β-cell insulin response")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(
                "This section explains why TCF7L2 is important for understanding "
                + "glucose regulation, pancreatic β-cell function, and insulin response."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Why TCF7L2 Matters

    private var whyTCF7L2Matters: some View {
        InformationCard(
            title: "Why TCF7L2 Matters",
            icon: "questionmark.circle.fill"
        ) {
            VStack(alignment: .leading, spacing: 12) {

                Text(
                    "TCF7L2 is a gene that encodes a transcription factor involved "
                    + "in the Wnt/β-catenin signaling pathway."
                )

                Text(
                    "A transcription factor acts more like a control system inside "
                    + "the cell than like a structural component. It helps determine "
                    + "which other genes are turned up, turned down, or maintained."
                )

                Text(
                    "TCF7L2 is particularly important in diabetes research because "
                    + "genetic variation near TCF7L2, especially rs7903146, has one "
                    + "of the strongest and most reproducible associations with "
                    + "type 2 diabetes risk."
                )

                HighlightBox(
                    title: "Key idea",
                    text: "TCF7L2 helps regulate the cellular program that allows "
                        + "β-cells to respond appropriately to metabolic signals."
                )
            }
        }
    }

    // MARK: - Functional Pipeline

    private var functionalPipeline: some View {
        InformationCard(
            title: "The TCF7L2 Functional Pipeline",
            icon: "arrow.down.circle.fill"
        ) {
            VStack(spacing: 0) {

                PipelineStep(
                    number: "1",
                    title: "TCF7L2 DNA",
                    description:
                        "The TCF7L2 gene is stored in the cell's DNA and contains "
                        + "the information needed to produce the TCF7L2 protein.",
                    analogy:
                        "The DNA is the master instruction manual."
                )

                PipelineConnector()

                PipelineStep(
                    number: "2",
                    title: "Gene Expression",
                    description:
                        "Regulatory machinery controls whether the TCF7L2 gene "
                        + "is actively transcribed.",
                    analogy:
                        "This is like opening the instruction manual to the page "
                        + "the cell needs."
                )

                PipelineConnector()

                PipelineStep(
                    number: "3",
                    title: "TCF7L2 mRNA",
                    description:
                        "When the gene is transcribed, an RNA copy of its "
                        + "instructions is produced.",
                    analogy:
                        "The mRNA is a working copy taken from the master manual."
                )

                PipelineConnector()

                PipelineStep(
                    number: "4",
                    title: "TCF7L2 Protein",
                    description:
                        "The mRNA is used to produce the TCF7L2 transcription "
                        + "factor protein.",
                    analogy:
                        "The working copy is handed to the cell's production team."
                )

                PipelineConnector()

                PipelineStep(
                    number: "5",
                    title: "Wnt / β-Catenin Signaling",
                    description:
                        "TCF7L2 participates in Wnt/β-catenin signaling. "
                        + "Its transcriptional activity depends on the signaling "
                        + "context and interacting proteins such as β-catenin.",
                    analogy:
                        "The control officer receives a signal telling it "
                        + "which instructions should be activated."
                )

                PipelineConnector()

                PipelineStep(
                    number: "6",
                    title: "Target Gene Regulation",
                    description:
                        "TCF7L2-containing transcriptional complexes regulate "
                        + "downstream gene programs involved in cellular function.",
                    analogy:
                        "The control officer sends instructions to different "
                        + "departments."
                )

                PipelineConnector()

                PipelineStep(
                    number: "7",
                    title: "β-Cell Functional State",
                    description:
                        "Those gene programs can influence β-cell biology, "
                        + "including pathways involved in glucose responsiveness "
                        + "and insulin secretion.",
                    analogy:
                        "The departments collectively determine how well "
                        + "the factory operates."
                )

                PipelineConnector()

                PipelineStep(
                    number: "8",
                    title: "Glucose Detection",
                    description:
                        "A functioning β-cell senses changes in glucose and "
                        + "converts metabolic information into an intracellular "
                        + "signal.",
                    analogy:
                        "The factory receives a delivery notification saying "
                        + "how much raw material has arrived."
                )

                PipelineConnector()

                PipelineStep(
                    number: "9",
                    title: "Insulin Response",
                    description:
                        "Glucose metabolism and intracellular signaling promote "
                        + "insulin granule release from β-cells.",
                    analogy:
                        "The factory responds by releasing the product "
                        + "needed by the rest of the system."
                )

                PipelineConnector()

                PipelineStep(
                    number: "10",
                    title: "Blood-Glucose Regulation",
                    description:
                        "Insulin acts on tissues throughout the body to help "
                        + "control circulating glucose.",
                    analogy:
                        "The product is delivered to the buildings that need it, "
                        + "helping restore the system to its target operating range."
                )
            }
        }
    }

    // MARK: - Expression

    private var tcf7l2Expression: some View {
        InformationCard(
            title: "What Does TCF7L2 Expression Mean?",
            icon: "waveform.path.ecg"
        ) {
            VStack(alignment: .leading, spacing: 12) {

                Text(
                    "Expression describes how actively information in the TCF7L2 "
                    + "gene is being used to produce RNA and ultimately TCF7L2 protein."
                )

                ExpressionRow(
                    label: "DNA",
                    value: "TCF7L2 gene"
                )

                ExpressionArrow()

                ExpressionRow(
                    label: "RNA",
                    value: "TCF7L2 mRNA"
                )

                ExpressionArrow()

                ExpressionRow(
                    label: "Protein",
                    value: "TCF7L2 transcription factor"
                )

                ExpressionArrow()

                ExpressionRow(
                    label: "Function",
                    value: "Regulation of downstream gene programs"
                )

                Text(
                    "Importantly, more TCF7L2 RNA does not automatically mean "
                    + "better β-cell function. Human studies have reported complex "
                    + "relationships between TCF7L2 expression, protein abundance, "
                    + "genotype, and insulin secretion."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                HighlightBox(
                    title: "Expression is a control variable",
                    text:
                        "The meaningful question is not simply whether TCF7L2 "
                        + "is present. It is whether the correct amount, form, "
                        + "timing, and cellular context produce an appropriate "
                        + "functional response."
                )
            }
        }
    }

    // MARK: - β Cell Response

    private var betaCellResponse: some View {
        InformationCard(
            title: "β-Cell Insulin Response",
            icon: "drop.fill"
        ) {
            VStack(alignment: .leading, spacing: 14) {

                ResponseRow(
                    number: "1",
                    title: "Glucose rises",
                    text:
                        "Blood glucose increases after food or another glucose load."
                )

                ResponseRow(
                    number: "2",
                    title: "β-cell senses the change",
                    text:
                        "Glucose enters the β-cell and is metabolized, changing "
                        + "the cell's energetic and electrical state."
                )

                ResponseRow(
                    number: "3",
                    title: "Insulin secretion is triggered",
                    text:
                        "The β-cell uses intracellular signaling to promote "
                        + "exocytosis of insulin-containing granules."
                )

                ResponseRow(
                    number: "4",
                    title: "Insulin enters the circulation",
                    text:
                        "Released insulin signals tissues to alter glucose uptake "
                        + "and metabolism."
                )

                ResponseRow(
                    number: "5",
                    title: "Glucose is brought under control",
                    text:
                        "The coordinated response contributes to restoration "
                        + "of glucose homeostasis."
                )

                Divider()

                Text(
                    "TCF7L2 is upstream of this process in the sense that it "
                    + "participates in transcriptional programs that can affect "
                    + "β-cell function and responsiveness. It is not itself the "
                    + "molecular switch that directly releases an insulin granule."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Analogy

    private var analogy: some View {
        InformationCard(
            title: "The Complete Analogy: A Smart Factory",
            icon: "building.2.fill"
        ) {
            VStack(alignment: .leading, spacing: 14) {

                AnalogyRow(
                    title: "DNA",
                    analogy: "The master factory manual",
                    meaning:
                        "Contains the instructions for producing TCF7L2."
                )

                AnalogyRow(
                    title: "Gene expression",
                    analogy: "Opening the correct manual page",
                    meaning:
                        "Determines whether the TCF7L2 instructions are actively used."
                )

                AnalogyRow(
                    title: "mRNA",
                    analogy: "A photocopy of the instructions",
                    meaning:
                        "Carries the information from DNA to the protein-production machinery."
                )

                AnalogyRow(
                    title: "TCF7L2 protein",
                    analogy: "The factory supervisor",
                    meaning:
                        "Helps control which downstream instructions are activated."
                )

                AnalogyRow(
                    title: "Wnt / β-catenin",
                    analogy: "The factory's communication network",
                    meaning:
                        "Provides signaling information that influences transcriptional activity."
                )

                AnalogyRow(
                    title: "Target genes",
                    analogy: "Factory departments",
                    meaning:
                        "Carry out specialized functions that affect cellular behavior."
                )

                AnalogyRow(
                    title: "β-cell",
                    analogy: "The glucose-response factory",
                    meaning:
                        "Detects metabolic conditions and produces/releases insulin."
                )

                AnalogyRow(
                    title: "Glucose",
                    analogy: "Incoming raw material",
                    meaning:
                        "Provides the metabolic signal that demands an appropriate response."
                )

                AnalogyRow(
                    title: "Insulin",
                    analogy: "The factory's outgoing product",
                    meaning:
                        "Signals other tissues to help manage circulating glucose."
                )

                AnalogyRow(
                    title: "Glucose homeostasis",
                    analogy: "The factory staying within its operating range",
                    meaning:
                        "Represents the body's overall ability to maintain appropriate glucose levels."
                )
            }
        }
    }

    // MARK: - Diabetes Connection

    private var diabetesConnection: some View {
        InformationCard(
            title: "Why TCF7L2 Is Important in Diabetes",
            icon: "exclamationmark.triangle.fill"
        ) {
            VStack(alignment: .leading, spacing: 12) {

                Text(
                    "TCF7L2 is one of the most extensively studied genetic loci "
                    + "associated with type 2 diabetes risk."
                )

                Text(
                    "The diabetes-associated rs7903146 variant has been linked "
                    + "to altered insulin responses and impaired glucose tolerance "
                    + "in multiple human studies."
                )

                Text(
                    "Research also indicates that TCF7L2 participates in the "
                    + "incretin pathway, including cellular responses to hormones "
                    + "such as GLP-1 and GIP that amplify glucose-dependent insulin "
                    + "secretion."
                )

                HighlightBox(
                    title: "The central concept",
                    text:
                        "A β-cell does not simply need to contain insulin. "
                        + "It must be able to sense glucose and release an "
                        + "appropriate amount of insulin at the appropriate time."
                )
            }
        }
    }

    // MARK: - Interpretation

    private var interpretation: some View {
        InformationCard(
            title: "How to Interpret the Pipeline",
            icon: "magnifyingglass"
        ) {
            VStack(alignment: .leading, spacing: 12) {

                InterpretationRow(
                    title: "TCF7L2 expression",
                    text:
                        "Measures the activity of the TCF7L2 gene at the RNA/protein "
                        + "level, depending on the assay."
                )

                InterpretationRow(
                    title: "β-cell function",
                    text:
                        "Describes whether β-cells can appropriately respond to "
                        + "metabolic stimulation."
                )

                InterpretationRow(
                    title: "Glucose-stimulated insulin secretion",
                    text:
                        "Tests whether increasing glucose produces an appropriate "
                        + "increase in insulin release."
                )

                InterpretationRow(
                    title: "Incretin response",
                    text:
                        "Tests how effectively signals such as GLP-1 or GIP "
                        + "enhance insulin secretion."
                )

                InterpretationRow(
                    title: "Functional outcome",
                    text:
                        "Connects cellular measurements to glucose regulation "
                        + "without assuming that changing one molecular variable "
                        + "automatically produces a therapeutic result."
                )
            }
        }
    }

    // MARK: - Scientific Note

    private var scientificNote: some View {
        VStack(alignment: .leading, spacing: 10) {

            Label("Scientific Context", systemImage: "info.circle.fill")
                .font(.headline)

            Text(
                "TCF7L2 biology is complex. Evidence supports an important role "
                + "in Wnt/β-catenin signaling, β-cell biology, incretin responsiveness, "
                + "and glucose regulation, but the relationship between TCF7L2 "
                + "expression and insulin secretion is not a simple one-to-one rule."
            )

            Text(
                "This visualization is an educational representation of the "
                + "biological pathway. It does not establish that modifying TCF7L2 "
                + "expression will restore normal β-cell function or treat diabetes."
            )
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 6)
        .padding(.bottom, 20)
    }
}

// MARK: - Reusable Components

private struct InformationCard<Content: View>: View {

    let title: String
    let icon: String
    let content: Content

    init(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(.blue)

                Text(title)
                    .font(.headline)

                Spacer()
            }

            Divider()

            content
        }
        .padding(17)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Pipeline Step

private struct PipelineStep: View {

    let number: String
    let title: String
    let description: String
    let analogy: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {

            HStack(alignment: .top, spacing: 12) {

                Text(number)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 27, height: 27)
                    .background(
                        Circle()
                            .fill(Color.blue)
                    )

                VStack(alignment: .leading, spacing: 5) {

                    Text(title)
                        .font(.subheadline.weight(.semibold))

                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Analogy: \(analogy)")
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

// MARK: - Pipeline Connector

private struct PipelineConnector: View {

    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.blue.opacity(0.25))
                .frame(width: 2, height: 20)
                .padding(.leading, 13)

            Spacer()
        }
    }
}

// MARK: - Expression Row

private struct ExpressionRow: View {

    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
        }
        .padding(.vertical, 7)
    }
}

private struct ExpressionArrow: View {

    var body: some View {
        HStack {
            Spacer()

            Image(systemName: "arrow.down")
                .font(.caption.weight(.bold))
                .foregroundStyle(.blue)

            Spacer()
        }
    }
}

// MARK: - Response Row

private struct ResponseRow: View {

    let number: String
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            Text(number)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(
                    Circle()
                        .fill(Color.blue)
                )

            VStack(alignment: .leading, spacing: 4) {

                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Analogy Row

private struct AnalogyRow: View {

    let title: String
    let analogy: String
    let meaning: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {

            Text(title)
                .font(.subheadline.weight(.semibold))

            Text("“\(analogy)”")
                .font(.subheadline)
                .foregroundStyle(.blue)

            Text(meaning)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 3)
    }
}

// MARK: - Interpretation Row

private struct InterpretationRow: View {

    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            Text(title)
                .font(.subheadline.weight(.semibold))

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Highlight Box

private struct HighlightBox: View {

    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {

            Text(title)
                .font(.subheadline.weight(.bold))

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.08))
        )
    }
}