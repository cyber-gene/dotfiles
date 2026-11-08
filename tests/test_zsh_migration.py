"""Exercise migration through real chezmoi applies in isolated destinations."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BOOTSTRAP = '[[ -f ~/.config/zsh/init.zsh ]] && source ~/.config/zsh/init.zsh\n'


class MigrationTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        base = Path(self.temp.name)
        self.home = base / 'home'
        self.home.mkdir()
        self.source = base / 'source'
        self.source.mkdir()
        for name in ('scripts', 'dot_config/zsh'):
            shutil.copytree(ROOT / name, self.source / name)
        (self.source / '.chezmoiscripts').mkdir()
        shutil.copyfile(ROOT / '.chezmoiscripts/run_before_00-migrate-zshrc.sh',
                        self.source / '.chezmoiscripts/run_before_00-migrate-zshrc.sh')
        shutil.copyfile(ROOT / '.chezmoiignore', self.source / '.chezmoiignore')
        self.command = ['chezmoi', '--config', str(base / 'config.toml'),
                        '--source', str(self.source), '--destination', str(self.home),
                        '--cache', str(base / 'cache'),
                        '--persistent-state', str(base / 'state.boltdb'),
                        'apply', '--force']
        self.env = dict(os.environ, HOME=str(self.home))

    def apply(self, success=True, extra=()):
        result = subprocess.run(self.command + list(extra), env=self.env,
                                capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, success, result.stderr)
        return result

    def test_new_and_repeated_apply(self):
        self.apply()
        self.assertEqual((self.home / '.zshrc').read_text(), BOOTSTRAP)
        backups = list(self.home.glob('.zshrc-migration-backup.*'))
        self.apply()
        self.assertEqual(list(self.home.glob('.zshrc-migration-backup.*')), backups)
        self.assertEqual((self.home / '.zshrc').read_text(), BOOTSTRAP)

    def test_known_versions_preserve_tail_local_and_backups(self):
        for fixture in (ROOT / 'scripts/legacy-zshrc').glob('*.zsh'):
            with self.subTest(version=fixture.name):
                original = fixture.read_text() + '\nexport PATH="$HOME/tool/bin:$PATH"\n'
                (self.home / '.zshrc').write_text(original)
                (self.home / '.zshrc.local').write_text('export LOCAL_SETTING=yes\n')
                self.apply()
                self.assertEqual((self.home / '.zshrc').read_text(),
                                 BOOTSTRAP + '\nexport PATH="$HOME/tool/bin:$PATH"\n')
                self.assertEqual((self.home / '.zshrc.local').read_text(),
                                 'export LOCAL_SETTING=yes\n')
                self.assertTrue(any((p / '.zshrc').read_text() == original
                                    for p in self.home.glob('.zshrc-migration-backup.*')))

    def test_unknown_stops_before_shared_files_change(self):
        original = 'export CUSTOM=yes\n'
        (self.home / '.zshrc').write_text(original)
        self.apply(success=False)
        self.assertEqual((self.home / '.zshrc').read_text(), original)
        self.assertFalse((self.home / '.config/zsh/init.zsh').exists())
        # Manual review acknowledges migration by inserting the documented line.
        (self.home / '.zshrc').write_text(original + BOOTSTRAP)
        self.apply()
        self.assertEqual((self.home / '.zshrc').read_text(), original + BOOTSTRAP)

    def test_symlink_is_preserved(self):
        target = self.home / 'custom.zsh'
        target.write_text('export CUSTOM=yes\n')
        (self.home / '.zshrc').symlink_to(target)
        self.apply(success=False)
        self.assertTrue((self.home / '.zshrc').is_symlink())
        self.assertEqual(target.read_text(), 'export CUSTOM=yes\n')

    def test_dry_run_does_not_migrate(self):
        self.apply(extra=('--dry-run',))
        self.assertFalse((self.home / '.zshrc').exists())
        self.assertEqual(list(self.home.glob('.zshrc-migration-backup.*')), [])

    def test_previously_managed_file_is_not_removed(self):
        # Populate chezmoi's previous state with the old managed entry point.
        script = self.source / '.chezmoiscripts/run_before_00-migrate-zshrc.sh'
        script.rename(script.with_suffix('.disabled'))
        legacy = (ROOT / 'scripts/legacy-zshrc/local-first.zsh').read_text()
        (self.source / 'dot_zshrc').write_text(legacy)
        ignore = self.source / '.chezmoiignore'
        ignore.write_text(ignore.read_text().replace('.zshrc\n', ''))
        self.apply(extra=('--exclude=scripts',))
        (self.source / 'dot_zshrc').unlink()
        script.with_suffix('.disabled').rename(script)
        shutil.copyfile(ROOT / '.chezmoiignore', ignore)
        self.apply()
        self.assertEqual((self.home / '.zshrc').read_text(), BOOTSTRAP)


if __name__ == '__main__':
    unittest.main()
