//
//  ReciepeService.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-07.
//
import Foundation
class RecipeService: RecipeServiceProtocol {
   
    private let baseURL = URL(string: "https://api.spoonacular.com/")!
    private let apiKey = "31082f0a28a64dc6b64aa4e7cecb60e1"

    func searchRecipes(query: String) async throws -> [Recipe] {
        guard var components = URLComponents(url: baseURL.appendingPathComponent("recipes/complexSearch"), resolvingAgainstBaseURL: true) else {
            throw APIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "number", value: "5")
           
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
    func fetchRandomRecipe() async throws -> RecipeDetailModel {
        guard let url = URL(string: "\(baseURL)recipes/random?apiKey=\(apiKey)&number=1") else {
                   throw APIError.invalidURL
               }
               let (data, response) = try await URLSession.shared.data(from: url)
               struct RandomRecipeResponse: Codable {
                   let recipes: [RecipeDetailModel]
               }
               let decodedResponse = try handleResponse(data: data, response: response, decodingType: RandomRecipeResponse.self)
               guard let randomRecipe = decodedResponse.recipes.first else {
                   throw APIError.invalidData
               }
               return randomRecipe
    }
    

    private func handleResponse<T: Codable>(data: Data, response: URLResponse, decodingType: T.Type) throws -> T {
        print("--- API Response Analysis ---")

        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
        } else {
            print("Received a non-HTTP response.")
        }

        print("--- Raw API Response Data ---")
        if let responseString = String(data: data, encoding: .utf8) {
            print(responseString)
        } else {
            print("Unable to decode response data as UTF-8.")
        }

        do {
            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode(decodingType, from: data)
            print("Successfully decoded data to \(decodingType)")
            return decodedObject
        } catch {
            print(error)
            throw APIError.decodingFailed(error)
        }
    }
}
