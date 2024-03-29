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
