# ``SectionKit/CollectionSectionController``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Topics

### Creating a Section Controller

- ``init(sectionProviders:)``
- ``init(coder:)``

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

- ``snapshot(for:)``
- ``apply(_:animatingDifferences:sectionProvider:)``
- ``apply(_:animatingDifferences:sectionProvider:completion:)``
- ``applySnapshotUsingReloadData(_:sectionProvider:)``
- ``applySnapshotUsingReloadData(_:sectionProvider:completion:)``

### Prefetching Cells and Data for Section Providers

- ``isPrefetchingEnabled``
- ``addPrefetchingDataSource(_:sectionProvider:)``
- ``removePrefetchingDataSource(for:)``
- ``CollectionSectionControllerDataSourcePrefetching``

### Managing Interactions with Section Provider Content

- ``addDelegate(_:sectionProvider:)``
- ``removeDelegate(for:)``
- ``CollectionSectionControllerDelegate``

### Creating Cells for Section Providers

- ``dequeueConfiguredReusableCell(using:for:item:for:)``
- ``register(_:forCellWithReuseIdentifier:)-7mthu``
- ``register(_:forCellWithReuseIdentifier:)-50v2u``
- ``dequeueReusableCell(withReuseIdentifier:for:sectionProvider:)``

### Creating Headers and Footers for Section Providers

- ``dequeueConfiguredReusableSupplementary(using:for:sectionProvider:)``
- ``register(_:forSupplementaryViewOfKind:withReuseIdentifier:)-40vnu``
- ``register(_:forSupplementaryViewOfKind:withReuseIdentifier:)-95s6g``
- ``dequeueReusableSupplementaryView(ofKind:withReuseIdentifier:for:sectionProvider:)``

### Getting the State of a Section Provider

- ``numberOfSections(for:)``
- ``numberOfItems(inSection:for:)``
- ``visibleCells(for:)``

### Selecting Cells for a Section Provider

- ``indexPathsForSelectedItems(in:)``
- ``selectItem(at:for:animated:scrollPosition:)``
- ``deselectItem(at:for:animated:)``
- ``allowsSelection``
- ``allowsMultipleSelection``
- ``allowsSelectionDuringEditing``
- ``allowsMultipleSelectionDuringEditing``
- ``selectionFollowFocus``

### Locating Items and Views for a Section Provider

- ``indexPathsForVisibleItems(for:)``
- ``indexPath(for:sectionProvider:)-80hfd``
- ``cellForItem(at:for:)``
- ``indexPathsForVisibleSupplementaryElements(ofKind:for:)``
- ``supplementaryView(forElementKind:at:for:)``
- ``visibleSupplementaryViews(ofKind:for:)``

### Getting Layout Information for Items and Views in Section Provider

- ``layoutAttributesForItem(at:for:)``
- ``layoutAttributesForSupplementaryElement(ofKind:at:for:)``

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
