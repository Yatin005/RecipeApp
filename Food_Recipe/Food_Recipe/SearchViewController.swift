//
//  SearchViewController.swift
//  Food_Recipe
//
//  Created by Yatin Parulkar on 2025-04-04.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    private var searchResults: [ProductDetail] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
        title = "Search Products"
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text, !query.isEmpty {
            performSearch(query: query)
            searchBar.resignFirstResponder()
        }
    }

    private func performSearch(query: String) {
        Api_Network.searchProducts(query: query) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error searching products: \(error)")
                return
            }
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(APIResponse.self, from: data)
                    if let results = apiResponse.data?.results {
                        DispatchQueue.main.async {
                            self.searchResults = results
                            self.tableView.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.searchResults = []
                            self.tableView.reloadData()
                            self.showAlert(message: "No results found for '\(query)'")
                        }
                    }
                } catch {
                    print("Error decoding search results: \(error)")
                }
            }
        }
    }

    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Search Result", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    // MARK: - UITableView Delegate & Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let product = searchResults[indexPath.row]
        cell.textLabel?.text = product.title ?? "No Title"
        cell.detailTextLabel?.text = product.price?.raw ?? "No Price"
        // Consider loading the image asynchronously here (using product.image)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = searchResults[indexPath.row]
        let detailVC = ProductDetailViewController()
        detailVC.product = selectedProduct
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
