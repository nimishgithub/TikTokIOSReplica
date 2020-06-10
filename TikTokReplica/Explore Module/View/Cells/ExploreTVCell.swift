//
//  ExploreTVCell.swift
//  Rizzle
//
//  Copyright © 2020 Nimish Sharma. All rights reserved.
//

import UIKit

class ExploreTVCell: UITableViewCell {
    
    enum Section: CaseIterable {
        case videos
    }
    
    //    MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //    MARK: Properties
    private(set) var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, Video>!
    private var didSelectItem: ((TableViewEmbeddedCollectionViewIndexPath)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = AppColors.appTheme
        setupCollectionView()
        setupLabels()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupCollectionViewDataSource()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.backgroundColor = AppColors.appTheme
        collectionView.registerCell(with: ExploreCell.self)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        setupCollectionViewDataSource()
    }
    
    private func setupLabels() {
        titleLabel.textColor = AppColors.appTextBlack
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    func populateData(_ dataSource: CategoryModel,
                      didSelectCallback: @escaping(_ indexPath: TableViewEmbeddedCollectionViewIndexPath)->Void) {
        self.titleLabel.text = dataSource.title
        didSelectItem = didSelectCallback
        updateDataSource(dataSource.videos)
    }
    
    private func setupCollectionViewDataSource() {
        self.collectionViewDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, video) -> UICollectionViewCell? in
            let cell = collectionView.dequeueCell(with: ExploreCell.self, indexPath: indexPath)
            cell.populateData(video)
            return cell
        })
    }
    
    private func updateDataSource(_ items: [Video]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Video>()
        snapshot.appendSections([Section.videos])
        snapshot.appendItems(items)
        collectionViewDataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

//    MARK: UICollectionViewDelegateFlowLayout
extension ExploreTVCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let estimatedWidth = (bounds.height * 0.5)
        return CGSize(width: estimatedWidth, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}

//    MARK: UICollectionViewDelegate
extension ExploreTVCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem?((indexPathInTableView ?? [0,0], indexPath))
    }
}
