To build a **Flutter app** with **clean architecture**, using **BLoC** for state management, **GetIt** for dependency injection, **SQLite** and **SharedPreferences** for data storage, and support for **dark and light themes**, we’ll structure the project to ensure **modularity**, **testability**, and **maintainability**. Below is a comprehensive guide to the best clean architecture setup tailored to your requirements.

---

### **Clean Architecture Overview**
Clean architecture divides the app into three main layers:
1. **Presentation Layer**: Handles UI (widgets, themes) and state management (BLoC).
2. **Domain Layer**: Contains business logic (use cases, entities), independent of frameworks.
3. **Data Layer**: Manages data sources (SQLite, SharedPreferences, APIs).

The **Dependency Rule** ensures outer layers depend on inner layers, with the domain layer being the most independent.

---

### **Project Structure**

Here’s the recommended folder structure, incorporating SQLite, SharedPreferences, and theme support:

```
my_app/
├── lib/
│   ├── core/
│   │   ├── di/                     # Dependency Injection (GetIt)
│   │   ├── error/                  # Custom exceptions and failures
│   │   ├── theme/                  # Theme data and theme mode logic
│   │   └── utils/                  # Constants, helpers
│   ├── features/
│   │   ├── todo/                   # Example feature (e.g., Todo)
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── local_data_source.dart      # SQLite operations
│   │   │   │   │   └── settings_data_source.dart   # SharedPreferences
│   │   │   │   ├── models/        # Data models
│   │   │   │   └── repositories/  # Repository implementations
│   │   │   ├── domain/
│   │   │   │   ├── entities/      # Business entities
│   │   │   │   ├── repositories/  # Abstract repository interfaces
│   │   │   │   └── usecases/      # Business logic
│   │   │   ├── presentation/
│   │   │   │   ├── bloc/          # BLoC for state management
│   │   │   │   ├── pages/         # Screens
│   │   │   │   └── widgets/       # Reusable UI components
│   ├── app.dart                    # App widget (root)
│   └── main.dart                   # Entry point
├── test/                           # Unit and widget tests
└── pubspec.yaml
```

---

### **Implementation Details**

Let’s build a **Todo** feature that:
- Stores todos in **SQLite**.
- Saves the theme mode (dark/light) and todo filter in **SharedPreferences**.
- Supports **dark and light themes** with a toggle.
- Uses **BLoC** for state management and **GetIt** for dependency injection.

#### **1. Dependencies**
Add the required packages to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  get_it: ^7.6.0
  dartz: ^0.10.1
  equatable: ^2.0.5
  sqflite: ^2.3.0
  path: ^1.8.3
  shared_preferences: ^2.2.2
  uuid: ^4.0.0

dev_dependencies:
  mockito: ^5.4.2
  bloc_test: ^9.1.4
  flutter_test:
    sdk: flutter
