//
//  CollectionSectionControllerDelegate.swift
//  
//
//  Created by Bryan Morfe on 10/22/22.
//

import UIKit

/// The methods adopted by the object you use to manage user interactions with the items in a section controller
/// provided by a section provider.
///
/// This delegate contains methods similar to that of a `UICollectionViewDelegate` and `UIScrollViewDelegate`,
/// however, only methods that pertain to specific section providers are sent. In addition, the section controller determines
/// which delegate a message should be sent to depending on the section provider that owns the resources in question.
/// For example, if an item is selected, only the delegate for the section provider that owns the item in informed of the message.
///
/// > Important: All index paths are relative to the section provider that own the item and section for said index path. That is,
/// it is not valid to use that index path with the collection view object or data source object. Instead, a section provider
/// must only use the methods in the section controller that is sending the message.
public protocol CollectionSectionControllerDelegate<SectionIdentifierType, ItemIdentifierType> : AnyObject {
    
    /// A type representing the identifier for a section in a diffable data source snapshot.
    associatedtype SectionIdentifierType : Hashable, Sendable
    
    /// A type representing the identifier for an item in a diffable data source snapshot.
    associatedtype ItemIdentifierType : Hashable, Sendable
    
    // MARK: Collection View Delegate Methods
    
    /// Asks the delegate if the specified item should be selected.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool
    
