export interface AccountDeletionRequest {
  firebaseUid: string;
  requestedAt: string;
  recentAuthConfirmed: boolean;
}

export interface AccountDeletionResult {
  status: "accepted";
  firebaseUid: string;
  requestedAt: string;
}

export class RecentAuthenticationRequiredError extends Error {
  constructor() {
    super("Recent authentication is required before deleting the account.");
  }
}

export interface AccountDeletionService {
  requestDeletion(input: AccountDeletionRequest): Promise<AccountDeletionResult>;
}

export class InMemoryAccountDeletionService implements AccountDeletionService {
  private readonly requests = new Map<string, AccountDeletionResult>();

  async requestDeletion(
    input: AccountDeletionRequest,
  ): Promise<AccountDeletionResult> {
    if (!input.recentAuthConfirmed) {
      throw new RecentAuthenticationRequiredError();
    }

    const result: AccountDeletionResult = {
      status: "accepted",
      firebaseUid: input.firebaseUid,
      requestedAt: input.requestedAt,
    };
    this.requests.set(input.firebaseUid, result);
    return result;
  }

  getRequest(firebaseUid: string): AccountDeletionResult | null {
    return this.requests.get(firebaseUid) ?? null;
  }
}

export const defaultAccountDeletionService =
  new InMemoryAccountDeletionService();
