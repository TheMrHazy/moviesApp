import SwiftUI

// Stone palette matching Tailwind stone-200 through stone-900
private enum StoneTheme {
    static let stone100 = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let stone200 = Color(red: 0.91, green: 0.90, blue: 0.89)
    static let stone300 = Color(red: 0.84, green: 0.83, blue: 0.82)
    static let stone400 = Color(red: 0.66, green: 0.64, blue: 0.62)
    static let stone500 = Color(red: 0.47, green: 0.44, blue: 0.42)
    static let stone600 = Color(red: 0.34, green: 0.33, blue: 0.31)
    static let stone900 = Color(red: 0.11, green: 0.10, blue: 0.09)
}

struct ContentView: View {
    @StateObject private var viewModel = MovieViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // Header & Search Section
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("\(viewModel.totalMovies)")
                            .font(.system(size: 12, weight: .medium))
                        Text("Movies Watched.")
                            .font(.system(size: 11, weight: .light))
                    }
                    .foregroundColor(StoneTheme.stone900)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                    .background(StoneTheme.stone400)
                    .cornerRadius(3)

                    TextField("Search for a movie", text: $viewModel.searchText)
                        .font(.system(size: 12))
                        .foregroundColor(StoneTheme.stone900)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(StoneTheme.stone300)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(StoneTheme.stone500, lineWidth: 2)
                        )

                    if !viewModel.searchText.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.searchResults.enumerated()), id: \.offset) { index, movie in
                                MovieRowView(
                                    movie: movie,
                                    url: viewModel.trailerURL(for: movie),
                                    isEven: index % 2 == 1,
                                    isLast: index == viewModel.searchResults.count - 1
                                )
                            }
                        }
                        .background(StoneTheme.stone200)
                    }

                    // Add a Movie Toggle & Form
                    VStack(spacing: 4) {
                        Button {
                            viewModel.isAddMovieExpanded.toggle()
                        } label: {
                            HStack {
                                Text("Add a Movie")
                                    .font(.system(size: 12, weight: .light))
                                Spacer()
                                Text(viewModel.isAddMovieExpanded ? "-" : "+")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(StoneTheme.stone500)
                            .cornerRadius(3)
                        }
                        .buttonStyle(.plain)

                        if viewModel.isAddMovieExpanded {
                            VStack(alignment: .leading, spacing: 5) {
                                TextField("Movie title", text: $viewModel.newMovieTitle)
                                    .font(.system(size: 11))
                                    .foregroundColor(StoneTheme.stone900)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(StoneTheme.stone300)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2)
                                            .stroke(StoneTheme.stone500, lineWidth: 1.5)
                                    )

                                HStack(spacing: 4) {
                                    ForEach(MovieTargetSection.allCases) { section in
                                        Button {
                                            viewModel.selectedSection = section
                                        } label: {
                                            Text(section.rawValue)
                                                .font(.system(size: 10, weight: viewModel.selectedSection == section ? .medium : .light))
                                                .foregroundColor(viewModel.selectedSection == section ? .white : StoneTheme.stone900)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 4)
                                                .background(viewModel.selectedSection == section ? StoneTheme.stone600 : StoneTheme.stone300)
                                                .cornerRadius(2)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }

                                if viewModel.selectedSection == .watched {
                                    TextField("Year (e.g. 2026)", text: $viewModel.newMovieYear)
                                        .font(.system(size: 11))
                                        .foregroundColor(StoneTheme.stone900)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 4)
                                        .background(StoneTheme.stone300)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 2)
                                                .stroke(StoneTheme.stone500, lineWidth: 1.5)
                                        )
                                }

                                Button {
                                    viewModel.addMovie()
                                } label: {
                                    Text("ADD MOVIE")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 5)
                                        .background(StoneTheme.stone600)
                                        .cornerRadius(2)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(6)
                            .background(StoneTheme.stone300.opacity(0.6))
                            .cornerRadius(3)
                        }
                    }
                }

                // Watchlist & Watched Accordion Container
                VStack(spacing: 4) {
                    // Watchlist Section
                    VStack(spacing: 2) {
                        Button {
                            viewModel.isWatchlistExpanded.toggle()
                        } label: {
                            HStack {
                                Text("Watchlist")
                                    .font(.system(size: 14, weight: .light))
                                Spacer()
                                Text(viewModel.isWatchlistExpanded ? "-" : "+")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(StoneTheme.stone600)
                            .cornerRadius(3)
                        }
                        .buttonStyle(.plain)

                        if viewModel.isWatchlistExpanded {
                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.watchlistMovies.enumerated()), id: \.offset) { index, movie in
                                    MovieRowView(
                                        movie: movie,
                                        url: viewModel.trailerURL(for: movie, isWatchlist: true),
                                        isEven: index % 2 == 1,
                                        isLast: index == viewModel.watchlistMovies.count - 1
                                    )
                                }
                            }
                        }
                    }

                    // Watched Section
                    VStack(spacing: 2) {
                        Button {
                            viewModel.isWatchedExpanded.toggle()
                        } label: {
                            HStack {
                                Text("Watched")
                                    .font(.system(size: 14, weight: .light))
                                Spacer()
                                Text(viewModel.isWatchedExpanded ? "-" : "+")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(StoneTheme.stone600)
                            .cornerRadius(3)
                        }
                        .buttonStyle(.plain)

                        if viewModel.isWatchedExpanded {
                            VStack(spacing: 3) {
                                ForEach(viewModel.watchedByYear, id: \.year) { section in
                                    let isYearOpen = viewModel.expandedYears.contains(section.year)
                                    VStack(spacing: 0) {
                                        Button {
                                            viewModel.toggleYear(section.year)
                                        } label: {
                                            HStack {
                                                Text(section.year)
                                                    .font(.system(size: 12, weight: .light))
                                                Spacer()
                                                Text(isYearOpen ? "-" : "+")
                                                    .font(.system(size: 13, weight: .light))
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 5)
                                            .background(StoneTheme.stone500)
                                            .cornerRadius(3)
                                        }
                                        .buttonStyle(.plain)

                                        if isYearOpen {
                                            VStack(spacing: 0) {
                                                ForEach(Array(section.movies.enumerated()), id: \.offset) { index, movie in
                                                    MovieRowView(
                                                        movie: movie,
                                                        url: viewModel.trailerURL(for: movie, year: section.year),
                                                        isEven: index % 2 == 1,
                                                        isLast: index == section.movies.count - 1
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(6)
        }
        .background(StoneTheme.stone200.ignoresSafeArea())
    }
}

struct MovieRowView: View {
    let movie: String
    let url: URL?
    let isEven: Bool
    let isLast: Bool

    var body: some View {
        if let url = url {
            Link(destination: url) {
                rowContent
            }
            .buttonStyle(.plain)
        } else {
            rowContent
        }
    }

    private var rowContent: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 6) {
                Text(movie.capitalized)
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(StoneTheme.stone900)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("TRAILER")
                    .font(.system(size: 9, weight: .light))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(StoneTheme.stone400)
            }
            .padding(6)
            .background(isEven ? StoneTheme.stone300 : StoneTheme.stone200)

            if !isLast {
                Divider()
                    .background(Color.black.opacity(0.4))
            }
        }
    }
}
