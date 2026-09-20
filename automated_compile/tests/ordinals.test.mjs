import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";
import ts from "typescript";

// Exercise the actual TypeScript helper using the project's existing compiler.
const source = readFileSync(new URL("../src/ordinals.ts", import.meta.url), "utf8");
const js = ts.transpileModule(source, {
  compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.ES2022 },
}).outputText;
const { compareOrdinals, readOrdinalCNF, ordinalSummary } = await import(
  `data:text/javascript;base64,${Buffer.from(js).toString("base64")}`
);

const one = [[[], "1"]];
const omega = [[one, "1"]];
const twice = [[one, "2"]];
const square = [[[[[], "2"]], "1"]];

test("orders zero, finite values, omega, successors, multiples, and nested powers", () => {
  const chain = [[], one, [[[], "9007199254740993"]], omega,
    [[one, "1"], [[], "1"]], twice, square, [[omega, "1"]], [[[[omega, "1"]], "1"]]];
  for (let i = 0; i < chain.length; i++) {
    const a = readOrdinalCNF(chain[i]);
    assert.notEqual(a, null);
    for (let j = 0; j < chain.length; j++) {
      assert.equal(compareOrdinals(a, readOrdinalCNF(chain[j])), Math.sign(i - j));
    }
  }
});

test("finite coefficients retain precision beyond JavaScript Number", () => {
  const a = readOrdinalCNF([[[], "9007199254740992"]]);
  const b = readOrdinalCNF([[[], "9007199254740993"]]);
  assert.equal(compareOrdinals(a, b), -1);
});

test("summary shows the latest recorded ordinal, even when it is smaller", () => {
  const entries = [
    { rank: 1, parameter: "ω^(2)", ordinal_cnf: square },
    { rank: 3, parameter: "ω*2", ordinal_cnf: twice },
    { rank: 8, parameter: "ω", ordinal_cnf: omega },
  ];
  assert.equal(ordinalSummary(entries), "latest r: r = ω");
  assert.equal(ordinalSummary([...entries].reverse()), "latest r: r = ω");
  assert.equal(ordinalSummary([{ rank: 1, parameter: "0", ordinal_cnf: [] }]), "latest r: r = 0");
  assert.equal(ordinalSummary([]), "latest r: N/A");
});

test("summary uses recording order for both supported and unsupported ordinals", () => {
  const entries = [
    { rank: 1, parameter: "ω*2", ordinal_cnf: twice },
    { rank: 2, parameter: "Ordinal.omega 1" },
  ];
  assert.equal(ordinalSummary(entries), "latest r: r = Ordinal.omega 1");
  assert.equal(ordinalSummary([...entries, { rank: 3, parameter: "ω", ordinal_cnf: omega }]),
    "latest r: r = ω");
});

test("malformed or non-normal keys fall back instead of inventing an order", () => {
  for (const value of [null, {}, [[[], "0"]], [[[], 1]], [[[], "01"]],
    [[[], "-1"]], [[[], "١"]], [[[], "2"], [one, "1"]], [[one, "1"], [one, "2"]]]) {
    assert.equal(readOrdinalCNF(value), null);
    assert.equal(ordinalSummary([{ rank: 1, parameter: "unrecognized", ordinal_cnf: value }]),
      "latest r: r = unrecognized");
  }
});
