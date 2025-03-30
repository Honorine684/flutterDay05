import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FactureLoyer extends StatelessWidget {
 
  final String nomLocataire = 'Lee';
  final String adresse = 'Abomey-Calavi, 75001 Paris';
  final double montantLoyer = 1200.00;
  final double chargesLocatives = 150.00;
  final DateTime moisConcerne = DateTime(2024, 3); 
  final DateTime datePaiement = DateTime(2024, 3, 25);

  FactureLoyer({super.key});


  Future<void> genererFactureLoyer(BuildContext context) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('QUITTANCE DE LOYER', 
                style: pw.TextStyle(
                  fontSize: 24, 
                  fontWeight: pw.FontWeight.bold
                )
              ),
              
              pw.SizedBox(height: 20),
              
              pw.Text('Locataire : $nomLocataire', 
                style: pw.TextStyle(fontSize: 16)
              ),
              pw.Text('Adresse : $adresse', 
                style: pw.TextStyle(fontSize: 16)
              ),
              
              pw.SizedBox(height: 20),
              
              pw.Text('Période : ${DateFormat('MMMM yyyy', 'fr_FR').format(moisConcerne)}', 
                style: pw.TextStyle(fontSize: 16)
              ),
              
              pw.SizedBox(height: 30),
              
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Désignation', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                        )
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Montant', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                        )
                      ),
                    ]
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Loyer')
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('${montantLoyer.toStringAsFixed(2)} €')
                      ),
                    ]
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Charges locatives')
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('${chargesLocatives.toStringAsFixed(2)} €')
                      ),
                    ]
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('TOTAL', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                        )
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('${(montantLoyer + chargesLocatives).toStringAsFixed(2)} €', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                        )
                      ),
                    ]
                  ),
                ]
              ),
              
              pw.SizedBox(height: 30),
              
              pw.Text('Date limite de paiement : ${DateFormat('dd/MM/yyyy').format(datePaiement)}', 
                style: pw.TextStyle(fontSize: 14)
              ),
              
              pw.Padding(
                padding: pw.EdgeInsets.only(top: 20),
                child: pw.Text('Merci de joindre le paiement à cette quittance.', 
                  style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)
                )
              )
            ],
          ),
        ),
      );

      // Enregistrer le PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/quittance_loyer.pdf');
      await file.writeAsBytes(await pdf.save());

      // Afficher ou partager le PDF
      await Printing.sharePdf(
        bytes: await pdf.save(), 
        filename: 'quittance_loyer.pdf'
      );

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF généré avec succès'))
      );

    } catch (e) {
      // Afficher une erreur détaillée
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de génération PDF: $e'),
          backgroundColor: Colors.red,
        )
      );
      print('Erreur de génération PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quittance de Loyer'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => genererFactureLoyer(context),
          child: Text('Générer la Quittance de Loyer'),
        ),
      ),
    );
  }
}