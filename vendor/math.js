(function(undefined) {
  if (Math.sum === undefined) {
    Math.sum = function() {
      sum = 0;
      Array.prototype.forEach.call(arguments, function(v) { sum += v; });
      return sum;
    };
  }
  if (Math.avg === undefined) {
    Math.avg = function() {
      if (arguments.length === 0) return 0;
      return Math.sum.apply(null, arguments) / arguments.length;
    }
  }
})();

