import 'package:flutter/material.dart';

class ViewPostScreen extends StatelessWidget {
  final String? notificationBody;

  const ViewPostScreen({super.key, this.notificationBody});

  @override
  Widget build(BuildContext context) {
    if (notificationBody == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('View Post'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No notification data received.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF1D1E33),
      );
    }

    final first = notificationBody!.split('/n'); // Split the string by "/n"
  
    List<String> lines = []; // Declare the list properly

    for (String i in first) {
      lines.addAll(i.split(" | ")); // Use addAll to add multiple items
    }

    String? description;
    String? location;
    String? injuredPersons;
    String? createdBy;
    String? dateTime;
    String? imageUrl;

    // Extract data from the body
    for (String line in lines) {
      if (line.startsWith('Description:')) {
        description = line.replaceFirst('Description: ', '');
      } else if (line.startsWith('Injured Persons:')) {
        injuredPersons = line.replaceFirst('Injured Persons: ', '');
      } else if (line.startsWith('Location:')) {
        location = line.replaceFirst('Location: ', '');
      } else if (line.startsWith('Created By:')) {
        createdBy = line.replaceFirst('Created By: ', '');
      } else if (line.startsWith('Date and Time:')) {
        dateTime = line.replaceFirst('Date and Time: ', '');
      } else if (line.startsWith('Image Url:')) {
        imageUrl = line.replaceFirst('Image Url: ', '');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Post'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display image from URL
              if (imageUrl != null && imageUrl.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      imageUrl!,
                      height: 250.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          'Image failed to load',
                          style: TextStyle(color: Colors.red),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 20.0),

              // Display the parsed details
              _buildDetailRow('Description:', description),
              _buildDetailRow('Location:', location),
              _buildDetailRow('Injured Persons:', injuredPersons),
              _buildDetailRow('Created By:', createdBy),
              _buildDetailRow('Date and Time:', dateTime),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFF1D1E33),
    );
  }

  // Helper method to build styled detail rows
  Widget _buildDetailRow(String title, String? detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            TextSpan(
              text: detail,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
