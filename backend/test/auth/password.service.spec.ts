import { PasswordService } from '../../src/modules/auth/password.service';

describe('PasswordService', () => {
  const service = new PasswordService();

  it('produces a hash that verifies against the original password', async () => {
    const hash = await service.hash('correct horse battery staple');
    await expect(
      service.verify(hash, 'correct horse battery staple'),
    ).resolves.toBe(true);
  });

  it('rejects a wrong password', async () => {
    const hash = await service.hash('correct horse battery staple');
    await expect(service.verify(hash, 'wrong password')).resolves.toBe(false);
  });

  it('salts: hashing the same password twice yields different hashes', async () => {
    const [a, b] = await Promise.all([
      service.hash('same password'),
      service.hash('same password'),
    ]);
    expect(a).not.toBe(b);
  });
});
