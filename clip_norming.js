// ############################## Helper functions ##############################

// Shows slides. We're using jQuery here - the **$** is the jQuery selector function, which takes as input either a DOM element or a CSS selector string.
function showSlide(id) {
  // Hide all slides
  $(".slide").hide();
  // Show just the slide we want to show
  $("#" + id).show();
}

// Get random integers.
// When called with no arguments, it returns either 0 or 1. When called with one argument, *a*, it returns a number in {*0, 1, ..., a-1*}. When called with two arguments, *a* and *b*, returns a random value in {*a*, *a + 1*, ... , *b*}.
function random(a, b) {
  if (typeof b == "undefined") {
    a = a || 2;
    return Math.floor(Math.random() * a);
  } else {
    return Math.floor(Math.random() * (b - a + 1)) + a;
  }
}

// Add a random selection function to all arrays (e.g., <code>[4,8,7].random()</code> could return 4, 8, or 7). This is useful for condition randomization.
Array.prototype.random = function() {
  return this[random(this.length)];
}

// shuffle function - from stackoverflow?
// shuffle ordering of argument array -- are we missing a parenthesis?
function shuffle(a) {
  var o = [];

  for (var i = 0; i < a.length; i++) {
    o[i] = a[i];
  }

  for (var j, x, i = o.length; i; j = parseInt(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
  return o;
}


// ## Configuration settings #########################

var files = ["finalADS1new.wav","finalADS5new.wav","finalIDS1new.wav", "finalIDS5new.wav","finalADS2new.wav","finalADS6new.wav","finalIDS2new.wav","finalIDS6new.wav","finalADS3new.wav","finalADS7new.wav","finalIDS3new.wav", "finalIDS7new.wav","finalADS4new.wav","finalADS8new.wav","finalIDS8new.wav"];

//####  CONDITIONS

// 1. Degree of noise in the stimuli (unfiltered). We have already done a "first pass" exclusion based on noise in the sample (and Robin will exclude any additional ones she finds), so there shouldn't be much noise, but so far we are including samples that have some "minimal" noise like a slight rustling. So it would be good to get some additional data on noisiness to select the "best" samples.
//
// 2. Degree of IDS-ness (filtered). This should be a 5- or 7-point Likert rating on a question like "How much does this sound like it was spoken to an infant or child?" from "Definitely spoken to an infant or a child" to "Definitely spoken to an adult". The stimuli HAVE to be low-pass filtered as we want the judgement to be made based on acoustic chars, not content.
//
// 3. Affect (filtered). How happy/sad does it sound? Again should be done on filtered speech so they are judging based on acoustic chars.
//
// 4. Naturalness (unfiltered). Particularly in light of the concerns expressed by the larger group about the ADS samples, this would be a rating of how "natural" or "comfortable" the speaker sounds.
//
// 5. "Accent" (unfiltered). Does the speaker have an accent? (to the rater) This is to get a sense about the extent to which the clips will do a good job of sounding nativelike across at least the North American labs.

var conditions = [{
  name: 'idsness',
  instructions: 'The specific question we are interested in here is <b>whether these clips sound like they were spoken to an adult or to a baby or young child</b>. Some of them were spoken to adults and others were spoken to babies or children, and we would like to know whether people can tell which is which. We will ask you to rate the clips from 1 - 7, choosing 1 if the clip contains sentences that were definitely spoken to an adult and 7 if the clip contains sentences that were definitely spoken to a baby/young child.',
  question: 'Does this clip sound like it was being spoken to an adult or to a baby or young child?',
  low_answer: 'Definitely spoken to an adult',
  high_answer: 'Definitely spoken to a baby/young child',
  directory: 'clips/'
}, {
  name: 'naturalness',
  instructions: 'The specific question we are interested in here is <b>how natural the clip sounds</b>. Some clips may sound like they are being spoken by someone who is comfortably interacting with a child or an adult. Others may sound artificial or awkward, like they are being spoken by a bad actor or the person speaking is uncomfortable with the situation. We will ask you to rate clips from 1 - 7, choosing 1 if the speaker sounds very unnatural and 7 if they sound very natural, comfortable, and normal.',
  question: 'Does this clip sound like the speaker is comfortable and in a normal environment (interacting with a child OR adult), or like the speaker is awkward or artificial? How natural-sounding is this clip?',
  low_answer: 'Very unnatural',
  high_answer: 'Very natural',
  directory: 'clips/'
}]

var condition = conditions.random();

// set up filenames array
var filenames = shuffle(files);

filenames.push("../choose_1.wav")
filenames.push("../choose_4.wav")
filenames.push("../choose_7.wav")

var numTrialsExperiment = filenames.length;

var audio_played = false;

// Show the instructions slide -- this is what we want subjects to see first.
showSlide("instructions");

// ############################## The main event ##############################
var experiment = {

  // The object to be submitted.
  data: {
    condition: condition.name,
    filename: [],
    rating: [],
    ladder: [],
    age: [],
    gender: [],
    education: [],
		region: [],
    homelang: [],
    ethnicity: [],
    race: [],
    children: [],
    childAgeYoung: [],
    childAgeOld: [],
    expt_aim: [],
    expt_gen: [],
  },

  // end the experiment
  end: function() {
    showSlide("finished");
    setTimeout(function() {
      turk.submit(experiment.data)
    }, 1500);
  },

  // LOG RESPONSE
  log_response: function() {

    var response_logged = false;

    //Array of radio buttons
    var radio = document.getElementsByName("judgment");

    // Loop through radio buttons
    for (i = 0; i < radio.length; i++) {
      if (radio[i].checked) {
				var response_value = radio[i].value;
        response_logged = true;
      }
    }

    // now deal with going next if audio has played and there is a response.
    if (response_logged & audio_played) {
      nextButton.blur();

      // uncheck radio buttons
      for (i = 0; i < radio.length; i++) {
        radio[i].checked = false;
      }

			audio_played = false;
			experiment.data.rating.push(response_value);
      experiment.next();

    } else if (audio_played) {
      $("#testMessage").html('<font color="red">' +
        'Please make a response!' +
        '</font>');
    } else if (response_logged) {
			$("#testMessage").html('<font color="red">' +
				'Please listen to the whole clip before responding!' +
				'</font>');
		} else {
			$("#testMessage").html('<font color="red">' +
				'Please listen to the whole clip and then make a response!' +
				'</font>');
		}
  },

  // specific instructions
  instructions: function() {
    showSlide("specific_instructions"); //display slide
    $("#instructions_text").html(condition.instructions); //add sentence to html
  },

  // The work horse of the sequence - what to do on every trial.
  next: function() {

    // Allow experiment to start if it's a turk worker OR if it's a test run
    if (window.self == window.top | turk.workerId.length > 0) {

      $("#progress").attr("style", "width:" +
        String(100 * (1 - (filenames.length) / numTrialsExperiment)) + "%")

      //style="width:progressTotal%"

      // Get the current trial - <code>shift()</code> removes the first element
      // select from our scales array and stop exp after we've exhausted all the domains
      var this_file = filenames.shift();

      //If the current trial is undefined, call the end function.
      if (typeof this_file == "undefined") {
        return experiment.debriefing();
      }

      showSlide("norm_slide"); //display slide
      $("#question").html(condition.question); //add sentence to html
      $("#low_answer").html(condition.low_answer); //add sentence to html
      $("#high_answer").html(condition.high_answer); //add sentence to html

      var audio = document.getElementById('audio');
      // var sourceOgg=document.getElementById('player');
      var sourceMp3 = document.getElementById('audio');

      sourceMp3.src = 'wavs/' + condition.directory + this_file;

      audio.load(); //just start buffering (preload)
      // audio.play(); //start playingvar audio = document.getElementById('audio');

      // log the file for each trial
      experiment.data.filename.push(this_file);
    }
  },


  //	go to debriefing slide
  debriefing: function() {
    showSlide("debriefing");
  },


  // submitcomments function
  submit_comments: function() {

    var races = document.getElementsByName("race");

    // Loop through race buttons
    for (i = 0; i < races.length; i++) {
      if (races[i].checked) {
        experiment.data.race.push(races[i].value);
      }
    }
    // experiment.data.ladder.push(document.getElementById("ladder").value);
    experiment.data.age.push(document.getElementById("age").value);
    experiment.data.gender.push(document.getElementById("gender").value);
    experiment.data.education.push(document.getElementById("education").value);
    experiment.data.region.push(document.getElementById("region").value);    experiment.data.homelang.push(document.getElementById("homelang").value);
    experiment.data.ethnicity.push(document.getElementById("ethnicity").value);
    experiment.data.children.push(document.getElementById("children").value);
    experiment.data.childAgeYoung.push(document.getElementById("youngestAge").value);
    experiment.data.childAgeOld.push(document.getElementById("oldestAge").value);
    experiment.data.expt_aim.push(document.getElementById("expthoughts").value);
    experiment.data.expt_gen.push(document.getElementById("expcomments").value);
    experiment.end();
  }
}
