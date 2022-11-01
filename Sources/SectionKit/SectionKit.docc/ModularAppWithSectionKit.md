# Create a Modular App With SectionKit

Learn how to use SectionKit to modularize your apps.

## Overview

For this example, we'll be creating a simple modular app for an upcoming food recommendation
network. The app provides users recommendations of different dishes and allows them
to place an order of the same.

There are two main pages on the app that we'll focus on; the dish recommendations page
and the dish detail page. On the dish recommendation page, there will be various sections,
e.g. "Popular Dishes" or "Recommended For You". In addition, the dish detail page will
contain details about a specific dish, and at the end, the same sections as in the dish
recommendations page.

## Designing the App

From the requirements given, there's opportunity to use SectionKit to modularize the app.
Since the dish detail page will contain the same content laid out in the same way as
dish recommendations page, then it becomes clear that the content in the dish recommendations
should be modular and reusable.

![UI mock of sample app](FoodRecNetwork)

The page to the left is the dish detail page. It contains several sections such as a header
and additional detail sections about a specific dish. Below, users will be able to explore
additional dishes. To the right is the dish recommendations page. It is the same layout and
data contained in the sections of the dish recommendations page.

Initially, it may be tempting to think of these two pages as two view controllers containing
two collection views that are managed independently. However, there are a few issues that can
arise from that.

First, if the two view controllers are fully indepedent, then that means that to add the
recommendations below the details, the same layout has to be built in both places, but perhaps
even worse, this results in almost the exact same code being in multiple places. Of course,
some aspects of it such as the content provider could be modularized, but that still leaves
the responsibility to the view controller to manage the layout.

Another option is to add the view of the dish recommendation view controller as a cell in
another section, but that too comes with challenges. Even though we've overcome the issue
of code duplication, we now have a perhaps worse problem; two collection views that scroll
along the same main direction with a parent-child relationship. This leads an awkward UX such
as interruptions in scrolling when transitioning the scrolling from one collection view to
the other.

### Designing With SectionKit

To solve the problems highlighted above, it helps to think of each section in the app
independently. The dish details header, the additional dish detail sections, and the
recommendation sections can be though of as completely independent, and all they need
is to be contained within a collection view. Doing so brings the following benefits:
- Each section that becomes independent of its container can be reused in other containers;
- The logic to populate and configure a section is completely independent of its container,
leading to better modularization and easier to maintain code. In principle that means that:
  - The section providers don't need to worry about the details of its container, but still
have full control over their content and interactions with it; and,
  - The container needn't worry about the details of the sections, but simply manages
the collection view and the order of the sections.

For the reasons stated above, in general, it is expected that each section provider and the
section controller be relatively lightweight components.

With that in mind, for the requirements of this app, there will be:
- A single Section Controller capable of containing any Section Provider used in the app
(`DishSectionController`); and,
- Four Section Providers:
  1. A section provider for the Dish Header section (`DishHeaderDetailSectionProvider`);
  2. A section provider for the Additional Details 1 section (`DishDetailOneSectionProvider`);
  3. A section provider for the Additional Details 2 section (`DishDetailTwoSectionProvider`); and,
  4. A section provider for the the recommendation sections (`DishRecommendationsSectionProvider`).

The reason to keep all recommendation sections in a single section provider is that the
content is expected to always be intertwined and its layout is always coming from a service
that will ultimately determine which sections show up, so it makes sense that they are
coupled together.

### Implementation

```swift
import UIKit
import SectionKit

class DishSectionController : CollectionSectionController<String, DishItemIdentifier> {}

struct DishItemIdentifier : Identifiable {
    let id = UUID()
    let dishID: Dish.ID

    static func identifier(with dishID: Dish.ID) -> DishItemIdentifier {
        DishItemIdentifier(dishID: dishID)
    }
}
```

