#include <benchmark/benchmark.h>

namespace {

// NOLINTNEXTLINE(readability-identifier-naming)
void BM_hello_world_Smoke(benchmark::State& state) {
    for (auto _ : state) {
        benchmark::DoNotOptimize(state.iterations());
    }
}
BENCHMARK(BM_hello_world_Smoke);

}  // namespace

BENCHMARK_MAIN();
