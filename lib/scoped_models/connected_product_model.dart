import 'package:product_app/models/auth.dart';
import 'package:product_app/models/product.dart';
import 'package:product_app/models/user.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

mixin ConnectedProductModel on Model {
  List<Product> _products = [];
  String _selProductId;
  User _authenticatedUser;
  bool _isLoading = false;
}

mixin UserModel on ConnectedProductModel {
  final signInUrl =
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyC4PNlXuVCsxgOUCnCwn9wYQcuyBPqZ5-M';
  final signUpUrl =
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyC4PNlXuVCsxgOUCnCwn9wYQcuyBPqZ5-M';

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode authMode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    bool hasError = true;
    String message = 'Something went wrong.';
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    final requestData = json.encode(authData);
    try {
      http.Response response;
      if (authMode == AuthMode.Login) {
        response = await http.post(
          signInUrl,
          body: requestData,
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        response = await http.post(
          signUpUrl,
          body: requestData,
          headers: {'Content-Type': 'application/json'},
        );
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('idToken')) {
        hasError = false;
        message = 'Authentication succeeded!';
      } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
        message = 'This email already exists.';
      } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
        message = 'This email was not found.';
      } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
        message = 'The password is invalid.';
      }
      _isLoading = false;
      notifyListeners();
      return {'success': !hasError, 'message': message};
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return {'success': !hasError, 'message': message};
    }
  }
}

mixin ProductModel on ConnectedProductModel {
  bool _showFavorites = false;
  final dbUrl = 'https://flutter-products-b83d5.firebaseio.com/products.json';

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites)
      return _products.where((Product product) => product.isFavorite).toList();
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == selectedProductId;
    });
  }

  String get selectedProductId {
    return _selProductId;
  }

  Product get selectedProduct {
    if (selectedProductId == null) return null;
    return _products.firstWhere((Product product) {
      return product.id == selectedProductId;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<bool> addProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();
    final imageUrl =
        'https://cdn.pixabay.com/photo/2015/10/02/12/00/chocolate-968457_960_720.jpg';
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image': imageUrl,
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    final requestData = json.encode(productData);
    try {
      final http.Response response = await http.post(dbUrl, body: requestData);
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
        id: responseData['name'],
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
      );
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();
    final serverUrl =
        "https://flutter-products-b83d5.firebaseio.com/products/${selectedProduct.id}.json";
    final imageUrl =
        'https://cdn.pixabay.com/photo/2015/10/02/12/00/chocolate-968457_960_720.jpg';
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image': imageUrl,
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId
    };
    final requestData = json.encode(updateData);
    try {
      await http.put(serverUrl, body: requestData);
      final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
      );
      _products[selectedProductIndex] = updatedProduct;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct() async {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();
    final serverUrl =
        "https://flutter-products-b83d5.firebaseio.com/products/$deletedProductId.json";
    try {
      await http.delete(serverUrl);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Null> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final http.Response response = await http.get(dbUrl);
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
      }
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            image: productData['image'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId']);
        fetchedProductList.add(product);
      });
      _products = fetchedProductList;
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updateProduct = Product(
      id: selectedProduct.id,
      title: selectedProduct.title,
      description: selectedProduct.description,
      price: selectedProduct.price,
      image: selectedProduct.image,
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.userId,
      isFavorite: newFavoriteStatus,
    );
    _products[selectedProductIndex] = updateProduct;
    notifyListeners();
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    if (_selProductId != null) {
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

mixin UtilityModel on ConnectedProductModel {
  bool get isLoading {
    return _isLoading;
  }
}
