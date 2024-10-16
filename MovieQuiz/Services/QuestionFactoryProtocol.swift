import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData(completion: @escaping () -> Void)
    func loadData()
}