The `DishSectionController` does not need any special implementation for now, so we'll leave
it as-is. However, notice that the `ItemIdentifierType` is an identifiable struct called
`DishItemIdentifier`. This is a very important practice that should be used to avoid collision
within the data source's snapshot in the collection view. Every time a new `DishItemIdentifier`
is created, it also creates a unique `id` which is then added to the snapshot. Wrapping up
the ID makes it easy to avoid collisions regardless of the sections' independence.

```swift
import UIKit
import SectionKit

class DishHeaderDetailSectionProvider : CollectionSectionProvider<String, DishItemIdentifier> {
    
    let id = UUID()
    
    var cellProvider: CollectionSectionController<String, String>.CellProvider {{
        sectionController, indexPath, item in
        return sectionController.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: item, sectionProvider: self)
    }}

    var sectionProvider: CollectionSectionController<String, String>.SectionProvider {{
        sectionIndex, layoutEnvironment in
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(180)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(180)
            ),
            repeatingSubitem: item,
            count: 1
        )
        group.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }}
        
    let cellRegistration = UICollectionView.CellRegistration<DishHeaderCollectionViewCell, String> {
        cell, indexPath, dishItemIdentifier in
        let identifier = self.identifiers[dishItemIdentifier]
        if let dish = DishStore.shared.dish(for: identifier.dishID) {
            cell.configure(with: dish)
        } else {
            Task {
                do {
                    try await DishStore.shared.downloadDish(with: identifier.dishID)
                    setItemNeedsUpdate(dishItemIdentifier)
                } catch {
                    /// Handler error
                }
            }
        }
    }

    var dishID: Dish.ID
    var identifiers: [UUID : DishItemIdentifier] = [:]

    init(dishID: Dish.ID) {
        self.dishID = dishID
    }

    func willMove(toSectionController sectionController: CollectionSectionController<String, String>) {
        /// Begin prefetching data
        Task {
            try? await DishStore.shared.downloadDish(with: self.dishID)
        }
    }
    
    func didMove(toSectionController sectionController: CollectionSectionController<String, String>) {
        /// Add this provider as a delegate
        sectionController.addDelegate(self, sectionProvider: self)

        /// Add data for section to be populated.
        let identifier: DishItemIdentifier = .identifier(with: dishID)
        identifiers[identifier.id] = identifier
        
        var snapshot = CollectionSectionController<String, String>.DiffableDataSourceSnapshot()
        snapshot.appendSections(["header.sectionID"])
        snapshot.appendItems([identifier], toSection: "header.sectionID")
        sectionController.apply(snapshot, sectionProvider: self)
    }
}

extension DishHeaderDetailSectionProvider : CollectionSectionControllerDelegate {
    func collectionSectionController(
        _ sectionController: CollectionSectionController<String, DishItemIdentifier>,
        didSelectItemAt indexPath: IndexPath
    ) {
        /// Handle selections 
    }
}
```

This very simple Section Provider does a few things:
- It configures and provides a cell to be used for the items in the section;
- It defines the layout of the section;
- It downloads the data needed for the section's content; and,
- It handles user interaction with the section's content.

To present this (and other) sections in a section controller, is as simple as
creating the section controller with the desired sections.

```swift
class HomeViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /// ... ///
    }

    func presentDishDetails(for dishID: Dish.ID) {
        let sectionController = DishSectionController(
            sectionProviders: [
                DishHeaderDetailSectionProvider(dishID: dishID),
                DishDetailOneSectionProvider(dishID: dishID),
                DishDetailTwoSectionProvider(dishID: dishID),
                DishRecommendationsSectionProvider(dishID: dishID)
            ]
        )
        present(sectionController, animated: true, completion: nil)
    }

    func presentRecommendations(for dishID: Dish.ID?) {
        let sectionController = DishSectionController(
            sectionProviders: [
                DishRecommendationsSectionProvider(dishID: dishID)
            ]
        )
        present(sectionController, animated: true, completion: nil)
    }
}
```

With that, we have a fully modular app with reusable sections that can live
in multiple different pages of it.
