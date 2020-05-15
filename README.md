# iOS App Template

Template of the new iOS App.

## Dependencies

  - [Homebrew](https://brew.sh/)
  - [Xcodegen](https://github.com/yonaskolb/XcodeGen)
  - [ios-deploy](https://github.com/ios-control/ios-deploy)

## Usage

Use script `generate.sh` to create new empty project:

    ./generate.sh all --path ~/ --name TestApp --bundle-prefix com.noname --team-id SOME0ID

This will create new folder "TestApp" inside yout home folder, that will
look like this:

    $ tree ~/TestApp
    /Users/anton/tmp/generate/TestApp
    ├── Brewfile
    ├── Makefile
    ├── Sources
    │   ├── AppDelegate.swift
    │   ├── Assets.xcassets
    │   │   ├── AppIcon.appiconset
    │   │   │   └── Contents.json
    │   │   └── Contents.json
    │   ├── Base.lproj
    │   │   ├── LaunchScreen.storyboard
    │   │   └── Main.storyboard
    │   └── ViewController.swift
    ├── project.yml
    └── utils
        └── run.sh

Details about the script can be explored with `help` subcommand:

    $ ./generate.sh help
    Usage: ./generate.sh <all|makefile|project|help> <options>
           ./generate.sh all \
                            --path </where/to/store/new/app> \
                            --bundle-prefix <some.company> \
                            --name <NewApp> \
                            --team-id <XXXXXX>
           ./generate.sh makefile --name <NewApp>
           ./generate.sh project \
                                --path </where/to/store/new/app> \
                                --bundle-prefix <some.company> \
                                --name <NewApp> \
                                --team-id <XXXXXX>
