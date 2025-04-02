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
  late double _totalCalcule;

  @override
  void initState() {
    super.initState();
    _dateDebut = '';
    _duree = '12';
    _showDetailsCalcul = false;
    
    final modesDisponibles = widget.contratData['modesDisponibles'] as Map<String, dynamic>? ?? 
                           {'mensuel': true, 'journalier': true};
    
    if (modesDisponibles['mensuel'] == true) {
      _selectedTypePaiement = 'Mensuel';
    } else if (modesDisponibles['journalier'] == true) {
      _selectedTypePaiement = 'Journalier';
    } else {
      _selectedTypePaiement = 'Mensuel'; 
    }
    
    _totalCalcule = _calculerTotal();
  }
double _calculerTotal() {
  final caution = (widget.contratData['caution'] as num?)?.toDouble() ?? 0.0;
  
  if (_selectedTypePaiement == 'Journalier') {
    final loyer = _getCurrentLoyer();
    final jours = int.tryParse(_duree) ?? 1;
    return caution + (loyer * jours); 
  } else {
    final avance = (widget.contratData['avance'] as num?)?.toDouble() ?? 0.0;
    final typeBail = widget.contratData['typeBail'] ?? 'Standard';
    return avance + caution + (typeBail == 'Avancé' ? _getCurrentLoyer() * 6 : _getCurrentLoyer());
  }
}


  @override
  Widget build(BuildContext context) {
  
    final typeBail = widget.contratData['typeBail']?.toString() ?? 'Standard';
    final nomDemandeur = widget.contratData['nomDemandeur']?.toString() ?? 'Non spécifié';
    final logementTitre = widget.contratData['detailsLogement']?['titre']?.toString() ?? 'Logement inconnu';
    final modesDisponibles = widget.contratData['modesDisponibles'] as Map<String, dynamic>? ?? 
                           {'mensuel': true, 'journalier': true};

    List<String> modesPaiementOptions = [];
    if (modesDisponibles['mensuel'] == true) {
      modesPaiementOptions.addAll(['Mensuel', 'Trimestriel', 'Semestriel']);
    }
    if (modesDisponibles['journalier'] == true) {
      modesPaiementOptions.add('Journalier');
    }

    if (modesPaiementOptions.isEmpty) {
      modesPaiementOptions.add('Mensuel');
    }

    if (!modesPaiementOptions.contains(_selectedTypePaiement)) {
      _selectedTypePaiement = modesPaiementOptions.first;
    }

    return AlertDialog(
      title: const Text('Création du contrat', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
         children: [
  _buildInfoSection('Informations principales', [
    _buildInfoRow('Logement:', logementTitre),
    _buildInfoRow('Locataire:', nomDemandeur),
  ]),

  _buildInfoSection('Détails financiers', [
    buildFinancialDetails(widget.contratData),
    
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.contratData['detailsLogement']?['loyerMois'] != null)
          _buildInfoRow('Loyer mensuel:', '${(widget.contratData['detailsLogement']!['loyerMois'] as num).toStringAsFixed(2)} FCFA'),
        
        if (widget.contratData['detailsLogement']?['loyerJour'] != null)
          _buildInfoRow('Loyer journalier:', '${(widget.contratData['detailsLogement']!['loyerJour'] as num).toStringAsFixed(2)} FCFA'),
          
        _buildInfoRow(
          'Loyer appliqué:', 
          '${_getCurrentLoyer().toStringAsFixed(2)} FCFA/${_selectedTypePaiement == 'Journalier' ? 'jour' : 'mois'}',
          isBold: true
        ),
      ],
    ),
    
    InkWell(
      onTap: () => setState(() => _showDetailsCalcul = !_showDetailsCalcul),
      child: Row(
        children: [
          const Text('Total à payer:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Icon(_showDetailsCalcul ? Icons.expand_less : Icons.expand_more),
          Text('${_totalCalcule.toStringAsFixed(2)} FCFA', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    ),
    
if (_showDetailsCalcul) ...[
  const SizedBox(height: 8),
  const Text('Détail du calcul:', style: TextStyle(fontStyle: FontStyle.italic)),
  const SizedBox(height: 4),

  Text('- Caution: ${(widget.contratData['caution'] ?? 0).toStringAsFixed(0)} FCFA'),

  if (_selectedTypePaiement != 'Journalier')
    Text('- Avance: ${(widget.contratData['avance'] ?? 0).toStringAsFixed(0)} FCFA'),

  if (_selectedTypePaiement == 'Journalier')
    Text('- $_duree jours à ${_getCurrentLoyer().toStringAsFixed(0)} FCFA/jour: '
        '${(_getCurrentLoyer() * (int.tryParse(_duree) ?? 1)).toStringAsFixed(0)} FCFA'),
]else
    Text('- ${typeBail == 'Avancé' ? '6 mois' : '1 mois'} de loyer: '
        '${(typeBail == 'Avancé' ? _getCurrentLoyer() * 6 : _getCurrentLoyer()).toStringAsFixed(0)} FCFA'),

  Text('- Total: ${_totalCalcule.toStringAsFixed(0)} FCFA'),
]),

  const SizedBox(height: 16),

            _buildInfoSection('Paramètres du contrat', [
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 20),
                label: Text(_dateDebut.isEmpty ? 'Sélectionner date de début' : _dateDebut),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
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
              TextField(
                decoration: InputDecoration(
                  labelText: _selectedTypePaiement == 'Journalier' ? 'Durée (jours)' : 'Durée (mois)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _duree = value;
                    _totalCalcule = _calculerTotal();
                  });
                },
                controller: TextEditingController(text: _duree),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedTypePaiement,
                decoration: const InputDecoration(
                  labelText: 'Mode de paiement',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: modesPaiementOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTypePaiement = newValue!;
                    
                    if (_selectedTypePaiement == 'Journalier' && _duree == '12') {
                      _duree = '1'; 
                    } else if (_selectedTypePaiement != 'Journalier' && _duree == '1') {
                      _duree = '12'; 
                    }
                    
                    _totalCalcule = _calculerTotal();
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
            Navigator.pop(context, true);
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
Widget buildFinancialDetails(Map<String, dynamic> contratData) {
  final caution = (contratData['caution'] as num?)?.toDouble() ?? 0.0;
  
  return Column(
    children: [
      if (_selectedTypePaiement != 'Journalier')
        _buildInfoRow('Avance:', '${(contratData['avance'] ?? 0).toStringAsFixed(0)} FCFA'),
      _buildInfoRow('Caution:', '${caution.toStringAsFixed(0)} FCFA'),
      if (_selectedTypePaiement == 'Journalier')
        _buildInfoRow('Loyer ($_duree jours):', 
          '${(_getCurrentLoyer() * (int.tryParse(_duree) ?? 1)).toStringAsFixed(0)} FCFA'),
      _buildInfoRow('Total:', '${_totalCalcule.toStringAsFixed(0)} FCFA', isBold: true),
    ],
  );
}
Widget buildLoyerDetails() {
  final loyerMois = widget.contratData['detailsLogement']?['loyerMois'] as num?;
  final loyerJour = widget.contratData['detailsLogement']?['loyerJour'] as num?;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (loyerMois != null)
        _buildInfoRow('Loyer mensuel:', '${loyerMois.toStringAsFixed(2)} FCFA'),
      if (loyerJour != null)
        _buildInfoRow('Loyer journalier:', '${loyerJour.toStringAsFixed(2)} FCFA'),
      _buildInfoRow(
        'Loyer appliqué:', 
        '${_getCurrentLoyer().toStringAsFixed(2)} FCFA/${_selectedTypePaiement == 'Journalier' ? 'jour' : 'mois'}',
        isBold: true
      ),
    ],
  );
}

double _getCurrentLoyer() {
  return _selectedTypePaiement == 'Journalier' 
      ? (widget.contratData['loyerJour'] ?? 
         (widget.contratData['detailsLogement']?['loyerJour'] as num?)?.toDouble() ?? 0.0)
      : (widget.contratData['loyerMois'] ?? 
         (widget.contratData['detailsLogement']?['loyerMois'] as num?)?.toDouble() ?? 0.0);
}
}