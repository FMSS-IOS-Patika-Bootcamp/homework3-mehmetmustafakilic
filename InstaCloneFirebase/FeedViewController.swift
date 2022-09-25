
import UIKit
import Firebase
import FirebaseStorage
import SDWebImage


class FeedViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    
    var userEmailArray = [String]()
    var userCommentArray = [String]()
    var likeArray = [Int]()
    var userImageArray = [String]()
    var documentIdArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        getDataFromFirestore()
    }
    // veri tabanından verileri anlık olarak çekme fonksiyonu yacağız
    func getDataFromFirestore(){
        let fireStoreDatabase = Firestore.firestore()
        //let settings = fireStoreDatabase.settings
        //settings.areTimestampInSnapshotsEnabled = true
        //fireStoreDatabase.settings = settings
        
        //fire base deki verilerimi tek tek çekiyoruz ve çektiğimiz verileri order kullanarak sıralı bir şekilde düzenliyoruz
        fireStoreDatabase.collection("Posts").order(by: "data:", descending: true).addSnapshotListener { snapshot, error  in
            if error != nil{
                print(error?.localizedDescription)
                
            } else {
                
                if snapshot?.isEmpty != true &&  snapshot != nil{
                    
                    self.userImageArray.removeAll(keepingCapacity: false)
                    self.userEmailArray.removeAll(keepingCapacity: false)
                    self.userCommentArray.removeAll(keepingCapacity: false)
                    self.likeArray.removeAll(keepingCapacity: false)
                    self.documentIdArray.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents {
                        let documentID = document.documentID
                        self.documentIdArray.append(documentID)
                        
                        if let postedBy = document.get("postedBy:") as? String{
                            self.userEmailArray.append(postedBy)
                        }
                        if let  postComment = document.get("postComment:") as? String {
                            self.userCommentArray.append(postComment)
                        }
                        if let like = document.get("like:") as? Int {
                            self.likeArray.append(like)
                        }
                        if let imageUrl = document.get("imageUrl:") as? String{
                            self.userImageArray.append(imageUrl)
                        }

            }
                    self.tableView.reloadData()
            }
          }
        }
    }
    
    
    // table lable deki satır sayını burada tanımlıyoruz
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEmailArray.count
    }
    // feedcelli buraya çekip içini dolduruyoruz. Feede gösteriyoruz
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.userEmailLabel.text = userEmailArray[indexPath.row]
        cell.commentLable.text = userCommentArray[indexPath.row]
        cell.likeLable.text = String(likeArray[indexPath.row])
        cell.userImageView.sd_setImage(with: URL(string: self.userImageArray[indexPath.row]))
        cell.documentIdLabel.text = documentIdArray[indexPath.row]
        return cell
    }
}
