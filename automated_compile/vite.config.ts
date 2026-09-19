import devServer from "@hono/vite-dev-server"
import path from "path"
import { readFileSync } from "node:fs"
const __dirname = import.meta.dirname
import react from "@vitejs/plugin-react"
import { defineConfig } from "vite"
import { inspectAttr } from 'kimi-plugin-inspect-react'

const projectRoot = path.resolve(__dirname, "..")
const leanVersion = readFileSync(path.join(projectRoot, "lean-toolchain"), "utf8")
  .trim().split(":").at(-1)!
const manifest = JSON.parse(readFileSync(path.join(projectRoot, "lake-manifest.json"), "utf8"))
const mathlib = manifest.packages.find((pkg: { name: string; rev: string }) => pkg.name === "mathlib")
if (!mathlib?.rev) throw new Error("The project manifest must pin a Mathlib revision.")

// https://vite.dev/config/
export default defineConfig(({ command, isPreview }) => ({
  define: {
    "import.meta.env.VITE_LEAN_VERSION": JSON.stringify(leanVersion),
    "import.meta.env.VITE_MATHLIB_REVISION": JSON.stringify(mathlib.rev),
  },
  // GitHub Pages serves this project site under /ten-challenges/.
  // `vite preview` must use the same base or the built asset URLs 404 and the
  // page renders blank. Only the dev server stays at the root.
  base: command === "build" || isPreview ? "/ten-challenges/" : "/",
  plugins: [
    devServer({ entry: "api/boot.ts", exclude: [/^\/(?!api\/).*$/] }),
    inspectAttr(), react()],
  server: {
    port: 3000,
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
      "@contracts": path.resolve(__dirname, "./contracts"),
      "@db": path.resolve(__dirname, "./db"),
      "db": path.resolve(__dirname, "./db"),
    },
  },
  envDir: path.resolve(__dirname),
  build: {
    outDir: path.resolve(__dirname, "dist/public"),
    emptyOutDir: true,
  },
}));
