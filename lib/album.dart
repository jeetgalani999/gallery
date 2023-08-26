import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'images.dart';


class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<AssetEntity> _images = [];
  List<AssetPathEntity> _albums = [];
  List<AssetEntity> _firstImages = [];

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  _loadImagesFromAlbum(AssetPathEntity album) async {
    final images = await album.getAssetListPaged(page: 0, size: 20);
    setState(() {
      _images = images;
    });
  }

  Future<AssetEntity?> _getFirstImageFromAlbum(AssetPathEntity album) async {
    final images = await album.getAssetListPaged(
        page: 0, size: 1); // Fetch only the first image.
    return images.isNotEmpty ? images.first : null;
  }

  _loadAlbums() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      final assetPaths = await PhotoManager.getAssetPathList();
      setState(() {
        _albums = assetPaths;

        // Fetch and store the first image of each album.
        _albums.forEach((album) async {
          final firstImage = await _getFirstImageFromAlbum(album);
          if (firstImage != null) {
            _firstImages.add(firstImage);
          }
        });
      });
    } else {
      // Handle permission denied.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Album')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: _albums.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePreview(_albums[index],_albums[index].name),
                        ));
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                            AssetEntityImageProvider(_firstImages[index]),
                            fit: BoxFit.fill)),
                  )),
              SizedBox(
                  width: 150,
                  child: Text(_albums[index].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black)))
            ],
          );
        },
      ),
    );
  }
}
