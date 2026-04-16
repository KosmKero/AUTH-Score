//const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
//const admin = require("firebase-admin");
//const PDFDocument = require("pdfkit");
//const sgMail = require("@sendgrid/mail");
//
//// Καλό είναι να το βάλεις σε μια μεταβλητή περιβάλλοντος αργότερα
//sgMail.setApiKey("mlsn.");
//
//// Initialize admin αν δεν έχει γίνει ήδη
//if (admin.apps.length === 0) {
//    admin.initializeApp();
//}
//
///**
// * Δημιουργεί το PDF Buffer για το φύλλο αγώνα
// * @param {Object} matchData Τα δεδομένα του αγώνα
// * @return {Promise<Buffer>}
// */
//async function createMatchPDF(matchData) {
//    return new Promise((resolve) => {
//        const doc = new PDFDocument({size: "A4", margin: 50});
//        const buffers = [];
//
//        // Προσπάθεια φόρτωσης γραμματοσειράς για Ελληνικά
//        try {
//            doc.font("fonts/Roboto-Regular.ttf");
//        } catch (e) {
//            console.warn("Font not found, using default");
//        }
//
//        doc.on("data", (chunk) => buffers.push(chunk));
//        doc.on("end", () => {
//            const pdfData = Buffer.concat(buffers);
//            resolve(pdfData);
//        });
//
//        // Σχεδιασμός PDF
//        doc.fontSize(20).text("UniScore - Επίσημο Φύλλο Αγώνα", {align: "center"});
//        doc.moveDown();
//        doc.fontSize(12).text(`Ημερομηνία: ${new Date().toLocaleDateString("el-GR")}`);
//        doc.moveDown();
//        doc.fontSize(18).text(
//            `${matchData.Hometeam} ${matchData.GoalHome} - ${matchData.GoalAway} ${matchData.Awayteam}`,
//            {align: "center"}
//        );
//
//        doc.end();
//    });
//}
//
//exports.generateMatchReport = onDocumentUpdated("year/2026/matches/{matchId}", async (event) => {
//    const newValue = event.data.after.data();
//    const previousValue = event.data.before.data();
//
//    // Έλεγχος αν το status άλλαξε σε finished
//    if (newValue.hasMatchFinished === true && previousValue.hasMatchFinished !== true) {
//        try {
//            console.log(`Έναρξη δημιουργίας PDF για το ματς: ${event.params.matchId}`);
//
//            const pdfBuffer = await createMatchPDF(newValue);
//
//            const msg = {
//                to: ["uniscore.info@gmail.com"],
//                from: "authscore@gmail.com",
//                subject: `Επίσημο Φύλλο Αγώνα: ${newValue.Hometeam} - ${newValue.Awayteam}`,
//                text: "Σας επισυνάπτεται το επίσημο φύλλο αγώνα από την πλατφόρμα UniScore.",
//                attachments: [
//                    {
//                        content: pdfBuffer.toString("base64"),
//                        filename: `match_report_${event.params.matchId}.pdf`,
//                        type: "application/pdf",
//                        disposition: "attachment",
//                    },
//                ],
//            };
//
//            await sgMail.send(msg);
//
//            await event.data.after.ref.update({
//                reportSent: true,
//                reportTimestamp: admin.firestore.FieldValue.serverTimestamp(),
//            });
//
//            console.log("Το email στάλθηκε με επιτυχία!");
//        } catch (error) {
//            console.error("Σφάλμα στην αποστολή PDF:", error);
//        }
//    }
//});
