//
//  WorkLogDataCell.swift
//  Metrolog
//
//  Created by jay on 07/08/24.
//

import UIKit

class WorkLogDataCell: UITableViewCell {

    @IBOutlet weak var workLogData: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var status: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
