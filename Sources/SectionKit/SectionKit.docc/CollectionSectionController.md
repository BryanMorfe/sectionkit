# ``SectionKit/CollectionSectionController``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Topics

### Creating a Section Controller

- ``init(sectionProviders:)``
- ``init(coder:)``

### Responding to View Events

- ``viewDidLoad()``

### Modifying Section Providers

- ``addSectionProvider(_:)``
- ``deleteSectionProvider(_:animatingDifferences:completion:)``
- ``deleteSectionProviderUsingReloadData(_:)``
- ``deleteSectionProviderUsingReloadData(_:completion:)``

### Identifying Items for Section Providers

- ``itemIdentifier(for:sectionProvider:)``
- ``indexPath(for:sectionProvider:)-7mqtd``

### Identifying Sections for Section Providers

- ``sectionIdentifier(for:sectionProvider:)``
- ``index(for:sectionProvider:)``

### Updating Section Provider Data

- ``snapshotForSectionProvider(_:)``
- ``apply(_:animatingDifferences:sectionProvider:)``
- ``apply(_:animatingDifferences:sectionProvider:completion:)``
- ``applySnapshotUsingReloadData(_:sectionProvider:)``
- ``applySnapshotUsingReloadData(_:sectionProvider:completion:)``

### Prefetching Cells and Data for Section Providers

- ``isPrefetchingEnabled``
- ``addPrefetchingDataSource(_:sectionProvider:)``
- ``removePrefetchingDataSource(forSectionProvider:)``
- ``CollectionSectionControllerDataSourcePrefetching``

### Managing Interactions with Section Provider Content

- ``addDelegate(_:sectionProvider:)``
- ``removeDelegate(forSectionProvider:)``
- ``CollectionSectionControllerDelegate``

### Creating Cells for Section Providers

- ``dequeueConfiguredReusableCell(using:for:item:sectionProvider:)``
- ``register(_:forCellWithReuseIdentifier:)-7mthu``
- ``register(_:forCellWithReuseIdentifier:)-50v2u``
- ``dequeueReusableCell(withReuseIdentifier:for:sectionProvider:)``

### Creating Headers and Footers for Section Providers

- ``dequeueConfiguredReusableSupplementary(using:for:sectionProvider:)``
- ``register(_:forSupplementaryViewOfKind:withReuseIdentifier:)-40vnu``
- ``register(_:forSupplementaryViewOfKind:withReuseIdentifier:)-95s6g``
- ``dequeueReusableSupplementaryView(ofKind:withReuseIdentifier:for:sectionProvider:)``

### Getting the State of a Section Provider

- ``numberOfSections(forSectionProvider:)``
- ``numberOfItems(inSection:sectionProvider:)``
- ``visibleCells(forSectionProvider:)``

### Selecting Cells for a Section Provider

- ``indexPathsForSelectedItems(forSectionProvider:)``
- ``selectItem(at:sectionProvider:animated:scrollPosition:)``
- ``deselectItem(at:sectionProvider:animated:)``
- ``allowsSelection``
- ``allowsMultipleSelection``
- ``allowsSelectionDuringEditing``
- ``allowsMultipleSelectionDuringEditing``
- ``selectionFollowFocus``

### Locating Items and Views for a Section Provider

- ``indexPathsForVisibleItems(forSectionProvider:)``
- ``indexPath(for:sectionProvider:)-80hfd``
- ``cellForItem(at:sectionProvider:)``
- ``indexPathsForVisibleSupplementaryElements(ofKind:sectionProvider:)``
- ``supplementaryView(forElementKind:at:for:)``
- ``visibleSupplementaryViews(ofKind:sectionProvider:)``

### Getting Layout Information for Items and Views in Section Provider

- ``layoutAttributesForItem(at:sectionProvider:)``
- ``layoutAttributesForSupplementaryElement(ofKind:at:sectionProvider:)``

### Creating Headers and Footers for a Section Controller

- ``boundarySupplementaryItems``
- ``boundarySupplementaryViewProvider``

### Resizing Self-Sizing Cells

- ``selfSizingInvalidation``

### Overriding Layout in a Section Controller

- ``interSectionSpacing``
- ``contentInsetReference``
- ``scrollDirection-swift.property``
- ``ScrollDirection-swift.typealias``

### Modifying Default Collection View Behavior

- ``collectionView``

### Creating Decoration Views

- ``register(_:forDecorationViewOfKind:)-44qpg``
- ``register(_:forDecorationViewOfKind:)-4gpvi``
