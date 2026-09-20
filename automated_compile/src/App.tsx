import { useEffect, useState } from "react";
import { problems, type Problem } from "@/data/problems";
import { ordinalSummary } from "@/ordinals";
import { leaderboardRows } from "@/leaderboard";

const SUBMISSIONS_REPO = "utkuokur/ten-challenges-submissions";
const LEAN_VERSION = import.meta.env.VITE_LEAN_VERSION;
const MATHLIB_REVISION = import.meta.env.VITE_MATHLIB_REVISION;

/** Public raw URL of the leaderboard JSON maintained by the submissions repo CI. */
const LEADERBOARD_URL =
  `https://raw.githubusercontent.com/${SUBMISSIONS_REPO}/main/site-data/leaderboard.json`;

interface LeaderboardEntry {
  rank: number;
  nickname: string;
  name?: string;
  problem: string;
  claim: string;
  parameter: string;
  /** Present only for the usual ordinal notation normalized by the checker. */
  ordinal_cnf?: unknown;
  date?: string;
  /** Public link to the proof. Empty/absent for private submissions. */
  source_url?: string;
  /** Whether the source was public at eval time. Absent on older entries
   *  (predating private submissions); treated as public. */
  submission_public?: boolean;
}

/** Compose the issue-template URL for a specific-r submission. */
function buildSpecificUrl(args: {
  problemId: string;
  parameter: string;
  nickname: string;
  fullName: string;
}): string {
  const params = new URLSearchParams();
  params.set("problem_id", args.problemId);
  params.set("parameter", args.parameter);
  params.set("nickname", args.nickname);
  if (args.fullName) params.set("full_name", args.fullName);
  return `https://github.com/${SUBMISSIONS_REPO}/issues/new?template=submit-specific.yml&${params.toString()}`;
}

/** Compose the issue-template URL for a universal (∀r) submission. */
function buildUniversalUrl(args: {
  problemId: string;
  claim: string;
  nickname: string;
  fullName: string;
}): string {
  const params = new URLSearchParams();
  params.set("problem_id", args.problemId);
  params.set("claim", args.claim);
  params.set("nickname", args.nickname);
  if (args.fullName) params.set("full_name", args.fullName);
  return `https://github.com/${SUBMISSIONS_REPO}/issues/new?template=submit-universal.yml&${params.toString()}`;
}

