import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:product_app/models/auth.dart';
import 'package:product_app/models/location_data.dart';
import 'package:product_app/models/product.dart';
import 'package:product_app/models/user.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mime/mime.dart';

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

  Timer _authTimer;

  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

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
        _authenticatedUser = User(
          id: responseData['localId'],
          email: responseData['email'],
          token: responseData['idToken'],
        );
        setAuthTimeout(int.parse(responseData['expiresIn']));
        _userSubject.add(true);
        final DateTime now = DateTime.now();
        final DateTime expiryTime =
            now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', responseData['idToken']);
        prefs.setString('userEmail', responseData['email']);
        prefs.setString('userId', responseData['localId']);
        prefs.setString('expiryTime', expiryTime.toIso8601String());
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

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifespan);
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("userEmail");
    prefs.remove("userId");
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

mixin ProductModel on ConnectedProductModel {
  bool _showFavorites = false;

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

  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final storeImageUri =
        'https://us-central1-flutter-products-b83d5.cloudfunctions.net/storeImage';
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(storeImageUri));
    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(
        mimeTypeData[0],
        mimeTypeData[1],
      ),
    );
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['Authorization'] =
        'Bearer ${_authenticatedUser.token}';

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) return null;
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      return null;
    }
  }

  Future<bool> addProduct(String title, String description, File image,
      double price, LocationData locationData) async {
    _isLoading = true;
    notifyListeners();
    final uploadData = await uploadImage(image);
    if (uploadData == null) return false;
    final dbUrl =
        'https://flutter-products-b83d5.firebaseio.com/products.json?auth=${_authenticatedUser.token}';
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
      'location_lat': locationData.latitude,
      'location_lng': locationData.longitude,
      'location_address': locationData.address
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
        image: uploadData['imageUrl'],
        imagePath: uploadData['imagePath'],
        price: price,
        location: locationData,
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

  Future<bool> updateProduct(String title, String description, File image,
      double price, LocationData locationData) async {
    _isLoading = true;
    notifyListeners();
    String imagePath = selectedProduct.imagePath;
    String imageUrl = selectedProduct.image;
    if (image != null) {
      final uploadData = await uploadImage(image);
      if (uploadData == null) return false;
      imagePath = uploadData['imagePath'];
      imageUrl = uploadData['imageUrl'];
    }
    final dbUrl =
        "https://flutter-products-b83d5.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}";
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'location_lat': locationData.latitude,
      'location_lng': locationData.longitude,
      'location_address': locationData.address
    };
    try {
      final requestData = json.encode(updateData);
      final http.Response response = await http.put(dbUrl, body: requestData);
      final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: title,
        description: description,
        image: imageUrl,
        imagePath: imagePath,
        price: price,
        location: locationData,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
      );
      _products[selectedProductIndex] = updatedProduct;
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
    final dbUrl =
        "https://flutter-products-b83d5.firebaseio.com/products/$deletedProductId.json?auth=${_authenticatedUser.token}";
    try {
      await http.delete(dbUrl);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Null> fetchProducts({onlyForUser = false}) async {
    _isLoading = true;
    notifyListeners();
    final dbUrl =
        'https://flutter-products-b83d5.firebaseio.com/products.json?auth=${_authenticatedUser.token}';
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
            image: productData['imageUrl'],
            imagePath: productData['imagePath'],
            price: productData['price'],
            location: LocationData(
              address: productData['location_address'],
              latitude: productData['location_lat'],
              longitude: productData['location_lng'],
            ),
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            isFavorite: productData['wishlistUsers'] == null
                ? false
                : (productData['wishlistUsers'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));
        fetchedProductList.add(product);
      });
      _products = onlyForUser
          ? fetchedProductList.where((Product product) {
              return product.userId == _authenticatedUser.id;
            }).toList()
          : fetchedProductList;
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleProductFavoriteStatus() async {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updateProduct = Product(
      id: selectedProduct.id,
      title: selectedProduct.title,
      description: selectedProduct.description,
      price: selectedProduct.price,
      image: selectedProduct.image,
      imagePath: selectedProduct.imagePath,
      location: selectedProduct.location,
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.userId,
      isFavorite: newFavoriteStatus,
    );
    _products[selectedProductIndex] = updateProduct;
    notifyListeners();
    final dbUrl =
        'https://flutter-products-b83d5.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}';
    final requestData = json.encode(true);
    http.Response response;
    if (newFavoriteStatus) {
      response = await http.put(dbUrl, body: requestData);
    } else {
      response = await http.delete(dbUrl);
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product updateProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        imagePath: selectedProduct.imagePath,
        location: selectedProduct.location,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorite: !newFavoriteStatus,
      );
      _products[selectedProductIndex] = updateProduct;
      notifyListeners();
    }
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    if (productId != null) {
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
