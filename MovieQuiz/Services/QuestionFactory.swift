import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                    case .success(let mostPopularMovies):
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    case .failure(let error):
                        self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            guard !self.movies.isEmpty else {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: NSError(domain: "QuestionFactory", code: 1, userInfo: [NSLocalizedDescriptionKey: ErrorMessages.noMovies.rawValue]))
                }
                return
            }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: NSError(domain: "QuestionFactory", code: 2, userInfo: [NSLocalizedDescriptionKey: ErrorMessages.noImage.rawValue]))
                }
                return
            }
            
            let movieRating = Float(movie.rating) ?? 0
            let questionRating = Float.random(in: 1..<10)
            let correctAnswer = movieRating > questionRating
            
            let question = QuizQuestion(image: imageData,
                                        text: QuestionText.ratingComparison(questionRating).text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}

// не удалять - пригодится в след спринте
//let questions: [QuizQuestion] = [
//    QuizQuestion(image: "The Godfather",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: true),
//    QuizQuestion(image: "The Dark Knight",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: true),
//    QuizQuestion(image: "Kill Bill",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: true),
//    QuizQuestion(image: "The Avengers",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: true),
//    QuizQuestion(image: "Deadpool",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: true),
//    QuizQuestion(image: "The Green Knight",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: true),
//    QuizQuestion(image: "Old",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: false),
//    QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: false),
//    QuizQuestion(image: "Tesla",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: false),
//    QuizQuestion(image: "Vivarium",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: false)
//]
