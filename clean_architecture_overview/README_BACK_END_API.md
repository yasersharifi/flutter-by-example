To create a **Flutter app** with **clean architecture**, using **Cubit** (from `flutter_bloc: ^9.0.0` or newer) for state management, **GetIt** for dependency injection, **SQLite** and **SharedPreferences** for local storage, a **backend API** for remote data, **dark and light themes**, and **input validation** for user inputs, we’ll design a modular, testable, and scalable structure. This setup incorporates your requirements, including using Cubit instead of full Bloc to simplify state management, and validates input (e.g., todo title) to ensure data integrity.

---

### **Clean Architecture Overview**
Clean architecture divides the app into three layers:
1. **Presentation Layer**: Manages UI (widgets, themes) and state (Cubit).
2. **Domain Layer**: Contains business logic (use cases, entities), independent of frameworks.
3. **Data Layer**: Handles data sources (SQLite, SharedPreferences, API).

The **Dependency Rule** ensures outer layers depend on the inner domain layer, keeping it pure.

---

### **Project Structure**

Here’s the folder structure, tailored for a **Todo** feature:

```
my_app/
├── lib/
│   ├── core/
│   │   ├── di/                     # GetIt setup
│   │   ├── error/                  # Exceptions and failures
│   │   ├── network/                # Dio for API
│   │   ├── theme/                  # Theme data
│   │   └── utils/                  # Validators, helpers
│   ├── features/
│   │   ├── todo/                   # Todo feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── local_data_source.dart      # SQLite
│   │   │   │   │   ├── remote_data_source.dart     # API
│   │   │   │   │   └── settings_data_source.dart   # SharedPreferences
│   │   │   │   ├── models/        # Data models
│   │   │   │   └── repositories/  # Repository impl
│   │   │   ├── domain/
│   │   │   │   ├── entities/      # Entities
│   │   │   │   ├── repositories/  # Abstract repos
│   │   │   │   └── usecases/      # Business logic
│   │   │   ├── presentation/
│   │   │   │   ├── cubit/         # Cubit for state
│   │   │   │   ├── pages/         # Screens
│   │   │   │   └── widgets/       # UI components
│   ├── app.dart                    # Root widget
│   └── main.dart                   # Entry point
├── test/                           # Tests
└── pubspec.yaml
```

---

### **Implementation Details**

We’ll implement a **Todo** feature that:
- Stores todos in **SQLite** and syncs with a **backend API**.
- Uses **SharedPreferences** for theme mode (dark/light/system) and todo filter (all, completed, incompleted).
- Supports **dark and light themes** with a toggle.
- Uses **Cubit** for state management and **GetIt** for dependency injection.
- Validates the todo title input:
    - Not empty.
    - Minimum 3 characters, maximum 50.
    - Only alphanumeric and spaces.

#### **1. Dependencies**
In `pubspec.yaml`, use the latest `flutter_bloc` and required packages:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^9.0.0
  get_it: ^7.6.0
  dartz: ^0.10.1
  equatable: ^2.0.5
  sqflite: ^2.3.0
  path: ^1.8.3
  shared_preferences: ^2.2.2
  dio: ^5.3.3
  uuid: ^4.0.0

dev_dependencies:
  mockito: ^5.4.2
  bloc_test: ^10.0.0
  flutter_test:
    sdk: flutter
