//
//  RecipeServiceProtocol.swift
//  Food
//
//  Created by Yatin Parulkar on 2025-04-07.
//

import Foundation

protocol RecipeServiceProtocol: AnyObject {
    func getRecipeInformation(id: Int, completion: @escaping (Result<Recipe, APIError>) -> Void)
    func fetchRecipeListByIds(ids: [Int], completion: @escaping (Result<[Recipe], APIError>) -> Void)
}
