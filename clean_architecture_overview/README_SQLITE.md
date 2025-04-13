If you're using **SQLite** as your local database in a Flutter app with **clean architecture**, **BLoC**, and **GetIt**, you can integrate it into the **data layer** while keeping the architecture clean and modular. Below, I’ll explain how to adapt the previously described clean architecture to include SQLite, focusing on the changes needed and providing a concise implementation.

---

### **Key Adjustments for SQLite**

1. **Data Layer**:
    - Add a **local data source** to interact with SQLite using a package like `sqflite`.
    - Update the repository to handle both local (SQLite) and remote data sources (if applicable).
    - Map SQLite data to domain entities.

2. **Dependency Injection**:
    - Register the SQLite database instance and local data source with **GetIt**.

3. **Domain and Presentation**:
    - These layers remain largely unchanged, as they are independent of the data source implementation.

---

### **Updated Project Structure**

The structure remains similar to the previous setup, with additions for SQLite in the data layer:

```
my_app/
├── lib/
│   ├── core/
│   │   ├── di/                     # GetIt setup
│   │   ├── error/                  # Exceptions
│   │   └── utils/                  # Constants, helpers
│   ├── features/
│   │   ├── feature_name/           # e.g., todo
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── local_data_source.dart  # SQLite operations
│   │   │   │   │   └── remote_data_source.dart # Optional API
│   │   │   │   ├── models/        # Data models
│   │   │   │   └── repositories/  # Repository impl
│   │   │   ├── domain/
│   │   │   │   ├── entities/      # Pure business objects
│   │   │   │   ├── repositories/  # Abstract repo interfaces
│   │   │   │   └── usecases/      # Business logic
│   │   │   ├── presentation/
│   │   │   │   ├── bloc/          # BLoC
│   │   │   │   ├── pages/         # UI screens
│   │   │   │   └── widgets/       # UI components
│   ├── app.dart                    # App widget
│   └── main.dart                   # Entry point
├── test/                           # Tests
└── pubspec.yaml
```

---

### **Implementation Details**

Let’s assume you’re building a **Todo** feature with SQLite to store todos locally.

#### **1. Dependencies**
Add `sqflite` and `path` to `pubspec.yaml`:

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

dev_dependencies:
  mockito: ^5.4.2
  bloc_test: ^9.1.4
  flutter_test:
    sdk: flutter
```

#### **2. Core Layer**

- **`core/di/injection.dart`**:
  Register the SQLite database and local data source.
  ```dart
  import 'package:get_it/get_it.dart';
  import 'package:sqflite/sqflite.dart';
  import '../features/todo/data/datasources/local_data_source.dart';
  import '../features/todo/data/repositories/todo_repository_impl.dart';
  import '../features/todo/domain/repositories/todo_repository.dart';
  import '../features/todo/domain/usecases/get_todos.dart';
  import '../features/todo/presentation/bloc/todo_bloc.dart';

  final sl = GetIt.instance;

  Future<void> init() async {
    // BLoC
    sl.registerFactory(() => TodoBloc(getTodos: sl()));

    // Use Cases
    sl.registerLazySingleton(() => GetTodos(sl()));

    // Repository
    sl.registerLazySingleton<TodoRepository>(
      () => TodoRepositoryImpl(localDataSource: sl()),
    );

    // Data Sources
    sl.registerLazySingleton<LocalDataSource>(
      () => LocalDataSourceImpl(database: sl()),
    );

    // Database
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

    await sl.allReady();
  }
  ```

- **`core/error/exceptions.dart`**:
  Add a `DatabaseException` for SQLite errors.
  ```dart
  class DatabaseException implements Exception {
    final String message;
    DatabaseException(this.message);
  }
  ```

#### **3. Data Layer**

- **`data/datasources/local_data_source.dart`**:
  Define and implement the SQLite operations.
  ```dart
  import 'package:sqflite/sqflite.dart';
  import '../../core/error/exceptions.dart';
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

- **`data/models/todo_model.dart`**:
  Model for SQLite and mapping to entity.
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

