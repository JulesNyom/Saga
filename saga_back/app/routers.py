from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from models import HomePageResponse, PopularBooksResponse
from scraper import LitteratureAudioScraper

router = APIRouter()
scraper = LitteratureAudioScraper()

@router.get("/", response_model=HomePageResponse)
async def get_books(limit: int = 20):
    """Get audio books from Littérature Audio homepage"""
    books_data = await scraper.scrape_homepage(limit)
    return JSONResponse(
        content=books_data,
        headers={
            "Content-Type": "application/json; charset=utf-8"
        }
    )

@router.get("/popular", response_model=PopularBooksResponse)
async def get_popular_books(page: int = 1):
    """Get most popular audio books with pagination"""
    if page < 1:
        raise HTTPException(status_code=400, detail="Page number must be greater than 0")
        
    try:
        books_data = await scraper.scrape_popular_books(page)
        return JSONResponse(
            content=books_data,
            headers={
                "Content-Type": "application/json; charset=utf-8"
            }
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))