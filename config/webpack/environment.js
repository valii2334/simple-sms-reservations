const { environment } = require("@rails/webpacker");

module.exports = environment;

const webpack = require("webpack");
environment.plugins.append(
  "Provide",
  new webpack.ProvidePlugin({
    $: "jquery",
    jQuery: "jquery",
    jquery: "jquery",
    Popper: ["popper.js", "default"],
    moment: "moment/moment"
  })
);
