#include <mc_rtc/logging.h>
#include <mc_rtc/version.h>

#include <mc_rbdyn/RobotLoader.h>

#include <mc_control/mc_global_controller.h>

#include <chrono>
#include <thread>

int main()
{
  mc_rtc::log::success("mc_rtc::version() {}", mc_rtc::version());

  mc_control::MCGlobalController gc;

  std::vector<double> initq;
  const auto & rjo = gc.robot().module().ref_joint_order();
  initq.reserve(rjo.size());
  for(const auto & j : rjo)
  {
    initq.push_back(gc.robot().mbc().q[gc.robot().jointIndexByName(j)][0]);
  }
  gc.init(initq);
  gc.running = true;

  using clock = typename std::conditional<std::chrono::high_resolution_clock::is_steady,
                                          std::chrono::high_resolution_clock, std::chrono::steady_clock>::type;

  while(gc.running)
  {
    auto start = clock::now();
    gc.run();
    std::this_thread::sleep_until(start + std::chrono::milliseconds(static_cast<int>(1000 * gc.timestep())));
  }

  return 0;
}
