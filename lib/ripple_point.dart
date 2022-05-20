import 'package:flutter/material.dart';
import 'package:osm_offline_download/ripple_animation.dart';

class RipplePoint extends StatelessWidget {
  final bool? repeat;
  final Duration? duration;
  const RipplePoint({Key? key, this.repeat = false, this.duration})
      : super(key: key);
  @override
  Widget build(Object context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        RippleAnimation2(
          repeat: repeat!,
          color: Colors.blue,
          minRadius: 15,
          ripplesCount: 13,
          duration: duration ?? const Duration(milliseconds: 1500),
          child: const SizedBox(),
        ),
        const PinPoint(),
      ],
    );
  }
}

class PinPoint extends StatelessWidget {
  final Color? color;

  const PinPoint({Key? key, this.color}) : super(key: key);
  @override
  Widget build(Object context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.black,
      ),
      child: Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: color ?? Colors.blue,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
