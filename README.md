# openflameo
Open-source part of our webApp Flameo, a dynamic provider of commerce solutions.  

## How to launch openflameo  
The basic requirements to run the application are the following:
1. Have flutter installed. Info about flutter and how to install it can be found in [Flutter's website](https://flutter.dev/).
2. Have a firebase account. All the info can be found in [Firebase's website](https://firebase.google.com).
3. The recommended IDE is vscode. Flutter is well integrated in it and provides a helpful linter when working in Dart.
4. Follow the steps to initialize the Firebase for a flutter repository in the firebase documentation. Both firebase firestore and firebase storage are used in openflameo.
5. In order to launch the application you need to load one of the configurations in the config folder. In order to do that, replace `__config__.json` with one of the files in the config folder (`local.json` is used for debugging).