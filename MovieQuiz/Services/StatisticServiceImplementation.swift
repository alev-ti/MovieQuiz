import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {
    private let storage = UserDefaults.standard
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct: Int = storage.integer(forKey: Keys.correct.rawValue)
            let total: Int = storage.integer(forKey: Keys.total.rawValue)
            let date: Date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    var totalQuestions: Int {
        get {
            storage.integer(forKey: Keys.totalQuestions.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestions.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        return totalQuestions != 0 ? Double(correctAnswers) / Double(totalQuestions) * 100 : 0.0
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1

        correctAnswers += count
        totalQuestions += amount

        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if (currentGame.isBetterThan(bestGame)) {
            bestGame = currentGame
        }
    }
    
    func clearStorage() {
        let allValues = UserDefaults.standard.dictionaryRepresentation()
        allValues.keys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}

private enum Keys: String {
    case gamesCount
    case correct
    case total
    case date
    case totalQuestions
    case correctAnswers
}
