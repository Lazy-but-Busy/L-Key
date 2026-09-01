import { PartialType } from '@nestjs/mapped-types';

import { CreateChordDto } from './create-chord.dto';

export class UpdateChordDto extends PartialType(CreateChordDto) {}
