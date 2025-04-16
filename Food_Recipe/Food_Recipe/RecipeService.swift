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
        return try handleResponse(data: data, response: response, decodingType: RecipeSearchResponse.self).results
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

    func getSimilarRecipes(id: Int) async throws -> [SimilarRecipe] {
        let urlString = "\(baseURL)recipes/\(id)/similar?apiKey=\(apiKey)"
                guard let url = URL(string: urlString) else {
                    throw APIError.invalidURL
                }
                print("Similar Recipes API URL: \(url)") // Added for debugging
                let (data, response) = try await URLSession.shared.data(from: url)
                return try handleResponse(data: data, response: response, decodingType: [SimilarRecipe].self)
    }
    


    private func handleResponse<T: Codable>(data: Data, response: URLResponse, decodingType: T.Type) throws -> T {
        print("--- API Response Analysis ---")

        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
        } else {
            print("Received a non-HTTP response.")
        }

        // Print the raw data
        print("--- Raw API Response Data ---")
        if let responseString = String(data: data, encoding: .utf8) {
            print(responseString)
        } else {
            print("Unable to decode response data as UTF-8.")
        }
        print("-----------------------------")

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("Request failed with HTTP status code: \(statusCode)")
            throw APIError.requestFailed(NSError(domain: "HTTPError", code: statusCode, userInfo: nil))
        }

        do {
            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode(decodingType, from: data)
            print("Successfully decoded data to \(decodingType)")
            return decodedObject
        } catch {
            print("--- Decoding Error ---")
            print(error)
            print("----------------------")
            throw APIError.decodingFailed(error)
        }
    }
}
