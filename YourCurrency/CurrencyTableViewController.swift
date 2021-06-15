//
//  CurrencyTableViewController.swift
//  YourCurrency
//
//  Created by Екатерина Полупанова on 15.06.2021.
//

import UIKit

class CurrencyTableViewController: UITableViewController {
    public var url: String = ""
    private var rssItems: [RSSItem]?
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    func newURL(url:String){
        self.url = url
    }
    private func fetchData()
    {
        let feedParser = FeedParser()
        feedParser.parseFeed(url: url)
        {
            (rssItems) in
            self.rssItems = rssItems
            OperationQueue.main.addOperation {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .left)
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rssItems = rssItems else {
            return 0
        }
        return rssItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CurrencyTableViewCell
        if let item = rssItems?[indexPath.item] {
            cell.item = item
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
