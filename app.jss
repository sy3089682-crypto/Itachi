// app.js - single-file logic for the cube solver web app
// Uses cubejs from CDN (window.Cube)

// Face order used by cubejs: U R F D L B
// We'll render faces on UI in that order, allow clicking stickers to change color.

const COLORS = [
  { name: "white", short: "U", hex: "#ffffff" },
  { name: "red",   short: "R", hex: "#d90429" },
  { name: "green", short: "F", hex: "#00a86b" },
  { name: "yellow",short: "D", hex: "#ffd166" },
  { name: "orange",short: "L", hex: "#f07a1a" },
  { name: "blue",  short: "B", hex: "#0b60ff" }
];

const FACE_NAMES = ["U","R","F","D","L","B"]; // cubejs expects U R F D L B

// create board state: 6 faces × 9 stickers each, represented as color short letters (U R F D L B)
let stickers = []; // length 54

function makeSolvedStickers(){
  stickers = [];
  for(let f=0; f<6; f++){
    for(let i=0;i<9;i++){
      stickers.push(FACE_NAMES[f]);
    }
  }
}

// DOM refs
const boardEl = document.getElementById("cubeBoard");
const colorSwatches = document.getElementById("colorSwatches");
const solveBtn = document.getElementById("solveBtn");
const scrambleBtn = document.getElementById("scrambleBtn");
const resetBtn = document.getElementById("resetBtn");
const solutionMovesEl = document.getElementById("solutionMoves");
const prevMoveBtn = document.getElementById("prevMove");
const nextMoveBtn = document.getElementById("nextMove");
const currentMoveIdxEl = document.getElementById("currentMoveIdx");

let activeColor = COLORS[0]; // default white
let solutionMoves = [];
let currentStep = -1; // -1 = not started

// Build color picker
function buildColorPicker(){
  colorSwatches.innerHTML = "";
  COLORS.forEach((c, idx) => {
    const sw = document.createElement("div");
    sw.className = "swatch";
    sw.style.background = c.hex;
    sw.title = c.name;
    if(c === activeColor) sw.style.outline = "3px solid rgba(0,0,0,0.12)";
    sw.addEventListener("click", () => {
      activeColor = c;
      // update outlines
      Array.from(colorSwatches.children).forEach(ch => ch.style.outline = "");
      sw.style.outline = "3px solid rgba(0,0,0,0.12)";
    });
    colorSwatches.appendChild(sw);
  });
}

// Render the cube as 6 faces (U R F D L B) in a simple layout
function renderBoard(){
  boardEl.innerHTML = "";
  // For clarity, we'll render faces in U (top row), then middle row (L F R B) arranged as L F R B, then D
  // But to keep layout simple we render U, R, F, D, L, B vertically as labeled face blocks.
  FACE_NAMES.forEach((face, fi) => {
    const label = document.createElement("div");
    label.className = "label";
    label.textContent = face;
    boardEl.appendChild(label);

    const grid = document.createElement("div");
    grid.className = "face-grid";
    const baseIdx = fi * 9;
    for(let i=0;i<9;i++){
      const st = document.createElement("div");
      st.className = "sticker";
      const colorShort = stickers[baseIdx + i];
      const c = COLORS.find(cc => cc.short === colorShort) || COLORS[0];
      st.style.background = c.hex;
      st.dataset.index = baseIdx + i;
      st.addEventListener("click", onStickerClick);
      grid.appendChild(st);
    }
    boardEl.appendChild(grid);
  });
}

function onStickerClick(e){
  const idx = Number(e.currentTarget.dataset.index);
  stickers[idx] = activeColor.short;
  renderBoard();
}

// convert stickers array to cube-string expected by cubejs
function stickersToCubeString(){
  // stickers already stored in faces U,R,F,D,L,B order
  // cubejs expects a 54-char string using face letters U R F D L B
  return stickers.join("");
}

// Solve using cubejs
function solveCube(){
  solutionMovesEl.innerHTML = "Working...";
  try {
    const cubeString = stickersToCubeString();
    // cubejs provides window.Cube.solve
    const solverResult = window.Cube.solve(cubeString, {range: 1, timeout: 5});
    // solverResult is e.g. "R U R' U R U2 R'"
    const moves = solverResult.trim().split(/\s+/).filter(Boolean);
    solutionMoves = moves;
    currentStep = -1;
    renderSolution();
  } catch (err) {
    solutionMovesEl.innerHTML = "Error solving cube: " + (err && err.message ? err.message : err);
  }
}

