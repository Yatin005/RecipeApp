//
//  RandomRecipeViewController.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-17.
//

import UIKit

class SimilarRecipeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var readyInMinutesLabel: UILabel!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var ingri: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    private let recipeService = RecipeService()
    private var currentRandomRecipeId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Random Recipe"
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        loadRandomRecipe()
    }

    private func loadRandomRecipe() {
        Task {
            do {
                let randomRecipeDetail = try await recipeService.fetchRandomRecipe()
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.updateUI(with: randomRecipeDetail)
                    self.currentRandomRecipeId = randomRecipeDetail.id
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.displayError(error)
                }
            }
        }
    }

    private func updateUI(with detail: RecipeDetailModel) {
        titleLabel.text = detail.title
        servingsLabel.text = "Servings: \(detail.servings?.description ?? "N/A")"
        readyInMinutesLabel.text = "Ready in: \(detail.readyInMinutes?.description ?? "N/A") minutes"
        instructionsTextView.text = detail.instructions?.isEmpty == false ? detail.instructions : "No instructions available."
        instructionsTextView.textColor = detail.instructions?.isEmpty == false ? .black : .gray

        var ingredientsText = "Ingredients:\n"
        if let ingredients = detail.extendedIngredients {
            for ingredient in ingredients {
                ingredientsText += "- \(ingredient.original ?? "N/A")\n"
            }
        } else {
            ingredientsText += "No ingredients available."
        }
        ingri.text = ingredientsText

        if let imageURLString = detail.image, let imageURL = URL(string: imageURLString) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: imageURL)
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.imageView.image = image
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(systemName: "photo")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(systemName: "photo")
                    }
                }
            }
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }

    private func displayError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
