To build a **clean architecture** Flutter app using **BLoC** (Business Logic Component) and **GetIt** (for dependency injection), you can structure your project to ensure separation of concerns, testability, and scalability. Below is a recommended clean architecture setup tailored for your requirements:

---

### **Clean Architecture Overview**
Clean architecture divides the app into layers, each with a specific responsibility:
1. **Presentation Layer**: Handles UI and user interactions (Widgets, BLoC).
2. **Domain Layer**: Contains business logic (Use Cases, Entities).
3. **Data Layer**: Manages data sources (Repositories, APIs, Local Storage).

The layers follow the **Dependency Rule**: Outer layers depend on inner layers, but inner layers (like Domain) are independent.

---

### **Recommended Project Structure**

```
my_app/
├── lib/
│   ├── core/
│   │   ├── di/                     # Dependency Injection setup
│   │   ├── error/                  # Custom exceptions and error handling
│   │   ├── network/                # Network configuration (e.g., Dio setup)
│   │   └── utils/                  # Helper classes, constants, etc.
│   ├── features/
│   │   ├── feature_name/           # Feature-specific folder (e.g., auth, todo)
│   │   │   ├── data/
│   │   │   │   ├── datasources/   # Local (Hive, SharedPreferences) or Remote (API)
│   │   │   │   ├── models/        # Data models (JSON parsing)
│   │   │   │   └── repositories/  # Repository implementations
│   │   │   ├── domain/
│   │   │   │   ├── entities/      # Pure business objects
│   │   │   │   ├── repositories/  # Abstract repository interfaces
│   │   │   │   └── usecases/      # Business logic (use cases)
│   │   │   ├── presentation/
│   │   │   │   ├── bloc/          # BLoC for state management
│   │   │   │   ├── pages/         # Screens or pages
│   │   │   │   └── widgets/       # Reusable UI components
│   │   └── another_feature/        # Another feature folder
│   ├── app.dart                    # App widget (root)
│   └── main.dart                   # Entry point
├── test/                           # Unit and widget tests
└── pubspec.yaml
```

---

### **Detailed Breakdown**

#### **1. Core Layer**
This contains cross-cutting concerns used across features.

- **`core/di/injection.dart`**:
  Use **GetIt** to register dependencies (singletons, factories, etc.).
  ```dart
  import 'package:get_it/get_it.dart';
  import 'package:dio/dio.dart';
  import '../features/feature_name/data/datasources/remote_data_source.dart';
  import '../features/feature_name/data/repositories/repository_impl.dart';
  import '../features/feature_name/domain/repositories/repository.dart';
  import '../features/feature_name/domain/usecases/get_data.dart';
  import '../features/feature_name/presentation/bloc/feature_bloc.dart';

  final sl = GetIt.instance;

  void init() {
    // BLoC
    sl.registerFactory(() => FeatureBloc(getData: sl()));

    // Use Cases
    sl.registerLazySingleton(() => GetData(sl()));

    // Repository
    sl.registerLazySingleton<FeatureRepository>(
      () => FeatureRepositoryImpl(remoteDataSource: sl()),
    );

    // Data Sources
    sl.registerLazySingleton<RemoteDataSource>(
      () => RemoteDataSourceImpl(dio: sl()),
    );

    // External
    sl.registerLazySingleton(() => Dio());
  }
  ```

- **`core/error/exceptions.dart`**:
  Define custom exceptions (e.g., `ServerException`, `CacheException`).

- **`core/network/network_info.dart`**:
  Handle network connectivity checks (optional, e.g., using `connectivity_plus`).

- **`core/utils/`**:
  Constants, logger, or helper functions.

#### **2. Data Layer**
Handles data retrieval and storage.

- **`data/datasources/`**:
    - **`remote_data_source.dart`**:
      Interfaces with APIs (e.g., using Dio).
      ```dart
      abstract class RemoteDataSource {
        Future<SomeModel> fetchData();
      }
  
      class RemoteDataSourceImpl implements RemoteDataSource {
        final Dio dio;
        RemoteDataSourceImpl({required this.dio});
  
        @override
        Future<SomeModel> fetchData() async {
          final response = await dio.get('https://api.example.com/data');
          return SomeModel.fromJson(response.data);
        }
      }
      ```
    - **`local_data_source.dart`** (optional):
      Interfaces with local storage (e.g., SharedPreferences, Hive).

