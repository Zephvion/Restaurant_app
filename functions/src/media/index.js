
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret, defineString } = require("firebase-functions/params");
const cloudinary = require("cloudinary").v2;

const CLOUDINARY_CLOUD_NAME = defineString("CLOUDINARY_CLOUD_NAME");
const CLOUDINARY_API_KEY = defineSecret("CLOUDINARY_API_KEY");
const CLOUDINARY_API_SECRET = defineSecret("CLOUDINARY_API_SECRET");

exports.createMediaUploadSignature = onCall(
  {
    secrets: [CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Sign in before uploading media."
      );
    }

    const cloudName = CLOUDINARY_CLOUD_NAME.value();
    const apiKey = CLOUDINARY_API_KEY.value();
    const apiSecret = CLOUDINARY_API_SECRET.value();

    if (!cloudName || !apiKey || !apiSecret) {
      throw new HttpsError(
        "failed-precondition",
        "Cloudinary is not configured."
      );
    }

    const timestamp = Math.floor(Date.now() / 1000);
    const folder = `restaurant-app/${request.auth.uid}`;

    const paramsToSign = {
      folder,
      timestamp,
    };

    const signature = cloudinary.utils.api_sign_request(
      paramsToSign,
      apiSecret
    );

    return {
      cloudName,
      apiKey,
      timestamp,
      folder,
      signature,
    };
  }
);
