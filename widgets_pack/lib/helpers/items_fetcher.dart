sealed class AppItemsFetcher<T> {
  const AppItemsFetcher();
}

class AppLocalItemsFetcher<T> extends AppItemsFetcher<T> {
  final List<T> items;

  const AppLocalItemsFetcher(
    this.items,
  );
}

abstract class AppRemoteItemsFetcher<T> extends AppItemsFetcher<T> {
  const AppRemoteItemsFetcher();
}

class AppRemoteListItemsFetcher<T> extends AppRemoteItemsFetcher<T> {
  final Future<List<T>> Function() getItems;

  const AppRemoteListItemsFetcher(
    this.getItems,
  );
}

class AppRemoteSearchListItemsFetcher<T> extends AppRemoteItemsFetcher<T> {
  final Future<List<T>> Function(String search) getItems;
  final String? searchHint;

  const AppRemoteSearchListItemsFetcher(
    this.getItems, {
    this.searchHint,
  });
}
