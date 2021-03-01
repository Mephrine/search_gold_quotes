import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:search_gold_quotes/app/domain/entities/home_data.dart';
import 'package:search_gold_quotes/app/number_trivia/presentation/widgets/loading_widget.dart';
import 'package:search_gold_quotes/app/number_trivia/presentation/widgets/message_display.dart';
import 'package:search_gold_quotes/app/presentation/pages/main/home/home/home_bloc.dart';
import 'package:search_gold_quotes/core/di/injection_container.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => container<HomeBloc>(),
      child: HomeContainer(),
    );
  }
}


class HomeContainer extends StatefulWidget {
  @override
  _HomeContainer createState() => _HomeContainer();
}

class _HomeContainer extends State<HomeContainer> {
  @override
  void initState() {
    super.initState();
    _dispatchHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (bloc, state) {
      if (state is Empty) {
        return Container();
      } else if (state is Loading) {
        return LoadingWidget();
      } else if (state is Loaded) {
        return _HomeLoadedWidget(homeData: state.homeData);
      } else if (state is Error) {
        return MessageDisplay(message: state.message);
      }
    }
    );
  }

  void _dispatchHomeData() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<HomeBloc>(context, listen: false)
          .add(GetHomeData());
    });
  }
}

class _HomeLoadedWidget extends StatelessWidget {
  final HomeData homeData;

  _HomeLoadedWidget({
    @required this.homeData
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Text(
              homeData.famousQuotes,
            style: TextStyle(

            ),
          ),
          Text(homeData.referenceSiteName,
            style: TextStyle(

            )),
          LineChart(
            LineChartData(
              // read about it in the below section
            ),
          ),
        ]
    );
  }
}