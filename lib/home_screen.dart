import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_watermark/image_watermark.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  Uint8List? imgBytes;
  Uint8List? imgBytes2;
  XFile? _image;
  Uint8List? watermarkedImgBytes;
  bool isLoading = false;
  String watermarkText = "", imgname = "Фото не выбрано";
  List<bool> textOrImage = [true, false];

  static Future<Uint8List> watermarkWrapper(Map elements) async {
    final result = await ImageWatermark.addTextWatermark(
      imgBytes: elements["imgBytes"],
      color: Colors.orange,
      watermarkText: elements["watermarkText"],
      dstX: elements['dstX'],
      dstY: elements['dstY'],
    );
    return result;
  }

  pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      _image = image;
      var t = await image.readAsBytes();
      imgBytes = Uint8List.fromList(t);
    }
    setState(() {});
  }

  pickImage2() async {
    XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      _image = image;
      imgname = image.name;
      var t = await image.readAsBytes();
      imgBytes2 = Uint8List.fromList(t);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Добавление водяного знака')),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
                child: SizedBox(
                    width: 600,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                              margin: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5))),
                              width: 600,
                              height: 250,
                              child: _image == null
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                          Icon(Icons.add_a_photo),
                                          SizedBox(height: 10),
                                          Text(
                                              'Нажмите чтобы выбрать изображение')
                                        ])
                                  : Image.memory(imgBytes!,
                                      width: 600,
                                      height: 200,
                                      fit: BoxFit.fitHeight)),
                        ),
                        ToggleButtons(
                          fillColor: Colors.blue,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          borderWidth: 3,
                          borderColor: Colors.black26,
                          selectedBorderColor: Colors.black54,
                          selectedColor: Colors.black,
                          onPressed: (index) {
                            textOrImage = [false, false];
                            setState(() {
                              textOrImage[index] = true;
                            });
                          },
                          isSelected: textOrImage,
                          children: const [
                            Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Текст')),
                            Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Изображение'))
                          ],
                        ),
                        const SizedBox(height: 10),
                        textOrImage[0]
                            ? Padding(
                                padding: const EdgeInsets.all(15),
                                child: SizedBox(
                                    width: 600,
                                    child: TextField(
                                        onChanged: (val) {
                                          watermarkText = val;
                                        },
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Водяной знак',
                                          hintText: 'Водяной знак',
                                        ))))
                            : Column(
                                children: [
                                  ElevatedButton(
                                      onPressed: pickImage2,
                                      child: const Text(
                                          'Выберите фото водяного знака')),
                                  Text(imgname)
                                ],
                              ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: () async {
                              Map elements = {
                                "imgBytes": imgBytes,
                                "watermarkText": watermarkText,
                                'dstX': 20,
                                'dstY': 30,
                              };
                              setState(() => isLoading = true);
                              if (textOrImage[0]) {
                                watermarkedImgBytes =
                                    await compute<Map, Uint8List>(
                                        (els) => watermarkWrapper(els),
                                        elements);
                              } else {
                                watermarkedImgBytes =
                                    await ImageWatermark.addImageWatermark(
                                        originalImageBytes: imgBytes!,
                                        waterkmarkImageBytes: imgBytes2!,
                                        imgHeight: 200,
                                        imgWidth: 200,
                                        dstY: 400,
                                        dstX: 400);
                              }
                              setState(() => isLoading = false);
                            },
                            child: const Text('Добавить водяной знак')),
                        const SizedBox(height: 10),
                        isLoading
                            ? const CircularProgressIndicator()
                            : Container(),
                        watermarkedImgBytes == null
                            ? const SizedBox()
                            : Image.memory(watermarkedImgBytes!),
                      ],
                    )))));
  }
}
