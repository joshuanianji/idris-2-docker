'''
Builds a docker image for the given dockerfile and idris version for local testing
'''

import argparse
import requests
import subprocess


def get_latest_sha():
    idris_latest_sha = requests.get(
        'https://api.github.com/repos/idris-lang/Idris2/commits').json()[0]['sha']
    return {
        'idris': idris_latest_sha
    }


def build_image_sha(image: str, sha_info: dict, tag: str):
    if image == 'devcontainer':
        dockerfile = f'{image}-latest.Dockerfile'
        # Devcontainer doesn't need IDRIS_SHA, it uses pack installer
        subprocess.run(['docker', 'build', '-t', tag, '-f', dockerfile, '.'])
    else:
        dockerfile = f'{image}-sha.Dockerfile'
        # Base image needs IDRIS_SHA build arg
        subprocess.run(['docker', 'build', '-t', tag, '-f', dockerfile,
                        '--build-arg', f'IDRIS_SHA={sha_info["idris"]}', '.'])
    print(f'Building {dockerfile} with tag {tag}')
    print(f'Image built with tag {tag}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Builds a docker image')
    parser.add_argument(
        '--image',
        help='The image to build. One of (base | devcontainer). Defaults to base.',
        default='base')
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        '--version',
        help='Idris version to use. Defaults to `latest`, and of the form `v0.6.0`',
        default='latest')
    group.add_argument(
        '--sha',
        help='Idris/Idris LSP SHA to use. Should not be used with `--version`.',
        default=None)
    parser.add_argument(
        '--tag',
        help='Tag to use for the image. Defaults to `{image}-{version}` or `{image}-{tag}.',
        default=None)
    parser.add_argument(
        '--idris_base_version',
        help='Only used for devcontainer SHA builds. Version of idris to build the LSP against. Defaults to `latest`, and in the form `v0.6.0`',
        default='latest'
    )
    args = parser.parse_args()

    if args.image not in ['base', 'devcontainer']:
        print('Invalid image. Must be one of (base | devcontainer).')
        exit(1)

    if args.version and args.version != 'latest':
        # Only the base image is genuinely versioned. The devcontainer installs
        # Idris + LSP via pack (always the current collection), so it is built
        # latest-only — there is no versioned devcontainer Dockerfile.
        if args.image == 'devcontainer':
            print('The devcontainer image is only built as `latest` '
                  '(it installs Idris + LSP via pack). Omit `--version`, or use '
                  '`--image base --version` for a specific Idris version.')
            exit(1)

        # Build versioned base image.
        dockerfile = f'{args.image}.Dockerfile'
        tag = f'{args.image}-{args.version}' if not args.tag else args.tag
        print(f'Building {dockerfile} with tag {tag}')

        subprocess.run(['docker', 'build', '-t', tag, '-f', dockerfile,
                       '--build-arg', f'IDRIS_VERSION={args.version}', '.'])
        print(f'Image built with tag {tag}')

    elif args.version == 'latest':
        # baseimage needs idris latest SHA to build latest versions
        sha_info = get_latest_sha()
        tag = f'{args.image}-latest' if not args.tag else args.tag
        build_image_sha(args.image, sha_info, tag)

    elif args.sha:
        sha_info = {
            'idris': args.sha
        }
        tag = f'{args.image}-{args.sha}' if not args.tag else args.tag
        build_image_sha(args.image, sha_info, tag)

    else:
        print('This should never happen.')
        exit(1)
