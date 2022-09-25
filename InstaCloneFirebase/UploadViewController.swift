
import UIKit
import Firebase
import FirebaseStorage

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)

        
        
    }
    @objc func chooseImage(){
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func makeAlert(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonClicked(_ sender: Any) {
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let medaiaFolder = storageReference.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            let uuid = UUID().uuidString
            let imageReference = medaiaFolder.child("\(uuid).jpeg")
            imageReference.putData(data, metadata: nil) { (metadata, error) in
                if error != nil {
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error!")
                } else {
                    imageReference.downloadURL { (url, error) in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            
                            // Database kullanıcı, resim, açıklama, tarih,post adı yapılıyor
                            
                            //data base oluşturma
                            let firestoreDatabase = Firestore.firestore()
                            //döküman referansı oluşturacağız data yazmak okumak çekmek için
                            var firestoreReference: DocumentReference? = nil
                            
                            //firestore postu sözlüğü oluşturmamız lazım kaydetmek için kayıt ettiğimiz fotoları urleri ile kayıt edeceğiz. sözlüğün için [] neyi kayıt etmek istiyorsak onu yazağız. sonrasında kimin tarafından bu post yazılmış onu yaacağız. sonunda String,any olarak aldık ki döküman oluşturduğumuz için içinde kullanmak için
                            let firestorePost = ["imageUrl:" : imageUrl!, "postedBy:" : Auth.auth().currentUser!.email!, "postComment:" : self.commentText.text!, "data:" : FieldValue.serverTimestamp(), "like:" : 0]  as [String : Any]
                            
                            // store datasının içinde döküman oluşturup içinde collection açmak açacağız
                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                if error != nil {
                                    self .makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error!")
                                }else {
                                    self.imageView.image = UIImage(named: "select.png")
                                    self.commentText.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                }
                            })
                                

                            }
                            
                        }
                    }
                }

            }
             
        }
}
