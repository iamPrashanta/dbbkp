import Redis from "ioredis";
import { exec } from "child_process";

// Configuration
const REDIS_HOST = process.env.REDIS_HOST || "127.0.0.1";
const REDIS_PORT = process.env.REDIS_PORT || 6379;
const REDIS_PASS = process.env.REDIS_PASS || "";

// Establish connection
const redis = new Redis({
  host: REDIS_HOST,
  port: REDIS_PORT,
  password: REDIS_PASS || undefined,
});

console.log("🚀 Infra Worker Started. Listening for events...");

async function start() {
  while (true) {
    try {
      // 1. BLPOP from the events queue (0 = block indefinitely)
      const res = await redis.blpop("infra:events", 0);
      if (!res) continue;

      const eventRaw = res[1];
      const event = JSON.parse(eventRaw);

      console.log(`\n[EVENT] ${event.type} from ${event.node} (Risk: ${event.risk_score})`);

      // 2. Idempotency Check (prevent duplicate reactions)
      const crypto = await import("crypto");
      const eventId = crypto.createHash("sha1").update(eventRaw).digest("hex");
      
      const isProcessed = await redis.setnx(`infra:event:processed:${eventId}`, 1);
      if (!isProcessed) {
        console.log(`  ↳ Skipping. Event already processed.`);
        continue;
      }
      
      // Set TTL on the processed key so it doesn't leak memory forever (e.g., 24h)
      await redis.expire(`infra:event:processed:${eventId}`, 86400);

      // 3. Automation Rules
      if (event.type === "HIGH_RISK_DETECTED") {
        // Rate Limiting (ensure we don't spam backups)
        const canBackup = await redis.set("infra:lock:backup", "1", "EX", 300, "NX");
        
        if (canBackup) {
          console.log(`  ↳ 🚨 Triggering emergency headless dbbkp for ${event.node}...`);
          
          exec("dbbkp --headless --mode=mysql-backup", (err, stdout, stderr) => {
            if (err) {
              console.error(`  ↳ ❌ Backup failed:`, err.message);
              return;
            }
            console.log(`  ↳ ✅ Backup completed successfully.`);
          });
        } else {
          console.log(`  ↳ ⏳ Backup locked (rate limited). Skipping dbbkp trigger.`);
        }
      }

    } catch (err) {
      console.error("[ERROR] Worker exception:", err.message);
      // Brief pause on error to prevent CPU thrashing
      await new Promise(resolve => setTimeout(resolve, 5000));
    }
  }
}

start();
