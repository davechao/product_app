import 'package:product_app/scoped_models/product_model.dart';
import 'package:product_app/scoped_models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model with UserModel, ProductModel {}
