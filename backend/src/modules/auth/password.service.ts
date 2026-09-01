import { Injectable } from '@nestjs/common';
import * as argon2 from 'argon2';

/**
 * Isolated so `AuthService` never calls argon2 directly — keeps hashing
 * mockable in unit tests and gives password policy exactly one home.
 */
@Injectable()
export class PasswordService {
  async hash(plain: string): Promise<string> {
    return argon2.hash(plain);
  }

  async verify(hash: string, plain: string): Promise<boolean> {
    return argon2.verify(hash, plain);
  }
}
