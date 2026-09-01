/** Never includes `passwordHash` or any other credential material. */
export class AuthUserDto {
  id!: string;
  email!: string | null;
}

export class AuthResponseDto {
  accessToken!: string;
  refreshToken!: string;
  user!: AuthUserDto;
}
