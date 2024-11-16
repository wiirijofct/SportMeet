import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'search_page.dart';
import 'package:sport_meet/application/presentation/widgets/person_card.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:flutter/material.dart';

class MeetPage extends StatefulWidget {
  const MeetPage({super.key});

  @override
  State<MeetPage> createState() => _MeetPageState();
}

class _MeetPageState extends State<MeetPage> {
  bool isFree = false;
  bool showOpenTeam = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Variáveis de seleção para os filtros
  List<String> sportsFilters = ['Basketball', 'Tennis', 'Swimming', 'Football'];
  List<String> selectedSports = [];
  List<String> selectedAvailability = [];
  List<String> selectedMunicipality = [];
  String selectedGender = '';

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String selectedSortOption = ''; // Variável para a opção de ordenação
  List<Map<String, String>> filteredEvent = []; // Variável para eventos filtrados

  final List<Map<String, String>> meetPeople = [
    // Lista de pessoas para o MeetPage
    {
      'title': 'Maria Inês Silva',
      'address': 'Municipality: Amadora',    
      'availability': 'Availability: All days',
      'sports': 'Favorite Sports: Basketball, Tennis',
      'gender': 'Gender: Female',
      'imagePath': 'lib/images/f1.png',
    },
    {
      'title': 'Mariana Coelho',
      'address': 'Municipality: Porto',
      'availability': 'Availability: All days',
      'sports': 'Favorite Sports: Football, Tennis, Voleyball, Handball',
      'gender': 'Gender: Female',
      'imagePath': 'lib/images/f2.png',
    },
    {
      'title': 'Rafael Santos',
      'address': 'Municipality: Sintra',
      'availability': 'Availability: Weekends',
      'sports': 'Favorite Sports: Boxing',
      'gender': 'Gender: Male',
      'imagePath': 'lib/images/m1.png',
    },
    {
      'title': 'Hugo Canelas',
      'address': 'Municipality: Sintra',
      'availability': 'Availability: Wednesdays, Fridays',
      'sports': 'Favorite Sports: Basketball',
      'gender': 'Gender: Male',
      'imagePath': 'lib/images/m2.png',
    },
    {
      'title': 'Joana Gonçalves',
      'address': 'Municipality: Faro',
      'availability': 'Availability: Tuesdays',
      'sports': 'Favorite Sports: Tennis',
      'gender': 'Gender: Female',
      'imagePath': 'lib/images/f3.png'
    },
    {
      'title': 'Pedro Pequeno',
      'address': 'Municipality: Setúbal',
      'availability': 'Availability: All days',
      'sports': 'Favorite Sports: Handball, Football',
      'gender': 'Gender: Male',
      'imagePath': 'lib/images/m3.png',
    },
    {
      'title': 'Gonçalo Marques',
      'address': 'Municipality: Setúbal',
      'availability': 'Availability: Tuesdays, Fridays',
      'sports': 'Favorite Sports: Football',
      'gender': 'Gender: Male',
      'imagePath': 'lib/images/m4.png',
    },
    {
      'title': 'Inês Bartolo',
      'address': 'Municipality: Sintra',
      'availability': 'Availability: All days',
      'sports': 'Favorite Sports: Basketball',
      'gender': 'Gender: Female',
      'imagePath': 'lib/images/f4.png',
    },
  ];

  void _navigateToSearchPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    selectedSports = List.from(sportsFilters); // Seleciona todos os esportes inicialmente
    filteredEvent = List.from(meetPeople); // Inicializa a lista de eventos filtrados
  }

  @override
  void dispose() {
    // Dispara o controlador ao remover o widget
    _searchController.dispose();
    super.dispose();
  }

  void toggleSportFilter(String sport) {
    setState(() {
      if (selectedSports.contains(sport)) {
        selectedSports.remove(sport);
      } else {
        selectedSports.add(sport);
      }
    });
  }

  void resetFilters() {
    setState(() {
      selectedSports = List.from(sportsFilters); // Reseta para todos os esportes
      selectedAvailability = [];
      selectedMunicipality = [];
      selectedGender = '';
      isFree = false;
      showOpenTeam = false;
      selectedStartDate = null;
      selectedEndDate = null;
      selectedSortOption = '';
      filteredEvent = List.from(meetPeople); // Reseta para todos os eventos
    });
  }

  void applyFilters() {
  setState(() {
    // Filtra os dados com base nos filtros selecionados
    filteredEvent = meetPeople.where((person) {
      final sportsMatch = selectedSports.isEmpty || selectedSports.any((sport) => person['sports']!.contains(sport));
      final availabilityMatch = selectedAvailability.isEmpty || selectedAvailability.any((day) => person['availability']!.contains(day));
      final municipalityMatch = selectedMunicipality.isEmpty || selectedMunicipality.contains(person['address']!.split(': ')[1]);
      final genderMatch = selectedGender.isEmpty || person['gender']!.contains(selectedGender);

      return sportsMatch && availabilityMatch && municipalityMatch && genderMatch;
    }).toList();
  });
}

