import type { MigrationRecord } from "./firestoreMappers.js";

export interface MigrationVerificationReport {
  sourceCount: number;
  targetCount: number;
  missing: string[];
  unexpected: string[];
  hashMismatches: string[];
  duplicateKeys: string[];
  warnings: string[];
  passed: boolean;
}

export function verifyMigrationRecords(
  source: MigrationRecord[],
  target: MigrationRecord[],
): MigrationVerificationReport {
  const sourceMap = new Map<string, MigrationRecord>();
  const targetMap = new Map<string, MigrationRecord>();
  const duplicateKeys: string[] = [];

  for (const record of source) {
    const key = keyFor(record);
    if (sourceMap.has(key)) duplicateKeys.push(key);
    sourceMap.set(key, record);
  }
  for (const record of target) {
    const key = keyFor(record);
    if (targetMap.has(key)) duplicateKeys.push(key);
    targetMap.set(key, record);
  }

  const missing: string[] = [];
  const unexpected: string[] = [];
  const hashMismatches: string[] = [];
  for (const [key, sourceRecord] of sourceMap) {
    const targetRecord = targetMap.get(key);
    if (!targetRecord) {
      missing.push(key);
      continue;
    }
    if (targetRecord.fieldHash !== sourceRecord.fieldHash) {
      hashMismatches.push(key);
    }
  }
  for (const key of targetMap.keys()) {
    if (!sourceMap.has(key)) {
      unexpected.push(key);
    }
  }
  const warnings = [];
  if (source.length !== target.length) {
    warnings.push(
      `Record count differs: source=${source.length}, target=${target.length}.`,
    );
  }

  return {
    sourceCount: source.length,
    targetCount: target.length,
    missing,
    unexpected,
    hashMismatches,
    duplicateKeys,
    warnings,
    passed:
      missing.length === 0 &&
      unexpected.length === 0 &&
      hashMismatches.length === 0 &&
      duplicateKeys.length === 0 &&
      source.length === target.length,
  };
}

export function formatMigrationVerificationReport(
  report: MigrationVerificationReport,
): string {
  return JSON.stringify(report, null, 2);
}

function keyFor(record: MigrationRecord): string {
  return `${record.userId}:${record.entityType}:${record.entityId}`;
}
