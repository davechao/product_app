import 'package:product_app/scoped_models/connected_product_model.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model
    with ConnectedProductModel, UserModel, ProductModel, UtilityModel {}
