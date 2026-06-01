// 로컬 테스트용 초간단 정적 서버 (외부 설치 불필요, Node 내장 기능만 사용)
// 실행:  node serve.js     →  브라우저에서 http://localhost:8000 접속
// 종료:  터미널에서 Ctrl + C
import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { extname, join, normalize } from "node:path";

const PORT = 8000;
const ROOT = process.cwd();
const TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js":   "text/javascript; charset=utf-8",
  ".css":  "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg":  "image/svg+xml",
  ".png":  "image/png",
  ".jpg":  "image/jpeg",
  ".ico":  "image/x-icon",
};

createServer(async (req, res) => {
  try {
    let urlPath = decodeURIComponent(new URL(req.url, "http://localhost").pathname);
    if (urlPath === "/") urlPath = "/index.html";
    // 상위 폴더 접근(../) 차단
    const filePath = join(ROOT, normalize(urlPath).replace(/^(\.\.[/\\])+/, ""));
    const body = await readFile(filePath);
    res.writeHead(200, { "Content-Type": TYPES[extname(filePath)] || "application/octet-stream" });
    res.end(body);
  } catch {
    res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
    res.end("404 Not Found");
  }
}).listen(PORT, "127.0.0.1", () => {
  console.log(`로컬 서버 실행 중 → http://localhost:${PORT}  (종료: Ctrl+C)`);
});
