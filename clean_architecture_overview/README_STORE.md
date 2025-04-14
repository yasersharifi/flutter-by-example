I’ll provide a concise implementation of Clean Architecture in a Flutter app for a grocery store, using **Cubit** (from the latest `flutter_bloc` package) for state management, **GetIt** for dependency injection, **Dio** for HTTP requests, **Formz** for form validation, and support for **dark/light themes**. The app will follow Clean Architecture principles (Presentation, Domain, Data layers) for maintainability, testability, and scalability.

---

### Overview of Clean Architecture

- **Presentation Layer**: UI (Flutter widgets), Cubit for state management, theme switching, and Formz for form validation.
- **Domain Layer**: Business logic (use cases, entities), independent of frameworks.
- **Data Layer**: Data sources (API via Dio, local storage) and repositories.

---

### Folder Structure

```
grocery_store/
├── lib/
│   ├── core/                  # App-wide utilities, constants, DI setup
│   │   ├── di/               # Dependency injection
│   │   └── theme/            # Theme data for dark/light modes
│   ├── data/                  # Data layer
│   │   ├── models/            # Data models (e.g., JSON parsing)
│   │   ├── repositories/      # Repository implementations
│   │   └── sources/           # Remote/local data sources
│   ├── domain/
│   │   ├── entities/          # Business entities (e.g., Product)
│   │   ├── repositories/      # Abstract repository interfaces
│   │   └── usecases/          # Business logic (use cases)
│   ├── presentation/
│   │   ├── cubits/            # Cubit classes for state management
│   │   ├── forms/             # Formz models for validation
│   │   ├── pages/             # UI screens (e.g., ProductListPage)
│   │   └── widgets/           # Reusable UI components
│   └── main.dart              # Entry point
├── test/                      # Unit and widget tests
└── pubspec.yaml
```

---

### Step-by-Step Implementation

#### 1. Setup Dependencies

In `pubspec.yaml`, add:

```yaml
dependencies:
  flutter:
    sdk: flutter
  bloc: ^8.1.4          # Latest BLoC with Cubit
  flutter_bloc: ^8.1.4   # Flutter integration for BLoC/Cubit
  get_it: ^7.6.0         # Dependency injection
  dio: ^5.4.0            # HTTP client
  formz: ^0.6.0          # Form validation
  equatable: ^2.0.5      # Equality comparisons
  shared_preferences: ^2.2.0  # Persist theme preference

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2        # Mocking for tests
```

Run `flutter pub get`.

---

#### 2. Core Layer

**Dependency Injection** (`lib/core/di/injection.dart`):

```dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/sources/remote_data_source.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_products.dart';
import '../../presentation/cubits/product/product_cubit.dart';
import '../../presentation/cubits/theme/theme_cubit.dart';

final getIt = GetIt.instance;

void setup() {
  // External
  getIt.registerSingleton<Dio>(Dio());

  // Data layer
  getIt.registerSingleton<RemoteDataSource>(RemoteDataSourceImpl(getIt()));
  getIt.registerSingleton<ProductRepository>(ProductRepositoryImpl(remoteDataSource: getIt()));

  // Domain layer
  getIt.registerSingleton<GetProducts>(GetProducts(getIt()));

  // Presentation layer
  getIt.registerFactory(() => ProductCubit(getProducts: getIt()));
  getIt.registerSingleton<ThemeCubit>(ThemeCubit());
}
```

**Theme Setup** (`lib/core/theme/app_theme.dart`):

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.green,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
    ),
  );
}
```

**Theme Cubit** (`lib/presentation/cubits/theme/theme_cubit.dart`):

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(isDarkMode: false)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    emit(ThemeState(isDarkMode: isDarkMode));
  }

  Future<void> toggleTheme() async {
    final newState = ThemeState(isDarkMode: !state.isDarkMode);
    emit(newState);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newState.isDarkMode);
  }
}
```

**Theme State** (`lib/presentation/cubits/theme/theme_state.dart`):

```dart
part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  final bool isDarkMode;

  const ThemeState({required this.isDarkMode});

  @override
  List<Object> get props => [isDarkMode];
}
```

---

#### 3. Domain Layer

**Entity** (`lib/domain/entities/product.dart`):

```dart
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final double price;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [id, name, price, imageUrl];
}
```

**Repository Interface** (`lib/domain/repositories/product_repository.dart`):

```dart
abstract class ProductRepository {
  Future<List<Product>> getProducts();
}
```

**Use Case** (`lib/domain/usecases/get_products.dart`):

```dart
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<List<Product>> call() async {
    return await repository.getProducts();
  }
}
```

---

#### 4. Data Layer

**Model** (`lib/data/models/product_model.dart`):

```dart
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required int id,
    required String name,
    required double price,
    required String imageUrl,
  }) : super(id: id, name: name, price: price, imageUrl: imageUrl);

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
```

**Data Source** (`lib/data/sources/remote_data_source.dart`):

```dart
import 'package:dio/dio.dart';
import '../models/product_model.dart';

abstract class RemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final Dio dio;

  RemoteDataSourceImpl(this.dio);

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await dio.get('https://api.example.com/products');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
```