    /// Tells the delegate that the item at the specified index path was selected.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didSelectItemAt indexPath: IndexPath
    )
    
    /// Asks the delegate if the specified item should be deselected.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldDeselectItemAt indexPath: IndexPath
    ) -> Bool
    
    /// Tells the delegate that the item at the specified path was deselected.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didDeselectItemAt indexPath: IndexPath
    )
    
    /// Asks the delegate whether the user can select multiple items using a two-finger pan gesture in
    /// a section controller.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldBeginMultipleSelectionInterationAt indexPath: IndexPath
    ) -> Bool
    
    /// Tells the delegate when the user starts using a two-finger pan gesture to select multiple items in
    /// a section controller.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didBeginMultipleSelectionInterationAt indexPath: IndexPath
    )
    
    /// Tells the delegate when the user stops using a two-finger pan gesture to select multiple items in
    /// a section controller.
    func collectionSectionControllerDidEndMultipleSelectionInteration(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>
    )
    
    /// Asks the delegate if the item should be highlighted during tracking.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldHighlightItemAt indexPath: IndexPath
    ) -> Bool
    
    /// Tells the delegate that the item at the specified index path was highlighted.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didHighlightItemAt indexPath: IndexPath
    )
    
    /// Tells the delegate that the highlight was removed from the item at the specified index path.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didUnhighlightItemAt indexPath: IndexPath
    )
    
    /// Tells the delegate that the specified cell is about to be displayed in the section controller.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    )
    
    /// Tells the delegate that the specified supplementary view is about to be displayed in the
    /// section controller.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    )
    
    /// Tells the delegate that the specified cell was removed from the section controller.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    )
    
    /// Tells the delegate that the specified supplementary view was removed from the section controller.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didEndDisplayingSupplementaryView view: UICollectionReusableView,
        forElementOfKind elementKind: String,
        at indexPath: IndexPath
    )
    
    // TODO: Handling layout updates is missing. Probably good?
    
    /// Informs the delegate when a context menu will appear.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willDisplayContextMenu configuration: UIContextMenuConfiguration,
        with animator: UIContextMenuInteractionAnimating?
    )
    
    /// Informs the delegate when a context menu will disappear.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
        with animator: UIContextMenuInteractionAnimating?
    )
    
    /// Informs the delegate when a user triggers a commit by tapping the preview.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    )
    
    @available(iOS 16, *)
    /// Asks the delegate for a context-menu configuration for the items at the specified index paths.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration?
    
    /// Returns a context menu configuration for the item at a point.
    @available(iOS, deprecated: 16.0)
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration?
    
    /// Asks the delegate for a preview of the item at the specified index path when a context-menu
    /// interaction begins.
    @available(iOS 16, *)
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview?
    
    /// Asks the delegate for a preview of the item at the specified index path when a context-menu
    /// interaction ends.
    @available(iOS 16, *)
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        dismissalPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview?
    
    // TODO: Focus is missing
    
    /// Determines whether the specified item is editable.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        canEditItemAt indexPath: IndexPath
    ) -> Bool
    
    @available(iOS 16, *)
    /// Asks the delegate whether to perform a primary action for the cell at the
    /// specified index path.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        canPerformPrimaryActionForItemAt indexPath: IndexPath
    ) -> Bool
    
    @available(iOS 16, *)
    /// Tells the delegate to perform the primary action for the cell at the specified index path.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        performPrimaryActionForItemAt indexPath: IndexPath
    )
    
    /// Returns a scene activation configuration that allows the cell to expand into a new scene.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        sceneActivationConfigurationForItemAt indexPath: IndexPath,
        with point: CGPoint
    ) -> UIWindowScene.ActivationConfiguration?
    
    /// Determines whether the spring-loading interaction effect is displayed for the specified item.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldSpringLoadItemAt indexPath: IndexPath
    ) -> Bool
    
    // MARK: Scroll View Delegate Methods
    
    /// Tells the delegate when the user scrolls the content view within the scroll view.
    func collectionSectionControllerDidScroll(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate when the scroll view is about to start scrolling the content.
    func collectionSectionControllerWillBeginDragging(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate when the user finishes scrolling the content.
    func collectionSectionControllerWillEndDragging(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate when dragging ended in the scroll view.
    func collectionSectionControllerDidEndDragging(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willDecelerate delerate: Bool,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate that the scroll view scrolled to the top of the content.
    func collectionSectionControllerDidScrollToTop(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate that the scroll view is starting to decelerate the scrolling
    /// movement.
    func collectionSectionControllerWillBeginDecelerating(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate that the scroll view ended decelerating the scrolling movement.
    func collectionSectionControllerDidEndDecelerating(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
    
    // TODO: Zoom Unsupported
    
    /// Tells the delegate when a scrolling animation in the scroll view concludes.
    func collectionSectionControllerDidEndScrollingAnimation(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate when the scroll view’s inset values change.
    func collectionSectionControllerDidChangeAdjustedContentInset(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
}

// MARK: Default implementations
public extension CollectionSectionControllerDelegate {
    // MARK: Collection View Delegate Methods
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool { return true }
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didSelectItemAt indexPath: IndexPath
    ) {}
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldDeselectItemAt indexPath: IndexPath
    ) -> Bool { return true }
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didDeselectItemAt indexPath: IndexPath
    ) {}
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldBeginMultipleSelectionInterationAt indexPath: IndexPath
    ) -> Bool { return true }
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didBeginMultipleSelectionInterationAt indexPath: IndexPath
    ) {}
    
    func collectionSectionControllerDidEndMultipleSelectionInteration(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>
    ) {}
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldHighlightItemAt indexPath: IndexPath
    ) -> Bool { return true }
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didHighlightItemAt indexPath: IndexPath
    ) {}
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didUnhighlightItemAt indexPath: IndexPath
    ) {}
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {}
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    ) {}
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {}
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didEndDisplayingSupplementaryView view: UICollectionReusableView,
        forElementOfKind elementKind: String,
        at indexPath: IndexPath
    ) {}
    
    // TODO: Hnadling layout updates is missing. Probably good?
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willDisplayContextMenu configuration: UIContextMenuConfiguration,
        with animator: UIContextMenuInteractionAnimating?
    ) {}
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
        with animator: UIContextMenuInteractionAnimating?
    ) {}
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {}
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? { return nil }
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? { return nil }
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? { return nil }
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        dismissalPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? { return nil }
    
    // TODO: Focus is missing
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        canEditItemAt indexPath: IndexPath
    ) -> Bool { return true }
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        canPerformPrimaryActionForItemAt indexPath: IndexPath
    ) -> Bool { return true }
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        performPrimaryActionForItemAt indexPath: IndexPath
    ) {}
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        sceneActivationConfigurationForItemAt indexPath: IndexPath,
        with point: CGPoint
    ) -> UIWindowScene.ActivationConfiguration? { return nil }
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldSpringLoadItemAt indexPath: IndexPath
    ) -> Bool { return true }
    
    // MARK: Scroll View Delegate Methods
    
    func collectionSectionControllerDidScroll(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    ) {}
    
    func collectionSectionControllerWillBeginDragging(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    ) {}
    
    func collectionSectionControllerWillEndDragging(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>,
        in scrollView: UIScrollView
    ) {}
    
    func collectionSectionControllerDidEndDragging(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willDecelerate delerate: Bool,
        in scrollView: UIScrollView
    ) {}
    
    func collectionSectionControllerDidScrollToTop(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    ) {}
    
    func collectionSectionControllerWillBeginDecelerating(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    ) {}
    
    func collectionSectionControllerDidEndDecelerating(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    ) {}
    
    // TODO: Zoom Unsupported
    
    func collectionSectionControllerDidEndScrollingAnimation(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    ) {}
    
    func collectionSectionControllerDidChangeAdjustedContentInset(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    ) {}
}
