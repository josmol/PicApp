//
//  PhotoViewController.swift
//  PicApp
//
//  Created by Josefine Möller on 2018-03-24.
//  Copyright © 2018 Josefine Möller. All rights reserved.
//

import UIKit

class PhotoViewController: UICollectionViewController, UITextFieldDelegate {
    
    // MARK: Properties
    fileprivate let reuseIdentifier = "PhotoCell"
    var dataModel = DataModel()
    @IBOutlet weak var searchWord: UITextField!
    @IBOutlet weak var noDataLabel: UILabel!
    
    // MARK: Actions
    
    // Close search view
    @IBAction func backToStartAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        // So we can select cells
        self.collectionView?.allowsSelection = true
        self.collectionView?.allowsMultipleSelection = true
        
        // layout
        let layout :  UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.minimumLineSpacing = 5
    }
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // when we have search results we show 1 section with cells. This is when noDataLabel is hidden
        if (noDataLabel.isHidden){
            return 1
        }
        // otherwise we want the noDataLabel.text to be displayed without any empty cells blocking the text so we display 0 sections
        else{
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModel.images.count
    }

    // Handling the HeaderView
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind ==  UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
            // Setting header text to searched query
            headerView.searchLabel.text = dataModel.searched
            
            return headerView
        }
        else{
            return UICollectionReusableView()
        }
    }
    
    // Creating cells with photos
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoViewCell

        let photo = dataModel.images[indexPath.item]
        cell.photo.image = photo
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    
    // When selecting a cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.superview?.bringSubview(toFront:  cell!)
        
        // Expand the cell
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            cell?.frame = (self.collectionView?.bounds)!
        }, completion: nil)
    
    }
    
    // When de-selecting a cell
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
      
       // Collapse the cell
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            cell?.frame = CGRect.zero
            
            //Reload collapsed item
            self.collectionView?.performBatchUpdates({
                self.collectionView?.reloadItems(at: [indexPath])
            })
        }, completion: nil)
    }
    
    
    // MARK: UITextFieldDelegate
    
    // On return key for search field
    func textFieldShouldReturn(_ searchField: UITextField) -> Bool {
        
        // Create a loading symbol
        let loadingSymbol = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        searchField.addSubview(loadingSymbol)
        loadingSymbol.frame = searchField.bounds
        
        // Check there is a search word
        if(searchWord.text != ""){
            // Set view in "searching-mode"
            loadingSymbol.startAnimating()
            noDataLabel.isHidden = true
            dataModel.images.removeAll()
            self.collectionView?.reloadData()
            
            // Get data for the searched query
            dataModel.getData(searchQuery: searchWord.text!) { [weak self] (data: String) in
                
                // Get back to main thread
                DispatchQueue.main.async {
                    // Stop loading animation
                    loadingSymbol.stopAnimating()
                    loadingSymbol.removeFromSuperview()
                
                    // Now we are done getting data, we can update the view
                    self?.updateView(data: data)
                }
            }
        }
        searchField.text = nil
        searchField.resignFirstResponder()
        return true
    }
    
    // MARK: Private Functions

    // Update the view depending on callback
    private func updateView(data: String) {
        // There is data to display
        if data == "isData"{
            // Reload the view to display it
           self.collectionView?.reloadData()
        }else{
            //No data, display error messages depending on state
            noDataLabel.isHidden = false
            
            if data == "error"{
                noDataLabel.text = "Ops! An error occured."
            }else if data == "noResults"{
                noDataLabel.text = "No search results available. Try something else."
            }else if data == "urlError"{
                noDataLabel.text = "Invalid search. Use only one search word."
            }else{
                noDataLabel.text = "Unexpected error"
            }
        }
    }
    
}


