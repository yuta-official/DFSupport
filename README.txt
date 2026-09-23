DFSupport flat upload package

GalaxyからGitHubへアップロードするファイルは、すべてこのフォルダ直下にあります。
フォルダごとのアップロードは不要です。

通常ファイル:
- main.dart
- pubspec.yaml
- AndroidManifest.xml
- MainActivity.kt
- NotificationStore.kt
- DFNotificationListener.kt

build.ymlだけはGitHub Actionsの仕様上、.github/workflows/build.yml として登録します。
