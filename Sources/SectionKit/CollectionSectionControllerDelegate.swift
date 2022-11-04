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
    ///
    /// The section controller calls this method when the user tries to select an item in the
    /// section controller. It does not call this method when you programatically set the
    /// selection.
    ///
    /// If you do not implement this method, the default implementation returns `true`.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller asking the caller.
    ///   - indexPath: The index path of the item to be selected.
    ///
    /// - Returns: `true` if the item should be selected or `false` otherwise.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool
    
    /// Tells the delegate that the item at the specified index path was selected.
    ///
    /// The section controller calls this method when the user successfully selects an item in the
    /// section controller. It does not call this method when you programatically set the selection.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - indexPath: The index path of the selected item.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didSelectItemAt indexPath: IndexPath
    )
    
    /// Asks the delegate if the specified item should be deselected.
    ///
    /// The section controller calls this method when the user tries to deselect an item in the
    /// section controller. It does not call this method when you programatically set the
    /// selection.
    ///
    /// If you do not implement this method, the default implementation returns `true`.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller asking the caller.
    ///   - indexPath: The index path of the item to be deselected.
    ///
    /// - Returns: `true` if the item should be deselected or `false` otherwise.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldDeselectItemAt indexPath: IndexPath
    ) -> Bool
    
    /// Tells the delegate that the item at the specified path was deselected.
    ///
    /// The section controller calls this method when the user successfully deselects an item in the
    /// section controller. It does not call this method when you programatically set the selection.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - indexPath: The index path of the deselected item.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didDeselectItemAt indexPath: IndexPath
    )
    
    /// Asks the delegate whether the user can select multiple items using a two-finger pan gesture in
    /// a section controller.
    ///
    /// When the system recognizes a two-finger pan gesture, it calls this method it sets
    /// ``CollectionSectionController/isEditingCollection`` to `true`. If you return
    /// `true` from this method, the user can select multiple items using a two-finger pan gesture.
    ///
    /// Users can select multiple items using the two-finger pan gesture on section controllers that scroll
    /// either horizontally or verically, but not both. Section controllers that scroll in both directions won't
    /// recognize the gesture or call this method.
    ///
    /// If you do not implement this method, the default implementation returns `false`.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller asking the caller.
    ///   - indexPath: The index path of the item that the user touched to start the two-finger
    ///   pan gesture.
    ///
    /// - Returns: `true` to allow the user to select multiple items using a two-finger pan gesture;
    /// otherwise, `false` to disable the behavior.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldBeginMultipleSelectionInterationAt indexPath: IndexPath
    ) -> Bool
    
    /// Tells the delegate when the user starts using a two-finger pan gesture to select multiple items in
    /// a section controller.
    ///
    /// Your implementation of this method is a good place to indicate, in the app's user interface, that the
    /// user is selecting multiple items; for example, you could replace an Edit or Select button with a Done
    /// button.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - indexPath: The index path of the item that the user touched to start the two-finger
    ///   pan gesture.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didBeginMultipleSelectionInterationAt indexPath: IndexPath
    )
    
    /// Tells the delegate when the user stops using a two-finger pan gesture to select multiple items in
    /// a section controller.
    ///
    /// The sectopm controller calls this method after the user lifts their finger from the device.
    ///
    /// > Important: This method is called for the delegates of all section providers.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    func collectionSectionControllerDidEndMultipleSelectionInteration(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>
    )
    
    /// Asks the delegate if the item should be highlighted during tracking.
    ///
    /// As touch events arrive, the section controller highlights items in anticipation of the user
    /// selecting them. As it processes those touch events, the section controller calls this
    /// method to ask your delegate if a given cell should be highlighted. It calls this method
    /// only in response to user interactions and does not call it if you programmatically set
    /// the highlight on a cell.
    ///
    /// If you return `false` in your implementation, the cell does not get highlighted and the
    /// system bypasses the entire selection process. That is, the system does not call
    /// ``collectionSectionController(_:shouldSelectItemAt:)-8kff0`` or
    /// any other selection-related methods. If you return `true`, `isHighlighted` is set
    /// to `true`, ``collectionSectionController(_:didHighlightItemAt:)-14g93``
    /// is called, and the system begins the selection process.
    ///
    /// If you do not implement this method, the default implementation returns `true`.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller asking the caller.
    ///   - indexPath: The index path of the item to be highlighted.
    ///
    /// - Returns: `true` if the item should be highlighted or `false` otherwise.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldHighlightItemAt indexPath: IndexPath
    ) -> Bool
    
    /// Tells the delegate that the item at the specified index path was highlighted.
    ///
    /// The section controller calls this method only in response to user interactions and does not
    /// call it if you programmatically set the highlighting on a cell.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - indexPath: The index path of the item that was highlighted.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didHighlightItemAt indexPath: IndexPath
    )
    
    /// Tells the delegate that the highlight was removed from the item at the specified index path.
    ///
    /// The section controller calls this method only in response to user interactions and does not
    /// call it if you programmatically set the highlighting on a cell.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - indexPath: The index path of the item that was unhighlighted.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didUnhighlightItemAt indexPath: IndexPath
    )
    
    /// Tells the delegate that the specified cell is about to be displayed in the section controller.
    ///
    /// The section controller calls this method before adding a cell to its content. Use this method
    /// to detect cell additions, as opposed to monitoring the cell itself to see when it appears.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the item that the cell represents.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    )
    
    /// Tells the delegate that the specified supplementary view is about to be displayed in the
    /// section controller.
    ///
    /// The section controller calls this method before adding a supplementary view to its content.
    /// Use this method to detect view additions, as opposed to monitoring the view itself to see
    /// when it appears.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - view: The view object being added.
    ///   - elementKind: The type of the supplementary view. This string is defined by
    ///   the layout that presents this view.
    ///   - indexPath: The index path of the item that the supplementary view represents.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    )
    
    /// Tells the delegate that the specified cell was removed from the section controller.
    ///
    /// The section controller calls this method after removing a cell from its content. Use this
    /// method to detect when a cell is removed from a section controller, as opposed to
    /// monitoring the cell itself to see when it disappears.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - cell: The cell object that was removed.
    ///   - indexPath: The index path of the item that the cell represented.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    )
    
    /// Tells the delegate that the specified supplementary view was removed from the section controller.
    ///
    /// The section controller calls this method after removing a view from its content. Use this
    /// method to detect when a view is removed from a section controller, as opposed to
    /// monitoring the view itself to see when it disappears.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - view: The view object that was removed.
    ///   - elementKind: The type of the supplementary view. This string is defined
    ///   by the layout that presents the view.
    ///   - indexPath: The index path of the item that the view represented.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        didEndDisplayingSupplementaryView view: UICollectionReusableView,
        forElementOfKind elementKind: String,
        at indexPath: IndexPath
    )
    
    // TODO: Handling layout updates is missing. Probably good?
    
    /// Informs the delegate when a context menu will appear.
    ///
    /// > Important: This method only gets whenever a context menu will appear, regardless
    /// of which section provider's item was the target of the context menu.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - configuration: The configuration of the menu that will be displayed.
    ///   - animator: The animations to run alongside the appearance transition.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willDisplayContextMenu configuration: UIContextMenuConfiguration,
        with animator: UIContextMenuInteractionAnimating?
    )
    
    /// Informs the delegate when a context menu will disappear.
    ///
    /// > Important: This method only gets whenever a context menu will end, regardless
    /// of which section provider's item was the target of the context menu.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - configuration: The ending configuration.
    ///   - animator: The animations to run alongside the disappearance transition.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
        with animator: UIContextMenuInteractionAnimating?
    )
    
    /// Informs the delegate when a user triggers a commit by tapping the preview.
    ///
    /// > Important: This method only gets whenever a context menu will appear, regardless
    /// of which section provider's item was the target of the context menu.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - configuration: The configuration of the menu being displayed.
    ///   - animator: The animations to run alongside the commit transition.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    )
    
    /// Asks the delegate for a context-menu configuration for the items at the specified index paths.
    ///
    /// The system calls this method when a user invokes a context menu from the section controller.
    /// Implement this method to build a `UIContextMenuConfiguration` according to the
    /// index paths the system passes to this method.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - indexPaths: An array of index paths corresponding to the items the menu acts on. This
    ///   array will never be empty. An array with multiple index paths indicates that a user is invoking
    ///   the menu on an item in a multiple selection. All index paths are guaranteed to be of a single
    ///   section provider.
    ///   - point: The location of the interaction in the section controller's collection view coordinate
    ///   space.
    ///
    /// - Returns: A contextual menu configuration object describing the menu to present. Returning
    /// `nil` prevents the interaction from beginning. Returning an empty configuration causes the
    /// interaction to begin, and then end with a cancellation effect. You can use this cancellation effect to
    /// indicate to users that it's possible to present a menu from this element, but that there aren't any
    /// actions currently available.
    @available(iOS 16, *)
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
    ///
    /// The system calls this method when a context menu interaction begins. Implement this method
    /// to override the default highlight preview that the collection view generates for the item at
    /// `indexPath`.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - configuration: The configuration of the menu to present if the interation proceeds.
    ///   - indexPath: The index path of the item where the interaction occurs.
    ///
    /// - Returns: A targeted preview object corresponding to the item at the index path to use
    /// during the menu's highlight and presentation animation.
    @available(iOS 16, *)
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview?
    
    /// Asks the delegate for a preview of the item at the specified index path when a context-menu
    /// interaction ends.
    ///
    /// The system calls this method when a context menu dismisses from the section controller.
    /// Implement this method to override the default dismissal preview that the collection view
    /// generates for the item at `indexPath`.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - configuration: The configuration of the menu to dismiss.
    ///   - indexPath: The index path of the item where the menu dismissal occurs.
    ///
    /// - Returns: A targeted preview object corresponding to the item at the index path to use
    /// during the menu's dismissal animation.
    @available(iOS 16, *)
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        dismissalPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview?
    
    // TODO: Focus is missing
    
    /// Determines whether the specified item is editable.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// If you do not implement this method, the default implementation returns `true`.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - indexPath: The index path of the item in the section controller.
    ///
    /// - Returns: `true` if the item is editable, `false` if it's not.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        canEditItemAt indexPath: IndexPath
    ) -> Bool
    
    /// Asks the delegate whether to perform a primary action for the cell at the
    /// specified index path.
    ///
    /// Primary actions allow you to distinguish between a disting user action and a change in
    /// selection (like a focus change or other indirect selection change). A primary action occurs
    /// when a user selects a single cell without extending an existing selection.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// If you do not implement this method, the default implementation returns `false`.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - indexPath: The index path of the item in the section controller.
    ///
    /// - Returns: `true` if the primary action can be performed; otherwise, `false`.
    @available(iOS 16, *)
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        canPerformPrimaryActionForItemAt indexPath: IndexPath
    ) -> Bool
    
    /// Tells the delegate to perform the primary action for the cell at the specified index path.
    ///
    /// Primary actions allow you to distinguish between a disting user action and a change in
    /// selection (like a focus change or other indirect selection change). A primary action occurs
    /// when a user selects a single cell without extending an existing selection. This method is
    /// called after ``collectionSectionController(_:shouldSelectItemAt:)-5uwy9``
    /// and ``collectionSectionController(_:didSelectItemAt:)-6u0gx``,
    /// regardless of whether the cell selection state changes.
    /// Use `collectionSectionController(_:didSelectItemAt:)` to update the
    /// state of the current view controller (like its button, title, and so on), and use this method
    /// for actions like navigation or showing another split view column.
    ///
    /// If `collectionSectionController(_:shouldSelectItemAt:)` returns `true`
    /// to allow selection for the cell at `indexPath`, only the cell has selection when the
    /// system calls this method. If `collectionSectionController(_:shouldSelectItemAt:)`
    /// returns `false`, the system preserve the existing cell selection in the section controller.
    /// You can use this behavior to perform primary actions on nonselectable, button-style cells
    /// without changing the selection.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - indexPath: The index path of the item in the section controller.
    @available(iOS 16, *)
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        performPrimaryActionForItemAt indexPath: IndexPath
    )
    
    /// Returns a scene activation configuration that allows the cell to expand into a new scene.
    ///
    /// A `UIWindowScene.ActivationConfiguration` object that facilitates exapanding
    /// the cell into a new scene. Return `nil` to prevent the interaction from starting.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - indexPath: The index path of the item with which the user is interacting.
    ///   - point: The location of the interaction in the section controller's collection
    ///   view coordinate space.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        sceneActivationConfigurationForItemAt indexPath: IndexPath,
        with point: CGPoint
    ) -> UIWindowScene.ActivationConfiguration?
    
    /// Determines whether the spring-loading interaction effect is displayed for the specified item.
    ///
    /// If you do not implement this method, the default implementation returns `false`.
    ///
    /// > Important: This method only gets called for a delegate associated with a section provider
    /// if the item is associated with the section provider. In addition, the index path is always relative
    /// to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - indexPath: The index path of the item for which the spring-loading behavior applies.
    ///   - context: A context object containing information about the item and view on which to
    ///   display the spring-loading interaction.
    ///
    /// - Returns: `true` to apply the spring-loading behavior for the item or `false` to
    /// suppress the behavior altogether.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        shouldSpringLoadItemAt indexPath: IndexPath
    ) -> Bool
    
    // MARK: Scroll View Delegate Methods
    
    /// Tells the delegate when the user scrolls the content view within the scroll view.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - scrollView: The scrollView in which the action occured.
    func collectionSectionControllerDidScroll(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate when the scroll view is about to start scrolling the content.
    ///
    /// The delegate might not receive this message until dragging has occurred over
    /// a small distance.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - scrollView: The scrollView in which the action will occur.
    func collectionSectionControllerWillBeginDragging(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate when the user finishes scrolling the content.
    ///
    /// Your application can change the value of the `targetContentOffset` parameter
    /// to adjust whether the `scrollView` finishes its scrolling animation.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - velocity: The velocity of the scroll view (in points per millisecond) at the moment
    ///   the touch was released.
    ///   - targetContentOffset: The expected offset when the scrolling action decelerates
    ///   to a stop.
    ///   - scrollView: The scrollView in which the action is occuring.
    func collectionSectionControllerWillEndDragging(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate when dragging ended in the scroll view.
    ///
    /// Your application can change the value of the `targetContentOffset` parameter
    /// to adjust whether the `scrollView` finishes its scrolling animation.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - decelerate: `true` if the scrolling animation will continue, but decelerate, after a
    ///   touch-up gestures during a dragging operation. If the value is `false`, scrolling stops
    ///   immediately upon touch-up.
    ///   - scrollView: The scrollView in which the action occured.
    func collectionSectionControllerDidEndDragging(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        willDecelerate delerate: Bool,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate that the scroll view scrolled to the top of the content.
    ///
    /// The section controller sends this message when it finishes scrolling to the top of the content.
    /// It might call it immediately if the top of the content is already shown. For the scroll-to-top
    /// feature (a tap on the status bar) to be effective, the `scrollsToTop` property in the
    /// `UIScrollView` must be set to `true`.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - scrollView: The scrollView in which the action occured.
    func collectionSectionControllerDidScrollToTop(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate that the scroll view is starting to decelerate the scrolling
    /// movement.
    ///
    /// The section controller calls this method as the user's finger touches up and as it's moving
    /// during a scrolling operation; the scroll view continues to move a short distance afterwards.
    /// The `isDecelerating` property of `UIScrollView` controls deceleration.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - scrollView: The scrollView in which the action will occur.
    func collectionSectionControllerWillBeginDecelerating(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate that the scroll view ended decelerating the scrolling movement.
    ///
    /// The section controller calls this method when the scrolling movement comes to a halt.
    /// The `isDecelerating` property of `UIScrollView` controls deceleration.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - scrollView: The scrollView in which the action occured.
    func collectionSectionControllerDidEndDecelerating(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
    
    // TODO: Zoom Unsupported
    
    /// Tells the delegate when a scrolling animation in the scroll view concludes.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - scrollView: The scrollView in which the action occured.
    func collectionSectionControllerDidEndScrollingAnimation(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        in scrollView: UIScrollView
    )
    
    /// Tells the delegate when the scroll view’s inset values change.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller sending the message.
    ///   - scrollView: The scrollView in which the action occured.
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
    ) -> Bool { return false }
    
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
    ) -> Bool { return false }
    
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