**Repository Implementation** (`lib/data/repositories/product_repository_impl.dart`):

```dart
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../sources/remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final RemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts() async {
    try {
      final productModels = await remoteDataSource.getProducts();
      return productModels;
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
}
```

---

#### 5. Presentation Layer

**Formz Models** (`lib/presentation/forms/quantity_form.dart`):

```dart
import 'package:formz/formz.dart';

enum QuantityValidationError { empty, invalid }

class Quantity extends FormzInput<int?, QuantityValidationError> {
  const Quantity.pure([int? value]) : super.pure(value);
  const Quantity.dirty([int? value]) : super.dirty(value);

  @override
  QuantityValidationError? validator(int? value) {
    if (value == null) return QuantityValidationError.empty;
    if (value <= 0) return QuantityValidationError.invalid;
    return null;
  }

  String? get errorMessage {
    if (isValid || isPure) return null;
    switch (error) {
      case QuantityValidationError.empty:
        return 'Quantity is required';
      case QuantityValidationError.invalid:
        return 'Quantity must be greater than 0';
      default:
        return null;
    }
  }
}
```

**Product Cubit** (`lib/presentation/cubits/product/product_cubit.dart`):

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/get_products.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProducts getProducts;

  ProductCubit({required this.getProducts}) : super(ProductInitial());

  Future<void> fetchProducts() async {
    emit(ProductLoading());
    try {
      final products = await getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError('Failed to load products: $e'));
    }
  }
}
```

**Product State** (`lib/presentation/cubits/product/product_state.dart`):

```dart
part of 'product_cubit.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}
```

**Add to Cart Cubit** (`lib/presentation/cubits/add_to_cart/add_to_cart_cubit.dart`):

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../../forms/quantity_form.dart';

part 'add_to_cart_state.dart';

class AddToCartCubit extends Cubit<AddToCartState> {
  AddToCartCubit() : super(const AddToCartState());

  void quantityChanged(String value) {
    final quantity = Quantity.dirty(int.tryParse(value));
    emit(state.copyWith(
      quantity: quantity,
      isValid: Formz.validate([quantity]),
    ));
  }

  void submit() {
    if (!state.isValid) return;
    // TODO: Implement add to cart logic (e.g., call repository)
    emit(state.copyWith(status: FormzSubmissionStatus.success));
  }
}
```

**Add to Cart State** (`lib/presentation/cubits/add_to_cart/add_to_cart_state.dart`):

```dart
part of 'add_to_cart_cubit.dart';

class AddToCartState extends Equatable {
  final Quantity quantity;
  final FormzSubmissionStatus status;
  final bool isValid;

  const AddToCartState({
    this.quantity = const Quantity.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
  });

  AddToCartState copyWith({
    Quantity? quantity,
    FormzSubmissionStatus? status,
    bool? isValid,
  }) {
    return AddToCartState(
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [quantity, status, isValid];
}
```

