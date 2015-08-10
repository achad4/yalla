require("cloud/app.js");

var twilioAccountSid = 'ACf850e90f6583c084a56e177ced9a35b6';
var twilioAuthToken = '927084684d6ff9f4daf5d68784002ed4';
var twilioPhoneNumber = '9255237929';
var secretPasswordToken = 'password';

var language = "en";
var languages = ["en", "es", "ja", "kr"];

var twilio = require('twilio')(twilioAccountSid, twilioAuthToken);

Parse.Cloud.define("sendCode", function(req, res) {
	var phoneNumber = req.params.phoneNumber;
	phoneNumber = phoneNumber.replace(/\D/g, '');

	var lang = req.params.language;
  if(lang !== undefined && languages.indexOf(lang) != -1) {
		language = lang;
	}

	if (!phoneNumber || (phoneNumber.length != 10 && phoneNumber.length != 11)) return res.error('Invalid Parameters');
	Parse.Cloud.useMasterKey();
	var query = new Parse.Query(Parse.User);
	query.equalTo('username', phoneNumber + "");
	query.first().then(function(result) {
		var min = 1000; var max = 9999;
		var num = Math.floor(Math.random() * (max - min + 1)) + min;

		if (result) {
			result.setPassword(secretPasswordToken + num);
			result.set("language", language);
			result.save().then(function() {
				return sendCodeSms(phoneNumber, num, language);
			}).then(function() {
				res.success();
			}, function(err) {
				res.error(err);
			});
		} else {
			var user = new Parse.User();
			user.setUsername(phoneNumber);
			user.setPassword(secretPasswordToken + num);
			user.set("language", language);
			user.setACL({});
			user.save().then(function(a) {
				return sendCodeSms(phoneNumber, num, language);
			}).then(function() {
				res.success();
			}, function(err) {
				res.error(err);
			});
		}
	}, function (err) {
		res.error(err);
	});
});

Parse.Cloud.define("logIn", function(req, res) {
	Parse.Cloud.useMasterKey();

	var phoneNumber = req.params.phoneNumber;
	var userName = req.params.userName;
	phoneNumber = phoneNumber.replace(/\D/g, '');

	if (userName && phoneNumber && req.params.codeEntry) {
		Parse.User.logIn(phoneNumber, secretPasswordToken + req.params.codeEntry).then(function (user) {
			user.set("alias", userName);
			user.save(null, {
				success: function(user) {
			    	console.log('New object updated with objectId: ' + user.id);
			  	},
				error: function(user, error) {
					console.log('Failed to update new object, with error code: ' + error.message);
				}
			});
			res.success(user._sessionToken);
		}, function (err) {
			res.error(err);
		});
	} else {
		res.error('Invalid parameters.');
	}
});

function sendCodeSms(phoneNumber, code, language) {
	var prefix = "+1";
	if(typeof language !== undefined && language == "ja") {
		prefix = "+81";
	} else if (typeof language !== undefined && language == "kr") {
		prefix = "+82";
		phoneNumber = phoneNumber.substring(1);
	}

	var promise = new Parse.Promise();
	twilio.sendSms({
		to: prefix + phoneNumber.replace(/\D/g, ''),
		from: twilioPhoneNumber.replace(/\D/g, ''),
		body: 'Your login code for yalla is ' + code
	}, function(err, responseData) {
		if (err) {
			console.log(err);
			promise.reject(err.message);
		} else {
			promise.resolve();
		}
	});
	return promise;
}


Parse.Cloud.job("deleteConversations", function(request, status) {
                 
                Parse.Cloud.useMasterKey();
                 
                var ts = Math.round(new Date().getTime() / 1000);
                var tsYesterday = ts - (24 * 3600);
                var dateYesterday = new Date(tsYesterday*1000);
                 
                // Delete conversations not updated within 24 hours
                var convoQuery = new Parse.Query("Conversation");
                 
                convoQuery.lessThan("updatedAt", dateYesterday);
                 
                convoQuery.find({
                                success: function(result) {
                                for(var i=0; i<result.length; i++) {
                                result[i].destroy({
                                                  success: function(object) {
                                                  status.success("Delete job completed");
                                                  alert('Delete Successful');
                                                  },
                                                  error: function(object, error) {
                                                  status.error("Delete error :" + error);
                                                  alert('Delete failed');
                                                  }
                                                  });
                                }
                                status.success("Delete job completed");
                                },
                                 
                                error: function(error) {
                                status.error("Error in delete query error: " + error);
                                alert('Error in delete query');
                                }
                                });
                 
  });

Parse.Cloud.job("deleteMessages", function(request, status) {
                 
                Parse.Cloud.useMasterKey();
                 
                var ts = Math.round(new Date().getTime() / 1000);
                var tsHour = ts - (3600);
                var dateHour = new Date(tsHour*1000);
                 
                // Delete messages after 1 hour
                var convoQuery = new Parse.Query("Message");
                 
                convoQuery.lessThan("updatedAt", dateHour);
                 
                convoQuery.find({
                                success: function(result) {
                                for(var i=0; i<result.length; i++) {
                                result[i].destroy({
                                                  success: function(object) {
                                                  status.success("Delete job completed");
                                                  alert('Delete Successful');
                                                  },
                                                  error: function(object, error) {
                                                  status.error("Delete error :" + error);
                                                  alert('Delete failed');
                                                  }
                                                  });
                                }
                                status.success("Delete job completed");
                                },
                                 
                                error: function(error) {
                                status.error("Error in delete query error: " + error);
                                alert('Error in delete query');
                                }
                                });
                 
  });



