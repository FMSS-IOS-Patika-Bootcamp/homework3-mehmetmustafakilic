
import UIKit
import Firebase

class FeedCell: UITableViewCell {

    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var commentLable: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var likeLable: UILabel!
    @IBOutlet weak var documentIdLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // like label da like yapma ve like güncellemeyi burada yapıyoruz
    @IBAction func likeButtonClicked(_ sender: Any) {
        let fireStoreDatabase = Firestore.firestore()
        
        if let likeCount = Int(likeLable.text!) {
            // güncelleme işlemi yapmak için
            let likeStore = ["like:" : likeCount + 1] as [String : Any]
            // güncelleme işlemi yapmak için set merge(birleştir demek) seçiyoruz
            fireStoreDatabase.collection("Posts").document(documentIdLabel.text!).setData(likeStore, merge: true)
        }
        
        
    }
    
}
