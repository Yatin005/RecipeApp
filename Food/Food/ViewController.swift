//
//  ViewController.swift
//  Food
//
//  Created by Yatin Parulkar on 2025-04-07.
//

import UIKit

class ViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var resultView: UITableView!
    
    private var recipeService: RecipeServiceProtocol!
    private var recipes: [Recipe] = []

    // Provide an initial list of recipe IDs
    let initialRecipeIds = [716429, 715538, 640352, 660228, 631753]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipe List"

        resultView.dataSource = self
        resultView.delegate = self
        resultView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        recipeService = RecipeService()
        fetchInitialRecipeList()
    }

    private func fetchInitialRecipeList() {
        recipeService.fetchRecipeListByIds(ids: initialRecipeIds) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedRecipes):
                    self?.recipes = fetchedRecipes
                    self?.resultView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let recipe = recipes[indexPath.row]
        cell.textLabel?.text = recipe.title

        // Load image asynchronously (basic implementation)
        if let imageURLString = recipe.image, let imageURL = URL(string: imageURLString) {
            URLSession.shared.dataTask(with: imageURL) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let currentIndexPath = tableView.indexPath(for: cell), currentIndexPath == indexPath {
                            let imageView = UIImageView(frame: CGRect(x: cell.contentView.bounds.width - 80, y: 5, width: 70, height: 60))
                            imageView.contentMode = .scaleAspectFit
                            imageView.image = image
                            cell.contentView.addSubview(imageView)
                            cell.setNeedsLayout()
                        }
                    }
                }
            }.resume()
        } else {
            let imageView = UIImageView(frame: CGRect(x: cell.contentView.bounds.width - 80, y: 5, width: 70, height: 60))
            imageView.image = UIImage(systemName: "photo")
            imageView.contentMode = .scaleAspectFit
            cell.contentView.addSubview(imageView)
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecipe = recipes[indexPath.row]
        print("Selected recipe ID: \(selectedRecipe.id)")
        // You can now use selectedRecipe.id to fetch more detailed info
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Error Display

    private func displayError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
