part of 'data_list_imports.dart';

class DataListView extends StatefulWidget {
  const DataListView({super.key});

  @override
  DataListViewState createState() => DataListViewState();
}

class DataListViewState extends State<DataListView> {
  final ScrollController _scrollController = ScrollController();
  List<int> items = List.generate(20, (index) => index); // Initial 20 items
  final GenericBloc<bool> isLoadingMoreBloc = GenericBloc<bool>(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 30 &&
        !isLoadingMoreBloc.state.data) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    isLoadingMoreBloc.onUpdateData(true);
    Future.delayed(const Duration(seconds: 2), () {
      items.addAll(List.generate(
          20, (index) => items.length + index)); // Load 20 more items
      isLoadingMoreBloc.onUpdateData(false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          const SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 50.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Data List'),
            ),
          ),
          BlocBuilder<GenericBloc<bool>, GenericState<bool>>(
              bloc: isLoadingMoreBloc,
              builder: (context, state) {
                bool isLoadingData = isLoadingMoreBloc.state.data;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Check if index is within the items range
                      if (index == items.length) {
                        return isLoadingData
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink();
                      }

                      // Ensure each item has a unique and stable key
                      return ItemWidget(
                        key: ValueKey<int>(items[index]),
                        index: items[index],
                      );
                    },
                    childCount: items.length +
                        (isLoadingMoreBloc.state.data
                            ? 1
                            : 0), // Adjust child count dynamically
                  ),
                );
              }),
        ],
      ),
    );
  }
}
