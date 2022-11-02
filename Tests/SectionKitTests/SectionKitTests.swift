import XCTest
@testable import SectionKit

protocol MockSectionProvider : CollectionSectionProvider {
    var sectionIdentifiers: [SectionIdentifierType] { get set }
    var sectionIdentifierToItemIdentifierMap: [SectionIdentifierType : [ItemIdentifierType]] { get set }
}

extension MockSectionProvider {
    var cellProvider: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>.CellProvider {{
        sectionController, indexPath, item in
        return sectionController.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath, sectionProvider: self)
    }}
    
    var layoutSectionProvider: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>.SectionProvider {{
        sectionIndex, layoutEnvironment in
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }}
    
    func didMove(toSectionController sectionController: CollectionSectionController<SectionIdentifierType, ItemIdentifierType>) {
        sectionController.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        if sectionIdentifiers.count > 0 {
            var snapshot = CollectionSectionController<SectionIdentifierType, ItemIdentifierType>.DiffableDataSourceSnapshot()
            snapshot.appendSections(sectionIdentifiers)
            for sectionIdentifier in sectionIdentifiers {
                if let itemIdentifiers = sectionIdentifierToItemIdentifierMap[sectionIdentifier] {
                    snapshot.appendItems(itemIdentifiers, toSection: sectionIdentifier)
                }
            }
            sectionController.apply(snapshot, sectionProvider: self)
        }
    }
}

final class ConfigurableMockSectionProvider : MockSectionProvider {
    typealias SectionIdentifierType = String
    typealias ItemIdentifierType = String
    
    var sectionIdentifiers: [String]
    var sectionIdentifierToItemIdentifierMap: [String : [String]]
    
    init(sectionIdentifiers: [String], sectionIdentifierToItemIdentifierMap: [String : [String]]) {
        self.sectionIdentifiers = sectionIdentifiers
        self.sectionIdentifierToItemIdentifierMap = sectionIdentifierToItemIdentifierMap
    }
}

class MockSectionController : CollectionSectionController<String, String> {
    override init() {
        super.init()
        viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        viewDidLoad()
    }
}

final class SectionKitTests: XCTestCase {
    var sectionController: MockSectionController!
    var provider1: ConfigurableMockSectionProvider!
    var provider2: ConfigurableMockSectionProvider!
    var provider3: ConfigurableMockSectionProvider!
    var emptyProvider: ConfigurableMockSectionProvider!
    
    var protocolMessageReceived = false
    var indexPathsOfReference: [IndexPath]?
    
    override func setUp() {
        sectionController = MockSectionController()
        
        provider1 = ConfigurableMockSectionProvider(
            sectionIdentifiers: [
                "provider1"
            ],
            sectionIdentifierToItemIdentifierMap: [
                "provider1" : [ "provider1.item.0", "provider1.item.1", "provider1.item.2" ]
            ]
        )
        
        provider2 = ConfigurableMockSectionProvider(
            sectionIdentifiers: [
                "provider2",
                "provider2.1"
            ],
            sectionIdentifierToItemIdentifierMap: [
                "provider2" : [ "provider2.item.0", "provider2.item.1" ],
                "provider2.1" : [ "provider2.1.item.0", "provider2.1.item.1" ],
            ]
        )
        
        provider3 = ConfigurableMockSectionProvider(
            sectionIdentifiers: [
                "provider3"
            ],
            sectionIdentifierToItemIdentifierMap: [
                "provider3" : [ "provider3.item.0" ]
            ]
        )
        
        emptyProvider = ConfigurableMockSectionProvider(sectionIdentifiers: [], sectionIdentifierToItemIdentifierMap: [:])
    }
    
