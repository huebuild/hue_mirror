#!/usr/bin/env python
# Licensed to Cloudera, Inc. under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  Cloudera, Inc. licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import logging
import os
import os.path
import sys
import traceback

LOG = logging.getLogger(__name__)

def entry():
  os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'desktop.settings')

  if len(sys.argv[:]) > 1:
    prof_id = subcommand = sys.argv[1]
  else:
    prof_id = str(os.getpid())

  django_installed = False
  try:
    from django.core.exceptions import ImproperlyConfigured
    from django.core.management import execute_from_command_line
    django_installed = True
  except ImportError:
    # The above import may fail for some other reason. Ensure that the
    # issue is really that Django is missing to avoid masking other
    # exceptions on Python 2.
    try:
      import django
      django_installed = True
    except ImportError:
      raise ImportError(
        "Couldn't import Django. Are you sure it's installed and "
        "available on your PYTHONPATH environment variable? Did you "
        "forget to activate a virtual environment?"
      )
    raise

  if django_installed:
    try:
      if os.getenv("DESKTOP_PROFILE"):
        _profile(prof_id, lambda: execute_from_command_line(sys.argv))
      else:
        execute_from_command_line(sys.argv)
    except ImproperlyConfigured, e:
      if len(sys.argv) > 1 and sys.argv[1] == 'is_db_alive' and 'oracle' in str(e).lower():
        print >> sys.stderr, e # Oracle connector is improperly configured
        sys.exit(10)
      else:
        raise e

def _profile(prof_id, func):
  """
  Wrap a call with a profiler
  """
  # Note that some distro don't come with pstats
  import pstats
  try:
    import cProfile as profile
  except ImportError:
    import profile

  PROF_DAT = '/tmp/desktop-profile-%s.dat' % (prof_id,)

  prof = profile.Profile()
  try:
    prof.runcall(func)
  finally:
    if os.path.exists(PROF_DAT):
      os.remove(PROF_DAT)
    prof.dump_stats(PROF_DAT)
    # Sort the calls by time spent and show top 50
    pstats.Stats(PROF_DAT).sort_stats('time').print_stats(50)
    print >>sys.stderr, "Complete profile data in %s" % (PROF_DAT,)