- **`data/models/`**:
    - **`some_model.dart`**:
      Data models for JSON serialization.
      ```dart
      class SomeModel {
        final String id;
        final String name;
  
        SomeModel({required this.id, required this.name});
  
        factory SomeModel.fromJson(Map<String, dynamic> json) {
          return SomeModel(id: json['id'], name: json['name']);
        }
  
        Map<String, dynamic> toJson() => {'id': id, 'name': name};
      }
      ```

- **`data/repositories/`**:
    - **`repository_impl.dart`**:
      Implements the domain repository interface, bridging data sources.
      ```dart
      class FeatureRepositoryImpl implements FeatureRepository {
        final RemoteDataSource remoteDataSource;
  
        FeatureRepositoryImpl({required this.remoteDataSource});
  
        @override
        Future<Either<Failure, SomeEntity>> getData() async {
          try {
            final model = await remoteDataSource.fetchData();
            return Right(model.toEntity());
          } catch (e) {
            return Left(ServerFailure());
          }
        }
      }
      ```

#### **3. Domain Layer**
The core of the app, independent of frameworks or external systems.

- **`domain/entities/`**:
    - **`some_entity.dart`**:
      Pure business objects (no dependencies).
      ```dart
      class SomeEntity {
        final String id;
        final String name;
  
        SomeEntity({required this.id, required this.name});
      }
      ```

- **`domain/repositories/`**:
    - **`repository.dart`**:
      Abstract interfaces for repositories.
      ```dart
      abstract class FeatureRepository {
        Future<Either<Failure, SomeEntity>> getData();
      }
      ```

- **`domain/usecases/`**:
    - **`get_data.dart`**:
      Encapsulates a single business rule.
      ```dart
      class GetData {
        final FeatureRepository repository;
  
        GetData(this.repository);
  
        Future<Either<Failure, SomeEntity>> call() async {
          return await repository.getData();
        }
      }
      ```

- **Error Handling**:
  Use a `Failure` class for error handling (e.g., with `dartz` for `Either`).
  ```dart
  abstract class Failure {}
  class ServerFailure extends Failure {}
  class CacheFailure extends Failure {}
  ```

#### **4. Presentation Layer**
Handles UI and state management using BLoC.

- **`presentation/bloc/`**:
    - **`feature_bloc.dart`**:
      Manages state and events.
      ```dart
      import 'package:flutter_bloc/flutter_bloc.dart';
      import '../../domain/usecases/get_data.dart';
      import 'feature_event.dart';
      import 'feature_state.dart';
  
      class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
        final GetData getData;
  
        FeatureBloc({required this.getData}) : super(FeatureInitial()) {
          on<FetchDataEvent>(_onFetchData);
        }
  
        Future<void> _onFetchData(FetchDataEvent event, Emitter<FeatureState> emit) async {
          emit(FeatureLoading());
          final result = await getData();
          result.fold(
            (failure) => emit(FeatureError('Failed to load data')),
            (data) => emit(FeatureLoaded(data)),
          );
        }
      }
      ```

    - **`feature_event.dart`**:
      ```dart
      abstract class FeatureEvent {}
      class FetchDataEvent extends FeatureEvent {}
      ```

    - **`feature_state.dart`**:
      ```dart
      abstract class FeatureState {}
      class FeatureInitial extends FeatureState {}
      class FeatureLoading extends FeatureState {}
      class FeatureLoaded extends FeatureState {
        final SomeEntity data;
        FeatureLoaded(this.data);
      }
      class FeatureError extends FeatureState {
        final String message;
        FeatureError(this.message);
      }
      ```

- **`presentation/pages/`**:
    - **`feature_page.dart`**:
      UI that interacts with the BLoC.
      ```dart
      import 'package:flutter/material.dart';
      import 'package:flutter_bloc/flutter_bloc.dart';
      import '../bloc/feature_bloc.dart';
      import '../bloc/feature_event.dart';
      import '../bloc/feature_state.dart';
  
      class FeaturePage extends StatelessWidget {
        @override
        Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(title: Text('Feature')),
            body: BlocProvider(
              create: (_) => context.read<FeatureBloc>()..add(FetchDataEvent()),
              child: BlocBuilder<FeatureBloc, FeatureState>(
                builder: (context, state) {
                  if (state is FeatureLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is FeatureLoaded) {
                    return Center(child: Text(state.data.name));
                  } else if (state is FeatureError) {
                    return Center(child: Text(state.message));
                  }
                  return Container();
                },
              ),
            ),
          );
        }
      }
      ```

