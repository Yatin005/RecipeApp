    //
    //  SimilarRecipesViewController.swift
    //  Food_Recipe
    //
    //  Created by Yatin Parulkar on 2025-04-07.
    //

import UIKit

class SimilarRecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var similarRecipesTableView: UITableView!
    
    var recipeId: Int? {
        didSet {
            print("SimilarRecipeViewController - recipeId didSet to: \(recipeId ?? -1)")
            loadSimilarRecipes()
        }
    }
    private let recipeService = RecipeService()
    private var similarRecipes: [SimilarRecipe] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print("SimilarRecipeViewController - viewDidLoad called here. Current recipeId: \(recipeId ?? -1)")
        title = "Similar Recipes"
        similarRecipesTableView.dataSource = self
        similarRecipesTableView.delegate = self
        similarRecipesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

    
    }

    private func loadSimilarRecipes() {
        print("SimilarRecipeViewController - loadSimilarRecipes - About to check recipeId: \(self.recipeId ?? -2) (-2 indicates nil)")
        guard let recipeId = self.recipeId else {
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.activityIndicator?.isHidden = true
                self.displayError(APIError.invalidURL)
            }
            print("SimilarRecipeViewController - loadSimilarRecipes - recipeId is nil, cannot load similar recipes.")
            return
        }
        print("SimilarRecipeViewController - loadSimilarRecipes - recipeId is NOT nil: \(recipeId)")
        Task {
            print("SimilarRecipeViewController - loadSimilarRecipes - Inside Task, recipeId: \(recipeId)")
            do {
                let fetchedRecipes = try await recipeService.getSimilarRecipes(id: recipeId)
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.activityIndicator?.isHidden = true
                    self.similarRecipes = fetchedRecipes
                    self.similarRecipesTableView.reloadData()
                    print("SimilarRecipeViewController - loadSimilarRecipes - Successfully loaded \(self.similarRecipes.count) similar recipes.")
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.activityIndicator?.isHidden = true
                    self.displayError(error)
                    print("SimilarRecipeViewController - loadSimilarRecipes - Error loading similar recipes: \(error)")
                }
            }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return similarRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
        let similarRecipe = similarRecipes[indexPath.row]
        cell.textLabel?.text = similarRecipe.title
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSimilarRecipe = similarRecipes[indexPath.row]
        print("SimilarRecipeViewController - tableView didSelectRowAt - Selected recipe ID: \(selectedSimilarRecipe.id), Title: \(selectedSimilarRecipe.title ?? "N/A")")
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "next", sender: selectedSimilarRecipe)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("SimilarRecipeViewController - prepare(for segue:) called with identifier: \(segue.identifier ?? "nil") and sender: \(String(describing: sender))")
        if segue.identifier == "next",
           let analyzeVC = segue.destination as? RecipeAnalyzeViewsViewController,
           let selectedRecipe = sender as? SimilarRecipe {
            analyzeVC.recipeId = selectedRecipe.id
            print("SimilarRecipeViewController - prepare(for segue:) - Passing recipeId: \(selectedRecipe.id) to RecipeAnalyzeViewsViewController.")
        }
    }

    // MARK: - Error Display

    private func displayError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
