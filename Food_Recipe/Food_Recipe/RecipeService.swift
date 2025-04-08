//
//  ReciepeService.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-07.
//
//
// RecipeService.swift
import Foundation
class RecipeService: RecipeServiceProtocol {
    private let baseURL = URL(string: "https://api.spoonacular.com/")!
    private let apiKey = "c0d3df26f25b4695a8ad33d4c7838012"

    func searchRecipes(query: String) async throws -> [Recipe] {
        guard var components = URLComponents(url: baseURL.appendingPathComponent("recipes/complexSearch"), resolvingAgainstBaseURL: true) else {
            throw APIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "number", value: "10")
           
        ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        return try handleResponse(data: data, response: response, decodingType: RecipeSearchResponse.self).results ?? []
    }

    func getRecipeInformation(id: Int) async throws -> RecipeDetailModel {
        guard let url = URL(string: "\(baseURL)recipes/\(id)/information?apiKey=\(apiKey)") else {
            throw APIError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        return try handleResponse(data: data, response: response, decodingType: RecipeDetailModel.self)
    }

    func fetchRecipeListByIds(ids: [Int]) async throws -> [RecipeDetailModel] {
        guard !ids.isEmpty else { return [] }
        let idsString = ids.map { String($0) }.joined(separator: ",")
        guard let url = URL(string: "\(baseURL)recipes/informationBulk?ids=\(idsString)&apiKey=\(apiKey)") else {
            throw APIError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        return try handleResponse(data: data, response: response, decodingType: [RecipeDetailModel].self)
    }

    func analyzeRecipe(instructions: String) async throws -> RecipeAnalysisResponse {
        guard let url = URL(string: "\(baseURL)recipes/analyze?apiKey=\(apiKey)") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = ["instructions": instructions]
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response, decodingType: RecipeAnalysisResponse.self)
    }

    private func handleResponse<T: Decodable>(data: Data, response: URLResponse, decodingType: T.Type) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed(NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil))
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(decodingType, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
