
import 'package:flutter/material.dart';
import 'package:my_tour_planner/screens/generate_trip/generateItinerary.dart';
import 'package:my_tour_planner/utilities/text_field/open_street_map_white_search_bar.dart';
import 'package:my_tour_planner/utilities/button/arrow_back_button.dart';
import 'package:my_tour_planner/utilities/button/save_next_button.dart';
import 'package:my_tour_planner/utilities/button/white_date_picker_button.dart';
import 'package:my_tour_planner/utilities/text/text_styles.dart';
import 'package:my_tour_planner/utilities/text_field/white_text_field.dart';
import 'package:intl/intl.dart';
import 'package:my_tour_planner/backend/classes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utilities/image_picker/template_cover_picker.dart';


class GenerateTripDatabase {
  final supabase = Supabase.instance.client;

  Future<void> insertTrip({
    required String userId,
    required String tripName,
    required String? startDate,
    required String? endDate,
    required String? cityLocation,
    required String? tripType,
    required String? budget,
    required String? coverPhotoUrl,
  }) async {
    final response = await supabase.from('Trip').insert({
      'user_id': userId,
      'trip_name': tripName,
      'start_date': startDate,
      'end_date': endDate,
      'city_location': cityLocation,
      'trip_type': tripType,
      'trip_budget': budget,
      'cover_photo_url': coverPhotoUrl,
    }).select(); // This returns the inserted row(s), optional

    if (response.isEmpty) {
      throw Exception('Failed to insert trip');
    }
  }
}


class GenerateTrip extends StatefulWidget {
  GenerateTrip({
    super.key,
  });

  @override
  State<GenerateTrip> createState() => _GenerateTripState();
}

class _GenerateTripState extends State<GenerateTrip> {
  String? selectedValue;
  final types = [
    "Historical",
    "Cultural",
    "Business",
    "Friends",
    "Family",
    "Relaxation",
    "Shopping",
    "Food"
  ];
  String? selectedBudgetValue;
  String? customRange;
  final List<String> budgetRange = [
    "Enter Custom Range",
    "Below ₹1,000",
    "₹1,000 - ₹2,500",
    "₹2,500 - ₹5,000",
    "₹5,000 - ₹10,000",
    "₹10,000 - ₹15,000",
    "₹15,000 - ₹20,000",
    "₹20,000 - ₹30,000",
    "₹30,000 - ₹50,000",
    "₹50,000 - ₹75,000",
    "₹75,000 - ₹1,00,000",
    "₹1,00,000 - ₹1,25,000",
    "₹1,25,000 - ₹1,50,000",
    "Above ₹1,50,000",
  ];

  final String page_title =
      "Generate your trip Itinerary.\nProvide details for your\nIdeal Trip.";

  final trip_db = GenerateTripDatabase();
  final tripID = Trip_ID();

  final TextEditingController trip_name = TextEditingController();

  final TextEditingController location = TextEditingController();

  DateTime? startDate;

  DateTime? endDate;

  String? FormatStartDate;
  String? FormatEndDate;

  String? _imageUrl;

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? startDatePicked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (startDatePicked == null) return; // Exit if no date is picked

    setState(() {
      startDate = startDatePicked;
    });

    if (endDate != null && startDatePicked.isAfter(endDate!)) {
      setState(() {
        endDate = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Start Date can't be after End Date"),
        duration: Duration(milliseconds: 400),
      ));
    }

    if (endDate != null && startDatePicked.isAtSameMomentAs(endDate!)) {
      setState(() {
        startDate = startDatePicked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please select a Start Date first"),
        duration: Duration(milliseconds: 400),
      ));
      return;
    }

