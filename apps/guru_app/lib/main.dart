import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();

  // Create repository instances
  final authRepo = AuthRepositoryImpl();
  final chatRepo = ChatRepositoryImpl();
  final scheduleRepo = ScheduleRepositoryImpl();
  final sessionRepo = SessionRepositoryImpl();
  final callRepo = CallRepositoryImpl();
  final syncRepo = SyncRepositoryImpl();

  runApp(GuruApp(
    authRepo: authRepo,
    chatRepo: chatRepo,
    scheduleRepo: scheduleRepo,
    sessionRepo: sessionRepo,
    callRepo: callRepo,
    syncRepo: syncRepo,
  ));
}

class GuruApp extends StatelessWidget {
  final AuthRepository authRepo;
  final ChatRepository chatRepo;
  final ScheduleRepository scheduleRepo;
  final SessionRepository sessionRepo;
  final CallRepository callRepo;
  final SyncRepository syncRepo;

  const GuruApp({
    super.key,
    required this.authRepo,
    required this.chatRepo,
    required this.scheduleRepo,
    required this.sessionRepo,
    required this.callRepo,
    required this.syncRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(
          authRepo: authRepo,
          chatRepo: chatRepo,
          scheduleRepo: scheduleRepo,
          sessionRepo: sessionRepo,
          syncRepo: syncRepo,
        )),
        BlocProvider(create: (_) => ChatBloc(
          chatRepo: chatRepo,
          authRepo: authRepo,
        )),
        BlocProvider(create: (_) => ScheduleBloc(
          scheduleRepo: scheduleRepo,
          authRepo: authRepo,
        )),
        BlocProvider(create: (_) => SessionBloc(
          sessionRepo: sessionRepo,
          authRepo: authRepo,
        )),
        BlocProvider(create: (_) => CallBloc(
          callRepo: callRepo,
          authRepo: authRepo,
        )),
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
