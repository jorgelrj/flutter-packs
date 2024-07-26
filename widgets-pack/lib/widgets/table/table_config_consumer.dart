part of 'table_widget.dart';

class _DatasourceConfigConsumer<M extends Object, T> extends StatefulWidget {
  final T Function(TableDataSource<M> dataSource) selector;
  final Widget Function(BuildContext context, T value) builder;

  const _DatasourceConfigConsumer({
    required this.selector,
    required this.builder,
    super.key,
  });

  @override
  State<_DatasourceConfigConsumer<M, T>> createState() => _DatasourceConfigConsumerState<M, T>();
}

class _DatasourceConfigConsumerState<M extends Object, T> extends State<_DatasourceConfigConsumer<M, T>> {
  late T _config;

  late final TableDataSource<M> _dataSource = context.tableDataSource<M>();

  void _datasourceListener() {
    final newValue = widget.selector(_dataSource);

    if (newValue != _config) {
      setState(() {
        _config = newValue;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _config = widget.selector(_dataSource);
    _dataSource.addListener(_datasourceListener);
  }

  @override
  void dispose() {
    super.dispose();

    _dataSource.removeListener(_datasourceListener);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _config,
    );
  }
}
