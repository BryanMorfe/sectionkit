//
//  CollectionSectionControllerDataSourcePrefetching.swift
//  
//
//  Created by Bryan Morfe on 10/26/22.
//

import UIKit

/// A protocol that provides advance warning of the data requirements for a section controller,
/// allowing the triggering of asynchronous data load operations.
///
/// This protocol contains methods similar to `UICollectionViewDataSourcePrefetching`, however,
/// the section controller will only send the message if the index paths are owned by section provider's whose
/// object is conforming to this protocol. That is, an object being the prefetching data source for a specific section
/// provider will only receive the message in the index paths are owned by said section provider.
///
/// > Important: All index paths are relative to the section provider that own the item and section for said index path. That is,
/// it is not valid to use that index path with the collection view object or data source object. Instead, a section provider
/// must only use the methods in the section controller that is sending the message.
@MainActor public protocol CollectionSectionControllerDataSourcePrefetching<SectionIdentifierType, ItemIdentifierType> : AnyObject {
    
    /// A type representing the identifier for a section in a diffable data source snapshot.
    associatedtype SectionIdentifierType : Hashable, Sendable
    
    /// A type representing the identifier for an item in a diffable data source snapshot.
    associatedtype ItemIdentifierType : Hashable, Sendable
    
    /// Tells your prefetch data source object to begin preparing data for the cells at the supplied index paths.
    ///
    /// The section controller calls this method as the user scrolls, providing the index paths for cells it's likely
    /// to display in the near future. Your implementation of this method is responsible for starting any
    /// expensive data loading processes. The data loading must be performed asynchronously, and the results
    /// made available to the ``CollectionSectionProvider/cellProvider`` closure that
    /// requires it.
    ///
    /// The section controller doesn't call this method cells it requires immediately, so your code must not rely
    /// on this method alone to load data. The order of the index paths provided represents the priority.
    ///
    /// > Important: This method only gets called for a prefetching data source associated with a section
    /// provider if the items are associated with the section provider. In addition, the index paths are always
    /// relative to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller issuing the prefetch request.
    ///   - indexPaths: The index paths that specify the location of the items for which data is to be
    ///   prefetched.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        prefetchItemsAt indexPaths: [IndexPath]
    )
    
    /// Cancels a previously triggered data prefetch request.
    ///
    /// The section controller calls this method to cancel prefetch requests as cells scroll out of view.
    /// Your implementation of this method is responsible for cancelling the operations initiated by
    /// a previous call to ``collectionSectionController(_:prefetchItemsAt:)``.
    ///
    /// > Important: This method only gets called for a prefetching data source associated with a section
    /// provider if the items are associated with the section provider. In addition, the index paths are always
    /// relative to the section provider to which the item belongs.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller issuing the cancellations of the prefetch request.
    ///   - indexPaths: The index paths that specify the location of the items for which data is no longer
    ///   required.
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        cancelPrefetchingForItemsAt indexPaths: [IndexPath]
    )
}

extension CollectionSectionControllerDataSourcePrefetching {
    
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        cancelPrefetchingForItemsAt indexPaths: [IndexPath]
    ) {}
}
