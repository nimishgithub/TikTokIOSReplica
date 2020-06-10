//
//  Extensions.swift

import UIKit


//MARK: UITableView Extension
extension UITableView {
    ///Register Table View Cell Nib
    func registerCell(with identifier: UITableViewCell.Type)  {
        self.register(UINib(nibName: "\(identifier.self)",bundle:nil),
                      forCellReuseIdentifier: "\(identifier.self)")
        
    }
    
    ///Dequeue Table View Cell
    func dequeueCell <T: UITableViewCell> (with identifier: T.Type, indexPath: IndexPath? = nil) -> T {
        if let index = indexPath {
            return self.dequeueReusableCell(withIdentifier: "\(identifier.self)", for: index) as! T
        } else {
            return self.dequeueReusableCell(withIdentifier: "\(identifier.self)") as! T
        }
    }
}

//MARK: UICollectionView Extension
extension UICollectionView {
    ///Register Collection View Cell Nib
    func registerCell(with identifier: UICollectionViewCell.Type)  {
        self.register(UINib(nibName: "\(identifier.self)", bundle: nil), forCellWithReuseIdentifier: "\(identifier.self)")
    }
    
    ///Dequeue Collection View Cell
    func dequeueCell <T: UICollectionViewCell> (with identifier: T.Type, indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: "\(identifier.self)", for: indexPath) as! T
    }
}

//MARK: UITableViewCell Extension
extension UITableViewCell {
    var indexPathInTableView: IndexPath? {
        if let tableView = self.superview as? UITableView, let indexPath = tableView.indexPath(for: self) {
            return indexPath
        }
        return nil
    }
    
}


//MARK: UITableViewCell Extension
extension UICollectionViewCell {
    var indexPathInCollectionView: IndexPath? {
        if let collectionView = self.superview as? UICollectionView, let indexPath = collectionView.indexPath(for: self) {
            return indexPath
        }
        return nil
    }
    
}
