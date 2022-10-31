//
//  CollectionSectionController.swift
//  CollectionViewArchitecture
//
//  Created by Bryan Morfe on 10/20/22.
//

import UIKit

/// A container controller for section providers. This object wraps a collection view using a compositional layout and
/// a diffable data source and receives section providers to layout views in a collection.
///
/// Section providers communicate with this object to handle operations normally carried out with a collection view,
/// diffable data source, or collection view compositional layout. Note, however, that section providers cannot modify
/// or query items owned by other section providers. In addition, section providers cannot modify properties or
/// behavior that affects other section providers, as that is decided by the section controller. For example, it is not
/// possible for a section provider to change the layout's scroll direction or change whether prefetching is enabled or
/// not. However, it is possible for a section provider to be a prefetching data source, and the controller will notify it
/// when items it owns need to be prefetched.
///
/// > Important: A section provider must never query or modify the collection view of the section controller. The
/// index paths it has access to are relative to its sections and won't be valid for the collection view. All methods
/// that are required for functionality that affects sections or items it owns are accessible through this controller's
/// methods.
///
/// A flow from a section provider can look like this:
///
/// ```swift
/// class MySectionProvider : CollectionSectionProvider<String, My.ID>
///     : CollectionSectionControllerDelegate<String, My.ID> {
///     ...
///     func didMove(toSectionController sectionController: CollectionSectionController<String, My.ID>) {
///         /// Add 'self' as delegate and prefetching data source
///         sectionController.addDelegate(self, sectionProvider: self)
///         sectionController.addPrefetchingDelegate(self, sectionProvider: self)
///
///         /// Build a snapshot
///         var snapshot = ...
///         ...
///         /// Similar methods to a diffable data source
///         sectionController.apply(snapshot, sectionProvider: self)
///     }
///
///     func collectionSectionController(
///         _ sectionController: CollectionSectionController<String, My.ID>,
///         didSelectItemAt indexPath: IndexPath
///     ) {
///         /// The index path is relative to this section provide, e.g. (0, 0)
///         /// represents the first item of the first section _for this object_.
///         /// Can query the section controller for the cell, for example.
///         let cell = sectionController.cellForItem(at: indexPath, sectionProvider: self)
///
///         /// Use the section controller to present view controllers
///         let viewController = ItemViewController()
///         viewController.item = cell?.item
///         sectionController.present(viewController, animated: true, completion: nil)
///     }
/// }
/// ```
///
/// > For more information, see <doc:ModularAppWithSectionKit>.
open class CollectionSectionController<SectionIdentifierType, ItemIdentifierType> : UIViewController, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching
    where SectionIdentifierType : Hashable,
          SectionIdentifierType : Sendable,
          ItemIdentifierType : Hashable,
          ItemIdentifierType : Sendable {
    
    // MARK: Configure Layout
    
    /// The scrolling direction of the collection view.
    open var scrollDirection: ScrollDirection { .vertical }
    
    /// The spacing between the sections in the collection view.
    open var interSectionSpacing: CGFloat { 0 }
    
    /// The boundary to reference when defining content insets.
    open var contentInsetReference: UIContentInsetsReference { .safeArea }
    
    /// An array of the supplementary items that are associated with the boundary edges of the entire layout,
    /// such as global headers and footers.
    open var boundarySupplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] { [] }
    
    /// A closure that creates and return the boundary supplementary views to use in the section controller.
    open var boundarySupplementaryViewProvider: UICollectionViewDiffableDataSource.SupplementaryViewProvider? { nil }
    
    /// The collection view that contains all the content in the controller.
    public var collectionView: UICollectionView {
        _collectionView
    }
    
    private lazy var _collectionView = collectionViewInit()
    
    private lazy var collectionViewLayout = collectionViewLayoutInit()
    private lazy var dataSource = dataSourceInit()
    
    private var sectionProviderContexts: [CollectionSectionProviderContext] = []
    private var sectionProviderToContext: [ObjectIdentifier : CollectionSectionProviderContext] = [:]

    /// Called after the controller's view is loaded into memory.
    ///
    /// This method will perform some preparation work for the section controller, such as configuring
    /// the collection view.
    ///
    /// > Important: In order for the controller to work properly, the super must always be called when
    /// overriding this method.
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(_collectionView)
        
        NSLayoutConstraint.activate([
            _collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            _collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            _collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            _collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    /// Creates a section controller with the specified section providers.
    public init(sectionProviders: [some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>]) {
        super.init(nibName: nil, bundle: nil)
        for sectionProvider in sectionProviders {
            self.addSectionProvider(sectionProvider)
        }
    }
    
    /// Creates a section controller object with data in an unarchiver.
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: CollectionViewDelegate
    
    // MARK: Managing the selected cells
    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        /// Selection is not allowed between sections belonging to multiple section providers
        guard let sectionProvider = sectionProvider(for: indexPath) else {
            return true
        }
        
        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
            let map = sectionProviderIDToRelativeIndexPathsMap(from: selectedIndexPaths)
            let keys = map.keys
            if keys.count != 1 || keys.first! != sectionProvider.id {
                return false
            }
        }
        
        guard let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return true
        }
        return context.delegate?.collectionSectionController(self, shouldSelectItemAt: indexPath) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return
        }
        context.delegate?.collectionSectionController(self, didSelectItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return true
        }
        return context.delegate?.collectionSectionController(self, shouldDeselectItemAt: indexPath) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return
        }
        context.delegate?.collectionSectionController(self, didDeselectItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return true
        }
        return context.delegate?.collectionSectionController(self, shouldBeginMultipleSelectionInterationAt: indexPath) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return
        }
        context.delegate?.collectionSectionController(self, didBeginMultipleSelectionInterationAt: indexPath)
    }
    
    open func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        for context in sectionProviderContexts {
            context.delegate?.collectionSectionControllerDidEndMultipleSelectionInteration(self)
        }
    }
    
    // MARK: Managing cell highlighting
    open func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return true
        }
        return context.delegate?.collectionSectionController(self, shouldHighlightItemAt: indexPath) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return
        }
        context.delegate?.collectionSectionController(self, didHighlightItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return
        }
        context.delegate?.collectionSectionController(self, didUnhighlightItemAt: indexPath)
    }
    
    // MARK: Tracking the addition and removal of views
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return
        }
        context.delegate?.collectionSectionController(self, willDisplay: cell, forItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return
        }
        context.delegate?.collectionSectionController(self, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return
        }
        context.delegate?.collectionSectionController(self, didEndDisplaying: cell, forItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return
        }
        context.delegate?.collectionSectionController(self, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        for context in sectionProviderContexts {
            context.delegate?.collectionSectionController(self, willDisplayContextMenu: configuration, with: animator)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        for context in sectionProviderContexts {
            context.delegate?.collectionSectionController(self, willEndContextMenuInteraction: configuration, with: animator)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        for context in sectionProviderContexts {
            context.delegate?.collectionSectionController(self, willPerformPreviewActionForMenuWith: configuration, animator: animator)
        }
    }
    
    @available(iOS 16, *)
    open func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first,
              let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return nil
        }
        return context.delegate?.collectionSectionController(self, contextMenuConfigurationForItemsAt: [indexPath], point: point)
    }
    
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    open func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return nil
        }
        return context.delegate?.collectionSectionController(self, contextMenuConfigurationForItemAt: indexPath, point: point)
    }
    
    @available(iOS 16, *)
    open func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return nil
        }
        return context.delegate?.collectionSectionController(self, contextMenuConfiguration: configuration, highlightPreviewForItemAt: indexPath)
    }
    
    @available(iOS 16, *)
    open func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return nil
        }
        return context.delegate?.collectionSectionController(self, contextMenuConfiguration: configuration, dismissalPreviewForItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return true
        }
        return context.delegate?.collectionSectionController(self, canEditItemAt: indexPath) ?? true
    }
    
    @available(iOS 16, *)
    open func collectionView(_ collectionView: UICollectionView, canPerformPrimaryActionForItemAt indexPath: IndexPath) -> Bool {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return true
        }
        return context.delegate?.collectionSectionController(self, canPerformPrimaryActionForItemAt: indexPath) ?? true
    }
    
    @available(iOS 16, *)
    open func collectionView(_ collectionView: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return
        }
        context.delegate?.collectionSectionController(self, performPrimaryActionForItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, sceneActivationConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIWindowScene.ActivationConfiguration? {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return nil
        }
        return context.delegate?.collectionSectionController(self, sceneActivationConfigurationForItemAt: indexPath, with: point)
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        guard let sectionProvider = sectionProvider(for: indexPath),
              let context = sectionProviderContext(for: sectionProvider),
              let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
            return true
        }
        return context.delegate?.collectionSectionController(self, shouldSpringLoadItemAt: indexPath) ?? true
    }
    
    // MARK: Collection View Prefetching Data Source
    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let map = sectionProviderIDToRelativeIndexPathsMap(from: indexPaths)
        
        for (id, indexPaths) in map {
            let context = sectionProviderToContext[id]
            context?.prefetchingDataSource?.collectionSectionController(self, prefetchItemsAt: indexPaths)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let map = sectionProviderIDToRelativeIndexPathsMap(from: indexPaths)
        
        for (id, indexPaths) in map {
            let context = sectionProviderToContext[id]
            context?.prefetchingDataSource?.collectionSectionController(self, prefetchItemsAt: indexPaths)
        }
    }
    
    // MARK: Scroll View Delegate Methods
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for context in sectionProviderContexts {
            context.delegate?.collectionSectionControllerDidScroll(self, in: scrollView)
        }
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for context in sectionProviderContexts {
            context.delegate?.collectionSectionControllerWillBeginDragging(self, in: scrollView)
        }
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        for context in sectionProviderContexts {
            context.delegate?.collectionSectionControllerWillEndDragging(self, withVelocity: velocity, targetContentOffset: targetContentOffset, in: scrollView)
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        for context in sectionProviderContexts {
            context.delegate?.collectionSectionControllerDidEndDragging(self, willDecelerate: decelerate, in: scrollView)
        }
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        for context in sectionProviderContexts {
            context.delegate?.collectionSectionControllerWillBeginDecelerating(self, in: scrollView)
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for context in sectionProviderContexts {
            context.delegate?.collectionSectionControllerDidEndDecelerating(self, in: scrollView)
        }
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        for context in sectionProviderContexts {
            context.delegate?.collectionSectionControllerDidEndScrollingAnimation(self, in: scrollView)
        }
    }
    
    open func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        for context in sectionProviderContexts {
            context.delegate?.collectionSectionControllerDidChangeAdjustedContentInset(self, in: scrollView)
        }
    }
}

