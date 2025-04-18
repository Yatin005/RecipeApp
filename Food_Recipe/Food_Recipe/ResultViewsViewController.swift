//
//  ResultViewsViewController.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-07.
//

import UIKit
import CoreData

class ResultViewsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var resultView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!


    
    private var recipeService: RecipeServiceProtocol!
    private var recipes: [Recipe] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipe List"

        searchBar.delegate = self
        resultView.dataSource = self
        resultView.delegate = self
        resultView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        recipeService = RecipeService()
        fetchInitialRecipes()
    }

    private func fetchInitialRecipes() {
        let initialQuery = "popular"
        fetchRecipes(query: initialQuery)
    }

    // MARK: - UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        searchBar.resignFirstResponder()
        fetchRecipes(query: query)
    }

    private func fetchRecipes(query: String) {
        Task {
            do {
                let fetchedRecipes = try await recipeService.searchRecipes(query: query)
                DispatchQueue.main.async {
                    self.recipes = fetchedRecipes
                    self.resultView.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.displayError(error)
                }
            }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let recipe = recipes[indexPath.row]
        cell.textLabel?.text = recipe.title
        cell.imageView?.image = nil

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
                        cell.imageView?.image = UIImage(systemName: "photo")
                        cell.setNeedsLayout()
                    }
                }
            }
        } else {
            cell.imageView?.image = UIImage(systemName: "photo")
            cell.setNeedsLayout()
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecipe = recipes[indexPath.row]
        print("Selected recipe: \(String(describing: selectedRecipe.title)) with ID: \(selectedRecipe.id)")
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "seg1", sender: selectedRecipe)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seg1",
           let detailVC = segue.destination as? RecipeAnalyzeViewsViewController,
           let selectedRecipe = sender as? Recipe {
            detailVC.recipeId = selectedRecipe.id
        }
    }

    // MARK: - Error Display

    private func displayError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