function renderSolution(){
  solutionMovesEl.innerHTML = "";
  if(solutionMoves.length === 0){
    solutionMovesEl.textContent = "(Already solved or no moves)";
  } else {
    solutionMoves.forEach((m, i) => {
      const b = document.createElement("div");
      b.className = "move-bubble";
      b.textContent = m;
      b.dataset.idx = i;
      if(i === currentStep) b.style.background = "#0b5cff"; // highlight current
      solutionMovesEl.appendChild(b);
    });
  }
  updateMoveIndicator();
}

function updateMoveIndicator(){
  const total = solutionMoves.length;
  if(currentStep < 0) currentMoveIdxEl.textContent = `0 / ${total}`;
  else currentMoveIdxEl.textContent = `${currentStep+1} / ${total}`;
  // Visual highlight of current move
  Array.from(solutionMovesEl.children).forEach((ch, i) => {
    ch.style.background = (i === currentStep) ? "#0b5cff" : "#f3f6ff";
    ch.style.color = (i === currentStep) ? "white" : "black";
  });
}

// Controls: Next/Prev just change index (we don't animate the cube; we provide the moves for the user to perform)
nextMoveBtn.addEventListener("click", () => {
  if(solutionMoves.length === 0) return;
  if(currentStep < solutionMoves.length - 1) currentStep++;
  updateMoveIndicator();
});
prevMoveBtn.addEventListener("click", () => {
  if(solutionMoves.length === 0) return;
  if(currentStep > -1) currentStep--;
  updateMoveIndicator();
});

solveBtn.addEventListener("click", solveCube);

// helper: random scramble generator (uses cubejs to scramble)
scrambleBtn.addEventListener("click", () => {
  // produce a random scramble (20 moves)
  const moves = ["U","U'","U2","R","R'","R2","F","F'","F2","D","D'","D2","L","L'","L2","B","B'","B2"];
  const scramble = [];
  let last = "";
  for(let i=0;i<20;i++){
    let mv;
    do{
      mv = moves[Math.floor(Math.random()*moves.length)];
    } while (last && mv[0] === last[0]);
    scramble.push(mv);
    last = mv;
  }
  // apply scramble to solved stickers using Cube.move? cubejs provides an API via Cube.fromString -> rotate?
  // Simpler: build a cube from solved string and apply moves using cubejs library instance
  try {
    const solved = makeCubejsFromStickers();
    // cubejs has a function 'move' on cube object in some builds. We'll use Cube.fromString + Cube.applyAlg if available.
    // Fallback: ask cubejs to scramble string via solve? Instead, we can use Cube.fromString and use algorithm method.
    // Try to use window.Cube.fromString
    if(window.Cube && typeof window.Cube.fromString === "function"){
      const c = window.Cube.fromString(stickersToCubeString());
      if(typeof c.move === "function"){
        scramble.forEach(m => c.move(m));
        const out = c.asString ? c.asString() : c.toString();
        // map back to stickers
        // asString/toString might return space-separated; normalize to letters
        const normalized = out.replace(/\s+/g, "").trim();
        // update stickers array
        for(let i=0;i<54;i++) stickers[i] = normalized[i];
        renderBoard();
        solutionMovesEl.innerHTML = "Scrambled: " + scramble.join(" ");
      } else {
        // fallback: we can't apply moves, just show the scramble text and leave stickers unchanged
        solutionMovesEl.innerHTML = "Scramble: " + scramble.join(" ") + " (copy & apply manually)";
      }
    } else {
      solutionMovesEl.innerHTML = "Scramble: " + scramble.join(" ");
    }
  } catch(err){
    console.warn(err);
    solutionMovesEl.innerHTML = "Scramble: " + scramble.join(" ");
  }
});

resetBtn.addEventListener("click", () => {
  makeSolvedStickers();
  renderBoard();
  renderSolution();
});

// helper to create cubejs cube from stickers (if available)
function makeCubejsFromStickers(){
  if(window.Cube && typeof window.Cube.fromString === "function"){
    return window.Cube.fromString(stickersToCubeString());
  }
  return null;
}

// init
makeSolvedStickers();
buildColorPicker();
renderBoard();
renderSolution();
