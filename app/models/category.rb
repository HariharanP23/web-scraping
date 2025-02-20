class Category < ApplicationRecord
  has_many :products, dependent: :destroy

  before_save :generate_slug

  private

  def generate_slug
    self.slug = self.name.parameterize
  end
end
