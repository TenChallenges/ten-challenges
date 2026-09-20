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

/** Stored ranks increase with recording order, independently of display sorting. */
export function ordinalSummary(entries: { rank: number; parameter: string }[]): string {
  let latest: { rank: number; parameter: string } | null = null;
  for (const entry of entries) {
    if (latest === null || entry.rank > latest.rank) latest = entry;
  }
  return `latest r: ${latest === null ? "N/A" : `r = ${latest.parameter}`}`;
}
