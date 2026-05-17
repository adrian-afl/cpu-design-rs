// pub fn pulse_gen_module(clo)

type Input<N = 1> = {};
type WireOutput<N = 1> = {};
type RegOutput<N = 1> = {};
type Wire<N = 1> = {};
type Reg<N = 1> = {};

type PulseGenParams = {
  clk_freq: number;
  interval_ms: number;
};

type PulseGenWires = {
  clk: Input;
  rst: Input;
  output: RegOutput;
};

function PulseGenModule(params: PulseGenParams, wiring: PulseGenWires) {
  //
  //
}
