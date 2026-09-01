import { Module } from '@nestjs/common';

import { NOTIFICATION_DISPATCHER } from './dispatch/notification-dispatcher.interface';
import { UnavailableNotificationDispatcher } from './dispatch/unavailable-notification.dispatcher';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';

@Module({
  controllers: [NotificationsController],
  providers: [
    NotificationsService,
    {
      provide: NOTIFICATION_DISPATCHER,
      useClass: UnavailableNotificationDispatcher,
    },
  ],
  exports: [NotificationsService],
})
export class NotificationsModule {}
