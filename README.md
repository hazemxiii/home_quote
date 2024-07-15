# home_quote

# The app creates a home widget that contains a message the user types. User can create multiple texts and choose from them, later the app traverse randomly on one of them to display

## Functions

- [Get data from perfs](#get-data-from-prefs)
- [Select/Deselect quote](#selectdeselect-quote)
- [Delete quote](#delete-quote)
- [Add quote](#add-quote)
- [Toggle multiple selection](#toggle-multi-selection)
- [Toggle transparent background](#toggle-transparent-background)
- [Predefined colors](#predefined-colors)
- [Change text & background Colors](#change-text--background-colors)
- [Select all](#select-all)
- [Import/Export files](#importexport)

## get data from prefs

- StyleNotifier.loadColors()
- QuotesNotifier.loadData()

## select/deselect quote

- QuotesNotifier.selectQuote()

## delete quote

- QuotesNotifier.deleteQuote()

## add quote

- QuotesNotifier.addQuote()

## toggle multi selection

- QuotesNotifier.toggleIsMulti()

## toggle transparent background

- StyleNotifier.toggleTransparent()

## predefined colors

- class \_ColorPaletteState List colors

## change text & background colors

- StyleNotifier.setTextColor()
- StyleNotifier.setColor()

## select all

- QuotesNotifier.selectAll()

## import/export

- QuotesNotifier.setDataFromFile()
