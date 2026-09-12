import '../widgets/custom_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cando_mobprog/constants.dart';

import '../models/post.dart';
import '../screens/detail_screen.dart';

class CustomInformation extends StatelessWidget {
  const CustomInformation({
    super.key,
    required this.name,
    required this.post,
    required this.description,
    this.icon = const Icon(Icons.person),
    this.profileImageUrl = '',
    this.atProfile = false,
    required this.date,
    this.imageUrl = '',
    required this.numOfLikes,
    this.detailPost,
  });

  final String name;
  final String post;
  final String description;
  final Icon icon;
  final String profileImageUrl;
  final bool atProfile;
  final String date;
  final String imageUrl;
  final int numOfLikes;
  final Post? detailPost;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!atProfile) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                post: detailPost,
                userName: name,
                postContent: description,
                date: date,
                profileImageUrl: profileImageUrl,
                imageUrl: imageUrl,
                numOfLikes: numOfLikes,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setSp(15)),
        child: Row(
          children: [
            //LAB 4 ENHANCEMENT 2
            (profileImageUrl == '')
                ? const Icon(Icons.person, color: FB_DARK_BLUE)
                : CircleAvatar(
                    radius: ScreenUtil().setSp(15),
                    backgroundImage: AssetImage(
                      'assets/images/$profileImageUrl',
                    ),
                  ),
            SizedBox(width: ScreenUtil().setWidth(10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomFont(
                  text: name,
                  fontSize: ScreenUtil().setSp(20),
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
                CustomFont(
                  text: 'Posted: $post',
                  fontSize: ScreenUtil().setSp(13),
                  color: Colors.black,
                ),
                CustomFont(
                  text: description,
                  fontSize: ScreenUtil().setSp(12),
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
                SizedBox(height: ScreenUtil().setHeight(5)),
                CustomFont(
                  text: date,
                  fontSize: ScreenUtil().setSp(12),
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.more_horiz),
          ],
        ),
      ),
    );
  }
}
