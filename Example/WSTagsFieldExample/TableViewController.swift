//
//  TableViewController.swift
//  WSTagsFieldExample
//
//  Created by Ricardo Pereira on 28/04/2017.
//  Copyright © 2017 Whitesmith. All rights reserved.
//

import UIKit
import WSTagsField

class TableViewController: UITableViewController {

    let records = ["Festival", "Salvador", "EuroVision", "Beer", "The Room", "The Disaster Movie", "Let's Go", "Bibofir", "The Shape of Water", "It", "American History", "Beautiful", "Sicario"]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh", style: .done, target: self, action: #selector(self.refreshButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(self.closeTapped))

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.allowsSelection = false
        tableView.register(TagsViewCell.self, forCellReuseIdentifier: String(describing: TagsViewCell.self))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
    }

    @objc func refreshButtonTapped() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    @objc func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TagsViewCell.self), for: indexPath) as? TagsViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }

        cell.tagsField.onDidChangeHeightTo = { [weak tableView] _, _ in
            tableView?.beginUpdates()
            tableView?.endUpdates()
        }

        return cell
    }

}

class TagsViewCell: UITableViewCell {

    let tagsField = WSTagsField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        tagsField.addTag("alksjlkasd")
        tagsField.addTag("alksjlkasd1")
        tagsField.addTag("alksjlkasd2")
        tagsField.addTag("alksjlkasd3")
        tagsField.addTag("alksjlkasd4")
        tagsField.addTag("alksjlkasdsds5")

        tagsField.placeholderAlwaysVisible = true
        tagsField.backgroundColor = .white

        tagsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tagsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        tagsField.tintColor = UIColor.init(hexString: "#F0F0F0")
        tagsField.textColor = UIColor.init(hexString: "#9A9FA5")
        tagsField.font = UIFont.systemFont(ofSize: 14, weight: .light)
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagsField)

        NSLayoutConstraint.activate([
            tagsField.topAnchor.constraint(equalTo: contentView.topAnchor),
            tagsField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            tagsField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            contentView.bottomAnchor.constraint(equalTo: tagsField.bottomAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
}
