//
//  ViewController.swift
//  DragDropCollectionView
//
//  Created by Ashwani Kumar on 06/06/20.
//  Copyright © 2020 iOSBrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var cvA: UICollectionView!
    @IBOutlet weak var cvB: UICollectionView!
    
    
    // MARK: Properties
    
    private var datasourceA: [String] = [
    "A1",
    "A2",
    "A3",
    "A4",
    "A5",
    ]
    private var datasourceB: [String] = [
    "B1",
    "B2",
    "B3",
    "B4",
    "B5"
    ]
    
    private var trackDict = [String: IndexPath]()
    
    
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cvB.dragInteractionEnabled = true
    }
    
   // MARK: Methods
    
    private func reloadCollectioViews() {
        self.cvA.reloadData()
        self.cvB.reloadData()
    }
    
    private func reloadCollectionViewCells(indexPath: IndexPath, collectionView: UICollectionView) {
        collectionView.reloadItems(at: [indexPath])
    }
    
    
    
}

// MARK: Collection View Delaget & Datasource Methods

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView ==  self.cvA {
            return datasourceA.count
        }else{
            return datasourceB.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.cvA {
           let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
            cellA.lblTitle.text = datasourceA[indexPath.row]
            return cellA
            
        }else {
            let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
              cellB.lblTitle.text = datasourceB[indexPath.row]
            return cellB
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.cvA {
            if !trackDict.keys.contains(datasourceA[indexPath.row]) {
                print("Invalid Items")
               return
            }
        if trackDict[datasourceA[indexPath.row]] == indexPath {
            self.datasourceB.insert(datasourceA[indexPath.row], at: indexPath.row)

        }else {
            self.datasourceB.append(datasourceA[indexPath.row])
        }
        trackDict.removeValue(forKey: datasourceA[indexPath.row])
        self.datasourceA.remove(at: indexPath.row)
        self.cvA.deleteItems(at: [indexPath])
        self.cvA.deleteItems(at: [indexPath])
        self.cvB.insertItems(at: [indexPath])
        self.reloadCollectioViews()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemCount = CGFloat(self.datasourceA.count)
        let width = (collectionView.frame.size.width - 40) / itemCount
        let height = (collectionView.frame.size.width - 40) / itemCount
        return CGSize(width: width, height: height)
    }
}

extension ViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if collectionView == self.cvB {
            let item = self.datasourceB[indexPath.row]
            let itemProvider = NSItemProvider(object: item as NSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
        }else {
            return []
        }
    }
}

extension ViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView == self.cvA {
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
        
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        }else {
            let row = cvB.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row-1, section: 0)
        }
        
        if coordinator.proposal.operation == .copy {
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
    }
}

extension ViewController {
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        if let item = coordinator.items.first {
            let index = datasourceB.firstIndex(of: item.dragItem.localObject! as! String)
            let indePathNew = IndexPath(row: index!, section: 0)
            trackDict[item.dragItem.localObject! as! String] = indePathNew
                self.datasourceA.insert(item.dragItem.localObject! as! String, at: indePathNew.row)
             self.cvB.deleteItems(at: [indePathNew])
             self.cvA.insertItems(at: [indePathNew])
            self.datasourceB.remove(at: indePathNew.row)
            self.reloadCollectioViews()
            coordinator.drop(item.dragItem, toItemAt: indePathNew)
        }
    }
}

