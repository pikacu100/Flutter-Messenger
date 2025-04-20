import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";

initializeApp();

export const sendMessageNotification = onDocumentCreated(
  "chatrooms/{chatRoomId}/messages/{messageId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const messageData = snapshot.data();
    if (messageData.notificationSent || messageData.systemMessage) return;

    const db = getFirestore();
    const [sender, receiver] = await Promise.all([
      db.collection("users").doc(messageData.senderId).get(),
      db.collection("users").doc(messageData.receiverId).get(),
    ]);

    if (!receiver.data()?.fcmToken) return;

    await getMessaging().send({
      notification: {
        title: sender.data()?.nickname || "New message",
        body: messageData.message,
      },
      data: {
        chatRoomId: event.params.chatRoomId,
        senderId: messageData.senderId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      token: receiver.data()?.fcmToken,
    });

    await snapshot.ref.update({notificationSent: true});
  }
);
