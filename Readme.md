# Currency Converter

### Description
This is a simple currency converter to test combine with uikit and mvvm.
It uses a currency api from currencylayer.com

If you would like to try it you have to input your own api key in Network.swift

The app also comes with old currency data for testing, so you don't need to call the api.

### How to use
Tested with
- XCode 12.3
- Swift 5.3

- iOS 14.3
- iPhone 12 Pro, iPhone 8

No dependencies, the project should just run.


## Features
- Offline ready
- Shows image for currency if available
- Appends the correct currency sign (figures out the currenc sign from currency code e.g $, € etc.)
- Localized UI (English, German, Japanese)
- Light & Dark Mode
- Input localization (understands that numbers in german are written 10,00 however english as 10.00)


## Screenshots
Under the folder 'Screenshots' you can find screenhots where you can see the app in light/dark mode and other language.

## Concept
Some scribbles under Concept

## Architecture/Technology Choices
- MVVM
- Swift Combine
- UIKit
- Storyboard

## Unit Testing
I made some unit tests for the CurrencyListViewModel and some basic conversion check in CurrencyTests



