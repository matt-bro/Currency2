# Currency Converter

### Description
Dear Developer, here you will find my implementation of the coding challenge.
It is hard to explain my thought process in a readme, so I hope we will have the chance to have some discussions :)

### How to use
Tested with
- XCode 12.3
- Swift 5.3

No dependencies, the project should just run.


### Features
- Offline ready
- Shows image for currency if available
- Appends the correct currency sign (figures out the currenc sign from currency code e.g $, € etc.)
- Localized UI (English, German, Japanese)
- Light & Dark Mode
- Input localization (understands that numbers in german are written 10,00 however english as 10.00)


### Screenshots
Under the folder 'Screenshots' you can find screenhots where you can see the app in light/dark mode and other language.

### Architecture/Technology Choices
- MVVM
- Swift Combine
- UIKit
- Storyboard

### Unit Testing
I made some unit tests for the CurrencyListViewModel and some basic conversion check in CurrencyTests

### Considerations
- Storyboards - Due to time constraints I have used one storyboard and regular segues. In real projects I would either use a lot of seperated storyboards or generally setup the UI completely in code.

### References
Country flags - https://github.com/transferwise/currency-flags

### Functional Requirements:
- [x] Exchange rates must be fetched from: https://currencylayer.com/documentation  
- [x] Use free API Access Key for using the API
- [x] User must be able to select a currency from a list of currencies provided by the API(for currencies that are not available, convert them on the app side. When converting, floating-point error is accpetable)
- [x] User must be able to enter desired amount for selected currency
- [x] User should then see a list of exchange rates for the selected currency
- [x] Rates should be persisted locally and refreshed no more frequently than every 30 minutes (to limit bandwidth usage)
- [x] Write unit testing

