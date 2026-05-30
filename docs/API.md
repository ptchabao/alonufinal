# ALONU API Documentation

## Overview

The ALONU app communicates with a backend API using REST over HTTP with Dio client and JWT authentication.

## Base Configuration

- **Base URL**: Defined in `lib/core/constants/app_constants.dart`
- **Timeout**: 30 seconds for all requests
- **Authentication**: Bearer token (JWT)

## API Client

### Initialization

The API client is initialized in `service_locator.dart`:

```dart
final dio = Dio(
  BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: Duration(milliseconds: 30000),
    receiveTimeout: Duration(milliseconds: 30000),
  ),
);

dio.interceptors.add(AuthInterceptor(secureStorage));
dio.interceptors.add(LoggingInterceptor());
```

## Interceptors

### AuthInterceptor

Automatically:
- Adds Bearer token to requests
- Refreshes expired tokens
- Handles 401 unauthorized responses

### LoggingInterceptor

Logs all HTTP requests and responses for debugging.

## Error Handling

All API errors are mapped to `Failure` classes:

```dart
class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}
```

## Authentication Endpoints

### Login
```
POST /auth/login
Body: {
  "identifier": "email or username",
  "password": "password",
  "rememberMe": true
}
Response: {
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token",
  "expiresAt": "2024-12-31T23:59:59Z",
  "user": { ... }
}
```

### Register
```
POST /auth/register
Body: {
  "username": "username",
  "email": "email@example.com",
  "password": "password",
  "nom": "surname",
  "prenom": "firstname",
  "telephone": "+1234567890",
  "role": "CLIENT|ARTISAN|STUDENT",
  "countryId": "country_id",
  "referralCode": "optional_code"
}
Response: { User object }
```

### Logout
```
POST /auth/logout
```

### Refresh Token
```
POST /auth/refresh
Body: {
  "refreshToken": "refresh_token"
}
Response: {
  "accessToken": "new_jwt_token",
  "expiresAt": "2024-12-31T23:59:59Z"
}
```

## User Profile

### Get User Profile
```
GET /users/me
Headers: Authorization: Bearer {accessToken}
Response: { User object }
```

### Update User Profile
```
PUT /users/me
Body: { updated fields }
Response: { User object }
```

## Artisans

### List Artisans
```
GET /artisans?page=1&limit=20&category=plumbing
Response: {
  "data": [ Artisan objects ],
  "total": 100,
  "page": 1,
  "limit": 20
}
```

### Get Artisan Details
```
GET /artisans/{id}
Response: { Artisan object with services }
```

### Search Artisans
```
GET /artisans/search?query=plumber&latitude=6.8276&longitude=5.0893
Response: { Artisan object array }
```

## Orders

### Create Order
```
POST /orders
Body: {
  "artisanId": "artisan_id",
  "items": [
    {
      "serviceId": "service_id",
      "quantity": 1,
      "price": 50000
    }
  ],
  "totalAmount": 50000,
  "deliveryAddress": "address",
  "notes": "special notes"
}
Response: { Order object }
```

### Get Orders
```
GET /orders?status=CONFIRMED&limit=20
Headers: Authorization: Bearer {accessToken}
Response: { Order array }
```

### Get Order Details
```
GET /orders/{id}
Response: { Order object }
```

### Update Order Status
```
PUT /orders/{id}/status
Body: { "status": "IN_PROGRESS|COMPLETED|CANCELLED" }
Response: { Order object }
```

## Payments

### Initialize Payment
```
POST /payments/initialize
Body: {
  "orderId": "order_id",
  "amount": 50000,
  "method": "FLOOZ|TMONEY|CARD",
  "currency": "XOF"
}
Response: {
  "reference": "payment_ref",
  "status": "PENDING",
  "paymentUrl": "https://..."
}
```

### Confirm Payment
```
POST /payments/{reference}/confirm
Body: { "transactionId": "tx_id" }
Response: { Payment object }
```

## Notifications

### Get Notifications
```
GET /notifications?unread=true&limit=20
Response: { Notification array }
```

### Mark as Read
```
POST /notifications/{id}/read
```

## Response Format

All successful responses follow this format:

```json
{
  "success": true,
  "data": {},
  "message": "Operation successful"
}
```

Error responses:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Error description"
  }
}
```

## Status Codes

- **200**: Success
- **201**: Created
- **204**: No Content
- **400**: Bad Request
- **401**: Unauthorized
- **403**: Forbidden
- **404**: Not Found
- **409**: Conflict
- **422**: Validation Error
- **500**: Server Error
- **503**: Service Unavailable

## Rate Limiting

- **Limit**: 100 requests per minute
- **Header**: `X-RateLimit-Remaining`

## Pagination

List endpoints support pagination:

```
GET /resource?page=1&limit=20&sort=createdAt&order=DESC
```

Query parameters:
- `page`: Page number (starts at 1)
- `limit`: Items per page (max 100)
- `sort`: Sort field name
- `order`: ASC or DESC

## Authentication Flow

1. User logs in with credentials
2. Server returns `accessToken` and `refreshToken`
3. Token stored in secure storage
4. All requests include `Authorization: Bearer {accessToken}` header
5. When token expires, `AuthInterceptor` automatically refreshes it
6. If refresh fails, user is logged out

## Example Usage

```dart
final dio = getIt<Dio>();

try {
  final response = await dio.post(
    '/auth/login',
    data: {
      'identifier': 'user@example.com',
      'password': 'password123',
    },
  );
  
  final authData = AuthResponseModel.fromJson(response.data);
  // Handle success
} on DioException catch (e) {
  // Handle error
  print('Error: ${e.message}');
}
```

## Development

### Mock API

For development without a real backend, use the mock data in data sources:

```dart
// Toggle in app constants
const bool USE_MOCK_DATA = true;
```

### Testing API Calls

Use Postman or similar tools:

1. Import API base URL
2. Set Authorization header with Bearer token
3. Test endpoints

## Security

- Always use HTTPS in production
- Store tokens securely using `flutter_secure_storage`
- Never expose tokens in logs
- Validate SSL certificates
- Implement certificate pinning for production

## Changelog

### v1.0.0
- Initial API documentation
- Authentication endpoints
- Core CRUD operations
