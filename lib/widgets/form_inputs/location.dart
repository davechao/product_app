import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:product_app/widgets/helpers/ensure_visible.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  Uri _staticMapUri;
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void getStaticMap(String address) async {
//    if (address.isEmpty) return;
//    final Uri uri = Uri.https(
//      'maps.googleapis.com',
//      '/maps/api/geocode/json',
//      {'address': address, 'key': 'AIzaSyAC5pmc85_60IolYZ'},
//    );
//    final http.Response response = await http.get(uri);
//    final decodedResponse = json.decode(response.body);
//
//    final StaticMapProvider staticMapProvider =
//        StaticMapProvider('AIzaSyAC5pmc85_60IolYZ-czqGx-rD4CkEdUbg');
//    final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers(
//        [Marker('position', 'Position', 25.0330155, 121.5638707)],
//        center: Location(25.0330155, 121.5638707),
//        width: 500,
//        height: 300,
//        maptype: StaticMapViewType.roadmap);
//    setState(() {
//      _staticMapUri = staticMapUri;
//    });
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      getStaticMap(_addressInputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            focusNode: _addressInputFocusNode,
            controller: _addressInputController,
            decoration: InputDecoration(labelText: 'Address'),
          ),
        ),
        SizedBox(height: 10.0),
        Image.network(_staticMapUri.toString()),
      ],
    );
  }
}
