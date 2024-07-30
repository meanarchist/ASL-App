import UIKit

struct MyDataModel: Decodable, Equatable {
    let timestamp: String
    let pulledText: String
}

struct DataResponse: Decodable {
    let data: String
    let flag: String
    let time: String  // Change the type to String
}

class MyCustomCell: UITableViewCell {
    @IBOutlet var Timestp: UILabel!
    @IBOutlet var PulledText: UILabel!
    @IBOutlet var Converted: UIImageView!
}

class TextViewController: UITableViewController {
    var dataArray: [MyDataModel] = [] // Array to store the fetched data
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("hello")

        // Start the timer to fetch data every 20 seconds
        timer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(fetchData), userInfo: nil, repeats: true)

        // Fetch data for the first time
        fetchData()
    }

    @objc func fetchData() {
        // Invalidate the timer to avoid concurrent requests
        timer?.invalidate()

        // Call a function to fetch data from the server and update dataArray
        fetchDataFromServer()

        // Start the timer again for the next 20 seconds
        timer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(fetchData), userInfo: nil, repeats: true)
    }

    func fetchDataFromServer() {
        guard let url = URL(string: "http://104.154.145.223:5000/get_data") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let jsonData = try JSONDecoder().decode(DataResponse.self, from: data)

                if jsonData.flag == "False" {
                    // Data is available, update dataArray
                    let formattedDate = self.formattedDateString(from: jsonData.time)
                    let newData = MyDataModel(timestamp: formattedDate, pulledText: jsonData.data)

                    // Check if the data is not already in dataArray
                    if !self.dataArray.contains(where: { $0 == newData }) {
                        self.dataArray.append(newData)

                        // Print statements to debug
                        print("Data fetched successfully:")
                        print("Timestamp: \(newData.timestamp)")
                        print("PulledText: \(newData.pulledText)")

                        // After updating dataArray, reload the table view
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    // Flag is true, no data available
                    print("No data available")
                }
            } catch let error {
                print("Error decoding JSON: \(error)")
            }
        }

        task.resume()
    }

    func formattedDateString(from timestamp: String) -> String {
        guard let timeInterval = Double(timestamp) else {
            return "Invalid Timestamp"
        }

        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedData = dataArray[indexPath.row]
        performSegue(withIdentifier: "showCopyViewController", sender: selectedData)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCopyViewController", let copyViewController = segue.destination as? CopyViewController, let selectedData = sender as? MyDataModel {
            copyViewController.selectedData = selectedData
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Assuming you have only one section
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! MyCustomCell
        let data = dataArray[indexPath.row]
        cell.Timestp.text = data.timestamp
        cell.PulledText.text = data.pulledText
        return cell
    }
}
