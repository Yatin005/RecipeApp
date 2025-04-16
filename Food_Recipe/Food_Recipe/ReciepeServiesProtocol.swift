//
//  ReciepeServie.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-07.
//

import Foundation


protocol RecipeServiceProtocol: AnyObject {
    func searchRecipes(query: String) async throws -> [Recipe]
        func getRecipeInformation(id: Int) async throws -> RecipeDetailModel
        func fetchRecipeListByIds(ids: [Int]) async throws -> [RecipeDetailModel]
        func getSimilarRecipes(id: Int) async throws -> [SimilarRecipe] 
    }
