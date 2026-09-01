import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../../common/prisma/prisma.service';
import { PaginatedResult } from '../content/common/paginated-result';
import {
  NOTIFICATION_DISPATCHER,
  NotificationDispatcher,
} from './dispatch/notification-dispatcher.interface';
import { NotificationQueryDto } from './dto/notification-query.dto';
import {
  NotificationResponseDto,
  toNotificationResponse,
} from './dto/notification-response.dto';

@Injectable()
export class NotificationsService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(NOTIFICATION_DISPATCHER)
    private readonly dispatcher: NotificationDispatcher,
  ) {}

  async list(
    userId: string,
    query: NotificationQueryDto,
  ): Promise<PaginatedResult<NotificationResponseDto>> {
    const where = {
      userId,
      ...(query.unreadOnly ? { readAt: null } : {}),
    };
    const [items, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        skip: (query.page - 1) * query.pageSize,
        take: query.pageSize,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.notification.count({ where }),
    ]);
    return {
      items: items.map(toNotificationResponse),
      total,
      page: query.page,
      pageSize: query.pageSize,
    };
  }

  async markRead(
    userId: string,
    id: string,
  ): Promise<NotificationResponseDto> {
    const existing = await this.prisma.notification.findUnique({
      where: { id },
    });
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException();
    }
    const notification = await this.prisma.notification.update({
      where: { id },
      data: { readAt: existing.readAt ?? new Date() },
    });
    return toNotificationResponse(notification);
  }

  /**
   * Internal — called programmatically by other modules once something
   * triggers a notification (none does yet in Phase 09). Writes the real
   * inbox row, then hands off to the (currently stubbed) delivery channel.
   */
  async create(input: {
    userId: string;
    type: string;
    title: string;
    body: string;
    data?: unknown;
  }): Promise<NotificationResponseDto> {
    const notification = await this.prisma.notification.create({
      data: {
        userId: input.userId,
        type: input.type,
        title: input.title,
        body: input.body,
        data: input.data as Prisma.InputJsonValue | undefined,
      },
    });
    await this.dispatcher.dispatch({
      userId: input.userId,
      type: input.type,
      title: input.title,
      body: input.body,
    });
    return toNotificationResponse(notification);
  }
}
