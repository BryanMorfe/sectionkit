//
//  CollectionSectionProvider.swift
//  CollectionViewArchitecture
//
//  Created by Bryan Morfe on 10/20/22.
//

import UIKit

/// Declares a type that can provide section layout and content for a section controller.
public protocol CollectionSectionProvider<SectionIdentifierType, ItemIdentifierType> : AnyObject, Identifiable where Self.ID == ObjectIdentifier {
    
    /// A type representing the identifier for a section in a diffable data source snapshot.
    associatedtype SectionIdentifierType : Hashable, Sendable
    
    /// A type representing the identifier for an item in a diffable data source snapshot.
    associatedtype ItemIdentifierType : Hashable, Sendable
        
    /// The closure that configures and returns a cell for a collection view from its diffable data source.
    var cellProvider: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>.CellProvider { get }
    
    /// The closure that configures and returns the section provider’s supplementary views, such as headers and footers,
    /// from the diffable data source.
    var supplementaryViewProvider: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>.SupplementaryViewProvider? { get }
    
    /// The closure that creates and returns each of the layout's sections.
    var layoutSectionProvider: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>.SectionProvider { get }
    
    /// Informs the section provider that it will be added into the provided section controller.
    ///
    /// The section controller calls this method before the section is added. At this point, you can start
    /// prefetching any data before it is added. At this point, data cannot be added to the section controller.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller that will contain the section provider.
    func willMove(toSectionController sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>)
    
    /// Informs the section provider that it has been added into the provided section controller.
    ///
    /// The section controller calls this method after the section is added. At this point, you begin adding
    /// new sections and items with a diffable data source snapshot.
    ///
    /// - Parameters:
    ///   - sectionController: The section controller that contains the section provider.
    func didMove(toSectionController sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>)
}

public extension CollectionSectionProvider {
    var supplementaryViewProvider: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>.SupplementaryViewProvider? { nil }
    
    func willMove(toSectionController sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>) {}
    func didMove(toSectionController sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>) {}
}
