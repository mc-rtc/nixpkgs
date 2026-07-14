#include <catch2/catch_test_macros.hpp>
#include <Eigen/Dense>
#include <cpp-template/cpp-template.h>

TEST_CASE("multiplyIdentity returns scaled identity matrix", "[cpp_template]")
{
    using cpp_template::multiplyIdentity;

    SECTION("Default scale is 1")
    {
        Eigen::Matrix3d expected = Eigen::Matrix3d::Identity();
        REQUIRE(multiplyIdentity().isApprox(expected));
    }

    SECTION("Scale 2.5")
    {
        double scale = 2.5;
        Eigen::Matrix3d expected = scale * Eigen::Matrix3d::Identity();
        REQUIRE(multiplyIdentity(scale).isApprox(expected));
    }

    SECTION("Scale 0")
    {
        Eigen::Matrix3d expected = Eigen::Matrix3d::Zero();
        REQUIRE(multiplyIdentity(0).isApprox(expected));
    }
}
