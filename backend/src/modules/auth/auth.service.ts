import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthProvider } from '@prisma/client';

import { PrismaService } from '../../common/prisma/prisma.service';
import { AuthResponseDto } from './dto/auth-response.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { PasswordService } from './password.service';
import { TokenService } from './token.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly passwordService: PasswordService,
    private readonly tokenService: TokenService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthResponseDto> {
    const existing = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });
    if (existing) throw new ConflictException('Email already registered');

    const passwordHash = await this.passwordService.hash(dto.password);

    const user = await this.prisma.$transaction(async (tx) => {
      const created = await tx.user.create({
        data: { email: dto.email, name: dto.displayName },
      });
      await tx.authCredential.create({
        data: { userId: created.id, provider: AuthProvider.EMAIL, passwordHash },
      });
      await tx.userProfile.create({
        data: { userId: created.id, displayName: dto.displayName },
      });
      await tx.userPreferences.create({ data: { userId: created.id } });
      return created;
    });

    const tokens = await this.tokenService.issueTokenPair(
      user.id,
      user.adminRole ?? undefined,
    );
    return {
      ...tokens,
      user: { id: user.id, email: user.email },
    };
  }

  async login(dto: LoginDto): Promise<AuthResponseDto> {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });
    if (!user) throw new UnauthorizedException('Invalid credentials');

    const credential = await this.prisma.authCredential.findUnique({
      where: {
        userId_provider: { userId: user.id, provider: AuthProvider.EMAIL },
      },
    });
    if (!credential?.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const valid = await this.passwordService.verify(
      credential.passwordHash,
      dto.password,
    );
    if (!valid) throw new UnauthorizedException('Invalid credentials');

    const tokens = await this.tokenService.issueTokenPair(
      user.id,
      user.adminRole ?? undefined,
    );
    return {
      ...tokens,
      user: { id: user.id, email: user.email },
    };
  }

  async refresh(
    refreshToken: string,
  ): Promise<Omit<AuthResponseDto, 'user'>> {
    return this.tokenService.rotateTokenPair(refreshToken);
  }

  async logout(refreshToken: string): Promise<void> {
    await this.tokenService.revoke(refreshToken);
  }

  async me(userId: string): Promise<{
    id: string;
    email: string | null;
    status: string;
  }> {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
    });
    return { id: user.id, email: user.email, status: user.status };
  }
}
