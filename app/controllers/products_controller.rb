class ProductsController < ApplicationController
  def index
    if params[:category_id].present?
      find_category
      products = @category.products.order(created_at: :desc)
      @pagy, @products = pagy(products)
    else
      @pagy, @products = pagy(Product.all)
    end
  end

  def web_scraper
  begin
    url = params[:url]
    @product = WebScraperService.new(url).scrape
  rescue StandardError => e
    flash[:alert] = "An unexpected error occurred: #{e.message}"
  end
  redirect_to products_path
  end

  private

  def find_category
    @category = Category.find_by(id: params[:category_id])
  end
end
