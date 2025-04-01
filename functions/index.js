const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onRequest } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

// Set the maximum instances for your functions
setGlobalOptions({ maxInstances: 10 });

exports.checkMatches = onSchedule(
  {
    schedule: "every 10 minutes", // Runs every minute (for testing)
    timeZone: "Europe/Athens",
  },
  async (event) => {
    const now = admin.firestore.Timestamp.now();
    const tenMinutesLater = new Date(now.toDate().getTime() + 10 * 60 * 1000);

    const matchesSnapshot = await admin.firestore()
      .collection("matches")
      .where("startTime", ">=", now)
      .where("startTime", "<=", admin.firestore.Timestamp.fromDate(tenMinutesLater))
      .where("notified", "==", false)
      .get();

    const promises = matchesSnapshot.docs.map(async (doc) => {
      const match = doc.data();

      const message = {
        notification: {
          title: "⚽ Match Starting Soon!",
          body: `${match.teamA} vs ${match.teamB} in 10 minutes!`,
        },
        topic: "upcoming_matches",
      };

      await admin.messaging().send(message);
      await doc.ref.update({ notified: true });
      console.log(`Notification sent for ${match.teamA} vs ${match.teamB}`);
    });

    await Promise.all(promises);
  }
);