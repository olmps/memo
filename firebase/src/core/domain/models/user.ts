// import { defaultMaxStringLength, validate } from "#utils/validate";
// import * as Joi from "joi";
import { MemoContent } from "./memo";

interface CollectionExecutionMetadata {
  timeSpentInMillis: number;
  executionsDifficulty: Map<string, number>;
}

export interface CollectionCategory {
  id: string;
  name: string;
}

interface MemoExecution {
  id: string;
  marketDifficulty: string;
  started: Date;
  finished: Date;
  question: MemoContent[];
  answer: MemoContent[];
}

interface ExecutionMetadata {
  id: string;
  totalExecutions: number;
  lastExecution: Date;
  lastMarkedDifficulty: string;
}

export interface CollectionExecution extends CollectionExecutionMetadata {
  id: string;
  executionsAmount: number;
  uniqueExecutionsAmount: number;
  executions: Map<string, ExecutionMetadata>;
  memoExecutions: MemoExecution[];
}

export interface User extends CollectionExecutionMetadata {
  id: string;
  // TODO(ggirotto: What is this?)
  executionChunk: number;
}
