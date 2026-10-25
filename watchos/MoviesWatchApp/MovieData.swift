import Foundation

struct WatchlistEntry: Codable {
    var movies: [String]
}

struct MovieDatabase: Codable {
    var watchlist: [WatchlistEntry]
    var watched: [[String: [String]]]
}

enum MovieTargetSection: String, CaseIterable, Identifiable {
    case watchlist = "Watchlist"
    case watched = "Watched"

    var id: String { rawValue }
}

@MainActor
final class MovieViewModel: ObservableObject {
    @Published var watchlistMovies: [String] = []
    @Published var watchedByYear: [(year: String, movies: [String])] = []
    @Published var totalMovies: Int = 0
    @Published var moviesNames: [String] = []
    @Published var searchText: String = ""

    @Published var isWatchlistExpanded: Bool = false
    @Published var isWatchedExpanded: Bool = false
    @Published var expandedYears: Set<String> = []

    // Add Movie Form State
    @Published var isAddMovieExpanded: Bool = false
    @Published var newMovieTitle: String = ""
    @Published var selectedSection: MovieTargetSection = .watchlist
    @Published var newMovieYear: String = String(Calendar.current.component(.year, from: Date()))

    private var rawWatchedMovies: [String: [String]] = [:]

    var searchResults: [String] {
        let searchValue = searchText.lowercased()
        guard !searchValue.isEmpty else { return [] }
        return moviesNames.filter { $0.lowercased().contains(searchValue) }
    }

    init() {
        loadData()
    }

    private var persistedDataURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("user_movies_data.json")
    }

    func loadData() {
        let fileURL: URL?
        if let savedURL = persistedDataURL, FileManager.default.fileExists(atPath: savedURL.path) {
            fileURL = savedURL
        } else {
            fileURL = Bundle.main.url(forResource: "data", withExtension: "json")
        }

        guard let url = fileURL else {
            print("Failed to load data")
            return
        }

        do {
            let rawData = try Data(contentsOf: url)
            let watchlist = try JSONDecoder().decode(MovieDatabase.self, from: rawData)

            self.watchlistMovies = watchlist.watchlist.first?.movies ?? []
            self.rawWatchedMovies = watchlist.watched.first ?? [:]
            rebuildWatchedState()
        } catch {
            print("Error loading data: \(error)")
        }
    }

    private func rebuildWatchedState() {
        let years = rawWatchedMovies.keys.sorted()

        var total = 0
        var allNames: [String] = []
        var yearSections: [(year: String, movies: [String])] = []

        for year in years {
            if let movies = rawWatchedMovies[year], !movies.isEmpty {
                yearSections.append((year: year, movies: movies))
                total += movies.count
                allNames.append(contentsOf: movies)
            }
        }

        // Reverse order to match flex-col-reverse in the web interface
        self.watchedByYear = yearSections.reversed()
        self.totalMovies = total
        self.moviesNames = allNames
    }

    private func saveData() {
        guard let saveURL = persistedDataURL else { return }
        let database = MovieDatabase(
            watchlist: [WatchlistEntry(movies: watchlistMovies)],
            watched: [rawWatchedMovies]
        )
        do {
            let encoded = try JSONEncoder().encode(database)
            try encoded.write(to: saveURL, options: .atomic)
        } catch {
            print("Error saving data: \(error)")
        }
    }

    func addMovie() {
        let trimmedTitle = newMovieTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        switch selectedSection {
        case .watchlist:
            watchlistMovies.append(trimmedTitle)
            watchlistMovies.sort { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            isWatchlistExpanded = true
        case .watched:
            let trimmedYear = newMovieYear.trimmingCharacters(in: .whitespacesAndNewlines)
            let targetYear = trimmedYear.isEmpty ? String(Calendar.current.component(.year, from: Date())) : trimmedYear
            var moviesForYear = rawWatchedMovies[targetYear] ?? []
            moviesForYear.append(trimmedTitle)
            moviesForYear.sort { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            rawWatchedMovies[targetYear] = moviesForYear
            rebuildWatchedState()
            isWatchedExpanded = true
            expandedYears.insert(targetYear)
        }

        saveData()
        newMovieTitle = ""
        isAddMovieExpanded = false
    }

    func toggleYear(_ year: String) {
        if expandedYears.contains(year) {
            expandedYears.remove(year)
        } else {
            expandedYears.insert(year)
        }
    }

    func trailerURL(for movie: String, year: String? = nil, isWatchlist: Bool = false) -> URL? {
        let encodedMovie = movie.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? movie
        let query: String
        if isWatchlist {
            query = "\(encodedMovie)+movie+trailer"
        } else if let year = year {
            query = "\(encodedMovie)+\(year)+movie+trailer"
        } else {
            query = "\(encodedMovie)+trailer"
        }
        return URL(string: "https://www.google.com/search?q=\(query)")
    }
}
