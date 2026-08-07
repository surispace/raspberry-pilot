# Pi5 + Ubuntu 24 migration plan

## Goal
Migrate raspberry-pilot's current Raspberry Pi 4 / Ubuntu 20 installation flow to support Raspberry Pi 5 running Ubuntu 24.x while preserving the existing setup experience as much as possible.

## Scope currently identified
- Modernize [start_install_tf.sh](/Users/suri/repo/raspberry-pilot/start_install_tf.sh) for Ubuntu 24.x.
- Update follow-on installer/build scripts to use the same Python environment strategy consistently.
- Identify Pi5-specific boot/runtime items that need separate validation on hardware.
- Track documentation changes needed after installer changes are made.

## Findings so far
- The current public setup flow expects Ubuntu 20.04 on Pi4 and runs [start_install_tf.sh](/Users/suri/repo/raspberry-pilot/start_install_tf.sh) directly.
- [start_install_tf.sh](/Users/suri/repo/raspberry-pilot/start_install_tf.sh) currently depends on several Ubuntu-20-era assumptions:
  - Ansible PPA
  - CRDA config edit
  - obsolete apt packages (`openjdk-8-jdk`, `clang-3.8`, `apt-transport-https`)
  - rewriting system Python with `update-alternatives`
  - `apt_pkg.so` copy hack
  - global `pip install` workflow
  - duplicate / obsolete Python packages (`sklearn`, `pycrypto`, duplicate `pyzmq`, duplicate `cython`)
- [finish_install.sh](/Users/suri/repo/raspberry-pilot/finish_install.sh) and [build_all.sh](/Users/suri/repo/raspberry-pilot/build_all.sh) imply the project was intended to run from an isolated Python environment, but the current installer does not set one up cleanly.
- Pi5 follow-up areas likely outside the first installer pass:
  - [phonelibs/usercfg.txt](/Users/suri/repo/raspberry-pilot/phonelibs/usercfg.txt) boot tuning
  - [selfdrive/thermald.py](/Users/suri/repo/raspberry-pilot/selfdrive/thermald.py) thermal zone mapping

## Work plan

### Phase 1 - Installer modernization
- [x] Replace Ubuntu-20-specific apt/repo steps with Ubuntu-24-compatible ones.
- [x] Remove system Python mutation and `apt_pkg` workaround.
- [x] Introduce a project-local Python environment for dependency installation.
- [x] Clean up duplicate or obsolete Python package installs.
- [x] Review whether optional services like InfluxDB should remain in the default install path.

### Phase 2 - Build/runtime integration
- [x] Update [finish_install.sh](/Users/suri/repo/raspberry-pilot/finish_install.sh) to use the chosen Python environment strategy.
- [x] Update [build_all.sh](/Users/suri/repo/raspberry-pilot/build_all.sh) to build within that environment consistently.
- [x] Update [launch_openpilot.sh](/Users/suri/repo/raspberry-pilot/launch_openpilot.sh) to use the venv interpreter explicitly for Python-launched processes.
- [x] Update [crontab.yml](/Users/suri/repo/raspberry-pilot/crontab.yml) so reboot jobs invoke the runtime in a way that reliably reaches the venv-managed Python.
- [x] Check startup scripts for any hardcoded Python-version assumptions that would break on Ubuntu 24.
- [x] Audit Python shebangs and direct `python` / `python3` invocations that must be normalized for Ubuntu 24 + venv execution.
- [x] Audit Python 3.12 compatibility for runtime-critical modules and startup paths.

### Phase 3 - Validation
- [x] Run targeted validation on modified scripts (syntax + dry-run level checks where possible).
- [x] Run the smallest available build/test commands relevant to the changed installer/build flow.
- [x] Add a Docker-based Ubuntu 24 arm64 validation path for installer/build preflight testing.
- [ ] Record any remaining hardware-only validation items for real Pi5 testing.
- [x] Review and replace the stale Docker validation entry points if they depend on missing files or outdated images.

### Phase 4 - Documentation follow-up
- [ ] Update user-facing setup documentation once the installer flow is finalized.
- [ ] Document any Pi5-specific manual steps or known limitations discovered during migration.

## Verification strategy

### Docker preflight validation
Use a Ubuntu 24 arm64 Docker environment to validate the migration before deploying to Pi5 hardware.

- Goals:
  - verify Ubuntu 24 package names and dependency availability
  - verify Python environment creation succeeds cleanly
  - verify Python packages install on arm64 without relying on system Python hacks
  - verify [build_all.sh](/Users/suri/repo/raspberry-pilot/build_all.sh) can build required native components
  - run the smallest targeted automated checks that are practical in a container
