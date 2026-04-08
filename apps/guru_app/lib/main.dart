import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  runApp(const GuruApp());
}

class GuruApp extends StatelessWidget {
  const GuruApp({super.key});

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
        title: 'Guru App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildTheme(isTrainer: false),
        home: const AppRoot(),
      ),
    );
  }
}
