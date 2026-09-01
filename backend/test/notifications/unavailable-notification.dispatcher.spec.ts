import { jest } from '@jest/globals';
import { Logger } from '@nestjs/common';

import { UnavailableNotificationDispatcher } from '../../src/modules/notifications/dispatch/unavailable-notification.dispatcher';

describe('UnavailableNotificationDispatcher', () => {
  it('resolves without throwing and logs intent rather than claiming delivery', async () => {
    const logSpy = jest
      .spyOn(Logger.prototype, 'log')
      .mockImplementation(() => undefined);
    const dispatcher = new UnavailableNotificationDispatcher();

    await expect(
      dispatcher.dispatch({
        userId: 'user-1',
        type: 'content.published',
        title: 'New song',
        body: 'A new song is available',
      }),
    ).resolves.toBeUndefined();

    expect(logSpy).toHaveBeenCalledWith(
      expect.objectContaining({ event: 'would_dispatch', userId: 'user-1' }),
    );
    logSpy.mockRestore();
  });
});
