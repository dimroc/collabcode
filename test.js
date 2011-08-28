// mailer = require("mailer");
mailer = require("emailjs");

server = mailer.server.connect({
  user: 'dimroc@gmail.com',
  password: 'Dim-5stuff',
  host: "smtp.gmail.com",
  ssl: true
});

server.send({
  text: "i hope this works",
  from: "dimroc@gmail.com",
  to: "dimroc@gmail.com",
  subject: "testing emailjs"
}, function(err, message) { console.log(err || message); });


// attempt to smtp mail with sendgrid.
server = mailer.server.connect({
  user: 'app820434@heroku.com',
  password: '69720811bbfb6510c7',
  host: "smtp.sendgrid.net",
  ssl: true
});

server.send({
  text: "i hope this works",
  from:  '[Collab][Code] <app820434@heroku.com>',
  to: "dimroc@gmail.com",
  subject: "testing emailjs"
}, function(err, message) { console.log(err || message); });


