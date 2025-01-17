import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationService {
  // Function to obtain the access token
  static Future<String> getAccessToken() async {
    if (kDebugMode) {
      print('Getting Access Token...');
    }

    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "acciaid-5925c",
      "private_key_id": "adeccd7fca89f7dfd149f38a487c56ec831d2c2a",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDFsUBezYV8YvPE\nlpsNT9hYVbWoEpaMjDPTj4HOFGoccsnkg+jTEdOrVXyLzudam/UR8IwEOq1GqxTL\nIrtCZL51ejpyCKyml0md8IYnJV2lHE8235x6DT+Tujhc/yCM+VoK9pATbX1HtYlu\nhEMWfZ5+GDLAjx4WpwCxGacIpiO11a+hS76rQqbKkAaCqrDQbk3wMX3CR/wMjkZa\nm0uf9Tv8aty7YPlKs8dWcDbmZaQDbEzoZvXXwxCw54j+2+aEUTNt0YyLMYdpUEDM\ndlIvNhsrH4a3IvY281mAssVUH0v2aF/lm2bQru+UzG3Qt9H23p+Vrx5dALy8RJAL\ntt4GimqbAgMBAAECggEANe3Sl4oNPg9oXFqRVaJQbFiFQ6I+e3zLrozZZjRfdf9C\nYBoz61BTo8ugPCtnJWqiAhDSwVyYZEzLUVbaKpR8+GMtimofXxqqNHGmxwsEbsQ4\nP8nkT89JZq1ILuZSJOLo01DLoOEfae513TYrbvk5wUAsqCbimF9aavWKgWuBFlsH\nErL/GVFBC/qMNgQqMP/OnFMFx86tSKlqsSdLrqoMxIBCUdXB8Rqv9kEYQ0Mk4tJB\n56wdDbwuvxqXztQd7M99Q2JnHSypCxsHyw8AtsjRYA4TM2mW7M3w1MCU2ALe0n30\ne4uCpN0IbU7WirU2hJYEBIG3uqQ0VmEY1SB+5z2jEQKBgQD8Hy142mVVmYafVHsa\nfkayYkMXr9jsJDBtS08xgFHY1+IXs2b5fBsdQ/R1pYqgPtp8fBx1r5HeCSX07j6d\nvv4oQep8HiiXNGADkrIt7SfvAd4BmyBX0CALWxlRLJwNypqnmLsv0KOhNp7QdNVE\nP0Ym6Oj0bl+z8o8HaG7wxDCN7wKBgQDIu7zu5LS7Kkipsx7jUDUSxlq8omwCxaWK\nGFjkOfX9LnxbfytKFURsUGKEVYMtm/juYUPRQ3eOTxJwyl13fuHG8SQdSmoFFm/0\nSDBIt8uOlFCQ28qReuN9w0qsw6d1bItSYgLdYoIUkgZEeKuUIpTiB1U9FhC17aFE\n2N+RRqOaFQKBgQDJKQ8c+BQWQlKZWcyHDO3XcnNZuOJ5Nz60VXwwYNPtEgLBKlEl\nChKQPSIVpCmBReUJofULKTRXVjFExbqMHlGnSUCQG3gDfLSG5UrpPem412KNIXqi\n1dpbdSo0DEXO8zKGOmRP+EY2YOBCLpXiyCFu9jK4pEAT0ZqxLHAoBkE/XQKBgQDD\n8vg438tJVbp+5drGHVrhy/1xXMBBaHzzNFc52xa1IvbEPnycoewcK9AvzGX0VOiI\nkywnkEuaALhIoFLjPlnZ4TXW3fhmpQN+nCV+JuSvdzq6XcP9hc+iycwQoCHNL7tF\nHWYchHfk6rLxjjY3shZSGsRrkCmZ3rFpyqdbYnB8DQKBgQDBoq+Q/MDhuYnD+5bp\nfLeFjK0od/mTYwDsGqxlmrdf74vL37WwatY1JYyikdRicLbdyP5byw0CSybYA+H8\nQWqZ2TQLo9osN+dOVu6DWm3f13wl8c6qyIdS6b233mxQa9mdh759EBc9wCvhsbIX\nQaEEQiGESjWM1XqnY5NzO4l40Q==\n-----END PRIVATE KEY-----\n",
      "client_email": "acci-surge@acciaid-5925c.iam.gserviceaccount.com",
      "client_id": "101580765236591293368",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/acci-surge%40acciaid-5925c.iam.gserviceaccount.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();

    if (kDebugMode) {
      print('Access Token obtained: ${credentials.accessToken.data}');
    }
    return credentials.accessToken.data;
  }

  // Function to send notification to all users
  static Future<void> sendNotificationToAllUsers(
      String title, String body) async {
    try {
      if (kDebugMode) {
        print('Sending Notification...');
      }
      final String serverAccessTokenKey = await getAccessToken();
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Retrieve device tokens from the users collection
      final QuerySnapshot usersSnapshot =
          await firestore.collection('users').get();

      final List<String> deviceTokens = usersSnapshot.docs
          .map((doc) => doc['deviceToken'] as String)
          .where((token) => token.isNotEmpty)
          .toList();

      if (deviceTokens.isEmpty) {
        if (kDebugMode) {
          print('No device tokens found');
        }
        return;
      }

      const String endpointFirebaseCloudMessaging =
          'https://fcm.googleapis.com/v1/projects/acciaid-5925c/messages:send';

      // Loop through all device tokens and send notifications
      for (String token in deviceTokens) {
        final Map<String, dynamic> message = {
          'message': {
            'token': token,
            'notification': {'title': title, 'body': body}
          }
        };

        final http.Response response = await http.post(
          Uri.parse(endpointFirebaseCloudMessaging),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $serverAccessTokenKey',
          },
          body: jsonEncode(message),
        );

        if (response.statusCode == 200) {
          if (kDebugMode) {
            print('FCM message sent successfully to $token');
          }
        } else {
          if (kDebugMode) {
            print(
                'Failed to send FCM message to $token: ${response.statusCode} ${response.body}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending notification: $e');
      }
    }
  }
}
