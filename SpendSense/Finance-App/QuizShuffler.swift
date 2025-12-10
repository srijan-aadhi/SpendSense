import Foundation

extension QuizQuestion {
    /// Creates a shuffled version of the question where choices are randomized
    /// and the answerIndex is updated to point to the correct answer in the new order
    func withShuffledChoices() -> QuizQuestion {
        guard answerIndex < choices.count else {
            return self
        }
        
        // Get the correct answer
        let correctAnswer = choices[answerIndex]
        
        // Shuffle the choices
        let shuffledChoices = choices.shuffled()
        
        // Find the new index of the correct answer
        guard let newAnswerIndex = shuffledChoices.firstIndex(of: correctAnswer) else {
            return self
        }
        
        // Return a new question with shuffled choices and updated answer index
        return QuizQuestion(
            prompt: prompt,
            choices: shuffledChoices,
            answerIndex: newAnswerIndex,
            explanation: explanation
        )
    }
}

extension Array where Element == QuizQuestion {
    /// Shuffles answer choices for all questions in the array
    func withShuffledChoices() -> [QuizQuestion] {
        return self.map { $0.withShuffledChoices() }
    }
}

