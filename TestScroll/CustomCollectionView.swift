//
//  UICollectionView.swift
//  NeonLedKeyboard
//
//  Created by MaxMobile Software on 15/02/2024.
//

import Foundation
import SwiftUI

struct CustomCollectionView
    <Collections, CellContent>
    : UIViewControllerRepresentable
    where
    Collections : RandomAccessCollection,
    Collections.Index == Int,
    Collections.Element : Identifiable,
    CellContent : View
{
    typealias Data = Collections.Element
    typealias ContentForData = (Data) -> CellContent
    typealias ScrollDirection = UICollectionView.ScrollDirection
    typealias SizeForData = (Data) -> CGSize
    typealias CustomSizeForData = (UICollectionView, UICollectionViewLayout, Data) -> CGSize
    typealias RawCustomize = (UICollectionView) -> Void
    typealias DataAction = (Data) -> Void
    
    
    /// config size of item
    enum ContentSize {
        case fixed(CGSize) /// fixed size for item
        case variable(SizeForData) /// size variable by data item
        case crossAxisFilled(mainAxisLength: CGFloat) /// set size for cross axis
        case custom(CustomSizeForData) /// custom size of item by Collection View, collection layout and dât
    }
    
    struct ItemSpacing : Hashable {
        var mainAxisSpacing: CGFloat /// spacing item in main axis
        var crossAxisSpacing: CGFloat /// spacing item in cross axis
    }
    
//    fileprivate let collections: Collections
//    fileprivate let contentForData: ContentForData
//    fileprivate let scrollDirection: ScrollDirection
//    fileprivate let contentSize: ContentSize
//    fileprivate let itemSpacing: ItemSpacing
//    fileprivate let rawCustomize: RawCustomize?
    
    @Binding var collections: Collections
    fileprivate let contentForData: ContentForData
    fileprivate let scrollDirection: ScrollDirection
    fileprivate let contentSize: ContentSize
    fileprivate let itemSpacing: ItemSpacing
    fileprivate let rawCustomize: RawCustomize?
    fileprivate let onDisplayItem: DataAction?
    fileprivate let onEndDisplayItem: DataAction?
    
    init(
        collections: Binding<Collections>,
        scrollDirection: ScrollDirection = .vertical,
        contentSize: ContentSize,
        itemSpacing: ItemSpacing = ItemSpacing(mainAxisSpacing: 0, crossAxisSpacing: 0),
        rawCustomize: RawCustomize? = nil,
        onDisplayItem: DataAction? = nil,
        onEndDisplayItem: DataAction? = nil,
        contentForData: @escaping ContentForData)
    {
        self._collections = collections
        self.scrollDirection = scrollDirection
        self.contentSize = contentSize
        self.itemSpacing = itemSpacing
        self.rawCustomize = rawCustomize
        self.contentForData = contentForData
        self.onDisplayItem = onDisplayItem
        self.onEndDisplayItem = onEndDisplayItem
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(view: self)
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        /// create UIViewController has UICollectionView  to handle UICollectiontionView
        let coordinator = context.coordinator
        let viewController = ViewController(coordinator: coordinator, scrollDirection: self.scrollDirection)
        coordinator.viewController = viewController
        self.rawCustomize?(viewController.collectionView)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        print("total image in device: \(collections.count)")
        context.coordinator.viewController?.collectionView.reloadData()
    }
}

extension CustomCollectionView {
    fileprivate static var cellReuseIdentifier: String {
        return "HostedCollectionViewCell"
    }
}

// MARK: ViewController
extension CustomCollectionView {
    
    final class ViewController : UIViewController {
        
        fileprivate let layout: UICollectionViewFlowLayout
        fileprivate let collectionView: UICollectionView
        
        /// config datasource, delegate for collectionview
        /// register cell item for uicollectionview
        init(coordinator: Coordinator, scrollDirection: ScrollDirection) {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = scrollDirection
            self.layout = layout
            
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = nil
            collectionView.register(HostedCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
            collectionView.dataSource = coordinator
            collectionView.delegate = coordinator
            self.collectionView = collectionView
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("In no way is this class related to an interface builder file.")
        }
        
        override func loadView() {
            self.view = self.collectionView
        }
    }
}

// MARK: Coordinator
extension CustomCollectionView {
    final class Coordinator: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
        
        fileprivate var view: CustomCollectionView
        fileprivate var viewController: ViewController?
        
        init(view: CustomCollectionView, viewController: ViewController? = nil) {
            self.view = view
            self.viewController = viewController
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            self.view.collections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            /// create cell as HostedCollectionViewCell
            /// get data at indexPath
            /// get content of item
            /// add content to cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! HostedCollectionViewCell
            let data = self.view.collections[indexPath.item]
            let content = self.view.contentForData(data)
            cell.provide(content)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            /// attach cell item when show
            let cell = cell as! HostedCollectionViewCell
            cell.attach(to: self.viewController!)
            let data = self.view.collections[indexPath.item]
            self.view.onDisplayItem?(data)
        }
        
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            /// detach cell item when hidden
            let cell = cell as! HostedCollectionViewCell
            cell.detach()
            if indexPath.item < self.view.collections.count {
                let data = self.view.collections[indexPath.item]
                self.view.onEndDisplayItem?(data)
            }
            
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
                switch self.view.scrollDirection {
                case .horizontal:
                    return CGSize(width: mainAxisLength, height: collectionView.bounds.height)
                case .vertical:
                    fallthrough
                @unknown default:
                    return CGSize(width: collectionView.bounds.width, height: mainAxisLength)
                }
            case .custom(let customSizeForData):
                let data = self.view.collections[indexPath.item]
                return customSizeForData(collectionView, collectionViewLayout, data)
            }
        }
        
        //        spacing in main axis
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return self.view.itemSpacing.mainAxisSpacing
        }
        
        //        spacing in cross axis
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return self.view.itemSpacing.crossAxisSpacing
        }
        
    }
}

// MARK: HostedCollectionViewCell
private extension CustomCollectionView {
    
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
