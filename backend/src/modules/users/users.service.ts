import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../common/prisma/prisma.service';
import { ProfileResponseDto } from './dto/profile-response.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async getProfile(userId: string): Promise<ProfileResponseDto> {
    const [user, profile] = await Promise.all([
      this.prisma.user.findUniqueOrThrow({ where: { id: userId } }),
      this.prisma.userProfile.findUnique({ where: { userId } }),
    ]);
    return {
      displayName: profile?.displayName ?? null,
      avatarUrl: profile?.avatarUrl ?? null,
      memberSince: user.createdAt,
    };
  }

  async updateProfile(
    userId: string,
    dto: UpdateProfileDto,
  ): Promise<ProfileResponseDto> {
    const profile = await this.prisma.userProfile.upsert({
      where: { userId },
      create: { userId, ...dto },
      update: dto,
    });
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
    });
    return {
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl,
      memberSince: user.createdAt,
    };
  }
}
