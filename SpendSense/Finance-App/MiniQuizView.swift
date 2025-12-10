import SwiftUI

struct MiniQuizView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let questions: [QuizQuestion]
    
    @State private var index = 0
    @State private var selectedChoice: Int? = nil
    @State private var score = 0
    @State private var showSummary = false
    @State private var isProcessing = false
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    
    private var currentQuestion: QuizQuestion? {
        guard !questions.isEmpty else { return nil }
        let safeIndex = min(index, max(questions.count - 1, 0))
        return questions[safeIndex]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if showSummary {
                        summaryView
                    } else if let question = currentQuestion {
                        quizCard(for: question)
                    } else {
                        ProgressView("Preparing quiz…")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .overlay {
                if isProcessing {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
        }
    }
    
    @ViewBuilder
    private func quizCard(for question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Progress indicator
            HStack {
                Text("Question \(index + 1) of \(questions.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                ProgressView(value: Double(index + 1), total: Double(questions.count))
                    .frame(width: 100)
            }
            
            // Question prompt with better visual hierarchy
            VStack(alignment: .leading, spacing: 8) {
                Text(question.prompt)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 8)
            
            // Answer choices with animations
            VStack(spacing: 12) {
                ForEach(question.choices.indices, id: \.self) { choiceIndex in
                    Button {
                        guard selectedChoice == nil else { return }
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        // Process selection with slight delay for better UX
                        isProcessing = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            selectedChoice = choiceIndex
                            if choiceIndex == question.answerIndex {
                                score += 1
                                // Success haptic
                                let notificationFeedback = UINotificationFeedbackGenerator()
                                notificationFeedback.notificationOccurred(.success)
                            } else {
                                // Error haptic
                                let notificationFeedback = UINotificationFeedbackGenerator()
                                notificationFeedback.notificationOccurred(.error)
                            }
                            isProcessing = false
                        }
                    } label: {
                        HStack {
                            Text(question.choices[choiceIndex])
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if let selectedChoice = selectedChoice {
                                if choiceIndex == question.answerIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else if choiceIndex == selectedChoice && choiceIndex != question.answerIndex {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
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
                    .disabled(selectedChoice != nil || isProcessing)
                    .opacity(selectedChoice != nil && choiceIndex != selectedChoice && choiceIndex != question.answerIndex ? 0.5 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: selectedChoice)
                }
            }
            
            // Feedback section with better styling
            if let selectedChoice = selectedChoice {
                let isCorrect = selectedChoice == question.answerIndex
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundStyle(isCorrect ? .green : .orange)
                        Text(isCorrect ? "Correct! Well done." : "Not quite, but you're learning!")
                            .font(.headline)
                            .foregroundStyle(isCorrect ? .green : .orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Explanation:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        Text(question.explanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button {
                        advance()
                    } label: {
                        HStack {
                            Text(index < questions.count - 1 ? "Next Question" : "Finish Quiz")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }
    
    private func advance() {
        guard !questions.isEmpty else { return }
        
        // Haptic feedback for navigation
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            if index < questions.count - 1 {
                index += 1
                selectedChoice = nil
            } else {
                showSummary = true
            }
        }
    }
    
    private var summaryView: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.largeTitle)
                    Text("Quiz Complete!")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Score")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("\(score) / \(questions.count)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(scoreColor)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                let percentage = Double(score) / Double(questions.count)
                VStack(alignment: .leading, spacing: 8) {
                    Text(encouragementMessage(percentage: percentage))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Spacer()
            
            Button {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                dismiss()
            } label: {
                HStack {
                    Text("Done")
                    Spacer()
                    Image(systemName: "checkmark")
                }
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
    
    private var scoreColor: Color {
        let percentage = Double(score) / Double(questions.count)
        if percentage >= 0.8 { return .green }
        if percentage >= 0.6 { return .orange }
        return .red
    }
    
    private func encouragementMessage(percentage: Double) -> String {
        if percentage >= 0.9 {
            return "Outstanding work! You've mastered these concepts. Keep building on this knowledge!"
        } else if percentage >= 0.7 {
            return "Great job! You're on the right track. Review any tricky questions to strengthen your understanding."
        } else if percentage >= 0.5 {
            return "Good effort! Learning takes practice. Revisit the lessons and try again—consistency compounds over time."
        } else {
            return "Keep learning! Financial concepts can be challenging. Take your time with the lessons and try the quiz again when you're ready."
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

