import { Injectable, Logger } from '@nestjs/common';

import { redact } from '../../../common/interceptors/redact';
import {
  NotificationDispatchPayload,
  NotificationDispatcher,
} from './notification-dispatcher.interface';

/**
 * Honest stub (CLAUDE.md §47): no push/email/SMS provider is wired up yet.
 * Logs the intent to dispatch and returns — it never claims delivery
 * succeeded, mirroring `UnavailableEntitlementProvider`/`UnavailableAdProvider`
 * on the mobile side.
 */
@Injectable()
export class UnavailableNotificationDispatcher implements NotificationDispatcher {
  private readonly logger = new Logger(UnavailableNotificationDispatcher.name);

  async dispatch(payload: NotificationDispatchPayload): Promise<void> {
    this.logger.log(redact({ event: 'would_dispatch', ...payload }));
  }
}