    func testEmptyProvider_shouldBeEmptyOrZeroOrNil() throws {
        sectionController.addSectionProvider(emptyProvider)
        
        XCTAssertNil(sectionController.sectionIdentifier(for: 0, sectionProvider: emptyProvider))
        XCTAssertNil(sectionController.itemIdentifier(for: IndexPath(item: 0, section: 0), sectionProvider: emptyProvider))
        XCTAssertNil(sectionController.numberOfItems(inSection: 0, sectionProvider: emptyProvider))
        XCTAssertEqual(sectionController.numberOfSections(forSectionProvider: emptyProvider), 0)
        
        XCTAssertEqual(sectionController.snapshotForSectionProvider(emptyProvider).numberOfSections, 0)
        XCTAssertEqual(sectionController.snapshotForSectionProvider(emptyProvider).numberOfItems, 0)
        XCTAssertEqual(sectionController.visibleCells(forSectionProvider: emptyProvider), [])
        XCTAssertEqual(sectionController.indexPathsForVisibleItems(forSectionProvider: emptyProvider), nil)
        XCTAssertEqual(sectionController.visibleSupplementaryViews(ofKind: "", sectionProvider: emptyProvider), [])
        XCTAssertEqual(sectionController.indexPathsForVisibleSupplementaryElements(ofKind: "", sectionProvider: emptyProvider), nil)
        
        XCTAssertEqual(sectionController.collectionView.numberOfSections, 0)
    }
    