    DateTime? endDatePicked = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate!,
      firstDate: startDate!,
      lastDate: startDate!.add(Duration(days: 365)),
    );

    if (endDatePicked == null) return; // Exit if no date is picked

    if (startDate != null && startDate!.isBefore(endDatePicked)) {
      setState(() {
        endDate = endDatePicked;
      });
    } else if (startDate != null &&
        startDate!.isAtSameMomentAs(endDatePicked)) {
      setState(() {
        endDate = endDatePicked;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("End Date must be after Start Date"),
        duration: Duration(milliseconds: 400),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ArrowBackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                page_title,
                style: sub_heading,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30,),
              TemplateCoverPicker(
                  imageUrl: _imageUrl,
                  onUpload: (imageUrl) async {
                    setState(() {
                      _imageUrl = imageUrl;
                    });
                  }),
              SizedBox(
                height: 40,
              ),
              WhiteTextField(
                  labelText: "Enter Trip Name", controller: trip_name),
              SizedBox(
                height: 25,
              ),
              OpenStreetMapWhiteSearchBar(
                  hintText: "Select Location", controller: location),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WhiteDatePicker_button(
                    onPress: () => _selectStartDate(context),
                    buttonLabel: Text(
                      startDate == null
                          ? "Start Date"
                          : "${DateFormat("dd MMM, y").format(startDate ?? DateTime.now())}",
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 16,
                        fontFamily: "Sofia_Sans",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  WhiteDatePicker_button(
                    onPress: () => _selectEndDate(context),
                    buttonLabel: Text(
                      endDate == null
                          ? "End Date"
                          : "${DateFormat("dd MMM, y").format(endDate ?? DateTime.now())}",
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 16,
                        fontFamily: "Sofia_Sans",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Color(0xFFD8DDE3),
                    width: 1.2,
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedBudgetValue == "Enter Custom Range"
                      ? null
                      : selectedBudgetValue,
                  hint: Text(customRange ?? "Select Budget Range"),
                  isExpanded: true,
                  underline: SizedBox(),
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 16,
                    fontFamily: "Sofia_Sans",
                    fontWeight: FontWeight.w400,
                  ),
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF666666)),
                  dropdownColor: Colors.grey[200],
                  onChanged: (newValue) {
                    if (newValue == "Enter Custom Range") {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final minController = TextEditingController();
                          final maxController = TextEditingController();

                          return AlertDialog(
                            title: Text("Enter Custom Budget Range"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: minController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: "Min Budget"),
                                ),
                                TextField(
                                  controller: maxController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: "Max Budget"),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final min = minController.text;
                                  final max = maxController.text;

                                  if (min.isNotEmpty && max.isNotEmpty) {
                                    setState(() {
                                      customRange = "₹$min - ₹$max";
                                      selectedBudgetValue =
                                      "Enter Custom Range"; // Not in the list, so Dropdown won't try to match
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                                child: Text("Apply"),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      setState(() {
                        selectedBudgetValue = newValue;
                        customRange =
                        null; // clear custom text if predefined selected
                      });
                    }
                  },
                  items: budgetRange.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(type),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Color(0xFFD8DDE3),
                    width: 1.2,
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedValue,
                  hint: Text("Select Trip Type"),
                  isExpanded: true,
                  underline: SizedBox(),
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 16,
                    fontFamily: "Sofia_Sans",
                    fontWeight: FontWeight.w400,
                  ),
                  // Text styling
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF666666)),
                  // Custom icon
                  dropdownColor: Colors.grey[200],
                  // Background color of dropdown
                  onChanged: (newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  },
                  items: types.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(type),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              SaveNextButton(
                  onPress: () async {
                    final supabase = Supabase.instance.client;
                    final user = supabase.auth.currentUser;
                    String? userId = user?.id;

                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("User not logged in!"),
                        duration: Duration(milliseconds: 400),
                      ));
                      return;
                    }

                    int? tripId = await tripID.getTripId();

                    if (startDate != null &&
                        endDate != null &&
                        location.text.isNotEmpty &&
                        trip_name.text.isNotEmpty) {
                      FormatStartDate = startDate != null
                          ? DateFormat('dd-MM-yyyy').format(startDate!)
                          : null;
                      FormatEndDate = endDate != null
                          ? DateFormat('dd-MM-yyyy').format(endDate!)
                          : null;

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateTripFlow(
                                    startDate: startDate.toString(),
                                    endDate: endDate.toString(),
                                    location: location.text,
                                    tripType: selectedValue!,
                                    tripId: tripId!,
                                    budget: selectedBudgetValue!,
                                  )));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Please fill all the fields"),
                        duration: Duration(milliseconds: 400),
                      ));
                    }

                    await trip_db.insertTrip(
                      userId: userId,
                      tripName: trip_name.text,
                      startDate: FormatStartDate,
                      endDate: FormatEndDate,
                      cityLocation: location.text,
                      tripType: selectedValue,
                      budget: selectedBudgetValue == "Enter Custom Range" ? customRange : selectedBudgetValue,
                      coverPhotoUrl: _imageUrl,
                    );
                  },
                  buttonLabel: Text(
                    "Next",
                    style: save_next_button,
                  )),
              SizedBox(
                height: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