- Limits:
  - does not verify Pi5 boot firmware config
  - does not verify thermal zone mappings
  - does not verify Panda USB behavior against real hardware
  - does not verify reboot-time cron/system integration on a real device

### Pi5 hardware validation
After Docker preflight passes, validate on actual Pi5 hardware.

- Fresh Ubuntu 24.x install
- Run [start_install_tf.sh](/Users/suri/repo/raspberry-pilot/start_install_tf.sh)
- Run [finish_install.sh](/Users/suri/repo/raspberry-pilot/finish_install.sh) flow
- Reboot and verify startup behavior from [crontab.yml](/Users/suri/repo/raspberry-pilot/crontab.yml)
- Confirm expected processes stay up
- Confirm Panda communication works
- Confirm Pi5-specific boot/runtime items behave correctly

### End-to-end acceptance checklist
- [x] Installer succeeds on Ubuntu 24 arm64 Docker image
- [x] Python environment setup works without mutating system Python
- [x] Required Python dependencies install successfully on arm64
- [x] Native project components build successfully
- [x] Pi5-specific boot firmware config updated (usercfg.txt)
- [x] Pi5 thermal zone mapping implemented (thermald.py with auto-detection)
- [x] Fresh Pi5 install completes successfully
- [x] Reboot/startup flow works on Pi5 — all 5 processes start automatically
- [ ] Panda connectivity works (requires Panda USB device connected)
- [ ] Controlled in-car validation succeeds

## Open questions to resolve during implementation
- Which Python packages from the historic install list are truly required at runtime versus legacy leftovers.
- Whether InfluxDB/Grafana should stay bundled, become optional, or be removed from the main install path.
- Whether any runtime code needs Python 3.12 compatibility fixes beyond installer changes.

## Design decisions
- Prefer a project-local `venv` for Ubuntu 24 / Pi5 migration instead of mutating system Python.
- Do not rely on shell activation for runtime startup. Use the venv interpreter explicitly in installer, build, and startup scripts where Python processes are launched.
- Keep the system `python3` installation intact so `apt`, OS tooling, and normal Ubuntu behavior are not affected by project setup.

## Pi5-specific validation focus
- Review [phonelibs/usercfg.txt](/Users/suri/repo/raspberry-pilot/phonelibs/usercfg.txt) for Pi4-only boot tuning or overlays before applying it on Pi5.
- Verify [selfdrive/thermald.py](/Users/suri/repo/raspberry-pilot/selfdrive/thermald.py) thermal zone assumptions against actual Pi5 sensor layout.
- Verify Panda USB enumeration and communication on Pi5 hardware after migration.
- Sanity-check CPU affinity choices in [fix_niceness.sh](/Users/suri/repo/raspberry-pilot/fix_niceness.sh) on Pi5 after runtime is stable.
- Treat these items as hardware-gated validation and not something Docker alone can prove.

## Progress log
- 2026-08-06: Created migration tracking plan and captured initial findings from installer script + existing Pi4 setup documentation.
- 2026-08-07: Added Docker-first verification strategy and acceptance checklist for Ubuntu 24 arm64 preflight + Pi5 hardware validation.
- 2026-08-07: Refined the plan with explicit venv runtime wiring, Python 3.12 audit work, Docker harness follow-up, and Pi5-specific hardware validation focus.
- 2026-08-07: Completed the first migration pass: modernized the Ubuntu 24 installer, added a shared venv runtime helper, rewired build/startup scripts to use the repo-local Python interpreter, and syntax-checked the modified shell/Python files.
- 2026-08-07: Added an Ubuntu 24 arm64 Docker validation harness, taught the installer/finish flow to skip hardware-only integration during container validation, fixed Ubuntu 24 build blockers (C++14 toolchain expectations, package names, Cap'n Proto integration), and verified the install/build flow successfully inside Docker on arm64.
- 2026-08-07: Fixed runtime startup failures on Pi5 hardware:
  - boardd_api_impl.so undefined symbol (C++ name mangling mismatch): introduced shared can_list_to_can_capnp.h header
  - pandad relative path crashes (chdir/execvp): switched to absolute paths derived from __file__
  - /data/upload/ missing: added to finish_install.sh
  - build_all.sh not building boardd_api_impl.so: added explicit make target
  - boardd_setup.py using distutils (removed in Python 3.12): switched to setuptools
  - Thermal zone detection for Pi5 Ubuntu 24 single-zone layout: all sensors map to zone0
- 2026-08-07: **MILESTONE** — All 5 processes (transcoderd, boardd, controlsd, ubloxd, dashboard) confirmed running automatically after reboot on Pi5 with Ubuntu 24.
