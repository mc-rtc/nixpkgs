#include <mc_rtc/logging.h>
#include <mc_rtc/version.h>

#include <mc_rbdyn/RobotLoader.h>

#include <mc_control/mc_global_controller.h>

#include <chrono>
#include <thread>

int main(int argc, char * argv[])
{
  if(argc < 2)
  {
    mc_rtc::log::critical("This requires a configuration file");
    return 1;
  }
  mc_rtc::log::success("mc_rtc::version() {}", mc_rtc::version());

  mc_control::MCGlobalController gc(argv[1]);

  const auto & rjo = gc.robot().module().ref_joint_order();
  std::vector<double> encoders(rjo.size());
  auto updateEncoders = [&]() {
    for(size_t i = 0; i < rjo.size(); ++i)
    {
      const auto & j = rjo[i];
      const auto & robot = gc.robot();
      const auto & q = robot.mbc().q;
      encoders[i] = q[robot.jointIndexByName(j)][0];
    }
    gc.setEncoderValues(encoders);
  };
  updateEncoders();
  gc.init(encoders);
  gc.running = true;

  using clock = typename std::conditional<std::chrono::high_resolution_clock::is_steady,
                                          std::chrono::high_resolution_clock, std::chrono::steady_clock>::type;

  while(gc.running)
  {
    auto start = clock::now();
    updateEncoders();
    gc.run();
    std::this_thread::sleep_until(start + std::chrono::milliseconds(static_cast<int>(1000 * gc.timestep())));
  }

  return 0;
}
