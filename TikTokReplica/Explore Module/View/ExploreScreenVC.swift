//
//  ExploreScreenVC.swift
//  Rizzle
//
//  Created by Nimish Sharma on 16/05/20.
//  Copyright © 2020 Nimish Sharma. All rights reserved.
//

import UIKit


typealias TableViewEmbeddedCollectionViewIndexPath = (tableViewIndexPath: IndexPath, collectionViewIndexPath: IndexPath)

class ExploreScreenVC: BaseUIViewController {
    
    enum Section: CaseIterable {
        case exploreSection
    }
    
    //    MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //    MARK: ViewModel
    var viewModel: ExploreScreenVM!
    var tableViewDataSource: UITableViewDiffableDataSource<Section, CategoryModel>!
    
    //    MARK: States
    var selectedIndexPath: TableViewEmbeddedCollectionViewIndexPath!

    //    MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ExploreScreenVM()
        initialSetup()
    }
    
    //    MARK: Private Methods
    private func initialSetup() {
        setupNavigationBar()
        setupTableView()
        requestData()
    }
    
    private func setupNavigationBar() {
        setNavigationBar(title: AppTexts.explore, largeTitles: true)
        addRightButtonToNavigation(image: AppImages.navigationOptionBtn)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear
        tableView.registerCell(with: ExploreTVCell.self)
        setupTableViewDataSource()
    }
    
    private func setupTableViewDataSource() {
        self.tableViewDataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else {return nil}
            let cell = tableView.dequeueCell(with: ExploreTVCell.self, indexPath: indexPath)
            cell.populateData(item, didSelectCallback: self.didSelectVideo)
            return cell
        })
    }
    
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CategoryModel>()
        snapshot.appendSections([Section.exploreSection])
        snapshot.appendItems(viewModel.dataSource)
        tableViewDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func requestData() {
        viewModel.fetchDataFromServer({ [weak self] in
            self?.tableView.separatorStyle = .singleLine
            self?.updateDataSource()
        }) { [weak self] error in
            self?.showErrorAlert(error.localizedDescription)
        }
    }
    
    private func showErrorAlert(_ message: String) {
        let controller = UIAlertController(title: AppTexts.oops, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: AppTexts.done, style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    private func didSelectVideo(_ indexPath: TableViewEmbeddedCollectionViewIndexPath) {
        selectedIndexPath = indexPath
        let vc = PlayerScreenContainerVC.instantiate(fromAppStoryboard: .main)
        navigationController?.delegate = vc.transitionController
        vc.transitionController.fromDelegate = self
        vc.transitionController.toDelegate = vc
        vc.delegate = self
        vc.currentIndex = self.selectedIndexPath.collectionViewIndexPath.row
        let videos = self.viewModel.dataSource[indexPath.tableViewIndexPath.row].videos
        vc.viewModel = PlayerScreenContainerVM(videos)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the event
    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: TableViewEmbeddedCollectionViewIndexPath) -> UIImageView {
        
        
        let tableViewCell = self.tableView.cellForRow(at: selectedIndexPath.tableViewIndexPath) as! ExploreTVCell
        
        let visibleCells = tableViewCell.collectionView.indexPathsForVisibleItems
        
        if !visibleCells.contains(self.selectedIndexPath.collectionViewIndexPath) {
            
            //Scroll the collectionView to the current selectedIndexPath which is offscreen
            tableViewCell.collectionView.scrollToItem(at: self.selectedIndexPath.collectionViewIndexPath, at: .centeredHorizontally, animated: false)

            guard let collectionViewCell = (tableViewCell.collectionView.cellForItem(at: self.selectedIndexPath.collectionViewIndexPath) as? ExploreCell) else {
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            
            return collectionViewCell.titleIV
            
        } else {
            guard let collectionViewCell = (tableViewCell.collectionView.cellForItem(at: self.selectedIndexPath.collectionViewIndexPath) as? ExploreCell) else {
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            return collectionViewCell.titleIV
        }
        
    }
    
    func getFrameFromCollectionViewCell(for selectedIndexPath: TableViewEmbeddedCollectionViewIndexPath) -> CGRect {
        
        
        let tableViewCell = self.tableView.cellForRow(at: selectedIndexPath.tableViewIndexPath) as! ExploreTVCell
        
        //Get the currently visible cells from the collectionView
        let visibleCells = tableViewCell.collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(self.selectedIndexPath.collectionViewIndexPath) {
            
            //Scroll the collectionView to the cell that is currently offscreen
            tableViewCell.collectionView.scrollToItem(at: self.selectedIndexPath.collectionViewIndexPath,
                                                      at: .centeredHorizontally,
                                                      animated: false)
            guard let collectionViewCell = (tableViewCell.collectionView.cellForItem(at: self.selectedIndexPath.collectionViewIndexPath) as? ExploreCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            return collectionViewCell.frame
            
        }//Otherwise the cell should be visible
        else {
            guard let collectionViewCell = (tableViewCell.collectionView.cellForItem(at: self.selectedIndexPath.collectionViewIndexPath) as? ExploreCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            return collectionViewCell.frame
        }
    }
    
}


//    MARK: TableView Delegate Methods
extension ExploreScreenVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension ExploreScreenVC: PlayerScreenContainerVCDelegate {
 
    func containerViewController(_ containerViewController: PlayerScreenContainerVC, indexDidUpdate currentIndex: Int) {
        let newIndexPath: TableViewEmbeddedCollectionViewIndexPath = (selectedIndexPath.tableViewIndexPath, IndexPath(row: currentIndex, section: 0))
        self.selectedIndexPath = newIndexPath
        
        let tableViewCell = self.tableView.cellForRow(at: selectedIndexPath.tableViewIndexPath) as! ExploreTVCell
        
        tableViewCell.collectionView.scrollToItem(at: self.selectedIndexPath.collectionViewIndexPath, at: .centeredHorizontally, animated: false)
    }
}

extension ExploreScreenVC: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        
        let tableViewCell = self.tableView.cellForRow(at: selectedIndexPath.tableViewIndexPath) as! ExploreTVCell
        
        let cell = tableViewCell.collectionView.cellForItem(at: self.selectedIndexPath.collectionViewIndexPath) as! ExploreCell
        
        let cellFrame = tableViewCell.collectionView.convert(cell.frame, to: self.view)
        
        if cellFrame.minY < tableViewCell.collectionView.contentInset.top {
            tableViewCell.collectionView.scrollToItem(at: self.selectedIndexPath.collectionViewIndexPath, at: .top, animated: false)
        } else if cellFrame.maxY > self.view.frame.height - tableViewCell.collectionView.contentInset.bottom {
            tableViewCell.collectionView.scrollToItem(at: self.selectedIndexPath.collectionViewIndexPath, at: .bottom, animated: false)
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        let referenceImageView = getImageViewFromCollectionViewCell(for: self.selectedIndexPath)
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        
        let tableViewCell = self.tableView.cellForRow(at: selectedIndexPath.tableViewIndexPath) as! ExploreTVCell
        
        self.view.layoutIfNeeded()
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: self.selectedIndexPath)
        
        let cellFrame = tableViewCell.collectionView.convert(unconvertedFrame, to: self.view)
        
        if cellFrame.minY < tableViewCell.collectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: tableViewCell.collectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (tableViewCell.collectionView.contentInset.top - cellFrame.minY))
        }
        
        return cellFrame
    }
    
}