function App() {
  const [openProblemId, setOpenProblemId] = useState<string | null>(null);
  const [activeLbTab, setActiveLbTab] = useState("all");

  // State for the "Prove special case (specific r)" form
  const [specNickname, setSpecNickname] = useState("");
  const [specName, setSpecName] = useState("");
  const [specProblem, setSpecProblem] = useState("");
  const [specParameter, setSpecParameter] = useState("");

  // State for the "Prove or disprove full conjecture" form
  const [univNickname, setUnivNickname] = useState("");
  const [univName, setUnivName] = useState("");
  const [univProblem, setUnivProblem] = useState("");
  const [univClaim, setUnivClaim] = useState("");

  // Leaderboard is read directly from the submissions repo's public JSON —
  // no backend required, so the site can be served as a static page.
  const [submissions, setSubmissions] = useState<LeaderboardEntry[]>([]);
  useEffect(() => {
    fetch(LEADERBOARD_URL)
      .then((res) => (res.ok ? res.json() : { entries: [] }))
      .then((data: { entries?: LeaderboardEntry[] }) =>
        setSubmissions(data.entries ?? [])
      )
      .catch(() => setSubmissions([]));
  }, []);

  const toggleProblem = (id: string) => {
    setOpenProblemId((prev) => (prev === id ? null : id));
  };

  // Challenge tabs rank larger recognized parameters first. The overall
  // list keeps recording order; unsupported ordinals remain unranked.
  const lbEntries = leaderboardRows(submissions, activeLbTab)
    .map((s) => ({
      rank: s.displayRank,
      recordRank: s.rank,
      nickname: s.nickname,
      name: s.name || "",
      problem: s.problem,
      result: s.parameter === "universal"
        ? (s.claim === "prove" ? "proven universally" : "fails for some r")
        : `${s.claim === "prove" ? "holds" : "fails"} for r = ${s.parameter}`,
      date: s.date || "",
      sourceUrl: s.source_url || "",
      // Missing submission_public (older entries) is treated as public.
      isPublic: s.submission_public !== false,
    }));

  // Show the largest natural parameter or the latest recorded ordinal parameter.
  const parameterSummary = (problem: Problem): string => {
    const ordinal = problem.id === "challenge_6" || problem.id === "challenge_10";
    const label = ordinal ? "latest r" : "largest r so far";
    if (
      submissions.some(
        (s) => s.problem === `${problem.id}_univ` && s.claim === "prove"
      )
    ) {
      return `${label}: all r`;
    }
    if (ordinal) {
      return ordinalSummary(submissions.filter(
        (s) => s.problem === problem.id && s.claim === "prove"
      ));
    }
    let best: bigint | null = null;
    for (const s of submissions) {
      if (s.problem !== problem.id || s.claim !== "prove") continue;
      const parameter = s.parameter.trim();
      if (!/^\d+$/.test(parameter)) continue;
      const r = BigInt(parameter);
      if (best === null || r > best) best = r;
    }
    return `${label}: ${best === null ? "N/A" : `r = ${best}`}`;
  };

  const specificGitHubUrl = buildSpecificUrl({
    problemId: specProblem,
    parameter: specParameter,
    nickname: specNickname,
    fullName: specName,
  });

  const universalGitHubUrl = buildUniversalUrl({
    problemId: univProblem,
    claim: univClaim,
    nickname: univNickname,
    fullName: univName,
  });

  return (
    <>
      {/* Header */}
      <header className="header">
        <nav>
          <ul className="header-nav">
            <li><a href="#problems">Problems</a></li>
            <li><a href="#leaderboard">Leaderboard</a></li>
            <li><a href="#submit">Submit</a></li>
            <li><a href="#contact">Contact</a></li>
          </ul>
        </nav>
      </header>

      <main className="main">
        {/* Intro */}
        <section className="intro">
          <h1 style={{ fontSize: 28, fontWeight: "normal", fontStyle: "italic", marginBottom: 16, lineHeight: 1.3 }}>
            Ten Challenges
          </h1>
          <p style={{ fontSize: 16, color: "#333", maxWidth: 640 }}>
            Parameterized open problems in combinatorics, formalized in Lean 4.
          </p>
          <p style={{ fontSize: 14, color: "#555", marginTop: 12 }}>
            <a href={`https://github.com/leanprover/lean4/releases/tag/${LEAN_VERSION}`}>
              Lean {LEAN_VERSION.replace(/^v/, "")}
            </a>
            {" · "}
            <a
              href={`https://github.com/leanprover-community/mathlib4/commit/${MATHLIB_REVISION}`}
              title={MATHLIB_REVISION}
            >
              Mathlib <code>{MATHLIB_REVISION.slice(0, 12)}</code>
            </a>
          </p>
        </section>

        {/* Problems */}
        <section id="problems">
          <h2 className="section-heading">Open Problems</h2>
          <p style={{ fontSize: 15, color: "#333", marginBottom: 20 }}>
            Click a problem to view its statement and details.
          </p>
          <div>
            {problems.map((p) => (
              <div key={p.id}>
                <div
                  className={`problem-item ${openProblemId === p.id ? "active" : ""}`}
                  onClick={() => toggleProblem(p.id)}
                >
                  <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", gap: 16, flexWrap: "wrap" }}>
                    <span style={{ fontSize: 16, fontWeight: "bold" }}>{p.title}</span>
                    <span style={{ fontSize: 13, color: "#555", fontFamily: '"Courier New", Courier, monospace' }}>
                      {parameterSummary(p)}
                    </span>
                  </div>
                </div>
                <div className={`detail-panel ${openProblemId === p.id ? "active" : ""}`}>
                  <span
                    style={{ fontSize: 13, color: "#555", cursor: "pointer", marginBottom: 16, display: "inline-block", fontFamily: '"Courier New", Courier, monospace' }}
                    onClick={(e) => { e.stopPropagation(); setOpenProblemId(null); }}
                  >
                    &larr; back to list
                  </span>
                  <h3>{p.title}</h3>
                  <iframe
                    src={`${import.meta.env.BASE_URL}${p.htmlPath}`}
                    style={{ width: "100%", height: "600px", border: "1px solid #ddd", borderRadius: "4px", marginBottom: "12px" }}
                    title={`${p.title} – full problem statement`}
                  />
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Leaderboard */}
        <section id="leaderboard">
          <h2 className="section-heading">Leaderboard</h2>
          <div style={{ display: "flex", gap: 4, marginBottom: 16, flexWrap: "wrap" }}>
            <button
              className={`lb-tab ${activeLbTab === "all" ? "active" : ""}`}
              onClick={() => setActiveLbTab("all")}
            >
              All
            </button>
            {problems.map((p) => (
              <button
                key={p.id}
                className={`lb-tab ${activeLbTab === p.id ? "active" : ""}`}
                onClick={() => setActiveLbTab(p.id)}
              >
                {p.title}
              </button>
            ))}
          </div>
          {lbEntries.some(row => row.rank === null) && (
            <p style={{ fontSize: 13, color: "#555" }}>
              Entries marked “—” await ordinal comparison and are not ranked.
            </p>
          )}
          <table className="data-table">
            <thead>
              <tr>
                <th>Rank</th>
                <th>Nickname</th>
                <th>Name</th>
                <th>Problem</th>
                <th>Result</th>
                <th>Date</th>
                <th>Proof</th>
              </tr>
            </thead>
            <tbody>
              {lbEntries.length === 0 ? (
                <tr>
                  <td colSpan={7} style={{ textAlign: "center", color: "#888", padding: "20px" }}>
                    No submissions yet.
                  </td>
                </tr>
              ) : (
                lbEntries.map((row) => (
                  <tr key={row.recordRank + row.nickname + row.problem}>
                    <td>{row.rank ?? "—"}</td>
                    <td>{row.nickname}</td>
                    <td style={{ color: row.name ? "#000" : "#888" }}>
                      {row.name || "—"}
                    </td>
                    <td>{row.problem}</td>
                    <td>{row.result}</td>
                    <td>{row.date}</td>
                    <td>
                      {row.isPublic ? (
                        row.sourceUrl ? (
                          <a href={row.sourceUrl} target="_blank" rel="noreferrer">
                            view
                          </a>
                        ) : (
                          <span style={{ color: "#888" }}>—</span>
                        )
                      ) : (
                        <span
                          style={{
                            fontSize: 12,
                            color: "#666",
                            background: "#eee",
                            borderRadius: 4,
                            padding: "2px 6px",
                          }}
                        >
                          private
                        </span>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </section>

        {/* Submit */}
        <section id="submit">
          <h2 className="section-heading">Submission</h2>
          <div style={{ fontSize: 15, color: "#333", marginBottom: 24, maxWidth: 720, lineHeight: 1.7 }}>
            <p style={{ marginBottom: 12 }}>
              Your Lean 4 proof must compile without errors and without any <code>sorry</code>.
            </p>
            <ol style={{ margin: 0, paddingLeft: 20, listStyleType: "decimal" }}>
              <li style={{ marginBottom: 12 }}>
                Clone the problem set —{" "}
                <a
                  href="https://github.com/TenChallenges/ten-challenges"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  github.com/TenChallenges/ten-challenges
                </a>{" "}
                — and put your solution in the <code>Submission/</code> folder.
              </li>
              <li style={{ marginBottom: 12 }}>
                <code>Submission/</code> must contain <code>Main.lean</code> (with the relevant{" "}
                <code>r</code> and <code>theorem challenge_N</code> inside{" "}
                <code>namespace Submission</code>), plus any helpers as{" "}
                <code>Submission/&lt;Name&gt;.lean</code>.
              </li>
              <li style={{ marginBottom: 12 }}>
                Push to your own GitHub repository. It can be public, or{" "}
                <strong>private</strong> — a private repo needs the{" "}
                <a
                  href="https://github.com/apps/ten-challenges-bot"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <code>ten-challenges-bot</code>
                </a>{" "}
                GitHub App so the CI can clone it. To install: open that page, click{" "}
                <strong>Install</strong>, choose your account, select{" "}
                <strong>Only select repositories → your submission repo</strong>, and
                confirm. (It needs only <strong>Contents: Read</strong>; you can later
                check it under your repo’s <strong>Settings → GitHub Apps</strong>.)
              </li>
              <li style={{ marginBottom: 12 }}>
                Pick the option below that matches your proof and fill in the submission form. It opens
                a pre-filled GitHub issue, asking for the <strong>Repository URL</strong> of your proof.
              </li>
            </ol>
            <p style={{ marginTop: 16 }}>
              To keep proofs usable as Lean and its libraries evolve, the submission form asks
              for permission to maintain compatible copies of your code. See:{" "}
              <a href={`https://github.com/${SUBMISSIONS_REPO}/blob/main/docs/maintenance-policy.md`}>
                Maintenance policy
              </a>
              .
            </p>
          </div>

          {/* Option 1: Prove special case (specific r) */}
          <div className="submit-section">
            <h3 style={{ fontSize: 17, marginBottom: 8 }}>Prove special case</h3>
            <p style={{ fontSize: 14, color: "#555", marginBottom: 20 }}>
              Submit a proof for a <strong>specific value</strong> of the parameter <code>r</code>.
              For example, prove the bound holds for <code>r = 5</code>.
            </p>

            <div className="form-row">
              <div className="form-group">
                <label className="form-label">Nickname *</label>
                <input
                  className="form-input"
                  type="text"
                  value={specNickname}
                  onChange={(e) => setSpecNickname(e.target.value)}
                  placeholder="e.g. lean_enjoyer"
                />
              </div>
              <div className="form-group">
                <label className="form-label">
                  Name & Surname{" "}
                  <span style={{ color: "#888", textTransform: "none", letterSpacing: 0, fontSize: 11 }}>
                    (optional)
                  </span>
                </label>
                <input
                  className="form-input"
                  type="text"
                  value={specName}
                  onChange={(e) => setSpecName(e.target.value)}
                  placeholder=""
                />
              </div>
            </div>

            <div className="form-row three-col">
              <div className="form-group">
                <label className="form-label">Problem *</label>
                <select
                  className="form-input"
                  value={specProblem}
                  onChange={(e) => setSpecProblem(e.target.value)}
                >
                  <option value="">Select a problem...</option>
                  {problems.map((p, i) => (
                    <option key={p.id} value={p.id}>{`${i + 1}. ${p.title}`}</option>
                  ))}
                </select>
              </div>
              <div className="form-group">
                <label className="form-label">Chosen parameter r *</label>
                <input
                  className="form-input"
                  type="text"
                  value={specParameter}
                  onChange={(e) => setSpecParameter(e.target.value)}
                  placeholder="e.g. 5"
                />
              </div>
            </div>

            <div style={{ display: "flex", justifyContent: "center", marginTop: 24 }}>
              <a
                className="btn"
                href={specificGitHubUrl}
                target="_blank"
                rel="noopener noreferrer"
              >
                Submit on GitHub &rarr;
              </a>
            </div>
          </div>

          {/* Option 2: Prove or disprove full universal conjecture (really?) */}
          <div className="submit-section" style={{ marginTop: 32 }}>
            <h3 style={{ fontSize: 17, marginBottom: 8 }}>Prove or disprove the full conjecture (really?)</h3>
            <p style={{ fontSize: 14, color: "#555", marginBottom: 20 }}>
              Settle the <strong>universal</strong> (&forall;r) version of a challenge —
              either prove the conjecture holds for all parameters, or disprove it by exhibiting a
              counterexample.
            </p>

            <div className="form-row">
              <div className="form-group">
                <label className="form-label">Nickname *</label>
                <input
                  className="form-input"
                  type="text"
                  value={univNickname}
                  onChange={(e) => setUnivNickname(e.target.value)}
                  placeholder="e.g. lean_enjoyer"
                />
              </div>
              <div className="form-group">
                <label className="form-label">
                  Name & Surname{" "}
                  <span style={{ color: "#888", textTransform: "none", letterSpacing: 0, fontSize: 11 }}>
                    (optional)
                  </span>
                </label>
                <input
                  className="form-input"
                  type="text"
                  value={univName}
                  onChange={(e) => setUnivName(e.target.value)}
                  placeholder=""
                />
              </div>
            </div>

            <div className="form-row three-col">
              <div className="form-group">
                <label className="form-label">Problem *</label>
                <select
                  className="form-input"
                  value={univProblem}
                  onChange={(e) => setUnivProblem(e.target.value)}
                >
                  <option value="">Select a problem...</option>
                  {problems.map((p, i) => p.id !== "challenge_2" && (
                    <option key={p.id} value={p.id}>{`${i + 1}. ${p.title}`}</option>
                  ))}
                </select>
              </div>
              <div className="form-group">
                <label className="form-label">Claim *</label>
                <select
                  className="form-input"
                  value={univClaim}
                  onChange={(e) => setUnivClaim(e.target.value)}
                >
                  <option value="">Prove or Disprove...</option>
                  <option value="prove">Prove</option>
                  <option value="disprove">Disprove</option>
                </select>
              </div>
            </div>

            <div style={{ display: "flex", justifyContent: "center", marginTop: 24 }}>
              <a
                className="btn"
                href={universalGitHubUrl}
                target="_blank"
                rel="noopener noreferrer"
              >
                Submit on GitHub &rarr;
              </a>
            </div>
          </div>
        </section>

        {/* Contact */}
        <section id="contact">
          <h2 className="section-heading">Contact</h2>
          <p style={{ fontSize: 15, color: "#333", maxWidth: 720, lineHeight: 1.7 }}>
            For issues and recommendations, please email{" "}
            <a href="mailto:utkuokur@gmail.com">utkuokur@gmail.com</a> or{" "}
            <a href="mailto:vaibhav.bajpai@math.tu-freiberg.de">
              vaibhav.bajpai@math.tu-freiberg.de
            </a>
            .
          </p>
        </section>
      </main>

      <footer className="footer">
        <span>Ten Challenges</span>
        <span>Built for the formal mathematics community</span>
      </footer>
    </>
  );
}

export default App;
