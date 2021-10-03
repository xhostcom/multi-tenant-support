require 'test_helper'


class ModelDestroyAllOnAssociationProtectTest < ActiveSupport::TestCase

  ####
  # .destroy_all
  ####
  test "can only destroy records under the tenant" do
    within_a_request_of amazon do
      assert_destroy_all(-1)
    end
  end

  test "fail to destroy when tenant is missing" do
    disallow_read_across_tenant do
      missing_tenant do
        refute_destroy_all MultiTenantSupport::MissingTenantError
      end
    end
  end

  test 'cannot destroy by super admin (default)' do
    within_a_request_of super_admin do
      refute_destroy_all MultiTenantSupport::MissingTenantError
    end
  end

  test 'can destroy scoped records by super admin through manual set current tenant' do
    within_a_request_of super_admin do
      under_tenant amazon do
        assert_destroy_all(-1)
      end
    end
  end

  def assert_destroy_all(number_change)
    assert_difference "UserTag.unscope_tenant.count", number_change do
      tags(:entrepreneur).users.destroy_all
    end

    allow_read_across_tenant do
      assert_equal 2, UserTag.unscope_tenant.count
      assert_equal 3, User.unscope_tenant.count
    end
  end

  def refute_destroy_all(error = nil)
    assert_raise(error) { tags(:entrepreneur).users.destroy_all }

    allow_read_across_tenant do
      assert_equal 3, User.count
      assert_equal 3, UserTag.count
    end
  end

end
