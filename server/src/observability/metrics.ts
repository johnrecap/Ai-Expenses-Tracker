export interface MetricSnapshot {
  uptimeSeconds: number;
  requests: {
    total: number;
    byStatusClass: Record<string, number>;
  };
  sync: {
    pushesAccepted: number;
    pushesRejected: number;
  };
}

class InMemoryMetrics {
  private readonly startedAt = Date.now();
  private requestTotal = 0;
  private readonly byStatusClass = new Map<string, number>();
  private pushesAccepted = 0;
  private pushesRejected = 0;

  recordRequest(statusCode: number) {
    this.requestTotal += 1;
    const statusClass = `${Math.floor(statusCode / 100)}xx`;
    this.byStatusClass.set(
      statusClass,
      (this.byStatusClass.get(statusClass) ?? 0) + 1,
    );
  }

  recordSyncPush(input: { accepted: number; rejected: number }) {
    this.pushesAccepted += input.accepted;
    this.pushesRejected += input.rejected;
  }

  snapshot(): MetricSnapshot {
    return {
      uptimeSeconds: Math.max(0, Math.floor((Date.now() - this.startedAt) / 1000)),
      requests: {
        total: this.requestTotal,
        byStatusClass: Object.fromEntries(this.byStatusClass.entries()),
      },
      sync: {
        pushesAccepted: this.pushesAccepted,
        pushesRejected: this.pushesRejected,
      },
    };
  }
}

export const metrics = new InMemoryMetrics();
