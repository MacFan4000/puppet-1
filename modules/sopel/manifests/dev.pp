class sopel::dev(
){
$ensure = lookup('sopel::dev::timer')
file { 'dev-venv':
        ensure  => directory,
        path    => '/srv/sopelbots/devvenv/',
        mode    => '770',
        owner   => sopel,
        group   => sopel,
    }
    file { 'dev-require':
        ensure  => file,
        path    => '/srv/sopelbots/devrequire.txt',
        source  => 'puppet:///modules/sopel/devrequire.txt',
        mode    => '770',
        owner   => sopel,
        group   => sopel,
        notify  => Exec['update dev'],
    }
    exec { 'update dev':
          command     => '/srv/sopelbots/devvenv/bin/pip3.9 install -U -r /srv/sopelbots/devrequire.txt',
          cwd         => '/srv/sopelbots/devvenv',
          refreshonly => true,
          user        => sopel,
          require     => File['dev-venv', 'dev-require']
    }
    file { 'dev-directory':
        ensure  => directory,
        path    => '/srv/sopelbots/devcode/',
        mode    => '770',
        owner   => sopel,
        group   => sopel,
    }
    $repos = ['MirahezeBots', 'sopel-adminlist', 'sopel-channelmgnt', 'jsonparser', 'sopel-joinall', 'sopel']
    $repos.each |$repo| {
      git::clone { "FOSSBots/${repo}":
          ensure    => 'latest',
          directory => "/srv/sopelbots/devcode/${repo}",
          branch    => 'dev',
          mode      => '770',
          owner     => sopel,
          group     => sopel,
          notify => Exec["rebuild ${repo}"],
      }
      exec { "rebuild ${repo}":
          command     => "/usr/bin/rm -rf /srv/sopelbots/devcode/${repo}/dist/*.whl && /srv/sopelbots/devvenv/bin/pyproject-build --wheel --outdir /srv/sopelbots/devcode/${repo}/dist /srv/sopelbots/devcode/${repo} && /usr/bin/find / -wholename \"/srv/sopelbots/devcode/${repo}/dist/*.whl\" | /usr/bin/xargs /srv/sopelbots/devvenv/bin/pip3.9 install --no-dependencies --force-reinstall",
          cwd         => "/srv/sopelbots/devcode/${repo}",
          user        => sopel,
          refreshonly => true,
      }
    }
    systemd::service { 'mirahezebottestlibera':
        ensure  => $ensure,
        content => systemd_template('mirahezebottestlibera'),
        restart => true,
        require => Git::Clone['FOSSBots/sopel'],
    }
}
