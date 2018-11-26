So, LD33 is over, and once again I made something: [*The Monster Within*][entry].

# Theme
The theme was *You are the Monster*, and I wanted to really incorporate the theme into the gameplay mechanics for once
(well yeah, [Curved Curse][curcur] did that, but the topic was very broad and there was no way but incorporate it into the gameplay itself).

Many games I have seen took the theme quite literally and made the main character a monster:

<mmm-embed path="smert"></mmm-embed>  
[*image by @RedOshal*][smert_src]

Although you play a monster in *The Monster Within*, I took the theme a bit further.
The theme reminded me of an exclamated "*Look at yourself! You've become a Monster!*", something a movie wife might say to her increasingly out-of-control husband who just killed the neighbor that found out about the family's dark secret.

The idea I came up with was the following: your main objective is to eliminate enemies from within a crowd of mostly civilians (in a generic top-down action game). However you turn into a Monster whenever you kill someone, which grants you a lot more power, but also impairs your senses; you can no longer differentiate between civilians and enemies.
As a result, I figured, people would have to decide between two playstyles, going on a rampage and killing as many people as possible, regardless of their type, or trying to play strategically by memorizing the enemies in the crowd.

<mmm-embed path="split"></mmm-embed>  
*The Monster Within, normal and beast mode*

To make playing in "Beast Mode" more appealing I increased the primary attack (punch) range and added a secondary lunge attack that is exclusive to that mode. This, I hope, tempts players to make use of the beast mode and facilitates players stopping to play for the original objective - eliminating enemies - and instead try to kill as many people as possible (which is an intended effect).

To emphasize the two approaches, I introduced a dual scoring system; there is a "good" score that you can increase by eliminating enemies that is penalized whenever you kill a civilian but there is also an "evil" score that increases by the same amount regardless of the type of character you killed.
To balance the two, killing enemies yields more "good" points than "bad" ones, so both options can be viable.

As the current comments on the [ludum dare entry page][entry] show, not everyone understood what I was trying to achieve:

>It was fun although I didn't really like the mechanic where everyone turns into ghosts; it requires some ridiculous amount of memorization in order to get a good score, so I just ran around punching everyone indiscriminately.

Although it seems *charliecarlo* was completely oblivious to my actual intentions with the core mechanic, which always feels a bit bad, he perfectly demonstrated that my idea worked out; his character let the *monster within* loose and went on a bloody rampage.

>Different between beast and human score was initially confusing. Then again, that fits the theme well, a black box morality system.

>I like the concept, the art is nice and I killed 50 innocent souls! - Cool game!

So overall I am happy with how the mechanic turned out and was received; the three weeks of rating will hopefully yield more critique and comments.

# Techology

## Moonscript
Although I have been working on a networked game engine on top of [LÖVE][love] in moonscript, this is the first **complete** game that I write in [moonscript][moonscript].
Writing aforementioned engine definetely helped me form some habits that sped up development for this game.
*The Monster Within* turned out to be an amazingly small game at 768 lines of code (excluding libraries); [Curved Curse][curcur] counted 1160.

Every time I had to read or write Lua code (for example my older library, `st8`, which still has hiccups that I needed to iron out) the syntax seemed extremely cumbersome and restrictive.
After over a month, moonscript is still fun to write and read and I the decision to give it a shot was definetely more than worth it. Thank you leafo!

## Steering Behaviors
A few months back I stumbled upon the [very nice series *Understanding Steering Behaviors*][steering] on *tutsplus.com*.
I used those guides, alongside the sixth chapter of *Daniel Shiffman*'s *The Nature of Code*, [*Autonomous Agents*][autonom], to implement the character AI for the enemies and civilians.

In particular, I used the `wander`, `flee` (from the player, when he is in beast mode), `collision avoidance` and the `seperation` behaviors to make the characters move around in a more or less natural and pleasant-looking fashion.

The implementation consists of just a few lines of vector math and the results are surprisingly lifelike for the very little effort I had to put into it.

## Box2D
I was very unsure whether I should roll out my own simple physics system with a little Vector math, or whether I should use Box2d (which ships with LÖVE anyway).
I opted to choose `Box2D` because that would enable things like destructable environments (like houses being knocked away) and novel interactions in more carefully designed environments later down the road.

## Optimization
I didn't really optimize anything, and if I didn't know it doesn't matter at the current level scale, I would have long added a spatial hash system, stopped simulating characters that are long out of view or at the very least culled the map.
However I worked so slowly on the first two days that there really wasn't any time left for that sort of thing, and most of the game only started working on the last day so there wasn't a lot of optimization possible before that point anyway.
If I continue working on this project, Optimization is one of the first things I will deal with.

# Productivity
This Ludum Dare hit me entirely unprepared, I had completely forgotten about the date and only noticed a day prior.
I was initially very unsure whether to participate at all and also couldn't reach my artist from last year's game.
I put out a tweet and a post to [r/gamedev][rgamedev] and `stewartisme` contacted me as I was sleeping after looking at the theme at 3AM.
Still, I wasn't very motivated and worked slowly, procrastinated a lot and overall didn't really 'get into it'.
It amazes me that the game even turned out playable and with an acceptable look in general, but on the last day we really did work until the last minute, and as usual 90% of the perceived complete-ness were achieved in the last 10% of the time.

# Future?
I'm not sure whether this project will continue, but I have a few ideas on how to improve the game.
In particular, I would like to add a Highscores table.
Because every *The Monster Within* run yields two scores, there are multiple options for this.
Aside from the obvious solution of two seperate high score tables, the most interesting option from a game design perspective, would be to have a single table, and to enter whichever score is higher there.
The entries could be colored white and red, denoting whether the player followed the "good" objective or let himself get carried away.
It would probably be required to fine tune the scoring system so that both playstyles are equally hard to succeed in.

You can check out *The Monster Within* on the [Ludum Dare entry page][entry], [on itch.io][itch.io] or [view the source code on github][repo].

[entry]:      http://ludumdare.com/compo/ludum-dare-33/?action=preview&uid=28620
[itch.io]:    http://s0lll0s.itch.io/the-monster-within
[repo]:       https://github.com/s-ol/ld33
[curcur]:     http://s0lll0s.itch.io/curved-curse

[smert_src]:  http://ludumdare.com/compo/2015/08/22/what-i-imagine-most-people-are-doing-with-the-theme/

[love]:       https://love2d.org
[moonscript]: https://moonscript.org
[steering]:   http://gamedevelopment.tutsplus.com/series/understanding-steering-behaviors--gamedev-12732
[autonom]:    http://natureofcode.com/book/chapter-6-autonomous-agents/
[rgamedev]:   https://reddit.com/r/gamedev
