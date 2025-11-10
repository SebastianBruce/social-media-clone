import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_clone/features/auth/data/firebase_auth_repo.dart';
import 'package:social_media_clone/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_clone/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_media_clone/features/auth/presentation/pages/auth_page.dart';
import 'package:social_media_clone/features/post/home/pages/home_page.dart';
import 'package:social_media_clone/themes/light_mode.dart';

/*

APP -  Root Level

-------------------------------------------------------------------------

Repositories: for the database
- firebase

Bloc Providers: for state management
- auth
- profile
- post
- search
- theme

Check Auth State
- unauthenticated -> auth page (login/register)
- authenticated -> home page

*/

class MyApp extends StatelessWidget {
  // auth repo
  final authRepo = FirebaseAuthRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // provide cubit to app
    return BlocProvider(
      create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,

        // unauthenticated -> auth page (login/register)
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, authState) {
            print(authState);
            if (authState is Unauthenticated) {
              return const AuthPage();
            }

            // authenticated -> home page
            if (authState is Authenticated) {
              return const HomePage();
            }
            // loading...
            else {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
          },

          // listen for errors..
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ),
    );
  }
}
