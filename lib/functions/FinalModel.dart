import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

const String apiKey = "YeHix9qLq3FoZZKPj4zy";
const String projectId = "all-about-lettuce";
const String modelVersion = "8";

Future<void> pickAndUploadImage() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final bytes = File(image.path).readAsBytesSync();

    // 2. Decode the image (using the image package)
    img.Image? imgImage = img.decodeImage(Uint8List.fromList(bytes));

    if (imgImage == null) return; // Make sure image decoding is successful

    // 3. Resize the image to 224x224
    imgImage = img.copyResize(imgImage, width: 224, height: 224);

    // 4. Convert the resized image back to bytes (JPEG format)
    final resizedBytes = Uint8List.fromList(img.encodeJpg(imgImage));

    // 5. Convert the resized bytes to Base64
    final String base64Image = base64Encode(resizedBytes);

    // 6. Build the request
    final Uri url = Uri.parse(
        "https://detect.roboflow.com/all-about-lettuce/8?api_key=YeHix9qLq3FoZZKPj4zy");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body:
          "image=${Uri.encodeComponent(base64Image)}", // Send the Base64 string
    );

    if (response.statusCode == 200) {
      print("Success: ${response.body}");
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Exception: $e");
  }
}
