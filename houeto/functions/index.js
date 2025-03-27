const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendConfierNotification = functions.https.onCall(async (data, context) => {
  try {
    const { destinataireToken, logementId, destinataireId } = data;

    if (!destinataireToken || !logementId || !destinataireId) {
      throw new Error("Paramètres manquants !");
    }

    // 1. Récupérer les détails du logement
    const logementDoc = await admin.firestore().collection("logement").doc(logementId).get();

    if (!logementDoc.exists) {
      throw new Error("Logement non trouvé !");
    }

    const logementTitre = logementDoc.get("titre") || "un logement";

    // 2. Envoyer la notification
    await admin.messaging().send({
      token: destinataireToken,
      notification: {
        title: "📌 Nouvelle demande de gestion",
        body: `On vous propose de gérer "${logementTitre}". Cliquez pour répondre.`,
      },
      data: {
        type: "confier",
        logementId: logementId,
        destinataireId: destinataireId,
      },
    });
    console.log("Envoyé");
    return { success: true };
  } catch (error) {
    console.error("Erreur lors de l'envoi de la notification :", error);
    return { success: false, error: error.message };
  }
});
