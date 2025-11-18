import SwiftUI

struct MiniQuizView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let questions: [QuizQuestion]
    
    @State private var index = 0
    @State private var selectedChoice: Int? = nil
    @State private var score = 0
    @State private var showSummary = false
    
    private var currentQuestion: QuizQuestion? {
        guard !questions.isEmpty else { return nil }
        let safeIndex = min(index, max(questions.count - 1, 0))
        return questions[safeIndex]
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                if showSummary {
                    summaryView
                } else if let question = currentQuestion {
                    quizCard(for: question)
                } else {
                    ProgressView("Preparing quiz…")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
            .padding()
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    @ViewBuilder
    private func quizCard(for question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Question \(index + 1) of \(questions.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(question.prompt)
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(question.choices.indices, id: \.self) { choiceIndex in
                    Button {
                        guard selectedChoice == nil else { return }
                        selectedChoice = choiceIndex
                        if choiceIndex == question.answerIndex {
                            score += 1
                        }
                    } label: {
                        HStack {
                            Text(question.choices[choiceIndex])
                            Spacer()
                        }
                        .padding()
                        .background(choiceBackground(for: choiceIndex, question: question))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(choiceBorder(for: choiceIndex, question: question), lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedChoice != nil)
                }
            }
            
            if let selectedChoice = selectedChoice {
                let isCorrect = selectedChoice == question.answerIndex
                Text(isCorrect ? "Great job!" : "Keep going!")
                    .font(.headline)
                    .foregroundStyle(isCorrect ? .green : .orange)
                Text(question.explanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Button(index < questions.count - 1 ? "Next question" : "Finish quiz") {
                    advance()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        }
    }
    
    private func advance() {
        guard !questions.isEmpty else { return }
        if index < questions.count - 1 {
            index += 1
            selectedChoice = nil
        } else {
            showSummary = true
        }
    }
    
    private var summaryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quiz complete!")
                .font(.title2)
                .fontWeight(.bold)
            Text("Score: \(score) / \(questions.count)")
                .font(.headline)
            Text("Revisit any lessons if a question felt tricky. Consistency compounds.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
    }
    
    private func choiceBackground(for choice: Int, question: QuizQuestion) -> Color {
        guard let selectedChoice else { return Color(.systemGray6) }
        if choice == selectedChoice {
            return choice == question.answerIndex ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
        }
        if choice == question.answerIndex {
            return Color.green.opacity(0.15)
        }
        return Color(.systemGray6)
    }
    
    private func choiceBorder(for choice: Int, question: QuizQuestion) -> Color {
        guard let selectedChoice else { return Color.clear }
        if choice == selectedChoice {
            return choice == question.answerIndex ? .green : .red
        }
        if choice == question.answerIndex {
            return .green
        }
        return .clear
    }
}

