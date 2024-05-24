import 'package:flutter_splim/dto/PriceDTO.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/dto/Shop.dart';
import 'dart:convert';

class PriceService{
  Future<List<PriceDTO>> fetchPriceDetails(String regday) async {
    final response = await http.get(Uri.parse('http://192.168.0.54:8080/prices/saving/detail/$regday'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => PriceDTO.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load price details');
    }
  }

  Future<List<PriceDTO>> fetchPriceTop3(String regday) async {
    final response = await http.get(Uri.parse('http://192.168.0.54:8080/prices/saving/top3/$regday'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => PriceDTO.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load price top3');
    }
  }

  Future<List<Shop>> fetchPriceIncreaseValues(String regday) async {
    final response = await http.get(Uri.parse('http://192.168.0.54:8080/prices/shopping/increase/$regday'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => Shop.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load shop increase');
    }
  }

  Future<List<Shop>> fetchPriceDecreaseValues(String regday) async {
    final response = await http.get(Uri.parse('http://192.168.0.54:8080/prices/shopping/decrease/$regday'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => Shop.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load shop decrease');
    }
  }

}