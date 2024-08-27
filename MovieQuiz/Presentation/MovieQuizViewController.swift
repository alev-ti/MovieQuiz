import UIKit

final class MovieQuizViewController: UIViewController {
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Dark Knight",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Kill Bill",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Avengers",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Deadpool",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Green Knight",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Old",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false),
        QuizQuestion(image: "Tesla",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false),
        QuizQuestion(image: "Vivarium",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false)
    ]
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        onAnswerButtonClicked(answer: true)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        onAnswerButtonClicked(answer: false)
    }
    
    private func onAnswerButtonClicked(answer: Bool) {
        guard currentQuestionIndex < questions.count else { return }
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image) ?? UIImage()
        let questionNumber = "\(currentQuestionIndex + 1)/\(questions.count)"
        return QuizStepViewModel(image: image, question: model.text, questionNumber: questionNumber)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        fillImageViewBorder(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.clearImageViewBorder()
            self.showNextQuestionOrResults()
        }
    }
    
    private func fillImageViewBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    private func clearImageViewBorder() {
        imageView.layer.borderWidth = 0
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            showResultsAlert()
        } else {
            currentQuestionIndex += 1
            showNextQuestion()
        }
    }
    
    private func showResultsAlert() {
        let text = "\(Messages.yourResult.rawValue)\(correctAnswers)/\(questions.count)"
        let viewModel = QuizResultsViewModel(
            title: Messages.roundFinished.rawValue,
            text: text,
            buttonText: Messages.playAgain.rawValue)
        showAlert(result: viewModel)
    }
    
    private func showNextQuestion() {
        guard currentQuestionIndex < questions.count else { return }
        let nextQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: nextQuestion)
        show(quiz: viewModel)
    }
    
    private func showAlert(result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.resetQuiz()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showNextQuestion()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNextQuestion()
    }
}

struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

enum Messages: String {
    case yourResult = "Ваш результат: "
    case roundFinished = "Этот раунд окончен!"
    case playAgain = "Сыграть ещё раз"
}
