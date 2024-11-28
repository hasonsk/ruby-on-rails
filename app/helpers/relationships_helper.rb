module RelationshipsHelper
  def unfollow_button user
    form_with(
      model: current_user.active_relationships.find_by(followed: user),
      html: { method: :delete }
    ) do |f|
      f.submit t("button.unfollow"), class: "btn"
    end
  end

  def follow_button user
    form_with(model: current_user.active_relationships.build) do |f|
      f.hidden_field :followed_id, value: user.id
      f.submit t("button.follow"), class: "btn btn-primary"
    end
  end
end
