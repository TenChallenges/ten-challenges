/** Cantor normal forms emitted by the Lean checker, with exact coefficients. */
export type OrdinalCNF = { exponent: OrdinalCNF; coefficient: bigint }[];

export function compareOrdinals(a: OrdinalCNF, b: OrdinalCNF): number {
  for (let i = 0; i < Math.min(a.length, b.length); i++) {
    const exponentOrder = compareOrdinals(a[i].exponent, b[i].exponent);
    if (exponentOrder !== 0) return exponentOrder;
    if (a[i].coefficient !== b[i].coefficient) {
      return a[i].coefficient < b[i].coefficient ? -1 : 1;
    }
  }
  return a.length === b.length ? 0 : a.length < b.length ? -1 : 1;
}

/** Missing/unsupported/malformed keys must never be guessed from display text. */
export function readOrdinalCNF(value: unknown): OrdinalCNF | null {
  let budget = 4096;
  const read = (input: unknown, depth: number): OrdinalCNF | null => {
    if (!Array.isArray(input) || depth > 128) return null;
    const result: OrdinalCNF = [];
    for (const term of input) {
      if (--budget < 0 || !Array.isArray(term) || term.length !== 2) return null;
      const [rawExponent, coefficient] = term;
      if (typeof coefficient !== "string" || coefficient.length > 1300 ||
          !/^[1-9][0-9]*$/.test(coefficient)) return null;
      const exponent = read(rawExponent, depth + 1);
      if (exponent === null) return null;
      if (result.length > 0 &&
          compareOrdinals(result[result.length - 1].exponent, exponent) <= 0) return null;
      result.push({ exponent, coefficient: BigInt(coefficient) });
    }
    return result;
  };
  return read(value, 0);
}

export function ordinalSummary(entries: { parameter: string; ordinal_cnf?: unknown }[]): string {
  if (entries.length === 0) return "proved r: N/A";
  let best: { parameter: string; value: OrdinalCNF } | null = null;
  for (const entry of entries) {
    const value = readOrdinalCNF(entry.ordinal_cnf);
    if (value === null) {
      // One unrecognized ordinal is enough to make a claimed maximum unsafe.
      const parameters = [...new Set(entries.map(e => e.parameter.trim()).filter(Boolean))];
      return `proved r: ${parameters.join(", ") || "N/A"}`;
    }
    if (best === null || compareOrdinals(value, best.value) > 0) {
      best = { parameter: entry.parameter, value };
    }
  }
  return `largest r so far: r = ${best!.parameter}`;
}
