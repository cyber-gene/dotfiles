"""Verify apt synchronization using isolated chezmoi state and fake commands."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class AptPackagesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        base = Path(self.temp.name)
        source = base / 'source'
        (source / '.chezmoiscripts').mkdir(parents=True)
        (source / 'scripts').mkdir()
        (source / '.chezmoiignore').write_text('scripts\n')
        shutil.copyfile(ROOT / 'scripts/install-apt-packages.sh',
                        source / 'scripts/install-apt-packages.sh')
        self.packages = source / 'scripts/ubuntu-packages.txt'
        self.packages.write_text('git\nfzf\n')
        name = 'run_onchange_after_20-install-apt-packages.sh.tmpl'
        template = (ROOT / '.chezmoiscripts' / name).read_text()
        # Exercise Ubuntu behavior on macOS runners as well.
        template = template.replace('.chezmoi.osRelease.id', '"ubuntu"')
        template = template.replace('.chezmoi.os', '"linux"')
        (source / '.chezmoiscripts' / name).write_text(template)
        self.log = base / 'calls'
        self.log.write_text('')
        binaries = base / 'bin'
        binaries.mkdir()
        commands = {
            'dpkg-query': '[[ "$*" == *git ]] && printf "%s" "${APT_TEST_GIT_STATUS:-install ok installed}"\n',
            'sudo': '[[ "${APT_TEST_FORBID_SUDO:-0}" == 1 ]] && exit 99\nexec "$@"\n',
            'apt-get': 'echo "$*" >> "$APT_TEST_LOG"\nexit "${APT_TEST_STATUS:-0}"\n',
        }
        for name, body in commands.items():
            path = binaries / name
            path.write_text('#!/bin/bash\n' + body)
            path.chmod(0o755)
        self.env = dict(os.environ, PATH=f'{binaries}:{os.environ["PATH"]}',
                        APT_TEST_LOG=str(self.log))
        home = base / 'home'
        home.mkdir()
        self.command = ['chezmoi', '--config', str(base / 'config.toml'),
                        '--source', str(source), '--destination', str(home),
                        '--cache', str(base / 'cache'),
                        '--persistent-state', str(base / 'state.boltdb'),
                        'apply', '--force']

    def apply(self, success=True):
        result = subprocess.run(self.command, env=self.env,
                                capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, success, result.stderr)

    def test_missing_packages_and_list_changes(self):
        self.apply()
        self.assertEqual(self.log.read_text().splitlines(),
                         ['update -q', 'install -y --no-upgrade fzf'])
        self.log.write_text('')
        self.apply()
        self.assertEqual(self.log.read_text(), '')
        self.packages.write_text('git\nfzf\ntmux\n')
        self.apply()
        self.assertIn('install -y --no-upgrade fzf tmux', self.log.read_text())

    def test_installed_packages_do_not_call_apt(self):
        self.packages.write_text('# Already installed\ngit\n')
        self.apply()
        self.assertEqual(self.log.read_text(), '')

    def test_held_installed_packages_do_not_call_sudo_or_apt(self):
        self.packages.write_text('git\n')
        self.env['APT_TEST_GIT_STATUS'] = 'hold ok installed'
        self.env['APT_TEST_FORBID_SUDO'] = '1'
        self.apply()
        self.assertEqual(self.log.read_text(), '')

    def test_held_unconfigured_package_is_still_missing(self):
        self.packages.write_text('git\n')
        self.env['APT_TEST_GIT_STATUS'] = 'hold ok unpacked'
        self.apply()
        self.assertEqual(self.log.read_text().splitlines(),
                         ['update -q', 'install -y --no-upgrade git'])

    def test_failure_is_retried(self):
        self.env['APT_TEST_STATUS'] = '1'
        self.apply(success=False)
        self.assertEqual(self.log.read_text(), 'update -q\n')
        self.env['APT_TEST_STATUS'] = '0'
        self.apply()
        self.assertIn('install -y --no-upgrade fzf', self.log.read_text())

    def test_invalid_package_is_rejected(self):
        self.packages.write_text('--allow-unauthenticated\n')
        self.apply(success=False)
        self.assertEqual(self.log.read_text(), '')
