from munch import Munch
import yaml
import logging
import re


toolYaml = Munch()


class BraceMessage:
    def __init__(self, fmt, /, *args, **kwargs):
        self.fmt = fmt
        self.args = args
        self.kwargs = kwargs

    def __str__(self):
        return self.fmt.format(*self.args, **self.kwargs)


__ = BraceMessage


with open("tools.yaml") as f:
    toolYaml = Munch.fromYAML(f)

valid = toolYaml["valid"]
methods = toolYaml["methods"]
components = toolYaml["components"]
os_methods = toolYaml["os_methods"]
stages = toolYaml["stages"]
flows = toolYaml["flows"]


def install_components(target_components, target_os, group):
    calls = []
    for target_component in target_components:
        call = component_call(logger, target_component, target_os, group)
        if call is not None:
            calls.append(call)
    return calls


def collect_components(stage_list, component_type):
    if type(stage_list) is str:
        stage_list = [stage_list]
    target_components = []
    for stage in stage_list:
        if stage not in stages:
            logger.error(__(f"echo {stage} not found in stages"))
        if component_type not in stages[stage]:
            logger.error(__(f"echo {component_type} not found in {stage}"))
        target_components += stages[stage][component_type]
    return target_components


def collect_group_components(logger, stage, target_os):
    component_calls = []
    for group in stages[stage].keys():
        logger.debug(stage, group)
        component_calls += install_components(
            collect_components(stage, group), target_os, group
        )
    return component_calls


def missing_parameters(called_parameters):
    """[summary]

    Args:
        called_parameters ([type]): [description]

    Returns:
        [type]: [description]
    """
    return list(set(called_parameters).difference(set(called_parameters)))


def execute_flow(logger, flow, target_os):
    """[summary]

    Args:
        logger ([type]): [description]
        flow ([type]): [description]
        target_os ([type]): [description]

    Returns:
        [type]: [description]
    """
    if flow not in flows:
        logger.error(__(f"{flow} not found in flows"))
    if target_os not in os_methods.keys():
        logger.error(__(f"echo {target_os} not found in os_methods"))
    all_installs = []
    for stage in flows[flow]:
        if stage not in stages:
            logger.error(__(f"echo {stage} not found in stages"))
        all_installs += collect_group_components(logger, stage, target_os)
    return all_installs


