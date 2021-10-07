require 'test_helper'
require 'sidekiq'
require 'sidekiq/testing'

module TestActiveJob
  module SidekiqAdapter
    class PeroformLaterTest < ActiveSupport::TestCase

      setup do
        MultiTenantSupport.under_tenant(accounts(:amazon)) do
          @bezos = users(:bezos)
        end
      end

      teardown do
        Sidekiq::RetrySet.new.clear
      end

      test 'update succes update user when tenant account match' do
        MultiTenantSupport.under_tenant(accounts(:amazon)) do
          assert_no_changes 'MultiTenantSupport.current_tenant' do
            UserNameUpdateJob.perform_later(@bezos)

            sleep 0.5
          end
        end

        MultiTenantSupport.under_tenant(accounts(:amazon)) do
          assert_equal "Jeff Bezos UPDATE", @bezos.reload.name
        end
      end

      test 'fail to update user when tenant account is missing on enqueue' do
        assert_no_changes 'MultiTenantSupport.current_tenant' do
          UserNameUpdateJob.perform_later(@bezos)

          sleep 0.1
        end

        Sidekiq.redis do |connection|
          retries = connection.zrange "retry", 0, -1
          assert 1, retries.count
          failed_job_data = JSON.parse(retries.last)
          assert_equal "Error while trying to deserialize arguments: MultiTenantSupport::MissingTenantError", failed_job_data["error_message"]
          assert_equal "ActiveJob::DeserializationError", failed_job_data["error_class"]
        end

        MultiTenantSupport.under_tenant(accounts(:amazon)) do
          assert_equal "Jeff Bezos", @bezos.reload.name # Does not change
        end
      end

      test 'fail to update user when tenant account is not match' do
        MultiTenantSupport.under_tenant(accounts(:apple)) do
          assert_no_changes 'MultiTenantSupport.current_tenant' do
            UserNameUpdateJob.perform_later(@bezos)

            sleep 0.2
          end
        end

        Sidekiq.redis do |connection|
          retries = connection.zrange "retry", 0, -1
          assert 1, retries.count
          failed_job_data = JSON.parse(retries.last)
          assert_equal %Q{Error while trying to deserialize arguments: Couldn't find User with 'id'=#{@bezos.id} [WHERE "users"."account_id" = $1]}, failed_job_data["error_message"]
          assert_equal "ActiveJob::DeserializationError", failed_job_data["error_class"]
        end

        MultiTenantSupport.under_tenant(accounts(:amazon)) do
          assert_equal "Jeff Bezos", @bezos.reload.name # Does not change
        end
      end

    end
  end
end