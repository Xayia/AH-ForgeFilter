# ForgeFilter - Auction House Filter for Titanforged Items

A lightweight addon that helps you quickly find and filter Titanforged, Warforged, and other special items in the Auction House for World of Warcraft 3.3.5a.

## Requirements
- World of Warcraft 3.3.5a
- Custom server with Titanforged/Warforged items (not compatible with standard WotLK servers)

## Features
- Quickly filters and displays Titanforged, Warforged, Lightforged, and Mythic items in the Auction House
- Customizable window width to fit your UI layout
- Simple and intuitive interface that integrates with the default Auction House
- Shows item levels and special properties at a glance

## Usage
1. Open the Auction House
2. Click the "Search" button to perform a normal search
3. ForgeFilter will automatically filter and display only the special items based on your settings
4. Use the options panel to customize which item types to show/hide

## Configuration
Access the options by typing `/ff` or through the standard Interface Options panel.

### Filters Tab
- **Show Titanforged**: Toggle display of Titanforged items
- **Show Warforged**: Toggle display of Warforged items
- **Show Lightforged**: Toggle display of Lightforged items
- **Show Mythic**: Toggle display of Mythic items

### Display Tab
- **Show Time Left**: Display time remaining for each auction
- **Show Bid**: Display current bid information
- **Price Format**: Customize how prices are displayed
  - Hide Silver
  - Hide Copper

### Window Tab
- **Window Width**: Adjust the width of the ForgeFilter window (250-800 pixels)

## Troubleshooting
- If items aren't showing up:
  - Ensure you're on a server that supports Titanforged/Warforged items
  - Verify the item types are enabled in the Filters tab
  - Try reloading your UI with `/reload`
- If the window is too wide/narrow:
  - Adjust the width in the Window tab of the options

## Notes
- This addon is specifically designed for custom 3.3.5a servers that have implemented item modifiers like Titanforged, Warforged, etc.
- It will not find any special items on a standard WotLK server as these mechanics were not part of the original game.

## Credits
- Addon by Xayia. Designed to be simple, reliable and configurable filtering forged and/or mythic items.
