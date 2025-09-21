import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_helper.dart';

Future<void> createCountry({
  required BuildContext context,
  required http.MultipartFile? coverImage,
  required String userID,
  required String countryTitle,
  required String countryDescription,
  required String countryCapital,
  required String countryCurrency,
  required String countryPopulation,
  required String countryDemonym,
  required String countryLanguage,
  required String countryTimeZone,
  required String countryPresident,
  required String countryCuisinesLink,
  required String countryCulturalDanceLink,
  required String countryArtsCraftsLink,
}) async {
  var headers = await getHeaders();
  // Create multipart request
  var request =
  http.MultipartRequest('POST', Uri.parse('$baseUrl/country/countries'))
    ..headers.addAll(headers)
    ..fields['created_by_id'] = userID
    ..fields['title'] = countryTitle
    ..fields['description'] = countryDescription
    ..fields['capital'] = countryCapital
    ..fields['currency'] = countryCurrency
    ..fields['population'] = countryPopulation
    ..fields['demonym'] = countryDemonym
    ..fields['language'] = countryLanguage
    ..fields['time_zone'] = countryTimeZone
    ..fields['president'] = countryPresident
    ..fields['link'] = countryCuisinesLink
    ..fields['arts_and_crafts'] = countryArtsCraftsLink
    ..fields['cultural_dance'] = countryCulturalDanceLink
    ..fields['latitude'] = "" //not needed anymore but keep
    ..fields['longitude'] = ""; //not needed anymore but keep


  // Add image file if provided
  if (coverImage != null) {
    request.files.add(coverImage);
  }
  // Send the request
  final response = await request.send();

  // Handle the response
  if (response.statusCode == 200 || response.statusCode == 201) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Country created successfully!',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ));
    }
  } else {
    final responseData = await http.Response.fromStream(response);
    final String errorMessage =
        json.decode(responseData.body)['message'] ?? 'Country creation failed';

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          errorMessage,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
    }
    throw Exception(errorMessage);
  }
}

Future<void> createBusiness({
  required BuildContext context,
  required String businessTitle,
  required String businessDescription,
  required String businessLocation,
  required String businessCategory,
  required String facebook,
  required String twitter,
  required String instagram,
  required String linkedIn,
  required String whatsapp,
  required String webAddress,
  required String email,
  required List<http.MultipartFile>? mediaFiles,
}) async {
  var headers = await getHeaders();

  // Create multipart request
  var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/business'))
    ..headers.addAll(headers)
    ..fields['businessTitle'] = businessTitle
    ..fields['businessDescription'] = businessDescription
    ..fields['businessLocation'] = businessLocation
    ..fields['businessAddress'] = email //this is correct
    ..fields['businessCategory'] = businessCategory
    ..fields['facebook'] = facebook
    ..fields['twitter'] = twitter
    ..fields['instagram'] = instagram
    ..fields['linkedIn'] = linkedIn
    ..fields['whatsapp'] = whatsapp
    ..fields['webAddress'] = webAddress;

  // Add Gallery Images
  if (mediaFiles != null && mediaFiles.isNotEmpty) {
    for (var file in mediaFiles) {
      request.files.add(file);
    }  }
  // Send the request
  final response = await request.send();

  // Handle the response
  if (response.statusCode == 200 || response.statusCode == 201) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Business created successfully!',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ));
    }
  } else {
    final responseData = await http.Response.fromStream(response);
    final String errorMessage =
        json.decode(responseData.body)['message'] ?? 'Business creation failed';

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          errorMessage,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
    }
    throw Exception(errorMessage);
  }
}