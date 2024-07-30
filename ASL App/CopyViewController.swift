import UIKit

class CopyViewController: UIViewController {

    @IBOutlet var PulledText: UILabel!
    // Add other outlets as needed

    var selectedData: MyDataModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = selectedData {
            PulledText.text = data.pulledText
            // Update other UI elements with data properties as needed
        }
    }
}
