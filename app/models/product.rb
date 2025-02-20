class Product < ApplicationRecord
  belongs_to :category

  validates :title, presence: true
  validates :source_url, presence: true, uniqueness: true

  before_save :generate_slug

  private

  def generate_slug
    self.slug = self.title.parameterize
  end
end
