const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

const pdfSender = require("./pdfSender");
exports.generateMatchReport = pdfSender.generateMatchReport;

if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();
const messaging = admin.messaging();

setGlobalOptions({ maxInstances: 10 });

const chunkArray = (arr, size) =>
  arr.reduce((acc, _, i) => i % size === 0 ? [...acc, arr.slice(i, i + size)] : acc, []);

// 🔁 1. Ειδοποίηση όταν αλλάζει ένα match
exports.sendPushNotification = onDocumentUpdated("year/2026/matches/{matchId}", async (event) => {
  const matchId = event.params.matchId;
  const before = event.data.before.data();
  const after = event.data.after.data();

  const flattenFacts = (factsMap) => Object.values(factsMap || {}).flat();
  const beforeFacts = flattenFacts(before.facts);
  const afterFacts = flattenFacts(after.facts);

  let titles = { en: "🔔 New Update!", el: "🔔 Νέα ενημέρωση!" };
  let bodies = { en: `There's a new update for the match: ${matchId}`, el: `Έχεις νέο μήνυμα για τον αγώνα: ${matchId}` };

  const factId = (f) => f.id || `${f.type}-${f.minute}-${f.scorerName || ""}-${f.isHomeTeam}`;
  const beforeFactIds = new Set(beforeFacts.map(factId));
  const newFacts = afterFacts.filter((f) => !beforeFactIds.has(factId(f)));
  const newGoal = newFacts.find((f) => f.type === "goal");

  if (newGoal && newGoal.minute != null) {
    const isHome = String(newGoal.isHomeTeam) === "true";
    const minuteFormatted = String(Math.floor(newGoal.minute / 60) + 1).padStart(2, "0");

    titles = {
      en: `${after.homeTeamEnglish} - ${after.awayTeamEnglish}`,
      el: `${after.Hometeam} - ${after.Awayteam}`,
    };

    let scorerName = "";
    if (newGoal.playerName && newGoal.playerName.trim() !== "" && newGoal.playerName !== "Άλλος") {
      scorerName = ` (${newGoal.playerName.trim()})`;
    }


    bodies = isHome ?
      {
        en: `${minuteFormatted}′ GOAL: [${newGoal.homeScore}]-${newGoal.awayScore} ${scorerName}`,
        el: `${minuteFormatted}′ ΓΚΟΛ: [${newGoal.homeScore}]-${newGoal.awayScore} ${scorerName}`,
      } :
      {
        en: `${minuteFormatted}′ GOAL: ${newGoal.homeScore}-[${newGoal.awayScore}] ${scorerName}`,
        el: `${minuteFormatted}′ ΓΚΟΛ: ${newGoal.homeScore}-[${newGoal.awayScore}] ${scorerName}`,
      };
  } else if (before.HasMatchStarted !== after.HasMatchStarted && after.HasMatchStarted) {
    titles = { en: `${after.homeTeamEnglish}-${after.awayTeamEnglish}`, el: `${after.Hometeam}-${after.Awayteam}` };
    bodies = { en: `Match has started.`, el: `Ο αγώνας ξεκίνησε.` };
  } else if (before.hasMatchFinished !== after.hasMatchFinished && after.hasMatchFinished) {
    titles = { en: `${after.homeTeamEnglish}-${after.awayTeamEnglish}`, el: `${after.Hometeam}-${after.Awayteam}` };
    bodies = { en: `Match ended: ${after.GoalHome} ${after.GoalAway}`, el: `Ο αγώνας τελείωσε: ${after.GoalHome}-${after.GoalAway}` };
  } else if (before.hasExtraTimeStarted !== after.hasExtraTimeStarted && after.hasExtraTimeStarted) {
    titles = { en: `${after.homeTeamEnglish}-${after.awayTeamEnglish}`, el: `${after.Hometeam}-${after.Awayteam}` };
    bodies = { en: `Extra time started: ${after.GoalHome} ${after.GoalAway}`, el: `Η παράταση ξεκίνησε: ${after.GoalHome}-${after.GoalAway}` };
  } else if (before.hasExtraTimeFinished !== after.hasExtraTimeFinished && after.hasExtraTimeFinished) {
    titles = { en: `${after.homeTeamEnglish}-${after.awayTeamEnglish}`, el: `${after.Hometeam}-${after.Awayteam}` };
    bodies = { en: `Extra time finished: ${after.GoalHome} ${after.GoalAway}`, el: `Η παράταση τελείωσε: ${after.GoalHome}-${after.GoalAway}` };
  } else {
    return;
  }

  const usersSnap = await db.collection("users").get();
  const englishTokens = [];
  const greekTokens = [];

  usersSnap.forEach((doc) => {
    const data = doc.data();
    if (!data.fcmToken) return;

    const matchPrefs = data.matchKeys || {};
    const favorites = data["Favourite Teams"] || [];
    const notifyAll = data.notifyAllMatches === true; // Ο γενικός διακόπτης

    const isFavorite = favorites.includes(after.Hometeam) || favorites.includes(after.Awayteam);
    const matchSetting = matchPrefs[matchId];

    if (matchSetting === false) return;

    const shouldNotify = (matchSetting === true) || notifyAll || isFavorite;

    if (!shouldNotify) return;

    if (data.Language === false) {
      englishTokens.push(data.fcmToken);
    } else {
      greekTokens.push(data.fcmToken);
    }
  });

  const sendLocalizedNotifications = async (tokens, lang) => {
    const message = {
      notification: { title: titles[lang], body: bodies[lang] },
      data: { matchId: String(matchId) },
      android: { priority: "high", notification: { icon: "ic_stat_notification", color: "#D32F2F", sound: "default" } },
      apns: { payload: { aps: { sound: "default" } } },
    };

    for (const chunk of chunkArray(tokens, 500)) {
      const response = await messaging.sendEachForMulticast({ ...message, tokens: chunk });
      console.log(`📨 Sent ${response.successCount}/${chunk.length} ${lang.toUpperCase()} messages`);
    }
  };

  if (englishTokens.length) await sendLocalizedNotifications(englishTokens, "en");
  if (greekTokens.length) await sendLocalizedNotifications(greekTokens, "el");
});

