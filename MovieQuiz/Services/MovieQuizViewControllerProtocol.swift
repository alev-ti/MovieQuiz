import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func loadingIndicator(showed: Bool)
    func show(networkError: AlertModel)
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: AlertModel)
    func fillImageViewBorder(isCorrect: Bool)
    func clearImageViewBorder()
    func changeStateButton(isEnabled: Bool)
}
