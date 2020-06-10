//
//  ExploreCell.swift

import UIKit

class ExploreCell: UICollectionViewCell {

    //    MARK: IBOutlets
    @IBOutlet weak var titleIV: UIImageView!
    
    //    MARK: View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUIComponents()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleIV.image = nil
        titleIV.backgroundColor = AppColors.bgLightGray
    }

    override func layoutSubviews() {
        titleIV.layer.cornerRadius = 12
    }
    
    private func setupUIComponents() {
        titleIV.clipsToBounds = true
        titleIV.contentMode = .scaleAspectFill
    }
    
    func populateData(_ model: Video) {
        if let videoUrl = URL(string: model.media.encodeURL) {
            
           self.titleIV.setThumbnail(videoUrl, placeholderImage: AppImages.placeHolder, originalIndex: indexPathInCollectionView, completion: { [weak self] (image, indexPath) in
                guard let self = self else {return}
                
                if indexPath == self.indexPathInCollectionView {
                    self.titleIV.image = image
                }
            })
        }
    }
}

