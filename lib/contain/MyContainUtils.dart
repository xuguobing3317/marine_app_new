import 'package:flutter/material.dart';
import 'package:marine_app/common/AppConst.dart';

class MyContainUtils extends StatelessWidget {
  MyContainUtils(this.imageUrl);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return ClipPath(
      clipper: ArcClipper(),
      child: Container(
        padding: new EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
        alignment: Alignment.center,
        child: new Container(
          alignment: Alignment.center,
          width: 99.0,
          height: 99.0,
          child: Image.asset('images/cycle3.png',
        width: 99.0,
        height: 99.0,
        ),
        ),

        width: screenWidth,
        height: 250.0,
        decoration: new BoxDecoration(
          color: AppConst.appColor,
          gradient: new LinearGradient(
            begin: const FractionalOffset(0.5, 0.0),
            end: const FractionalOffset(0.5, 1.0),
            colors: <Color>[Colors.white,AppConst.appColor],
          ),
        ),
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 40);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