def compose_call(logger, target_method_name, invoked_call_parameters):
    
    if target_method_name in methods:
        # if target_method_name == "compound-command":
        #     return compose_call(logger, invoked_call_parameters['componentA'], invoked_call_parameters['argsA']) + compose_call(logger, invoked_call_parameters['componentA'], invoked_call_parameters['argsB'])
        target_method_definition = methods[target_method_name]
        # allowed_method_params_dict = method_definition_dict['params']
        target_method_call_string = target_method_definition["call"]
        called_parameters = invoked_call_parameters.keys()

        target_method_parameter_names = []
        required_parameters = []
        default_parameters_dicts = []
        default_parameters = []
        param_to_call_dict = {}

        for param in target_method_definition["params"].items():
            param_name, param_dict = param
            target_method_parameter_names.append(param_name)
            if {"required": True} in [param_dict]:
                required_parameters.append(param_name)
            if "default" in param_dict:
                default_parameters_dicts.append(param)
        for param_name, param_dict in default_parameters_dicts:
            default_parameters.append(param_name)
            param_to_call_dict.update({param_name: param_dict["default"]})

        missing_called_parameters = missing_parameters(
            called_parameters, required_parameters
        )
        invoked_target_parameter_names = list(
            set(called_parameters).intersection(set(target_method_parameter_names))
        )
        empty_target_parameter_names = list(
            set(target_method_parameter_names).difference(
                set(invoked_target_parameter_names + default_parameters)
            )
        )
        out_of_scope_params = list(
            set(called_parameters).difference(set(target_method_parameter_names))
        )

        logger.debug(
            __("compose_call - called_parameters:" + " ".join(called_parameters))
        )
        logger.debug(
            __("compose_call - default_parameters:" + " ".join(default_parameters))
        )
        logger.debug(
            __(
                "compose_call - missing_called_parameters:"
                + " ".join(called_parameters)
                + " difference "
                + " ".join(required_parameters)
                + " equals "
                + " ".join(missing_called_parameters)
            )
        )
        logger.debug(
            __(
                "compose_call - invoked_target_parameter_names:"
                + " ".join(called_parameters)
                + " difference "
                + " ".join(target_method_parameter_names)
                + " equals "
                + " ".join(invoked_target_parameter_names)
            )
        )
        logger.debug(
            __(
                "compose_call - empty_target_parameter_names:",
                target_method_parameter_names,
                " difference ",
                invoked_target_parameter_names + default_parameters,
                " equals ",
                empty_target_parameter_names,
            )
        )

        if missing_called_parameters:
            logger.error(
                __(
                    f"echo required parameters: {missing_called_parameters} not found in defined invoked_call_parameters"
                )
            )

        if empty_target_parameter_names:
            for parameter_name in empty_target_parameter_names:
                param_to_call_dict.update({parameter_name: ""})

        # if out_of_scope_params:
        #     logger.error(__(f"echo unrecognized parameters: [{out_of_scope_params}] for method {method}"
        if invoked_target_parameter_names:
            for parameter_name in invoked_target_parameter_names:
                compound_command = re.search(
                    "(?<=(component\()).*,.*(?=\))",
                    invoked_call_parameters[parameter_name],
                )
                if compound_command is not None:
                    compound_command_parts = re.split(", *", compound_command[0])
                    param_to_call_dict.update(
                        {
                            parameter_name: re.split(
                                "component\(", invoked_call_parameters[parameter_name]
                            )[0]
                            + component_call(
                                logger,
                                compound_command_parts[1],
                                group=compound_command_parts[0],
                                target_method=compound_command_parts[2],
                            )
                        }
                    )
                else:
                    param_to_call_dict.update(
                        {parameter_name: invoked_call_parameters[parameter_name]}
                    )
            logger.debug(
                __(
                    "combining call string:",
                    target_method_call_string,
                    param_to_call_dict,
                )
            )
            return target_method_call_string.format(**param_to_call_dict)
        else:
            logger.error(
                __(
                    f"echo {target_method_name} - did not find invoked_target_parameter_names - "
                    + " ".join(invoked_call_parameters)
                )
            )
    else:
        logger.error(__(f"echo {target_method_name} not found in defined methods"))


def component_call(
    logger, component, target_os=None, group="components", target_method=None
):
    if target_method is not None:
        logger.debug(__(f"calling compose call with {target_method}"))
        call = compose_call(
            logger, target_method, components[group][component][target_method]
        )
        if call is None:
            logger.error(
                __(
                    f"compose_call returned None, component call with component:{component}, target_os:{target_os}, group:{group}, target_method:{target_method}"
                )
            )
        else:
            return call
    else:
        if target_os not in os_methods.keys():
            logger.error(__(f"echo {target_os} not found in os_methods"))
        if group not in components:
            logger.error(__(f"echo {group} not found in component groups"))
        if component not in components[group]:
            logger.error(__(f"echo {group} has no found component {component}"))
        target_methods = components[group][component]
        component_method_set = set(target_methods.keys())
        os_method_set = set(os_methods[target_os])
        if bool(component_method_set & os_method_set):
            target_method = list(component_method_set.intersection(os_method_set))[0]
            call = compose_call(logger, target_method, target_methods[target_method])
            if call is None:
                logger.error(
                    __(
                        f"compose_call returned None, component call with component:{component}, target_os:{target_os}, group:{group}, target_method:{target_method}"
                    )
                )
            else:
                return call
        else:
            logger.error(__(f"echo {component} has no found method for {target_os}"))


# test
import unittest