    func testNonEmptyProviders_shouldSucceed() throws {
        sectionController.addSectionProvider(provider1)
        sectionController.addSectionProvider(provider2)
        sectionController.addSectionProvider(provider3)
        
        /// Query snapshot relative to provider
        var snapshot = sectionController.snapshotForSectionProvider(provider1)
        XCTAssertEqual(snapshot.sectionIdentifiers, provider1.sectionIdentifiers)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider1"), provider1.sectionIdentifierToItemIdentifierMap["provider1"])
        
        snapshot = sectionController.snapshotForSectionProvider(provider2)
        XCTAssertEqual(snapshot.sectionIdentifiers, provider2.sectionIdentifiers)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider2"), provider2.sectionIdentifierToItemIdentifierMap["provider2"])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider2.1"), provider2.sectionIdentifierToItemIdentifierMap["provider2.1"])
        
        snapshot = sectionController.snapshotForSectionProvider(provider3)
        XCTAssertEqual(snapshot.sectionIdentifiers, provider3.sectionIdentifiers)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider3"), provider3.sectionIdentifierToItemIdentifierMap["provider3"])
        
        /// Query number of sections relative to provider
        XCTAssertEqual(sectionController.numberOfSections(forSectionProvider: provider1), 1)
        XCTAssertEqual(sectionController.numberOfSections(forSectionProvider: provider2), 2)
        XCTAssertEqual(sectionController.numberOfSections(forSectionProvider: provider3), 1)
        
        /// Query number of items relative to provider
        XCTAssertEqual(sectionController.numberOfItems(inSection: 0, sectionProvider: provider1), 3)
        XCTAssertEqual(sectionController.numberOfItems(inSection: 0, sectionProvider: provider2), 2)
        XCTAssertEqual(sectionController.numberOfItems(inSection: 1, sectionProvider: provider2), 2)
        XCTAssertEqual(sectionController.numberOfItems(inSection: 0, sectionProvider: provider3), 1)
        
        /// Query section identifiers relative to provider
        XCTAssertEqual(sectionController.sectionIdentifier(for: 0, sectionProvider: provider1), provider1.sectionIdentifiers[0])
        XCTAssertEqual(sectionController.sectionIdentifier(for: 0, sectionProvider: provider2), provider2.sectionIdentifiers[0])
        XCTAssertEqual(sectionController.sectionIdentifier(for: 1, sectionProvider: provider2), provider2.sectionIdentifiers[1])
        XCTAssertEqual(sectionController.sectionIdentifier(for: 0, sectionProvider: provider3), provider3.sectionIdentifiers[0])
        
        /// Query item identifiers relative to provider
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 0, section: 0), sectionProvider: provider1), "provider1.item.0")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 1, section: 0), sectionProvider: provider1), "provider1.item.1")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 2, section: 0), sectionProvider: provider1), "provider1.item.2")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 0, section: 0), sectionProvider: provider2), "provider2.item.0")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 1, section: 0), sectionProvider: provider2), "provider2.item.1")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 0, section: 1), sectionProvider: provider2), "provider2.1.item.0")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 1, section: 1), sectionProvider: provider2), "provider2.1.item.1")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 0, section: 0), sectionProvider: provider3), "provider3.item.0")
        
        /// Query index paths for items relative to providers
        XCTAssertEqual(sectionController.indexPath(for: "provider1.item.0", sectionProvider: provider1), IndexPath(item: 0, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider1.item.1", sectionProvider: provider1), IndexPath(item: 1, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider1.item.2", sectionProvider: provider1), IndexPath(item: 2, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider2.item.0", sectionProvider: provider2), IndexPath(item: 0, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider2.item.1", sectionProvider: provider2), IndexPath(item: 1, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider2.1.item.0", sectionProvider: provider2), IndexPath(item: 0, section: 1))
        XCTAssertEqual(sectionController.indexPath(for: "provider2.1.item.1", sectionProvider: provider2), IndexPath(item: 1, section: 1))
        XCTAssertEqual(sectionController.indexPath(for: "provider3.item.0", sectionProvider: provider3), IndexPath(item: 0, section: 0))
    }
    
    func testNonEmptyAndEmptyProviders_shouldSucceed() throws {
        sectionController.addSectionProvider(provider1)
        sectionController.addSectionProvider(emptyProvider)
        sectionController.addSectionProvider(provider3)
        
        /// Query snapshot relative to provider
        var snapshot = sectionController.snapshotForSectionProvider(provider1)
        XCTAssertEqual(snapshot.sectionIdentifiers, provider1.sectionIdentifiers)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider1"), provider1.sectionIdentifierToItemIdentifierMap["provider1"])
        
        snapshot = sectionController.snapshotForSectionProvider(emptyProvider)
        XCTAssertEqual(snapshot.numberOfSections, 0)
        XCTAssertEqual(snapshot.numberOfItems, 0)
        
        snapshot = sectionController.snapshotForSectionProvider(provider3)
        XCTAssertEqual(snapshot.sectionIdentifiers, provider3.sectionIdentifiers)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider3"), provider3.sectionIdentifierToItemIdentifierMap["provider3"])
        
        /// Query number of sections relative to provider
        XCTAssertEqual(sectionController.numberOfSections(forSectionProvider: provider1), 1)
        XCTAssertEqual(sectionController.numberOfSections(forSectionProvider: emptyProvider), 0)
        XCTAssertEqual(sectionController.numberOfSections(forSectionProvider: provider3), 1)
        
        /// Query number of items relative to provider
        XCTAssertEqual(sectionController.numberOfItems(inSection: 0, sectionProvider: provider1), 3)
        XCTAssertNil(sectionController.numberOfItems(inSection: 0, sectionProvider: emptyProvider))
        XCTAssertEqual(sectionController.numberOfItems(inSection: 0, sectionProvider: provider3), 1)
        
        /// Query section identifiers relative to provider
        XCTAssertEqual(sectionController.sectionIdentifier(for: 0, sectionProvider: provider1), provider1.sectionIdentifiers[0])
        XCTAssertNil(sectionController.sectionIdentifier(for: 0, sectionProvider: emptyProvider))
        XCTAssertEqual(sectionController.sectionIdentifier(for: 0, sectionProvider: provider3), provider3.sectionIdentifiers[0])
        
        /// Query item identifiers relative to provider
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 0, section: 0), sectionProvider: provider1), "provider1.item.0")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 1, section: 0), sectionProvider: provider1), "provider1.item.1")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 2, section: 0), sectionProvider: provider1), "provider1.item.2")
        XCTAssertNil(sectionController.itemIdentifier(for: IndexPath(item: 0, section: 0), sectionProvider: emptyProvider))
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 0, section: 0), sectionProvider: provider3), "provider3.item.0")
        
        /// Query index paths for items relative to providers
        XCTAssertEqual(sectionController.indexPath(for: "provider1.item.0", sectionProvider: provider1), IndexPath(item: 0, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider1.item.1", sectionProvider: provider1), IndexPath(item: 1, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider1.item.2", sectionProvider: provider1), IndexPath(item: 2, section: 0))
        XCTAssertNil(sectionController.indexPath(for: "provider2.item.0", sectionProvider: emptyProvider))
        XCTAssertEqual(sectionController.indexPath(for: "provider3.item.0", sectionProvider: provider3), IndexPath(item: 0, section: 0))
    }
    
    func testNonEmptyProviderByRemovingProviderAnimatingDifferences_shouldSucceed() throws {
        sectionController.addSectionProvider(provider1)
        sectionController.addSectionProvider(provider2)
        sectionController.addSectionProvider(provider3)
        
        sectionController.deleteSectionProvider(provider2)
        
        /// Original snapshot should not have `provider2`
        var snapshot = (sectionController.collectionView.dataSource as! MockSectionController.DiffableDataSource).snapshot()
        XCTAssertEqual(snapshot.sectionIdentifiers, ["provider1", "provider3"])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider1"), provider1.sectionIdentifierToItemIdentifierMap["provider1"])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider3"), provider3.sectionIdentifierToItemIdentifierMap["provider3"])
        
        /// Query snapshot relative to provider
        snapshot = sectionController.snapshotForSectionProvider(provider1)
        XCTAssertEqual(snapshot.sectionIdentifiers, provider1.sectionIdentifiers)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider1"), provider1.sectionIdentifierToItemIdentifierMap["provider1"])
        
        snapshot = sectionController.snapshotForSectionProvider(provider3)
        XCTAssertEqual(snapshot.sectionIdentifiers, provider3.sectionIdentifiers)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider3"), provider3.sectionIdentifierToItemIdentifierMap["provider3"])
        
        /// Query number of sections relative to provider
        XCTAssertEqual(sectionController.numberOfSections(forSectionProvider: provider1), 1)
        XCTAssertEqual(sectionController.numberOfSections(forSectionProvider: provider3), 1)
        
        /// Query number of items relative to provider
        XCTAssertEqual(sectionController.numberOfItems(inSection: 0, sectionProvider: provider1), 3)
        XCTAssertEqual(sectionController.numberOfItems(inSection: 0, sectionProvider: provider3), 1)
        
        /// Query section identifiers relative to provider
        XCTAssertEqual(sectionController.sectionIdentifier(for: 0, sectionProvider: provider1), provider1.sectionIdentifiers[0])
        XCTAssertEqual(sectionController.sectionIdentifier(for: 0, sectionProvider: provider3), provider3.sectionIdentifiers[0])
        
        /// Query item identifiers relative to provider
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 0, section: 0), sectionProvider: provider1), "provider1.item.0")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 1, section: 0), sectionProvider: provider1), "provider1.item.1")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 2, section: 0), sectionProvider: provider1), "provider1.item.2")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 0, section: 0), sectionProvider: provider3), "provider3.item.0")
        
        /// Query index paths for items relative to providers
        XCTAssertEqual(sectionController.indexPath(for: "provider1.item.0", sectionProvider: provider1), IndexPath(item: 0, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider1.item.1", sectionProvider: provider1), IndexPath(item: 1, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider1.item.2", sectionProvider: provider1), IndexPath(item: 2, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider3.item.0", sectionProvider: provider3), IndexPath(item: 0, section: 0))
    }
    
    func testNonEmptyProviderByRemovingProviderReloadingData_shouldSucceed() throws {
        sectionController.addSectionProvider(provider1)
        sectionController.addSectionProvider(provider2)
        sectionController.addSectionProvider(provider3)
        
        sectionController.deleteSectionProviderUsingReloadData(provider2)
        
        /// Original snapshot should not have `provider2`
        var snapshot = (sectionController.collectionView.dataSource as! MockSectionController.DiffableDataSource).snapshot()
        XCTAssertEqual(snapshot.sectionIdentifiers, ["provider1", "provider3"])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider1"), provider1.sectionIdentifierToItemIdentifierMap["provider1"])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider3"), provider3.sectionIdentifierToItemIdentifierMap["provider3"])
        
        /// Query snapshot relative to provider
        snapshot = sectionController.snapshotForSectionProvider(provider1)
        XCTAssertEqual(snapshot.sectionIdentifiers, provider1.sectionIdentifiers)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider1"), provider1.sectionIdentifierToItemIdentifierMap["provider1"])
        
        snapshot = sectionController.snapshotForSectionProvider(provider3)
        XCTAssertEqual(snapshot.sectionIdentifiers, provider3.sectionIdentifiers)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: "provider3"), provider3.sectionIdentifierToItemIdentifierMap["provider3"])
        
        /// Query number of sections relative to provider
        XCTAssertEqual(sectionController.numberOfSections(forSectionProvider: provider1), 1)
        XCTAssertEqual(sectionController.numberOfSections(forSectionProvider: provider3), 1)
        
        /// Query number of items relative to provider
        XCTAssertEqual(sectionController.numberOfItems(inSection: 0, sectionProvider: provider1), 3)
        XCTAssertEqual(sectionController.numberOfItems(inSection: 0, sectionProvider: provider3), 1)
        
        /// Query section identifiers relative to provider
        XCTAssertEqual(sectionController.sectionIdentifier(for: 0, sectionProvider: provider1), provider1.sectionIdentifiers[0])
        XCTAssertEqual(sectionController.sectionIdentifier(for: 0, sectionProvider: provider3), provider3.sectionIdentifiers[0])
        
        /// Query item identifiers relative to provider
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 0, section: 0), sectionProvider: provider1), "provider1.item.0")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 1, section: 0), sectionProvider: provider1), "provider1.item.1")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 2, section: 0), sectionProvider: provider1), "provider1.item.2")
        XCTAssertEqual(sectionController.itemIdentifier(for: IndexPath(item: 0, section: 0), sectionProvider: provider3), "provider3.item.0")
        
        /// Query index paths for items relative to providers
        XCTAssertEqual(sectionController.indexPath(for: "provider1.item.0", sectionProvider: provider1), IndexPath(item: 0, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider1.item.1", sectionProvider: provider1), IndexPath(item: 1, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider1.item.2", sectionProvider: provider1), IndexPath(item: 2, section: 0))
        XCTAssertEqual(sectionController.indexPath(for: "provider3.item.0", sectionProvider: provider3), IndexPath(item: 0, section: 0))
    }
    
    func testNonEmptyProvidersDelegate_shouldBeCalled() throws {
        sectionController.addSectionProvider(provider1)
        sectionController.addSectionProvider(provider2)
        sectionController.addSectionProvider(provider3)
        
        /// Test Delegate Methods Get Called
        sectionController.addDelegate(self, sectionProvider: provider2)
        
        prepareForProtocolMessage()
        let _ = sectionController.collectionView(sectionController.collectionView, shouldSelectItemAt: IndexPath(item: 0, section: 2))
        XCTAssert(protocolMessageReceived)
        var indexPaths = try XCTUnwrap(indexPathsOfReference)
        XCTAssertEqual(indexPaths, [IndexPath(item: 0, section: 1)])
        
        prepareForProtocolMessage()
        sectionController.collectionView(sectionController.collectionView, didSelectItemAt: IndexPath(item: 0, section: 2))
        XCTAssert(protocolMessageReceived)
        indexPaths = try XCTUnwrap(indexPathsOfReference)
        XCTAssertEqual(indexPaths, [IndexPath(item: 0, section: 1)])
        
        let _ = sectionController.collectionView(sectionController.collectionView, shouldDeselectItemAt: IndexPath(item: 0, section: 2))
        XCTAssert(protocolMessageReceived)
        indexPaths = try XCTUnwrap(indexPathsOfReference)
        XCTAssertEqual(indexPaths, [IndexPath(item: 0, section: 1)])
        
        prepareForProtocolMessage()
        sectionController.collectionView(sectionController.collectionView, didDeselectItemAt: IndexPath(item: 0, section: 2))
        XCTAssert(protocolMessageReceived)
        indexPaths = try XCTUnwrap(indexPathsOfReference)
        XCTAssertEqual(indexPaths, [IndexPath(item: 0, section: 1)])
        
        let _ = sectionController.collectionView(sectionController.collectionView, shouldHighlightItemAt: IndexPath(item: 0, section: 2))
        XCTAssert(protocolMessageReceived)
        indexPaths = try XCTUnwrap(indexPathsOfReference)
        XCTAssertEqual(indexPaths, [IndexPath(item: 0, section: 1)])
        
        prepareForProtocolMessage()
        sectionController.collectionView(sectionController.collectionView, didHighlightItemAt: IndexPath(item: 0, section: 2))
        XCTAssert(protocolMessageReceived)
        indexPaths = try XCTUnwrap(indexPathsOfReference)
        XCTAssertEqual(indexPaths, [IndexPath(item: 0, section: 1)])
        
        if #available(iOS 16, *) {
            let _ = sectionController.collectionView(sectionController.collectionView, contextMenuConfigurationForItemsAt: [IndexPath(item: 0, section: 2)], point: .zero)
        } else {
            let _ = sectionController.collectionView(sectionController.collectionView, contextMenuConfigurationForItemAt: IndexPath(item: 0, section: 2), point: .zero)
        }
        XCTAssert(protocolMessageReceived)
        indexPaths = try XCTUnwrap(indexPathsOfReference)
        XCTAssertEqual(indexPaths, [IndexPath(item: 0, section: 1)])
        
        prepareForProtocolMessage()
        let _ = sectionController.collectionView(sectionController.collectionView, canEditItemAt: IndexPath(item: 0, section: 2))
        XCTAssert(protocolMessageReceived)
        indexPaths = try XCTUnwrap(indexPathsOfReference)
        XCTAssertEqual(indexPaths, [IndexPath(item: 0, section: 1)])
        
        if #available(iOS 16, *) {
            prepareForProtocolMessage()
            let _ = sectionController.collectionView(sectionController.collectionView, canPerformPrimaryActionForItemAt: IndexPath(item: 0, section: 2))
            XCTAssert(protocolMessageReceived)
            indexPaths = try XCTUnwrap(indexPathsOfReference)
            XCTAssertEqual(indexPaths, [IndexPath(item: 0, section: 1)])
            
            prepareForProtocolMessage()
            sectionController.collectionView(sectionController.collectionView, performPrimaryActionForItemAt: IndexPath(item: 0, section: 2))
            XCTAssert(protocolMessageReceived)
            indexPaths = try XCTUnwrap(indexPathsOfReference)
            XCTAssertEqual(indexPaths, [IndexPath(item: 0, section: 1)])
        }
        
        /// Test Delegate Methods Don't Get Called
        prepareForProtocolMessage()
        sectionController.collectionView(sectionController.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        XCTAssertFalse(protocolMessageReceived)
        XCTAssertNil(indexPathsOfReference)
        
        prepareForProtocolMessage()
        sectionController.collectionView(sectionController.collectionView, didSelectItemAt: IndexPath(item: 0, section: 3))
        XCTAssertFalse(protocolMessageReceived)
        XCTAssertNil(indexPathsOfReference)
        
        prepareForProtocolMessage()
        sectionController.collectionView(sectionController.collectionView, didDeselectItemAt: IndexPath(item: 0, section: 0))
        XCTAssertFalse(protocolMessageReceived)
        XCTAssertNil(indexPathsOfReference)
        
        prepareForProtocolMessage()
        sectionController.collectionView(sectionController.collectionView, didDeselectItemAt: IndexPath(item: 0, section: 3))
        XCTAssertFalse(protocolMessageReceived)
        XCTAssertNil(indexPathsOfReference)
        
        prepareForProtocolMessage()
        sectionController.collectionView(sectionController.collectionView, didHighlightItemAt: IndexPath(item: 0, section: 0))
        XCTAssertFalse(protocolMessageReceived)
        XCTAssertNil(indexPathsOfReference)
        
        prepareForProtocolMessage()
        sectionController.collectionView(sectionController.collectionView, didHighlightItemAt: IndexPath(item: 0, section: 3))
        XCTAssertFalse(protocolMessageReceived)
        XCTAssertNil(indexPathsOfReference)
    }
}

