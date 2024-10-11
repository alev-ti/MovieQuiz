import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let statisticService: StatisticServiceProtocol!
    var questionFactory: QuestionFactoryProtocol?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        viewController.loadingIndicator(showed: true)
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.loadingIndicator(showed: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.loadingIndicator(showed: false)
        let errorMessage = (error as NSError).userInfo[NSLocalizedDescriptionKey] as? String ?? error.localizedDescription
        let viewModel = AlertModel(
            title: "Error",
            message: errorMessage,
            buttonText: "Try again",
            completion: { [weak self] in
                self?.viewController?.loadingIndicator(showed: true)
                self?.questionFactory?.loadData { [weak self] in
                    self?.viewController?.loadingIndicator(showed: false)
                }
            }
        )
        
        viewController?.show(networkError: viewModel)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        viewController?.changeStateButton(isEnabled: true)

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            self.createResultsMessage()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        viewController?.fillImageViewBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            viewController?.clearImageViewBorder()
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func createResultsMessage() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGameCorrect = statisticService.bestGame.correct
        let bestGameTotal = statisticService.bestGame.total
        let bestGameDate = statisticService.bestGame.date.dateTimeString
        let totalAccuracy = "\(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let viewModel = AlertModel(
            title: Messages.roundFinished.rawValue,
            message: """
            \(Messages.yourResult.rawValue)\(correctAnswers)/\(questionsAmount)
            \(Messages.gamesCount.rawValue) \(statisticService.gamesCount)
            \(Messages.bestGame.rawValue) \(bestGameCorrect)/\(bestGameTotal) (\(bestGameDate))
            \(Messages.totalAccuracy.rawValue) \(totalAccuracy)
            """,
            buttonText: Messages.playAgain.rawValue,
            completion: self.resetQuiz
        )
        
        viewController?.show(quiz: viewModel)
    }
    
    func resetQuiz() {
        self.resetQuestionIndex()
        self.correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        return QuizStepViewModel(image: image, question: model.text, questionNumber: questionNumber)
    }
    
    func onAnswerButtonClicked(answer: Bool) {
        if let currentQuestion = currentQuestion {
            viewController?.changeStateButton(isEnabled: false)
            self.proceedWithAnswer(isCorrect: answer == currentQuestion.correctAnswer)
        }
    }
    
    func yesButtonClicked() {
        self.onAnswerButtonClicked(answer: true)
    }

    func noButtonClicked() {
        self.onAnswerButtonClicked(answer: false)
    }
    
}
