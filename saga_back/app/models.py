from typing import List, Optional
from pydantic import BaseModel

class AudioChapter(BaseModel):
    number: int
    title: str
    duration: str
    audio_url: str
    start_time: float = 0  # timestamp in seconds where this chapter starts

class AudioBook(BaseModel):
    id: str
    title: str
    author: str
    imageUrl: str
    duration: str
    views: str
    url: str
    narrator: Optional[str] = ""
    date: Optional[str] = ""
    description: Optional[str] = ""
    chapters: List[AudioChapter] = []
    
class HomePageResponse(BaseModel):
    featured_books: List[AudioBook]
    recent_books: List[AudioBook]

class PopularBooksResponse(BaseModel):
    featured_books: List[AudioBook]
    recent_books: List[AudioBook]
    page: int
    total_pages: int