package chipyard

import org.chipsalliance.cde.config.{Config}
import freechips.rocketchip.diplomacy.{AsynchronousCrossing}

// --------------
// Rocket Configs
// --------------

class RocketConfig extends Config(
  new freechips.rocketchip.subsystem.WithNBigCores(1) ++         // single rocket-core
  new chipyard.config.AbstractConfig)

class TinyRocketConfig extends Config(
  new chipyard.harness.WithDontTouchChipTopPorts(false) ++        // TODO FIX: Don't dontTouch the ports
  new testchipip.soc.WithNoScratchpads ++                         // All memory is the Rocket TCMs
  new freechips.rocketchip.subsystem.WithIncoherentBusTopology ++ // use incoherent bus topology
  new freechips.rocketchip.subsystem.WithNBanks(0) ++             // remove L2$
  new freechips.rocketchip.subsystem.WithNoMemPort ++             // remove backing memory
  new freechips.rocketchip.subsystem.With1TinyCore ++             // single tiny rocket-core
  new chipyard.config.AbstractConfig)

class QuadRocketConfig extends Config(
  new freechips.rocketchip.subsystem.WithNBigCores(4) ++    // quad-core (4 RocketTiles)
  new chipyard.config.AbstractConfig)

class Cloned64RocketConfig extends Config(
  new freechips.rocketchip.subsystem.WithCloneRocketTiles(63, 0) ++ // copy tile0 63 more times
  new freechips.rocketchip.subsystem.WithNBigCores(1) ++            // tile0 is a BigRocket
  new chipyard.config.AbstractConfig)

class RV32RocketConfig extends Config(
  new freechips.rocketchip.subsystem.WithRV32 ++            // set RocketTiles to be 32-bit
  new freechips.rocketchip.subsystem.WithNBigCores(1) ++
  new chipyard.config.AbstractConfig)

// DOC include start: l1scratchpadrocket
class ScratchpadOnlyRocketConfig extends Config(
  new chipyard.config.WithL2TLBs(0) ++
  new testchipip.soc.WithNoScratchpads ++                      // remove subsystem scratchpads, confusingly named, does not remove the L1D$ scratchpads
  new freechips.rocketchip.subsystem.WithNBanks(0) ++
  new freechips.rocketchip.subsystem.WithNoMemPort ++          // remove offchip mem port
  new freechips.rocketchip.subsystem.WithScratchpadsOnly ++    // use rocket l1 DCache scratchpad as base phys mem
  new freechips.rocketchip.subsystem.WithNBigCores(1) ++
  new chipyard.config.AbstractConfig)
// DOC include end: l1scratchpadrocket

class MMIOScratchpadOnlyRocketConfig extends Config(
  new freechips.rocketchip.subsystem.WithDefaultMMIOPort ++  // add default external master port
  new freechips.rocketchip.subsystem.WithDefaultSlavePort ++ // add default external slave port
  new ScratchpadOnlyRocketConfig
)

class L1ScratchpadRocketConfig extends Config(
  new chipyard.config.WithRocketICacheScratchpad ++         // use rocket ICache scratchpad
  new chipyard.config.WithRocketDCacheScratchpad ++         // use rocket DCache scratchpad
  new freechips.rocketchip.subsystem.WithNBigCores(1) ++
  new chipyard.config.AbstractConfig)

class MulticlockRocketConfig extends Config(
  new freechips.rocketchip.subsystem.WithAsynchronousRocketTiles(3, 3) ++ // Add async crossings between RocketTile and uncore
  new freechips.rocketchip.subsystem.WithNBigCores(1) ++
  // Frequency specifications
  new chipyard.config.WithTileFrequency(1000.0) ++        // Matches the maximum frequency of U540
  new chipyard.clocking.WithClockGroupsCombinedByName(("uncore"   , Seq("sbus", "cbus", "implicit"), Nil),
                                                      ("periphery", Seq("pbus", "fbus"), Nil)) ++
  new chipyard.config.WithSystemBusFrequency(500.0) ++    // Matches the maximum frequency of U540
  new chipyard.config.WithMemoryBusFrequency(500.0) ++    // Matches the maximum frequency of U540
  new chipyard.config.WithPeripheryBusFrequency(500.0) ++ // Matches the maximum frequency of U540
  //  Crossing specifications
  new chipyard.config.WithFbusToSbusCrossingType(AsynchronousCrossing()) ++ // Add Async crossing between FBUS and SBUS
  new chipyard.config.WithCbusToPbusCrossingType(AsynchronousCrossing()) ++ // Add Async crossing between PBUS and CBUS
  new chipyard.config.WithSbusToMbusCrossingType(AsynchronousCrossing()) ++ // Add Async crossings between backside of L2 and MBUS
  new chipyard.config.AbstractConfig)

class CustomIOChipTopRocketConfig extends Config(
  new chipyard.example.WithBrokenOutUARTIO ++
  new chipyard.example.WithCustomChipTop ++
  new chipyard.example.WithCustomIOCells ++
  new freechips.rocketchip.subsystem.WithNBigCores(1) ++         // single rocket-core
  new chipyard.config.AbstractConfig)

class PrefetchingRocketConfig extends Config(
  new barf.WithHellaCachePrefetcher(Seq(0), barf.SingleStridedPrefetcherParams()) ++   // strided prefetcher, sits in front of the L1D$, monitors core requests to prefetching into the L1D$
  new barf.WithTLICachePrefetcher(barf.MultiNextLinePrefetcherParams()) ++             // next-line prefetcher, sits between L1I$ and L2, monitors L1I$ misses to prefetch into L2
  new barf.WithTLDCachePrefetcher(barf.SingleAMPMPrefetcherParams()) ++                // AMPM prefetcher, sits between L1D$ and L2, monitors L1D$ misses to prefetch into L2
  new chipyard.config.WithTilePrefetchers ++                                           // add TL prefetchers between tiles and the sbus
  new freechips.rocketchip.subsystem.WithNonblockingL1(2) ++                           // non-blocking L1D$, L1 prefetching only works with non-blocking L1D$
  new freechips.rocketchip.subsystem.WithNBigCores(1) ++                               // single rocket-core
  new chipyard.config.AbstractConfig)

class Usb2Config extends Config(
  new usb2.WithUsb2(usb2.Usb2Params()) ++
  new freechips.rocketchip.subsystem.WithNSmallCores(1) ++
  new testchipip.soc.WithNoScratchpads ++ // Remove subsystem scratchpads
  new testchipip.serdes.WithSerialTLMem(size = (1 << 30) * 1L) ++ // Configure the off-chip memory accessible over serial-tl as backing memory
  new freechips.rocketchip.subsystem.WithNoMemPort ++ // Remove off-chip AXI port
  new testchipip.soc.WithOffchipBusClient(freechips.rocketchip.subsystem.MBUS) ++ // off-chip bus connects to MBUS to provide backing memory
  new testchipip.soc.WithOffchipBus ++ // Attach off-chip bus
  new chipyard.config.WithBroadcastManager ++ // Replace L2 with a broadcast hub for coherence
  new chipyard.config.AbstractConfig)