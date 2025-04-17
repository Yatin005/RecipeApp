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
    private let apiKey = "8741ee128ea74009874c9a33f0506ae8"

    func searchRecipes(query: String) async throws -> [Recipe] {
        guard var components = URLComponents(url: baseURL.appendingPathComponent("recipes/complexSearch"), resolvingAgainstBaseURL: true) else {
            throw APIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "number", value: "20")
           
        ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        return try handleResponse(data: data, response: response, decodingType: RecipeSearchResponse.self).results
    }
    func fetchPopularRecipes() async throws -> [Recipe] {
        guard let url = URL(string: "\(baseURL)recipes/complexSearch?apiKey=\(apiKey)&sort=popularity&number=20") else {
                    throw APIError.invalidURL
                }

                let (data, response) = try await URLSession.shared.data(from: url)
                let popularRecipeResponse = try handleResponse(data: data, response: response, decodingType: RecipeSearchResponse.self)
                return popularRecipeResponse.results
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
