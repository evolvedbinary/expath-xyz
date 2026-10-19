# EXPath Community Group (xyz)

[![Build Status](https://dl.circleci.com/status-badge/img/gh/evolvedbinary/expath-xyz/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/evolvedbinary/expath-xyz/tree/main)

Repository (reboot) for the [W3C EXPath Community Group](http://w3.org/community/expath/).

Specifications may be written in either [W3C ReSpec](https://github.com/speced/respec) (preferred) or the legacy EXPath Spec (an extension of [XMLSpec](https://www.w3.org/2002/xmlspec/)).

Each specification has a sub-folder in in the `expath-cg-specs/` folder.

## Building from Source Code

### Prerequisites

* Java — JDK 8 or later
* Maven — 3.9.0 or later

### Validate all Specifications

```bash
$ mvn verify
```

This validates the ReSpec and EXPath Spec source files against their schemas.

### Compile

```bash
$ mvn package
```

Upon sucessful completion, a distribution of the compiled specifications in ReSpec format and any associated schemas will be present in the sub-folder `expath-cg-distribution/target/expath-cg-distribution-1.0.0-SNAPSHOT/`. There is also a Zip file of this generated for convenience: `expath-cg-distribution/target/expath-cg-distribution-1.0.0-SNAPSHOT.zip`

A copy of the [`expath.xyz`](https://expath.xyz) website is also generated, and may be found in the `expath-xyz-website/target/website` folder.


## Licensing

1. Documents under development are subject to the [W3C Community Contributor License Agreement](https://www.w3.org/community/about/process/cla/)
2. Documents that are final are subject to the [W3C Community Final Specification Ageeement](https://www.w3.org/community/about/process/fsa/)
3. The build system and assocationed code in this repository is under the [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) license.

