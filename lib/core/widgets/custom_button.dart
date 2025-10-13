import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class CustomButton extends StatefulWidget {
  final double widthFactor;
  final double heightFactor;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color borderColor;
  final double borderRadius;

  const CustomButton({
    Key? key,
    this.widthFactor = 0.25,
    this.heightFactor = 0.04,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.borderColor = const Color(0xFFE6E6E6),
    this.borderRadius = 15.0,
  }) : super(key: key);

  @override
  _CustomButton createState() => _CustomButton();
}

class _CustomButton extends State<CustomButton> {
  bool isApproved = false; // Track state

  void toggleStatus() {
    setState(() {
      isApproved = !isApproved;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * widget.widthFactor,
      height: screenHeight * widget.heightFactor,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: isApproved ? Colors.green : Colors.orange, // Toggle color
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor, width: 2),

      ),
      child: InkWell(
        onTap: toggleStatus,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        splashColor: Colors.white24,
        child: Padding(
          padding: widget.padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isApproved ? "Approved" : "Pending",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              SizedBox(width: 8),
              SvgPicture.asset(
                isApproved
                    ? 'assets/icons/check.svg'
                    : 'assets/icons/pending.svg', // Change icon dynamically
                height: MediaQuery.of(context).size.height * 0.02,  // 2% of screen height

                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}