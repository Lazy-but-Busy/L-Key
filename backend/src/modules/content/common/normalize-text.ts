/**
 * NFC-normalizes user-entered text before it's stored. Myanmar Unicode can
 * encode the same visible text with different byte sequences (CLAUDE.md
 * §32); normalizing on write keeps `contains` search consistent regardless
 * of which sequence a client sent.
 */
export function normalizeText<T extends string | undefined>(value: T): T {
  return (value?.normalize('NFC') ?? value) as T;
}
