# File Parser - extension.rb

This program lists a defined set of file extensions the user wishes to target. The program iterates through all files 
located in the working directory and subdirectories and assembles them into zip files that don't exceed a maximum size. A JSON-formatted manifest, listing information about the files, is included in each zip file. An error log generates a list of files that did not meet a target extension.

## Details

The program includes the following implementations:

- Define a hard list of image file extensions to target
- Define a list of string mapping rules in mapping.txt (in the same location as the extension.rb program); rules will impact the filenames of files saved in the zip file (`fluffy` => `crunchy`)
- Iterate through all files in the parent directory and all subdirectories
- Create a zip file (`my(n).zip`) and populate it with files in the working directory and subdirectories matching any of the target extensions
- Monitor the file size of each file placed in the zip file; when the defined maximum zip size is reached, the zip (`my1.zip`) is closed and a new zip is opened (`my2.zip` and so on) for continued population
- Files are saved in the zip file in the following format: ex. /home/images/person.jpeg saves as `home_images_person.jpeg`
- A JSON-formatted manifest file (`manifest.JSON`) is included in each zip file to list information of files put in the specific zip file
- An error log file (`rejects.txt`) is generated in the working directory to include the date/time the script was run and the list of files in the directory/subdirectories that either did not match a target extension or were larger than the set size limit of the zip file
- Error handling rescues EntryExistsError in Ruby, allowing the user to run the program to search for newly-added files while `my.zip` is still in the parent directory

## Setup

The user should download the extensions.rb file into a working directory of their choosing. Next, the user should open
a Unix/Linux terminal located in the same directory. The user should run the following commands to install the
necessary Ruby libraries known as `gems`:

```bash
sudo gem install zip rubyzip json
```

Once the gems have been installed to the system, the user has the option to configure mapping rules to a file named `mapping.txt` that is located in the same directory as the script. These rules specify string exchanges in the filenames as saved in the zip file(s). The `mapping.txt` file should be written in the following format:

```text
old=new
fluffy=crunchy
194e45=host_path
```

## Usage

Run the following command in the Unix/Linux terminal to execute the program:

```bash
ruby extension.rb
```

Once the program completes, the working directory should include a text file named `rejects.txt` and at least one zip file called `my1.zip`. Further zip files are called `my2.zip`, `my3.zip`, etc. The user may choose to unzip the file with the following command:

```bash
unzip my1.zip
```

The program should run consecutively without errors, however it is best practice to remove any created zip files from previous executions before re-running the program. This can be accomplished with the following command:

```bash
rm *.zip 
```
