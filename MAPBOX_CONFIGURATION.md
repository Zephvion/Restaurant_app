\# Mapbox Environment Configuration



\## Overview



The application supports separate Mapbox public access tokens for Development, Staging, and Production.



Tokens must never be hardcoded or committed to Git.



\## Build configurations



\### Staging



```bash

flutter build apk --release \\

&#x20; --dart-define=APP\_ENV=staging \\

&#x20; --dart-define=MAPBOX\_STAGING\_TOKEN=YOUR\_STAGING\_PUBLIC\_TOKEN

```



\### Production



```bash

flutter build apk --release \\

&#x20; --dart-define=APP\_ENV=production \\

&#x20; --dart-define=MAPBOX\_PRODUCTION\_TOKEN=YOUR\_PRODUCTION\_PUBLIC\_TOKEN

```



\### Development



```bash

flutter run

```



\## Security requirements



\- Use separate Mapbox public tokens for Staging and Production.

\- Use public tokens with only the required scopes.

\- Apply URL restrictions where supported by the Mapbox token configuration.

\- Store tokens in approved CI/CD secret storage.

\- Never commit real tokens, private keys, or credentials.

\- Rotate exposed tokens immediately.



\## Verification



The configuration is implemented in `lib/core/config/mapbox\_config.dart`.



Run:



```bash

flutter analyze lib/core/config/mapbox\_config.dart

```



Real environment verification requires company-provided Mapbox tokens and access to the relevant deployment environments.