// MARK: Initializers
private extension CollectionSectionController {
    func collectionViewInit() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        return collectionView
    }
    
    func collectionViewLayoutInit() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = scrollDirection
        configuration.interSectionSpacing = interSectionSpacing
        configuration.contentInsetsReference = contentInsetReference
        configuration.boundarySupplementaryItems = boundarySupplementaryItems
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { sectionIndex, layoutEnvironment in
                let sectionProvider = self.sectionProviderForSectionWithIndex(sectionIndex)
                if let sectionProvider, let offset = self.sectionOffset(for: sectionProvider) {
                    return sectionProvider.layoutSectionProvider(sectionIndex - offset, layoutEnvironment)
                } else {
                    return nil
                }
            },
            configuration: configuration)
        return layout
    }
    
    func dataSourceInit() -> DiffableDataSource {
        let dataSource = DiffableDataSource(collectionView: _collectionView) { collectionView, indexPath, itemIdentifier in
            guard let sectionProvider = self.sectionProvider(for: indexPath),
                  let relativeIndexPath = self.indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
                /// Should never happen
                return nil
            }

            return sectionProvider.cellProvider(self, relativeIndexPath, itemIdentifier)
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            if indexPath.count == 1 {
                /// This is a boundary supplementary item for the entire section controller, not any individual section provider.
                return self.boundarySupplementaryViewProvider?(collectionView, elementKind, indexPath)
            }
            
            guard let sectionProvider = self.sectionProvider(for: indexPath),
                  let relativeIndexPath = self.indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) else {
                /// Should never happen
                return nil
            }
            
            return sectionProvider.supplementaryViewProvider?(self, elementKind, relativeIndexPath)
        }
        
        return dataSource
    }
}

