<p align="center">
<img src="release/LatexManual/figures/piHPSDR_logo.png" width="300" height="300">
</p>

**SDR host program**,
supporting both the old (P1) and new (P2) HPSDR protocols, as well as the SoapySDR framework.
It runs on Linux (Raspberry Pi but also Desktop or Laptop computers running LINUX) and MacOS (Intel or AppleSilicon CPUs, using  "Homebrew" or "MacPorts").

---

## HB9TOB fork — changes vs upstream DL1YCF

This fork is based on [DL1YCF's piHPSDR](https://github.com/dl1ycf/pihpsdr) and adds the following fix:

### Adalm Pluto TX chain fix (SoapySDR)

**Problem:** When using an Adalm Pluto (or any SoapySDR device) the TX stream was
activated at program startup, causing the hardware to transmit immediately even
while in receive mode.

**Fix:** For non-LimeSDR SoapySDR devices the TX stream is now:
- **not** activated at startup,
- activated only when entering TX (after setting the LO frequency and TX gain),
- deactivated immediately when returning to RX.

The LimeSDR behaviour is unchanged (its TX stream must remain active for
auto-calibration purposes).

---

## Installation from scratch (Linux PC / Desktop)

### Quick install with the provided script

```bash
curl -sL https://raw.githubusercontent.com/hb9tob/pihpsdr/master/install-pihpsdr-hb9tob.sh | bash
```

Or download and run manually:

```bash
wget https://raw.githubusercontent.com/hb9tob/pihpsdr/master/install-pihpsdr-hb9tob.sh
chmod +x install-pihpsdr-hb9tob.sh
./install-pihpsdr-hb9tob.sh
```

The script will:
1. Clone this repository into `~/PiHPSDR-HB9TOB-<date>/`
2. Install all required system libraries (`libinstall.sh`)
3. Create `make.config.pihpsdr` with `GPIO=OFF` and `SOAPYSDR=ON`
4. Compile piHPSDR
5. Optionally build SoapySDR device modules (Pluto, RTL-SDR, Airspy, HackRF, SDRplay)

### Manual installation step by step

#### 1. Install dependencies

```bash
git clone https://github.com/hb9tob/pihpsdr
cd pihpsdr
./LINUX/libinstall.sh
```

#### 2. Build configuration

Create `make.config.pihpsdr` in the project root:

```
GPIO=OFF
SOAPYSDR=ON
```

- `GPIO=OFF` — disable Raspberry Pi GPIO support (not needed on a PC)
- `SOAPYSDR=ON` — enable SoapySDR framework (required for Adalm Pluto, RTL-SDR, etc.)

#### 3. Compile

```bash
make clean && make
```

#### 4. Build SoapySDR device modules (optional)

Build only the modules for your hardware:

```bash
./LINUX/soapy.pluto.sh      # Adalm Pluto / Pluto+
./LINUX/soapy.rtlstick.sh   # RTL-SDR dongles
./LINUX/soapy.airspy.sh     # Airspy
./LINUX/soapy.hackrf.sh     # HackRF
./LINUX/soapy.sdrplay.sh    # SDRplay
```

#### 5. Run

```bash
./pihpsdr
```

On first run, piHPSDR computes FFT wisdom tables — this takes a few minutes, do not interrupt it.

### Adalm Pluto connection

Connect the Pluto via USB before starting piHPSDR. The Pluto must appear as a network
interface (`pluto.local` or `192.168.2.1`). You can verify with:

```bash
SoapySDRUtil --find="driver=plutosdr"
```

### Custom screen resolution

Use the **Screen** menu inside piHPSDR to select "Custom" and set any width/height.
This is a native feature of the DL1YCF codebase.

---

## piHPSDR Manual

**v2.4:** https://github.com/dl1ycf/pihpsdr/releases/download/v2.5/piHPSDR-Manual-v2.4.pdf

**v2.5:** https://github.com/dl1ycf/pihpsdr/releases/download/v2.5/piHPSDR-Manual-v2.5.pdf

**v2.6:** https://github.com/dl1ycf/pihpsdr/releases/download/v2.5/piHPSDR-Manual-v2.6.pdf

**Current master branch manual:**
https://github.com/dl1ycf/pihpsdr/releases/download/v2.5/piHPSDR-Manual.pdf

---

## Upstream features (DL1YCF)

- manual multi notch filter (in the FILTER menu)
- NR3/NR4 noise reduction models (RNNnoise and libspecbleach) fully integrated
- client/server model for remote operation (including transmitting in phone and CW)
- fully configurable Slider and Toolbar area
- full support for Anan G2-Ultra radios, including customizable panel button/encoder functions
- added continuous frequency compressor (**CFC**) and downward expander (**DEXP**) to the TX chain
- HermesLite-II I/O-board support
- audio recording (RX capture) and playback (TX)
- dynamic screen resizing in the "Screen" menu, including transitions between full-screen and window mode

---

## Acknowledgements

This project stands on the work of several people — many thanks to all of them:

- **John Melton, G0ORX / N6LYT** — original author of piHPSDR (2015).
  The entire SDR host architecture, protocol handling and UI are his work.
  https://github.com/g0orx/pihpsdr

- **Christoph van Wüllen, DL1YCF** — current maintainer of the upstream fork
  used as the base for this repository. Responsible for the vast majority of
  features present in the modern codebase (multi-notch, NR3/NR4, client/server,
  G2-Ultra support, WDSP integration improvements, and much more).
  https://github.com/dl1ycf/pihpsdr

- **Warren Pratt, NR0V** — author of the WDSP (Wideband DSP) signal processing
  library that provides all RX/TX DSP functions (filters, noise reduction,
  AGC, modulation/demodulation, etc.).
  https://github.com/WDSP/WDSP

- **Mike T, M0AWS** — author of the `install-pihpsdr` shell script for Linux PC,
  which served as the basis for the install script included in this repository.
  https://m0aws.co.uk/
