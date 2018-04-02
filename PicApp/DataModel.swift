//
//  DataModel.swift
//  PicApp
//
//  Created by Josefine Möller on 2018-03-24.
//  Copyright © 2018 Josefine Möller. All rights reserved.
//

import UIKit


class DataModel{
    
    // MARK: Properties
    var images = [UIImage()]
    var searched = String()
    // api-key
    let clientID = "63f42747bc92ae568b5a736ff58a7b59be9b210e7234a15b27a153b1198e6719"
    
    // MARK: Functions
    func getData(searchQuery: String, completion: @escaping ((_ data: String) -> Void)) {
        
        // Save searchQuery so it can be displayed in view header
        self.searched = searchQuery
        
        // Create URL
        guard let url = makeURL(query: searchQuery) else {
            // Complete with url/query error
            completion("urlError")
            return
        }
        
        // Make GET-request
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("error", error)
                return
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    let results = json!.value(forKey: "results") as! NSArray;
                    
                    if results.count == 0 {
                         //Complete with empty data
                        completion("noResults")
                    }
                    else{
                        for result in results{
                            let result = result as AnyObject
                            let urls = result["urls"] as AnyObject
                            
                            //Create image and append it to array with images
                            let imageString = urls["regular"] as! String
                            let imageURL = URL(string: imageString)
                            let imageData = try Data(contentsOf: imageURL!)
                            let image = UIImage(data: imageData)
                            self.images.append(image!)
                        }
                        // Complete with Data
                        completion("isData")
                    }
                }
                catch{
                    print("error", error)
                    // Complete with error
                    completion("error")
                }
            }
        }.resume()
    }
  
    // MARK: Private functions
    
    // Creating URL and returns it on success
    private func makeURL(query: String) -> URL? {
        let URLString = "https://api.unsplash.com/search/photos/?client_id=" + clientID + "&query=" + query
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        return url
    }
    
}



