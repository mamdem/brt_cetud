import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DamageItem extends StatefulWidget {
  final Function(DamageItem) onRemove;

  DamageItem({required this.onRemove});

  @override
  _DamageItemState createState() => _DamageItemState();
}

class _DamageItemState extends State<DamageItem> {
  final TextEditingController _labelController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dégât matériel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () => widget.onRemove(widget),
              ),
            ],
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _labelController,
            decoration: InputDecoration(
              labelText: 'Libellé du dégât',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          SizedBox(height: 15),
          InkWell(
            onTap: _pickImage,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _imageFile == null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.grey),
                    SizedBox(height: 5),
                    Text('Ajouter une photo'),
                  ],
                ),
              )
                  : Stack(
                children: [
                  Image.file(
                    _imageFile!,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: InkWell(
                      onTap: () => setState(() => _imageFile = null),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }
}