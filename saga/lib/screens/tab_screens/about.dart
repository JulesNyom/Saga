import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutPageState();
}

class _AboutPageState extends State<About> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  double _scrollOffset = 0.0;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onMainScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onMainScroll);
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onMainScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  double get _appBarOpacity {
    const showAt = 20.0;
    const fullyVisibleAt = 100.0;
    
    if (_scrollOffset <= showAt) return 0.0;
    if (_scrollOffset >= fullyVisibleAt) return 1.0;
    
    return (_scrollOffset - showAt) / (fullyVisibleAt - showAt);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement form submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message envoyé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear form
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          child: AppBar(
            backgroundColor: Colors.black.withOpacity(_appBarOpacity),
            elevation: _appBarOpacity * 4,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(_appBarOpacity * 0.8),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            title: Opacity(
              opacity: _appBarOpacity,
              child: const Text(
                'À propos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              const Text(
                'Notre Mission',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoSection(
                'Médit\'Audio est une association à but non lucratif dédiée à rendre la méditation et le développement personnel accessibles à tous. Notre mission est de proposer gratuitement une vaste collection de livres audio de qualité pour accompagner votre parcours de bien-être.',
              ),
              const SizedBox(height: 30),
              _buildFeatureCard(
                icon: Icons.library_books,
                title: 'Collection Gratuite',
                description: 'Plus de 100 livres audio disponibles gratuitement, soigneusement sélectionnés pour leur pertinence et leur qualité.',
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                icon: Icons.people_outline,
                title: 'Communauté Engagée',
                description: 'Une communauté de bénévoles passionnés qui contribuent à la lecture et à la production de contenus audio.',
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                icon: Icons.workspace_premium,
                title: 'Qualité Professionnelle',
                description: 'Des enregistrements réalisés dans des conditions professionnelles pour une expérience d\'écoute optimale.',
              ),
              const SizedBox(height: 40),
              const Text(
                'Notre Histoire',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoSection(
                'Fondée en 2020, Médit\'Audio est née de la volonté de démocratiser l\'accès aux ressources de développement personnel. Notre équipe de passionnés travaille sans relâche pour enrichir notre bibliothèque et améliorer l\'expérience utilisateur.',
              ),
              const SizedBox(height: 40),
              const Text(
                'Contactez-nous',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoSection(
                'Vous avez des questions, des suggestions ou souhaitez rejoindre notre équipe de bénévoles ? N\'hésitez pas à nous contacter via le formulaire ci-dessous.',
              ),
              const SizedBox(height: 30),
              _buildContactForm(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 16,
        height: 1.6,
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.purple.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Nom',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _messageController,
            label: 'Message',
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre message';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Envoyer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.blue,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      validator: validator,
    );
  }
}