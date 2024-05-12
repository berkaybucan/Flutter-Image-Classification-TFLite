import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:developer' as devtools;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COVID-19 detection using just Chest X-rays',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? filePath;
  String label = '';
  double confidence = 0.0;

  Future<void> _tfLteInit() async {
    // TensorFlow Lite modelini başlatır.
    String? res = await Tflite.loadModel(
        // Modeli yükler ve başlatır.
        model: "assets/covidmodel.tflite", // Model dosyasının yolu.
        labels: "assets/labels.txt", // Etiket dosyasının yolu.
        numThreads: 1, // İş parçacığı sayısı.
        isAsset: true, // Asset kullanıp kullanılmayacağını belirtir
        useGpuDelegate: false // GPU desteğini belirtir.
        );
  }

  pickImageGallery() async {
    //Galeriden Resim Seçme
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery); // Galeriden resim seçer.

    if (image == null) return;

    var imageMap = File(image.path); // Seçilen resmin dosya yolunu alır.

    setState(() {
      filePath = imageMap; // Dosya yolu değişkenini günceller.
    });

    var recognitions = await Tflite.runModelOnImage(
        // TensorFlow Lite modelini resim üzerinde çalıştırır.
        path: image.path, // Resmin dosya yolu.
        imageMean: 0.0, // Resim ortalama değeri.
        imageStd: 255.0, // Resim standart sapması.
        numResults: 2, // Sonuç sayısı
        threshold: 0.2, // Eşik değeri.
        asynch: true // Asenkron çalışma modu
        );

    if (recognitions == null) {
      // Eğer model tahmin yapamadıysa
      devtools.log("recognitions is Null");
      return;
    }
    devtools
        .log(recognitions.toString()); // Tahmin sonuçlarını loglara kaydeder.
    setState(() {
      confidence = (recognitions[0]['confidence'] *
          100); // Doğruluk oranını kullanıcıya göstermek için confidence değişkenine atar.
      label = recognitions[0]['label']
          .toString(); // Etiketi kullanıcıya göstermek için label değişkenine atar.
    });
  }

  pickImageCamera() async {
    // Kameradan resim çeker.
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    var imageMap = File(image.path);

    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        // TensorFlow Lite modelini resim üzerinde çalıştırır.
        path: image.path, // Resmin dosya yolu.
        imageMean: 0.0, // Resim ortalama değeri.
        imageStd: 255.0, // Resim standart sapması.
        numResults: 2, // Sonuç sayısı
        threshold: 0.2, // Eşik değeri.
        asynch: true // Asenkron çalışma modu
        );

    if (recognitions == null) {
      // Eğer model tahmin yapamadıysa
      devtools.log("recognitions is Null");
      return;
    }
    devtools.log(recognitions.toString());
    setState(() {
      confidence = (recognitions[0]['confidence'] * 100);
      label = recognitions[0]['label'].toString();
    });
  }

  @override
  void dispose() {
    // State nesnesi kaldırıldığında çağrılan metot.
    super.dispose(); // Üst sınıfın dispose metotunu çağırır.
    Tflite.close(); // TensorFlow Lite modelini kapatır.
  }

  @override
  void initState() {
    // State nesnesi oluşturulduğunda çağrılan metot.
    // TODO: implement initState
    super.initState(); // Üst sınıfın initState metotunu çağırır.
    _tfLteInit(); // TensorFlow Lite modelini başlatır.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("COVID-19 detection using just Chest X-rays"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),
              Card(
                elevation: 20,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 18,
                        ),
                        Container(
                          height: 280,
                          width: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage('assets/upload.jpg'),
                            ),
                          ),
                          child: filePath == null
                              ? const Text('')
                              : Image.file(
                                  filePath!,
                                  fit: BoxFit.fill,
                                ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                "The Accuracy is ${confidence.toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  pickImageCamera();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Colors.black),
                child: const Text(
                  "Take a Photo",
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  pickImageGallery();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Colors.black),
                child: const Text(
                  "Pick from gallery",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
