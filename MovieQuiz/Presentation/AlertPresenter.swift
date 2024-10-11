import UIKit

final class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert(with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "messageAlert"
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        delegate?.presentAlert(alert)
    }
}
