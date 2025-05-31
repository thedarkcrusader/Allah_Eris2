/datum/voicepack/orc/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("laugh")
			used = pick('sound/vo/mobs/orc/laugh (1).ogg','sound/vo/mobs/orc/laugh (2).ogg')
		if("aggro")
			used = pick('sound/vo/mobs/orc/aggro (1).ogg','sound/vo/mobs/orc/aggro (2).ogg','sound/vo/mobs/orc/aggro (3).ogg','sound/vo/mobs/orc/aggro (4).ogg')
		if("deathgurgle")
			used = pick('sound/vo/mobs/orc/death (1).ogg','sound/vo/mobs/orc/death (2).ogg')
		if("idle")
			used = pick('sound/vo/mobs/orc/idle (1).ogg','sound/vo/mobs/orc/idle (2).ogg','sound/vo/mobs/orc/idle (3).ogg','sound/vo/mobs/orc/idle (4).ogg','sound/vo/mobs/orc/idle (5).ogg')
		if("pain")
			used = pick('sound/vo/mobs/orc/pain (1).ogg','sound/vo/mobs/orc/pain (2).ogg','sound/vo/mobs/orc/pain (3).ogg')
		if("paincrit")
			used = pick('sound/vo/mobs/orc/pain (1).ogg','sound/vo/mobs/orc/painscream (2).ogg','sound/vo/mobs/orc/pain (3).ogg','sound/vo/mobs/orc/painscream (4).ogg')
		if("painscream")
			used = pick('sound/vo/mobs/orc/painscream (1).ogg','sound/vo/mobs/orc/painscream (2).ogg','sound/vo/mobs/orc/painscream (3).ogg','sound/vo/mobs/orc/painscream (4).ogg')

	return used
