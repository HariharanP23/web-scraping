class WebScraperService
  def initialize(url)
    @url = url
  end

  def scrape
    begin
      html_content = fetch_page_content
      doc = Nokogiri::HTML(html_content)

        scrape_zepto_product(doc)
        @product
    rescue StandardError => e
      Rails.logger.error("WebScraperService Error: #{e.message}")
      raise e
    end
  end

  private

  def scrape_zepto_product(doc)
    product_data = {}

    # Extract product name/title
    product_name_element = doc.css("h1.text-xl.font-semibold")
    product_data[:title] = product_name_element.text.strip if product_name_element.any?

    # Extract quantity/net weight
    quantity_element = doc.css("p.mt-2.text-sm.leading-4 span.font-bold")
    product_data[:quantity] = quantity_element.text.strip if quantity_element.any?

    # Extract current price
    current_price_element = doc.css('span.text-\\[32px\\].font-medium')
    if current_price_element.any?
      price_text = current_price_element.text.strip
      product_data[:price] = price_text.gsub(/[^\d.]/, "").to_f
    end

    # Extract discount percentage
    discount_element = doc.css('p.text-\\[14px\\].font-semibold.text-\\[\\#079761\\]')
    if discount_element.any?
      discount_text = discount_element.text.strip
      product_data[:discount_percentage] = discount_text.gsub(/[^\d.]/, "").to_f
    end

    # Extract MRP (original price)
    mrp_element = doc.css("span.line-through.font-bold")
    if mrp_element.any?
      original_price_text = mrp_element.text.strip
      product_data[:original_price] = original_price_text.gsub(/[^\d.]/, "").to_f
    end


    # Extract category from breadcrumbs
    breadcrumbs = doc.css('div[data-testid="pdp-breadcrumbs"] a.text-sm')
    if breadcrumbs.length >= 2
      category_name = breadcrumbs[1].text.strip
      category = Category.find_or_create_by(name: category_name)
      product_data[:category_id] = category.id
    end

    seller_info_section = doc.css("div#productInformationL4")
    if seller_info_section.any?
      seller_name_row = seller_info_section.css("div.flex.items-start").find do |row|
        row.css("h3").text.strip.downcase.include?("seller name")
      end

      if seller_name_row
        product_data[:seller_name] = seller_name_row.css("p").text.strip
      end
    end

    description_section = doc.css("div#productHighlights")
    if description_section.any?
      description_section_row = description_section.css("div.flex.items-start").find do |row|
        row.css("h3").text.strip.downcase.include?("about the product")
      end

      if description_section_row
        product_data[:description] = description_section_row.css("p").text.strip
      end
    end

    product_data[:source_url] = @url
    @product = Product.find_or_initialize_by(source_url: @url)
    @product.update!(product_data)
    @product
  end

  def fetch_page_content
    user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
    HTTParty.get(@url, headers: { "User-Agent" => user_agent })
  end
end