// 🕒 2. Ειδοποίηση για αγώνες που ξεκινάνε σε 30 λεπτά
exports.checkMatchesAndNotify = onSchedule(
  {
    schedule: "*/5 12-21 * * *",
    timeZone: "Europe/Athens",
  },
  async () => {
    const now = new Date();
    const in30Mins = new Date(now.getTime() + 30 * 60 * 1000);

    const snapshot = await db
      .collection("year")
      .doc("2026")
      .collection("matches")
      .where("startTime", ">=", admin.firestore.Timestamp.fromDate(now))
      .where("startTime", "<=", admin.firestore.Timestamp.fromDate(in30Mins))
      .where("notified", "==", false)
      .get();

    await Promise.all(snapshot.docs.map(async (doc) => {
      const match = doc.data();
      const matchId = doc.id;

      const usersSnap = await db.collection("users").where("fcmToken", "!=", "").get();
      const tokens = [];

      usersSnap.forEach(userDoc => {
        const data = userDoc.data();
        if (!data.fcmToken) return;

        const matchKeyPrefs = data.matchKeys || {};
        const favorites = data["Favourite Teams"] || [];

        const home = match.Hometeam;
        const away = match.Awayteam;
        const matchPref = matchKeyPrefs[matchId];
        const isFavorite = favorites.includes(home) || favorites.includes(away);

        const shouldNotify = matchPref === true || (matchPref === undefined && isFavorite);
        if (!shouldNotify) return;

        tokens.push({ token: data.fcmToken, isEnglish: data.Language === false });
      });

      if (!tokens.length) return;

      const englishTokens = tokens.filter(t => t.isEnglish).map(t => t.token);
      const greekTokens = tokens.filter(t => !t.isEnglish).map(t => t.token);

      const enMessage = {
        notification: { title: `${match.homeTeamEnglish}-${match.awayTeamEnglish}`, body: `Match will start in 30 minutes!` },
        data: { matchId: String(matchId) }
      };

      const elMessage = {
        notification: { title: `${match.Hometeam}-${match.Awayteam}`, body: `Ο αγώνας ξεκινάει σε 30 λεπτά!` },
        data: { matchId: String(matchId) }
      };

      for (const chunk of chunkArray(englishTokens, 500)) {
        await messaging.sendEachForMulticast({ ...enMessage, tokens: chunk });
      }

      for (const chunk of chunkArray(greekTokens, 500)) {
        await messaging.sendEachForMulticast({ ...elMessage, tokens: chunk });
      }

      await doc.ref.update({ notified: true });
    }));
  }
);