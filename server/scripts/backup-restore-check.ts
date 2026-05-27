import { spawn } from "node:child_process";
import { mkdtemp, rm } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";

const sourceUrl = process.env.DATABASE_URL;
const restoreUrl = process.env.RESTORE_DATABASE_URL;

async function main() {
  if (!sourceUrl || !restoreUrl) {
    console.error(
      "DATABASE_URL and RESTORE_DATABASE_URL are required. RESTORE_DATABASE_URL must point to a disposable restore-check database.",
    );
    process.exitCode = 1;
    return;
  }
  if (sourceUrl === restoreUrl) {
    console.error("Refusing to restore into DATABASE_URL. Use a separate restore-check database.");
    process.exitCode = 2;
    return;
  }

  const workspace = await mkdtemp(join(tmpdir(), "ai-expenses-restore-"));
  const dumpPath = join(workspace, "backup.dump");
  try {
    await run("pg_dump", ["--format=custom", "--no-owner", "--file", dumpPath, sourceUrl]);
    await run("pg_restore", [
      "--clean",
      "--if-exists",
      "--no-owner",
      "--dbname",
      restoreUrl,
      dumpPath,
    ]);
    await run("psql", [
      restoreUrl,
      "--tuples-only",
      "--no-align",
      "--command",
      "select 1;",
    ]);
    console.log(
      JSON.stringify(
        {
          status: "ok",
          checkedAt: new Date().toISOString(),
          restoredInto: "RESTORE_DATABASE_URL",
        },
        null,
        2,
      ),
    );
  } finally {
    await rm(workspace, { recursive: true, force: true });
  }
}

function run(command: string, args: string[]): Promise<void> {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, { stdio: "inherit", shell: process.platform === "win32" });
    child.on("error", reject);
    child.on("exit", (code) => {
      if (code === 0) {
        resolve();
        return;
      }
      reject(new Error(`${command} exited with code ${code}`));
    });
  });
}

await main();
