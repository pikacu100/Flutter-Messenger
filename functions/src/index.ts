import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";

initializeApp();

export const sendMessageNotification = onDocumentCreated(
  "chatrooms/{chatRoomId}/messages/{messageId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      return;
    }

    const messageData = snapshot.data();
    const chatRoomId = event.params.chatRoomId;

    if (messageData.notificationSent || messageData.systemMessage) {
      return;
    }

    const senderId = messageData.senderId;
    const receiverId = messageData.receiverId;

    const db = getFirestore();
    const [senderSnapshot, receiverSnapshot] = await Promise.all([
      db.collection("users").doc(senderId).get(),
      db.collection("users").doc(receiverId).get(),
    ]);

    const sender = senderSnapshot.data();
    const receiver = receiverSnapshot.data();

    if (!receiver?.fcmToken || receiver?.notificationEnabled === false) {
      return;
    }

    const payload = {
      notification: {
        title: `${sender?.displayName || "New message"}`,
        body: messageData.message,
      },
      data: {
        chatRoomId: chatRoomId,
        senderId: senderId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      token: receiver.fcmToken,
    };

    try {
      await getMessaging().send(payload);
      await snapshot.ref.update({notificationSent: true});
      console.log("Notification sent successfully");
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  });