// MARK: CollectionSectionControllerDelegate
public extension CollectionSectionController {
    
    /// Adds a delegate for controller associated with the provided section provider.
    ///
    /// The delegate is associated with an existing section provider. When the controller
    /// needs to send a message to about a specific section provider, it will send the message
    /// to the provided delegate.
    ///
    /// - Parameters:
    ///   - delegate: The object that will delegate the controller on behalf of the section provider.
    ///   - sectionProvider: The section provider associated with the delegate.
    func addDelegate(
        _ delegate: some CollectionSectionControllerDelegate<SectionIdentifierType, ItemIdentifierType>,
        sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) {
        guard let context = sectionProviderContext(for: sectionProvider) else {
            // TODO: Throw error?
            return
        }
        
        context.delegate = delegate
    }
    
    /// Removes a delegate associated with the provided section provided.
    ///
    /// This method will remove the delegate for the controller associated with the section provider.
    /// If a delegate or section provider does not exist, this method fails gracefully.
    ///
    /// - Parameters:
    ///   - sectionProvider: The section provider for which an associated delegate is to be removed.
    func removeDelegate(forSectionProvider sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) {
        if let context = sectionProviderContext(for: sectionProvider) {
            context.delegate = nil
        }
    }
}

// MARK: CollectionSectionControllerDataSourcePrefetching
public extension CollectionSectionController {
    
    /// Adds a prefetching data source for controller associated with the provided section provider.
    ///
    /// The prefetching data source is associated with an existing section provider. When the controller
    /// needs to send a message to about a specific section provider, it will send the message
    /// to the provided prefetching data source.
    ///
    /// - Parameters:
    ///   - prefetchingDataSource: The object that will be the prefetching data source the controller on behalf of the section provider.
    ///   - sectionProvider: The section provider associated with the prefetching data source.
    func addPrefetchingDataSource(
        _ prefetchingDataSource: some CollectionSectionControllerDataSourcePrefetching<SectionIdentifierType, ItemIdentifierType>,
        sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) {
        guard let context = sectionProviderContext(for: sectionProvider) else {
            // TODO: Throw error?
            return
        }
        
        context.prefetchingDataSource = prefetchingDataSource
    }
    
    /// Removes a prefetching data source associated with the provided section provided.
    ///
    /// This method will remove the prefetching data source for the controller associated with the section provider.
    /// If a prefetching data source or section provider does not exist, this method fails gracefully.
    ///
    /// - Parameters:
    ///   - sectionProvider: The section provider for which an associated prefetching data source is to be removed.
    func removePrefetchingDataSource(forSectionProvider sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) {
        if let context = sectionProviderContext(for: sectionProvider) {
            context.prefetchingDataSource = nil
        }
    }
}

// MARK: Configure Decorator Views
public extension CollectionSectionController {
    
    /// Registers a class for use in creating decoration views for a collection view.
    func register(_ viewClass: AnyClass?, forDecorationViewOfKind elementKind: String) {
        collectionViewLayout.register(viewClass, forDecorationViewOfKind: elementKind)
    }
    
