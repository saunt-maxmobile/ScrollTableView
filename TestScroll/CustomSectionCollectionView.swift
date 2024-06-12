//
//  CustomSectionCollectionView.swift
//  TestScroll
//
//  Created by MaxMobile Software on 12/6/24.
//

import Foundation
import SwiftUI
import UIKit

struct CustomSectionCollectionView<Sections, CellContent, HeaderContent>: UIViewControllerRepresentable
where Sections: RandomAccessCollection, Sections.Index == Int, Sections.Element: SectionData, CellContent: View, HeaderContent: View {
    
    typealias SectionData = Sections.Element
    typealias ItemData = Sections.Element.Item
    typealias ContentForItem = (ItemData) -> CellContent
    typealias ContentForHeader = (SectionData) -> HeaderContent
    typealias ScrollDirection = UICollectionView.ScrollDirection
    typealias SizeForItem = (ItemData) -> CGSize
    typealias CustomSizeForItem = (UICollectionView, UICollectionViewLayout, ItemData) -> CGSize
    typealias RawCustomize = (UICollectionView) -> Void
    typealias ItemAction = (ItemData) -> Void
    typealias SectionAction = (SectionData) -> Void
    
    enum ContentSize {
        case fixed(CGSize)
        case variable(SizeForItem)
        case crossAxisFilled(mainAxisLength: CGFloat)
        case custom(CustomSizeForItem)
    }
    
    struct ItemSpacing: Hashable {
        var mainAxisSpacing: CGFloat
        var crossAxisSpacing: CGFloat
    }
    
    @Binding var sections: Sections
    @Binding var selectedIndex: Int
    @Binding var selectSection: Bool
    fileprivate let contentForItem: ContentForItem
    fileprivate let contentForHeader: ContentForHeader
    fileprivate let scrollDirection: ScrollDirection
    fileprivate let contentSize: ContentSize
    fileprivate let itemSpacing: ItemSpacing
    fileprivate let sectionSpacing: CGFloat
    fileprivate let rawCustomize: RawCustomize?
    fileprivate let onDisplayItem: ItemAction?
    fileprivate let onEndDisplayItem: ItemAction?
    fileprivate let onShowSection: SectionAction?
    fileprivate let onHideSection: SectionAction?
    
    init(
        sections: Binding<Sections>,
        selectedIndex: Binding<Int>,
        selectSection: Binding<Bool>,
        scrollDirection: ScrollDirection = .vertical,
        contentSize: ContentSize,
        itemSpacing: ItemSpacing = ItemSpacing(mainAxisSpacing: 0, crossAxisSpacing: 0),
        sectionSpacing: CGFloat = 0,
        rawCustomize: RawCustomize? = nil,
        onDisplayItem: ItemAction? = nil,
        onEndDisplayItem: ItemAction? = nil,
        onShowSection: SectionAction? = nil,
        onHideSection: SectionAction? = nil,
        contentForItem: @escaping ContentForItem,
        contentForHeader: @escaping ContentForHeader)
    {
        self._sections = sections
        self._selectedIndex = selectedIndex
        self._selectSection = selectSection
        self.scrollDirection = scrollDirection
        self.contentSize = contentSize
        self.itemSpacing = itemSpacing
        self.sectionSpacing = sectionSpacing
        self.rawCustomize = rawCustomize
        self.contentForItem = contentForItem
        self.contentForHeader = contentForHeader
        self.onDisplayItem = onDisplayItem
        self.onEndDisplayItem = onEndDisplayItem
        self.onShowSection = onShowSection
        self.onHideSection = onHideSection
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(view: self)
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        let coordinator = context.coordinator
        let viewController = ViewController(coordinator: coordinator, scrollDirection: self.scrollDirection)
        coordinator.viewController = viewController
        self.rawCustomize?(viewController.collectionView)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        uiViewController.collectionView.reloadData()
        
        if selectSection {
            // Scroll to the selected index if it's different from the currently visible section
            let indexPath = IndexPath(item: 0, section: selectedIndex)
            if !uiViewController.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader).contains(indexPath) {
                uiViewController.collectionView.scrollToItem(at: indexPath, at: .init(rawValue: UInt(1)), animated: true)
            }
            selectSection = false
        }
    }
    
    fileprivate static var cellReuseIdentifier: String {
        return "HostedCollectionViewCell"
    }
    
    fileprivate static var headerReuseIdentifier: String {
        return "HostedCollectionViewHeader"
    }
    
    final class ViewController: UIViewController {
        
        fileprivate let layout: UICollectionViewFlowLayout
        fileprivate let collectionView: UICollectionView
        
        init(coordinator: Coordinator, scrollDirection: ScrollDirection) {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = scrollDirection
            self.layout = layout
            
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = nil
            collectionView.register(HostedCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
            collectionView.register(HostedCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
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
    
    final class Coordinator: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
        
        fileprivate var view: CustomSectionCollectionView
        fileprivate var viewController: ViewController?
        fileprivate var visibleSections: Set<Int> = []
        
        init(view: CustomSectionCollectionView, viewController: ViewController? = nil) {
            self.view = view
            self.viewController = viewController
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            self.view.sections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            self.view.sections[section].details.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! HostedCollectionViewCell
            let section = self.view.sections[indexPath.section]
            let item = section.details[indexPath.item]
            let content = self.view.contentForItem(item)
            cell.provide(content)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! HostedCollectionViewHeader
            let section = self.view.sections[indexPath.section]
            let content = self.view.contentForHeader(section)
            header.provide(content)
            return header
        }
        
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            let cell = cell as! HostedCollectionViewCell
            cell.attach(to: self.viewController!)
            let section = self.view.sections[indexPath.section]
            let item = section.details[indexPath.item]
            self.view.onDisplayItem?(item)
        }
        
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            let cell = cell as! HostedCollectionViewCell
            cell.detach()
            let section = self.view.sections[indexPath.section]
            let item = section.details[indexPath.item]
            self.view.onEndDisplayItem?(item)
        }
        
        func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            let sectionIndex = indexPath.section
            if !visibleSections.contains(sectionIndex) {
                visibleSections.insert(sectionIndex)
                let section = self.view.sections[sectionIndex]
                if !self.view.selectSection {
                    self.view.onShowSection?(section)
                }
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            let sectionIndex = indexPath.section
            if visibleSections.contains(sectionIndex) {
                visibleSections.remove(sectionIndex)
                let section = self.view.sections[sectionIndex]
                if !self.view.selectSection {
                    self.view.onHideSection?(section)
                }
                
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let section = self.view.sections[indexPath.section]
            let item = section.details[indexPath.item]
            switch self.view.contentSize {
            case .fixed(let size):
                return size
            case .variable(let sizeForItem):
                return sizeForItem(item)
            case .crossAxisFilled(let mainAxisLength):
                switch self.view.scrollDirection {
                case .horizontal:
                    return CGSize(width: mainAxisLength, height: collectionView.bounds.height)
                case .vertical:
                    fallthrough
                @unknown default:
                    return CGSize(width: collectionView.bounds.width, height: mainAxisLength)
                }
            case .custom(let customSizeForItem):
                return customSizeForItem(collectionView, collectionViewLayout, item)
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return self.view.itemSpacing.mainAxisSpacing
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return self.view.itemSpacing.crossAxisSpacing
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: self.view.sectionSpacing, left: 0, bottom: self.view.sectionSpacing, right: 0)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
    }
    
    final class HostedCollectionViewCell: UICollectionViewCell {
        
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
    
    final class HostedCollectionViewHeader: UICollectionReusableView {
        
        var viewController: UIHostingController<HeaderContent>?
        
        func provide(_ content: HeaderContent) {
            if let viewController = self.viewController {
                viewController.rootView = content
            } else {
                let hostingController = UIHostingController(rootView: content)
                hostingController.view.backgroundColor = nil
                self.viewController = hostingController
                self.addSubview(hostingController.view)
                
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                hostingController.view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                hostingController.view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                hostingController.view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                hostingController.view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            }
        }
    }
}
