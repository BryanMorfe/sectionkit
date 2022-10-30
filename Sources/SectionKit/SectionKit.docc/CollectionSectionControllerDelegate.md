# ``SectionKit/CollectionSectionControllerDelegate``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Topics

### Declaring Section Controller Delegate Topography

- ``SectionIdentifierType``
- ``ItemIdentifierType``

### Managing the Selected Cells

- ``collectionSectionController(_:shouldSelectItemAt:)-8kff0``
- ``collectionSectionController(_:didSelectItemAt:)-6u0gx``
- ``collectionSectionController(_:shouldDeselectItemAt:)-9wqi2``
- ``collectionSectionController(_:didDeselectItemAt:)-3kwij``
- ``collectionSectionController(_:shouldBeginMultipleSelectionInterationAt:)-4corw``
- ``collectionSectionController(_:didBeginMultipleSelectionInterationAt:)-k5ek``
- ``collectionSectionControllerDidEndMultipleSelectionInteration(_:)-3qx8a``

### Managing Cell Highlighting

- ``collectionSectionController(_:shouldHighlightItemAt:)-6y4fr``
- ``collectionSectionController(_:didHighlightItemAt:)-m38d``
- ``collectionSectionController(_:didUnhighlightItemAt:)-2rcld``

### Tracking the Addition and Removal of Views

- ``collectionSectionController(_:willDisplay:forItemAt:)-1euqd``
- ``collectionSectionController(_:willDisplaySupplementaryView:forElementKind:at:)-46fvo``
- ``collectionSectionController(_:didEndDisplaying:forItemAt:)-3gtg2``
- ``collectionSectionController(_:didEndDisplayingSupplementaryView:forElementOfKind:at:)-6qn14``

### Managing Context Menus

- ``collectionSectionController(_:willDisplayContextMenu:with:)-5rz8f``
- ``collectionSectionController(_:willEndContextMenuInteraction:with:)-201vz``
- ``collectionSectionController(_:willPerformPreviewActionForMenuWith:animator:)-7lpz4``
- ``collectionSectionController(_:contextMenuConfigurationForItemsAt:with:)-811i0``
- ``collectionSectionController(_:contextMenuConfiguration:highlightPreviewForItemAt:)-7p2m9``
- ``collectionSectionController(_:contextMenuConfiguration:dismissalPreviewForItemAt:)-5wpuy``

### Editing Items

- ``collectionSectionController(_:canEditItemAt:)-9fweb``

### Managing Actions for Cells

- ``collectionSectionController(_:canPerformPrimaryActionForItemAt:)-8ky0``
- ``collectionSectionController(_:performPrimaryActionForItemAt:)-29d2r``

### Handling Scene Transitions

- ``collectionSectionController(_:sceneActivationConfigurationForItemAt:with:)-21gmi``

### Controlling the Spring-Loading Behavior

- ``collectionSectionController(_:shouldSpringLoadItemAt:)-93jqb``

### Responding to Scrolling and Dragging

- ``collectionSectionControllerDidScroll(_:in:)-9jzr1``
- ``collectionSectionControllerWillBeginDragging(_:in:)-8yvfo``
- ``collectionSectionControllerWillEndDragging(_:withVelocity:targetContentOffset:in:)-78dbs``
- ``collectionSectionControllerDidEndDragging(_:willDecelerate:in:)-39e23``
- ``collectionSectionControllerDidScrollToTop(_:in:)-1rzz1``
- ``collectionSectionControllerWillBeginDecelerating(_:in:)-255qs``
- ``collectionSectionControllerDidEndDecelerating(_:in:)-6xbja``

### Responding to Scrolling Animations

- ``collectionSectionControllerDidEndScrollingAnimation(_:in:)-9eflj``

### Responding to Inset Changes

- ``collectionSectionControllerDidChangeAdjustedContentInset(_:in:)-3qva9``
