#!/bin/bash

$(which cpanm >/dev/null 2>&1) || ( curl -L http://cpanmin.us | perl - App::cpanminus )
$(which dzil >/dev/null 2>&1) || perl $(which cpanm) Dist::Zilla
dzil listdeps | xargs cpanm
