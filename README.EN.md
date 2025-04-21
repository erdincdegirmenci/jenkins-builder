# 🛠️ Jenkins Builder Script

This repository contains a `batch` file developed to trigger Jenkins projects via the command line and monitor build processes.

## 🚀 Features
- Trigger authorized builds using Jenkins API token
- Choose a project from a list (you may need to customize this based on your use case)
- Start builds with parameters (branch, version, obfuscator, etc.)
- Monitor the build status in real-time
- Automatically generate a configuration file (`jenkins-config.bat`)

## 🔧 Usage
1. Run the `jenkins-builder.bat` file.
2. On the first run, enter your username and API token to create the `jenkins-config.bat` file.
3. Choose a project from the list.
4. Enter the necessary parameters and start the build.