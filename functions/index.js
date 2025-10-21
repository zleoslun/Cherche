const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Stripe = require("stripe");

admin.initializeApp();
const db = admin.firestore();

//
// 🔹 Load secret key securely from Firebase Functions config
// (You already set it with: firebase functions:config:set stripe.secret="sk_test_XXXX")
const stripe = Stripe(functions.config().stripe.secret);

exports.publishScheduledVideos = functions.pubsub
  .schedule("every 2 minutes")
  .timeZone("UTC")
  .onRun(async () => {
    try {
      const now = admin.firestore.Timestamp.now();
      const snapshot = await db
        .collection("videos")
        .where("status", "==", "scheduled")
        .where("scheduledAt", "<=", now)
        .get();

      if (snapshot.empty) {
        console.log("No videos to publish");
        return null;
      }

      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        const videoRef = db.collection("videos").doc(doc.id);
        batch.update(videoRef, { status: "published", publishedAt: now });
      });
      await batch.commit();

      const userUpdates = new Map();
      for (const doc of snapshot.docs) {
        const data = doc.data();
        const uid = data.uid;
        if (!userUpdates.has(uid)) userUpdates.set(uid, []);
        userUpdates.get(uid).push(data);
      }

      const userBatch = db.batch();
      for (const [uid] of userUpdates.entries()) {
        const userRef = db.collection("users").doc(uid);
        const userSnap = await userRef.get();
        let streak = 0;
        let lastUploadDate = null;

        if (userSnap.exists) {
          const userData = userSnap.data();
          streak = userData.streak || 0;
          lastUploadDate = userData.lastUploadDate || null;
        }

        const latestPublishTime = now.toDate();
        let newStreak = streak;

        if (lastUploadDate) {
          const lastDate = lastUploadDate.toDate();
          const diffDays = Math.floor(
            (latestPublishTime - lastDate) / (1000 * 60 * 60 * 24)
          );
          if (diffDays === 1) newStreak += 1;
          else if (diffDays > 1) newStreak = 1;
          else newStreak = streak;
        } else {
          newStreak = 1;
        }

        userBatch.update(userRef, { lastUploadDate: now, streak: newStreak });
      }

      await userBatch.commit();
      return null;
    } catch (error) {
      console.error("Error publishing scheduled videos:", error);
      throw error;
    }
  });

exports.cleanupExpiredSchedules = functions.pubsub
  .schedule("every 24 hours")
  .timeZone("UTC")
  .onRun(async () => {
    try {
      const now = admin.firestore.Timestamp.now();
      const oneDayAgo = new admin.firestore.Timestamp(
        now.seconds - 24 * 60 * 60,
        now.nanoseconds
      );

      const snapshot = await db
        .collection("videos")
        .where("status", "==", "scheduled")
        .where("scheduledAt", "<", oneDayAgo)
        .get();

      if (!snapshot.empty) {
        const batch = db.batch();
        snapshot.docs.forEach((doc) => {
          batch.update(doc.ref, {
            status: "draft",
            scheduledAt: admin.firestore.FieldValue.delete(),
          });
        });
        await batch.commit();
        console.log(`Moved ${snapshot.size} expired videos to draft`);
      }

      return null;
    } catch (error) {
      console.error("Error cleaning up expired schedules:", error);
      throw error;
    }
  });

// Payment method Integration

// 🔹 Create PaymentIntent (only if enabled in Firestore)
exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be logged in"
    );
  }

  // Fetch Stripe settings from Firestore
  const settingsSnap = await db.collection("config").doc("stripe").get();
  if (!settingsSnap.exists) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Stripe settings not found"
    );
  }

  const { enabled, currency } = settingsSnap.data();
  if (!enabled) {
    throw new functions.https.HttpsError(
      "unavailable",
      "Stripe payments are disabled"
    );
  }

  const amount = data.amount; // e.g., 1000 for $10

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: currency || "eur",
      metadata: { uid },
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  } catch (error) {
    console.error("Stripe error:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Unable to create payment intent"
    );
  }
});

// 🔹 Stripe Webhook to Confirm Payment and Update User
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const endpointSecret = functions.config().stripe.webhook; // Store webhook secret via: firebase functions:config:set stripe.webhook="whsec_XXXX"
  const sig = req.headers["stripe-signature"];

  let event;
  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
  } catch (err) {
    console.error("Webhook signature verification failed:", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === "payment_intent.succeeded") {
    const paymentIntent = event.data.object;
    const uid = paymentIntent.metadata.uid;

    try {
      await admin.firestore().collection("users").doc(uid).update({
        isPremium: true,
        premiumActivatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`User ${uid} upgraded to premium`);
    } catch (err) {
      console.error("Error updating user:", err);
    }
  }

  res.status(200).send("Webhook received");
});
