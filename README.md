# SectionKit

UIKit extension to modularize app with single-responsibility reusable collection view sections.

## Design Philosophy
SectionKit follows a simple yet powerful design philosophy:
1. The logic of generating a section and its content should be independent of the content's container;
2. A section's content container does not need to know the details of how a content provider generates its content; and,
3. A content provider need only be concerned with its own content and not that of any other content provider.

That philosophy comes with a few implications. For one, if the third point is to be true, that means that the content providers should not have access to other content providers in the content container, for example. In addition, a content container must be generic enough to contain content providers without known specific details about its implementations. Finally, a content container should be able to constrain which section providers can participate.

In addition, having such versatility should not come with perceivable performance shortcomings. Fortunately, `UIKit` already lays out the foundation upon which SectionKit is based; _Collection Views_. Collection views are perfect for this use case because they allow developers to lay out content in an ordered container while having features such as _lazy loading_ that help indefinitely long containers stay performant.

Furthermore, if a content container should really be able to lay out content provided by arbitrary content providers, then its layout must be fluid. SectionKit takes advantage of the versatility of _Compositional Layouts_ to allow content providers to specify how containers lay out its content. This further allows for decoupling between a content container and content providers.

Finally, if content providers are truly owners of their own content, they must be able to provide and manage all data associated with its content. SectionKit takes advatange of _Collection View Diffable Data Sources_. Using diffable data sources allows content providers to use a minimal effort approach to set the data used for its content, and without the cumbersome approach of providing a data source manually for a collection view.

In summary, three great UIKit features come together to make SectionKit possible; Collection Views, Compositional Layouts, and Diffable Data Sources.

### Technical Design Decisions

To formalize the philosophy, there are four entities that should be known:
- `CollectionSectionController`: A view controller that manages a collection view to lay out content provided by `CollectionSectionProvider`s.
- `CollectionSectionProvider`: A protocol adopted by objects that which to provide content to be displayed in a `CollectionSectionController`.
- `CollectionSectionControllerDelegate`: A protocol adopted by objects that which to delegate messages from a `CollectionSectionController` on behalf of a `CollectionSectionProvider`.
- `CollectionSectionControllerDataSourcePrefetching`: A protocol adopted by objects that which to respond to advanced warnings of data requirements from a `CollectionSectionController` on behalf of a `CollectionSectionProvider`. 

These four entities provide the core functionality of SectionKit. They are designed to fulfill and abide by the philosophies mentioned above.

First, in order to give developers the flexibility to constraint compatibility between section controllers and section providers, generics are used. Each section controller and section provider decides what is the type of its collection view's diffable data source section and item identifiers, just like can be done with `UICollectionViewDiffableDataSource` and `NSDiffableDataSourceSnapshot`. For example, the below section controller and provider are compatible:

```swift
class SectionController : CollectionSectionController<String, UUID> {}
```

```swift
class SectionProvider : CollectionSectionProvider {
    typealias SectionIdentifierType = String
    typealias ItemIdentifierType = UUID
}
```

Whereas the following `CollectionSectionProvider` is not compatible with the above declared `CollectionSectionController`:

```swift
class SectionProvider : CollectionSectionProvider {
    typealias SectionIdentifierType = String
    typealias ItemIdentifierType = String
}
```

Declaring the typography of Section Providers and Section Controllers is the only constraint that determines whether they are compatible. Ultimately, though, control is in the hands of the developer as it is easy to design a Section Controller compatible with _any_ section provider by using generic typography, such as `AnyHashable`, etc.

Second, in order to allow complete independence between `CollectionSectionProvider`s as well as prevent section providers from modifying properties that affect other section providers, directly querying the underlying collection view, data source, or layout is discouraged. `CollectionSectionController`s implement the methods that a section provider exactly needs for functionality. For example, to dequeue a cell, instead of calling:

```swift
let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
```

Section Providers would call:

```swift
let cell = sectionController.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item, sectionProvider: self)
```

Although `CollectionSectionController`s have a public property for its underlying collection view, that should only be used for classes that inherit from `CollectionSectionController`s, and, the index paths that `CollectionSectionProvider`s receive and send are relative to its content. That allows the following:
- It hides the order of sections in a `CollectionSectionProvider` in a `CollectionSectionController`. This encourages developers to write generic `CollectionSectionProvider` that needn't rely on being in a specific order in order to function properly, but also, it needn't care about any other Section providers that live in the same `CollectionSectionController`.
- `CollectionSectionProvider`s have a difficult time directly interacting with the collection view and data source, further encouraging use of the `CollectionSectionController`s equivalent methods and preventing code prone to error; and,
- Makes it easier for section providers to address and determine which content is being addressed. For example, for a section provider, an index path of (0, 0) always refers to the first item of its first section, regardless of its actual position in the `CollectionSectionController`.

This is also true when implementing a delegate (`CollectionSectionControllerDelegate`) or prefetching data source (`CollectionSectionControllerDataSourcePrefetching`) on behalf of a section provider. Any messages it receives are sure to belong to that section provider or are to be received by all section providers. For example, when the delegate of a section provider receives the message `collectionSectionController(:didSelectItemAt:)` (the equivalent of `UICollectionViewDelegate`'s `collectionView(:didSelectItemAt:)`), then the index path will be relative to the section provider's content and will always be for content that belong to the section provider, whereas the method `collectionSectionControllerDidScroll(:in:)` will be received by all delegates.

For the reasons listed above, it is preferable to provide methods equivalent to those of the Collection View, Diffable Data Source, as well as a new delegate and prefetching data source protocols. The downside of that approach are of course that SectionKit must always be catching up with the new Collection View and related objects' APIs. However, that is preferable to accomplish the design philosophy approach.
