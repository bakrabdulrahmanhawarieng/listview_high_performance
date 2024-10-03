part of 'widgets_imports.dart';

class ItemWidget extends StatefulWidget {
  final int index;
  const ItemWidget({super.key, required this.index});

  @override
  ItemWidgetState createState() => ItemWidgetState();
}

class ItemWidgetState extends State<ItemWidget> {
  late Timer _timer;
  final GenericBloc<int> remainingTimeBloc =
      GenericBloc<int>(60); // Initial countdown for each item

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheImage();
  }

  void _precacheImage() {
    precacheImage(
        const NetworkImage(
            'https://miro.medium.com/v2/resize:fit:1400/1*D_d4QYSvdh042zATpNFYTg.gif'),
        context);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTimeBloc.state.data > 0) {
        remainingTimeBloc.onUpdateData(remainingTimeBloc.state.data - 1);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('item-${widget.index}'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0) {
          _timer.cancel(); // Stop timer when item is not visible
        } else {
          if (!_timer.isActive) {
            _startTimer(); // Resume timer when item becomes visible
          }
        }
      },
      child: RepaintBoundary(
        child: ListTile(
          leading: CachedNetworkImage(
            imageUrl:
                'https://miro.medium.com/v2/resize:fit:1400/1*D_d4QYSvdh042zATpNFYTg.gif',
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          title: Text('Item ${widget.index}'),
          subtitle: BlocBuilder<GenericBloc<int>, GenericState<int>>(
              bloc: remainingTimeBloc,
              builder: (context, state) {
                int dataTime = state.data;
                return Text('Countdown: $dataTime seconds');
              }),
        ),
      ),
    );
  }
}
