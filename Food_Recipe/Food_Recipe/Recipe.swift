//
//  Recipe.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-07.
//

import Foundation

// MARK: - Recipe Search Response Model
struct RecipeSearchResponse: Codable {
    let results: [Recipe]
    let offset: Int?
    let number: Int?
    let totalResults: Int?
}

struct Recipe: Codable, Identifiable {
    let id: Int
    let title: String?
    let image: String?
    let imageType: String?
}

// MARK: - Recipe Detail Model
struct RecipeDetailModel: Codable {
    let id: Int?
    let title: String?
    let image: String?
    let imageType: String?
    let servings: Int?
    let readyInMinutes: Int?
    let cookingMinutes: Int?
    let preparationMinutes: Int?
    let sourceName: String?
    let sourceUrl: String?
    let spoonacularSourceUrl: String?
    let healthScore: Double?
    let spoonacularScore: Double?
    let pricePerServing: Double?
    let cheap: Bool?
    let creditsText: String?
    let cuisines: [String]?
    let dairyFree: Bool?
    let diets: [String]?
    let gaps: String?
    let glutenFree: Bool?
    let instructions: String?
    let ketogenic: Bool?
    let lowFodmap: Bool?
    let occasions: [String]?
    let sustainable: Bool?
    let vegan: Bool?
    let vegetarian: Bool?
    let veryHealthy: Bool?
    let veryPopular: Bool?
    let whole30: Bool?
    let weightWatcherSmartPoints: Int?
    let dishTypes: [String]?
    let extendedIngredients: [ExtendedIngredient]?
}


struct ExtendedIngredient: Codable {
    let aisle: String?
    let amount: Double?
    let consistency: String?
    let id: Int?
    let image: String?
    let meta: [String]?
    let name: String?
    let original: String?
    let originalName: String?
    let unit: String?
}

struct SimilarRecipe: Codable {
    let id: Int
    let title: String?
    let imageType: String?
    let readyInMinutes: Int?
    let servings: Int?
    let sourceUrl: String?
}

struct RecipeAnalysisResponse: Codable {
    let id: Int?
    let title: String?
    let servings: Int?
    let ingredients: [String]?
    let instructions: String?
}



// MARK: - API Error Enumeration
enum APIError: Error {
    case invalidURL
    case requestFailed(Error, statusCode: Int?) // Include status code
    case invalidData
    case decodingFailed(Error)
    case apiLimitReached(message: String) // For API limit errors
}
