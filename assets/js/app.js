// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import socket from "./socket"
import WaterCooler from "./water_cooler"
import page from "./page"
//Does this get called everytime we change paths? or only when we first come to cooler.chat
WaterCooler.init(socket)

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import { EmojiButton } from '@joeattardi/emoji-button';

const picker = new EmojiButton();
const reactionButtons = document.getElementsByClassName('add-reaction-button');
const chatLink = document.getElementById('new-chat-link')

picker.on('emoji', selection => {
  // reaction_button.innerHTML = selection.emoji;
});

for (var i = 0; i < reactionButtons.length; i++) {
  reactionButtons[i].addEventListener('click', (e) => {
    picker.togglePicker(e.currentTarget)
  });
}
