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

// listen to Following events and then trigger a push notification
exports.observeFollowing = functions.firestore
    .document("following/{uid}/follows/{followingId}")
    .onCreate((snapshot, context) => {
        const uid = context.params.uid;
        const followingId = context.params.followingId;

        console.log("User: " + uid + "is following " + followingId);
        
        var fcmToken = "d4TLypNqk_w:APA91bFhmYMjuW_Cayg0XCXy64gzxJLcaf1gDwDcPLZCqUr3Dnt2Mx1WvoLAlKRC0qKOyTunFinRI7HrTaX3Cmu4sfPVPucWVilcxYtgEsk94u3hgTJlvvrY30AemtHzW2UiBZtB6dXh"

    var message = {
        notification: {
            title: "Notification Title",
            body: "Notification Body"
        },

        data: {
            score: "850",
            time: "2:45"
        },
        token: fcmToken
    };

    admin.messaging().send(message)
    .then(function(response) {
        console.log("Successfully sent message: ", response);
    })
    .catch(function(error) {
        console.log("Error sending message: ", error);
    });
});

exports.sendPushNotifications = functions.https.onRequest((req, res) => {
    res.send("Attempting to send push notifications...");
    console.log("LOGGER----Trying to send push message using hardcorede data...");


    // var uid = "OR25rA4Ha1fnJgDfD9VRHBnOvkg1"
    
    // admin.firestore().doc("users/" + uid).get()
    //     .then(doc => {
    //         if (!doc.exists) {
    //             console.log('No such document!');
    //         } else {
    //             var user = doc.data();

    //             res.send(user);

    //             var message = {
    //                 notification: {
    //                     title: "Notification Title",
    //                     body: "Notification Body"
    //                 },
            
    //                 data: {
    //                     score: "850",
    //                     time: "2:45"
    //                 },
    //                 token: user.fcmToken
    //             };
            
    //             admin.messaging().send(message)
    //             .then(function(response) {
    //                 console.log("Successfully sent message: ", response);
    //             })
    //             .catch(function(error) {
    //                 console.log("Error sending message: ", error);
    //             });
    //         }
    //     })
    //     .catch(err => {
    //         console.log('Error getting document ', err);
    //     });


    var fcmToken = "d4TLypNqk_w:APA91bFhmYMjuW_Cayg0XCXy64gzxJLcaf1gDwDcPLZCqUr3Dnt2Mx1WvoLAlKRC0qKOyTunFinRI7HrTaX3Cmu4sfPVPucWVilcxYtgEsk94u3hgTJlvvrY30AemtHzW2UiBZtB6dXh"

    var message = {
        notification: {
            title: "Notification Title",
            body: "Notification Body"
        },

        data: {
            score: "850",
            time: "2:45"
        },
        token: fcmToken
    };

    admin.messaging().send(message)
    .then(function(response) {
        console.log("Successfully sent message: ", response);
    })
    .catch(function(error) {
        console.log("Error sending message: ", error);
    });
});
