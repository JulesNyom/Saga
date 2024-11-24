from bs4 import BeautifulSoup
import requests
import re
from typing import Optional, Set, List
import html
import json
from .models import AudioBook, AudioChapter
from fastapi import HTTPException

class LitteratureAudioScraper:
    def __init__(self):
        self.base_url = 'https://www.litteratureaudio.com'
        self.popular_url = f"{self.base_url}/classement-de-nos-livres-audio-gratuits-les-plus-apprecies"
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        self.processed_ids: Set[str] = set()

    async def get_book_details(self, book_url: str) -> dict:
        """Fetch detailed book information including audio URLs."""
        try:
            response = requests.get(book_url, headers=self.headers, timeout=10)
            response.encoding = 'utf-8'
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'lxml')
            
            # Extract description
            description = soup.select_one('div.entry-content p')
            description_text = description.text.strip() if description else ""
            
            # Extract chapters and audio URLs
            chapters = []
            chapter_elements = soup.select('div.audio-player')
            
            current_time = 0
            for idx, chapter in enumerate(chapter_elements, 1):
                # Extract audio URL
                audio_element = chapter.select_one('audio source')
                if audio_element and audio_element.get('src'):
                    audio_url = audio_element['src']
                else:
                    continue
                
                # Extract chapter title
                title_element = chapter.find_previous('h2') or chapter.find_previous('h3')
                chapter_title = title_element.text.strip() if title_element else f"Chapter {idx}"
                
                # Extract duration
                duration_element = chapter.select_one('span.duration')
                duration = duration_element.text.strip() if duration_element else "00:00"
                
                # Calculate duration in seconds for chapter positioning
                duration_parts = duration.split(':')
                duration_seconds = sum(x * int(t) for x, t in zip([3600, 60, 1], duration_parts))
                
                chapters.append({
                    "number": idx,
                    "title": chapter_title,
                    "duration": duration,
                    "audio_url": audio_url,
                    "start_time": current_time
                })
                
                current_time += duration_seconds
            
            return {
                "description": description_text,
                "chapters": chapters
            }
                
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error fetching book details: {str(e)}")

    async def extract_book_data(self, article) -> Optional[AudioBook]:
        try:
            post_id = article.get('data-id', '').replace('post-', '')
            
            if post_id in self.processed_ids:
                return None
            
            self.processed_ids.add(post_id)
            
            # Extract basic book data as before
            data = await self._extract_basic_book_data(article)
            
            # Fetch detailed book information including audio URLs
            if data.get('url'):
                details = await self.get_book_details(data['url'])
                data.update(details)
            
            return AudioBook(
                id=post_id,
                title=data['title'],
                author=data['author'],
                imageUrl=data['image'],
                duration=data['duration'],
                views=data['views'],
                url=data['url'],
                narrator=data.get('narrator', ''),
                date=data.get('date', ''),
                description=data.get('description', ''),
                chapters=[AudioChapter(**chapter) for chapter in data.get('chapters', [])]
            )
            
        except Exception as e:
            print(f"Error extracting data from article: {e}")
            return None

    async def _extract_basic_book_data(self, article) -> dict:
        """Extract basic book information from article element."""
        selectors = {
            'title': ('h3.entry-title a', 'text'),
            'url': ('h3.entry-title a', 'href'),
            'image': ('img.wp-post-image', 'src'),
            'duration': ('div.duration', 'text'),
            'views': ('div.views', None),
            'author': ('span.entry-auteur a', 'text'),
            'narrator': ('span.entry-voix a', 'text'),
            'date': ('span.posted-on a', 'text')
        }
        
        data = {}
        for key, (selector, attr) in selectors.items():
            elem = article.select_one(selector)
            if elem:
                if attr == 'text':
                    data[key] = self.decode_text(elem.text.strip())
                elif attr == 'href':
                    data[key] = elem['href']
                elif attr == 'src':
                    data[key] = self.clean_url(elem['src'])
                elif key == 'views':
                    data[key] = self.extract_views(elem)
            else:
                data[key] = "" if key in ['narrator', 'date'] else "Unknown"
                
        return data

    def decode_text(self, text: str) -> str:        
        if not text:
            return ""
        
        text = html.unescape(text)
        
        french_chars = {
            '&#233;': 'é', '&#232;': 'è', '&#224;': 'à',
            '&#231;': 'ç', '&#226;': 'â', '&#238;': 'î',
            '&#244;': 'ô', '&#251;': 'û', '&#39;': "'"
        }
        for html_char, decoded_char in french_chars.items():
            text = text.replace(html_char, decoded_char)
        
        return ' '.join(text.split())

    def clean_url(self, url: str) -> str:
        if not url:
            return ''
        return re.sub(r'-\d+x\d+(?=\.(jpg|jpeg|png))', '', url)

    def extract_views(self, views_element) -> str:
        if not views_element:
            return "0"
        views_text = views_element.text.strip() if views_element else "0"
        views_number = ''.join(filter(str.isdigit, views_text))
        return views_number if views_number else "0"

    def extract_book_data(self, article) -> Optional[AudioBook]:
        try:
            post_id = article.get('data-id', '').replace('post-', '')
            
            if post_id in self.processed_ids:
                return None
            
            self.processed_ids.add(post_id)
            
            selectors = {
                'title': ('h3.entry-title a', 'text'),
                'url': ('h3.entry-title a', 'href'),
                'image': ('img.wp-post-image', 'src'),
                'duration': ('div.duration', 'text'),
                'views': ('div.views', None),
                'author': ('span.entry-auteur a', 'text'),
                'narrator': ('span.entry-voix a', 'text'),
                'date': ('span.posted-on a', 'text')
            }
            
            data = {}
            for key, (selector, attr) in selectors.items():
                elem = article.select_one(selector)
                if elem:
                    if attr == 'text':
                        data[key] = self.decode_text(elem.text.strip())
                    elif attr == 'href':
                        data[key] = elem['href']
                    elif attr == 'src':
                        data[key] = self.clean_url(elem['src'])
                    elif key == 'views':
                        data[key] = self.extract_views(elem)
                else:
                    data[key] = "" if key in ['narrator', 'date'] else "Unknown"

            return AudioBook(
                id=post_id,
                title=data['title'],
                author=data['author'],
                imageUrl=data['image'],
                duration=data['duration'],
                views=data['views'],
                url=data['url'],
                narrator=data['narrator'],
                date=data['date']
            )
        except Exception as e:
            print(f"Error extracting data from article: {e}")
            return None

    async def scrape_homepage(self, limit: int = 20) -> dict:
        try:
            self.processed_ids.clear()
            
            response = requests.get(self.base_url, headers=self.headers, timeout=10)
            response.encoding = 'utf-8'
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'lxml', from_encoding='utf-8')
            articles = soup.find_all('article', class_='block-loop-item')
            
            all_books = []
            for article in articles:
                book = self.extract_book_data(article)
                if book:
                    all_books.append(book)
                if len(all_books) >= limit:
                    break
            
            sorted_books = sorted(
                all_books,
                key=lambda x: int(x.views) if x.views.isdigit() else 0,
                reverse=True
            )
            
            featured_books = sorted_books[:3]
            recent_books = sorted_books[3:] if len(sorted_books) > 3 else []

            return {
                "featured_books": [json.loads(book.json()) for book in featured_books],
                "recent_books": [json.loads(book.json()) for book in recent_books]
            }
            
        except requests.RequestException as e:
            raise HTTPException(status_code=503, detail=str(e))
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    async def scrape_popular_books(self, page: int = 1) -> dict:
        try:
            self.processed_ids.clear()
            
            url = f"{self.popular_url}/page/{page}" if page > 1 else self.popular_url
            
            response = requests.get(url, headers=self.headers, timeout=10)
            response.encoding = 'utf-8'
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'lxml', from_encoding='utf-8')
            
            pagination = soup.select_one('nav.pagination')
            total_pages = 1
            if pagination:
                pages = pagination.select('a.page-numbers')
                if pages:
                    for page_link in reversed(pages):
                        if page_link.text.isdigit():
                            total_pages = int(page_link.text)
                            break
            
            articles = soup.find_all('article', class_='block-loop-item')
            
            books = []
            for article in articles:
                book = self.extract_book_data(article)
                if book:
                    books.append(book)
            
            return {
                "page": page,
                "total_pages": total_pages,
                "books": [json.loads(book.json()) for book in books]
            }
            
        except requests.RequestException as e:
            raise HTTPException(status_code=503, detail=str(e))
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))