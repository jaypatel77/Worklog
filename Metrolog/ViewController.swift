//
//  ViewController.swift
//  Metrolog
//
//  Created by jay on 31/07/24.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {
    
    @IBOutlet weak var fromDate: UIDatePicker!
    @IBOutlet weak var toDate: UIDatePicker!
    
    @IBOutlet weak var headerViewInTable: UIView!
    @IBOutlet weak var weekTableView: UITableView!
    
    @IBOutlet weak var textField: UITextField!
    
    var workLog: [WorkLogModel] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        
        headerViewInTable.layer.borderWidth = 0.2
        headerViewInTable.layer.borderColor = UIColor.black.cgColor
        weekTableView.delegate = self
        weekTableView.dataSource = self
        weekTableView.register(UINib(nibName: "WorkLogDataCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        loadAndShowDataFromFirebase()
    }
    
    @IBAction func submit(_ sender: Any) {
        
        fromDate.datePickerMode = .dateAndTime
        toDate.datePickerMode = .time
        
        let thatDate = getSelectDate(fromDate: fromDate)
        let thatDay = getSelectedDayFromDate(fromDate: fromDate)
        let hours = getHours(fromDate: fromDate, toDate: toDate)
        let timeRangeStartEnd = getTimeRange(fromDate: fromDate, toDate: toDate)
        let docData: [String: Any] = ["thatDate": thatDate,"thatDay": thatDay,"timeRange": timeRangeStartEnd,"hours": hours,"status": ""]
        
        saveDataOnFirebase(docData: docData)
    }
    
    func loadAndShowDataFromFirebase()   {
        db.collection("data").order(by: "thatDate").addSnapshotListener { (QuerySnapshot, error) in
            self.workLog = []
            if let e = error {
                print("Issue in retrieving from firebase", "\(e)")
            }else{
                if let snapshortDocuments =  QuerySnapshot?.documents {
                    for doc in snapshortDocuments {
                        let data = doc.data()
                        if let thatDate = data["thatDate"] as? String,
                           let thatDay = data["thatDay"] as? String,
                           let timeRange = data["timeRange"] as? String,
                           let hours = data["hours"] as? String,
                           let status = data["status"] as? String{
                            let newWorkLogRetrieved = WorkLogModel(date: thatDate, day: thatDay, timeRange: timeRange, hours: hours, status: status)
                            self.workLog.append(newWorkLogRetrieved)
                            
                            DispatchQueue.main.async {
                                self.weekTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func saveDataOnFirebase(docData : [String: Any]) {
        do {
            try  db.collection("data").document(docData["thatDate"] as! String).setData(docData)
            let thatDate = docData["thatDate"] as! String
            let timeRange = docData["timeRange"] as! String
            let alertController = UIAlertController(title: "Saved", message:  thatDate + " and " + timeRange, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                // Handle OK button tap
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
        } catch {
          print("Error writing document: \(error)")
        }
    }
    
    func getSelectDate(fromDate: UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let thatDate = dateFormatter.string(from: fromDate.date)
        return thatDate
    }
    
    func getSelectedDayFromDate(fromDate : UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        let thatDay = dateFormatter.string(from: fromDate.date)
        return thatDay
    }
    
    func getTimeRange(fromDate: UIDatePicker, toDate: UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        let startDateFormattedTime = dateFormatter.string(from: fromDate.date)   // Extract hours and minutes
        let statDateHourMinute = startDateFormattedTime.components(separatedBy: ":")
        let startDateHours = statDateHourMinute[0]
        let startDateMinutes = statDateHourMinute[1]
        
        let endDateFormattedTime = dateFormatter.string(from: toDate.date)
        let endDateHourMinuteTime = endDateFormattedTime.components(separatedBy: ":")
        let endDateHours = endDateHourMinuteTime[0]
        let endDateMinutes = endDateHourMinuteTime[1]
        let timeRangeStartEnd = startDateFormattedTime + "-" + endDateFormattedTime
        return timeRangeStartEnd
    }
    
    
    func getHours(fromDate: UIDatePicker, toDate: UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        var startDateFormattedTime = dateFormatter.string(from: fromDate.date)
        var statDateHourMinute = startDateFormattedTime.components(separatedBy: ":")
        
        var endDateFormattedTime = dateFormatter.string(from: toDate.date)
        var endDateHourMinuteTime = endDateFormattedTime.components(separatedBy: ":")
        
        let numberFormatter = NumberFormatter()
        let endNumber = numberFormatter.number(from: endDateHourMinuteTime[0] + "." + endDateHourMinuteTime[1])
        let endNumberFloatValue = endNumber?.floatValue ?? 0
        
        let startNumber = numberFormatter.number(from: statDateHourMinute[0] + "." + statDateHourMinute[1])
        let startNumberFloatValue = startNumber?.floatValue ?? 0
        
        var endNumberHourMin = endNumber?.decimalValue ?? 0
        var startNumberHourMin = startNumber?.decimalValue ?? 0
        
        var hours = endNumberHourMin - startNumberHourMin
 
        return "\(hours)"
    }
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workLog.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! WorkLogDataCell
        cell.date.text = workLog[indexPath.row].date
        cell.day.text = workLog[indexPath.row].day
        cell.hours.text = workLog[indexPath.row].hours
        cell.time.text = workLog[indexPath.row].timeRange
        cell.status.text = workLog[indexPath.row].status
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            weekTableView.beginUpdates()
            let cell = weekTableView.cellForRow(at: indexPath) as! WorkLogDataCell
            workLog.remove(at: indexPath.row)
            weekTableView.deleteRows(at: [indexPath], with: .fade)
             do {
                try  db.collection("data").document(cell.date.text!).delete()
                print("Document successfully updated")
            } catch {
              print("Error updating document: \(error)")
            }
            weekTableView.endUpdates()
            
        }
    }
}


//    private lazy var customDateTimePicker: DateTimePicker = {
//       let picker  = DateTimePicker()
//        picker.setup()
//        picker.didSelectDates = { [weak self] (startDate, endDate) in
//            let text = Date.buildTimeRangeString(startDate: startDate, endDate: endDate)
//
//            print(text)
//
//        }
//        return picker
//    }()

//textField.inputView = customDateTimePicker.inputView

//        let differenceInSeconds = toDate.date.timeIntervalSince(fromDate.date)
//        let differenceInHours = differenceInSeconds / 3600
//        let formattedDifference = String(differenceInHours)

