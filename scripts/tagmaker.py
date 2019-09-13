import argparse
import sys
import os
from distutils.version import StrictVersion
from packaging import version
from github import Github


def increment_version(version, increment_type):
    version = version.split('.')
    # increase our version number
    version[increment_type] = str(int(version[increment_type]) + 1)

    increment_type = increment_type + 1  # reset lower numbers
    while increment_type <= 2:
        version[increment_type] = str(0)
        increment_type = increment_type + 1

    return '.'.join(version)

########################################################################################################################
##### tagmaker #########################################################################################################
########################################################################################################################

parser = argparse.ArgumentParser(
    description='Tagmaker makes tags.'
)

parser.add_argument("access_token", type=str,
                    help="The github person access token used to create a release.")
parser.add_argument("--repo", type=str, default="",
                    help="The repository's name.")
parser.add_argument("--message", type=str, default="",
                    help="The release message. Optional.")
parser.add_argument("--current_commit_hash", type=str, default="",
                    help="The commit we're building a tag/release for.")
parser.add_argument("--workspace_directory", type=str,
                    default="", help="The path to the artifact.")
parser.add_argument("--artifact_name", type=str,
                    default="", help="The artifact's name.")
parser.add_argument("--should_increment", type=int, default=2,
                    help="Which version number should be incremented - 0 = major, 1 = minor, 2 = patch")
parser.add_argument("--is_draft", action="store_true", default=False,
                    help="If this is set, release will be a draft.")
parser.add_argument("--is_prerelease", action="store_true", default=False,
                    help="If this is set, release will be a prerelease.")

args = parser.parse_args()
paToken = args.access_token
repo = args.repo
message = args.message
current_commit_hash = args.current_commit_hash
workspace_directory = args.workspace_directory
artifact_name = args.artifact_name
should_increment = args.should_increment
is_draft = args.is_draft
is_prerelease = args.is_prerelease

if should_increment > 2 or should_increment < 0:
    print("ERROR, not incrementing a valid version field!")
    sys.exit(1)


# get repo
github = Github(paToken)
user = github.get_user()
repos = user.get_repos()
for _repo in repos:
    if _repo.name == repo:
        repo = _repo

# previous version
previous_tag = repo.get_tags()[0]
previous_version = StrictVersion(previous_tag.name)

# new version
new_version = StrictVersion(increment_version(previous_tag.name, should_increment))
new_version_string = str(new_version)

# message
if message == '':
    message = "tag " + str(new_version) + " proudly created by tidecaller"

# artifact we're uploading (modNameCanonical.zip)
artifact = open(workspace_directory + os.path.sep + artifact_name)
artifact_path = os.path.realpath(artifact.name)

#repo.create_git_tag(tag=new_version, message=tag_message, object=current_commit_hash, type="commit", tagger=user)
print("creating git release, tag is " + new_version_string + ", file is " + artifact.name)
release = repo.create_git_release(  tag=new_version_string,
                                    name=new_version_string,
                                    message=message,
                                    draft=is_draft,
                                    prerelease=is_prerelease,
                                    target_commitish=current_commit_hash)
release.upload_asset(path=artifact_path, content_type="application/zip")
