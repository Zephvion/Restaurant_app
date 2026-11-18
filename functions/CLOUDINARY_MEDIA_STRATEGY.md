

\# Cloudinary Media Strategy



\## 1. Overview



Cloudinary is the centralized media storage and delivery provider for the Restaurant App.



It handles restaurant images, food images, profile pictures and other application media.



\## 2. Environment Configuration



Use separate Cloudinary configuration for Development, Staging and Production.



Required configuration:



\- CLOUDINARY\_CLOUD\_NAME

\- CLOUDINARY\_API\_KEY

\- CLOUDINARY\_API\_SECRET



The API secret must only be stored in Firebase Secret Manager.

Never commit real credentials to Git.



\## 3. Secure Upload Strategy



1\. User authenticates with Firebase Authentication.

2\. Flutter requests an upload signature from `createMediaUploadSignature`.

3\. Firebase Cloud Functions validates the authenticated user.

4\. Backend generates a Cloudinary upload signature.

5\. Flutter uploads the file directly to Cloudinary using the returned signature.

6\. Cloudinary returns the uploaded media details.



The Cloudinary API secret never reaches the Flutter application.



\## 4. Media Organization



Uploads are organized by authenticated user:



`restaurant-app/{firebase-user-id}`



Use separate Cloudinary configurations or accounts for Staging and Production.



\## 5. Firestore Media References



Store media metadata and references, not binary image files.



Recommended fields:



\- `publicId`: Cloudinary public ID

\- `secureUrl`: HTTPS delivery URL

\- `resourceType`: image or video

\- `format`: file format

\- `width`: image width

\- `height`: image height

\- `uploadedAt`: upload timestamp

\- `uploadedBy`: Firebase user ID



Use `publicId` as the stable reference for future transformations or deletion. Avoid relying only on the delivery URL.



\## 6. Security Requirements



\- Require Firebase authentication for signing requests.

\- Keep API secrets in Firebase Secret Manager.

\- Never expose the API secret in Flutter or source control.

\- Restrict upload folders and allowed formats.

\- Apply file size limits and upload rate limits.

\- Validate ownership before deleting or modifying media.

\- Use HTTPS delivery URLs.

\- Configure separate Staging and Production credentials.



\## 7. Deployment Configuration



Set the Cloudinary cloud name as a Firebase Functions parameter and configure API credentials as Firebase secrets.



Example:



`firebase functions:secrets:set CLOUDINARY\_API\_KEY`



`firebase functions:secrets:set CLOUDINARY\_API\_SECRET`



Do not enter real credentials into source files or Git commits.



\## 8. Verification



Before production use:


\- Configure company-provided Cloudinary credentials.

\- Verify authenticated signature generation.

\- Test successful and rejected uploads.

\- Verify media references are stored correctly.

\- Verify Staging and Production use separate Cloudinary configurations.

\- Confirm unauthorized users cannot request upload signatures.
