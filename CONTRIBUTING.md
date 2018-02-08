# How to Contribute

Welcome to TaleCaster, a project to provide a complete solution for media management for the home.

We're glad you're here. Contributing to TaleCaster is very easy. 

## Testing
Simply put, we need _you_ to test our software for us. That's easy as can be: just use it!
If you run into an issue, simply [open an issue against the main talecaster repo](https://github.com/rootwyrm/talecaster/issues).

If you want to help with unit testing, most of our code is written in portable shell script and Python. We always welcome new test cases.
When proposing a new test case, please be sure to open an issue in the correct repository. For all 'core' TaleCaster items, that's this one.
For Linux, Docker, and Docker Hub please open them against the correct Docker image.

## Adopting Problems
We have a great many things we'd like to do, that we simply don't have time to do. 
If you'd like to adopt a problem, simply comment in the relevant issue(s) that you would like to adopt it and we'll get you started!

## Submitting Change Requests
Please send a [GitHub Pull Request](https://github.com/rootwyrm/talecaster/pulls) against the correct repository.
Remember: only changes to the common code and documentation should be submitted to the [main repository](https://github.com/rootwyrm/talecaster)

## Coding Conventions
Because TaleCaster is primarily FreeBSD based, we attempt to comply with [style(9)](https://www.freebsd.org/cgi/man.cgi?query=style&sektion=9) and [rcng style conventions](https://www.freebsd.org/doc/en_US.ISO8859-1/articles/rc-scripting/rcng-dummy.html).

Some important things to note about our conventions that are different from `style(9)`:
* We do not use VCS IDs
* Do _not_ use Camel Case
* Functions must be clearly labeled
* Always avoid duplicative funnctions 
* Always locate multiple use functions and macros in libraries
* Configuration files are not required to support commenting
* Error checking functions must be all-caps, e.g. `CHECK_ERROR()`, `CHECK_RETURN()`
