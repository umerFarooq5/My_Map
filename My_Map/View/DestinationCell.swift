//
//  TVCell.swift
//  My_Map
//
//  Created by umer malik on 30/10/2020.
//

import UIKit

class DestinationCell: UITableViewCell {
    
    var dataModel : DataModel? {
        didSet {
            let searchDate = dataModel?.date ?? Date()
            guard let destination = dataModel?.destination else { return }
            textLbl.text = destination
            
            setDate(searchDate: searchDate, com: { (time, date) in
                self.dateLbl.text = ("\(time), \(date)")
            })
        }
        
    }
    
    
    var bubble : UIView = {
        let lbl = UIView()
        lbl.backgroundColor = .blue
        lbl.layer.cornerRadius = 5
        return lbl
    }()
    
    let dateLbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 10)
        return lbl
    }()
    
    let textLbl : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        return lbl
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(dateLbl)
        dateLbl.anchor(bottom: bottomAnchor, right: rightAnchor,paddingBottom: 2, paddingRight: 2, width: 120, height: 30)
        
        
        addSubview(bubble)
        bubble.anchor(top: topAnchor, left: leftAnchor, bottom: dateLbl.topAnchor, right: rightAnchor, paddingTop: 3, paddingLeft: 10, paddingBottom: 2, paddingRight: 8)
        
        bubble.addSubview(textLbl)
        textLbl.anchor(top: bubble.topAnchor, left: bubble.leftAnchor, bottom: bubble.bottomAnchor, right: bubble.rightAnchor, paddingTop: 3, paddingLeft: 10, paddingBottom: 2, paddingRight: 8)
    }
    
    func setDate(searchDate: Date, com: @escaping(String, String) -> ()) {
        let time = DateFormatter.localizedString(from: searchDate, dateStyle: .none, timeStyle: .short)
        let date = DateFormatter.localizedString(from: searchDate, dateStyle: .medium, timeStyle: .none)
        com(time, date)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
