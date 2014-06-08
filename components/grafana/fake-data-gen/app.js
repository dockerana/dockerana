var graphite = require('graphite');
var client = graphite.createClient('plaintext://localhost:2003/');
var SDC = new require('statsd-client');
var sdc = new SDC({host: 'localhost'});
var counter = 1000;

setInterval(function() {

	counter += Math.random() * 10 - 5;

	var metrics = { highres: { test: counter } };

	sdc.increment('prod.apps.myfake.counter', counter); // Increment by one.
	sdc.increment('test.apps.myfake.counter', counter); // Increment by one.
	sdc.timing('prod.apps.myfake.timer', counter + (Math.random() * 100) - 50); // Calculates time diff

	client.write(metrics, function(err) {
	  if (err) {
	  	console.log('failed to write to graphite');
	  }
	});

}, 1000);
