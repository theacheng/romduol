import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:romduol/configs/palette.dart';
import 'package:romduol/models/date.dart';
import 'package:romduol/models/models.dart';
import 'package:romduol/widget/networkImage.dart';
import 'package:romduol/widget/star_rating.dart';

class CommentPage extends StatefulWidget {
  const CommentPage(
      {Key key,
      @required this.comments,
      @required this.isKH,
      @required this.scrollController})
      : super(key: key);
  final bool isKH;
  final ScrollController scrollController;
  final List<CommentModel> comments;

  @override
  _CommentPageState createState() => _CommentPageState();
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class _CommentPageState extends State<CommentPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: ListView(
        controller: widget.scrollController,
        children: [
          for (int index = 0; index < widget.comments.length; index++)
            buildComment(width, index),
        ],
      ),
    );
  }

  Widget buildComment(double width, int index) {
    DateTime _date = widget.comments[index].date.toDate();
    Date _finalDate = Date().toKhDate(_date, widget.isKH);
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("userData")
            .doc(widget.comments[index].uid)
            .snapshots(),
        builder: (context, snapshot) {
          String image = "";
          String name = "";
          if (snapshot.hasData) {
            name = snapshot.data['lname'] + " " + snapshot.data['fname'];
            image = snapshot.data['image'];
          }
          return Container(
            width: width,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            margin: EdgeInsets.only(
              bottom: index == widget.comments.length - 1 ? 10 : 0,
              top: index == 0 ? 10 : 0,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Palette.sky),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      padding: EdgeInsets.all(1),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: NetworkImageLoader(
                            imagelocation: image.isNotEmpty
                                ? image
                                : "https://firebasestorage.googleapis.com/v0/b/romduoltravel.appspot.com/o/commons%2Ferror-image-generic.png?alt=media&token=4fdd9d9b-04f6-4228-8b13-cd19a27fd44f",
                            width: 35,
                            height: 35,
                            onPressed: () {},
                          )),
                    ),
                    SizedBox(width: 10.0),
                    Container(
                      decoration: buildBoxDecoration().copyWith(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      width: width - 35 - 10 - 20 - 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name.isNotEmpty ? name : "Anonymous",
                                textAlign: TextAlign.start,
                              ),
                              StarRating(
                                rating:
                                    widget.comments[index].rating.toDouble(),
                              )
                            ],
                          ),
                          Text(
                            _finalDate.day +
                                " " +
                                _finalDate.month +
                                " " +
                                _finalDate.year,
                            style: TextStyle(fontSize: 11),
                          ),
                          SizedBox(height: 5),
                          Text(widget.comments[index].comment),
                          SizedBox(height: 5),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black87.withOpacity(0.1),
          blurRadius: 1.0,
          offset: Offset(0, 0),
        )
      ],
      color: Colors.white,
    );
  }

  PreferredSize buildAppBar(BuildContext context, String title) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: AppBar(
        elevation: 0.5,
        backgroundColor: Palette.sky,
        titleSpacing: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
