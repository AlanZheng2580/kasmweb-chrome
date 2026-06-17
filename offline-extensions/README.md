# Offline Chrome Extensions

Place CRX files in this directory when extensions must install without internet access.

Each CRX needs a matching Chrome update manifest under `updates/`.

Example `updates/<extension-id>.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<gupdate xmlns="http://www.google.com/update2/response" protocol="2.0">
  <app appid="<extension-id>">
    <updatecheck codebase="file:///opt/kasm/offline-extensions/<extension-id>.crx" version="1.0.0" />
  </app>
</gupdate>
```

The `version` must match the CRX package version. Reference the update manifest from
`chrome-policies/managed/policy.json`. Docker only copies these files into the image; it
does not generate them during build.
