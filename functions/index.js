/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const emoji = require("node-emoji"); // 이모티콘 변환 라이브러리

admin.initializeApp();

/// 전체 푸쉬 알림 전송
exports.sendSlackMessageNotification = functions.firestore
  .document("/slack_messages/{messageId}") // /slack_messages 컬렉션 감지
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const text = data.text;
    const channel = data.channel;
    const user = data.user;

    // Firestore에서 모든 기기 토큰 가져오기
    const tokensSnapshot = await admin
      .firestore()
      .collection("/device_tokens")
      .get();
    const tokens = tokensSnapshot.docs.map((doc) => doc.data().token);
    console.log("🛠️", tokens);

    // `*`을 기준으로 파싱
    const matches = text.match(/\*(.*?)\*/);
    let title = "BalbamBalbam"; // 기본 제목
    let body = text; // 기본 본문

    if (matches) {
      title = emoji.emojify(matches[1]); // `*` 안의 내용이 제목
      body = emoji.emojify(text.replace(matches[0], "").trim()); // 제목 부분을 제거한 나머지가 본문
    } else {
      body = emoji.emojify(text);
    }

    // FCM 메시지 설정
    const message = {
      notification: {
        title: title,
        body: body,
      },
    };

    const promises = tokens.map((token) => {
      return admin.messaging().send({ ...message, token: token });
    });

    try {
      await Promise.all(promises);
      console.log("✅ FCM 알림 전송 성공!", title, body);
    } catch (error) {
      console.error("❌ FCM 전송 오류:", error);
    }
  });

/// 개별 푸쉬 알림 전송
exports.sendPersonalMessageNotification = functions.firestore
  .document("/personal_messages/{messageId}") // personal_messages 컬렉션 감지
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const text = data.text; // text값
    const user = data.user; // user값

    if (!text || !user) {
      console.error("❌ 필수 데이터(text 또는 user)가 없습니다.");
      return;
    }

    try {
      // Firestore에서 해당 user의 token 조회
      const tokensSnapshot = await admin
        .firestore()
        .collection("device_tokens")
        .where("user", "==", user)
        .get();

      if (tokensSnapshot.empty) {
        console.warn(
          `⚠️ 해당 user(${user})의 device token이 존재하지 않습니다.`
        );
        return;
      }

      const tokens = tokensSnapshot.docs.map((doc) => doc.data().token);

      // `*`을 기준으로 제목 추출
      const matches = text.match(/\*(.*?)\*/);
      let title = "BalbamBalbam"; // 기본 제목
      let body = text; // 기본 본문

      if (matches) {
        title = emoji.emojify(matches[1]); // `*` 안의 내용을 제목으로 사용
        body = emoji.emojify(text.replace(matches[0], "").trim()); // 제목을 제외한 나머지를 본문으로 사용
      } else {
        body = emoji.emojify(text);
      }

      // FCM 메시지 설정
      const message = {
        notification: {
          title: title,
          body: body,
        },
      };

      // FCM 메시지 전송
      const promises = tokens.map((token) =>
        admin.messaging().send({ ...message, token: token })
      );

      await Promise.all(promises);
      console.log(`✅ FCM 알림 전송 성공! 대상 user: ${user}`, title, body);
    } catch (error) {
      console.error("❌ FCM 전송 오류:", error);
    }
  });
