import { compareOrdinals, readOrdinalCNF } from "./ordinals";

interface RankedEntry {
  rank: number;
  problem: string;
  parameter: string;
  ordinal_cnf?: unknown;
  /** challenge_2 only: the certified bound B on the number of excluded minors. */
  bound?: string;
}

const naturalChallenges = new Set([
  "challenge_1", "challenge_3", "challenge_4",
  "challenge_5", "challenge_7", "challenge_8", "challenge_9",
]);

const natural = (text: string | undefined): bigint | null => {
  const value = (text ?? "").trim();
  return /^[0-9]+$/.test(value) ? BigInt(value) : null;
};

/** Display order is independent of the stored submission-order rank. */
export function leaderboardRows<T extends RankedEntry>(entries: readonly T[], tab: string) {
  const selected = entries.filter(entry =>
    tab === "all" || entry.problem.replace(/_(univ|disprove)$/, "") === tab
  );
  if (tab === "challenge_6" || tab === "challenge_10") {
    return selected.map(entry => ({
      entry,
      universal: entry.parameter.trim() === "universal",
      value: readOrdinalCNF(entry.ordinal_cnf),
    })).sort((a, b) => {
      if (a.universal !== b.universal) return a.universal ? -1 : 1;
      if (a.universal) return a.entry.rank - b.entry.rank;
      if (a.value !== null && b.value !== null) {
        return compareOrdinals(b.value, a.value) || a.entry.rank - b.entry.rank;
      }
      if ((a.value === null) !== (b.value === null)) return a.value === null ? 1 : -1;
      return a.entry.rank - b.entry.rank;
    }).map(({ entry, universal, value }, index) => ({
      ...entry,
      // Unsupported values are a separate, unranked group, not smaller ordinals.
      displayRank: universal || value !== null ? index + 1 : null,
    }));
  }
  if (tab === "challenge_2") {
    // Pairs (r, B): larger r first, then smaller B — the order in which the
    // statement gets stronger. Entries without a readable pair go last.
    return selected.map(entry => ({
      entry,
      universal: entry.parameter.trim() === "universal",
      value: natural(entry.parameter),
      bound: natural(entry.bound),
    })).sort((a, b) => {
      if (a.universal !== b.universal) return a.universal ? -1 : 1;
      if (a.value !== null && b.value !== null && a.value !== b.value) {
        return a.value > b.value ? -1 : 1;
      }
      if ((a.value === null) !== (b.value === null)) return a.value === null ? 1 : -1;
      if (a.bound !== null && b.bound !== null && a.bound !== b.bound) {
        return a.bound < b.bound ? -1 : 1;
      }
      if ((a.bound === null) !== (b.bound === null)) return a.bound === null ? 1 : -1;
      return a.entry.rank - b.entry.rank;
    }).map(({ entry }, index) => ({ ...entry, displayRank: index + 1 }));
  }
  if (!naturalChallenges.has(tab)) {
    return selected.map(entry => ({ ...entry, displayRank: entry.rank }));
  }

  return selected.map(entry => {
    const parameter = entry.parameter.trim();
    return {
      entry,
      universal: parameter === "universal",
      value: /^[0-9]+$/.test(parameter) ? BigInt(parameter) : null,
    };
  }).sort((a, b) => {
    // Results settling the full conjecture precede its individual parameters.
    if (a.universal !== b.universal) return a.universal ? -1 : 1;
    if (a.value !== null && b.value !== null && a.value !== b.value) {
      return a.value > b.value ? -1 : 1;
    }
    if ((a.value === null) !== (b.value === null)) return a.value === null ? 1 : -1;
    return a.entry.rank - b.entry.rank;
  }).map(({ entry }, index) => ({ ...entry, displayRank: index + 1 }));
}
