import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_routes.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const MusicoApp());
}

class MusicoApp extends StatelessWidget {
  const MusicoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Adicione outros providers aqui conforme necessário
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Músico App',
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                elevation: 1,
                centerTitle: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
                titleTextStyle: TextStyle(
                  color: Colors.indigo,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.indigo),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
              ),
              scaffoldBackgroundColor: Colors.grey[50],
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: authProvider.isAuthenticated 
                ? AppRoutes.musicians 
                : AppRoutes.login,
            routes: AppRoutes.getRoutes(),
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
