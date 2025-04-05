//
//  Api_Network.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-04.
//

import Foundation

protocol NewsDelegate {
    func networkingDidFinishGettingNews(newsResponse: NewsResponse)
    func networkingDidFail(error: Error?)
}

class Api_Network {
    static var shared = NetworkingManager()

    var newsDelegate: NewsDelegate?

    private let newsApiKey = "YOUR_NEWS_API_KEY" // Replace with your actual News API key
    private let newsBaseURL = URL(string: "https://newsapi.org/v2")!

    // MARK: - News API Integration

    func getNews(query: String, from date: String, to endDate: String? = nil, sortBy: String = "popularity") {
        let toDate = endDate ?? date // Use 'from' date as 'to' date if not provided
        guard let url = buildNewsURL(query: query, from: date, to: toDate, sortBy: sortBy) else {
            print("Error building News API URL")
            
            return
        }

        var task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching news: \(error)")
                DispatchQueue.main.async {
                    self.newsDelegate?.networkingDidFail(error: error)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid HTTP response for news")
                DispatchQueue.main.async {
                    
                }
                return
            }

            guard let data = data else {
                print("No data received from News API")
                DispatchQueue.main.async {
                    
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let newsResponse = try decoder.decode(NewsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.newsDelegate?.networkingDidFinishGettingNews(newsResponse: newsResponse)
                }
            } catch {
                print("Error decoding News API JSON: \(error)")
                DispatchQueue.main.async {
                    self.newsDelegate?.networkingDidFail(error: error)
                }
            }
        }
        task.resume()
    }

    private func buildNewsURL(query: String, from: String, to: String, sortBy: String) -> URL? {
        guard var components = URLComponents(url: newsBaseURL.appendingPathComponent("everything"), resolvingAgainstBaseURL: true) else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "from", value: from),
            URLQueryItem(name: "to", value: to),
            URLQueryItem(name: "sortBy", value: sortBy),
            URLQueryItem(name: "apiKey", value: newsApiKey)
        ]

        return components.url
    }
}
