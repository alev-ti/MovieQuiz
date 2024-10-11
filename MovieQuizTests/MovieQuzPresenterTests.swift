import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func loadingIndicator(showed: Bool) {}
    func show(networkError: AlertModel) {}
    func show(quiz step: QuizStepViewModel) {}
    func show(quiz result: AlertModel) {}
    func fillImageViewBorder(isCorrect: Bool) {}
    func clearImageViewBorder() {}
    func changeStateButton(isEnabled: Bool) {}
    func presentAlert(_ alert: UIAlertController) {}
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)

        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
