require 'test_helper'

module TestActiveJob
  module InlineAdapter
    class PreconfiguredPerformLaterTest < ActiveSupport::TestCase
      include ActiveJob::TestHelper

      setup do
        Rails.application.configure do
          config.active_job.queue_adapter = :inline
        end
      end

      test 'update succes update user when tenant account match' do
        under_tenant(amazon) do
          assert_no_changes 'MultiTenantSupport.current_tenant' do
            perform_enqueued_jobs do
              UserNameUpdateJob.set(queue: :integration_tests).perform_later(bezos)
            end
          end

          assert_equal "Jeff Bezos UPDATE", bezos.reload.name
        end
      end

      test 'fail to update user when tenant account is missing' do
        under_tenant nil do
          assert_no_changes 'MultiTenantSupport.current_tenant' do
            perform_enqueued_jobs do
              begin
                UserNameUpdateJob.set(queue: :integration_tests).perform_later(bezos)
              rescue ActiveJob::DeserializationError => e
                assert_equal "Error while trying to deserialize arguments: MultiTenantSupport::MissingTenantError", e.message
              end
            end
          end
        end

        under_tenant(amazon) do
          assert_equal "Jeff Bezos", @bezos.reload.name # Does not change
        end
      end

      test 'fail to update user when tenant account is not match' do
        under_tenant(apple) do
          assert_no_changes 'MultiTenantSupport.current_tenant' do
            perform_enqueued_jobs do
              begin
                UserNameUpdateJob.set(queue: :integration_tests).perform_later(bezos)
              rescue ActiveJob::DeserializationError => e
                assert_includes e.message, "Couldn't find User with 'id'"
              end
            end
          end
        end

        under_tenant(amazon) do
          assert_equal "Jeff Bezos", @bezos.reload.name # Does not change
        end
      end

    end
  end
end