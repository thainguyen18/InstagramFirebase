// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
 response.send("Hello from Firebase!");
});

exports.sendPushNotifications = functions.https.onRequest((req, res) => {
    res.send("Attempting to send push notifications...");
    console.log("LOGGER----Trying to send push message...");
    
    //admin.messaging().sendToDevice(token, payload)

    var fcmToken = "d4TLypNqk_w:APA91bFhmYMjuW_Cayg0XCXy64gzxJLcaf1gDwDcPLZCqUr3Dnt2Mx1WvoLAlKRC0qKOyTunFinRI7HrTaX3Cmu4sfPVPucWVilcxYtgEsk94u3hgTJlvvrY30AemtHzW2UiBZtB6dXh"

    var payload = {
        notification: {
            title: "Notification Title",
            body: "Notification Body"
        },

        data: {
            score: "850",
            time: "2:45"
        }
    };

    admin.messaging().sendToDevice(fcmToken, payload)
    .then(function(response) {
        console.log("Successfully sent message: ", response);
    })
    .catch(function(error) {
        console.log("Error sending message: ", error);
    });
});
