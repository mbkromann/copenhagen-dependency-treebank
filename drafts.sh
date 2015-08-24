#!/bin/bash

ls `grep -l -v '\#parents' *.wiki | xargs grep -l '`
