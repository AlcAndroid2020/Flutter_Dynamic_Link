import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    title: 'Dynamic Links Example',
    routes: <String, WidgetBuilder>{
      '/': (BuildContext context) => _MainScreen(),
      '/deals': (BuildContext context) => GameScreen("deals"),
      '/Product': (BuildContext context) => GameScreen("Product"),
    },
  ));
}

class _MainScreen extends StatefulWidget {

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {

  String _linkMessage;
  bool _isCreatingLink = false;
  String _testString =
      "To test: long press link and then copy and click from a non-browser "
      "app. Make sure this isn't being tested on iOS simulator and iOS xcode "
      "is properly setup. Look at firebase_dynamic_links/README.md for more "
      "details.";
  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }



  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });




    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: "https://abcedf.page.link",
        //main url

        //main link (must be real url)
        link: Uri.parse("http://www.example.com/Product"),
        androidParameters: AndroidParameters(
            packageName: "com.example.flutterdynamiclink", minimumVersion: 0),
        iosParameters: IosParameters(
            bundleId: "com.example.flutterdynamiclink;", minimumVersion: '0'),
        dynamicLinkParametersOptions: DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: '1L Food Container',
          description: 'Affordable container',
          imageUrl: Uri.parse(
              "https://www.ikea.com/my/en/images/products/ikea-365--food-container-with-lid__0594331_PE675656_S5.JPG"),
        )


    );
    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
      print(url);
    } else {
      url = await parameters.buildUrl();
      print(url);

    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }


  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;

          if (deepLink != null) {
            Navigator.pushNamed(context, deepLink.path);
            print("Deep link1= ${deepLink.path}");

          }
        }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
      print("Deep link2= ${deepLink.path}");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dyanmic Link"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: !_isCreatingLink
                      ? () => _createDynamicLink(false)
                      : null,
                  child: const Text('Get Long Link'),
                ),
                RaisedButton(
                  onPressed: !_isCreatingLink
                      ? () => _createDynamicLink(true)
                      : null,
                  child: const Text('Get Short Link'),
                ),
              ],
            ),
            InkWell(
              child: Text(
                _linkMessage ?? '',
                style: const TextStyle(color: Colors.blue),
              ),
              onTap: () async {
                if (_linkMessage != null) {
              //    await launch(_linkMessage);
                }
              },
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: _linkMessage));
                Scaffold.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied Link!')),
                );
              },
            ),
            Text(_linkMessage == null ? '' : _testString)
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class GameScreen extends StatefulWidget {
  String title;
  GameScreen(this.title);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(widget.title),
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
