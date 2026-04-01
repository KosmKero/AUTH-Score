const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const PDFDocument = require('pdfkit');
const sgMail = require('@sendgrid/mail'); // Ενεργοποιήθηκε

// Καλό είναι να το βάλεις σε μια μεταβλητή περιβάλλοντος αργότερα
sgMail.setApiKey('mlsn.f0e32c1c55b1b8f667a9e5301cfbd330d66d3120c6f964f6b41da14fd27da7e6');


// Initialize admin αν δεν έχει γίνει ήδη
if (admin.apps.length === 0) {
    admin.initializeApp();
}

exports.generateMatchReport = onDocumentUpdated("matches/{matchId}", async (event) => {
    const newValue = event.data.after.data();
    const previousValue = event.data.before.data();

    // Έλεγχος αν το status άλλαξε σε finished
    if (newValue.status === "finished" && previousValue.status !== "finished") {
        try {
            console.log(`Έναρξη δημιουργίας PDF για το ματς: ${event.params.matchId}`);

            // 1. Δημιουργία του PDF Buffer
            const pdfBuffer = await createMatchPDF(newValue);

            // 2. Προετοιμασία του Email
            const msg = {
                to: ['uniscore.info@gmail.com'],
                from: 'authscore@gmail.com',
                subject: `Επίσημο Φύλλο Αγώνα: ${newValue.teamA.name} - ${newValue.teamB.name}`,
                text: 'Σας επισυνάπτεται το επίσημο φύλλο αγώνα από την πλατφόρμα authscore.',
                attachments: [
                    {
                        content: pdfBuffer.toString('base64'),
                        filename: `match_report_${event.params.matchId}.pdf`,
                        type: 'application/pdf',
                        disposition: 'attachment'
                    },
                ],
            };

            // 3. Αποστολή μέσω SendGrid
            await sgMail.send(msg);

            // 4. Ενημέρωση Firestore για επιβεβαίωση
            await event.data.after.ref.update({
                reportSent: true,
                reportTimestamp: admin.firestore.FieldValue.serverTimestamp()
            });

            console.log("Το email στάλθηκε με επιτυχία!");
        } catch (error) {
            console.error("Σφάλμα στην αυτόματη διαδικασία:", error);
        }
    }
});

// Η συνάρτηση δημιουργίας PDF
async function createMatchPDF(matchData) {
    return new Promise((resolve, reject) => {
        const doc = new PDFDocument({ size: 'A4', margin: 50 });
        let buffers = [];

        // ΕΔΩ ΒΑΖΕΙΣ ΤΟ FONT ΓΙΑ ΤΑ ΕΛΛΗΝΙΚΑ
        // Πρέπει να έχεις το αρχείο στο: functions/fonts/Roboto-Regular.ttf
        try {
            doc.font('fonts/Roboto-Regular.ttf');  //δεν το εχω βαλει ακομα
        } catch (e) {
            console.warn("Το font δεν βρέθηκε, θα χρησιμοποιηθεί το default (ίσως χαλάσουν τα Ελληνικά)");
        }

        doc.on('data', buffers.push.bind(buffers));
        doc.on('end', () => {
            const pdfData = Buffer.concat(buffers);
            resolve(pdfData);
        });

        // Σχεδιασμός
        doc.fontSize(20).text('authscore - Επίσημο Φύλλο Αγώνα', { align: 'center' });
        doc.moveDown();
        doc.fontSize(12).text(`Ημερομηνία: ${new Date().toLocaleDateString('el-GR')}`);
        doc.moveDown();

        doc.fontSize(18).text(`${matchData.teamA.name} ${matchData.teamA.score} - ${matchData.teamB.score} ${matchData.teamB.name}`, { align: 'center' });

        // ... πρόσθεσε εδώ τα events (goals κλπ) όπως είχαμε πει

        doc.end();
    });
}