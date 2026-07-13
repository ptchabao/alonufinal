import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/order_repository_impl.dart';
import '../data/repositories/artisan_remote_repository_impl.dart';
import '../data/datasources/artisan_remote_data_source.dart';
import '../data/datasources/order_remote_data_source.dart';
import '../domain/repositories/artisan_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/order_repository.dart';
import '../domain/usecases/artisan_usecases.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/order_usecases.dart';
import '../core/network/dio_client.dart';
import '../core/constants/app_constants.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Secure Storage
  const secureStorage = FlutterSecureStorage();
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: AppConstants.sendTimeout),
    ),
  );

  dio.interceptors.add(AuthInterceptor(secureStorage));
  dio.interceptors.add(LoggingInterceptor());

  getIt.registerSingleton<Dio>(dio);

  // Data Sources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(getIt<Dio>()),
  );

  // Register artisan remote datasource for repository wiring
  getIt.registerSingleton<ArtisanRemoteDataSource>(
    ArtisanRemoteDataSourceImpl(getIt<Dio>()),
  );

  getIt.registerSingleton<OrderRemoteDataSource>(
    OrderRemoteDataSourceImpl(getIt<Dio>()),
  );

  getIt.registerSingleton<AuthLocalDataSource>(
    AuthLocalDataSourceImpl(),
  );

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      secureStorage: secureStorage,
    ),
  );

  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Replace mock repositories with remote implementations wired to datasources
  getIt.registerSingleton<ArtisanRepository>(
    ArtisanRemoteRepositoryImpl(getIt<ArtisanRemoteDataSource>()),
  );
  getIt.registerSingleton<ProductRepository>(
    RemoteProductRepositoryImpl(getIt<ArtisanRemoteDataSource>()),
  );
  getIt.registerSingleton<OrderRepository>(
    OrderRepositoryImpl(getIt<OrderRemoteDataSource>()),
  );
  getIt.registerSingleton<PaymentRepository>(PaymentRepositoryImpl());

  // Use Cases
  getIt.registerSingleton<LoginUseCase>(LoginUseCase(getIt<AuthRepository>()));
  getIt.registerSingleton<RegisterUseCase>(RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerSingleton<LogoutUseCase>(LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerSingleton<IsAuthenticatedUseCase>(IsAuthenticatedUseCase(getIt<AuthRepository>()));
  getIt.registerSingleton<GetCachedTokenUseCase>(GetCachedTokenUseCase(getIt<AuthRepository>()));
  getIt.registerSingleton<ChangePasswordUseCase>(ChangePasswordUseCase(getIt<AuthRepository>()));

  getIt.registerSingleton<GetCategoriesUseCase>(GetCategoriesUseCase(getIt<ArtisanRepository>()));
  getIt.registerSingleton<GetSubcategoriesUseCase>(GetSubcategoriesUseCase(getIt<ArtisanRepository>()));
  getIt.registerSingleton<GetNearbyArtisansUseCase>(GetNearbyArtisansUseCase(getIt<ArtisanRepository>()));
  getIt.registerSingleton<GetArtisanDetailsUseCase>(GetArtisanDetailsUseCase(getIt<ArtisanRepository>()));
  getIt.registerSingleton<CreateArtisanProfileUseCase>(CreateArtisanProfileUseCase(getIt<ArtisanRepository>()));
  getIt.registerSingleton<UpdateArtisanProfileUseCase>(UpdateArtisanProfileUseCase(getIt<ArtisanRepository>()));
  getIt.registerSingleton<GetRealisationsUseCase>(GetRealisationsUseCase(getIt<ArtisanRepository>()));
  getIt.registerSingleton<AddRealisationUseCase>(AddRealisationUseCase(getIt<ArtisanRepository>()));
  getIt.registerSingleton<DeleteRealisationUseCase>(DeleteRealisationUseCase(getIt<ArtisanRepository>()));

  getIt.registerSingleton<GetProductsUseCase>(GetProductsUseCase(getIt<ProductRepository>()));
  getIt.registerSingleton<GetProductDetailsUseCase>(GetProductDetailsUseCase(getIt<ProductRepository>()));
  getIt.registerSingleton<CreateProductUseCase>(CreateProductUseCase(getIt<ProductRepository>()));
  getIt.registerSingleton<UpdateProductUseCase>(UpdateProductUseCase(getIt<ProductRepository>()));
  getIt.registerSingleton<DeleteProductUseCase>(DeleteProductUseCase(getIt<ProductRepository>()));
  getIt.registerSingleton<ToggleProductActiveUseCase>(ToggleProductActiveUseCase(getIt<ProductRepository>()));
  getIt.registerSingleton<GetArtisanProductsUseCase>(GetArtisanProductsUseCase(getIt<ProductRepository>()));

  getIt.registerSingleton<CreateOrderUseCase>(CreateOrderUseCase(getIt<OrderRepository>()));
  getIt.registerSingleton<GetMyOrdersUseCase>(GetMyOrdersUseCase(getIt<OrderRepository>()));
  getIt.registerSingleton<GetOrderDetailsUseCase>(GetOrderDetailsUseCase(getIt<OrderRepository>()));
  getIt.registerSingleton<UpdateOrderStatusUseCase>(UpdateOrderStatusUseCase(getIt<OrderRepository>()));
  getIt.registerSingleton<CancelOrderUseCase>(CancelOrderUseCase(getIt<OrderRepository>()));

  getIt.registerSingleton<InitiateOrderPaymentUseCase>(InitiateOrderPaymentUseCase(getIt<PaymentRepository>()));
  getIt.registerSingleton<CheckPaymentStatusUseCase>(CheckPaymentStatusUseCase(getIt<PaymentRepository>()));
  getIt.registerSingleton<GetPaymentHistoryUseCase>(GetPaymentHistoryUseCase(getIt<PaymentRepository>()));
}
