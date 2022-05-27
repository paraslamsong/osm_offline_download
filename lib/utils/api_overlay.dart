import 'package:flutter/material.dart';
import 'package:osm_offline_download/providers/api_validity_provider.dart';
import 'package:provider/provider.dart';

class APIValidityOverlay extends StatelessWidget {
  const APIValidityOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MapValidity>(
      builder: (context, validity, child) {
        return Visibility(
          visible: !validity.isApiKeyValid,
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.identity()..rotateZ(-45 * 3.1415927 / 180),
                child: const Text(
                  "You need\nAPI key to use Map\nContact Yeti Tech",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
