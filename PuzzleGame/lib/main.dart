import 'dart:async';
import 'dart:io';

import 'package:PuzzleGame/puzzle_piece.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Img;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Puzzle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Puzzle'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final int rows = 5;
  final int cols = 4;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  ImagePicker picker = ImagePicker();
  List<Widget> pieces = [];

  @override
  void initState() {
    super.initState();

    _image = null;
    picker = ImagePicker();
  }

  Future getImage(ImageSource imageSource) async {
    PickedFile pickedFile =
        await picker.getImage(source: imageSource, maxWidth: 800);
    setState(() {
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          pieces.clear();
        });

        final image = ResizeImage(FileImage(_image), width: 200);
        splitImage(Image(
          image: image,
        ));
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Center(
            child: _image == null
                ? Text('No image selected.')
                : Stack(children: pieces) //Image.file(_image),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.camera),
                        title: Text('Camera'),
                        onTap: () {
                          Navigator.pop(context);
                          getImage(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.image),
                        title: Text('Gallery'),
                        onTap: () {
                          Navigator.pop(context);
                          getImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                );
              })
        },
        tooltip: 'New Image',
        child: Icon(Icons.add),
      ),
    );
  }

// we need to find out the image size, to be used in the PuzzlePiece widget
  Future<Size> getImageSize(Image image) async {
    final Completer<Size> completer = Completer<Size>();

    image.image
        .resolve(const ImageConfiguration())
        .addListener(new ImageStreamListener(
      (ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      },
    ));

    final Size imageSize = await completer.future;

    return imageSize;
  }

  // here we will split the image into small pieces using the rows and columns defined above; each piece will be added to a stack
  void splitImage(Image image) async {
    Size imageSize = await getImageSize(image);
    print('-=-=splitImage  ');
    print(imageSize);
    for (int x = 0; x < widget.rows; x++) {
      for (int y = 0; y < widget.cols; y++) {
        setState(() {
          pieces.add(PuzzlePiece(
              key: GlobalKey(),
              image: image,
              imageSize: imageSize,
              row: x,
              col: y,
              maxRow: widget.rows,
              maxCol: widget.cols,
              bringToTop: this.bringToTop,
              sendToBack: this.sendToBack));
        });
      }
    }
  }

  // when the pan of a piece starts, we need to bring it to the front of the stack
  void bringToTop(Widget widget) {
    setState(() {
      pieces.remove(widget);
      pieces.add(widget);
    });
  }

// when a piece reaches its final position, it will be sent to the back of the stack to not get in the way of other, still movable, pieces
  void sendToBack(Widget widget) {
    setState(() {
      pieces.remove(widget);
      pieces.insert(0, widget);
    });
  }
}
