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