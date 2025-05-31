/datum/voicepack/male/squire/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("firescream")
			used = pick('sound/vo/male/squire/firescream (1).ogg','sound/vo/male/squire/firescream (2).ogg','sound/vo/male/squire/firescream (3).ogg')
		if("laugh")
			used = pick('sound/vo/male/squire/laugh (1).ogg','sound/vo/male/squire/laugh (2).ogg','sound/vo/male/squire/laugh (3).ogg','sound/vo/male/squire/laugh (4).ogg','sound/vo/male/squire/laugh (5).ogg','sound/vo/male/squire/laugh (6).ogg','sound/vo/male/squire/laugh (7).ogg')
		if("pain")
			used = pick('sound/vo/male/squire/pain (1).ogg','sound/vo/male/squire/pain (2).ogg','sound/vo/male/squire/pain (3).ogg','sound/vo/male/squire/pain (4).ogg')
		if("paincrit")
			used = pick('sound/vo/male/squire/paincrit (1).ogg','sound/vo/male/squire/paincrit (2).ogg','sound/vo/male/squire/paincrit (3).ogg')
		if("painscream")
			used = pick('sound/vo/male/squire/painscream (1).ogg','sound/vo/male/squire/painscream (2).ogg','sound/vo/male/squire/painscream (3).ogg')
		if("rage")
			used = 'sound/vo/male/squire/rage.ogg'
	if(!used)
		used = ..(soundin, modifiers)
	return used