extension SectionKitTests : CollectionSectionControllerDelegate, CollectionSectionControllerDataSourcePrefetching {
    typealias SectionIdentifierType = String
    typealias ItemIdentifierType = String
    
    func prepareForProtocolMessage() {
        indexPathsOfReference = nil
        protocolMessageReceived = false
    }
    
    // MARK: Prefetching Data Source
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPathsOfReference = indexPaths
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPathsOfReference = indexPaths
        protocolMessageReceived = true
    }
    
    // MARK: Delegate Tests
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
        return true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, didSelectItemAt indexPath: IndexPath) {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
        return true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, didDeselectItemAt indexPath: IndexPath) {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, shouldBeginMultipleSelectionInterationAt indexPath: IndexPath) -> Bool {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
        return true
    }
    
    func collectionSectionControllerDidEndMultipleSelectionInteration(_ sectionController: CollectionSectionController<String, String>) {
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
        return true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, didHighlightItemAt indexPath: IndexPath) {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, didUnhighlightItemAt indexPath: IndexPath) {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, willDisplayContextMenu configuration: UIContextMenuConfiguration, with animator: UIContextMenuInteractionAnimating?) {
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, with animator: UIContextMenuInteractionAnimating?) {
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        indexPathsOfReference = indexPaths
        protocolMessageReceived = true
        return nil
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
        return nil
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
        return nil
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, contextMenuConfiguration configuration: UIContextMenuConfiguration, dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
        return nil
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, canEditItemAt indexPath: IndexPath) -> Bool {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
        return true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, canPerformPrimaryActionForItemAt indexPath: IndexPath) -> Bool {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
        return true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, performPrimaryActionForItemAt indexPath: IndexPath) {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, sceneActivationConfigurationForItemAt indexPath: IndexPath, with point: CGPoint) -> UIWindowScene.ActivationConfiguration? {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
        return nil
    }
    
    func collectionSectionController(_ sectionController: CollectionSectionController<String, String>, shouldSpringLoadItemAt indexPath: IndexPath) -> Bool {
        indexPathsOfReference = [indexPath]
        protocolMessageReceived = true
        return true
    }
    
    func collectionSectionControllerDidScroll(_ sectionController: CollectionSectionController<String, String>, in scrollView: UIScrollView) {
        protocolMessageReceived = true
    }
    
    func collectionSectionControllerWillBeginDragging(_ sectionController: CollectionSectionController<String, String>, in scrollView: UIScrollView) {
        protocolMessageReceived = true
    }
    
    func collectionSectionControllerWillEndDragging(_ sectionController: CollectionSectionController<String, String>, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>, in scrollView: UIScrollView) {
        protocolMessageReceived = true
    }
    
    func collectionSectionControllerDidEndDragging(_ sectionController: CollectionSectionController<String, String>, willDecelerate delerate: Bool, in scrollView: UIScrollView) {
        protocolMessageReceived = true
    }
    
    func collectionSectionControllerDidScrollToTop(_ sectionController: CollectionSectionController<String, String>, in scrollView: UIScrollView) {
        protocolMessageReceived = true
    }
    
    func collectionSectionControllerWillBeginDecelerating(_ sectionController: CollectionSectionController<String, String>, in scrollView: UIScrollView) {
        protocolMessageReceived = true
    }
    
    func collectionSectionControllerDidEndDecelerating(_ sectionController: CollectionSectionController<String, String>, in scrollView: UIScrollView) {
        protocolMessageReceived = true
    }
    
    func collectionSectionControllerDidEndScrollingAnimation(_ sectionController: CollectionSectionController<String, String>, in scrollView: UIScrollView) {
        protocolMessageReceived = true
    }
    
    func collectionSectionControllerDidChangeAdjustedContentInset(_ sectionController: CollectionSectionController<String, String>, in scrollView: UIScrollView) {
        protocolMessageReceived = true
    }
}
