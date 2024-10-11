import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private var presenter: MovieQuizPresenter!
    var alertPresenter: AlertPresenter?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    func loadingIndicator(showed: Bool) {
        if showed {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    func showNetworkError(message: String) {
        let viewModel = AlertModel(
            title: "Error",
            message: message,
            buttonText: "Try again",
            completion: { [weak self] in
                self?.loadingIndicator(showed: true)
                self?.presenter.questionFactory?.loadData { [weak self] in
                    self?.loadingIndicator(showed: false)
                }
            }
        )
        
        alertPresenter?.showAlert(with: viewModel)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func fillImageViewBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func clearImageViewBorder() {
        imageView.layer.borderWidth = 0
    }
    
    func changeStateButton(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func presentAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
}

