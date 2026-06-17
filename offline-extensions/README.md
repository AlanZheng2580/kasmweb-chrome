# Offline Chrome Extensions

Place CRX files in this directory when extensions must install without internet access.

Example `extensions.json` entry:

```json
{
  "id": "onnfghpihccifgojkpnnncpagjcdbjod",
  "name": "Proxy Switcher and Manager",
  "crx_path": "onnfghpihccifgojkpnnncpagjcdbjod.crx",
  "version": "1.0.0"
}
```

`crx_path` may be relative to this directory or an absolute path inside the image.
The `version` must match the CRX package version.