    /// Registers a nib file for use in creating decoration views for a collection view.
    func register(_ nib: UINib?, forDecorationViewOfKind elementKind: String) {
        collectionViewLayout.register(nib, forDecorationViewOfKind: elementKind)
    }
}

// MARK: Modifying Section Providers
public extension CollectionSectionController {
    
    /// Adds a section provider to the section controller.
    func addSectionProvider(_ sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) {
        sectionProvider.willMove(toSectionController: self)
        
        let context = CollectionSectionProviderContext(sectionProvider: sectionProvider)
        sectionProviderContexts.append(context)
        sectionProviderToContext[sectionProvider.id] = context
        
        sectionProvider.didMove(toSectionController: self)
    }
    
    /// Deletes a section provider and removes all associated sections, optionally animating the changes.
    func deleteSectionProvider(_ sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        guard let context = sectionProviderContext(for: sectionProvider) else {
            return
        }
        let snapshot = snapshotByRemovingSectionProvider(sectionProvider)
        sectionProviderContexts.removeAll(where: { $0.id == context.id })
        sectionProviderToContext.removeValue(forKey: sectionProvider.id)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
    
    /// Deletes a section provider and removes all associated sections by reloading the collection view.
    func deleteSectionProviderUsingReloadData(_ sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>, completion: (() -> Void)? = nil) {
        guard let context = sectionProviderContext(for: sectionProvider) else {
            return
        }
        let snapshot = snapshotByRemovingSectionProvider(sectionProvider)
        sectionProviderContexts.removeAll(where: { $0.id == context.id })
        sectionProviderToContext.removeValue(forKey: sectionProvider.id)
        dataSource.applySnapshotUsingReloadData(snapshot, completion: completion)
    }
    
    /// Deletes a section provider and removes all associated sections by reloading the collection view.
    func deleteSectionProviderUsingReloadData(_ sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) async {
        guard let context = sectionProviderContext(for: sectionProvider) else {
            return
        }
        let snapshot = snapshotByRemovingSectionProvider(sectionProvider)
        sectionProviderContexts.removeAll(where: { $0.id == context.id })
        sectionProviderToContext.removeValue(forKey: sectionProvider.id)
        await dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
}

// MARK: Container Controller Data
public extension CollectionSectionController {
    
    // MARK: Prefetching collection view cells and data
    
    /// A Boolean value that determines if prefetching is enabled for the collection view.
    var isPrefetchingEnabled: Bool {
        _collectionView.isPrefetchingEnabled
    }
    
    /// A Boolean value that indicates whether users can select items in the collection view.
    var allowsSelection: Bool {
        _collectionView.allowsSelection
    }
    
    /// A Boolean value that determines whether users can select more than one item in the collection view.
    var allowsMultipleSelection: Bool {
        _collectionView.allowsMultipleSelection
    }
    
    /// A Boolean value that determines whether users can select cells while the collection view is in editing mode.
    var allowsSelectionDuringEditing: Bool {
        _collectionView.allowsSelectionDuringEditing
    }
    
    /// A Boolean value that controls whether users can select more than one cell simultaneously in editing mode.
    var allowsMultipleSelectionDuringEditing: Bool {
        _collectionView.allowsMultipleSelectionDuringEditing
    }
    
    /// A Boolean value that triggers an automatic selection when focus moves to a cell.
    var selectionFollowFocus: Bool {
        _collectionView.selectionFollowsFocus
    }
    
    @available(iOS 16, *)
    /// The mode that the collection view uses for invalidating the size of self-sizing cells.
    var selfSizingInvalidation: UICollectionView.SelfSizingInvalidation {
        _collectionView.selfSizingInvalidation
    }
    
    // MARK: Getting the state of the collection view
    
    /// Returns the number of items for the specified section index associated with the section provider.
    func numberOfItems(inSection section: Int, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> Int? {
        guard let offset = sectionOffset(for: sectionProvider) else {
            return nil
        }
        return _collectionView.numberOfItems(inSection: section + offset)
    }
    
    /// Returns the number of sections displayed by the section controller for a section provider.
    func numberOfSections(forSectionProvider sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> Int? {
        guard let context = sectionProviderContext(for: sectionProvider) else {
            return nil
        }
        return context.numberOfSections
    }
    
    /// An array of visible cells currently displayed by the section controller that belong to the provided section provider.
    func visibleCells(forSectionProvider sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> [UICollectionViewCell] {
        var visibleCells = [UICollectionViewCell]()
        let allVisibleCells = collectionView.visibleCells
        
        for visibleCell in allVisibleCells {
            if let indexPath = collectionView.indexPath(for: visibleCell), let sectionProviderForIndexPath = sectionProviderForSectionWithIndex(indexPath.section), sectionProvider.id == sectionProviderForIndexPath.id {
                visibleCells.append(visibleCell)
            }
        }
        
        return visibleCells
    }
    
    /// Gets an array of the visible supplementary views of the specified kind associated with a section provider.
    func visibleSupplementaryViews(ofKind elementKind: String, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> [UICollectionReusableView] {
        var visibleSupplementaryViews = [UICollectionReusableView]()
        let indexPathsForVisibleSupplementaryViews = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: elementKind)
        
        for indexPathForVisibleSupplementaryView in indexPathsForVisibleSupplementaryViews {
            if let sectionProviderForIndexPath = sectionProviderForSectionWithIndex(indexPathForVisibleSupplementaryView.section), sectionProvider.id == sectionProviderForIndexPath.id, let supplementaryView = collectionView.supplementaryView(forElementKind: elementKind, at: indexPathForVisibleSupplementaryView) {
                visibleSupplementaryViews.append(supplementaryView)
            }
        }
        
        return visibleSupplementaryViews
    }
    
    /// Gets the layout information for the item at the specified index path for the provided section provider.
    func layoutAttributesForItem(at indexPath: IndexPath, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> UICollectionViewLayoutAttributes? {
        guard let indexPath = indexPathFromRelativeIndexPath(indexPath, sectionProvider: sectionProvider) else {
            return nil
        }
        return collectionView.layoutAttributesForItem(at: indexPath)
    }
    
    /// Gets the layout information for the specified supplementary view associated with the provided section provider.
    func layoutAttributesForSupplementaryElement(ofKind elementKind: String, at indexPath: IndexPath, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> UICollectionViewLayoutAttributes? {
        guard let indexPath = indexPathFromRelativeIndexPath(indexPath, sectionProvider: sectionProvider) else {
            return nil
        }
        return collectionView.layoutAttributesForSupplementaryElement(ofKind: elementKind, at: indexPath)
    }
    
    // TODO: Drag and Drop is not supported yet
    
    // MARK: Selecting Cells
    
    /// Returns the index paths for the selected items associated with the provided section provider.
    func indexPathsForSelectedItems(forSectionProvider sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> [IndexPath] {
        let indexPaths = collectionView.indexPathsForVisibleItems
        var indexPathsForSelectedItems = [IndexPath]()
        
        for indexPath in indexPaths {
            if let sectionProviderForIndexPath = sectionProviderForSectionWithIndex(indexPath.section), sectionProviderForIndexPath.id == sectionProvider.id, let indexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) {
                indexPathsForSelectedItems.append(indexPath)
            }
        }
        
        return indexPathsForSelectedItems
    }
    
    /// Gets the cell object at the index path you specify.
    func cellForItem(at indexPath: IndexPath, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> UICollectionViewCell? {
        guard let indexPath = indexPathFromRelativeIndexPath(indexPath, sectionProvider: sectionProvider) else {
            return nil
        }
        return collectionView.cellForItem(at: indexPath)
    }
    
    /// Gets the index path relative to the section provider for the specified cell.
    func indexPath(for cell: UICollectionViewCell, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> IndexPath? {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return nil
        }
        return indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath)
    }
    
    /// Gets the index paths of the visible items in the section controller for a section provider.
    func indexPathsForVisibleItems(forSectionProvider sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> [IndexPath]? {
        let indexPaths = collectionView.indexPathsForVisibleItems
        let map = sectionProviderIDToRelativeIndexPathsMap(from: indexPaths)
        return map[sectionProvider.id]
    }
    
    /// Gets the index paths of all visible supplementary views of the specified type in a section provider.
    func indexPathsForVisibleSupplementaryElements(ofKind elementKind: String, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> [IndexPath]? {
        let indexPaths = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: elementKind)
        let map = sectionProviderIDToRelativeIndexPathsMap(from: indexPaths)
        return map[sectionProvider.id]
    }
    
    /// Gets the supplementary view at the specified index path for a section provider.
    func supplementaryView(forElementKind elementKind: String, at indexPath: IndexPath, for sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> UICollectionReusableView? {
        guard let indexPath = indexPathFromRelativeIndexPath(indexPath, sectionProvider: sectionProvider) else {
            return nil
        }
        return collectionView.supplementaryView(forElementKind: elementKind, at: indexPath)
    }
    
    /// Selects an item at a specified index path relative to the section provider.
    func selectItem(at indexPath: IndexPath, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        if let indexPath = indexPathFromRelativeIndexPath(indexPath, sectionProvider: sectionProvider) {
            collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        }
    }
    
    /// Deselects the item at the specified index path relative to the section provider.
    func deselectItem(at indexPath: IndexPath, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>, animated: Bool) {
        if let indexPath = indexPathFromRelativeIndexPath(indexPath, sectionProvider: sectionProvider) {
            collectionView.deselectItem(at: indexPath, animated: animated)
        }
    }
    
    /// Dequeues a configured reusable cell object.
    func dequeueConfiguredReusableCell<Cell, Item>(
        using registration: UICollectionView.CellRegistration<Cell, Item>,
        for indexPath: IndexPath,
        item: Item?,
        sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>
    ) -> Cell where Cell : UICollectionViewCell {
        guard let indexPath = indexPathFromRelativeIndexPath(indexPath, sectionProvider: sectionProvider) else {
            // TODO: Throw an error instead
            return Cell()
        }
        return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
    }
    
    /// Registers a class for use in creating new collection view cells.
    func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    /// Registers a nib file for use in creating new collection view cells.
    func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    /// Dequeues a reusable cell object located by its identifier.
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> UICollectionViewCell {
        guard let indexPath = indexPathFromRelativeIndexPath(indexPath, sectionProvider: sectionProvider) else {
            // TODO: Throw an error instead
            return UICollectionViewCell()
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    /// Dequeues a configured reusable supplementary view object.
    func dequeueConfiguredReusableSupplementary<Supplementary>(
        using registration: UICollectionView.SupplementaryRegistration<Supplementary>,
        for indexPath: IndexPath,
        sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>
    ) -> Supplementary where Supplementary : UICollectionReusableView {
        guard let indexPath = indexPathFromRelativeIndexPath(indexPath, sectionProvider: sectionProvider) else {
            // TODO: Throw an error instead
            return Supplementary()
        }
        return collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
    }
    
    /// Registers a class for use in creating supplementary views for the collection view.
    func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind elementKind: String, withReuseIdentifier identifier: String) {
        collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)
    }
    
    /// Registers a nib file for use in creating supplementary views for the collection view.
    func register(_ nib: UINib?, forSupplementaryViewOfKind elementKind: String, withReuseIdentifier identifier: String) {
        collectionView.register(nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)
    }
    
    /// Dequeues a reusable supplementary view located by its identifier and kind.
    func dequeueReusableSupplementaryView(ofKind elementKind: String, withReuseIdentifier identifier: String, for indexPath: IndexPath, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> UICollectionReusableView {
        guard let indexPath = indexPathFromRelativeIndexPath(indexPath, sectionProvider: sectionProvider) else {
            // TODO: Throw an error instead
            return UICollectionReusableView()
        }
        return collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: identifier, for: indexPath)
    }
}

// MARK: Data Source Methods
public extension CollectionSectionController {
    /// Providing access to the snapshot is easier than implementing all of these methods as essentially a passthrough,
    /// however, there must be a way to ensure that any given section provider cannot modify the entire data source and
    /// thus interfere with the other section providers. In other words, some of these methods cannot be a passthrough
    /// but should have some coordination logic and know which part of the snapshot is owned by which section provider
    /// to leave the snapshot otherwise unmodified.
    
    // MARK: Identifying Items
    
    /// Returns an identifier for the item at the specified index path in the section controller for a section provider.
    func itemIdentifier(for indexPath: IndexPath, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> ItemIdentifierType? {
        guard let indexPath = indexPathFromRelativeIndexPath(indexPath, sectionProvider: sectionProvider) else {
            return nil
        }
        return dataSource.itemIdentifier(for: indexPath)
    }
    
    /// Returns an index path for the item with the specified identifier in the section controller for a section provider.
    func indexPath(for itemIdentifier: ItemIdentifierType, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> IndexPath? {
        guard let indexPath = dataSource.indexPath(for: itemIdentifier) else {
            return nil
        }
        return indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath)
    }
    
    // MARK: Identifying Sections
    
    /// Returns an identifier for the section at the index you specify in the section controller for a section provider.
    func sectionIdentifier(for index: Int, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> SectionIdentifierType? {
        guard let sectionOffset = sectionOffset(for: sectionProvider) else {
            return nil
        }
        return dataSource.sectionIdentifier(for: index + sectionOffset)
    }
    
    /// Returns an index for the section with the identifier you specify in the section controller for a section provider.
    func index(for sectionIdentifier: SectionIdentifierType, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> Int? {
        guard let index = dataSource.index(for: sectionIdentifier),
              let sectionOffset = sectionOffset(for: sectionProvider) else {
            return nil
        }
        return index - sectionOffset
    }
    
    // MARK: Updating Data
    
    /// Returns a representation of the current state of the data in the section controller for a section provider.
    func snapshotForSectionProvider(_ sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> DiffableDataSourceSnapshot {
        var snapshot = DiffableDataSourceSnapshot()
        let sections = sectionIdentifiers(for: sectionProvider)
        snapshot.appendSections(sections)
        for section in sections {
            let items = dataSource.snapshot().itemIdentifiers(inSection: section)
            snapshot.appendItems(items, toSection: section)
        }
        return snapshot
    }
    
    /// Updates the UI to reflect the state of the data in the snapshot, optionally animating the UI changes and
    /// executing a completion handler.
    func apply(_ snapshot: DiffableDataSourceSnapshot, animatingDifferences: Bool = true, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) {
        let completedSnapshot = snapshotByJoining(with: snapshot, for: sectionProvider)
        setNumberOfSections(for: sectionProvider, afterApplying: snapshot)
        dataSource.apply(completedSnapshot, animatingDifferences: animatingDifferences)
    }
    
    /// Updates the UI to reflect the state of the data in the snapshot, optionally animating the UI changes and
    /// executing a completion handler.
    func apply(_ snapshot: DiffableDataSourceSnapshot, animatingDifferences: Bool = true, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>, completion: (() -> Void)? = nil) {
        let completedSnapshot = snapshotByJoining(with: snapshot, for: sectionProvider)
        setNumberOfSections(for: sectionProvider, afterApplying: snapshot)
        dataSource.apply(completedSnapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
    
    /// Resets the UI to reflect the state of the data in the snapshot without computing a diff or animating the
    /// changes.
    func applySnapshotUsingReloadData(_ snapshot: DiffableDataSourceSnapshot, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) async {
        let completedSnapshot = snapshotByJoining(with: snapshot, for: sectionProvider)
        setNumberOfSections(for: sectionProvider, afterApplying: snapshot)
        await dataSource.applySnapshotUsingReloadData(completedSnapshot)
    }
    
    /// Resets the UI to reflect the state of the data in the snapshot without computing a diff or animating the
    /// changes, optionally executing a completion handler.
    func applySnapshotUsingReloadData(_ snapshot: DiffableDataSourceSnapshot, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>, completion: (() -> Void)? = nil) {
        let completedSnapshot = snapshotByJoining(with: snapshot, for: sectionProvider)
        setNumberOfSections(for: sectionProvider, afterApplying: completedSnapshot)
        dataSource.applySnapshotUsingReloadData(completedSnapshot, completion: completion)
    }
    
}

// MARK: Section Provider Identification
private extension CollectionSectionController {
    
    /// An object that encapsulates contextual information about a section provider, such as its number of sections,
    /// delegate, and prefetching data source.
    class CollectionSectionProviderContext : Identifiable, Hashable, Equatable {
        let sectionProvider: any CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>
        var numberOfSections: Int = 0
        weak var delegate: (any CollectionSectionControllerDelegate<SectionIdentifierType, ItemIdentifierType>)?
        weak var prefetchingDataSource: (any CollectionSectionControllerDataSourcePrefetching<SectionIdentifierType, ItemIdentifierType>)?
        
        init(sectionProvider: any CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>, numberOfSections: Int = 0) {
            self.sectionProvider = sectionProvider
            self.numberOfSections = numberOfSections
        }
        
        static func ==(lhs: CollectionSectionProviderContext, rhs: CollectionSectionProviderContext) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    /// Updates the number of sections for a section provider after applying a snapshot.
    ///
    /// - Parameters:
    ///   - sectionProvider: The section provider for which to update the number of sections.
    ///   - snapshot: The snapshot that will be applied.
    func setNumberOfSections(for sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>, afterApplying snapshot: DiffableDataSourceSnapshot) {
        guard let context = sectionProviderContext(for: sectionProvider) else {
            return
        }
        context.numberOfSections = snapshot.numberOfSections
    }
    
    /// Returns the context for a section provider.
    func sectionProviderContext(for sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> CollectionSectionProviderContext? {
        return sectionProviderToContext[sectionProvider.id]
    }
    
    /// Returns the section offset for a section provider.
    ///
    /// A section offset is the index of the first section for a given section provider. This offset
    /// can be used to determine the position of a section provider in the controller.
    ///
    /// - Parameters:
    ///   - sectionProvider: The section provider for which to compute its offset.
    func sectionOffset(for sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> Int? {
        guard let context = sectionProviderContext(for: sectionProvider) else {
            return nil
        }
        
        var offset = 0
        for sectionProviderContext in sectionProviderContexts {
            if sectionProviderContext == context {
                break
            }

            offset += sectionProviderContext.numberOfSections
        }
        return offset
    }
    
    /// Returns the section provider for an absolute index path.
    ///
    /// The index path is absolute, i.e., the real index path used by the data source and collection view.
    ///
    /// > Important: This method requires the absolute index path, i.e., an index path provided by the underlying
    /// collection view or data source.
    func sectionProvider(for indexPath: IndexPath) -> (any CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>)? {
        return sectionProviderForSectionWithIndex(indexPath.section)
    }
    
    /// Returns the section provider for a section identifier.
    func sectionProvider(for sectionIdentifier: SectionIdentifierType) -> (any CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>)? {
        guard let index = dataSource.snapshot().indexOfSection(sectionIdentifier) else {
            return nil
        }
        
        return sectionProviderForSectionWithIndex(index)
    }
    
    /// Returns the section provider that ows the section with a provided index.
    func sectionProviderForSectionWithIndex(_ index: Int) -> (any CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>)? {
        var offset = 0
        for sectionProviderContext in sectionProviderContexts {
            let maxSectionIndex = offset + sectionProviderContext.numberOfSections - 1
            if index <= maxSectionIndex {
                return sectionProviderContext.sectionProvider
            }
            offset += sectionProviderContext.numberOfSections
        }
        return nil
    }
    
    /// Returns the absolute index path for a provided index path relative to the provided section provider.
    ///
    /// - Parameters:
    ///   - indexPath: Index path relative to `sectionProvider`.
    ///   - sectionProvider: The section provider to reference.
    ///
    /// - Returns: Absolute index path for use in the collection view.
    func indexPathFromRelativeIndexPath(_ indexPath: IndexPath, sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> IndexPath? {
        guard let sectionOffset = sectionOffset(for: sectionProvider) else {
            return nil
        }
        return IndexPath(item: indexPath.item, section: indexPath.section + sectionOffset)
    }
    
    /// Returns the relative index for a section provider.
    ///
    /// - Parameters:
    ///   - sectionProvider: The section provider to reference.
    ///   - indexPath: The absolute index path.
    ///
    /// - Returns: The index path relative to the provided section provider.
    private func indexPathRelativeToSectionProvider(_ sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>, indexPath: IndexPath) -> IndexPath? {
        guard let sectionOffset = sectionOffset(for: sectionProvider) else {
            return nil
        }
        return IndexPath(item: indexPath.item, section: indexPath.section - sectionOffset)
    }
    
    /// Returns the index of a section provider.
    ///
    /// The index is the zero-based position in the array of section providers. If the section
    /// provider is not managed by the controller, this method returns `nil`.
    ///
    /// > A section provider `index` is different from a section provider `offset` in that the latter
    /// is the index of the first section that the provider owns, whereas the former does not count the
    /// number of sections in any preceding section providers.
    func index(for sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> Int? {
        return sectionProviderContexts.firstIndex(where: { $0.sectionProvider.id == sectionProvider.id } )
    }
    
    /// Returns all section identifiers for a section provider.
    func sectionIdentifiers(for sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> [SectionIdentifierType] {
        guard let context = sectionProviderContext(for: sectionProvider),
              let offset = sectionOffset(for: sectionProvider),
              context.numberOfSections > 0 else {
            return []
        }
        let snapshot = dataSource.snapshot()
        let rangeHigherBound = offset + context.numberOfSections - 1
        
        guard rangeHigherBound >= 0 && rangeHigherBound < snapshot.sectionIdentifiers.count else {
            return []
        }
        
        return Array(snapshot.sectionIdentifiers[offset...rangeHigherBound])
    }
    
    /// Returns a map of section provider ID to relative index paths given an array of absolute index paths.
    ///
    /// This method splits the absolute index paths by section provider, then converts to absolute index paths
    /// to be relative to the owner section providers. The resulting map looks something like this:
    /// ```
    ///   SectionProvider1.ID -> [IndexPathsRelativeToSectionProvider1],
    ///   SectionProvider2.ID -> [IndexPathsRelativeToSectionProvider2],
    ///   ...
    /// ```
    func sectionProviderIDToRelativeIndexPathsMap(from indexPaths: [IndexPath]) -> [ObjectIdentifier : [IndexPath]] {
        var map = [ObjectIdentifier : [IndexPath]]()
        for indexPath in indexPaths {
            if let sectionProvider = sectionProvider(for: indexPath),
               let relativeIndexPath = indexPathRelativeToSectionProvider(sectionProvider, indexPath: indexPath) {
                if map[sectionProvider.id] == nil {
                    map[sectionProvider.id] = []
                }
                map[sectionProvider.id]?.append(relativeIndexPath)
            }
        }
        return map
    }
    
    /// Returns a resulting snapshot after joining with the snapshot for a given section provider.
    ///
    /// This method replaces all section identifiers and their items for a specific section provider with those
    /// of the provided snapshot, if any. This operation guarantees the section provider section identifiers will
    /// be contiguous and will respect the order of all section providers in the controller.
    func snapshotByJoining(with snapshot: DiffableDataSourceSnapshot, for sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> DiffableDataSourceSnapshot {
        let sections = sectionIdentifiers(for: sectionProvider)
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteSections(sections)
        
        let newSnapshotSections = snapshot.sectionIdentifiers
        let sectionProviderIndex = index(for: sectionProvider)
        
        /// Insert sections in correct index
        if let sectionProviderIndex, sectionProviderIndex > 0 {
            let precedingSectionProviderContext = sectionProviderContexts[sectionProviderIndex - 1]
            if let precedingSection = self.sectionIdentifiers(for: precedingSectionProviderContext.sectionProvider).first {
                currentSnapshot.insertSections(newSnapshotSections, afterSection: precedingSection)
            } else {
                currentSnapshot.appendSections(newSnapshotSections)
            }
        } else {
            currentSnapshot.appendSections(newSnapshotSections)
        }
        
        for section in newSnapshotSections {
            let items = snapshot.itemIdentifiers(inSection: section)
            currentSnapshot.appendItems(items, toSection: section)
        }
        
        return currentSnapshot
    }
    
    /// Returns a snapshot resulting by removing all data associated with a section provider.
    func snapshotByRemovingSectionProvider(_ sectionProvider: some CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType>) -> DiffableDataSourceSnapshot {
        let sections = sectionIdentifiers(for: sectionProvider)
        var snapshot = dataSource.snapshot()
        snapshot.deleteSections(sections)
        return snapshot
    }
}

// MARK: Public typesaliases
public extension CollectionSectionController {
    
    /// The object you use to manage data and provide cells for a collection view.
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    
    /// A representation of the state of the data in a view at a specific point in time.
    typealias DiffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    
    /// A closure that configures and returns a cell for a section controller from its section provider.
    typealias CellProvider = (_ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>, _ indexPath: IndexPath, _ itemIdentifier: ItemIdentifierType) -> UICollectionViewCell?
    
    /// A closure that configures and returns a section controller’s supplementary view, such as a header or
    /// footer, from a section provider.
    typealias SupplementaryViewProvider = (_ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>, _ elementKind: String, _ indexPath: IndexPath) -> UICollectionReusableView?
    
    /// A closure that creates and returns each of the layout's sections.
    typealias SectionProvider = UICollectionViewCompositionalLayoutSectionProvider
    
    /// Constants that indicate the direction of scrolling for the layout.
    typealias ScrollDirection = UICollectionView.ScrollDirection
    
    /// Constants that indicate how to scroll an item into the visible portion of the collection view.
    typealias ScrollPosition = UICollectionView.ScrollPosition
}
