## To Build jar file

### Aattach android.jar first and Build Dex File and generate jar file

javac -source 1.7 -target 1.7 -cp "$ANDROID_HOME"/platforms/android-27/android.jar UniHubServer.java &&
javac -source 1.7 -target 1.7 UniHubServer.java
"$ANDROID_HOME"/build-tools/30.0.3/dx \
 --dex --output classes.dex UniHubServer.class && jar cvf UniHubServer.jar classes.dex && rm UniHubServer.class && rm classes.dex

## To execute in android

adb push UniHubServer.jar /data/local/tmp/
adb shell CLASSPATH=/data/local/tmp/UniHubServer.jar app_process / UniHubServer
