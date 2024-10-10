import UIKit

final class MovieQuizPresenter {
    weak var viewController: MovieQuizViewController?
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        return QuizStepViewModel(image: image, question: model.text, questionNumber: questionNumber)
    }
    
    private func onAnswerButtonClicked(answer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        viewController?.changeStateButton(isEnabled: false)
        viewController?.showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    func yesButtonClicked() {
        onAnswerButtonClicked(answer: true)
    }

    func noButtonClicked() {
        onAnswerButtonClicked(answer: false)
    }
    
}
