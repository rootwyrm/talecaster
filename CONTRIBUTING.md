# How to Contribute

Welcome to TaleCaster, a project to provide a complete solution for media management for the home.

We're glad you're here. Contributing to TaleCaster is very easy. 

## Testing
Simply put, we need _you_ to test our software for us. That's easy as can be: just use it!
If you run into an issue, simply [open an issue against the main talecaster repo](https://github.com/rootwyrm/talecaster/issues).

If you want to help with unit testing, most of our code is written in portable shell script and Python. We always welcome new test cases.
When proposing a new test case, please be sure to open an issue in this repository.

## Adopting Problems
We have a great many things we'd like to do, that we simply don't have time to do. 
If you'd like to adopt a problem, simply comment in the relevant issue(s) that you would like to adopt it and we'll get you started!

## Submitting Change Requests
Please send a [GitHub Pull Request](https://github.com/rootwyrm/talecaster/pulls) against the main repository. Unless it is a security fix, pull requests should be submitted against `latest`.

## Coding Conventions
TaleCaster has a somewhat unique coding style, and it is important to comply with this for consistency. Most files have an appropriate [vim modeline](https://vim.fandom.com/wiki/Modeline_magic). For shell scripts, we use **4 space indentation** (vim: `expandtab`, emacs: `indent-tabs-mode . nil`). For Python, we use vim 8.4 defaults. Lines longer than 80 characters should be avoided *when possible and reasonable*. Functions must be prefixed with a comment which at minimum indicates the required and optional arguments, i.e. `# CHECK_ERROR ARG: return_code` or `# rebuild_database ARG: sqlite_file [application]`. All shell functions must be declared with `function` (ksh conventional).

Some very important notes about our conventions:
* We do not use VCS IDs in files
* Do _not_ use Camel Case
* Functions must be clearly labeled
* Error checking and trapping functions must be `ALL_CAPS`
* Always locate multiple use functions and macros in libraries
* Configuration files are not *required* but strongly *preferred* to support commenting

## Privacy Conventions
We have a strict 'keep no unnecessary data' policy both for the project *and* default configurations. 

Configurations should, by default, log only the minimum necessary information. (i.e. OpenVPN defaults to log level 3 - connection, errors, and warnings.) Any application which logs **must** include a log rotation or retention policy with a default retention period of 7 days.

Issues or other entries which contain sensitive information will be promptly edited to remove sensitive information or will be deleted.

We define sensitive information as any proprietary information which would not normally be accessible or known to the general public. Some examples of this include (obviously) passwords, account names (other than the defaults,) and the addresses of non-public DNS servers or VPN servers. We recommend when opening an issue that contains potentially sensitive information, you rewrite all potentially sensitive IP addresses in the format of `X.X.X.Actual_Last` and you 'genercize' hostnames such as `vpn.server` and `my.talecaster`.
