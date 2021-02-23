//
//  FunctionalTableData+UITableViewDataSource.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-03-08.
//  Copyright © 2019 Shopify. All rights reserved.
//

import UIKit

extension FunctionalTableData {
	class DataSource: NSObject, UITableViewDataSource {
		private let data: TableData
		private var cellStyler: CellStyler
    private let sectionTitles: [String]
		
    init(cellStyler: CellStyler, sectionTitles: [String]) {
			self.cellStyler = cellStyler
			self.data = cellStyler.data
      self.sectionTitles = sectionTitles
		}
		
		public func numberOfSections(in tableView: UITableView) -> Int {
			return data.sections.count
		}
		
		public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return data.sections[section].rows.count
		}
		
		public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let sectionData = data.sections[indexPath.section]
			let row = indexPath.row
			let cellConfig = sectionData[row]
			let cell = cellConfig.dequeueCell(from: tableView, at: indexPath)
			let accessibilityIdentifier = ItemPath(sectionKey: sectionData.key, itemKey: cellConfig.key).description
			cellConfig.accessibility.with(defaultIdentifier: accessibilityIdentifier).apply(to: cell)
			cellStyler.update(cell: cell, cellConfig: cellConfig, at: indexPath, in: tableView)
			
			return cell
		}
		
		public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
			// Should only ever be moving within section
			assert(sourceIndexPath.section == destinationIndexPath.section)
			
			// Update internal state to match move
			let cell = data.sections[sourceIndexPath.section].rows.remove(at: sourceIndexPath.row)
			data.sections[destinationIndexPath.section].rows.insert(cell, at: destinationIndexPath.row)
			data.sections[sourceIndexPath.section].didMoveRow?(sourceIndexPath.row, destinationIndexPath.row)
		}
		
		public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
			return data.sections[indexPath]?.actions.canBeMoved ?? false
		}
		
		public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
			guard let cellConfig = data.sections[indexPath] else { return false }
			return cellConfig.actions.hasEditActions || self.tableView(tableView, canMoveRowAt: indexPath) || cellConfig.style?.selected != nil
		}

    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
      return sectionTitles
    }
	}
}