void _showPersonDetails(Map<String, String> person) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(person['title']!, style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold,),), // Nome da pessoa
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Centraliza a imagem no topo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                person['imagePath']!,
                width: 150, // Tamanho ajustado da imagem
                height: 150, // Tamanho ajustado da imagem
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10), // Espaço entre a imagem e os esportes favoritos
            // Esportes favoritos (texto pequeno e preto)
            Text(
              person['sports']!,
              style: TextStyle(
                fontSize: 12, // Tamanho pequeno
                color: Colors.black, // Cor preta
              ),
            ),
            const SizedBox(height: 20), // Espaço entre os esportes e os botões
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botão de Adicionar Amigo
                ElevatedButton(
                  onPressed: () {
                    // Lógica para adicionar como amigo
                    Navigator.pop(context);
                    // Aqui você pode adicionar a lógica de adicionar amigo
                  },
                  child: const Text('Adicionar Amigo'),
                ),
                const SizedBox(width: 10), // Espaço entre os botões
                // Botão de Enviar Mensagem
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Fecha o diálogo atual
                    _showChatDialog(person); // Mostra o chat pop-up
                  },
                  child: const Text('Enviar Mensagem'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

void _showChatDialog(Map<String, String> person) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Lista para armazenar mensagens. Cada mensagem pode ter uma flag para indicar se é do usuário ou da outra pessoa.
      List<Map<String, String>> messages = [];

      TextEditingController controller = TextEditingController(); // Controlador para o TextField

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: Container(
              width: double.maxFinite,
              height: 300, // Ajuste a altura conforme necessário
              child: Column(
                children: [
                  // Imagem da pessoa com quem você está conversando
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      person['imagePath']!, // A imagem é extraída da lista de pessoas
                      width: 80, // Tamanho ajustado da imagem
                      height: 80, // Tamanho ajustado da imagem
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10), // Espaço entre a imagem e as mensagens
                  Expanded(
                    child: ListView.builder(
                      itemCount: messages.length, // Número de mensagens
                      itemBuilder: (context, index) {
                        // Verifica se a mensagem é do usuário ou da outra pessoa
                        bool isUserMessage = messages[index]['sender'] == 'user';

                        return Align(
                          alignment: isUserMessage
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            margin: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isUserMessage ? Colors.red[200] : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              messages[index]['text']!, // Exibe a mensagem armazenada na lista
                              style: TextStyle(
                                color: isUserMessage ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  TextField(
                    controller: controller, // Atribuindo o controlador ao TextField
                    decoration: InputDecoration(
                      hintText: 'Escreva uma mensagem...',
                      hintStyle: TextStyle(fontSize: 14),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            // Adiciona a mensagem do usuário na lista
                            setState(() {
                              messages.add({
                                'sender': 'user', // Marca que a mensagem é do usuário
                                'text': controller.text,
                              });
                            });
                            controller.clear(); // Limpa o campo de texto após enviar
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fechar o chat
                },
                child: const Text('Fechar'),
              ),
            ],
          );
        },
      );
    },
  );
}


  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Options'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // Multi-select dropdown para esportes favoritos
                    MultiSelectDialogField(
                      items: [
                        MultiSelectItem('Basketball', 'Basketball'),
                        MultiSelectItem('Tennis', 'Tennis'),
                        MultiSelectItem('Swimming', 'Swimming'),
                        MultiSelectItem('Football', 'Football'),
                      ],
                      listType: MultiSelectListType.LIST,
                      title: const Text("Favorite Sports", 
                        style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),),
                      selectedColor: const Color.fromARGB(255, 193, 50, 74),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      buttonText: const Text(
                        "Favorite Sports",
                        style: TextStyle(color: Colors.black),
                      ),
                      onConfirm: (values) {
                        setState(() {
                          selectedSports = values.cast<String>();
                        });
                      },
                      chipDisplay: MultiSelectChipDisplay(
                        chipColor: const Color.fromARGB(255, 193, 50, 74),
                        textStyle: const TextStyle(color: Colors.black),
                      ),
                    ),

                    SizedBox(height: 16.0),

                    // Multi-select dropdown para Disponibilidade
                    MultiSelectDialogField(
                      items: [
                        MultiSelectItem('All days', 'All days'),
                        MultiSelectItem('Weekends', 'Weekends'),
                        MultiSelectItem('Mondays', 'Mondays'),
                        MultiSelectItem('Tuesdays', 'Tuesday'),
                        MultiSelectItem('Wednesdays', 'Wednesday'),
                        MultiSelectItem('Thursdays', 'Thursdays'),
                        MultiSelectItem('Fridays', 'Fridays'),
                      ],
                      title: const Text("Availability", 
                        style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),),
                      selectedColor: const Color.fromARGB(255, 193, 50, 74),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      buttonText: const Text(
                        "Availability",
                        style: TextStyle(color: Colors.black),
                      ),
                      onConfirm: (values) {
                        setState(() {
                          selectedAvailability = values.cast<String>();
                        });
                      },
                      chipDisplay: MultiSelectChipDisplay(
                        chipColor: const Color.fromARGB(255, 193, 50, 74),
                        textStyle: const TextStyle(color: Colors.black),
                      ),
                    ),

                    SizedBox(height: 16.0),

                    // Multi-select dropdown para Município
                    MultiSelectDialogField(
                      items: [
                        MultiSelectItem('Lisboa', 'Lisboa'),
                        MultiSelectItem('Cascais', 'Cascais'),
                        MultiSelectItem('Porto', 'Porto'),
                        MultiSelectItem('Faro', 'Faro'),
                      ],
                      title: const Text("Municipality", 
                        style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),),
                      selectedColor: const Color.fromARGB(255, 193, 50, 74),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      buttonText: const Text(
                        "Municipality",
                        style: TextStyle(color: Colors.black),
                      ),
                      onConfirm: (values) {
                        setState(() {
                          selectedMunicipality = values.cast<String>();
                        });
                      },
                      chipDisplay: MultiSelectChipDisplay(
                        chipColor: const Color.fromARGB(255, 193, 50, 74),
                        textStyle: const TextStyle(color: Colors.black),
                      ),
                    ),

                    SizedBox(height: 16.0),

                    // Dropdown de gênero
                    DropdownButtonFormField<String>(
                      value: selectedGender.isEmpty ? null : selectedGender,
                      hint: const Text(
                        'Gender',
                       style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      )
                        
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGender = newValue ?? '';
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                      style: const TextStyle(color: Colors.black),
                      dropdownColor: const Color.fromARGB(255, 118, 120, 120),
                      iconEnabledColor: Colors.black,
                    ),
                  ],
                ),
              ),
              actions: [
                 TextButton(
                onPressed: () {
                  resetFilters(); // Reseta todos os filtros
                  Navigator.of(context).pop();
                },
                child: const Text('Clear Filters'),
                ),
                TextButton(
                  onPressed: () {
                    applyFilters(); // Aplica os filtros selecionados
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Filter the list based on searchQuery to match all text fields
    final filteredPeople = meetPeople.where((person) {
      final title = person['title']!.toLowerCase();
      final address = person['address']!.toLowerCase();
      final availability = person['availability']!.toLowerCase();
      final sports = person['sports']!.toLowerCase();
      final query = _searchController.text.toLowerCase();

      // Check if any of the fields contain the search query
      return title.contains(query) ||
            address.contains(query) ||
            availability.contains(query) ||
            sports.contains(query);
    }).toList();

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                      setState(() {
                        
                      }
                      );
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Ionicons.search),
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      suffixIcon: IconButton(
                            icon: const Icon(Ionicons.close_circle, color: Colors.red), // Cross icon
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Ionicons.filter_outline),
                  onPressed: showFilterDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEvent.length,
              itemBuilder: (context, index) {
                final person = filteredEvent[index]; // Usa filteredEvent ao invés de filteredPeople
                return GestureDetector(
                  onTap: () {
                    // Mostra o pop-up com as informações da pessoa
                    _showPersonDetails(person);
                  },
                  child: PersonCard(
                    title: person['title']!,
                    address: person['address']!,
                    availability: person['availability']!,
                    sports: person['sports']!,
                    imagePath: person['imagePath']!,
                    gender: person['gender']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.chatbubble_ellipses_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.heart_outline),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false, // Remove the back arrow
      toolbarHeight: 70,
      centerTitle: true,
      backgroundColor: Colors.red,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _navigateToSearchPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: const Text('SEARCH'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              // Stay on MeetPage
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: const Text('MEET'),
          ),
        ],
      ),
    );
  }
}