```

---

#### **2. Core Layer**

This layer contains cross-cutting concerns like dependency injection, error handling, and theme management.

##### **Dependency Injection**
- **`core/di/injection.dart`**:
  Register all dependencies with GetIt.
  ```dart
  import 'package:get_it/get_it.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:sqflite/sqflite.dart';
  import '../features/todo/data/datasources/local_data_source.dart';
  import '../features/todo/data/datasources/settings_data_source.dart';
  import '../features/todo/data/repositories/todo_repository_impl.dart';
  import '../features/todo/domain/repositories/todo_repository.dart';
  import '../features/todo/domain/usecases/get_todos.dart';
  import '../features/todo/domain/usecases/save_todo.dart';
  import '../features/todo/domain/usecases/set_theme_mode.dart';
  import '../features/todo/domain/usecases/set_todo_filter.dart';
  import '../features/todo/presentation/bloc/todo_bloc.dart';

  final sl = GetIt.instance;

  Future<void> init() async {
    // BLoC
    sl.registerFactory(() => TodoBloc(
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
        settingsDataSource: sl(),
      ),
    );

    // Data Sources
    sl.registerLazySingleton<LocalDataSource>(
      () => LocalDataSourceImpl(database: sl()),
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
  ```

- **`core/error/failures.dart`**:
  ```dart
  abstract class Failure {}
  class DatabaseFailure extends Failure {}
  class CacheFailure extends Failure {}
  ```

##### **Theme Management**
- **`core/theme/app_theme.dart`**:
  Define dark and light themes.
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

---

#### **3. Data Layer**

Handles data storage with SQLite (for todos) and SharedPreferences (for theme mode and filters).

##### **Data Sources**
- **`features/todo/data/datasources/local_data_source.dart`** (SQLite):
  ```dart
  import 'package:sqflite/sqflite.dart';
  import '../../../../core/error/exceptions.dart';
  import '../models/todo_model.dart';

  abstract class LocalDataSource {
    Future<List<TodoModel>> getTodos();
    Future<void> saveTodo(TodoModel todo);
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
        isCompleted: json['isCompleted'] == 1,
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'title': title,
        'isCompleted': isCompleted ? 1 : 0,
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
  Combines SQLite and SharedPreferences.
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../../../core/error/exceptions.dart';
  import '../../../../core/error/failures.dart';
  import '../../domain/entities/todo_entity.dart';
  import '../../domain/repositories/todo_repository.dart';
  import '../datasources/local_data_source.dart';
  import '../datasources/settings_data_source.dart';
  import '../models/todo_model.dart';
  import 'package:flutter/material.dart';

  class TodoRepositoryImpl implements TodoRepository {
    final LocalDataSource localDataSource;
    final SettingsDataSource settingsDataSource;

    TodoRepositoryImpl({
      required this.localDataSource,
      required this.settingsDataSource,
    });

    @override
    Future<Either<Failure, List<TodoEntity>>> getTodos() async {
      try {
        final filter = await settingsDataSource.getTodoFilter();
        final models = await localDataSource.getTodos();
        List<TodoEntity> todos = models.map((model) => model.toEntity()).toList();

        if (filter == TodoFilter.completed) {
          todos = todos.where((todo) => todo.isCompleted).toList();
        } else if (filter == TodoFilter.incompleted) {
          todos = todos.where((todo) => !todo.isCompleted).toList();
        }

        return Right(todos);
      } on DatabaseException {
        return Left(DatabaseFailure());
      } on CacheException {
        return Left(CacheFailure());
      }
    }

    @override
    Future<Either<Failure, void>> saveTodo(TodoEntity todo) async {
      try {
        await localDataSource.saveTodo(TodoModel(
          id: todo.id,
          title: todo.title,
          isCompleted: todo.isCompleted,
        ));
        return const Right(null);
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
  }
  ```

---

#### **4. Domain Layer**

Contains business logic, independent of SQLite, SharedPreferences, or UI.

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
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../../../core/error/failures.dart';
  import '../entities/todo_entity.dart';
  import '../repositories/todo_repository.dart';

  class SaveTodo {
    final TodoRepository repository;

    SaveTodo(this.repository);

    Future<Either<Failure, void>> call(TodoEntity todo) async {
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

Handles UI, state management, and theme switching.

##### **BLoC**
- **`features/todo/presentation/bloc/todo_bloc.dart`**:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import '../../data/datasources/settings_data_source.dart';
  import '../../domain/entities/todo_entity.dart';
  import '../../domain/usecases/get_todos.dart';
  import '../../domain/usecases/save_todo.dart';
  import '../../domain/usecases/set_todo_filter.dart';
  import '../../domain/usecases/set_theme_mode.dart';
  import 'todo_event.dart';
  import 'todo_state.dart';

  class TodoBloc extends Bloc<TodoEvent, TodoState> {
    final GetTodos getTodos;
    final SaveTodo saveTodo;
    final SetTodoFilter setTodoFilter;
    final SetThemeMode setThemeMode;

    TodoBloc({
      required this.getTodos,
      required this.saveTodo,
      required this.setTodoFilter,
      required this.setThemeMode,
    }) : super(TodoInitial()) {
      on<FetchTodosEvent>(_onFetchTodos);
      on<AddTodoEvent>(_onAddTodo);
      on<FilterTodosEvent>(_onFilterTodos);
      on<ToggleThemeEvent>(_onToggleTheme);
    }

    Future<void> _onFetchTodos(FetchTodosEvent event, Emitter<TodoState> emit) async {
      emit(TodoLoading());
      final result = await getTodos();
      result.fold(
        (failure) => emit(TodoError('Failed to load todos')),
        (todos) => emit(TodoLoaded(
          todos: todos,
          filter: event.filter ?? TodoFilter.all,
          themeMode: event.themeMode ?? ThemeMode.system,
        )),
      );
    }

    Future<void> _onAddTodo(AddTodoEvent event, Emitter<TodoState> emit) async {
      final result = await saveTodo(event.todo);
      result.fold(
        (failure) => emit(TodoError('Failed to save todo')),
        (_) => add(FetchTodosEvent(
          filter: state is TodoLoaded ? (state as TodoLoaded).filter : TodoFilter.all,
          themeMode: state is TodoLoaded ? (state as TodoLoaded).themeMode : ThemeMode.system,
        )),
      );
    }

    Future<void> _onFilterTodos(FilterTodosEvent event, Emitter<TodoState> emit) async {
      final result = await setTodoFilter(event.filter);
      result.fold(
        (failure) => emit(TodoError('Failed to set filter')),
        (_) => add(FetchTodosEvent(
          filter: event.filter,
          themeMode: state is TodoLoaded ? (state as TodoLoaded).themeMode : ThemeMode.system,
        )),
      );
    }

    Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter<TodoState> emit) async {
      final result = await setThemeMode(event.themeMode);
      result.fold(
        (failure) => emit(TodoError('Failed to toggle theme')),
        (_) => add(FetchTodosEvent(
          filter: state is TodoLoaded ? (state as TodoLoaded).filter : TodoFilter.all,
          themeMode: event.themeMode,
        )),
      );
    }
  }
  ```

- **`features/todo/presentation/bloc/todo_event.dart`**:
  ```dart
  import 'package:flutter/material.dart';
  import '../../data/datasources/settings_data_source.dart';
  import '../../domain/entities/todo_entity.dart';

  abstract class TodoEvent {}
  class FetchTodosEvent extends TodoEvent {
    final TodoFilter? filter;
    final ThemeMode? themeMode;
    FetchTodosEvent({this.filter, this.themeMode});
  }
  class AddTodoEvent extends TodoEvent {
    final TodoEntity todo;
    AddTodoEvent(this.todo);
  }
  class FilterTodosEvent extends TodoEvent {
    final TodoFilter filter;
    FilterTodosEvent(this.filter);
  }
  class ToggleThemeEvent extends TodoEvent {
    final ThemeMode themeMode;
    ToggleThemeEvent(this.themeMode);
  }
  ```

- **`features/todo/presentation/bloc/todo_state.dart`**:
  ```dart
  import 'package:flutter/material.dart';
  import '../../data/datasources/settings_data_source.dart';
  import '../../domain/entities/todo_entity.dart';

  abstract class TodoState {}
  class TodoInitial extends TodoState {}
  class TodoLoading extends TodoState {}
  class TodoLoaded extends TodoState {
    final List<TodoEntity> todos;
    final TodoFilter filter;
    final ThemeMode themeMode;
    TodoLoaded({
      required this.todos,
      required this.filter,
      required this.themeMode,
    });
  }
  class TodoError extends TodoState {
    final String message;
    TodoError(this.message);
  }
  ```

##### **UI**
- **`features/todo/presentation/pages/todo_page.dart`**:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:uuid/uuid.dart';
  import '../../data/datasources/settings_data_source.dart';
  import '../../domain/entities/todo_entity.dart';
  import '../bloc/todo_bloc.dart';
  import '../bloc/todo_event.dart';
  import '../bloc/todo_state.dart';

  class TodoPage extends StatelessWidget {
    final TextEditingController _controller = TextEditingController();

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
                final currentMode = context.read<TodoBloc>().state is TodoLoaded
                    ? (context.read<TodoBloc>().state as TodoLoaded).themeMode
                    : ThemeMode.system;
                context.read<TodoBloc>().add(ToggleThemeEvent(
                  currentMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                ));
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
                      decoration: const InputDecoration(labelText: 'New Todo'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        context.read<TodoBloc>().add(AddTodoEvent(
                              TodoEntity(
                                id: const Uuid().v4(),
                                title: _controller.text,
                                isCompleted: false,
                              ),
                            ));
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<TodoFilter>(
                value: context.watch<TodoBloc>().state is TodoLoaded
                    ? (context.watch<TodoBloc>().state as TodoLoaded).filter
                    : TodoFilter.all,
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
                    context.read<TodoBloc>().add(FilterTodosEvent(filter));
                  }
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<TodoBloc, TodoState>(
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
                  } else if (state is TodoError) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text('No todos yet'));
                },
              ),
            ),
          ],
        ),
      );
    }
  }
  ```

---

#### **6. App and Main Setup**

##### **Main**
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

##### **App**
- **`app.dart`**:
  Set up the app with dynamic theme support.
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:get_it/get_it.dart';
  import 'core/theme/app_theme.dart';
  import 'features/todo/presentation/bloc/todo_bloc.dart';
  import 'features/todo/presentation/pages/todo_page.dart';

  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (_) => GetIt.instance<TodoBloc>()..add(FetchTodosEvent()),
        child: BlocBuilder<TodoBloc, TodoState>(
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

1. **Data Storage**:
    - **SQLite**: Stores todos (id, title, isCompleted) in a `todos` table.
    - **SharedPreferences**: Stores the todo filter (`all`, `completed`, `incompleted`) and theme mode (`light`, `dark`, `system`).

2. **State Management**:
    - **BLoC**: `TodoBloc` manages todos, filters, and theme mode.
    - Events: Fetch todos, add todo, change filter, toggle theme.
    - States: Initial, loading, loaded (with todos, filter, theme), error.

3. **Dependency Injection**:
    - **GetIt**: Registers singletons (`Database`, `SharedPreferences`) and factories (`TodoBloc`, use cases, repositories).
    - Ensures loose coupling and easy testing.

4. **Theme Support**:
    - **Dark/Light Themes**: Defined in `AppTheme`.
    - **Theme Mode**: Stored in SharedPreferences and updated via `TodoBloc`.
    - UI updates dynamically when the theme mode changes.

5. **UI**:
    - **TodoPage**: Displays a text field to add todos, a dropdown for filtering, a list of todos, and a theme toggle button.
    - Reflects the current theme and filter state.

---

### **Key Features**

1. **Separation of Concerns**:
    - **Presentation**: UI and BLoC are isolated from data sources.
    - **Domain**: Pure business logic, no Flutter or storage dependencies.
    - **Data**: SQLite and SharedPreferences abstracted via data sources.

2. **Testability**:
    - **Domain**: Test use cases with pure Dart.
    - **Data**: Mock `LocalDataSource` and `SettingsDataSource`.
    - **Presentation**: Test BLoC with `bloc_test` and widgets with `flutter_test`.

3. **Scalability**:
    - Add new features by creating new `features/` folders.
    - Extend the repository for additional data sources (e.g., APIs).

4. **Theme Management**:
    - Supports dark, light, and system themes.
    - Persists theme choice in SharedPreferences.

5. **Error Handling**:
    - Uses `dartz` for `Either<Failure, Result>`.
    - Maps SQLite and SharedPreferences errors to user-friendly messages.

---

### **Why This Setup?**

- **Clean Architecture**: Ensures modularity and maintainability.
- **BLoC**: Provides predictable state management for todos and themes.
- **GetIt**: Simplifies dependency injection, making the codebase flexible.
- **SQLite + SharedPreferences**: Combines structured data storage with lightweight settings management.
- **Dark/Light Themes**: Enhances UX with persistent theme preferences.

---

### **Additional Tips**

1. **Performance**:
    - Use SQLite indexes for large datasets.
    - Avoid storing large data in SharedPreferences; keep it for settings only.

2. **Testing**:
    - Use `sqflite_ffi` for in-memory SQLite testing.
    - Mock SharedPreferences with `shared_preferences_mocks`.

3. **Enhancements**:
    - Add update/delete todo functionality by extending the data source and repository.
    - Integrate an API for syncing todos, using SQLite as an offline cache.
    - Add animations for theme transitions.

4. **Localization**:
    - Store language preferences in SharedPreferences for a multilingual app.

---

### **Example Workflow**

- **Startup**: App loads, GetIt initializes SQLite and SharedPreferences, `TodoBloc` fetches todos and theme mode.
- **Add Todo**: User enters a title, BLoC saves it to SQLite via the repository.
- **Filter Todos**: User selects a filter, BLoC saves it to SharedPreferences and reloads filtered todos.
- **Toggle Theme**: User clicks the theme button, BLoC updates SharedPreferences, and the UI reflects the new theme.

If you need further details, such as adding more features (e.g., todo deletion), specific test cases, or UI enhancements, let me know!