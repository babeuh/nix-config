const locale = { hc: 'h24' }

function gebi(id) {
  return document.getElementById(id)
}

function time() {
  let now = new Date()
  let options = {
    hour: 'numeric',
    minute: 'numeric',
    second: 'numeric',
    timeZone: 'Europe/Paris',
    hour12: false,
  }
  gebi('time').innerHTML = now.toLocaleTimeString(locale, options)
  setTimeout(time, 100)
}

function date() {
  let options = {
    day: 'numeric',
    month: 'long',
    timeZone: 'Europe/Paris',
    year: 'numeric',
  }
  let now = new Date()
  gebi('date').innerHTML = now.toLocaleDateString(locale, options)
  setTimeout(date, 1000)
}

async function startWeatherLoop(position) {
  const lat = position.coords.latitude
  const lon = position.coords.longitude
  const req = await fetch(
    `http://nominatim.openstreetmap.org/reverse?format=xml&lat=${lat}&lon=${lon}&zoom=18&addressdetails=1`,
  )
  const loc = (await req.text()).split('<city>')[1].split('</city>')[0]
  weather(loc)
}

function weather(town) {
  fetch('https://wttr.in/' + town + '?format=%C+%t')
    .then((response) => response.text())
    .then((text) => {
      document.getElementById('weather').innerHTML = text
    })
  setTimeout(() => {
    weather(loc)
  }, 1200000)
}

function randChoice(arr) {
  return arr[Math.floor(Math.random() * arr.length)]
}

const finderPossibleResults = [
  { name: 'invidious', url: 'https://api.invidious.io' },
  { name: 'lemmy', url: 'https://lemmy.world' },
  { name: 'github', url: 'https://github.com' },
  { name: 'protondb', url: 'https://protondb.com' },
  { name: 'lichess', url: 'https://lichess.org' },
  { name: 'monkeytype', url: 'https://monkeytype.com' },
  {
    name: 'nixos search',
    url: 'https://search.nixos.org/packages?channel=unstable',
  },
  {
    name: 'home-manager search',
    url: 'https://mipmip.github.io/home-manager-option-search',
  },
  { name: 'nix-config', url: 'https://github.com/babeuh/nix-config' },
]

const finderResults = {
  quantity: 0,
  selected: 1,
  list: [],
}

function finderProcessResult() {
  const finderInput = gebi('finder-input')
  let url = ''

  if (
    finderInput.value.startsWith('https://') ||
    finderInput.value.startsWith('http://')
  ) {
    url = finderInput.value
  } else if (finderInput.value.startsWith('/')) {
    url = `https://duckduckgo.com/?q=${finderInput.value.substring(1)}`
  } else if (finderResults.quantity !== 0) {
    url = finderResults.list[finderResults.selected - 1].url
  } else {
    return false
  }

  window.open(url, '_blank')
  finderInput.value = ''
  return false
}

function finderUpdateSelection(code) {
  if (finderResults.quantity == 0) return
  if (code == 'ArrowDown' || code == 'ArrowUp') {
    if (finderResults.selected > finderResults.quantity)
      finderResults.selected = finderResults.quantity
    if (
      finderResults.selected !==
      (code == 'ArrowDown' ? finderResults.quantity : 1)
    ) {
      finderResults.selected += code == 'ArrowDown' ? 1 : -1
    } else {
      finderResults.selected = code == 'ArrowDown' ? 1 : finderResults.quantity
    }
    return true
  }
}

function stringSimilarity(str1, str2, gramSize = 2) {
  function getNGrams(s, len) {
    s = ' '.repeat(len - 1) + s.toLowerCase() + ' '.repeat(len - 1)
    let v = new Array(s.length - len + 1)
    for (let i = 0; i < v.length; i++) {
      v[i] = s.slice(i, i + len)
    }
    return v
  }
  if (
    !(str1 === null || str1 === void 0 ? void 0 : str1.length) ||
    !(str2 === null || str2 === void 0 ? void 0 : str2.length)
  ) {
    return 0.0
  }
  let s1 = str1.length < str2.length ? str1 : str2
  let s2 = str1.length < str2.length ? str2 : str1
  let pairs1 = getNGrams(s1, gramSize)
  let pairs2 = getNGrams(s2, gramSize)
  let set = new Set(pairs1)
  let total = pairs2.length
  let hits = 0
  for (let item of pairs2) {
    if (set.delete(item)) {
      hits++
    }
  }
  return hits / total
}
function finderUpdateResults() {
  const finderInput = gebi('finder-input')
  let fuzzyMatched = []
  for (i = 0; i < finderPossibleResults.length; i++) {
    const ngramSize = finderInput.value.length < 2 ? 1 : 2
    const similarity = stringSimilarity(
      finderInput.value,
      finderPossibleResults[i].name,
      ngramSize,
    )
    if (similarity > 0)
      fuzzyMatched.push({
        name: finderPossibleResults[i].name,
        url: finderPossibleResults[i].url,
        similarity: similarity,
      })
  }

  fuzzyMatched.sort((a, b) => {
    if (a.similarity < b.similarity) {
      return 1
    } else if (a.similarity > b.similarity) {
      return -1
    } else {
      return 0
    }
  })

  finderResults.quantity = fuzzyMatched.length
  let selected = finderResults.selected
  if (selected > finderResults.quantity) {
    selected = finderResults.quantity
  }
  finderResults.list = fuzzyMatched

  const resultList = gebi('result-ul')
  resultList.innerHTML = '<li>~/results</li>'
  for (i = 0; i < finderResults.list.length; i++) {
    const r = finderResults.list[i]
    resultList.innerHTML += `<li><a class="${selected == i + 1 ? 'selected' : ''}" href="${r.url}" target="_blank">${r.name}</a></li>`
  }
}

function finderInputUpdate(e) {
  const finderInputValue = gebi('finder-input').value
  if (
    e.code == 'Enter' ||
    e.key == 'Shift' ||
    e.key == 'Alt' ||
    e.key == 'Control' ||
    e.key == 'OS' ||
    finderInputValue.startsWith('/')
  ) {
    return
  } else if (
    finderInputValue.startsWith('http://') ||
    finderInputValue.startsWith('https://')
  ) {
    gebi('result-ul').innerHTML = '<li>~/results</li>'
    return
  }
  finderUpdateSelection(e.code)
  finderUpdateResults()
}

function finderInputExclusions(e) {
  if (e.code == 'ArrowDown' || e.code == 'ArrowUp') {
    e.preventDefault()
    return false
  }
}

function main() {
  time()
  date()
  navigator.geolocation.getCurrentPosition(startWeatherLoop)
  window.onfocus = () => {
    window.setTimeout(() => {
      gebi('finder-input').focus()
      gebi('finder-input').value = ''
      gebi('result-ul').innerHTML = '<li>~/results</li>'
      finderResults.selected = 1
    }, 0)
  }
  gebi('finder-input').addEventListener('keyup', finderInputUpdate)
  gebi('finder-input').addEventListener('keydown', finderInputExclusions)
}
