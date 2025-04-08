//
//  SimilarRecipesViewController.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-07.
//

import UIKit

class SimilarRecipesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var similarRecipesTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var recipeId: Int?
    private let recipeService = RecipeService()
    private var similarRecipes: [SimilarRecipe] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Similar Recipes"
        similarRecipesTableView.dataSource = self
        similarRecipesTableView.delegate = self
        similarRecipesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell") // Changed identifier to "cell"

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        loadSimilarRecipes()
    }

    private func loadSimilarRecipes() {
        guard let recipeId = self.recipeId else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.displayError(APIError.invalidURL) // Or a more specific error
            }
            return
        }

        Task {
            do {
                let fetchedSimilarRecipes = try await recipeService.getSimilarRecipes(id: recipeId)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.similarRecipes = fetchedSimilarRecipes
                    self.similarRecipesTableView.reloadData()
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

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return similarRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) // Using "cell"
        let similarRecipe = similarRecipes[indexPath.row]
        cell.textLabel?.text = similarRecipe.title
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSimilarRecipe = similarRecipes[indexPath.row]
        print("Selected similar recipe: \(String(describing: selectedSimilarRecipe.title)) with ID: \(selectedSimilarRecipe.id)")
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "next", sender: selectedSimilarRecipe)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next",
           let analyzeVC = segue.destination as? RecipeAnalyzeViewsViewController,
           let selectedRecipe = sender as? SimilarRecipe {
            analyzeVC.recipeId = selectedRecipe.id
            // You might want to pass other data if needed
        }
    }

    // MARK: - Error Display

    private func displayError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
