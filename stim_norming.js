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

var files = ["Baby 1810_112.28785226540757.wav", "Baby 1810_212.33847556642402.wav", "Baby 1810_298.1001772894327.wav", "Baby 1810_341.78370202005016.wav", "Baby 1810_436.785481010318.wav", "Baby 1810_560.8068981305205.wav", "Baby 1810_88.86870410178693.wav", "Baby 2077_113.02363282815345.wav", "Baby 2077_316.3634768658419.wav", "Baby 2077_325.2131190053606.wav", "Baby 2077_369.75832648186525.wav", "Baby 2077_392.63977244181063.wav", "Baby 2077_502.3671442456944.wav", "Baby 2077_542.8901545374738.wav", "Baby 2874_423.9870515300145.wav", "Baby 2874_470.6960809064687.wav", "Baby 2874_492.0910270695727.wav", "Baby 2874_498.20327264845236.wav", "Baby 2874_552.9438134996509.wav", "Baby 2874_585.7648203732617.wav", "Baby 2874_681.2315898452964.wav", "Baby 3314 at 210.265.wav", "Baby 3314 at 248.176.wav", "Baby 3314 at 90.785.wav", "Baby 3912_189.43910293047873.wav", "Baby 3912_233.49077753067155.wav", "Baby 3912_246.0280238700178.wav", "Baby 4_101.46068388606659.wav", "Baby 4_119.15118217078498.wav", "Baby 4_139.08102763398546.wav", "Baby 4_164.8060521942662.wav", "Baby 4_70.21009376493727.wav", "Baby 4_93.3328966173391.wav", "Baby 4510_115.47958435251769.wav", "Baby 4510_132.80257160363274.wav", "Baby 4510_18.858192396783313.wav", "Baby 4510_203.56842214889127.wav", "Baby 4510_222.06275079043385.wav", "Baby 4510_277.39461602176004.wav", "Baby 4510_386.2227425561305.wav", "Baby 4510_413.3546018544898.wav", "Baby 4510_450.81831091701173.wav", "Baby 4547 at 554.549.wav", "Baby 4547 at 646.298.wav", "Baby 4784_115.77902044731665.wav", "Baby 4784_217.32396004850006.wav", "Baby 4784_282.3260484905622.wav", "Baby 4784_329.3687108316608.wav", "Baby 4784_340.76037359632795.wav", "Baby 4784_8.09470456084376.wav", "Baby 4784_82.35264476401137.wav", "Baby 5_105.57700379351351.wav", "Baby 5_130.5774456466338.wav", "Baby 5_157.4031068572158.wav", "Baby 5_65.53872765319125.wav", "ball, Baby 1266_1081.994965918577.wav", "ball, Baby 2077_12.582301715046901.wav", "ball, Baby 2077_30.01383908287438.wav", "ball, Baby 2874_391.0200430191452.wav", "ball, Baby 3214_461.6955604692438.wav", "ball, Baby 3214_464.7267987032388.wav", "ball, Baby 3314 at 104.602.wav", "ball, Baby 3314 at 115.838.wav", "ball, Baby 4510_341.74610580792717.wav", "block, Baby 1810_458.0540644809489.wav", "block, Baby 4_184.73879609345.wav", "cup, Baby 1266_1103.6708312684427.wav", "cup, Baby 2077_442.0700898098337.wav", "cup, Baby 2077_447.12387234854714.wav", "cup, Baby 2874_545.902024470267.wav", "cup, Baby 3214_540.8525468070718.wav", "cup, Baby 3214_548.2954351161833.wav", "cup, Baby 4_152.04239497413855.wav", "cup, Baby 4510_34.38991088014878.wav", "cup, Baby 4547 at 636.615(1).wav", "flag, Baby 2874_412.1850841095442.wav", "flag, Baby 3912_15.037955853329555.wav", "flag, Baby 4_71.73592085823985.wav", "flag, Baby 4784_4.515356306021673.wav", "globe, Baby 1266_1054.4929789006917.wav", "globe, Baby 2077_166.68622689664895.wav", "globe, Baby 2936_636.407159425541.wav", "globe, Baby 3214_666.742110864785.wav", "globe, Baby 4510_335.2411179172068.wav", "shoe, Baby 1810_467.1777833598229.wav", "shoe, Baby 2077_420.39159070410506.wav", "shoe, Baby 2874_479.5476071115915.wav", "shoe, Baby 3214_766.4750928238898.wav", "shoe, Baby 4_134.149755832785.wav", "shoe, Baby 4510_307.403956084694.wav", "sieve, Baby 2077_309.2595749953863.wav", "sieve, Baby 2874_579.8183520434693.wav", "sieve, Baby 2936_653.2693839485118.wav", "sieve, Baby 4547 at 602.277.wav", "sieve, Baby 4547 at 627.465.wav", "sieve, Baby 5_63.51105939873247.wav", "train, Baby 2077_483.6996629498416.wav", "train, Baby 2874_615.358749152172.wav", "train, Baby 3214_709.7436105197614.wav", "train, Baby 3214_747.4731669126435.wav", "train, Baby 4510_381.13749408600387.wav", "whisk, Baby 1810_284.02024489690655.wav", "whisk, Baby 2077_57.12753441367709.wav", "whisk, Baby 2077_98.85615167809891.wav", "whisk, Baby 2874_435.7926817225463.wav", "whisk, Baby 2936_506.30553451466204.wav", "whisk, Baby 3214_514.1518210676982.wav", "whisk, Baby 3314 at 214.515.wav", "whisk, Baby 5_139.08118150122942.wav", "yeast, Baby 1810_129.25098395616675.wav", "yeast, Baby 2077_349.7339051020574.wav", "yeast, Baby 2874_675.6670048027384.wav", "yeast, Baby 3214_620.3920087002338.wav", "yeast, Baby 3214_644.8326586228219.wav", "yeast, Baby 3912_121.11405378347743.wav", "yeast, Baby 4510_190.42389050838185.wav", "yeast, Baby 5_116.95457424694321.wav", "Baby 1266_154.14809393032257.wav", "Baby 1266_162.60786237046568.wav", "Baby 1266_290.9275872076564.wav", "Baby 1266_297.497131311381.wav", "Baby 1266_344.7847490735958.wav", "Baby 1266_386.6540619962722.wav", "Baby 1810_1017.5754052263309.wav", "Baby 1810_1148.7826767146175.wav", "Baby 1810_662.77102273508.wav", "Baby 1810_792.9934263350068.wav", "Baby 1810_880.1674289728155.wav", "Baby 2077_1030.7292597994947.wav", "Baby 2077_14.879063232058567.wav", "Baby 2077_287.0942149788068.wav", "Baby 2077_298.43773570482466.wav", "Baby 2077_377.207911515445.wav", "Baby 2077_486.724412738805.wav", "Baby 2077_543.2879661852369.wav", "Baby 2077_627.1174028986043.wav", "Baby 2077_639.308111816499.wav", "Baby 2077_653.2399541887826.wav", "Baby 2077_681.3154526508381.wav", "Baby 2077_730.1956497211921.wav", "Baby 2077_740.8185060018474.wav", "Baby 2077_787.8539591923895.wav", "Baby 2077_879.5171532966713.wav", "Baby 2077_900.3117780947271.wav", "Baby 2936_144.59510648926303.wav", "Baby 2936_147.46686891933587.wav", "Baby 2936_155.95953433497698.wav", "Baby 2936_192.8653554888671.wav", "Baby 2936_228.4663124964059.wav", "Baby 2936_3.5141170515042672.wav", "Baby 2936_316.2384873069083.wav", "Baby 2936_335.3282845753848.wav", "Baby 2936_406.04803014416336.wav", "Baby 2936_417.8743349932715.wav", "Baby 2936_99.56910174909278.wav", "Baby 3214_81.53152246997749.wav", "Baby 3314 at 568.463.wav", "Baby 4_109.9676936894571.wav", "Baby 4_143.24641872335704.wav", "Baby 4_152.78003996692723.wav", "Baby 4_154.80632070178874.wav", "Baby 4_165.74460165260246.wav", "Baby 4_189.90045545569708.wav", "Baby 4_194.358287668529.wav", "Baby 4_198.62539651017852.wav", "Baby 4_201.6290743132863.wav", "Baby 4_21.772095962819797.wav", "Baby 4_216.9059665246425.wav", "Baby 4_222.11379879288614.wav", "Baby 4_345.6492426006938.wav", "Baby 4_349.12969234141605.wav", "Baby 4_379.93286628504495.wav", "Baby 4_436.27456184312365.wav", "Baby 4_44.73969689114542.wav", "Baby 4_458.45182670125496.wav", "Baby 4_502.7916898800839.wav", "Baby 4_527.5306735604257.wav", "Baby 4_532.1076975332735.wav", "Baby 4_537.4713818314366.wav", "Baby 4_75.07710244926915.wav", "Baby 4510_542.4133794672472.wav", "Baby 4510_579.3790731401354.wav", "Baby 4510_614.102959313815.wav", "Baby 4510_639.5356066570439.wav", "Baby 4510_750.1077485865037.wav", "Baby 4510_836.1680079319436.wav", "Baby 5_104.18135306605845.wav", "Baby 5_169.8693129177112.wav", "Baby 5_172.08192734715217.wav", "Baby 5_188.7230603647254.wav", "Baby 5_193.0114402841952.wav", "Baby 5_202.56565007451687.wav", "Baby 5_208.5120212796304.wav", "Baby 5_231.4298284816723.wav", "Baby 5_236.97966194091387.wav", "Baby 5_349.8681104663433.wav", "Baby 5_450.2031223325161.wav", "Baby 5_60.95494937104302.wav", "Baby 5_89.85002439231228.wav", "ball, Baby 2077_132.31916232186742.wav", "ball, Baby 2936_296.0815847200069.wav", "ball, Baby 3214_155.2472667014158.wav", "ball, Baby 4_16.034320085213878.wav", "ball, Baby 4_36.49519137179645.wav", "ball, Baby 4_58.10583836671947.wav", "ball, Baby 5_379.32423854994346.wav", "ball, Baby 5_65.9595859218018.wav", "block, Baby 4_494.49767506211765.wav", "block, Baby 4784_742.9883388969735(1).wav", "cup, Baby 2077_100.09849529172934.wav", "cup, Baby 2077_107.85705677543913.wav", "cup, Baby 3214_38.59791647608294.wav", "cup, Baby 4_405.8106227338113.wav", "cup, Baby 4547 at 402.557.wav", "cup, Baby 5_101.82931237904873.wav", "cup, Baby 5_126.14468943267546.wav", "flag, Baby 4_231.4823673670105.wav", "globe, Baby 4_146.74887495610417.wav", "shoe, Baby 1266_268.5571572972691.wav", "shoe, Baby 2077_478.73114244939586.wav", "shoe, Baby 2936_435.60356292496397.wav", "shoe, Baby 3214_146.42957350550878.wav", "shoe, Baby 4_102.45853567202916.wav", "shoe, Baby 4_79.6376286981184.wav", "shoe, Baby 4_82.97503226141973.wav", "shoe, Baby 4510_534.6349019034208.wav", "shoe, Baby 4547 at 11.741.wav", "shoe, Baby 4547 at 32.820.wav", "train, Baby 2077_401.6461644731435.wav", "train, Baby 3214_391.50393768367746.wav", "train, Baby 4_269.0538859282394.wav", "train, Baby 4_324.2806594621357.wav", "train, Baby 4_327.592406919837.wav", "train, Baby 4784_699.5693795626885.wav", "whisk, Baby 4_342.74093378124553.wav", "whisk, Baby 4_371.6131959736724.wav", "whisk, Baby 5_314.5604977684141.wav", "yeast, Baby 5_347.82013131422985.wav"];

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
  name: 'noise',
  instructions: 'The specific question we are interested in here is <b>whether there is noise in thse clips</b>, in particular whether they have any background noise that might distract someone who is listening to the speech. We will ask you to rate the level of noise from 1 - 7, with 1 being essentially no noise (many clips might fall into this category) and 7 obvious noise that is very distracting.',
  question: 'Do you hear any background noise that might distract you from listening to the speech? How noisy is this audio clip?',
  low_answer: 'No noise at all',
  high_answer: 'Lots of noise',
  directory: 'normed/'
}, {
  name: 'idsness',
  instructions: 'The specific question we are interested in here is <b>whether these clips sound like they were spoken to an adult or to a baby or young child</b>. Some of them were spoken to adults and others were spoken to babies or children, and we would like to know whether people can tell which is which. We will ask you to rate the clips from 1 - 7, choosing 1 if the clip was definitely spoken to an adult and 7 if the clip was definitely spoken to a baby/young child.',
  question: 'Does this clip sound like it was being spoken to an adult or to a baby or young child?',
  low_answer: 'Definitely spoken to an adult',
  high_answer: 'Definitely spoken to a baby/young child',
  directory: 'filtered/'
}, {
  name: 'affect',
  instructions: 'The specific question we are interested in here is <b>what the emotional tone of the speaker is in each clip</b>. We will ask you to rate the clips from 1 - 7, choosing 1 if the speaker sounds negative (sad, angry, or disgusted) and 7 if the speaker sounds very positive (happy or excited).',
  question: 'How positive or negative does this audio clip sound?',
  low_answer: 'Very negative (sad, angry, or disgusted)',
  high_answer: 'Very positive (happy or excited)',
  directory: 'filtered/'
}, {
  name: 'naturalness',
  instructions: 'The specific question we are interested in here is <b>how natural the clip sounds</b>. Some clips may sound like they are being spoken by someone who is comfortably interacting with a child or an adult. Others may sound artificial or awkward, like they are being spoken by a bad actor or the person speaking is uncomfortable with the situation. We will ask you to rate clips from 1 - 7, choosing 1 if the speaker sounds very unnatural and 7 if they sound very natural, comfortable, and normal.',
  question: 'Does this clip sound like the speaker is comfortable and in a normal environment, or like the speaker is awkward or artificial? How natural-sounding is this clip?',
  low_answer: 'Very unnatural',
  high_answer: 'Very natural',
  directory: 'normed/'
}, {
  name: 'accent',
  instructions: 'The specific question we are interested in here is <b>whether the speakers in these clips sound to you like they have a particular accent that is not typical American English</b>. We will ask you to rate clips from 1 - 7, choosing 1 if the speaker sounds like she has a standard American English accent and 7 if the speaker sounds like she has a very strong accent (a different kind of English accent, e.g. British or Australian, or a foreign accent). Many clips may sound unaccented. If they sound like they have no accent, it is OK to rate many of them near 1.',
  question: 'Does this speaker sound like she has an accent?',
  low_answer: 'No accent (standard American English)',
  high_answer: 'Very strong accent (other English or foreign accent)',
  directory: 'normed/'
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
