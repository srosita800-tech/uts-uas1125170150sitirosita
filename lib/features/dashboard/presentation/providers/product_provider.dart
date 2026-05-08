import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../data/model/product_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  String? _error;

  ProductStatus get status => _status;
  List<ProductModel> get products => _products;
  String? get error => _error;
  bool get isLoading => _status == ProductStatus.loading;

  // 1. FETCH PRODUK (Ambil semua 20+ laptop)
  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await DioClient.instance.get(
        ApiConstants.products,
        queryParameters: {
          'limit': 100,
          'page': 1,
        },
      );

      final List<dynamic> data = response.data['data'] ?? [];
      debugPrint("INFO: Berhasil ditarik ${data.length} laptop");

      _products = data.map((e) => ProductModel.fromJson(e)).toList();
      _status = ProductStatus.loaded;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Gagal memuat produk';
      _status = ProductStatus.error;
    } catch (e) {
      _error = "Terjadi kesalahan sistem";
      _status = ProductStatus.error;
    } finally {
      notifyListeners();
    }
  }

  // 2. CREATE PRODUCT (Untuk Admin)
  Future<bool> createProduct({
    required String name,
    required double price,
    required String category,
    String? description,
    int? stock,
    File? imageFile,
    String? imageUrl,
  }) async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      Map<String, dynamic> body = {
        "name": name,
        "price": price,
        "category": category,
        "description": description ?? "",
        "stock": stock ?? 0,
        "image_url": imageUrl ?? "",
      };

      FormData formData = FormData.fromMap(body);
      if (imageFile != null) {
        formData.files.add(MapEntry(
          "image",
          await MultipartFile.fromFile(imageFile.path),
        ));
      }

      await DioClient.instance.post(ApiConstants.products, data: formData);
      await fetchProducts(); 
      return true;
    } catch (e) {
      _error = "Gagal simpan produk";
      return false;
    } finally {
      _status = ProductStatus.loaded;
      notifyListeners();
    }
  }

  // 3. UPDATE PRODUCT (Untuk Admin)
  Future<bool> updateProduct(
    int id, {
    required String name,
    required double price,
    required String category,
    String? description,
    int? stock,
    File? imageFile,
    String? imageUrl,
  }) async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      Map<String, dynamic> body = {
        "name": name,
        "price": price,
        "category": category,
        "description": description ?? "",
        "stock": stock ?? 0,
        "image_url": imageUrl ?? "",
      };
      
      FormData formData = FormData.fromMap(body);
      if (imageFile != null) {
        formData.files.add(MapEntry(
          "image",
          await MultipartFile.fromFile(imageFile.path),
        ));
      }

      await DioClient.instance.put("${ApiConstants.products}/$id", data: formData);
      await fetchProducts();
      return true;
    } catch (e) {
      _error = "Gagal update produk";
      return false;
    } finally {
      _status = ProductStatus.loaded;
      notifyListeners();
    }
  }

  // 4. DELETE PRODUCT (Untuk Admin)
  Future<bool> deleteProduct(int id) async {
    try {
      await DioClient.instance.delete("${ApiConstants.products}/$id");
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Gagal hapus produk";
      return false;
    }
  }
}