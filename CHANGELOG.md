## 0.0.1

* Provide a route delegate.
* Enable inner navigation.
* Enable navigation stack history saved.

## 0.0.2

* Added ScopedPageBuilder which provide functionality to get notified when initial page has been exited.
* Added widget tests that cover the new ScopedPageBuilder functionality.
* Renamed the JsonPojoConverter to DestinationArgumentConverter to unify the api and make it more clear.

## 0.0.3

* Update DBNavigationObserver to check initial destination by path rather than destination equality.

## 0.0.4

* Disallow closing a screen which is the only one in the page stack.
* Provide possibility to close all page until a specific page is displayed.

## 0.0.5

* Provide option to retrieve the root DBRouterDelegate in tree of DBRouterDelegate for example nested navigation.

## 0.0.6

* Added check if completer is future is not completed before completing it. This might happen if the pages that had
  pending future have been disposed. 

## 0.0.7

* Fixed DBRouterDelegate not updating the UI after closeUntil called.

## 0.0.8

* Allow close until last page in stack.

## 0.0.9

* Allow custom navigator observers to be provided.

## 0.0.10

* Added support for didRemove in DBNavigationObserver.

## 0.0.11

* Added support for reset, that reset the state of the DBNavigationObserver.
* Added support for addAll, that add more ScopedPageBuilders to DBNavigationObserver.
* Added support for custom navigation observer for the DBRouterDelegate.
* Added support for dispose for the DBRouterDelegate, this is useful in a tree of DBRouterDelegate.
* Added scopeName getter to ScopedPageBuilder, so they can be differentiated.
* Fixed issue in DBNavigationObserver when the observer page builder list has changed but the event to exit ongoing
  scope has not yet been dispatched.

## 0.0.12

* Updated dependencies of the library.
* Update code to match new lint rules.

## 0.0.13

* Added closeUntilLast functionality.
* Added DBRouterDelegateCantClosePageException so that in release mode, we can also be aware of wrong usage.

## 0.1.0

* Update the library to provide support for both Material and Cupertino.
* Updated algorithm logic for scoped page builder entering and exiting events.
* Added default db page transitions for both material and cupertino.
* Fixed example for arguments.

## 0.1.1

* Added support for restoration scope id for DBRouterDelegate.
* Added support for out of box widget that provide nested navigation functionality out of the box.
* Added support for disposing of DBRouterDelegate.

## 0.1.2

* Added support for sync and async type of destination factory
* Added support for page builder scope exiting events when reset is called. (This provides better support for DI scopes)
