import 'package:db_navigator/src/db_page_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:db_navigator/src/destination.dart';
import 'package:db_navigator/src/db_page.dart';
import 'package:db_navigator/src/db_router_delegate.dart';

import 'utils.dart';

void main() {
  const List<Destination> destinations = <Destination>[
    Destination(path: Page1.path),
    Destination(path: unknownPath),
    Destination(path: Page2.path)
  ];

  group(
    'getPage',
    () {
      test('should return page if page builder supports destination', () async {
        const List<DBPageBuilder> pageBuilders = <DBPageBuilder>[
          TestPageBuilder(),
        ];

        final DBPage? page =
            await pageBuilders.getPage(const Destination(path: Page2.path));

        expect(page, isNotNull);
        expect(page?.destination.path, equals(Page2.path));
      });

      test(
        'should return null if page builder does not support destination',
        () async {
          const List<DBPageBuilder> pageBuilders = <DBPageBuilder>[
            TestPageBuilder(),
          ];

          final DBPage? page =
              await pageBuilders.getPage(const Destination(path: unknownPath));

          expect(page, isNull);
        },
      );
    },
  );

  group(
    'buildStack',
    () {
      test(
        'should build stack only with pages supported by one of page builders',
        () async {
          const List<DBPageBuilder> pageBuilders = <DBPageBuilder>[
            TestPageBuilder(),
          ];

          final List<DBPage> pageStack =
              await pageBuilders.buildStack(destinations);

          expect(pageStack.length, equals(2));
        },
      );
    },
  );

  group(
    'filterHistory',
    () {
      test(
          'should return only those destinations '
          'that are supported by one of page builders', () {
        const List<DBPageBuilder> pageBuilders = <DBPageBuilder>[
          TestPageBuilder(),
        ];

        final List<Destination> filteredDestination =
            pageBuilders.filterHistory(destinations);

        expect(filteredDestination.length, equals(destinations.length - 1));
      });

      test(
        'should not include destinations that are not supported '
        'at by page builders',
        () {
          const List<DBPageBuilder> pageBuilders = <DBPageBuilder>[
            TestPageBuilder(),
          ];

          final int lengthBeforeFiltering = destinations.length;

          final List<Destination> filteredDestinations =
              pageBuilders.filterHistory(destinations);

          expect(filteredDestinations.length, lessThan(lengthBeforeFiltering));

          expect(
            filteredDestinations
                .where((Destination dest) =>
                    dest.path == Page1.path || dest.path == Page2.path),
            hasLength(2),
          );

          expect(
            filteredDestinations
                .where((Destination dest) => dest.path == unknownPath),
            isEmpty,
          );
        },
      );
    },
  );
}
