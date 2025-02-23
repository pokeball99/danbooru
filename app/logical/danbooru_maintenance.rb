# frozen_string_literal: true

module DanbooruMaintenance
  module_function

  def hourly
    queue PrunePostsJob
    queue PruneRateLimitsJob
    queue RegeneratePostCountsJob
    queue PruneUploadsJob
    #queue AmcheckDatabaseJob
  end

  def daily
    queue PruneJobsJob
    queue PrunePostDisapprovalsJob
    queue PruneBulkUpdateRequestsJob
    queue PruneBansJob
    queue BigqueryExportAllJob
    queue VacuumDatabaseJob
  end

  def weekly
    queue RetireTagRelationshipsJob
    queue DmailInactiveApproversJob
  end

  def monthly
    queue PruneApproversJob
  end

  def queue(job)
    Rails.logger.level = :info
    DanbooruLogger.info("Queueing #{job.name}")
    ApplicationRecord.connection.verify!
    job.perform_later
  rescue Exception => e # rubocop:disable Lint/RescueException
    DanbooruLogger.log(e)
    raise e if Rails.env.test?
  end
end
