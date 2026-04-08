import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  runApp(const TrainerApp());
}

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ChatBloc()),
        BlocProvider(create: (_) => ScheduleBloc()),
        BlocProvider(create: (_) => SessionBloc()),
        BlocProvider(create: (_) => CallBloc()),
      ],
      child: MaterialApp(
        title: 'Trainer App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildTheme(isTrainer: true),
        home: const AppRoot(),
      ),
    );
  }
}
