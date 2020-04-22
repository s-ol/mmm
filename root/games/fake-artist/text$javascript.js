const words = [
  "airplane",
  "alive",
  "alligator",
  "angel",
  "ant",
  "apple",
  "arm",
  "baby",
  "backpack",
  "ball",
  "balloon",
  "banana",
  "bark",
  "baseball",
  "basketball",
  "bat",
  "bathroom",
  "beach",
  "beak",
  "bear",
  "bed",
  "bee",
  "bell",
  "bench",
  "bike",
  "bird",
  "blanket",
  "blocks",
  "boat",
  "bone",
  "book",
  "bounce",
  "bow",
  "bowl",
  "box",
  "boy",
  "bracelet",
  "branch",
  "bread",
  "bridge",
  "broom",
  "bug",
  "bumblebee",
  "bunk bed",
  "bunny",
  "bus",
  "butterfly",
  "button",
  "camera",
  "candle",
  "candy",
  "car",
  "carrot",
  "cat",
  "caterpillar",
  "chair",
  "cheese",
  "cherry",
  "chicken",
  "chimney",
  "clock",
  "cloud",
  "coat",
  "coin",
  "comb",
  "computer",
  "cookie",
  "corn",
  "cow",
  "crab",
  "crack",
  "crayon",
  "cube",
  "cup",
  "cupcake",
  "curl",
  "daisy",
  "desk",
  "diamond",
  "dinosaur",
  "dog",
  "doll",
  "door",
  "dragon",
  "dream",
  "drum",
  "duck",
  "ear",
  "ears",
  "Earth",
  "egg",
  "elephant",
  "eye",
  "eyes",
  "face",
  "family",
  "feather",
  "feet",
  "finger",
  "fire",
  "fish",
  "flag",
  "float",
  "flower",
  "fly",
  "football",
  "fork",
  "frog",
  "ghost",
  "giraffe",
  "girl",
  "glasses",
  "grapes",
  "grass",
  "hair",
  "hamburger",
  "hand",
  "hat",
  "head",
  "heart",
  "helicopter",
  "hippo",
  "hook",
  "horse",
  "house",
  "ice cream cone",
  "inchworm",
  "island",
  "jacket",
  "jail",
  "jar",
  "jellyfish",
  "key",
  "king",
  "kite",
  "kitten",
  "knee",
  "ladybug",
  "lamp",
  "leaf",
  "leg",
  "legs",
  "lemon",
  "light",
  "line",
  "lion",
  "lips",
  "lizard",
  "lollipop",
  "love",
  "man",
  "Mickey Mouse",
  "milk",
  "mitten",
  "monkey",
  "monster",
  "moon",
  "motorcycle",
  "mountain",
  "mountains",
  "mouse",
  "mouth",
  "music",
  "nail",
  "neck",
  "night",
  "nose",
  "ocean",
  "octopus",
  "orange",
  "oval",
  "owl",
  "pants",
  "pen",
  "pencil",
  "person",
  "pie",
  "pig",
  "pillow",
  "pizza",
  "plant",
  "popsicle",
  "purse",
  "rabbit",
  "rain",
  "rainbow",
  "ring",
  "river",
  "robot",
  "rock",
  "rocket",
  "sea",
  "seashell",
  "sheep",
  "ship",
  "shirt",
  "shoe",
  "skateboard",
  "slide",
  "smile",
  "snail",
  "snake",
  "snowflake",
  "snowman",
  "socks",
  "spider",
  "spider web",
  "spoon",
  "stairs",
  "star",
  "starfish",
  "suitcase",
  "sun",
  "sunglasses",
  "swimming pool",
  "swing",
  "table",
  "tail",
  "train",
  "tree",
  "truck",
  "turtle",
  "water",
  "whale",
  "wheel",
  "window",
  "woman",
  "worm",
  "zebra",
  "zoo",
];

const main = document.getElementById('main');
const players = document.getElementById('players');
const spies = document.getElementById('spies');
const name = document.getElementById('name');
const add = document.getElementById('add');

const shuffle = (array, rng) => {
  for (let i = array.length - 1; i > 0; i--) {
    let j = Math.floor(rng() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
};

const infect = a => {
  a.onclick = () => {
    const hash = a.href.split('#')[1];
    update('#' + hash);
  };
};

const genSeed = rng => (
          words[Math.floor(rng() * words.length)].replace(' ', '-')
  + '_' + words[Math.floor(rng() * words.length)].replace(' ', '-')
  + '_' + words[Math.floor(rng() * words.length)].replace(' ', '-')
);

const update = (hash) => {
  const [ mode, seed, n, ...names ] = hash.split(/,/);
  const rng = new Math.seedrandom(seed);
  const nextSeed = genSeed(rng);

  while (main.lastChild)
    main.removeChild(main.lastChild);

  if (mode === '#link') {
    document.body.className = '';
    names.forEach((name, i) => {
      const a = document.createElement('a');
      a.innerText = 'play';
      a.href = `#play,${seed},${n},${names.join(',')},${i}`;
      infect(a);
      
      const div = document.createElement('div');
      div.append(`${name}: `);
      div.append(a);
      main.append(div);
    });

    const a = document.createElement('a');
    a.innerText = 'next round';
    a.href = `#link,${nextSeed},${n},${names.join(',')}`;
    infect(a);
    main.append(document.createElement('br'));
    main.append(a);
  } else if (mode === '#play') {
    document.body.className = '';
    const i = names.pop();

    const word = words[Math.floor(rng() * words.length)];
    const list = names.map((x, i) => i < +n);
    shuffle(list, rng);

    if (list[+i]) {
      main.append("you are a");
      main.append(document.createElement('br'));
      const span = document.createElement('span');
      span.className = 'spy';
      span.innerText = 'SPY!';
      main.append(span);
    } else {
      main.append("the word is");
      main.append(document.createElement('br'));
      const span = document.createElement('span');
      span.innerText = word;
      main.append(span);
    }

    const a = document.createElement('a');
    a.innerText = 'next round';
    a.href = `#play,${nextSeed},${n},${names.join(',')},${i}`;
    infect(a);
    main.append(document.createElement('br'));
    main.append(a);
  } else {
    document.body.className = 'setup';
    const seed = genSeed(Math.random);
    const names = [];
    const a = document.createElement('a');
    a.innerText = 'start';
    a.href = `#link,${seed},${spies.value},${names.join(',')}`;
    main.append(a);
    infect(a);

    add.onclick = () => {
      const li = document.createElement('li');
      li.innerText = name.value;
      players.append(li);
      names.push(name.value);
      a.href = `#link,${seed},${spies.value},${names.join(',')}`;
      name.value = '';
    };

    spies.onchange = () => {
      a.href = `#link,${seed},${spies.value},${names.join(',')}`;
    }
  }
}

update(window.location.hash);
