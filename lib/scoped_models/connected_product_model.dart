import 'package:product_app/models/product.dart';
import 'package:product_app/models/user.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

mixin ConnectedProductModel on Model {
  List<Product> _products = [];
  int _selProductIndex;
  User _authenticatedUser;

  void addProduct(
      String title, String description, String image, double price) {
    final serverUrl =
        'https://flutter-products-b83d5.firebaseio.com/products.json';
    final imageUrl =
        'https://cdn.pixabay.com/photo/2015/10/02/12/00/chocolate-968457_960_720.jpg';
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image': imageUrl,
      'price': price
    };
    final requestData = json.encode(productData);
    http.post(serverUrl, body: requestData).then((http.Response response) {
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
      notifyListeners();
    });
  }
}

mixin UserModel on ConnectedProductModel {
  void login(String email, String password) {
    _authenticatedUser = User(id: 'userId', email: email, password: password);
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
    return _selProductIndex;
  }

  Product get selectedProduct {
    if (selectedProductIndex == null) return null;
    return _products[selectedProductIndex];
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  void updateProduct(
      String title, String description, String image, double price) {
    final Product updatedProduct = Product(
      title: title,
      description: description,
      image: image,
      price: price,
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.userId,
    );
    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void deleteProduct() {
    _products.removeAt(selectedProductIndex);
    _selProductIndex = null;
    notifyListeners();
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updateProduct = Product(
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

  void selectProduct(int index) {
    _selProductIndex = index;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}
