import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/recipeview/recipeview.dart';
import 'package:flutter_splim/search/search.dart';

class MyPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 탭의 개수
      initialIndex: 3, // 초기화할 탭의 인덱스 (0부터 시작)
      child: Scaffold(
        appBar: AppBar(
          title: Text('MyProfile'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
            ),
          ],
        ),

        body: TabBarView(
          children: [
            Container(),
            Container(),
            Container(),
            MyScreen(), // 마이페이지
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 3,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.blue),
              label: 'Home',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search, color: Colors.blue),
                label: 'Search',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view, color: Colors.blue),
                label: 'Recipe',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Colors.blue),
                label: 'My Page',
                backgroundColor: Colors.amber
            ),
          ],

          selectedItemColor: Colors.blue,

          onTap: (int index) {
            if (index == 0) {
              Navigator.pop(context);
            }
            else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            }
            else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipeView()),
              );
            }
          },
        ),
      ),
    );
  }
}

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('My Screen'),
    );
  }
}