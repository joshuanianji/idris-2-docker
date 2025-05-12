'''
Builds a docker image for the given dockerfile and idris version for local testing
'''

import argparse
import requests
import subprocess


def get_latest_sha():
    idris_latest_sha = requests.get(
        'https://api.github.com/repos/idris-lang/Idris2/commits').json()[0]['sha']
    lsp_latest_sha = requests.get(
        'https://api.github.com/repos/idris-community/idris2-lsp/commits').json()[0]['sha']
    return {
        'idris': idris_latest_sha,
        'lsp': lsp_latest_sha
    }


def get_lsp_version(version: str):
    '''
    Given an idris version, return the corresponding lsp version
    If the version is not supported by the LSP, exit with an error
    '''
    version_map = {
        'latest': 'latest',
        'v0.7.0': 'idris2-0.7.0',
        'v0.6.0': 'idris2-0.6.0',
        'v0.5.1': 'idris2-0.5.1',
    }
    if version not in version_map:
        print(f'Idris2 version {version} not supported in LSP')
        exit(1)
    return version_map[version]


def build_image_sha(image: str, sha_info: dict, idris_base_version: str, tag: str):
    dockerfile = f'{image}-sha.Dockerfile'
    print(f'Building {dockerfile} with tag {tag}')
    if image == 'devcontainer':
        # for sha-specific devcontainer images, we also need to pass in the sha from the idris2 github repo
        # by default, this is the latest idris2 sha.
        idris_sha = sha_info['idris'] if idris_base_version == 'latest' else idris_base_version
        subprocess.run(['docker', 'build', '-t', tag, '-f', dockerfile,
                        '--build-arg', f'IDRIS_SHA={idris_sha}',
                        '--build-arg', f'IDRIS_LSP_SHA={sha_info["lsp"]}',
                        '--build-arg', f'IDRIS_VERSION={idris_base_version}',
                        '.'])
    else:
        subprocess.run(['docker', 'build', '-t', tag, '-f', dockerfile,
                        '--build-arg', f'IDRIS_SHA={sha_info["idris"]}', '.'])
    print(f'Image built with tag {tag}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Builds a docker image')
    parser.add_argument(
        '--image',
        help='The image to build. One of (base | debian | ubuntu | devcontainer). Defaults to base.',
        default='base')
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        '--version',
        help='Idris version to use. Defaults to `latest`, and of the form `v0.6.0`',
        default='latest')
    group.add_argument(
        '--sha',
        help='Idris/Idris LSP SHA to use. Should not be used with `--version`. SHAs also cannot be used with base or debian images.',
        default=None)
    parser.add_argument(
        '--tag',
        help='Tag to use for the image. Defaults to `{image}-{version}` or `{image}-{tag}.',
        default=None)
    parser.add_argument(
        '--idris_base_version',
        help='Only used for devcontainer sha images. Version of idris to build the LSP against. Defaults to `latest`, and in the form `v0.6.0`',
        default='latest'
    )
    args = parser.parse_args()

    if args.image not in ['base', 'debian', 'ubuntu', 'devcontainer']:
        print('Invalid image. Must be one of (base | debian | ubuntu | devcontainer).')
        exit(1)

    if args.version and args.version != 'latest':
        # Build versioned image.
        dockerfile = f'{args.image}.Dockerfile'
        tag = f'{args.image}-{args.version}' if not args.tag else args.tag
        print(f'Building {dockerfile} with tag {tag}')

        # build image
        if args.image == 'devcontainer':
            lsp_version = get_lsp_version(args.version)
            subprocess.run(['docker', 'build', '-t', tag, '-f', dockerfile,
                            '--build-arg', f'IDRIS_VERSION={args.version}',
                            '--build-arg', f'IDRIS_LSP_VERSION={lsp_version}',
                            '.'])
        else:
            subprocess.run(['docker', 'build', '-t', tag, '-f', dockerfile,
                           '--build-arg', f'IDRIS_VERSION={args.version}', '.'])
        print(f'Image built with tag {tag}')

    elif args.version == 'latest':
        if args.image in ['base', 'devcontainer']:
            # base and devcontainer need idris' latest SHA to build
            sha_info = get_latest_sha()
            tag = f'{args.image}-latest' if not args.tag else args.tag
            build_image_sha(args.image, sha_info, args.idris_base_version, tag)

        else:
            tag = f'{args.image}-latest' if not args.tag else args.tag
            print(f'Building {args.image}.Dockerfile with tag {tag}')
            subprocess.run(['docker', 'build', '-t', tag, '-f',
                            f'{args.image}.Dockerfile', '.'])
            print(f'Image built with tag {tag}')

    elif args.sha:
        if args.image in ['base', 'debian']:
            print('Cannot build base or debian images with a sha.')
            exit(1)

        sha_info = {
            'idris': args.sha,
            'lsp': args.sha
        }
        tag = f'{args.image}-{args.sha}' if not args.tag else args.tag
        build_image_sha(args.image, sha_info, args.idris_base_version, tag)

    else:
        print('This should never happen.')
        exit(1)
