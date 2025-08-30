# ForgeFilter - Auction House Filter for Forged Items

A lightweight addon that helps you quickly find and filter Titanforged, Warforged, and other special items in the Auction House for World of Warcraft 3.3.5a.

## Requirements
- World of Warcraft 3.3.5a
- Custom server with Titanforged/Warforged items (not compatible with standard WotLK servers)
- LibSharedMedia-3.0 (optional, for additional fonts)

## Features
- Quickly filters and displays Titanforged, Warforged, Lightforged, and Mythic items in the Auction House
- Customizable window width and position
- Font customization (size, style, and outline)
- Simple and intuitive interface that integrates with the default Auction House
- Shows item levels and special properties at a glance
- Right-click context menu for quick actions
- Enhanced Options Button: Wider, displays 'Options' text, and features a subtle text highlight on mouseover.
- Improved Item Highlighting: Filtered items now display a subtle background 'fog' effect on mouseover for better visibility.

## Usage
1. Open the Auction House
2. Click the "Search" button to perform a normal search
3. ForgeFilter will automatically filter and display only the special items based on your settings
4. Use the options panel to customize which item types to show/hide

### Right-Click Menu
Right-click any item in the results to access these options:
- **Buyout**: Purchase the item immediately
- **Bid**: Place a bid on the item
- **Search for Item**: Search the Auction House for similar items
- **Item Link**: Generate a clickable link in chat
- **Report as Invalid**: Flag an item that shouldn\'t be in the results

## Configuration
Access the options by typing `/ff` or through the standard Interface Options panel.

### Filters Tab
- **Show Titanforged**: Toggle display of Titanforged items
- **Show Warforged**: Toggle display of Warforged items
- **Show Lightforged**: Toggle display of Lightforged items
- **Show Mythic**: Toggle display of Mythic items

### Display Tab
- **Price Format**: Customize how prices are displayed
  - Show Bid Prices: Toggle display of bid prices
  - Show Time Left: Display time remaining for each auction
  - Hide Silver
  - Hide Copper

### Misc Tab
- **Show Time Remaining**: Display time remaining for each auction
- **Hide Tooltip**: Toggle item tooltips on mouseover for filtered items

### Window Tab
- **Window Width**: Adjust the width of the ForgeFilter window (250-800 pixels)
- **Horizontal Offset**: Adjust the horizontal position of the window relative to the Auction House

### Font Tab
- **Font**: Choose from available fonts (includes system fonts and LibSharedMedia if installed)
- **Font Size**: Adjust the text size (8-32)
- **Outline**: Choose text outline style (None, Outline, Thick Outline, Monochrome Outline)


## Troubleshooting
- If items aren't showing up:
  - Ensure you're on a server that supports Titanforged/Warforged items
  - Verify the item types are enabled in the Filters tab
  - Try reloading your UI with `/reload`
- If the window is too wide/narrow:
  - Adjust the width in the Window tab of the options
- If font changes aren't applying:
  - Ensure you have the selected font installed
  - Try a different font if the current one isn't displaying correctly

## Notes
- This addon is specifically designed for custom 3.3.5a servers that have implemented item modifiers like Titanforged, Warforged, etc.
- It will not find any special items on a standard WotLK server as these mechanics were not part of the original game.
- For best results, install LibSharedMedia-3.0 to access additional fonts

## Credits
- Addon by Xayia. Designed to be simple, reliable and configurable filtering forged and/or mythic items.
