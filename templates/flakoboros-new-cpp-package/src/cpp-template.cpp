#include <cpp-template/cpp-template.h>

namespace cpp_template {

Eigen::Matrix3d multiplyIdentity(double scale)
{
        return scale * Eigen::Matrix3d::Identity();
}

} // !namespace cpp_template
