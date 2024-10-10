import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private let presenter = MovieQuizPresenter()
    
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        statisticService = StatisticServiceImplementation()
        
        loadingIndicator(showed: true)

        questionFactory?.loadData { [weak self] in
            self?.loadingIndicator(showed: false)
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        let errorMessage = (error as NSError).userInfo[NSLocalizedDescriptionKey] as? String ?? error.localizedDescription
        showNetworkError(message: errorMessage)
    }
    
    private func loadingIndicator(showed: Bool) {
        if showed {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    private func showNetworkError(message: String) {
        loadingIndicator(showed: false)
        
        let viewModel = AlertModel(
            title: "Error",
            message: message,
            buttonText: "Try again",
            completion: { [weak self] in
                self?.loadingIndicator(showed: true)
                self?.questionFactory?.loadData { [weak self] in
                    self?.loadingIndicator(showed: false)
                }
            }
        )
        
        alertPresenter?.showAlert(with: viewModel)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        
        changeStateButton(isEnabled: true)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        fillImageViewBorder(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
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
        if presenter.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            showResultsAlert()
        } else {
            presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func showResultsAlert() {
        guard let statisticService else { return }
        
        let bestGameCorrect = statisticService.bestGame.correct
        let bestGameTotal = statisticService.bestGame.total
        let bestGameDate = statisticService.bestGame.date.dateTimeString
        let totalAccuracy = "\(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let viewModel = AlertModel(
            title: Messages.roundFinished.rawValue,
            message: """
            \(Messages.yourResult.rawValue)\(correctAnswers)/\(presenter.questionsAmount)
            \(Messages.gamesCount.rawValue) \(statisticService.gamesCount)
            \(Messages.bestGame.rawValue) \(bestGameCorrect)/\(bestGameTotal) (\(bestGameDate))
            \(Messages.totalAccuracy.rawValue) \(totalAccuracy)
            """,
            buttonText: Messages.playAgain.rawValue,
            completion: resetQuiz
        )
        
        alertPresenter?.showAlert(with: viewModel)
    }
    
    func changeStateButton(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func resetQuiz() {
        presenter.resetQuestionIndex()
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func presentAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
}

