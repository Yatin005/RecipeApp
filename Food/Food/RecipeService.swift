//
//  RecipeService.swift
//  Food
//
//  Created by Yatin Parulkar on 2025-04-07.
//

import Foundation


class RecipeService: RecipeServiceProtocol {
    private let baseURL = URL(string: "https://api.spoonacular.com/recipes/{id}/information")!
    private let apiKey = "c0d3df26f25b4695a8ad33d4c7838012"

    func getRecipeInformation(id: Int, completion: @escaping (Result<Recipe, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/recipes/\(id)/information?apiKey=\(apiKey)") else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            // ... (error handling and decoding as before) ...
            do {
                let decoder = JSONDecoder()
                let recipeInfo = try decoder.decode(Recipe.self, from: data!)
                completion(.success(recipeInfo))
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }.resume()
    }

    func fetchRecipeListByIds(ids: [Int], completion: @escaping (Result<[Recipe], APIError>) -> Void) {
        guard !ids.isEmpty else {
            completion(.success([]))
            return
        }

        let idsString = ids.map { String($0) }.joined(separator: ",")
        guard let url = URL(string: "\(baseURL)/recipes/informationBulk?ids=\(idsString)&apiKey=\(apiKey)") else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            // ... (error handling) ...
            do {
                let decoder = JSONDecoder()
                let recipes = try decoder.decode([Recipe].self, from: data!)
                completion(.success(recipes))
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }.resume()
    }
}
