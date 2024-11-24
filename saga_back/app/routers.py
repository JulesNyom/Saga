from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from .models import HomePageResponse, PopularBooksResponse, AudioBook
from .scraper import LitteratureAudioScraper

router = APIRouter()
scraper = LitteratureAudioScraper()

@router.get("/book/{book_id}", response_model=AudioBook)
async def get_book(book_id: str):
    """Get detailed book information including audio URLs"""
    try:
        # First try to find the book in the homepage
        homepage_data = await scraper.scrape_homepage()
        all_books = homepage_data['featured_books'] + homepage_data['recent_books']
        
        book = next((book for book in all_books if book['id'] == book_id), None)
        
        if not book:
            # If not found, try the popular books
            popular_data = await scraper.scrape_popular_books()
            all_popular_books = popular_data['books']
            book = next((book for book in all_popular_books if book['id'] == book_id), None)
        
        if not book:
            raise HTTPException(status_code=404, detail="Book not found")
            
        return JSONResponse(
            content=book,
            headers={"Content-Type": "application/json; charset=utf-8"}
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/", response_model=HomePageResponse)
async def get_books(limit: int = 20):
    """Get audio books from Littérature Audio homepage"""
    try:
        books_data = await scraper.scrape_homepage(limit)
        return JSONResponse(
            content=books_data,
            headers={
                "Content-Type": "application/json; charset=utf-8"
            }
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/popular", response_model=PopularBooksResponse)
async def get_popular_books(page: int = 1):
    """Get most popular audio books with pagination"""
    if page < 1:
        raise HTTPException(status_code=400, detail="Page number must be greater than 0")
        
    try:
        books = await scraper.scrape_popular_books(page)
        
        # Structure the response to match what Flutter expects
        response_data = {
            "featured_books": books["books"][:3] if page == 1 else [],
            "recent_books": books["books"][3:] if page == 1 else books["books"],
            "total_pages": books["total_pages"],
            "page": books["page"]
        }
        
        return JSONResponse(
            content=response_data,
            headers={
                "Content-Type": "application/json; charset=utf-8"
            }
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))