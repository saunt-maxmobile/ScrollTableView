//
//  CustomScrollView.swift
//  NeonLedKeyboard
//
//  Created by MaxMobile Software on 10/6/24.
//

import Foundation
import SwiftUI
import UIKit

struct CustomScrollView<Collections, TableContent, CellContent>: UIViewControllerRepresentable where
Collections: RandomAccessCollection,
Collections.Index == Int,
Collections.Element: Identifiable,
CellContent: View,
TableContent: View {
    
    typealias Data = Collections.Element
    typealias CollectionViewContent = (Data, Int) -> CellContent
    typealias TableViewContent = (Data) -> TableContent
    typealias SizeForData = (Data) -> CGSize
    typealias RawCustomize = (UICollectionView) -> Void
    typealias DataAction = (Data) -> Void
    
    @Binding var collections: Collections
    let collectionViewContent: CollectionViewContent
    let tableViewContent: TableViewContent
    let collectionHeight: CGFloat
    let contentSize: ContentSize
    let rawCustomize: RawCustomize?
    let onDisplayItem: DataAction?
    let onEndDisplayItem: DataAction?
    
    enum ContentSize {
        case fixed(CGSize) /// fixed size for item
        case variable(SizeForData) /// size variable by data item
        case crossAxisFilled(mainAxisLength: CGFloat) /// set size for cross axis
    }
    
    init(
        collections: Binding<Collections>,
        collectionHeight: CGFloat,
        contentSize: ContentSize,
        rawCustomize: RawCustomize? = nil,
        onDisplayItem: DataAction? = nil,
        onEndDisplayItem: DataAction? = nil,
        collectionViewContent: @escaping CollectionViewContent,
        tableViewContent: @escaping TableViewContent
    ) {
        self._collections = collections
        self.collectionHeight = collectionHeight
        self.contentSize = contentSize
        self.rawCustomize = rawCustomize
        self.collectionViewContent = collectionViewContent
        self.tableViewContent = tableViewContent
        self.onDisplayItem = onDisplayItem
        self.onEndDisplayItem = onEndDisplayItem
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(view: self)
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        let coordinator = context.coordinator
        let viewController = ViewController(coordinator: coordinator)
        coordinator.viewController = viewController
        self.rawCustomize?(viewController.collectionView)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        context.coordinator.viewController?.tableView.reloadData()
        context.coordinator.viewController?.collectionView.reloadData()
    }
}

extension CustomScrollView {
    fileprivate static var collectionCellReuseIdentifier: String {
        return "HostedCollectionViewCell"
    }
    
    fileprivate static var tableCellReuseIdentifier: String {
        return "HostedTableViewCell"
    }
}

// MARK: ViewController
extension CustomScrollView {
    
    final class ViewController: UIViewController {
        
        let scrollView: UIScrollView
        let collectionView: UICollectionView
        let tableView: UITableView
        var collectionViewHeightConstraint: NSLayoutConstraint!
        
