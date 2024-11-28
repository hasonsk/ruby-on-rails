class Micropost < ApplicationRecord
  belongs_to :user
  MICROPOST_PERMITTED_ATTRIBUTES = [:content, :image].freeze

  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [Settings.default.resize_to_limit_width, Settings.default.resize_to_limit_height]
  end

  default_scope {order(created_at: :desc)}

  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: Settings.default.micropost_content_max_length}
  validate :validate_image

  scope :newest_by_user, ->(user_id){where(user_id: user_id)}
  scope :feed_for, lambda {|user_id|
    part_of_feed = "relationships.follower_id = :id OR microposts.user_id = :id"
    left_outer_joins(user: :followers)
      .where(part_of_feed, id: user_id)
      .distinct
      .includes(:user, image_attachment: :blob)
  }

  private

  def validate_image
    if image.attached?
      unless image.content_type.in?(%w(image/jpeg image/gif image/png))
        errors.add :image, "must be a valid image format"
      end

      if image.byte_size > Settings.default.micropost_image_max_size.megabytes
        errors.add :image, "should be less than 5MB"
      end
    else
      errors.add :image, "must be attached"
    end
  end
end
