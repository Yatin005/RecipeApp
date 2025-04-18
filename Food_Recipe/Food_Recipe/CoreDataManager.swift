//
//  CoreDataManager.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-17.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "RecipeDataModel") // Replace "RecipeDataModel" with the name of your data model file if different
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    func fetchFavoriteRecipes() throws -> [FavoriteRecipe] {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        return try viewContext.fetch(fetchRequest)
    }

    func saveFavoriteRecipe(recipeDetail: RecipeDetailModel) throws {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", recipeDetail.id!)

        if let existingRecipe = try viewContext.fetch(fetchRequest).first {
            // Recipe already exists, maybe handle updates here if needed
            print("Recipe with ID \(recipeDetail.id!) already exists in favorites.")
            return
        }

        let favoriteRecipe = FavoriteRecipe(context: viewContext)
        favoriteRecipe.id = Int32(Int64(recipeDetail.id!))
        favoriteRecipe.title = recipeDetail.title
        favoriteRecipe.image = recipeDetail.image
        favoriteRecipe.imageType = recipeDetail.imageType
        favoriteRecipe.servings = Int16(recipeDetail.servings ?? 0)
        favoriteRecipe.readyInMinutes = Int16(recipeDetail.readyInMinutes ?? 0)
        favoriteRecipe.cookingMinutes = Int16(recipeDetail.cookingMinutes ?? 0)
        favoriteRecipe.preparationMinutes = Int16(recipeDetail.preparationMinutes ?? 0)
        favoriteRecipe.sourceName = recipeDetail.sourceName
        favoriteRecipe.sourceUrl = recipeDetail.sourceUrl
        favoriteRecipe.spoonacularSourceUrl = recipeDetail.spoonacularSourceUrl
        favoriteRecipe.healthScore = recipeDetail.healthScore ?? 0.0
        favoriteRecipe.spoonacularScore = recipeDetail.spoonacularScore ?? 0.0
        favoriteRecipe.pricePerServing = recipeDetail.pricePerServing ?? 0.0
        favoriteRecipe.cheap = recipeDetail.cheap ?? false
        favoriteRecipe.creditsText = recipeDetail.creditsText
        favoriteRecipe.cuisines = recipeDetail.cuisines as NSArray?
        favoriteRecipe.dairyFree = recipeDetail.dairyFree ?? false
        favoriteRecipe.diets = recipeDetail.diets as NSArray?
        favoriteRecipe.gaps = recipeDetail.gaps
        favoriteRecipe.glutenFree = recipeDetail.glutenFree ?? false
        favoriteRecipe.instructions = recipeDetail.instructions
        favoriteRecipe.ketogenic = recipeDetail.ketogenic ?? false
        favoriteRecipe.lowFodmap = recipeDetail.lowFodmap ?? false
        favoriteRecipe.occasions = recipeDetail.occasions as NSArray?
        favoriteRecipe.sustainable = recipeDetail.sustainable ?? false
        favoriteRecipe.vegan = recipeDetail.vegan ?? false
        favoriteRecipe.vegetarian = recipeDetail.vegetarian ?? false
        favoriteRecipe.veryHealthy = recipeDetail.veryHealthy ?? false
        favoriteRecipe.veryPopular = recipeDetail.veryPopular ?? false
        favoriteRecipe.whole30 = recipeDetail.whole30 ?? false
        favoriteRecipe.weightWatcherSmartPoints = Int16(recipeDetail.weightWatcherSmartPoints ?? 0)
        favoriteRecipe.dishTypes = recipeDetail.dishTypes as NSArray?
        favoriteRecipe.extendedIngredients = recipeDetail.extendedIngredients as NSArray?

        saveContext()
    }

    func deleteFavoriteRecipe(recipeId: Int) throws {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", recipeId)

        let recipesToDelete = try viewContext.fetch(fetchRequest)
        for recipe in recipesToDelete {
            viewContext.delete(recipe)
        }
        saveContext()
    }

    func isRecipeFavorite(recipeId: Int) throws -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", recipeId)
        let count = try viewContext.count(for: fetchRequest)
        return count > 0
    }
}
