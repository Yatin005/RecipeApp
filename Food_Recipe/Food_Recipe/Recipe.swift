//
//  Recipe.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-07.
//
import Foundation

// MARK: - Recipe Search Response Model
struct RecipeSearchResponse: Decodable {
    let results: [Recipe]
    let offset: Int?
    let number: Int?
    let totalResults: Int?
}

struct Recipe: Decodable, Identifiable {
    let id: Int
    let title: String?
    let image: String?
    let imageType: String?
}

// MARK: - Recipe Detail Model
struct RecipeDetailModel: Decodable {
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



struct ExtendedIngredient: Decodable {
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

// MARK: - Recipe Analysis Response Model (Based on your earlier request)
struct RecipeAnalysisResponse: Decodable {
    let id: Int?
    let title: String?
    let servings: Int?
    let ingredients: [String]?
    let instructions: String?
}

// MARK: - API Error Enumeration
enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidData
    case decodingFailed(Error)
}
