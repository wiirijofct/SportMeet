import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MaterialApp(
    home: ProfileSportMeet(),
    debugShowCheckedModeBanner: false, // Remove a banner de debug
    theme: ThemeData(
      primarySwatch: Colors.blue, // Alterado para azul suave
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
          .copyWith(secondary: Colors.blueAccent),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all<Color>(Colors.black),
        trackColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
        thickness: MaterialStateProperty.all<double>(6.0),
        radius: Radius.circular(8),
      ),
    ),
  ));
}

class ProfileSportMeet extends StatefulWidget {
  @override
  _ProfileSportMeetState createState() => _ProfileSportMeetState();
}

class _ProfileSportMeetState extends State<ProfileSportMeet> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();
  String _selectedTime = "00:00";

  // Lista de esportes para o autocomplete
  final List<String> sportsOptions = [
    'football',
    'pool',
    'padel',
    'tennis',
    'basketball',
  ];

  // Estrutura para armazenar horários de abertura e fechamento por dia
  Map<String, Map<String, String>> schedule = {
    'Monday': {'Opens': '', 'Closes': ''},
    'Tuesday': {'Opens': '', 'Closes': ''},
    'Wednesday': {'Opens': '', 'Closes': ''},
    'Thursday': {'Opens': '', 'Closes': ''},
    'Friday': {'Opens': '', 'Closes': ''},
    'Saturday': {'Opens': '', 'Closes': ''},
    'Sunday': {'Opens': '', 'Closes': ''},
  };

  // Widget para rótulos de entrada
  Widget buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800, // Cor do texto alterada para cinza escuro
        ),
      ),
    );
  }

  // Widget para campos de texto
  Widget buildTextField(String hint,
      {bool isNumber = false, bool isMultiline = false}) {
    return TextFormField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: isMultiline ? 4 : 1,
      style: TextStyle(
        color: Colors.grey.shade800, // Cor do texto alterada para cinza escuro
        fontSize: 16,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade200, // Fundo suave cinza claro
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
      ),
    );
  }

  // Abre o pop-up de seleção de horas para Schedule
  void openScheduleHourPopup(BuildContext context, String day, String type,
      StateSetter parentSetState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select $type for $day",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        Colors.grey.shade800, // Cor do texto alterada para cinza escuro
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 250,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 24,
                    itemBuilder: (BuildContext context, int index) {
                      String time = "${index.toString().padLeft(2, '0')}:00";
                      return ListTile(
                        title: Text(
                          time,
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                        onTap: () {
                          setState(() {
                            schedule[day]![type] = time;
                          });
                          Navigator.of(context).pop();
                          // Atualiza o diálogo principal
                          parentSetState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("$type for $day set to $time"),
                              backgroundColor: Colors
                                  .blue.shade600, // Cor do SnackBar alterada para azul
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Abre o pop-up de dias para o Schedule
  void openScheduleDayPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Usando StatefulBuilder para gerenciar o estado dentro do diálogo
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Schedule",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey
                            .shade800, // Cor alterada para cinza escuro
                      ),
                    ),
                    SizedBox(height: 20),
                    Table(
                      columnWidths: {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(2),
                      },
                      border: TableBorder.all(
                        color: Colors.black, // Cor da borda alterada para preto
                        style: BorderStyle.solid,
                        width: 1,
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey
                                .shade300, // Fundo suave cinza
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  "Day",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black, // Texto em preto
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  "Opens",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  "Closes",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ...schedule.keys.map((day) {
                          // Determina a cor do texto com base no dia
                          Color dayColor = (day == 'Saturday' ||
                                  day == 'Sunday')
                              ? Colors.blue.shade800
                              : Colors.black;

                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    color: dayColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  openScheduleHourPopup(
                                      context, day, 'Opens', setState);
                                },
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                            Colors.black), // Bordas pretas
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: Colors.grey
                                        .shade200, // Fundo suave cinza claro
                                  ),
                                  child: Center(
                                    child: Text(
                                      schedule[day]!['Opens']!.isEmpty
                                          ? "Not set" // Exibe "Not set" se vazio
                                          : schedule[day]!['Opens']!,
                                      style: TextStyle(
                                        color: schedule[day]!['Opens']!
                                                .isEmpty
                                            ? Colors.grey
                                            : Colors
                                                .black, // Texto preto se setado
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  openScheduleHourPopup(
                                      context, day, 'Closes', setState);
                                },
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                            Colors.black), // Bordas pretas
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: Colors.grey
                                        .shade200, // Fundo suave cinza claro
                                  ),
                                  child: Center(
                                    child: Text(
                                      schedule[day]!['Closes']!.isEmpty
                                          ? "Not set"
                                          : schedule[day]!['Closes']!,
                                      style: TextStyle(
                                        color: schedule[day]!['Closes']!
                                                .isEmpty
                                            ? Colors.grey
                                            : Colors
                                                .black, // Texto preto se setado
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue
                            .shade600, // Cor do botão alterada para azul
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        "Close",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Abre o pop-up de Unavailability
  void openUnavailabilityPopup(BuildContext context) {
    List<DateTime> selectedDates = [];
    Map<DateTime, String> unavailabilityReasons = {};
    DateTime focusedMonth =
        DateTime.now(); // Track the currently focused month

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Usando StatefulBuilder para gerenciar o estado dentro do diálogo
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Unavailability",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey
                            .shade800, // Cor do texto alterada para cinza escuro
                      ),
                    ),
                    SizedBox(height: 20),
                    TableCalendar(
                      focusedDay:
                          focusedMonth, // Mantém o mês focado
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      calendarFormat: CalendarFormat.month,
                      selectedDayPredicate: (day) {
                        return selectedDates.contains(day);
                      },
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontSize: 14, // Fonte aumentada
                          color: Colors.grey
                              .shade800, // Dias úteis em cinza escuro
                        ),
                        weekendStyle: TextStyle(
                          fontSize: 14, // Fonte aumentada
                          color: Colors.blue.shade800, // Fins de semana em azul
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible:
                            false, // Remove o botão "2 Weeks"
                        titleCentered: true, // Centraliza o título
                        titleTextStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        leftChevronIcon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.grey.shade800,
                        ),
                        rightChevronIcon: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          if (selectedDates.contains(selectedDay)) {
                            selectedDates.remove(selectedDay);
                          } else {
                            selectedDates.add(selectedDay);
                          }
                        });
                      },
                      onPageChanged: (focusedDay) {
                        // Atualiza o mês focado ao mudar manualmente
                        setState(() {
                          focusedMonth = focusedDay;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Reason:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey
                            .shade800, // Cor do texto alterada para cinza escuro
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _reasonController,
                      maxLines: 3,
                      style: TextStyle(
                        color: Colors.grey
                            .shade800, // Cor do texto alterada para cinza escuro
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Colors.grey.shade200, // Fundo suave cinza claro
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Enter a reason for unavailability",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Salva a razão para cada data selecionada
                          for (var date in selectedDates) {
                            unavailabilityReasons[date] =
                                _reasonController.text;
                          }
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Unavailability set for: ${selectedDates.map((date) => "${date.day}/${date.month}/${date.year}").join(', ')}",
                              ),
                              backgroundColor: Colors.blue
                                  .shade600, // Cor do SnackBar alterada para azul
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue
                              .shade600, // Cor do botão alterada para azul
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                        ),
                        child: Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register Property",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade600, // Cor da AppBar alterada para azul
        centerTitle: true,
        elevation: 4,
      ),
      body: Scrollbar(
        thickness: 6,
        radius: Radius.circular(8),
        thumbVisibility: true, // Sempre visível
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Área de Imagens
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Upload Images",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey
                              .shade800, // Cor do texto alterada para cinza escuro
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                // Implementar funcionalidade de upload de imagem
                              },
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey
                                      .shade200, // Fundo suave cinza claro
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade600),
                                ),
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey
                                      .shade800, // Cor do ícone alterada para cinza escuro
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    // Implementar funcionalidade de upload de imagem
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey
                                          .shade200, // Fundo suave cinza claro
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade600),
                                    ),
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey
                                          .shade800, // Cor do ícone alterada para cinza escuro
                                      size: 30,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Campo Nome do Campo
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      buildInputLabel("Field Name"),
                      SizedBox(height: 10),
                      buildTextField("Enter the field name"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Campo "Sport" com Autocomplete
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      buildInputLabel("Sport"),
                      SizedBox(height: 10),
                      Autocomplete<String>(
                        optionsBuilder:
                            (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return sportsOptions;
                          }
                          return sportsOptions.where((String option) {
                            return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          _sportController.text = selection;
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController
                                fieldTextEditingController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted) {
                          return TextFormField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              hintText: "Select or type a sport",
                              hintStyle:
                                  TextStyle(color: Colors.grey.shade600),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade600),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade600),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.blue.shade600, width: 2),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Contatos
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      buildInputLabel("Contacts"),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: buildTextField("Email")),
                          SizedBox(width: 16),
                          Expanded(child: buildTextField("Phone Number")),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Preço por Hora
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      buildInputLabel("Hourly Price"),
                      SizedBox(height: 10),
                      buildTextField("Enter hourly price", isNumber: true),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Schedule e Unavailability
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildInputLabel("Schedule"),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => openScheduleDayPopup(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey
                                      .shade200, // Fundo suave cinza claro
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade600),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.grey
                                          .shade800, // Cor do ícone alterada para cinza escuro
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Schedule", // Texto alterado
                                      style: TextStyle(
                                        color: Colors.grey
                                            .shade800, // Cor do texto alterada para cinza escuro
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildInputLabel("Unavailability"),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => openUnavailabilityPopup(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey
                                      .shade200, // Fundo suave cinza claro
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade600),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey
                                          .shade800, // Cor do ícone alterada para cinza escuro
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Unavailability", // Texto alterado
                                      style: TextStyle(
                                        color: Colors.grey
                                            .shade800, // Cor do texto alterada para cinza escuro
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Descrição
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      buildInputLabel("Description"),
                      SizedBox(height: 10),
                      buildTextField("Enter a description",
                          isMultiline: true),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Botão de Registro
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Implementar lógica de registro
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Property Registered with sport: ${_sportController.text}"),
                        backgroundColor: Colors.blue
                            .shade600, // Cor do SnackBar alterada para azul
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue
                        .shade600, // Cor do botão alterada para azul
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    elevation: 5,
                  ),
                  child: Text(
                    "Register Property",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}