import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";
import ts from "typescript";

const source = readFileSync(new URL("../src/leaderboard.ts", import.meta.url), "utf8");
const compile = source => ts.transpileModule(source, {
  compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.ES2022 },
}).outputText;
const ordinalSource = readFileSync(new URL("../src/ordinals.ts", import.meta.url), "utf8");
const ordinalUrl = `data:text/javascript;base64,${Buffer.from(compile(ordinalSource)).toString("base64")}`;
const js = compile(source).replace('from "./ordinals"', `from ${JSON.stringify(ordinalUrl)}`);
const { leaderboardRows } = await import(
  `data:text/javascript;base64,${Buffer.from(js).toString("base64")}`
);

const entry = (rank, parameter, problem = "challenge_8") => ({ rank, parameter, problem });

test("each natural-number challenge orders parameters decreasingly", () => {
  for (const number of [1, 2, 3, 4, 5, 7, 8, 9]) {
    const problem = `challenge_${number}`;
    const original = [entry(2, "3", problem), entry(5, "100", problem), entry(8, "20", problem)];
    const rows = leaderboardRows(original, problem);
    assert.deepEqual(rows.map(e => e.parameter), ["100", "20", "3"]);
    assert.deepEqual(rows.map(e => e.displayRank), [1, 2, 3]);
    assert.deepEqual(rows.map(e => e.rank), [5, 8, 2]);
    assert.deepEqual(original.map(e => e.parameter), ["3", "100", "20"]);
  }
});

test("zero, large parameters, and equal values are compared exactly", () => {
  const rows = leaderboardRows([
    entry(1, "0"), entry(2, "9007199254740992"), entry(3, "9007199254740993"),
    entry(5, "003"), entry(4, " 3 "),
  ], "challenge_8");
  assert.deepEqual(rows.map(e => e.rank), [3, 2, 4, 5, 1]);
});

test("universal results come first and unrelated challenges are excluded", () => {
  const rows = leaderboardRows([
    entry(1, "3"), entry(2, "universal", "challenge_8_univ"),
    entry(3, "100"), entry(4, "universal", "challenge_8_disprove"),
    entry(5, "1000", "challenge_1"), entry(6, "unrecognized"),
  ], "challenge_8");
  assert.deepEqual(rows.map(e => e.rank), [2, 4, 3, 1, 6]);
});

test("All preserves recording order; unsupported ordinals remain unranked", () => {
  const entries = [
    entry(1, "3"), entry(2, "ω", "challenge_6"), entry(3, "ω*2", "challenge_6"),
    entry(4, "100"), entry(5, "3", "challenge_10"), entry(6, "100", "challenge_10"),
  ];
  assert.deepEqual(leaderboardRows(entries, "all").map(e => e.displayRank), [1, 2, 3, 4, 5, 6]);
  assert.deepEqual(leaderboardRows(entries, "challenge_6").map(e => e.displayRank), [null, null]);
  assert.deepEqual(leaderboardRows(entries, "challenge_10").map(e => e.displayRank), [null, null]);
  assert.deepEqual(leaderboardRows([], "challenge_1"), []);
});

test("ordinal tabs sort recognized values decreasingly and break ties by recording order", () => {
  const one = [[[], "1"]];
  const omega = [[one, "1"]];
  const twice = [[one, "2"]];
  const square = [[[[[], "2"]], "1"]];
  for (const problem of ["challenge_6", "challenge_10"]) {
    const original = [
      { ...entry(1, "ω", problem), ordinal_cnf: omega },
      { ...entry(2, "ω^(2)", problem), ordinal_cnf: square },
      { ...entry(3, "0", problem), ordinal_cnf: [] },
      { ...entry(4, "ω*2", problem), ordinal_cnf: twice },
      { ...entry(5, "ω", problem), ordinal_cnf: omega },
    ];
    const rows = leaderboardRows(original, problem);
    assert.deepEqual(rows.map(e => e.rank), [2, 4, 1, 5, 3]);
    assert.deepEqual(rows.map(e => e.displayRank), [1, 2, 3, 4, 5]);
    assert.deepEqual(original.map(e => e.rank), [1, 2, 3, 4, 5]);
  }
});

test("mixed ordinal results put universal results first and never assign unknown values a rank", () => {
  const rows = leaderboardRows([
    entry(1, "ω₁", "challenge_6"),
    { ...entry(2, "ω", "challenge_6"), ordinal_cnf: [[[[[], "1"]], "1"]] },
    entry(3, "universal", "challenge_6_univ"),
    { ...entry(4, "unsupported", "challenge_6"), ordinal_cnf: [[[], "0"]] },
    entry(5, "universal", "challenge_6_disprove"),
    entry(6, "100", "challenge_8"),
  ], "challenge_6");
  assert.deepEqual(rows.map(e => e.rank), [3, 5, 2, 1, 4]);
  assert.deepEqual(rows.map(e => e.displayRank), [1, 2, 3, null, null]);
});
