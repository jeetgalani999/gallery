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
  List<AssetEntity> _selectedImages = [];

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
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _deleteSelectedImages();
            },
          ),
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () {
              _selectAllImages();
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final asset = _images[index];
          final isSelected = _selectedImages.contains(asset);
          return GestureDetector(
            onTap: () {
              _toggleSelectImage(asset);
            },
            child: Stack(
              children: [
                Image(
                  image: AssetEntityImageProvider(asset),
                  fit: BoxFit.fill,
                ),
                if (isSelected)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleSelectImage(AssetEntity asset) {
    setState(() {
      if (_selectedImages.contains(asset)) {
        _selectedImages.remove(asset);
      } else {
        _selectedImages.add(asset);
      }
    });
  }

  void _selectAllImages() {
    setState(() {
      if (_selectedImages.length < _images.length) {
        _selectedImages.addAll(_images);
      } else {
        _selectedImages.clear();
      }
    });
  }

  Future<void> _deleteSelectedImages() async {
    if (_selectedImages.isNotEmpty) {
      // Get the editor instance.
      final editor = PhotoManager.editor;

      // Delete the selected assets.
      final idsToDelete = _selectedImages.map((asset) => asset.id).toList();
      final result = await editor.deleteWithIds(idsToDelete);

      // Remove deleted assets from the list.
      _images.removeWhere((asset) => _selectedImages.contains(asset));
      _selectedImages.clear();

      setState(() {});
    }
  }
}
