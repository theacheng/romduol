import 'package:auto_animated/auto_animated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:romduol/configs/palette.dart';
import 'package:romduol/configs/scrollnotifer.dart';
import 'package:romduol/data/data.dart';
import 'package:romduol/lang/lang.dart';
import 'package:romduol/main.dart';
import 'package:romduol/models/models.dart';
import 'package:romduol/screens/package/package_detail.dart';
import 'package:romduol/screens/myapp.dart';
import 'package:romduol/screens/province/province.dart';
import 'package:romduol/widget/drawer.dart';
import 'package:romduol/widget/location.dart';
import 'package:romduol/widget/networkImage.dart';
import 'package:romduol/widget/pageroutetransition.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:romduol/widget/theme/theme.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  final Function onTab;
  const HomePage({Key key, this.onTab}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0.0);
  double offset = 0;
  bool isKH = true;

  @override
  void initState() {
    getLang();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void getLang() async {
    isKH = await Lang().isKH();
    setState(() {
      if (isKH == null) {
        Lang().setLang(true);
        isKH = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<PackageModel> packages =
        Provider.of<List<PackageModel>>(context) ?? [];
    var scaffoldKey = GlobalKey<ScaffoldState>();
    // Backup().autoBackupProvince();
    // Backup().autoBackupPackages();

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (_) => ScrollNotifier(_scrollController),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Consumer<ScrollNotifier>(
              builder: (context, notifier, child) {
                return buildAppBar(
                  title: Lang().of(key: 'title', isKH: isKH),
                  onTab: () {},
                  elevation: math.min(notifier.offset * 0.05, 3),
                  isKH: isKH,
                );
              },
            ),
          ),
          drawer: HomeDrawer(
            onLangTab: () => setState(() {
              isKH = !isKH;
              Lang().setLang(isKH);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => SplashScreen()));
            }),
            isKH: isKH,
          ),
          body: GestureDetector(
            onHorizontalDragEnd: (e) {
              if (e.velocity.pixelsPerSecond.direction > 0 &&
                  e.velocity.pixelsPerSecond.dx > 0) {
                scaffoldKey.currentState.openDrawer();
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: -80 - 30.0,
                  child: Stack(
                    children: [
                      Container(
                        height: height * 0.85,
                        constraints: BoxConstraints(minHeight: 620),
                        width: width,
                        child: Consumer<ScrollNotifier>(
                          builder: (context, notifier, child) {
                            return Transform.translate(
                              offset: Offset(0, notifier.offset * 0.2),
                              child: child,
                            );
                          },
                          child: Image.asset(
                            "assets/home/background.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          color: Palette.sky.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Consumer<ScrollNotifier>(
                    builder: (context, notifier, child) {
                      return Transform.translate(
                        offset: Offset(0, -notifier.offset),
                        child: child,
                      );
                    },
                    child: Container(
                      height: height - 200,
                      width: width,
                      color: Palette.bg,
                    ),
                  ),
                ),
                ListView(
                  controller: _scrollController,
                  physics: RangeMaintainingScrollPhysics(),
                  children: [
                    //HELLO TITLE
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('questions')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData)
                          snapshot.data.docs.forEach(
                            (element) {
                              if (!question.contains(element['question']))
                                question.add(element['question']);
                            },
                          );
                        return hello(width, question);
                      },
                    ),

                    //PROVINCES
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      width: width,
                      decoration: buildBoxDecoration(),
                      child: Column(
                        children: [
                          sectionTitle(
                            context: context,
                            title: Lang().of(
                              key: 'chooseaprovince',
                              isKH: isKH,
                            ),
                            isKH: isKH,
                          ),
                          Stack(
                            children: [
                              Container(
                                height: width > 360 ? 155 : 290,
                                child: LiveGrid.options(
                                  physics: NeverScrollableScrollPhysics(),
                                  options: options,
                                  itemBuilder: (context, index, animation) {
                                    ProvinceModel data = provinces[index];
                                    return FadeTransition(
                                      opacity: Tween<double>(
                                        begin: 0,
                                        end: 1,
                                      ).animate(animation),
                                      child: buildProvinceCard(
                                        context: context,
                                        province: isKH
                                            ? data.province
                                            : data.enprovince,
                                        views: data.views,
                                        imagelocation: data.imagelocation,
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Province(
                                              province: data.province,
                                              enprovince: data.enprovince,
                                              isKH: isKH,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: 4,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: width > 360 * 2 ? 4 : 2,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                    childAspectRatio: 8 / 7,
                                  ),
                                ),
                              ),
                              width < 360 * 2
                                  ? Positioned.fill(
                                      top: -1.5,
                                      right: 0.2,
                                      child: IgnorePointer(
                                        child: Container(
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/graphics/provincedivider.svg',
                                              width: 100,
                                              height: 100,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    //ECO TRAVEL PACKAGE
                    Container(
                      decoration: buildBoxDecoration(),
                      padding: EdgeInsets.all(15),
                      width: width,
                      child: Column(
                        children: [
                          posterCard(width),
                          SizedBox(height: 5),
                          sectionTitle(
                            context: context,
                            title: Lang().of(key: 'joinwithus', isKH: isKH),
                            isKH: isKH,
                          ),
                          Wrap(
                            children: [
                              packages.length != null
                                  ? LiveList.options(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      options: options,
                                      itemCount: packages.length,
                                      itemBuilder: (context, i, animation) {
                                        return FadeTransition(
                                          opacity: Tween<double>(
                                            begin: 0,
                                            end: 1,
                                          ).animate(animation),
                                          child: packageCard(
                                            width: width,
                                            package: packages[i],
                                            onErrorPressed: () =>
                                                Navigator.pushReplacement(
                                              context,
                                              PageRouteTransition(
                                                child: MyApp(),
                                                duration:
                                                    Duration(milliseconds: 500),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Center(
                                      heightFactor: 2,
                                      child: CircularProgressIndicator(),
                                    ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final options = LiveOptions(
    showItemInterval: Duration(milliseconds: 100),
    showItemDuration: Duration(milliseconds: 500),
    visibleFraction: 0.05,
    reAnimateOnVisibility: false,
  );

  Container packageCard({
    double width,
    PackageModel package,
    Function onErrorPressed,
  }) {
    return Container(
      height: null,
      //package container
      width: width,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Palette.bgdark.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: FlatButton(
        highlightColor: Palette.text.withOpacity(0.05),
        splashColor: Palette.bg,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PackageDetail(
                package: package,
                isKH: isKH,
              ),
            ),
          );
        },
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Stack(
              //left side - image + booked/total people join
              children: [
                Container(
                  width: 110,
                  height: 60,
                  alignment: Alignment.center,
                  child: Hero(
                    tag: "thumnail" + package.thumbnail,
                    child: NetworkImageLoader(
                      onPressed: onErrorPressed,
                      imagelocation: package.thumbnail,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 110,
                    color: Palette.bgdark.withOpacity(0.25),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.white.withOpacity(1),
                            fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
                            fontWeight: FontWeight.w300,
                            fontSize: 11),
                        children: [
                          TextSpan(
                            text:
                                "${khNum(package.bookedspace.toString(), isKH)}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text:
                                "/${khNum(package.totalspace.toString(), isKH)} ",
                          ),
                          TextSpan(text: isKH ? 'នាក់' : "Joined")
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(width: 10),
            Container(
              //right side
              width: width - 110 - 40 - 10,
              //width = width - leftside(110) - padding(20) * 2 - sizebox(10)
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    //first row - title + price
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          package.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Palette.bgdark.withOpacity(0.8),
                            fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
                          ),
                        ),
                      ),
                      Text(
                        "${khNum(package.price.toString(), isKH)}\$",
                        style: TextStyle(
                          fontSize: 14,
                          color: Palette.sky,
                          fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0),

                  //second row - location + date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LocationText(
                        location: package.location,
                        isKH: isKH,
                      ),
                      SizedBox(width: 5),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 5,
                          ),
                          color: Palette.text.withOpacity(0.1),
                          child: Text(
                            khNum(package.date, isKH),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Palette.text,
                              fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget posterCard(double width) {
    return Consumer<ScrollNotifier>(
      builder: (context, notifier, child) {
        return Container(
          width: width,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Palette.sky,
            image: DecorationImage(
              image: AssetImage('assets/home/package_poster.png'),
              alignment: Alignment(0, notifier.offset.abs() * 0.002),
              fit: BoxFit.cover,
            ),
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Palette.sky.withOpacity(0.35),
              ),
            ),
            FlatButton(
              splashColor: Palette.bg.withOpacity(0.1),
              onPressed: () {},
              padding: EdgeInsets.zero,
              child: Container(
                height: 150,
                width: width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Palette.bgdark.withOpacity(0.2)),
                child: Container(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Lang().of(key: 'ecotravelpackage', isKH: isKH),
                        style: TextStyle(
                          color: Colors.white.withOpacity(1),
                          fontFamily: isKH ? 'Kantumruy' : 'Playfair',
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        Lang().of(key: 'posterpackageinfo', isKH: isKH),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontFamily: isKH ? 'Kantumruy' : 'Playfair',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 10,
              child: Container(
                width: 104.0 + 17,
                child: FlatButton.icon(
                  splashColor: Palette.sky.withOpacity(0.15),
                  color: Palette.sky.withOpacity(0.25),
                  highlightColor: Palette.sky.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  onPressed: () {},
                  icon: Icon(Icons.info, color: Colors.white, size: 16),
                  label: Text(
                    Lang().of(key: 'moreinfo', isKH: isKH),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProvinceCard({
    String province,
    int views,
    Function onPressed,
    String imagelocation,
    BuildContext context,
  }) {
    double width = MediaQuery.of(context).size.width;
    return Consumer<ScrollNotifier>(builder: (context, notifier, child) {
      return Container(
        margin: EdgeInsets.zero,
        width: (width - 60) / 2,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Palette.text.withOpacity(0.2),
              blurRadius: 0,
              offset: Offset(-0.25, -0.25),
            )
          ],
          color: Colors.white,
        ),
        child: FlatButton(
          padding: EdgeInsets.fromLTRB(5, 8, 5, 0),
          onPressed: onPressed,
          highlightColor: Palette.bg,
          splashColor: Palette.bggrey.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(1),
                child: Image.asset(
                  imagelocation,
                  height: 80,
                  fit: BoxFit.cover,
                  width: (width - 60) / 2,
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                province,
                style: TextStyle(
                  fontSize: 14,
                  color: Palette.sky,
                  fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
                ),
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        height: 1.6,
                        fontSize: 13,
                        color: Palette.bgdark.withOpacity(0.8),
                        fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
                      ),
                      children: [
                        TextSpan(
                          text: "${khNum(views.toString(), isKH)}",
                        ),
                        TextSpan(
                          text: " ",
                          style: TextStyle(fontSize: isKH ? 3 : 10),
                        ),
                        TextSpan(
                          text: Lang().of(key: 'views', isKH: isKH),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Palette.bgdark.withOpacity(1),
                            fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.remove_red_eye,
                    size: 12,
                    color: Palette.text.withOpacity(0.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Container hello(double width, List<String> question) {
    String name = "Sok";
    int index = math.Random().nextInt(question.length).toInt();
    Color color = Colors.white;
    print(index);
    return Container(
      width: width,
      height: 100.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${Lang().of(key: 'hello', isKH: isKH)} $name",
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
            ),
          ),
          Text(
            question[index],
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            titlePadding: EdgeInsets.fromLTRB(15, 15, 15, 0),
            contentPadding: EdgeInsets.only(left: 15),
            actionsPadding: EdgeInsets.only(right: 5),
            title: Text(
              Lang().of(key: 'doyouwantexitapp', isKH: isKH),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
              ),
            ),
            content: Text(
              isKH ? 'សូមចុច "បាទ/ចាស"' : "Please click on 'Yes'",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
              ),
            ),
            backgroundColor: Palette.sky,
            actions: <Widget>[
              FlatButton(
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  isKH ? "ទេ" : "No",
                  style: TextStyle(
                    color: Palette.sky,
                    fontSize: 14,
                    fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
                  ),
                ),
              ),
              FlatButton(
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  isKH ? "បាទ/ចាស" : "Yes",
                  style: TextStyle(
                    color: Palette.sky,
                    fontSize: 14,
                    fontFamily: isKH ? 'Kantumruy' : 'Open Sans',
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
