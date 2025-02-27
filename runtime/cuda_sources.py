#
# Copyright (C) 2016-2021, AdaCore
#
# Python script to gather files for the bareboard runtime.
# Don't use any fancy features.  Ideally, this script should work with any
# Python version starting from 2.6 (yes, it's very old but that's the system
# python on oldest host).


#
# Copyright (C) 2016-2021, AdaCore
#
# This file holds the source list and scenario variables of the runtimes

######################
# Scenario Variables #
######################

# Scenario variables used to configure the runtime sources, together with their
# acceptable values.

# default value is always the first value of the list. So for example for
# optional features enabled via a "no" or "yes" value, always set 'no' as the
# first option to disable the feature by default.

rts_scenarios = {
    'Cuda_Target': ['device', 'host'],
}

# Sources

# List of source files for the runtime
#
# This list is a dictionary with keys being the RTS source folder name, and the
# value a dictionary with the following items:
# * 'conditions': see below
# * 'srcs': a list of source files to be placed in the folder
# * 'bb_srcs': sources only applicable to bare metal targets
# * 'pikeos_srcs': sources only applicable to pikeos targets
#
# Semantic of conditions:
# * the 'conditions' value is always a list.
# * each condition evaluates to a boolean.
# * if several conditions are defined for a folder, then a logical and is used
# * a condition takes the forms:
#     Scenario_Var_Name:accepted_values
#   with accepted_values being:
#     a) a simple value (e.g. RTS_Profile:light): evaluated to True if
#        RTS_Profile is set to "light"
#     b) a coma-separated list of values (e.g. RTS_Profile:light,light-tasking):
#        evaluated to True if RTS_Profile is "light" or "light-tasking"
#     c) a negated value, preceded with an exclamation point (e.g.
#        RTS_Profile:!light): evaluated to True if RTS_Profile is not "light".
# If no condition is defined, then the folder is always used.
rts_sources = {
    # LIBGNAT

    'device_gnat': {
        'conditions': ['Cuda_Target:device'],
        'srcs': [
            'device_gnat/a-numeri.ads',
            'device_gnat/a-nagefl.ads',
            'device_gnat/a-ngelfu.ads',
            'device_gnat/a-nuaufl.ads',
            'device_gnat/a-nuelfu.ads',
            'libgnat/a-unccon.ads',
            'libgnat/ada.ads',
            'hie/i-c__hie.ads',
            'libgnat/i-cexten.ads',
            'device_gnat/i-cpoint.ads',
            'device_gnat/i-cpoint.adb',
            'device_gnat/i-cstrin.ads',
            'libgnat/interfac.ads',
            'libgnat/interfac.ads',
            'libgnat/machcode.ads',
            'libgnat/s-atacco.ads',
            'device_gnat/s-atoope.ads',
            'libgnat/s-maccod.ads',
            'device_gnat/s-memory.ads',
            'device_gnat/s-memory.adb',
            'device_gnat/s-parame.ads',
            'device_gnat/s-assert.ads',
            'device_gnat/s-assert.adb',
            'device_gnat/s-atopex.ads',
            'device_gnat/s-atopex.adb',
            'device_gnat/s-atopri.ads',
            'libgnat/s-stoele.ads',
            'device_gnat/s-stoele.adb',
            'libgnat/s-unstyp.ads',
            'libgnat/unchconv.ads'],
    },
}
