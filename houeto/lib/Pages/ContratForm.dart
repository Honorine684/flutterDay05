import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContratForm extends StatefulWidget {
  final Map<String, dynamic> contratData;
  final Function(String dateDebut, String duree, String modePaiement) onSubmit;

  const ContratForm({
    super.key,
    required this.contratData,
    required this.onSubmit,
  });

  @override
  State<ContratForm> createState() => _ContratFormState();
}

class _ContratFormState extends State<ContratForm> {
  late String _dateDebut;
  late String _duree;
  late String _selectedTypePaiement;
  late bool _showDetailsCalcul;

  @override
  void initState() {
    super.initState();
    _dateDebut = '';
    _duree = '12';
    _showDetailsCalcul = false;
    
    // Gestion sécurisée de la valeur null
    final modePaiementBase = widget.contratData['modePaiement']?.toString() ?? 'Mois';
    _selectedTypePaiement = modePaiementBase == 'Mois' ? 'Mensuel' : 'Journalier';
  }

  @override
  Widget build(BuildContext context) {
    // Valeurs par défaut sécurisées
  double loyer = 0.0;
  if (widget.contratData.containsKey('loyer') && widget.contratData['loyer'] != null) {
    loyer = (widget.contratData['loyer'] as num).toDouble();
  } else {
    // Essayer de récupérer depuis detailsLogement en fonction du mode
    final modePaiementBase = widget.contratData['modePaiement']?.toString() ?? 'Mois';
    if (modePaiementBase == 'Mois' && 
        widget.contratData['detailsLogement']?.containsKey('loyerMois') == true) {
      loyer = (widget.contratData['detailsLogement']!['loyerMois'] as num).toDouble();
    } else if (widget.contratData['detailsLogement']?.containsKey('loyerJour') == true) {
      loyer = (widget.contratData['detailsLogement']!['loyerJour'] as num).toDouble();
    }
  }

  final avance = (widget.contratData['avance'] as num?)?.toDouble() ?? 0.0;
  final totalInitial = (widget.contratData['totalInitial'] as num?)?.toDouble() ?? 0.0;
  final typeBail = widget.contratData['typeBail']?.toString() ?? 'Bail standard';
  final modePaiementBase = widget.contratData['modePaiement']?.toString() ?? 'Mois';
  final nomDemandeur = widget.contratData['nomDemandeur']?.toString() ?? 'Non spécifié';
  final logementTitre = widget.contratData['detailsLogement']?['titre']?.toString() ?? 'LOgement inconnu';

    return AlertDialog(
      title: const Text('Création du contrat', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Informations de base
            _buildInfoSection('Informations principales', [
              _buildInfoRow('Logement:', logementTitre),
              _buildInfoRow('Locataire:', nomDemandeur),
            ]),

            // Section Détails financiers
          _buildInfoSection('Détails financiers', [
  if (modePaiementBase == 'Mois' && widget.contratData['detailsLogement']?['loyerJour'] != null)
    _buildInfoRow('Loyer/jour:', '${(widget.contratData['detailsLogement']!['loyerJour'] as num).toStringAsFixed(2)} FCFA'),
  
  if (modePaiementBase == 'Jour' && widget.contratData['detailsLogement']?['loyerMois'] != null)
    _buildInfoRow('Loyer/mois:', '${(widget.contratData['detailsLogement']!['loyerMois'] as num).toStringAsFixed(2)} FCFA'),
  
  _buildInfoRow('Loyer:', '${loyer.toStringAsFixed(2)} FCFA/${modePaiementBase == 'Mois' ? 'mois' : 'jour'}'),
  _buildInfoRow('Caution:', '${avance.toStringAsFixed(2)} FCFA'),
  _buildInfoRow('Type de bail:', typeBail),
  
              
              InkWell(
                onTap: () => setState(() => _showDetailsCalcul = !_showDetailsCalcul),
                child: Row(
                  children: [
                    const Text('Total initial:', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
                    Icon(_showDetailsCalcul ? Icons.expand_less : Icons.expand_more),
                    Text('${totalInitial.toStringAsFixed(2)} FCFA', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              
           if (_showDetailsCalcul) ...[
  const SizedBox(height: 8),
  const Text('Détail du calcul:', style: TextStyle(fontStyle: FontStyle.italic)),
  const SizedBox(height: 4),
  Text('- Caution: ${avance.toStringAsFixed(2)} FCFA'),
  Text('- ${typeBail == 'Avancé' ? '6 mois de loyer' : '1 mois de loyer'}: '
      '${typeBail == 'Avancé' ? (loyer * 6).toStringAsFixed(2) : loyer.toStringAsFixed(2)} FCFA'),
  Text('- Total: ${avance.toStringAsFixed(2)} + '
      '${typeBail == 'Avancé' ? (loyer * 6).toStringAsFixed(2) : loyer.toStringAsFixed(2)} = '
      '${totalInitial.toStringAsFixed(2)} FCFA'),
],
            ]),

            const SizedBox(height: 16),

            // Section Paramètres du contrat
            _buildInfoSection('Paramètres du contrat', [
              // Date de début
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 20),
                label: Text(_dateDebut.isEmpty ? 'Sélectionner date de début' : _dateDebut),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _dateDebut = DateFormat('dd/MM/yyyy').format(date);
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Durée du bail
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Durée (mois)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _duree = value,
                controller: TextEditingController(text: _duree),
              ),

              const SizedBox(height: 16),

              // Mode de paiement
              DropdownButtonFormField<String>(
                value: _selectedTypePaiement,
                decoration: const InputDecoration(
                  labelText: 'Mode de paiement',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: ['Mensuel', 'Trimestriel', 'Semestriel', 'Journalier']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTypePaiement = newValue!;
                  });
                },
              ),
            ]),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _dateDebut.isEmpty ? null : () {
            widget.onSubmit(_dateDebut, _duree, _selectedTypePaiement);
            Navigator.pop(context);
          },
          child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 18,
          color: Colors.blue[800],
        )),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            )),
          ),
          Expanded(
            child: Text(value, 
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}