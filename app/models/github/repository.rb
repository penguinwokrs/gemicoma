# == Schema Information
#
# Table name: github_repositories
#
#  id             :bigint(8)        not null, primary key
#  github_user_id :bigint(8)        not null
#  repository     :string           not null
#  branch         :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  user_id_repository_unique  (github_user_id,repository) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (github_user_id => github_users.id)
#

class Github::Repository < ApplicationRecord
  belongs_to :github_user, class_name: 'Github::User', inverse_of: :github_repositories

  has_one :github_ruby_gem_info, class_name: 'Github::Ruby::GemInfo',
                                 dependent: :destroy,
                                 inverse_of: :github_repository,
                                 foreign_key: :github_repository_id

  has_many :revisions, dependent: :destroy, inverse_of: :repository, as: :repository
  has_one :revision_latest, class_name: 'Revision::Latest', dependent: :destroy, inverse_of: :repository, as: :repository

  # rails/arel
  def github_path
    "#{github_user.name}/#{repository}"
  end

  def github_link_path
    "https://github.com/#{github_path}"
  end

  def update_revision(revision)
    build_revision_latest unless revision_latest
    revision_latest.update_revision(revision)
  end
end
