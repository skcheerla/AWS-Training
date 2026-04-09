 The AWS CDK is an open-source software development framework used to define cloud infrastructure in code and provision it through AWS CloudFormation.

Here is a breakdown of what each part of the command does:

`**npm install -g aws-cdk**`

This command is used to install the **AWS Cloud Development Kit (CDK)** globally on your local machine.

### Command Breakdown

* **`npm install`**: This is the standard command for the Node Package Manager (NPM) to download and install packages.
* **`-g`**: This flag stands for **global**. It ensures that the package is installed in your system's central node_modules folder rather than the local directory where you are currently working. This allows you to run the `cdk` command from any terminal window or project directory.
* **`aws-cdk`**: This is the specific package name for the AWS CDK command-line interface (CLI).

---

### What does the AWS CDK do?
The CDK allows you to define your infrastructure using familiar programming languages like **Python, TypeScript, or Java**. When you run CDK commands, the framework "synthesizes" your code into a CloudFormation template (JSON or YAML) and deploys it to your AWS account.



### Common CDK CLI Commands
Once you have installed the toolkit with the `-g` flag, you gain access to several essential commands in your terminal:

| Command | Action |
| :--- | :--- |
| `cdk init` | Initializes a new CDK project in your preferred language. |
| `cdk synth` | Translates your code into an AWS CloudFormation template. |
| `cdk diff` | Compares your local code with the stack currently deployed in AWS. |
| `cdk deploy` | Deploys your infrastructure to your AWS account. |
| `cdk destroy` | Removes the stack and all its associated resources from AWS. |

### Prerequisites
To run this command successfully, you need to have **Node.js** and **NPM** installed on your system. Because it is a global installation, on macOS or Linux, you might need to prefix the command with `sudo` if you encounter permission errors:

```bash
sudo npm install -g aws-cdk
```

After installation, you can verify it worked by checking the version:
```bash
cdk --version
```

PS E:\Job Search Suresh\My Learning\AWS\AWS CDK\py-starter> cdk init app --language python
Applying project template app for python

# Welcome to your CDK Python project!

This is a blank project for CDK development with Python.

The `cdk.json` file tells the CDK Toolkit how to execute your app.

This project is set up like a standard Python project.  The initialization
process also creates a virtualenv within this project, stored under the `.venv`
directory.  To create the virtualenv it assumes that there is a `python3`
(or `python` for Windows) executable in your path with access to the `venv`
package. If for any reason the automatic creation of the virtualenv fails,
you can create the virtualenv manually.

To manually create a virtualenv on MacOS and Linux:

```
$ python -m venv .venv
```

After the init process completes and the virtualenv is created, you can use the following
step to activate your virtualenv.

```
$ source .venv/bin/activate
```

If you are a Windows platform, you would activate the virtualenv like this:

```
% .venv\Scripts\activate.bat
```

Once the virtualenv is activated, you can install the required dependencies.

```
$ pip install -r requirements.txt
```

At this point you can now synthesize the CloudFormation template for this code.

```
$ cdk synth
```

To add additional dependencies, for example other CDK libraries, just add
them to your `requirements.txt` file and rerun the `python -m pip install -r requirements.txt`
command.

## Useful commands

 * `cdk ls`          list all stacks in the app
 * `cdk synth`       emits the synthesized CloudFormation template
 * `cdk deploy`      deploy this stack to your default AWS account/region
 * `cdk diff`        compare deployed stack with current state
 * `cdk docs`        open CDK documentation

Enjoy!

Initializing a new git repository...
(node:10048) [DEP0190] DeprecationWarning: Passing args to a child process with shell option true can lead to security vulnerabilities, as the arguments are not escaped, only concatenated.
(Use `node --trace-deprecation ...` to show where the warning was created)
warning: in the working copy of '.gitignore', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'README.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'app.py', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'cdk.json', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'py_starter/py_starter_stack.py', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'requirements-dev.txt', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'requirements.txt', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'source.bat', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'tests/unit/test_py_starter_stack.py', LF will be replaced by CRLF the next time Git touches it
Executing Creating virtualenv...
Executing Installing dependencies...

[notice] A new release of pip is available: 25.2 -> 26.0.1
[notice] To update, run: E:\Job Search Suresh\My Learning\AWS\AWS CDK\py-starter\.venv\Scripts\python.exe -m pip install --upgrade pip
✅ All done!
PS E:\Job Search Suresh\My Learning\AWS\AWS CDK\py-starter>
