import 'package:flutter/material.dart';
import 'package:flutter_splim/constant.dart';
import 'package:flutter_splim/dto/RecipeDTO.dart';
import 'package:flutter_splim/mobile/mypage/recipe/otherRecipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_splim/mobile/mypage/recipe/modify.dart';
import 'package:flutter_splim/mobile/mypage/recipe/share.dart';

class RecipeListPage extends StatefulWidget {
  final int userId;

  RecipeListPage({required this.userId});

  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late Future<List<RecipeDTO>> recipeList;
  bool isEditing = false;
  List<int> selectedIds = [];
  List<int> selectedOtherIds = [];

  @override
  void initState() {
    super.initState();
    recipeList = fetchRecipeList(widget.userId);
  }

  Future<List<RecipeDTO>> fetchRecipeList(int userId) async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/recipe/list/$userId'));

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        List jsonResponse = json.decode(responseBody);
        return jsonResponse.map((data) => RecipeDTO.fromJson(data)).toList();
      } else {
        print('Error: ${response.reasonPhrase}');
        throw Exception('Failed to load recipe list');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to load recipe list');
    }
  }

  Future<void> deleteRecipesAndselected(List<int> recipeIds, List<int> addSelectedIds) async {
    try {
      // 레시피 삭제
      for (int id in recipeIds) {
        final response = await http.put(
          Uri.parse('${Constants.baseUrl}/recipe/deleteAt/$id'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        if (response.statusCode == 200) {
          print('ID가 $id인 레시피가 성공적으로 삭제되었습니다.');
        } else {
          print('ID가 $id인 레시피 삭제에 실패했습니다: ${response.reasonPhrase}');
        }
      }

      // 선택된 추가 레시피 삭제
      for (int id in addSelectedIds) {
        final response = await http.delete(
          Uri.parse('${Constants.baseUrl}/add/delete/${widget.userId}/$id'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        if (response.statusCode == 200) {
          print('ID가 $id인 선택된 추가 레시피가 성공적으로 삭제되었습니다.');
        } else {
          print('ID가 $id인 선택된 추가 레시피 삭제에 실패했습니다: ${response.reasonPhrase}');
          print('서버 응답 내용: ${response.body}');
        }
      }

      setState(() {
        recipeList = fetchRecipeList(widget.userId);
        selectedIds.clear();
        selectedOtherIds.clear();
      });
    } catch (e) {
      print('레시피 삭제 중 오류 발생: $e');
    }
  }

  Future<void> _showDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 바깥을 눌러도 다이얼로그가 닫히지 않음
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('삭제하면 다시는 볼 수 없습니다.'),
                Text('정말 삭제하시겠습니까?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                deleteRecipesAndselected(selectedIds, selectedOtherIds); // 선택된 항목 삭제 함수 호출
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피 목록'),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        scrolledUnderElevation: 0,
        actions: [
          // 편집 버튼
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
                if (!isEditing) {
                  selectedIds.clear();
                  selectedOtherIds.clear();
                }
              });
            },
            child: Text(
              isEditing ? '완료' : '편집',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
      Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        '(공개 : 공유 상태, 비공개 : 비공개, 외부 : 외부 레시피)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey
        ),
      ),
    ),
      Expanded(
        child:FutureBuilder<List<RecipeDTO>>(
        future: recipeList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('레시피 목록이 없습니다.'));
          } else {
            return Scrollbar(
               // Show scrollbar always
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  RecipeDTO recipeDTO = snapshot.data![index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: index == 0 ? BorderSide(width: 1.0, color: Colors.grey) : BorderSide.none,
                        bottom: BorderSide(width: 1.0, color: Colors.grey),
                      ),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 3),
                    child: ListTile(
                      title: Text(recipeDTO.title),
                      trailing: Text(
                        recipeDTO.userDTO.id == widget.userId
                            ? (recipeDTO.status ? '공개' : '비공개')
                            : '외부',
                        style: TextStyle(
                          color: recipeDTO.userDTO.id == widget.userId
                              ? (recipeDTO.status ? Colors.green : Colors.blue)
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        if (!isEditing) {
                          if (recipeDTO.status) {
                            if (recipeDTO.userDTO.id == widget.userId) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SharePage(recipeDTO: recipeDTO),
                                ),
                              ).then((value) => setState(() {
                                recipeList = fetchRecipeList(widget.userId);
                              }));
                            } else {
                              // 다른 사용자의 레시피를 클릭한 경우 추가 동작을 정의할 수 있습니다.
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtherRecipePage(recipeDTO: recipeDTO),
                                ),
                              ).then((value) => setState(() {
                                recipeList = fetchRecipeList(widget.userId);
                              }));
                            }
                          } else {
                            if (recipeDTO.userDTO.id == widget.userId){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModifyPage(recipeDTO: recipeDTO),
                                ),
                              ).then((value) => setState(() {
                                recipeList = fetchRecipeList(widget.userId);
                              }));
                            }else{
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtherRecipePage(recipeDTO: recipeDTO),
                                ),
                              ).then((value) => setState(() {
                                recipeList = fetchRecipeList(widget.userId);
                              }));
                            }
                          }
                        }
                      },
                      leading: isEditing
                          ? Checkbox(
                        value: selectedIds.contains(recipeDTO.id) || selectedOtherIds.contains(recipeDTO.id),
                        onChanged: (value) {
                          setState(() {
                            if (value != null && value) {
                              if (recipeDTO.userDTO.id == widget.userId) {
                                selectedIds.add(recipeDTO.id);
                              } else {
                                selectedOtherIds.add(recipeDTO.id);
                              }
                            } else {
                              if (selectedIds.contains(recipeDTO.id)) {
                                selectedIds.remove(recipeDTO.id);
                              }
                              if (selectedOtherIds.contains(recipeDTO.id)) {
                                selectedOtherIds.remove(recipeDTO.id);
                              }
                            }
                          });
                        },
                      )
                          : null,
                    ),
                  );
                },
              ),
            );
          }
        },
      ),),]
      ),

      floatingActionButton: isEditing
          ? FloatingActionButton(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            onPressed: () {
              _showDeleteDialog();
            },
            child: Icon(Icons.delete),
      ) : null, // 편집 모드에서만 삭제 버튼을 표시
    );
  }
}
