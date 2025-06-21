import json
conf = open('conf/packer/docker.json', 'r')
version = json.loads(conf.read())['version']

# def test_version_via_default(host):
#     cmd = host.run_expect([0], 'docker run cliffano/awstaga --version')
#     assert cmd.stdout == '0.12.0\n'

def test_help_via_default(host):
    cmd = host.run_expect([0], 'docker run cliffano/awstaga --help')
    assert 'Usage: awstaga [OPTIONS]' in cmd.stdout

# def test_version_via_latest_tag(host):
#     cmd = host.run_expect([0], 'docker run cliffano/awstaga:latest --version')
#     assert cmd.stdout == '0.12.0\n'

def test_help_via_latest_tag(host):
    cmd = host.run_expect([0], 'docker run cliffano/awstaga:latest --help')
    assert 'Usage: awstaga [OPTIONS]' in cmd.stdout

# def test_version_via_version_tag(host):
#     cmd = host.run_expect([0], f'docker run cliffano/awstaga:{version} --version')
#     assert cmd.stdout == '0.12.0\n'

# TODO: uncomment after publishing
# def test_help_via_version_tag(host):
#     cmd = host.run_expect([0], f'docker run cliffano/awstaga:{version} --help')
#     assert 'Usage: awstaga [OPTIONS]' in cmd.stdout
