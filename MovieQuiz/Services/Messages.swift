import Foundation

enum Messages: String {
    case roundFinished = "Этот раунд окончен!"
    case yourResult = "Ваш результат: "
    case gamesCount = "Количество сыгранных квизов: "
    case bestGame = "Рекорд: "
    case totalAccuracy = "Средняя точность: "
    case playAgain = "Сыграть ещё раз"
}

enum QuestionText {
    case ratingComparison(Float)
    
    var text: String {
        switch self {
        case .ratingComparison(let questionRating):
            return "Рейтинг этого фильма больше чем \(Int(questionRating))?"
        }
    }
}

enum ErrorMessages: String {
    case noMovies = "No movies available"
    case noImage = "Failed to load image"
}
