# Proposal / idea

Unify and standardize device setup for different functional groups in the business. Make sure all team environments and machines share parent states to minimize the number of install scrips and methods we have to maintain.

## Objectives

1. Build and maintain a set of setup scrips for `windows` and `macos` that simplify the IT management of our staff's machines, and ensure consistent machine starting configuration for each functional group.
2. Have our scripts be grouped into a single script entry method to initialize a machine per functional group. IE, we should have a single entry script for business, dev, data, etc.
3. Maximize the amount of re-used code / script using layered install scripts in a polymorphic [Directed Acyclic Graph (DAG)](https://airflow.apache.org/docs/apache-airflow/1.10.12/concepts.html#dags) to get to a output machine state with appropriate configured apps / state.
4. Have the scripts run on machine initialization so we capture MDM, azureAD identity, and ensure machines are configured in a standard method.
5. Have the scripts run without human intervention, minus first stage initialization of entry script.
6. Have the scripts run verbose, so we can understand what broke if something goes wrong.
7. Have our end state be testable, ideally have a closing script before complete that verifies our machine is setup correctly against its expected state.

## Proposed Approach

- Use layered install scripts in a polymorphic DAG to get to a output machine state with appropriate configured apps / state.
- Start DAG with asset initalization with [Miradore MDM](https://provisionanalytics.online.miradore.com/), sign in with user's [Azure AD](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Overview)
- Work with functional groups to determine required base apps / machine state, and refactor/extract shared steps up to earlier shared base stage to maximize number of base shared states
- Have scripts build ontop of eachother to end up with a number of configurable states
- Have base set scripts that install basic applications and functionality shared by large components of the organization
- Collect component scripts by using tool scripts per stage, allowing us to call sub-scripts/tool scripts to set up weird components (like registry keys in windows, or installing weird applications)
- Unify development environments by configuring `windows` with WSL2
- Have the `windows` development endpoint merge into the development setup for `*nix` systems by calling our WSL2 environment with an entry script.
- Have our `*nix` system setup be `macos` / `linux` agnostic.

## Implementation

### Repo Structure

- `layered-install`
  - `start-scripts` - entrypoint for a given business function by machine type
    - `business, dev, data, etc...`
  - `script-nodes`   - folder containing setup scripts for different nodes on the setup DAG. These scripts are called by `start-scripts`
    - `windows`       - entrypoint for windows machines
    - `macos`         - entrypoint for macos
    - `devbase`       - entrypoint for unified dev environment (`*nix` system). after completion of `windows` or `macos` setup
    - `flow.drawio`   - visual representation of the DAG/human readable documentation of what we have setup

### Entry point

- All assets start with a base entry dependent on their system type: `windows` or `macos`.
- From there, we traverse the tree of install scripts to get to our desired functional group's end state.

### Business teams

- For business teams, we have created a base image to branch out from.

### Development teams

- For development teams, we converge on `devBase.sh`, the entry point for setting up all environments with a standard base of tools. This is possible due to wsl2 for `windows` allowing us to prepare a `*nix` system and pass a `.sh` script into the wsl2 image to bootstrap our desired state, which will match our end environment for `macos` and `*nix` systems. 
- From there, we install dependencies for development.

## Big brain ideas for later

- Use airflow to orchestrate DAG steps through Miradore API.