**Product List Page** (`lib/presentation/pages/product_list_page.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../cubits/product/product_cubit.dart';
import '../cubits/theme/theme_cubit.dart';
import '../widgets/add_to_cart_form.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ProductCubit>()..fetchProducts()),
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            theme: themeState.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Grocery Store'),
                actions: [
                  IconButton(
                    icon: Icon(themeState.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                    onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                  ),
                ],
              ),
              body: BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductLoaded) {
                    return ListView.builder(
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return ListTile(
                          leading: Image.network(
                            product.imageUrl,
                            width: 50,
                            errorBuilder: (_, __, ___) => const Icon(Icons.error),
                          ),
                          title: Text(product.name),
                          subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AddToCartForm(product: product),
                              );
                            },
                          ),
                        );
                      },
                    );
                  } else if (state is ProductError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
```

**Add to Cart Form** (`lib/presentation/widgets/add_to_cart_form.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../cubits/add_to_cart/add_to_cart_cubit.dart';

class AddToCartForm extends StatelessWidget {
  final Product product;

  const AddToCartForm({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddToCartCubit(),
      child: BlocListener<AddToCartCubit, AddToCartState>(
        listener: (context, state) {
          if (state.status == FormzSubmissionStatus.success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.name} added to cart')),
            );
          }
        },
        child: AlertDialog(
          title: Text('Add ${product.name} to Cart'),
          content: BlocBuilder<AddToCartCubit, AddToCartState>(
            builder: (context, state) {
              return TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  errorText: state.quantity.errorMessage,
                ),
                onChanged: (value) => context.read<AddToCartCubit>().quantityChanged(value),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => context.read<AddToCartCubit>().submit(),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Main Entry Point** (`lib/main.dart`):

```dart
import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'presentation/pages/product_list_page.dart';

void main() {
  setup();
  runApp(const GroceryStoreApp());
}

class GroceryStoreApp extends StatelessWidget {
  const GroceryStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProductListPage();
  }
}
```

---

#### 6. Features for Grocery Store

- **Cart Management**:
  - Create a `Cart` entity and `CartRepository`.
  - Implement `AddToCart` and `RemoveFromCart` use cases.
  - Use a `CartCubit` to manage cart state.
  - Add a `CartPage` to display items and total price.

- **Authentication**:
  - Add Formz models for email/password (similar to `Quantity`).
  - Example `Email` Formz model (`lib/presentation/forms/email_form.dart`):

    ```dart
    import 'package:formz/formz.dart';

    enum EmailValidationError { empty, invalid }

    class Email extends FormzInput<String, EmailValidationError> {
      const Email.pure() : super.pure('');
      const Email.dirty([String value = '']) : super.dirty(value);

      static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

      @override
      EmailValidationError? validator(String value) {
        if (value.isEmpty) return EmailValidationError.empty;
        if (!_emailRegex.hasMatch(value)) return EmailValidationError.invalid;
        return null;
      }

      String? get errorMessage {
        if (isValid || isPure) return null;
        switch (error) {
          case EmailValidationError.empty:
            return 'Email is required';
          case EmailValidationError.invalid:
            return 'Enter a valid email';
          default:
            return null;
        }
      }
    }
    ```

  - Use in a `LoginPage` with a `LoginCubit`.

- **Categories**:
  - Add `Category` entity and `GetCategories` use case.
  - Update `ProductListPage` with a dropdown to filter products.

- **Local Storage**:
  - Use `shared_preferences` for theme persistence (already implemented).
  - Add a `LocalDataSource` with `hive` or `sembast` for offline product caching.

---

#### 7. Theme Switching

- `ThemeCubit` persists the theme using `shared_preferences`.
- The toggle button in `ProductListPage` switches between dark/light modes.
- `AppTheme` ensures consistent styling for both modes.

---

#### 8. Form Validation with Formz

- `Quantity` Formz model validates cart input.
- Extend Formz for other inputs (e.g., `Email`, `Password`, `Address`) as needed.
- Formz integrates seamlessly with Cubit for reactive validation.

---

#### 9. Dio Integration

- `Dio` is used in `RemoteDataSourceImpl` for API calls.
- Add interceptors for logging or auth tokens if needed (`lib/core/network/dio_interceptors.dart`):

```dart
import 'package:dio/dio.dart';

void setupDioInterceptors(Dio dio) {
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      print('Request: ${options.method} ${options.uri}');
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('Response: ${response.statusCode}');
      return handler.next(response);
    },
    onError: (DioException e, handler) {
      print('Error: ${e.message}');
      return handler.next(e);
    },
  ));
}
```

Update `injection.dart`:

```dart
getIt.registerSingleton<Dio>(Dio()..interceptors.addAll(setupDioInterceptors()));
```

---

#### 10. Testing

- **Unit Test for Use Case** (`test/domain/usecases/get_products_test.dart`):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../lib/domain/entities/product.dart';
import '../../lib/domain/usecases/get_products.dart';
import '../../lib/domain/repositories/product_repository.dart';
import 'get_products_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  late GetProducts usecase;
  late MockProductRepository mockRepository;

  setUp() {
    mockRepository = MockProductRepository();
    usecase = GetProducts(mockRepository);
  }

  final tProducts = [
    Product(id: 1, name: 'Apple', price: 1.0, imageUrl: 'url'),
  ];

  test('should get products from the repository', () async {
    when(mockRepository.getProducts()).thenAnswer((_) async => tProducts);

    final result = await usecase();

    expect(result, tProducts);
    verify(mockRepository.getProducts());
    verifyNoMoreInteractions(mockRepository);
  });
}
```

Run `flutter pub run build_runner build` to generate mocks.

- **Widget Test for ProductListPage** (`test/presentation/pages/product_list_page_test.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/di/injection.dart';
import '../../lib/presentation/cubits/product/product_cubit.dart';
import '../../lib/presentation/cubits/theme/theme_cubit.dart';
import '../../lib/presentation/pages/product_list_page.dart';

void main() {
  setUp(() {
    setup();
  });

  testWidgets('displays loading indicator when state is ProductLoading', (tester) async {
    final productCubit = getIt<ProductCubit>();
    final themeCubit = getIt<ThemeCubit>();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: productCubit),
          BlocProvider.value(value: themeCubit),
        ],
        child: const MaterialApp(home: ProductListPage()),
      ),
    );

    productCubit.emit(ProductLoading());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

---

### Notes

- **Cubit**: Simplifies state management compared to traditional BLoC by eliminating events.
- **Dio**: Provides robust HTTP handling with interceptors, retries, and caching support.
- **Formz**: Offers type-safe, reusable form validation integrated with Cubit.
- **API**: Replace `https://api.example.com/products` with a real API (e.g., Firebase, Supabase).
- **Enhancements**:
  - Add `cached_network_image` for efficient image loading.
  - Implement pull-to-refresh in `ProductListPage`.
  - Add animations for theme transitions using `AnimatedSwitcher`.
- **Testing**: Extend tests for `AddToCartCubit` and form validation.

This setup delivers a clean, scalable grocery store app with dark/light themes, Formz validation, and Dio for API calls. Let me know if you need deeper details (e.g., cart implementation, login page) or specific extensions!