```

---

#### **2. Core Layer**

Handles dependency injection, errors, networking, themes, and validation.

##### **Dependency Injection**
- **`core/di/injection.dart`**:
  ```dart
  import 'package:get_it/get_it.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:sqflite/sqflite.dart';
  import 'package:dio/dio.dart';
  import '../features/todo/data/datasources/local_data_source.dart';
  import '../features/todo/data/datasources/remote_data_source.dart';
  import '../features/todo/data/datasources/settings_data_source.dart';
  import '../features/todo/data/repositories/todo_repository_impl.dart';
  import '../features/todo/domain/repositories/todo_repository.dart';
  import '../features/todo/domain/usecases/get_todos.dart';
  import '../features/todo/domain/usecases/save_todo.dart';
  import '../features/todo/domain/usecases/set_theme_mode.dart';
  import '../features/todo/domain/usecases/set_todo_filter.dart';
  import '../features/todo/presentation/cubit/todo_cubit.dart';
  import '../network/dio_client.dart';

  final sl = GetIt.instance;

  Future<void> init() async {
    // Cubit
    sl.registerFactory(() => TodoCubit(
          getTodos: sl(),
          saveTodo: sl(),
          setTodoFilter: sl(),
          setThemeMode: sl(),
        ));

    // Use Cases
    sl.registerLazySingleton(() => GetTodos(sl()));
    sl.registerLazySingleton(() => SaveTodo(sl()));
    sl.registerLazySingleton(() => SetTodoFilter(sl()));
    sl.registerLazySingleton(() => SetThemeMode(sl()));

    // Repository
    sl.registerLazySingleton<TodoRepository>(
      () => TodoRepositoryImpl(
        localDataSource: sl(),
        remoteDataSource: sl(),
        settingsDataSource: sl(),
      ),
    );

    // Data Sources
    sl.registerLazySingleton<LocalDataSource>(
      () => LocalDataSourceImpl(database: sl()),
    );
    sl.registerLazySingleton<RemoteDataSource>(
      () => RemoteDataSourceImpl(dio: sl()),
    );
    sl.registerLazySingleton<SettingsDataSource>(
      () => SettingsDataSourceImpl(prefs: sl()),
    );

    // External
    sl.registerSingletonAsync<Database>(() async {
      final database = await openDatabase(
        join(await getDatabasesPath(), 'todo_database.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE todos(id TEXT PRIMARY KEY, title TEXT, isCompleted INTEGER)',
          );
        },
        version: 1,
      );
      return database;
    });

    sl.registerSingletonAsync<SharedPreferences>(() async {
      return await SharedPreferences.getInstance();
    });

    sl.registerLazySingleton<Dio>(() => DioClient().dio);

    await sl.allReady();
  }
  ```

##### **Error Handling**
- **`core/error/exceptions.dart`**:
  ```dart
  class DatabaseException implements Exception {
    final String message;
    DatabaseException(this.message);
  }

  class CacheException implements Exception {
    final String message;
    CacheException(this.message);
  }

  class ServerException implements Exception {
    final String message;
    ServerException(this.message);
  }
  ```

- **`core/error/failures.dart`**:
  ```dart
  abstract class Failure {}
  class DatabaseFailure extends Failure {}
  class CacheFailure extends Failure {}
  class ServerFailure extends Failure {}
  class ValidationFailure extends Failure {
    final String message;
    ValidationFailure(this.message);
  }
  ```

##### **Networking**
- **`core/network/dio_client.dart`**:
  ```dart
  import 'package:dio/dio.dart';

  class DioClient {
    final Dio dio;

    DioClient()
        : dio = Dio(
            BaseOptions(
              baseUrl: 'https://api.example.com', // Replace with your API
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 3),
            ),
          );
  }
  ```

##### **Theme Management**
- **`core/theme/app_theme.dart`**:
  ```dart
  import 'package:flutter/material.dart';

  class AppTheme {
    static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    );

    static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blueGrey,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );
  }
  ```

##### **Validation Utility**
- **`core/utils/validators.dart`**:
  ```dart
  class Validators {
    static String? validateTodoTitle(String? value) {
      if (value == null || value.isEmpty) {
        return 'Title cannot be empty';
      }
      if (value.length < 3) {
        return 'Title must be at least 3 characters';
      }
      if (value.length > 50) {
        return 'Title cannot exceed 50 characters';
      }
      if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
        return 'Title can only contain letters, numbers, and spaces';
      }
      return null;
    }
  }
  ```

---

#### **3. Data Layer**

Manages **SQLite**, **API**, and **SharedPreferences**. Validation doesn’t affect this layer directly.

##### **Data Sources**
- **`features/todo/data/datasources/local_data_source.dart`** (SQLite):
  ```dart
  import 'package:sqflite/sqflite.dart';
  import '../../../../core/error/exceptions.dart';
  import '../models/todo_model.dart';

  abstract class LocalDataSource {
    Future<List<TodoModel>> getTodos();
    Future<void> saveTodo(TodoModel todo);
    Future<void> cacheTodos(List<TodoModel> todos);
  }

  class LocalDataSourceImpl implements LocalDataSource {
    final Database database;

    LocalDataSourceImpl({required this.database});

    @override
    Future<List<TodoModel>> getTodos() async {
      try {
        final result = await database.query('todos');
        return result.map((json) => TodoModel.fromJson(json)).toList();
      } catch (e) {
        throw DatabaseException('Failed to fetch todos: $e');
      }
    }

    @override
    Future<void> saveTodo(TodoModel todo) async {
      try {
        await database.insert(
          'todos',
          todo.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        throw DatabaseException('Failed to save todo: $e');
      }
    }

    @override
    Future<void> cacheTodos(List<TodoModel> todos) async {
      try {
        await database.delete('todos');
        for (var todo in todos) {
          await database.insert('todos', todo.toJson());
        }
      } catch (e) {
        throw DatabaseException('Failed to cache todos: $e');
      }
    }
  }
  ```

- **`features/todo/data/datasources/remote_data_source.dart`** (API):
  ```dart
  import 'package:dio/dio.dart';
  import '../../../../core/error/exceptions.dart';
  import '../models/todo_model.dart';

  abstract class RemoteDataSource {
    Future<List<TodoModel>> getTodos();
    Future<void> saveTodo(TodoModel todo);
  }

  class RemoteDataSourceImpl implements RemoteDataSource {
    final Dio dio;

    RemoteDataSourceImpl({required this.dio});

    @override
    Future<List<TodoModel>> getTodos() async {
      try {
        final response = await dio.get('/todos');
        return (response.data as List).map((json) => TodoModel.fromJson(json)).toList();
      } catch (e) {
        throw ServerException('Failed to fetch todos: $e');
      }
    }

    @override
    Future<void> saveTodo(TodoModel todo) async {
      try {
        await dio.post('/todos', data: todo.toJson());
      } catch (e) {
        throw ServerException('Failed to save todo: $e');
      }
    }
  }
  ```

- **`features/todo/data/datasources/settings_data_source.dart`** (SharedPreferences):
  ```dart
  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../../../../core/error/exceptions.dart';

  enum TodoFilter { all, completed, incompleted }

  abstract class SettingsDataSource {
    Future<TodoFilter> getTodoFilter();
    Future<void> saveTodoFilter(TodoFilter filter);
    Future<ThemeMode> getThemeMode();
    Future<void> saveThemeMode(ThemeMode mode);
  }

  class SettingsDataSourceImpl implements SettingsDataSource {
    final SharedPreferences prefs;

    SettingsDataSourceImpl({required this.prefs});

    @override
    Future<TodoFilter> getTodoFilter() async {
      try {
        final filterString = prefs.getString('todo_filter') ?? 'all';
        return TodoFilter.values.firstWhere((f) => f.toString() == 'TodoFilter.$filterString');
      } catch (e) {
        throw CacheException('Failed to fetch filter: $e');
      }
    }

    @override
    Future<void> saveTodoFilter(TodoFilter filter) async {
      try {
        await prefs.setString('todo_filter', filter.toString().split('.').last);
      } catch (e) {
        throw CacheException('Failed to save filter: $e');
      }
    }

    @override
    Future<ThemeMode> getThemeMode() async {
      try {
        final modeString = prefs.getString('theme_mode') ?? 'system';
        return ThemeMode.values.firstWhere((m) => m.toString() == 'ThemeMode.$modeString');
      } catch (e) {
        throw CacheException('Failed to fetch theme mode: $e');
      }
    }

    @override
    Future<void> saveThemeMode(ThemeMode mode) async {
      try {
        await prefs.setString('theme_mode', mode.toString().split('.').last);
      } catch (e) {
        throw CacheException('Failed to save theme mode: $e');
      }
    }
  }
  ```

##### **Model**
- **`features/todo/data/models/todo_model.dart`**:
  ```dart
  import '../../domain/entities/todo_entity.dart';

  class TodoModel {
    final String id;
    final String title;
    final bool isCompleted;

    TodoModel({
      required this.id,
      required this.title,
      required this.isCompleted,
    });

    factory TodoModel.fromJson(Map<String, dynamic> json) {
      return TodoModel(
        id: json['id'],
        title: json['title'],
        isCompleted: json['isCompleted'] == 1 || json['isCompleted'] == true,
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };
    }

    TodoEntity toEntity() {
      return TodoEntity(
        id: id,
        title: title,
        isCompleted: isCompleted,
      );
    }
  }
  ```

##### **Repository**
- **`features/todo/data/repositories/todo_repository_impl.dart`**:
  ```dart
  import 'package:dartz/dartz.dart';
  import 'package:flutter/material.dart';
  import '../../../../core/error/exceptions.dart';
  import '../../../../core/error/failures.dart';
  import '../../domain/entities/todo_entity.dart';
  import '../../domain/repositories/todo_repository.dart';
  import '../datasources/local_data_source.dart';
  import '../datasources/remote_data_source.dart';
  import '../datasources/settings_data_source.dart';
  import '../models/todo_model.dart';

  class TodoRepositoryImpl implements TodoRepository {
    final LocalDataSource localDataSource;
    final RemoteDataSource remoteDataSource;
    final SettingsDataSource settingsDataSource;

    TodoRepositoryImpl({
      required this.localDataSource,
      required this.remoteDataSource,
      required this.settingsDataSource,
    });

    @override
    Future<Either<Failure, List<TodoEntity>>> getTodos() async {
      try {
        final filter = await settingsDataSource.getTodoFilter();
        try {
          final remoteTodos = await remoteDataSource.getTodos();
          await localDataSource.cacheTodos(remoteTodos);
          return _filterTodos(remoteTodos, filter);
        } catch (e) {
          final localTodos = await localDataSource.getTodos();
          return _filterTodos(localTodos, filter);
        }
      } on DatabaseException {
        return Left(DatabaseFailure());
      } on CacheException {
        return Left(CacheFailure());
      }
    }

    @override
    Future<Either<Failure, void>> saveTodo(TodoEntity todo) async {
      try {
        final todoModel = TodoModel(
          id: todo.id,
          title: todo.title,
          isCompleted: todo.isCompleted,
        );
        await remoteDataSource.saveTodo(todoModel);
        await localDataSource.saveTodo(todoModel);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } on DatabaseException {
        return Left(DatabaseFailure());
      }
    }

    @override
    Future<Either<Failure, void>> setTodoFilter(TodoFilter filter) async {
      try {
        await settingsDataSource.saveTodoFilter(filter);
        return const Right(null);
      } on CacheException {
        return Left(CacheFailure());
      }
    }

    @override
    Future<Either<Failure, ThemeMode>> getThemeMode() async {
      try {
        final mode = await settingsDataSource.getThemeMode();
        return Right(mode);
      } on CacheException {
        return Left(CacheFailure());
      }
    }

    @override
    Future<Either<Failure, void>> setThemeMode(ThemeMode mode) async {
      try {
        await settingsDataSource.saveThemeMode(mode);
        return const Right(null);
      } on CacheException {
        return Left(CacheFailure());
      }
    }

    Future<Either<Failure, List<TodoEntity>>> _filterTodos(List<TodoModel> models, TodoFilter filter) async {
      List<TodoEntity> todos = models.map((model) => model.toEntity()).toList();
      if (filter == TodoFilter.completed) {
        todos = todos.where((todo) => todo.isCompleted).toList();
      } else if (filter == TodoFilter.incompleted) {
        todos = todos.where((todo) => !todo.isCompleted).toList();
      }
      return Right(todos);
    }
  }
  ```

---

#### **4. Domain Layer**

Contains business logic and validation for input.

##### **Entity**
- **`features/todo/domain/entities/todo_entity.dart`**:
  ```dart
  class TodoEntity {
    final String id;
    final String title;
    final bool isCompleted;

    TodoEntity({
      required this.id,
      required this.title,
      required this.isCompleted,
    });

    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
        other is TodoEntity &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            isCompleted == other.isCompleted;

    @override
    int get hashCode => id.hashCode ^ title.hashCode ^ isCompleted.hashCode;
  }
  ```

##### **Repository Interface**
- **`features/todo/domain/repositories/todo_repository.dart`**:
  ```dart
  import 'package:dartz/dartz.dart';
  import 'package:flutter/material.dart';
  import '../../../../core/error/failures.dart';
  import '../entities/todo_entity.dart';
  import '../../data/datasources/settings_data_source.dart';

  abstract class TodoRepository {
    Future<Either<Failure, List<TodoEntity>>> getTodos();
    Future<Either<Failure, void>> saveTodo(TodoEntity todo);
    Future<Either<Failure, void>> setTodoFilter(TodoFilter filter);
    Future<Either<Failure, ThemeMode>> getThemeMode();
    Future<Either<Failure, void>> setThemeMode(ThemeMode mode);
  }
  ```

##### **Use Cases**
- **`features/todo/domain/usecases/get_todos.dart`**:
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../../../core/error/failures.dart';
  import '../entities/todo_entity.dart';
  import '../repositories/todo_repository.dart';

  class GetTodos {
    final TodoRepository repository;

    GetTodos(this.repository);

    Future<Either<Failure, List<TodoEntity>>> call() async {
      return await repository.getTodos();
    }
  }
  ```

- **`features/todo/domain/usecases/save_todo.dart`**:
  Validates input before saving.
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../../../core/error/failures.dart';
  import '../../../../core/utils/validators.dart';
  import '../entities/todo_entity.dart';
  import '../repositories/todo_repository.dart';

  class SaveTodo {
    final TodoRepository repository;

    SaveTodo(this.repository);

    Future<Either<Failure, void>> call(TodoEntity todo) async {
      final validationError = Validators.validateTodoTitle(todo.title);
      if (validationError != null) {
        return Left(ValidationFailure(validationError));
      }
      return await repository.saveTodo(todo);
    }
  }
  ```

- **`features/todo/domain/usecases/set_todo_filter.dart`**:
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../../../core/error/failures.dart';
  import '../../data/datasources/settings_data_source.dart';
  import '../repositories/todo_repository.dart';

  class SetTodoFilter {
    final TodoRepository repository;

    SetTodoFilter(this.repository);

    Future<Either<Failure, void>> call(TodoFilter filter) async {
      return await repository.setTodoFilter(filter);
    }
  }
  ```

- **`features/todo/domain/usecases/set_theme_mode.dart`**:
  ```dart
  import 'package:dartz/dartz.dart';
  import 'package:flutter/material.dart';
  import '../../../../core/error/failures.dart';
  import '../repositories/todo_repository.dart';

  class SetThemeMode {
    final TodoRepository repository;

    SetThemeMode(this.repository);

    Future<Either<Failure, void>> call(ThemeMode mode) async {
      return await repository.setThemeMode(mode);
    }
  }
  ```

---

#### **5. Presentation Layer**

Uses **Cubit** with validation in the UI and Cubit logic.

##### **Cubit**
- **`features/todo/presentation/cubit/todo_cubit.dart`**:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import '../../data/datasources/settings_data_source.dart';
  import '../../domain/entities/todo_entity.dart';
  import '../../domain/usecases/get_todos.dart';
  import '../../domain/usecases/save_todo.dart';
  import '../../domain/usecases/set_todo_filter.dart';
  import '../../domain/usecases/set_theme_mode.dart';
  import 'todo_state.dart';

  class TodoCubit extends Cubit<TodoState> {
    final GetTodos getTodos;
    final SaveTodo saveTodo;
    final SetTodoFilter setTodoFilter;
    final SetThemeMode setThemeMode;

    TodoCubit({
      required this.getTodos,
      required this.saveTodo,
      required this.setTodoFilter,
      required this.setThemeMode,
    }) : super(TodoInitial());

    Future<void> fetchTodos({TodoFilter? filter, ThemeMode? themeMode}) async {
      emit(TodoLoading());
      final result = await getTodos();
      result.fold(
        (failure) => emit(TodoError('Failed to load todos')),
        (todos) => emit(TodoLoaded(
          todos: todos,
          filter: filter ?? TodoFilter.all,
          themeMode: themeMode ?? ThemeMode.system,
        )),
      );
    }

    Future<void> addTodo(TodoEntity todo) async {
      final currentState = state is TodoLoaded ? state as TodoLoaded : null;
      final result = await saveTodo(todo);
      result.fold(
        (failure) {
          if (failure is ValidationFailure) {
            emit(TodoError(failure.message));
          } else {
            emit(TodoError('Failed to save todo'));
          }
        },
        (_) => fetchTodos(
          filter: currentState?.filter ?? TodoFilter.all,
          themeMode: currentState?.themeMode ?? ThemeMode.system,
        ),
      );
    }

    Future<void> setFilter(TodoFilter filter) async {
      final currentState = state is TodoLoaded ? state as TodoLoaded : null;
      final result = await setTodoFilter(filter);
      result.fold(
        (failure) => emit(TodoError('Failed to set filter')),
        (_) => fetchTodos(
          filter: filter,
          themeMode: currentState?.themeMode ?? ThemeMode.system,
        ),
      );
    }

    Future<void> toggleTheme(ThemeMode themeMode) async {
      final currentState = state is TodoLoaded ? state as TodoLoaded : null;
      final result = await setThemeMode(themeMode);
      result.fold(
        (failure) => emit(TodoError('Failed to toggle theme')),
        (_) => fetchTodos(
          filter: currentState?.filter ?? TodoFilter.all,
          themeMode: themeMode,
        ),
      );
    }
  }
  ```

- **`features/todo/presentation/cubit/todo_state.dart`**:
  ```dart
  import 'package:flutter/material.dart';
  import '../../data/datasources/settings_data_source.dart';
  import '../../domain/entities/todo_entity.dart';

  abstract class TodoState {
    const TodoState();
  }

  class TodoInitial extends TodoState {}

  class TodoLoading extends TodoState {}

  class TodoLoaded extends TodoState {
    final List<TodoEntity> todos;
    final TodoFilter filter;
    final ThemeMode themeMode;

    const TodoLoaded({
      required this.todos,
      required this.filter,
      required this.themeMode,
    });

    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
        other is TodoLoaded &&
            runtimeType == other.runtimeType &&
            todos == other.todos &&
            filter == other.filter &&
            themeMode == other.themeMode;

    @override
    int get hashCode => todos.hashCode ^ filter.hashCode ^ themeMode.hashCode;
  }

  class TodoError extends TodoState {
    final String message;

    const TodoError(this.message);

    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
        other is TodoError &&
            runtimeType == other.runtimeType &&
            message == other.message;

    @override
    int get hashCode => message.hashCode;
  }
  ```

##### **UI**
- **`features/todo/presentation/pages/todo_page.dart`**:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:uuid/uuid.dart';
  import '../../../../core/utils/validators.dart';
  import '../../data/datasources/settings_data_source.dart';
  import '../../domain/entities/todo_entity.dart';
  import '../cubit/todo_cubit.dart';
  import '../cubit/todo_state.dart';

  class TodoPage extends StatefulWidget {
    @override
    _TodoPageState createState() => _TodoPageState();
  }

  class _TodoPageState extends State<TodoPage> {
    final TextEditingController _controller = TextEditingController();
    String? _validationError;

    void _validateInput(String value) {
      setState(() {
        _validationError = Validators.validateTodoTitle(value);
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Todos'),
          actions: [
            IconButton(
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.wb_sunny
                    : Icons.nightlight_round,
              ),
              onPressed: () {
                final currentMode = context.read<TodoCubit>().state is TodoLoaded
                    ? (context.read<TodoCubit>().state as TodoLoaded).themeMode
                    : ThemeMode.system;
                context
                    .read<TodoCubit>()
                    .toggleTheme(currentMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'New Todo',
                        errorText: _validationError,
                      ),
                      onChanged: _validateInput,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _validationError == null && _controller.text.isNotEmpty
                        ? () {
                            context.read<TodoCubit>().addTodo(
                                  TodoEntity(
                                    id: const Uuid().v4(),
                                    title: _controller.text,
                                    isCompleted: false,
                                  ),
                                );
                            _controller.clear();
                            setState(() {
                              _validationError = null;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: BlocBuilder<TodoCubit, TodoState>(
                builder: (context, state) {
                  final currentFilter = state is TodoLoaded ? state.filter : TodoFilter.all;
                  return DropdownButton<TodoFilter>(
                    value: currentFilter,
                    items: TodoFilter.values
                        .map((filter) => DropdownMenuItem(
                              value: filter,
                              child: Text(
                                filter == TodoFilter.all
                                    ? 'All'
                                    : filter == TodoFilter.completed
                                        ? 'Completed'
                                        : 'Incompleted',
                              ),
                            ))
                        .toList(),
                    onChanged: (filter) {
                      if (filter != null) {
                        context.read<TodoCubit>().setFilter(filter);
                      }
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: BlocConsumer<TodoCubit, TodoState>(
                listener: (context, state) {
                  if (state is TodoError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is TodoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TodoLoaded) {
                    return ListView.builder(
                      itemCount: state.todos.length,
                      itemBuilder: (context, index) {
                        final todo = state.todos[index];
                        return ListTile(
                          title: Text(todo.title),
                          trailing: Checkbox(
                            value: todo.isCompleted,
                            onChanged: (_) {}, // Add update logic if needed
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('No todos yet'));
                },
              ),
            ),
          ],
        ),
      );
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
  }
  ```

---

#### **6. App and Main Setup**

##### **Main**
- **`main.dart`**:
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

##### **App**
- **`app.dart`**:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:get_it/get_it.dart';
  import 'core/theme/app_theme.dart';
  import 'features/todo/presentation/cubit/todo_cubit.dart';
  import 'features/todo/presentation/pages/todo_page.dart';

  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (_) => GetIt.instance<TodoCubit>()..fetchTodos(),
        child: BlocBuilder<TodoCubit, TodoState>(
          builder: (context, state) {
            final themeMode = state is TodoLoaded ? state.themeMode : ThemeMode.system;
            return MaterialApp(
              title: 'Todo App',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: TodoPage(),
            );
          },
        ),
      );
    }
  }
  ```

---

### **How It Works**

1. **Data Flow**:
    - **SQLite**: Caches todos for offline access.
    - **API**: Primary source for todos, cached in SQLite.
    - **SharedPreferences**: Stores theme mode and filter.
    - Repository tries API, falls back to SQLite if offline.

2. **State Management**:
    - **Cubit**: `TodoCubit` manages todos, filters, and themes via methods (`fetchTodos`, `addTodo`, `setFilter`, `toggleTheme`).
    - States: `TodoInitial`, `TodoLoading`, `TodoLoaded` (todos, filter, theme), `TodoError`.

3. **Dependency Injection**:
    - **GetIt**: Registers `Database`, `SharedPreferences`, `Dio`, data sources, repositories, use cases, and Cubit.

4. **Themes**:
    - Dark/light themes in `AppTheme`.
    - Theme mode stored in SharedPreferences, toggled via Cubit.

5. **Validation**:
    - **UI**: `TextField` validates on change using `Validators.validateTodoTitle`, showing errors below the field. “Add” button disables on invalid input.
    - **Domain**: `SaveTodo` use case validates title, returning `ValidationFailure` if invalid.
    - **Cubit**: Handles `ValidationFailure`, emitting `TodoError` with the message.
    - **Feedback**: Errors appear in the UI (text field) and via snackbar (domain errors).

6. **Rules**:
    - Title: Not empty, 3–50 characters, alphanumeric + spaces.

---

### **Why This Setup?**

- **Clean Architecture**: Separates concerns (UI, business logic, data).
- **Cubit**: Simplifies state management with methods, reducing boilerplate vs. Bloc.
- **GetIt**: Ensures loose coupling and testability.
- **SQLite + API**: Offline support with remote syncing.
- **SharedPreferences**: Lightweight for settings.
- **Themes**: Persistent dark/light modes.
- **Validation**: Dual-layer (UI for UX, domain for rules), preventing invalid data.

---

### **Testing**

- **Validation**:
    - **`test/core/utils/validators_test.dart`**:
      ```dart
      import 'package:flutter_test/flutter_test.dart';
      import '../../../lib/core/utils/validators.dart';
  
      void main() {
        group('Validators', () {
          test('returns error for empty title', () {
            expect(Validators.validateTodoTitle(''), 'Title cannot be empty');
          });
  
          test('returns error for short title', () {
            expect(Validators.validateTodoTitle('ab'), 'Title must be at least 3 characters');
          });
  
          test('returns error for long title', () {
            final longTitle = 'a' * 51;
            expect(Validators.validateTodoTitle(longTitle), 'Title cannot exceed 50 characters');
          });
  
          test('returns error for special characters', () {
            expect(Validators.validateTodoTitle('Test@123'), 'Title can only contain letters, numbers, and spaces');
          });
  
          test('returns null for valid title', () {
            expect(Validators.validateTodoTitle('Valid Todo'), isNull);
          });
        });
      }
      ```

- **Cubit**:
    - **`test/features/todo/presentation/cubit/todo_cubit_test.dart`**:
      ```dart
      import 'package:bloc_test/bloc_test.dart';
      import 'package:dartz/dartz.dart';
      import 'package:flutter_test/flutter_test.dart';
      import 'package:mockito/mockito.dart';
      import '../../../../../lib/core/error/failures.dart';
      import '../../../../../lib/features/todo/domain/entities/todo_entity.dart';
      import '../../../../../lib/features/todo/domain/usecases/get_todos.dart';
      import '../../../../../lib/features/todo/domain/usecases/save_todo.dart';
      import '../../../../../lib/features/todo/presentation/cubit/todo_cubit.dart';
      import '../../../../../lib/features/todo/presentation/cubit/todo_state.dart';
  
      class MockGetTodos extends Mock implements GetTodos {}
      class MockSaveTodo extends Mock implements SaveTodo {}
      class MockSetTodoFilter extends Mock implements SetTodoFilter {}
      class MockSetThemeMode extends Mock implements SetThemeMode {}
  
      void main() {
        late TodoCubit cubit;
        late MockGetTodos mockGetTodos;
        late MockSaveTodo mockSaveTodo;
        late MockSetTodoFilter mockSetTodoFilter;
        late MockSetThemeMode mockSetThemeMode;
  
        setUp(() {
          mockGetTodos = MockGetTodos();
          mockSaveTodo = MockSaveTodo();
          mockSetTodoFilter = MockSetTodoFilter();
          mockSetThemeMode = MockSetThemeMode();
          cubit = TodoCubit(
            getTodos: mockGetTodos,
            saveTodo: mockSaveTodo,
            setTodoFilter: mockSetTodoFilter,
            setThemeMode: mockSetThemeMode,
          );
        });
  
        blocTest<TodoCubit, TodoState>(
          'emits [TodoLoading, TodoLoaded] when fetchTodos succeeds',
          build: () {
            when(mockGetTodos()).thenAnswer(
              (_) async => Right([TodoEntity(id: '1', title: 'Test', isCompleted: false)]),
            );
            return cubit;
          },
          act: (cubit) => cubit.fetchTodos(),
          expect: () => [
            TodoLoading(),
            isA<TodoLoaded>()
                .having((s) => s.todos.length, 'todos length', 1)
                .having((s) => s.filter, 'filter', TodoFilter.all),
          ],
        );
  
        blocTest<TodoCubit, TodoState>(
          'emits [TodoError] when addTodo fails due to validation',
          build: () {
            when(mockSaveTodo(any)).thenAnswer(
              (_) async => Left(ValidationFailure('Title cannot be empty')),
            );
            return cubit;
          },
          act: (cubit) => cubit.addTodo(
            TodoEntity(id: '1', title: '', isCompleted: false),
          ),
          expect: () => [
            TodoError('Title cannot be empty'),
          ],
        );
      }
      ```

---

### **Enhancements**

1. **Validation**:
    - Add rules (e.g., no duplicates) in `Validators`.
    - Use `formz` for complex forms if needed.

2. **UI**:
    - Add animations for error display.
    - Highlight invalid fields with colors.

3. **API**:
    - Replace `https://api.example.com` with your endpoint.
    - Add authentication:
      ```dart
      dio.options.headers['Authorization'] = 'Bearer <token>';
      ```

4. **Features**:
    - Extend with update/delete todos.
    - Add network status checks (`connectivity_plus`).

5. **Testing**:
    - Test UI validation:
      ```dart
      await tester.enterText(find.byType(TextField), 'ab');
      expect(find.text('Title must be at least 3 characters'), findsOneWidget);
      ```

---

### **Workflow**

- **Startup**: Initializes GetIt, loads theme/filter, fetches todos (API → SQLite).
- **Add Todo**: User types → UI validates (e.g., “ab” shows error), domain validates, saves to API/SQLite if valid.
- **Filter/Theme**: User changes filter or theme → Updates SharedPreferences, UI refreshes.
- **Offline**: Fetches from SQLite if API fails.
- **Validation**: UI shows errors instantly, domain blocks invalid data, snackbar for errors.

If you need specific API details, more validation rules, or additional features, please share, and I’ll refine the solution!