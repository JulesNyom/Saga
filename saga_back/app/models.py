from typing import List, Optional
from pydantic import BaseModel

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

class HomePageResponse(BaseModel):
    featured_books: List[AudioBook]
    recent_books: List[AudioBook]

class PopularBooksResponse(BaseModel):
    featured_books: List[AudioBook]
    recent_books: List[AudioBook]
    page: int
    total_pages: int