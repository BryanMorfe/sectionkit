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
    func collectionSectionController(
        _ sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>,
        prefetchItemsAt indexPaths: [IndexPath]
    )
    
    /// Cancels a previously triggered data prefetch request.
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
