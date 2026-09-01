export interface NotificationDispatchPayload {
  userId: string;
  type: string;
  title: string;
  body: string;
}

/**
 * The external delivery seam (push/email/SMS). CLAUDE.md §47: no fake
 * "delivered" claims — the in-app inbox row (`Notification`) is real,
 * working functionality; this interface is only for the channel beyond it,
 * which has no production implementation yet.
 */
export interface NotificationDispatcher {
  dispatch(payload: NotificationDispatchPayload): Promise<void>;
}

export const NOTIFICATION_DISPATCHER = Symbol('NOTIFICATION_DISPATCHER');
