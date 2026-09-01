import { Notification } from '@prisma/client';

export class NotificationResponseDto {
  id!: string;
  type!: string;
  title!: string;
  body!: string;
  data!: unknown;
  readAt!: Date | null;
  createdAt!: Date;
}

export function toNotificationResponse(
  notification: Notification,
): NotificationResponseDto {
  return {
    id: notification.id,
    type: notification.type,
    title: notification.title,
    body: notification.body,
    data: notification.data,
    readAt: notification.readAt,
    createdAt: notification.createdAt,
  };
}
