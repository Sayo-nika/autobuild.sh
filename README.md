# autobuild.sh

A simple nifty tool to build your mod in just one go!

## How to install

Simply `git pull` and run it. It's easy.

Or, if you don't have git:

```sh

wget https://raw.githubusercontent.com/Sayo-nika/autobuild.sh/master/autobuild.sh && bash autobuild.sh

````

## Using the CLI

To start the script in interactive mode, just run `./autobuild.sh`. 

However, if you want to use arguments for non-interactive usage, like CIs, These are the available options

```
./autobuild.sh [-d <DIRECTORY> | -h]

Builds a mod by creating a build/ folder and compiles releases there.
When no arguments are present, the script starts in interactive mode.
However, for non-interactive usage, the following is accepted as a argument:

-d <DIRECTORY>      The Directory of the mod to build.
-h                  Print this help dialogue.
```

## Contributing

If you think you can make this better, send us a PR! We love you.

## Disclaimer

The following source code is licensed under MIT. Copyright 2018&copy; The Sayonika Project Authors

This script complies with the Team Salvato IP Guidelines.
