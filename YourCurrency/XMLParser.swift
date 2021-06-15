//
//  XMLParser.swift
//  YourCurrency
//
//  Created by Екатерина Полупанова on 15.06.2021.
//

import Foundation


struct RSSItem
{
    var value: String
    var date: String
    var num: String
}


class FeedParser: NSObject, XMLParserDelegate
{
    var c = false
    private var CHECK: Bool = true
    private var rssItem: [RSSItem] = []
    private var currentElement = ""
    private var currentDate = ""
    private var currentNum = ""
    private var currentValue: String = ""
    private var parserCompletionHandler: (([RSSItem]) -> Void)?
    
    func parseFeed(url: String, completionHandler:(([RSSItem]) -> Void)?)
    {
        self.parserCompletionHandler = completionHandler
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            let parser = XMLParser(data:data)
            parser.delegate = self
            parser.parse()
        }
        
        task.resume()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "Record" {
            currentValue = ""
            currentNum = ""
            if let date = attributeDict["Date"] {
                currentDate = date            }
        }
        if elementName == "Valute" {
            currentValue = ""
            currentNum = ""
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "Value": currentValue += string
        case "NumCode": currentNum += string
        default: break
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Record" {
            let rssItem = RSSItem(value: currentValue, date: currentDate, num: currentNum)
            self.rssItem.append(rssItem)
            CHECK = false
        }
        if elementName == "Valute" {
            let rssItem = RSSItem(value: currentValue, date: currentDate, num: currentNum)
            self.rssItem.append(rssItem)
            CHECK = true
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(rssItem)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
    
}
