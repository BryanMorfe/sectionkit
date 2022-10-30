# ``SectionKit``

UIKit extension to modularize app with single-responsibility reusable collection view sections.

## Overview

SectionKit provides a modular way to architecture your apps' collection views. The philosophy
behind it is simply; all sections on a view controller should be reusable across the app, and
should not be concerned with other sections. In addition, a container for sections should not
have to manage the details of how sections are layed out, or which cells or reusable views
are displayed in a given section.

![SectionKit mocks](SectionKit)

SectionKit takes advantage of compositional layouts and diffable data sources and takes it one
step further by decoupling the layout and content of the collection view from the collection
view itself. To explore the advantages of using SectionKit and the problems it solves, please read
<doc:ModularAppWithSectionKit>.

## Topics

### Getting Started

- <doc:ModularAppWithSectionKit>
- ``CollectionSectionController``
- ``CollectionSectionProvider``

### Handling Messages From Section Controller on Behalf of Section Provider

- ``CollectionSectionControllerDelegate``
- ``CollectionSectionControllerDataSourcePrefetching``