class test_compose_call(unittest.TestCase):
    logger = logging.getLogger(__name__)

    def extract_methods(methods, methods_to_extract=None):
        if methods_to_extract is None:
            methods_to_extract = methods.keys()
        if type(methods_to_extract) == str:
            methods_to_extract = [methods_to_extract]
        return_methods = {}
        for method in methods_to_extract:
            return_methods.update({method: methods[method]})
        return return_methods

    methods = {
        "winget": {
            "params": {
                "args": {"required": False},
                "source": {"required": False, "default": "--source winget"},
                "pkg": {"required": True},
            },
            "call": "winget install {pkg} {source} {args}",
        },
        "brew": {
            "params": {
                "args": {"required": False},
                "source": {"required": False},
                "pkg": {"required": True},
            },
            "call": "brew install {source} {pkg} -y {args}",
        },
    }
    components = {
        "tools": {
            "chrome": {
                "brew": {"pkg": "google-chrome", "source": "--cask"},
                "winget": {"pkg": "Google.Chrome", "source": "--source winget"},
            },
            "docker": {
                "brew": {"pkg": "docker", "source": "--cask"},
                "winget": {"pkg": "Docker.DockerDesktop", "source": "--source winget"},
            },
        }
    }

    def test_compose_call(self):
        assert (
            compose_call(logger, "brew", {"pkg": "test_package"})
            == "brew install  test_package -y "
        )
        assert (
            compose_call(
                logger,
                "winget",
                {"pkg": "test_package", "args": "-arg1 -arg2 val1 -arg3"},
            )
            == "winget install test_package --source winget -arg1 -arg2 val1 -arg3"
        )

    def component_batch_test():
        methods = {
            "winget": {
                "params": {
                    "args": {"required": False},
                    "source": {"required": False, "default": "--source winget"},
                    "pkg": {"required": True},
                },
                "call": "winget install {pkg} {source} {args}",
            },
            "brew": {
                "params": {
                    "args": {"required": False},
                    "source": {"required": False},
                    "pkg": {"required": True},
                },
                "call": "brew install {source} {pkg} -y {args}",
            },
        }
        components = {
            "tools": {
                "chrome": {
                    "brew": {"pkg": "google-chrome", "source": "--cask"},
                    "winget": {"pkg": "Google.Chrome", "source": "--source winget"},
                },
                "docker": {
                    "brew": {"pkg": "docker", "source": "--cask"},
                    "winget": {
                        "pkg": "Docker.DockerDesktop",
                        "source": "--source winget",
                    },
                },
            },
            "devenv": {
                "python": {
                    "bash": {"source": "install-python.sh"},
                    "winget": {"pkg": "Python.Python.3", "source": "--source winget"},
                },
                "conda": {"bash": {"source": "install-conda.sh"}},
            },
        }
        os_methods = {
            "macos": ["apt", "apt-get", "bash", "brew", "vs-extension"],
            "unix": ["apt", "apt-get", "bash", "brew", "vs-extension"],
            "windows": ["powershell", "winget", "vs-extension", "regedit"],
        }
        response = []
        for group in components.keys():
            for component in components[group]:
                for target_os in os_methods.keys():
                    response.append(
                        f"{target_os}, {group}, {component}: {component_call(logger, component, target_os, group)}"
                    )
        return response

    def test_component_call(self):
        assert (
            component_call(logger, "chrome", "windows", "tools")
            == "winget install Google.Chrome --source winget "
        )
        assert component_batch_test() == [
            "macos, tools, chrome: brew install --cask google-chrome -y ",
            "unix, tools, chrome: brew install --cask google-chrome -y ",
            "windows, tools, chrome: winget install Google.Chrome --source winget ",
            "macos, tools, docker: brew install --cask docker -y ",
            "unix, tools, docker: brew install --cask docker -y ",
            "windows, tools, docker: winget install Docker.DockerDesktop --source winget ",
            "macos, devenv, python: bash -c install-python.sh ",
            "unix, devenv, python: bash -c install-python.sh ",
            "windows, devenv, python: winget install Python.Python.3 --source winget ",
            "macos, devenv, conda: bash -c install-conda.sh ",
            "unix, devenv, conda: bash -c install-conda.sh ",
            "windows, devenv, conda: echo conda has no found method for windows",
        ]


# compose_call(logger, 'winget',{'pkg':'test_package', 'args': '-arg1 -arg2 val1 -arg3'})

