// Generated by CoffeeScript 1.4.0
(function() {

  exports.create = function(page_list, death_callback) {
    var HackScan, fs, hack_scan, system;
    fs = require("fs");
    system = require("system");
    HackScan = (function() {

      HackScan.prototype.page_list = page_list;

      HackScan.prototype.beatingHeart = null;

      HackScan.prototype.loadCount = 0;

      HackScan.prototype.pages = [];

      HackScan.prototype.busy_frazzling = false;

      HackScan.prototype.imports_output = [];

      HackScan.prototype.hierarchies = {};

      HackScan.prototype.rooted = {};

      HackScan.prototype.outputs = {};

      HackScan.prototype.processed_count = 0;

      function HackScan(path) {
        var death, pulse, _this;
        console.log("Constructing...");
        _this = this;
        pulse = function() {
          return _this.CheckPulse();
        };
        death = function() {
          var k, p, _ref;
          console.log("ASDASDASDAS");
          _ref = _this.hierarchies;
          for (p in _ref) {
            k = _ref[p];
            console.log(p + " " + k);
          }
          return death_callback(_this);
        };
        console.log(page_list);
        this.beatingHeart = require("../BeatingHeart").create(pulse, death);
        this.LoadPages();
      }

      HackScan.prototype.CheckPulse = function() {
        if (this.buzy_frazzling) {
          console.write(".");
        }
        return !this.LastBreath();
      };

      HackScan.prototype.LastBreath = function() {
        return this.processed_count === this.page_list.length;
      };

      HackScan.prototype.LoadPages = function() {
        var page, _i, _len, _ref, _results;
        _ref = this.page_list;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          page = _ref[_i];
          _results.push(this.LoadPage(page));
        }
        return _results;
      };

      HackScan.prototype.LoadPage = function(page) {
        var webpage, _this;
        _this = this;
        webpage = require('webpage').create();
        webpage.settings.userAgent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.71 Safari/537.36';
        this.pages.push(webpage);
        console.log("Loading " + page);
        return webpage.open(page, function(status) {
          console.log("Loaded " + page);
          _this.Process(webpage, page);
          return _this.loadCount++;
        });
      };

      HackScan.prototype.Process = function(webpage, identifier) {
        webpage.injectJs('../jquery-2.1.0.min.js');
        this.outputs[identifier] = [];
        this.hierarchies[identifier] = webpage.evaluate("function () {\n	return $(\"body\").html();\n}");
        return this.processed_count++;
      };

      return HackScan;

    })();
    return hack_scan = new HackScan();
  };

}).call(this);
