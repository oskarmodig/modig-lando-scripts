# Modig Lando Scripts
## Pre-requisites
- PHP 8.2 (or later)
- [Composer](https://getcomposer.org/download/)
- jq (install with `sudo apt install jq`)
### Windows
You need WSL 2 running, the correct distro as default
(check with `wsl --list --verbose` and `wsl --set-default Ubuntu`, for instance).

Also, you probably need to add this to your `/etc/wsl.conf` file (in WSL)
```
[automount]
options = "metadata,umask=22,fmask=11"
```

Then, make sure you have a Linux user that is not `root`, it might need sudo permissions though.
Also, make sure your Linux user is the owner of the project files.

You should the be able to run setup with `modlan setup`.
## Usage
### Lando scripts
These are scripts that are run in the Lando container. You can set them up in the `.lando.yml` file, and run them with `lando <script-name>`.
They are run with the `modig-lando.sh` script, and the input variables are set with the `MOD_INP_ENV` and `MOD_INP_SCRIPT` variables.
- `deploy` - Deploys the package to the server
- `make-pot` - Creates a .pot file for translations

- Example:
```yaml
  deploy:
      cmd:
        - appserver: modig-lando.sh MOD_INP_ENV=app_env MOD_INP_SCRIPT=deploy
```
### Unix
- WordPress setup is run with `modlan.sh setup`
- WordPress destruction is run with `modlan.sh destroy`
### Windows
- WordPress setup is run with `modlan setup`
- WordPress destruction is run with `modlan destroy`
- Starting ngrok is run with `modlan ngrok`
- Stopping ngrok is run with `modlan ngrok-kill`

For all the commands above, you can also pass your linux username as the second argument, if it is not the default user in WSL.

## Environment Setup
This is a guide for setting up the local development environment for the first time, not per project.
It is assumed that you have the pre-requisites installed.

1. Install [Lando](https://docs.lando.dev/getting-started/installation.html) (this will install the required version of Docker as well)
2. Install the WordPress Coding Standard Ruleset globally `composer global require oskarmodig/wpcs`
    1. When it asks, do trust it to execute code
3. Install scripts for building and deploying the project `composer global require oskarmodig/lando-scripts`
4. Add the global composer bin folder to your PATH
    1. On Windows, this is `%APPDATA%\Composer\vendor\bin`
    2. On Unix, this is `~/.composer/vendor/bin`.
5. Update composer config process-timout to 0 `composer global config process-timeout 0`

NOTE that with Windows/WSL, `oskarmodig/lando-scripts` has to be installed both in Windows and in WSL.

## Project Setup
### Environment variable files
There are 2 types of environment variable files,
those specific for each package ("package env files"), and those that are global for the lando app ("global env files").
If you use the global env files, they have to be named `.modig.lando.global.env`
(can be included in git) and/or `.modig.lando.local.env` (should NOT be included in git).
They have to be placed in the same dir as your .lando.yml file.

The package env files can be called and placed as you like, but preferably in the package root.
Name suggestions are `lando.global.env` and `lando.local.env`, again with the same rules for git as above.

What can be placed in the global and package env files is the same is described in the [Environment Variables](#environment-variables) section.
### lando app
Here is a template for the '.lando.yml' file, which is the Lando configuration file for the project:
```yaml
#
# SETUP INSTRUCTIONS can be found at https://github.com/oskarmodig/modig-lando-scripts
#
name: app-name
recipe: wordpress
proxy:
  appserver:
    - app-name.lndo.site
    - second.app-name.lndo.site
    - third.app-name.lndo.site
  pma:
    - pma.app-name.lndo.site
  mailhog:
    - mail.app-name.lndo.site
config:
  webroot: wordpress
  php: '8.2'
excludes: # This is only needed for a WSL setup. Excludes folders from the Docker file sync, which greatly improves performance
  - wordpress # Excludes the entire WordPress folder
  - node_modules # You can remove this if not using Node.js
  - vendor # You can remove this if not using Composer
services:
  appserver:
    build:
      - composer global require oskarmodig/lando-scripts # Installs the deploy scripts in the container.
    extras:
      - apt-get update -y
      - apt-get install zip -y
      - apt-get install nano -y
  pma:
    type: phpmyadmin
    host:
      - database
  mailhog:
    type: mailhog
    hogfrom:
      - appserver
environment:
  PATH: "/var/www/.composer/vendor/bin:$PATH" # Adds the global composer bin folder to the PATH, so you can run the scripts from the container. 

env_file: # Run 'lando rebuild' for changes here in these files to take effect
  - .lando.public.env
  - .lando.secret.env

events:
  post-start:
    - appserver: composer global update # Updates the global composer packages when the container starts    

tooling:
  composer:
    service: appserver
  mount:
      cmd:
        - appserver: cd /app/wordpress/wp-content/plugins/ && ln -snf ../../../app-name app-name # Symlinks the app to the WordPress plugins folder

  deploy:
      cmd:
        - appserver: modig-lando.sh MOD_INP_ENV=app_env MOD_INP_SCRIPT=deploy # Runs the deploy script

  deploy-test:
      cmd:
        - appserver: modig-lando.sh MOD_INP_ENV=app_env MOD_INP_SCRIPT=deploy MOD_INP_TEST=true # Runs the deploy script with the test flag

  make-pot:
    cmd:
      - appserver: modig-lando.sh MOD_INP_ENV=app_env MOD_INP_SCRIPT=make-pot # Creates a .pot file for translations
```
#### Multiple packages
The paths above assume that there is only one package, and that WordPress and the lando app is set up in the package directory.
If there are multiple packages, you can place the packages (git repos) in sub-folders, and have a single .lando.yml file in the root of the project.

You have to modifiy the lando file as follows:
1. `env_file` - Add the package specific environment files to the `env_file` list.
   - Example: 
   ```yaml
   env_file: # Run 'lando rebuild' for changes here in these files to take effect
     - plugin-dir/.lando.public.env
     - plugin-dir/.lando.secret.env
     - theme-dir/.lando.public.env
     - theme-dir/.lando.secret.env
     ```
2. `mount` - Add a mount command for each package.
   - Example: 
     ```yaml
     mount:
       cmd:
         - appserver: cd /app/wordpress/wp-content/plugins/ && ln -snf ../../../plugin-dir plugin-dir
         - appserver: cd /app/wordpress/wp-content/theme/ && ln -snf ../../../theme-dir theme-dir
     ```
3. `tooling` - Add a tooling command for each package.
   - Example: 
     ```yaml
     deploy-plugin:
         cmd:
           - appserver: modig-lando.sh MOD_INP_ENV=plugin_env MOD_INP_SCRIPT=deploy
     deploy-theme:
         cmd:
           - appserver: modig-lando.sh MOD_INP_ENV=theme_env MOD_INP_SCRIPT=deploy
     ```

### Input variables
Input variables are set when calling lando scripts, mainly used to determine what environment and script to run.
The `MOD_INP_ENV` and `MOD_INP_SCRIPT` variables are used to determine what environment and script to run.

See the lando tooling section in the [`.lando.yml` file](#lando-app) for examples of how to run the scripts.

| Variable       | Description                                                                                                     |
|----------------|-----------------------------------------------------------------------------------------------------------------|
| MOD_INP_SCRIPT | The script to run (e.g., 'deploy' or 'make-pot'). See case below for available scripts.                         |
| MOD_INP_ENV    | The package (environment) to get variables for. See more under [Environment variables](#environment-variables). |
| MOD_INP_TEST   | Can be set to use test variables. See more under [Environment variables](#environment-variables).               |

### Environment Variables
#### Global environment variables
Again, these variables are set per lando app, rather than per package.
They are mainly used by the Windows and Linux scripts (modlan.bat and modlan.sh), run outside the lando app container.
##### General global environment variables

| Variable         | Description                                                                         | Default value                                                           |
|------------------|-------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| MODIG_LINUX_USER | For Windows scripts, what user in your WSL instance to run commands as.             | [not set, script will default to the default user for the WSL instance] |
| MODIG_WP_PATH    | Relative path to WordPress (from cwd, which should be same dir as .lando.yml file). | `wordpress`                                                             |

##### Setup global environment variables
Variables for site setup, run with `modlan.sh setup` or `modlan.bat setup`.

| Variable              | Description                                                                                                                                                                      | Default value |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| MODIG_SETUP_PLUGINS   | Comma separated list of plugin names and/or URLs. These plugins are installed on site setup. Note that if `woocommerce` is one of them, a special WooCommerce setup will be run. | [not set]     |
| MODIG_SETUP_THEMES    | Comma separated list of theme names and/or URLs. These themes are installed on site setup. Note that if `storefront` is one of them, a special Storefront setup will be run.     | [not set]     |
| MODIG_SETUP_MULTISITE | If this is set (to anything), the site will be set up as multisite.                                                                                                              | [not set]     |

##### NGROK global environment variables
| Variable                        | Description                                                                                                     | Default value                                                                                    |
|---------------------------------|-----------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| MODIG_NGROK_FULL_URL            | Local URL of site that ngrok will share with the world.                                                         | [not set, the 4th url from lando info will be used, usually the https version of your main site] |
| MODIG_NGROK_DOMAIN              | Domain to use when starting ngrok service.                                                                      | [not set, a random URL will be used]                                                             |
| MODIG_NGROK_OAUTH_GOOGLE        | If this is set, visitors must authenticate with Google to view the ngrok site.                                  | [not set, no authentication required]                                                            |
| MODIG_NGROK_OAUTH_GOOGLE_DOMAIN | If this is set, visitors must authenticated with a Google account ON THIS DOMAIN to view the ngrok site.        | [not set]                                                                                        |
| MODIG_NGROK_OAUTH_GOOGLE_EMAIL  | If this is set, visitors must authenticated with a Google account ON THIS EMAIL ADDRESS to view the ngrok site. | [not set]                                                                                        |

#### Package environment variables

Since a Lando app might contain multiple packages,
all the environment variables below can have a package identifier in them,
to separate the variables for different packages.
So for instance, `MOD_VAR_PACKAGE_NAME`
can be set as both `MOD_VAR__PACKAGE1__PACKAGE_NAME` and `MOD_VAR__PACKAGE2__PACKAGE_NAME` in the same file.
What variable is used is determined by the [`MOD_INP_ENV` input variable](#input-variables).

In addition to the setting variables per package,
they can also be set as test variables, with `__TEST__` in the variable name.
Like `MOD_VAR__TEST__PACKAGE_NAME` or `MOD_VAR__PACKAGE1_TEST__PACKAGE_NAME`.

##### General package environment variables

| Variable                 | Description                                                              | Default value               |
|--------------------------|--------------------------------------------------------------------------|-----------------------------|
| MOD_VAR_PACKAGE_TYPE     | The type of package, `plugin` or `theme`.                                | `plugin`                    |
| MOD_VAR_PACKAGE_PATH     | Absolute path to the package files, in the lando environment.            | `/app`                      |
| MOD_VAR_WP_PATH          | Relative path to WordPress files, from the package path.                 | `wordpress`                 |


##### Deploy package environment variables

| Variable                       | Description                                                                                                                                                                | Default value               |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| MOD_VAR_PACKAGE_DEV_NAME       | The name of the package as seen by WordPress (plugin/theme folder name).                                                                                                   | Lando app name if available |
| MOD_VAR_PACKAGE_NAME           | Name of the folder and zip file created for the deploy package.                                                                                                            | Required for deploy         |
| MOD_VAR_PUBLISH                | Needs to be set for the publish script to run                                                                                                                              | unset                       |
| MOD_VAR_SKIP_COMPOSER          | If set, composer is not run. If this is not set, and a `composer.json` file exists, composer is run with `--no-dev --optimize-autoloader` before packaging.                | unset                       |
| MOD_VAR_SKIP_NPM               | If set, npm is not run. If this is not set, and a `package.json` file exists, `npm install && npm run build` is run before packaging.                                      | unset                       |
| MOD_VAR_EXTRA_EXCLUDES         | Can be set to a comma-separated string with additional excludes. Used by `rsync`. The [default list of excludes](#default-list-of-excludes-for-deploy) can be found below. | unset                       |
| MOD_VAR_REMOVE_DIR_AFTER_BUILD | Can be set to a comma-separated string of paths to folders to remove after composer/npm build process.                                                                     | unset                       |

##### Publish package environment variables
| Variable             | Description                                                   | Default value                                                                                                                           |
|----------------------|---------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| MOD_VAR_REMOTE_USER  | User on remote server used for login                          | `ubuntu`                                                                                                                                |
| MOD_VAR_REMOTE_HOST  | IP or hostname of the remote server                           | unset                                                                                                                                   |
| MOD_VAR_CERT_PATH    | Path to the certificate file used for login                   | `/lando/ssh`                                                                                                                            |
| MOD_VAR_CERT_FILE    | Name of the certificate file used for login                   | `cert.pem`                                                                                                                              |
| MOD_VAR_FILE_1       | Name of the file to be published                              | MOD_VAR_PACKAGE_NAME                                                                                                                    |
| MOD_VAR_FILE_2       | Name of the file to be published                              | If MOD_VAR_FILE_1 has no extension, this is set to the same filename, but with the `.json` extension. FILE_1 will the default to `.zip` |
| MOD_VAR_ARCHIVE_FILE | Set this to also create an archive file of the package        | unset                                                                                                                                   |
| MOD_VAR_TARGET_USER  | User that will be set to owner of the file                    | unset                                                                                                                                   |
| MOD_VAR_TARGET_GROUP | User group that will be set to owner group of the file        | unset                                                                                                                                   |
| MOD_VAR_TARGET_DIR   | Absolute path on remote server where the files will be placed | unset                                                                                                                                   |



##### Git tag package environment variables
| Variable               | Description                                                                                    | Default value |
|------------------------|------------------------------------------------------------------------------------------------|---------------|
| MOD_VAR_GIT_TAG_PREFIX | Prefix for git tags. Added before package version. Defaults to `v``, so tag would be "v1.0.0". | `v`           |
| MOD_VAR_GIT_USERNAME   | Gitlab username (script prompts for password)                                                  | unset         |


### Default list of excludes for deploy
In addition to these default excludes, the [`MOD_VAR_EXTRA_EXCLUDES` environment variable](#deploy-environment-variables) can be set to a comma-separated string with additional excludes.

| Exclude                  | Description                                                                                                                                                                                                                                    |
|--------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `"/.*"`                  | All hidden files and folders                                                                                                                                                                                                                   |
| `"/*.env"`               | All environment files                                                                                                                                                                                                                          |
| `/node_modules`          | Node modules (note that if `MOD_VAR_SKIP_NPM` is not set, this will be generated on packaging). Also note that `package.json`, `package-lock.json`, `webpack.config.js` and `babel.config.json` will be deleted before package zip is created. |
| `/wordpress`             | WordPress files                                                                                                                                                                                                                                |
| `/testsuite`             | Test suite                                                                                                                                                                                                                                     |
| `/tests`                 | Tests                                                                                                                                                                                                                                          |
| `/bin`                   | Binaries                                                                                                                                                                                                                                       |
| `/deploy`                | Deploy files                                                                                                                                                                                                                                   |
| `/customization-plugins` | Customization plugins                                                                                                                                                                                                                          |
| `"*.gitlab-ci.yml*"`     | Gitlab CI files                                                                                                                                                                                                                                |
| `"*.git*"`               | Git files                                                                                                                                                                                                                                      |
| `"*.DS_Store*"`          | Mac OS files                                                                                                                                                                                                                                   |
| `/vendor`                | Composer vendor files (note that if `MOD_VAR_SKIP_COMPOSER` is not set, this will be generated on packaging). Also note that `composer.json` and `composer.lock` will be deleted before package zip is created.                                |
| `"phpunit.xml.dist"`     | PHPUnit config                                                                                                                                                                                                                                 |
