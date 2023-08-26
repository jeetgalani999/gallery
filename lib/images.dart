import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImagePreview extends StatefulWidget {
  String name;
  AssetPathEntity _images;

  ImagePreview(this._images, this.name);

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  List<AssetEntity> _images = [];

  _loadImagesFromAlbum(AssetPathEntity album) async {
    final images = await album.getAssetListPaged(page: 0, size: 30);
    setState(() {
      _images = images;
    });
  }

  @override
  void initState() {
    _loadImagesFromAlbum(widget._images);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {},
            child: Image(
              image: AssetEntityImageProvider(_images[index]),
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

}