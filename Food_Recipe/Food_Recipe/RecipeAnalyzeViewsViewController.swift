//
//  RecipeDetailViewController.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-07.
//

import UIKit

class RecipeAnalyzeViewsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var readyInMinutesLabel: UILabel!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var ingri: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var recipeId: Int?
    private let recipeService = RecipeService()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipe Details"
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        loadRecipeDetails()
    }

    private func loadRecipeDetails() {
        guard let recipeId = self.recipeId else {
            DispatchQueue.main.async {
                self.displayError(APIError.invalidURL) 
            }
            return
        }

        Task {
            do {
                let recipeDetail = try await recipeService.getRecipeInformation(id: recipeId)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.updateUI(with: recipeDetail)
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
    @IBAction func showSimilarRecipesTapped(_ sender: UIButton) {
            guard let recipeId = self.recipeId else {
                // This should not happen if the button is only enabled when recipeId is set
                return
            }

            if let similarVC = storyboard?.instantiateViewController(withIdentifier: "SimilarRecipesViewController") as? SimilarRecipesViewController {
                similarVC.recipeId = recipeId
                navigationController?.pushViewController(similarVC, animated: true)
            }
        }

    private func displayError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