- **`data/repositories/todo_repository_impl.dart`**:
  Use the local data source to implement the repository.
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../core/error/exceptions.dart';
  import '../../core/error/failures.dart';
  import '../../domain/entities/todo_entity.dart';
  import '../../domain/repositories/todo_repository.dart';
  import '../datasources/local_data_source.dart';
  import '../models/todo_model.dart';

  class TodoRepositoryImpl implements TodoRepository {
    final LocalDataSource localDataSource;

    TodoRepositoryImpl({required this.localDataSource});

    @override
    Future<Either<Failure, List<TodoEntity>>> getTodos() async {
      try {
        final models = await localDataSource.getTodos();
        return Right(models.map((model) => model.toEntity()).toList());
      } on DatabaseException {
        return Left(DatabaseFailure());
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
  }
  ```

#### **4. Domain Layer**

- **`domain/entities/todo_entity.dart`**:
  Unchanged, as it’s independent of SQLite.
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

- **`domain/repositories/todo_repository.dart`**:
  Abstract interface, unchanged.
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../core/error/failures.dart';
  import '../entities/todo_entity.dart';

  abstract class TodoRepository {
    Future<Either<Failure, List<TodoEntity>>> getTodos();
    Future<Either<Failure, void>> saveTodo(TodoEntity todo);
  }
  ```

- **`domain/usecases/get_todos.dart`**:
  Unchanged.
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../core/error/failures.dart';
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

- **`domain/usecases/save_todo.dart`**:
  New use case for saving a todo.
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../core/error/failures.dart';
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

- **`core/error/failures.dart`**:
  Add a `DatabaseFailure`.
  ```dart
  abstract class Failure {}
  class DatabaseFailure extends Failure {}
  ```

#### **5. Presentation Layer**

- **`presentation/bloc/todo_bloc.dart`**:
  Update to handle saving todos.
  ```dart
  import 'package:flutter_bloc/flutter_bloc.dart';
  import '../../domain/entities/todo_entity.dart';
  import '../../domain/usecases/get_todos.dart';
  import '../../domain/usecases/save_todo.dart';
  import 'todo_event.dart';
  import 'todo_state.dart';

  class TodoBloc extends Bloc<TodoEvent, TodoState> {
    final GetTodos getTodos;
    final SaveTodo saveTodo;

    TodoBloc({required this.getTodos, required this.saveTodo})
        : super(TodoInitial()) {
      on<FetchTodosEvent>(_onFetchTodos);
      on<AddTodoEvent>(_onAddTodo);
    }

    Future<void> _onFetchTodos(FetchTodosEvent event, Emitter<TodoState> emit) async {
      emit(TodoLoading());
      final result = await getTodos();
      result.fold(
        (failure) => emit(TodoError('Failed to load todos')),
        (todos) => emit(TodoLoaded(todos)),
      );
    }

    Future<void> _onAddTodo(AddTodoEvent event, Emitter<TodoState> emit) async {
      final result = await saveTodo(event.todo);
      result.fold(
        (failure) => emit(TodoError('Failed to save todo')),
        (_) => add(FetchTodosEvent()), // Refresh todos
      );
    }
  }
  ```

- **`presentation/bloc/todo_event.dart`**:
  ```dart
  import '../../domain/entities/todo_entity.dart';

  abstract class TodoEvent {}
  class FetchTodosEvent extends TodoEvent {}
  class AddTodoEvent extends TodoEvent {
    final TodoEntity todo;
    AddTodoEvent(this.todo);
  }
  ```

- **`presentation/bloc/todo_state.dart`**:
  Unchanged.
  ```dart
  import '../../domain/entities/todo_entity.dart';

  abstract class TodoState {}
  class TodoInitial extends TodoState {}
  class TodoLoading extends TodoState {}
  class TodoLoaded extends TodoState {
    final List<TodoEntity> todos;
    TodoLoaded(this.todos);
  }
  class TodoError extends TodoState {
    final String message;
    TodoError(this.message);
  }
  ```

- **`presentation/pages/todo_page.dart`**:
  Add a form to save todos.
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:uuid/uuid.dart';
  import '../../domain/entities/todo_entity.dart';
  import '../bloc/todo_bloc.dart';
  import '../bloc/todo_event.dart';
  import '../bloc/todo_state.dart';

  class TodoPage extends StatelessWidget {
    final TextEditingController _controller = TextEditingController();

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Todos')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(labelText: 'Add Todo'),
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

#### **6. Main and App Setup**

- **`main.dart`**:
  Ensure GetIt initializes the database.
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
  Unchanged, but ensure the BLoC is provided.
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:get_it/get_it.dart';
  import 'features/todo/presentation/bloc/todo_bloc.dart';
  import 'features/todo/presentation/pages/todo_page.dart';

  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        theme: ThemeData.light(),
        home: BlocProvider(
          create: (_) => GetIt.instance<TodoBloc>()..add(FetchTodosEvent()),
          child: TodoPage(),
        ),
      );
    }
  }
  ```

---

### **Additional Notes**

1. **Database Initialization**:
    - The database is initialized as a singleton in GetIt to ensure a single instance across the app.
    - Use `join` from the `path` package to create a platform-independent database path.

2. **Error Handling**:
    - Catch SQLite-specific errors in the local data source and throw `DatabaseException`.
    - Map to `DatabaseFailure` in the repository for the domain layer.

3. **Testing**:
    - Use `sqflite_ffi` or an in-memory database for unit tests.
    - Mock the `LocalDataSource` when testing the repository.
    - Test BLoC and UI as before.

4. **Optional Remote Data Source**:
    - If you’re syncing todos with an API, add a `RemoteDataSource` and update the repository to combine local and remote data (e.g., cache locally with SQLite, fetch remotely with Dio).

5. **Performance**:
    - Use batch operations for bulk inserts/updates in SQLite.
    - Index fields (e.g., `id`) if querying frequently.

6. **UUID**:
    - Added `uuid` package for generating unique IDs:
      ```yaml
      dependencies:
        uuid: ^4.0.0
      ```

---

### **Why This Setup?**
- **Clean Architecture**: SQLite is isolated in the data layer, keeping the domain and presentation layers unchanged.
- **BLoC**: Manages state seamlessly, whether data comes from SQLite or an API.
- **GetIt**: Simplifies database and data source injection.
- **Testability**: SQLite operations are abstracted, making mocks easy.
- **Scalability**: Add more CRUD operations (e.g., update, delete) by extending the data source and repository.

If you need help with additional SQLite operations (e.g., updating or deleting todos), syncing with an API, or specific test cases, let me know!