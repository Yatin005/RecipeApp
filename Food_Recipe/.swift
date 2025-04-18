//
//  FavoriteRecipe+CoreDataProperties.swift
//  Food_Recipe
//
//  Created by Deep Kaleka on 2025-04-17.
//
//

import Foundation
import CoreData


extension FavoriteRecipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteRecipe> {
        return NSFetchRequest<FavoriteRecipe>(entityName: "FavoriteRecipe")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var image: String?
    @NSManaged public var imageType: String?
    @NSManaged public var servings: Int16
    @NSManaged public var readyInMinutes: Int16
    @NSManaged public var cookingMinutes: Int16
    @NSManaged public var preparationMinutes: Int16
    @NSManaged public var sourceName: String?
    @NSManaged public var sourceUrl: String?
    @NSManaged public var spoonacularSourceUrl: String?
    @NSManaged public var healthScore: Double
    @NSManaged public var spoonacularScore: Double
    @NSManaged public var pricePerServing: Double
    @NSManaged public var cheap: Bool
    @NSManaged public var creditsText: String?
    @NSManaged public var cuisines: NSObject?
    @NSManaged public var dairyFree: Bool
    @NSManaged public var diets: NSObject?
    @NSManaged public var gaps: String?
    @NSManaged public var glutenFree: Bool
    @NSManaged public var instructions: String?
    @NSManaged public var ketogenic: Bool
    @NSManaged public var lowFodmap: Bool
    @NSManaged public var occasions: NSObject?
    @NSManaged public var sustainable: Bool
    @NSManaged public var vegan: Bool
    @NSManaged public var vegetarian: Bool
    @NSManaged public var veryHealthy: Bool
    @NSManaged public var veryPopular: Bool
    @NSManaged public var whole30: Bool
    @NSManaged public var weightWatcherSmartPoints: Int16
    @NSManaged public var dishTypes: NSObject?
    @NSManaged public var extendedIngredients: NSObject?

}

extension FavoriteRecipe : Identifiable {

}
