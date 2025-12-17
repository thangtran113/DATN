export interface Movie {
  id: number;
  title: string;
  description: string;
  rating: number;
  level: 'Beginner' | 'Intermediate' | 'Advanced';
  coverUrl: string;
  backdropUrl: string;
  year: number;
  duration: string;
}

export interface CastMember {
  name: string;
  role?: string;
  imageUrl: string;
}

export interface Comment {
  id: number;
  user: string;
  avatarUrl: string;
  timeAgo: string;
  content: string;
  likes: number;
  dislikes: number;
}

export interface VocabWord {
  id: number;
  word: string;
  definitionEn: string;
  definitionVn: string;
  sourceImage: string;
  level: number; // 0-100
  mastery: 'new' | 'learning' | 'mastered';
}

export interface QuizQuestion {
  id: number;
  question: string;
  contextImage: string;
  options: string[];
  correctIndex: number;
}