- **`presentation/widgets/`**:
  Reusable UI components (e.g., custom buttons, cards).

#### **5. Main and App Setup**

- **`main.dart`**:
  Initialize GetIt and run the app.
  ```dart
  import 'package:flutter/material.dart';
  import 'core/di/injection.dart' as di;
  import 'app.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await di.init();
    runApp(MyApp());
  }
  ```

- **`app.dart`**:
  Root widget with app-wide setup (e.g., theme, routing).
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:get_it/get_it.dart';
  import 'features/feature_name/presentation/bloc/feature_bloc.dart';
  import 'features/feature_name/presentation/pages/feature_page.dart';

  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        theme: ThemeData.light(),
        home: BlocProvider(
          create: (_) => GetIt.instance<FeatureBloc>(),
          child: FeaturePage(),
        ),
      );
    }
  }
  ```

---

### **Key Points for BLoC and GetIt Integration**

1. **BLoC**:
    - Use BLoC for state management in the presentation layer.
    - Each feature has its own BLoC, handling events and emitting states.
    - Inject use cases into BLoC via GetIt for loose coupling.

2. **GetIt**:
    - Centralize dependency injection in `core/di/injection.dart`.
    - Register dependencies as singletons (e.g., Dio, repositories) or factories (e.g., BLoCs).
    - Initialize GetIt in `main.dart` before running the app.

3. **Error Handling**:
    - Use `dartz` for functional error handling (`Either<Failure, Result>`).
    - Map exceptions to user-friendly messages in the presentation layer.

4. **Testing**:
    - **Domain Layer**: Test use cases and entities (pure Dart, no dependencies).
    - **Data Layer**: Mock data sources to test repositories.
    - **Presentation Layer**: Test BLoC with `bloc_test` and widgets with `flutter_test`.

5. **Scalability**:
    - Group code by feature for modularity.
    - Avoid tight coupling between layers using abstractions (e.g., repository interfaces).

---

### **Recommended Packages**

- **flutter_bloc**: For state management.
- **get_it**: For dependency injection.
- **dartz**: For functional programming (`Either`).
- **dio**: For HTTP requests.
- **equatable**: For value comparison in BLoC states/events.
- **mockito** or **mocktail**: For mocking in tests.
- **connectivity_plus** (optional): For network checks.
- **shared_preferences** or **hive** (optional): For local storage.

Add these to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  get_it: ^7.6.0
  dartz: ^0.10.1
  dio: ^5.3.3
  equatable: ^2.0.5

dev_dependencies:
  mockito: ^5.4.2
  bloc_test: ^9.1.4
  flutter_test:
    sdk: flutter
```

---

### **Example Workflow**
Let’s say you’re building a **Todo** feature:

1. **Domain**:
    - Entity: `TodoEntity(id, title, isCompleted)`.
    - Use Case: `GetTodos` fetches a list of todos.
    - Repository: `TodoRepository` with `getTodos()`.

2. **Data**:
    - Model: `TodoModel` for JSON parsing.
    - Data Source: `RemoteTodoDataSource` calls an API.
    - Repository Impl: `TodoRepositoryImpl` uses the data source.

3. **Presentation**:
    - BLoC: `TodoBloc` with events (`FetchTodosEvent`) and states (`TodosLoaded`, `TodosError`).
    - UI: `TodoPage` displays a list of todos and handles loading/error states.

4. **DI**:
    - Register `TodoBloc`, `GetTodos`, `TodoRepository`, and `RemoteTodoDataSource` in GetIt.

---

### **Why This Setup?**
- **Separation of Concerns**: Each layer has a clear responsibility.
- **Testability**: Domain is pure Dart, and data/presentation layers are mockable.
- **Scalability**: Feature-based structure supports adding new features easily.
- **Maintainability**: BLoC isolates state, and GetIt simplifies dependency management.

If you need a specific feature example (e.g., authentication, CRUD), let me know, and I can provide a detailed implementation!
