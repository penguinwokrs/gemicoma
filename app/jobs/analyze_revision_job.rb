class AnalyzeRevisionJob < ApplicationJob
  queue_as :default

  def perform(revision_id, need_sleep)
    sleep 1 if need_sleep

    revision = Revision.find_by(id: revision_id)
    return false unless revision

    V1::Analyzer::Revision.execute(revision)
  end
end
