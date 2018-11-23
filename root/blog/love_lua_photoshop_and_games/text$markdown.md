Recently I've been building a 2d game engine for my semester project at [CGL](http://colognegamelab.de).
Below, I'll copy and paste two blog posts from my internal documentation blog:

--- 

After nailing down the basic narrative and gameplay idea in a lengthy group discussion on the first day,
we each set goals for the next few days in order to kickstart the project.

As we decided on a pixel art art approach and point-and-click gameplay, as the programmer I decided to write a custom engine in
[LÖVE](https://love2d.org) instead of using a bulky engine like Unity that we wouldn't really profit from anyway and that would be less specific,
and therefore less fitting, than what I could come up with.
Following this, my goal as an engine programmer was then to reduce any effort needed to put content into the engine to a minimum.
I remembered iteration speeds and how most things I did as a programmer last time I built a pixel art project in Unity really weren't programming but replacing assets; adding states in an animation state machine that I could've easily coded by hand in a fraction of the time; and generally wrestling with the development environment, and I wanted to instead create a working environment that would make my job as the gameplay programmer and the job of the artist(s) a lot easier.

Because creating my own engine is not a minor task and obviously a very crucial one for the project,
the decision to go ahead and not use a prebuilt Engine was to be thought out thoroughly,
if I am to write my own engine it needs to work _at least_ as good as a prebuilt one or it will harm the project.
To test whether I could actually improve workflow and build something my team can profit from, without degrading the project work during the time I need to actually put it together, I set myself a three-day deadline to try and go as far as I can and see whether writing the engine myself seemed realistic.
The other goal of this trial phase was to show my team members why the switch could be worthwhile for them also.

Therefore my main starting point was to build a feature that they would see as useful and that was central to what the engine was going to do later: **rendering and scene management.**

Specifically, I started writing something that loads a .PSD directly and animates the sublayers.
I also added code that detects file changes and reloads them automatically.
At the end of the second project day, I had this:

<video controls>
  <source src="{{site.url}}/assets/{{page.imgid}}/sheet.mp4" type="video/mp4" />
</video>

The code for this isn't much, but it took a few iterations to make the file- reload-watching reuseable and work on Linux and Windows alike (and efficient).
I used a 3rd party library for loading the photoshop files, but I had to patch it a lot.
Here's the main part for the animated-layer-loading:

    artal = require "lib.artal.artal"

    ALL_SHEETS = setmetatable {}, __mode: 'v'
    RECHECK = 0.3

    class PSDSheet
      new: (@filename, @frametime=.1) =>
        @time   = 0
        @frame  = 1

        @reload!

        if WATCHER
          WATCHER\register @filename, @

      reload: =>
        print "reloading #{@filename}..."


        @frames = {}
        target = @frames
        local group

        psd = artal.newPSD @filename
        for layer in *psd
          if layer.type == "open"
            if not group
              layer.image = love.graphics.newCanvas psd.width, psd.height
              love.graphics.setCanvas layer.image
              table.insert target, layer
              group = layer.name
          elseif layer.type == "close"
            if layer.name == group
              love.graphics.setCanvas!
              group = nil
          else
            if not group
              table.insert target, layer
            else
              love.graphics.draw layer.image, -layer.ox, -layer.oy if layer.image

      update: (dt) =>
        @time += dt

        @frame = 1 + (math.floor(@time/@frametime) % #@frames)

      draw: (x, y, rot) =>
        {:image, :ox, :oy} = @frames[@frame]
        love.graphics.draw image, x, y, rot, nil, nil, ox, oy if image

    {
      :PSDSheet,
    }


---

After being able to load simple animations from photoshop without even closing the game was working, I tried loading the scene İlke had created meanwhile:

![outside1]({{site.url}}/assets/{{page.imgid}}/outside1.jpg)

Naturally, this failed at first.
He was using clipping masks and blend modes, neither of which were implemented at the time,
but after I made a few changes to hide the affected layers for the time being, it looked fine.

My overall engine goal was to be able to build something like 90% of the level right in photoshop - including animations, hit areas, player spawns etc.
Basically I wanted to use Photoshop as a full level editor and only write gameplay scripts and engine code outside of it.

This meant that there would be very different types of information inside a level .psd that we would need to be accessible to the engine.

To load information and behaviours into the level structure that is loaded from the PSD I created a layer naming conventions;
layers can specify a _Directive_ afte their name.

The most important Directive (so far) is _load_: it loads a lua/moonscript _mixin_ via it's name and passes arguments to it .
For example there is a 'common' (shared between different scenes/levels) module called _subanim_ that treat's a group inside a bigger,
non-animated photoshop document as an animation (like what I did in the first post, but inside a complex scene).
The _subanim _module has one parameter, the frame-duration (in seconds).
To turn a group into a _subanim_, you have to append 'load:subanim,0.2' to it's name for example.

Another Directive is _tag_, it stores the layer under a name so other scripts can access it specifically and consistently.
Because this could also be done by a mixin, i am thinking about abolishing the _Directive_ concept and only using mixins (so that the _load_ could be removed also).
You can see the system working in this clip:


<video controls>
  <source src="{{site.url}}/assets/{{page.imgid}}/animating.mp4" type="video/mp4" />
</video>
_making an animation out of the single rain layer_

Moreover, I added a directory structure for mixins; to load a mixin called _name _for a scene called _scene_, it first looks in the scene specific directories:

  - game/_scene_/_name_.moon
  - game/_scene.moon_ (this file can return multiple mixins)

if neither of these exist, it checks for _common_ mixins of this name in the common directory and files:

  - games/common/_name.moon_
   - games/common.moon (this file can return multiple mixins)

This allows to share mixins between scenes (like click-area mixins maybe, or the _subanim_ mentioned above)
but still keep a clean directory structure for specific elements (like the dialogue of a certain scene,
or the tram in the background of the scene we are working on currently).

Mixin code can modify the scene node / layer object and overwrite the default "draw" and "update" hooks/methods.
This allows for nearly everything I can think of right now, but most mixins are still very short and concise.
As examples, you can take a look at the code that animates the tram in the background or the subanim source:

game/first_encounter/tram.moon:

    import wrapping_, Mixin from  require "util"

    wrapping_ class SubAnim extends Mixin
      SPEED = 440
      new: (scene) =>
        super!

        @pos = 0

      update: (dt) =>
        @pos = (@pos + SPEED*dt) % (WIDTH*2)

      draw: (recursive_draw) =>
        love.graphics.draw @image, @pos/4 - @ox - 140, -@oy


game/common/subanim.moon:

    import wrapping_, Mixin from  require "util"

    wrapping_ class SubAnim extends Mixin
      new: (scene, @frametime=0.1) =>
        super!

        @time = 0
        @frame = 1

      update: (dt) =>
        @time += dt

        @frame = 1 + (math.floor(@time/@frametime) % #@)

      draw: (recursive_draw) =>
        recursive_draw {@[@frame]}


_wrapping_ is a small helper that allows a moonscript class to wrap an existing lua table
(= object, in this case the layer objects produced by the psd parsing phase) and Mixin is a class that handles mixin live-reloading
(yep, that works with mixins too!) and might contain utility functions to write better mixins in the future.
Here's the code for both:

    wrapping_ = (klass) ->
      getmetatable(klass).__call = (cls, self, ...) ->
        setmetatable self, cls.__base
        cls.__init self, ...

      klass

    class Mixin
      new: =>
        info = debug.getinfo 2
        file = string.match info.source, "@%.?[/\\]?(.*)"

        @module = info.source\match "@%.?[/\\]?(.*)%.%a+"
        @module = @module\gsub "/", "."

        if WATCHER
          WATCHER\register file, @

      reload: (filename) =>
        print "reloading #{@module}..."

        package.loaded[@module] = nil
        new = require @module

        setmetatable @, new.__base

      find_tag: =>
        layer = @
        while not layer.tag
          layer = layer.parent

          if not layer
            return nil

        layer.tag

    {
      :wrapping_,
      :Mixin
    }


By the end of the three day "test phase".
This is how the first scene looked in-game:

<video controls>
  <source src="{{site.url}}/assets/{{page.imgid}}/final.mp4" type="video/mp4" />
</video>

Here's _psdscene.moon_, wrapping most things mentioned in this article:

    artal = require "lib.artal.artal"

    class PSDScene
      new: (@scene) =>
        @reload!

        if WATCHER
          WATCHER\register "assets/#{@scene}.psd", @

      load: (name, ...) =>
        _, mixin = pcall require, "game.#{@scene}.#{name}"
        return mixin if _ and mixin

        _, module = pcall require, "game.#{scene}"
        return module[name] if _ and module[name]

        _, mixin = pcall require, "game.common.#{name}"
        return mixin if _ and mixin

        _, module = pcall require, "game.common"
        return module[name] if _ and module[name]

        LOG_ERROR "couldn't find mixin '#{name}' for scene '#{@scene}'"
        nil

      reload: (filename) =>
        filename = "assets/#{@scene}.psd" unless filename
        print "reloading scene #{filename}..."

        @tree, @tags = {}, {}
        target = @tree
        local group

        indent = 0

        psd = artal.newPSD filename
        for layer in *psd
          if layer.type == "open"
            table.insert target, layer
            layer.parent = target
            target = layer
            LOG "+ #{layer.name}", indent
            indent += 1
            continue -- skip until close
          elseif layer.type == "close"
            layer = target
            target = target.parent
            indent -= 1
          else
            LOG "- #{layer.name}", indent
            table.insert target, layer

          cmd, params = layer.name\match "([^: ]+):(.+)"
          switch cmd
            when nil
              ""
            when "tag"
              @tags[params] = tag
              layer.tag = params
            when "load"
              params = [str for str in params\gmatch "[^,]+"]
              name = table.remove params, 1

              mixin = @load name
              if mixin
                LOG "loading mixin '#{@scene}/#{name}' (#{table.concat params, ", "})", indent
                mixin layer, unpack params
              else
                LOG_ERROR "couln't find mixin for '#{@scene}/#{name}'", indent
            else
              LOG_ERROR "unknown cmd '#{cmd}' for layer '#{layer.name}'", indent

      update: (dt, group=@tree) =>
        if group == false
          return

        for layer in *group
          if layer.update
            layer\update dt, @\update
          elseif layer.type == "open"
            @update dt, layer

      draw: (group=@tree) =>
        if group == false
          return
        elseif group == @tree
          love.graphics.scale 4

        for layer in *group
          if layer.draw
            layer\draw @\draw
          elseif layer.image
            {:image, :ox, :oy} = layer
            love.graphics.setColor 255, 255, 255, layer.opacity or 255
            love.graphics.draw image, x, y, nil, nil, nil, ox, oy
          elseif layer.type == "open"
            @draw layer

    {
      :PSDScene,
    }


Seeing that everything was (and is) going very smoothly up to this point,
I decided to "end" the test phase and finalize the decision to roll out my own engine.
