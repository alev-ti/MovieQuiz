import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func presentAlert(_ alert: UIAlertController)
}
