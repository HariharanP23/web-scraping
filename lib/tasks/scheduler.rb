namespace :scheduler do
  desc "Expire old orders"
  task update_product: :environment do
    Product.where("updated_at <= ?", 1.week.ago).each do |product|
      WebScraperService.new(product.source_url).scrape
    end
  end
end
