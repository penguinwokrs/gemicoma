class Admin::Github::RepositoriesController < Admin::BaseController
  def new
  end

  def create
    github_repository = params[:github_repository]
    raise ActionController::BadRequest unless github_repository

    user_name, repository_name = github_repository.split('/')
    repository = nil
    ActiveRecord::Base.transaction do
      user = ::Github::User.find_or_create_by!(name: user_name)
      repository = user.github_repositories.find_or_initialize_by(repository: repository_name, branch: params[:branch])
      create_bundle_files(repository)
      user.save!
    end

    ::FetchMasterJob.perform_later(repository.id, true)

    redirect_to "/github/users/#{user_name}/repositories/#{repository_name}"
  end

  private

    def create_bundle_files(repository)
      rubygem = params[:bundle_files][:rubygem]
      return unless rubygem

      b = repository.github_ruby_gem_info
      b ||= repository.build_github_ruby_gem_info
      b.gemfile_path = rubygem['gemfile_path']
      b.ruby_version_path = rubygem['ruby_version_path'] if rubygem['ruby_version_path'].present?

      b.save! if b.changed?
      b
    end
end
