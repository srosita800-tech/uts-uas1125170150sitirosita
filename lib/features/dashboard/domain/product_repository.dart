import '../../data/model/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20, String? category});
  Future<ProductModel> getProductById(int id);
}