        init(coordinator: Coordinator) {
            self.scrollView = UIScrollView()
            self.scrollView.translatesAutoresizingMaskIntoConstraints = false
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            self.collectionView.translatesAutoresizingMaskIntoConstraints = false
            
            self.tableView = UITableView()
            self.tableView.translatesAutoresizingMaskIntoConstraints = false
            
            super.init(nibName: nil, bundle: nil)
            
            self.collectionView.dataSource = coordinator
            self.collectionView.delegate = coordinator
            self.collectionView.register(HostedCollectionViewCell.self, forCellWithReuseIdentifier: CustomScrollView.collectionCellReuseIdentifier)
            
            self.tableView.dataSource = coordinator
            self.tableView.delegate = coordinator
            self.tableView.register(HostedTableViewCell.self, forCellReuseIdentifier: CustomScrollView.tableCellReuseIdentifier)
            
//            self.scrollView.addSubview(self.collectionView)
//            self.scrollView.addSubview(self.tableView)
//            self.view.addSubview(self.scrollView)
            
            self.view.addSubview(self.collectionView)
            self.view.addSubview(self.tableView)
            
            self.collectionViewHeightConstraint = self.collectionView.heightAnchor.constraint(equalToConstant: coordinator.view.collectionHeight)
            
            NSLayoutConstraint.activate([
                
//                self.scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
//                self.scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
//                self.scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
//                self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
                
                self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
                self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
                self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                self.collectionViewHeightConstraint,
                
                self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                self.tableView.topAnchor.constraint(equalTo: self.collectionView.bottomAnchor, constant: 10),
//                self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
//                self.tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: Coordinator
extension CustomScrollView {
    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
        
        fileprivate var view: CustomScrollView
        fileprivate var viewController: ViewController?
        
        init(view: CustomScrollView, viewController: ViewController? = nil) {
            self.view = view
            self.viewController = viewController
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            self.view.collections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomScrollView.collectionCellReuseIdentifier, for: indexPath) as! HostedCollectionViewCell
            let data = self.view.collections[indexPath.item]
            let content = self.view.collectionViewContent(data, indexPath.row)
            cell.provide(content)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            let cell = cell as! HostedCollectionViewCell
            cell.attach(to: self.viewController!)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            /// custom size of item
            switch self.view.contentSize {
            case .fixed(let size):
                return size
            case .variable(let sizeForData):
                let data = self.view.collections[indexPath.item]
                return sizeForData(data)
            case .crossAxisFilled(let mainAxisLength):
                return CGSize(width: mainAxisLength, height: collectionView.bounds.height)
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
        
        //        MARK: TableView
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            self.view.collections.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomScrollView.tableCellReuseIdentifier, for: indexPath) as! HostedTableViewCell
            let data = self.view.collections[indexPath.row]
            let content = self.view.tableViewContent(data)
            cell.provide(content)
            cell.attach(to: self.viewController!)
            return cell
        }
        
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let data = self.view.collections[indexPath.row]
            self.view.onDisplayItem?(data)
            // Scroll the collection view to the corresponding item
            self.viewController?.collectionView.scrollToItem(at: IndexPath(item: indexPath.row, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let cell = cell as! HostedTableViewCell
//            cell.detach()
            if indexPath.row < self.view.collections.count {
                let data = self.view.collections[indexPath.row]
                self.view.onEndDisplayItem?(data)
            }
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            if scrollView == self.viewController?.tableView {
//                // Sync collection view scroll
//                let tableViewOffsetY = scrollView.contentOffset.y
//                let collectionViewHeight = self.view.collectionHeight
//                let index = Int((tableViewOffsetY + scrollView.contentInset.top) / collectionViewHeight)
//                self.viewController?.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
//            }
        }
    }
}

// MARK: HostedCollectionViewCell
private extension CustomScrollView {
    
    final class HostedCollectionViewCell : UICollectionViewCell {
        
        var viewController: UIHostingController<CellContent>?
        
        func provide(_ content: CellContent) {
            if let viewController = self.viewController {
                viewController.rootView = content
            } else {
                let hostingController = UIHostingController(rootView: content)
                hostingController.view.backgroundColor = nil
                self.viewController = hostingController
            }
        }
        
        func attach(to parentController: UIViewController) {
            let hostedController = self.viewController!
            let hostedView = hostedController.view!
            let contentView = self.contentView
            
            parentController.addChild(hostedController)
            
            hostedView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(hostedView)
            hostedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            hostedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            hostedView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            hostedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            
            hostedController.didMove(toParent: parentController)
        }
        
        func detach() {
            let hostedController = self.viewController!
            guard hostedController.parent != nil else { return }
            let hostedView = hostedController.view!
            
            hostedController.willMove(toParent: nil)
            hostedView.removeFromSuperview()
            hostedController.removeFromParent()
        }
    }
}

// MARK: HostedTableViewCell
private extension CustomScrollView {
    
    final class HostedTableViewCell: UITableViewCell {
        
        var viewController: UIHostingController<TableContent>?
        
        func provide(_ content: TableContent) {
            if let viewController = self.viewController {
                viewController.rootView = content
            } else {
                let hostingController = UIHostingController(rootView: content)
                hostingController.view.backgroundColor = nil
                self.viewController = hostingController
            }
        }
        
        func attach(to parentController: UIViewController) {
            guard let hostedController = self.viewController else { return }
            let hostedView = hostedController.view!
            let contentView = self.contentView
            
            parentController.addChild(hostedController)
            
            hostedView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(hostedView)
            hostedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            hostedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            hostedView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            hostedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            
            hostedController.didMove(toParent: parentController)
        }
        
        func detach() {
            guard let hostedController = self.viewController else { return }
            let hostedView = hostedController.view
            
            hostedController.willMove(toParent: nil)
            hostedView?.removeFromSuperview()
            hostedController.removeFromParent()
        }
    }
}
