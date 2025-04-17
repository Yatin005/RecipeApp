//
//  SimilarRecipeViewController.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-17.
//

import UIKit

class SimilarRecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var similarRecipesTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let popularRecipeService: RecipeServiceProtocol = RecipeService()
    private var popularRecipes: [Recipe] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Popular Recipes"

        similarRecipesTableView.dataSource = self
        similarRecipesTableView.delegate = self
        similarRecipesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "next")

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        loadPopularRecipes()
    }

    private func loadPopularRecipes() {
        Task {
            do {
                popularRecipes = try await popularRecipeService.fetchPopularRecipes()
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
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
        return popularRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
        let recipe = popularRecipes[indexPath.row]
        cell.textLabel?.text = recipe.title
        cell.imageView?.image = nil // Clear previous image

        if let imageURLString = recipe.image, let imageURL = URL(string: imageURLString) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: imageURL)
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            if let currentCell = tableView.cellForRow(at: indexPath), currentCell === cell {
                                cell.imageView?.image = image
                                cell.setNeedsLayout()
                            }
                        }
                    }
                } catch {
                    print("Error loading image: \(error)")
                    DispatchQueue.main.async {
                        cell.imageView?.image = UIImage(systemName: "flame.fill") // Placeholder
                        cell.setNeedsLayout()
                    }
                }
            }
        } else {
            cell.imageView?.image = UIImage(systemName: "flame.fill") // Placeholder if no image URL
            cell.setNeedsLayout()
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecipe = popularRecipes[indexPath.row]
        print("Selected popular recipe: \(selectedRecipe.title ?? "No Title") with ID: \(selectedRecipe.id)")
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "next", sender: selectedRecipe)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next",
           let detailVC = segue.destination as? RecipeAnalyzeViewsViewController,
           let recipeIdToSend = sender as? Int {
            detailVC.recipeId = recipeIdToSend
        }
    }

    private func displayError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
