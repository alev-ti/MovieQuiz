import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData(completion: @escaping () -> Void) {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                    case .success(let mostPopularMovies):
                        self.movies = mostPopularMovies.items
                        completion()
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

