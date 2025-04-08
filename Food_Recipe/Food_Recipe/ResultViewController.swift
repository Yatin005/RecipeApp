//
//  ResultViewController.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-07.
//

import UIKit

class ResultViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    private var recipeService: RecipeServiceProtocol!
    private var recipes: [Recipe] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipe Search"

        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecipeCell")

        recipeService = RecipeService()
    }

    // MARK: - UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        searchBar.resignFirstResponder()

        recipeService.searchRecipes(query: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedRecipes):
                    self?.recipes = fetchedRecipes
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.displayError(error)
                }
            }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath)
        let recipe = recipes[indexPath.row]
        cell.textLabel?.text = recipe.title

        // Load image asynchronously (basic implementation - consider using a library)
        if let imageURLString = recipe.image, let imageURL = URL(string: imageURLString) {
            URLSession.shared.dataTask(with: imageURL) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        // Check if the cell is still visible for this index path
                        if let currentIndexPath = tableView.indexPath(for: cell), currentIndexPath == indexPath {
                            let imageView = UIImageView(frame: CGRect(x: cell.contentView.bounds.width - 80, y: 5, width: 70, height: 60))
                            imageView.contentMode = .scaleAspectFit
                            imageView.image = image
                            cell.contentView.addSubview(imageView)
                            cell.setNeedsLayout() // Trigger layout update
                        }
                    }
                }
            }.resume()
        } else {
            // Set a placeholder image if no image URL
            let imageView = UIImageView(frame: CGRect(x: cell.contentView.bounds.width - 80, y: 5, width: 70, height: 60))
            imageView.image = UIImage(systemName: "photo") // Example placeholder
            imageView.contentMode = .scaleAspectFit
            cell.contentView.addSubview(imageView)
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecipe = recipes[indexPath.row]
        print("Selected recipe: \(selectedRecipe.title)")
        tableView.deselectRow(at: indexPath, animated: true)
        // Navigate to a detailed view if implemented
    }

    // MARK: - Error Display

    private func displayError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
