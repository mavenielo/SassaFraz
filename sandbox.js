// Generated by CoffeeScript 1.4.0
(function() {
  var config_path, page, sassaFraz, system;

  page = require('webpage').create();

  system = require('system');

  if (system.args.length !== 5) {
    console.log("Usage: sandbox.js /path/to/fraz/file");
    console.log(JSON.stringify(system.args));
    phantom.exit();
  }

  config_path = system.args[4];

  console.log("\n" + config_path);

  sassaFraz = require("./SassaFraz").create(config_path, function(fraz) {
    console.log("All pages processed.");
    fraz.SaveToFiles();
    return phantom.exit();
  });

}).call(this);
