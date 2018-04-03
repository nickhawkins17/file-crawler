
# Run the following commands in the terminal:
# sudo gem install zip
# sudo gem install rubyzip
# sudo gem install json

require 'zip'
require 'json'

class Extensions
	# Initialize empty array of @@files - files with target extensions
	@@files = []

	# Initialize empty array of @@rejects - files with different extensions
	@@rejects = []

	# Initialize the maximum size of the zip file (in bytes)
	# Give enough buffer to add manifest at the end
	# 95 megabytes; give 5 megabyte buffer for manifest
	@@zipSizeMax = 95000000
	
	# Define target file extensions (all lowercase)
	@@targetExtensions = [".png", ".jpeg", ".jpg", ".gif", ".tiff", ".ppm", ".pgm", ".pbm", ".pnm"]
	
	# Populate @@files and @@rejects arrays with files in specific path
	def search(path)
		# Iterate through each file in the path
		Dir.foreach(Dir.pwd+"/"+path) do |x|
			# Check if the current file has a target extension and place in appropriate array
			# Extensions on the files are case-insensitive
			if @@targetExtensions.include? File.extname(x).downcase
				# Reject file that's larger than the zip file size maximum
				if File.size(Dir.pwd+"/"+path+x) >= @@zipSizeMax
					@@rejects.push(Dir.pwd+"/"+path+x)
					puts "\nFile \"" + x + "\" (" + File.size(Dir.pwd+"/"+path+x).to_s+
						" bytes) rejected. \nLarger than zip file maximum size ("+ 
						@@zipSizeMax.to_s+" bytes).\n"
				# Accepted file is pushed to array
				else
					@@files.push(Dir.pwd+"/"+path+x)
				end
			# Rejected file is pushed to array
			else 
				if File.file?(x)
				@@rejects.push(Dir.pwd+"/"+path+x)
				end
			end
		end
	end

	# Use mapping rules from mapping.txt to rename files in zip 
	def mapName (name)
		IO.foreach('mapping.txt') do |line|
			map = line.split('=')
			name.sub!(map[0], map[1])
			name.sub!("\n","")
		end

		return name
	end

	def createManifest (startII, endII)
		# Initialize count of files in zip/for manifest
		fileCount = 0
		# Write a JSON formatted manifest of files with target extension
		File.open(Dir.pwd+"/manifest.JSON", 'w') do |file|
			# Beginning of manifest file
			file.write("{\n\"manifests\":\n[\n")
			for ii in startII..endII

				# Commas to separate each file entry
				if fileCount > 0
					file.write(",\n")
				end

				# JSON manifest entry for each file
				file.write(JSON.pretty_generate({ :original_filename => File.basename(@@files[ii]), 
					:metadata => [{ :name => "SOURCE", :value => "the interwebs"},{ :name => 
					"CL******", :value => "******"},{ :name => "TOPIC", :value => "persons"},
					{ :name => "SIZE", :value => File.size(@@files[ii]).to_s + " bytes."} ] }))

				fileCount += 1
			end
			# End of manifest file
			file.write("\n]\n}")
		end
	end

	# Initialize Extensions object to call search method
	ext = Extensions.new
	# Initialize time object to monitor time of script execution
	time = Time.new
	# Initialize count of zip files
	zipCount = 1
	# Initialize index of total files to be added to zip file(s) 
	fileIndex = 0
	# Initialize array with current working directory
	subDirectories = [""]

	# Populate array with all subdirectores in the working directory
	subDirectories += Dir.glob("**/")

	# Run a search of files in each directory/subdirectory
	subDirectories.each do |z|
		ext.search(z)
	end

	# Iterate through all files to be added to zip file(s)
	while fileIndex < @@files.length do

		# Initialize the size of the current zip file (in bytes)
		zipSizeCurrent = 0
		# Initialize the number of files added to the current zip file 
		filesInZip = 0

		# Create new zip file 'my.zip'
		Zip::File.open('my'+zipCount.to_s+'.zip', Zip::File::CREATE) do |zipfile|

			# Add files with target extensions to the zip file
			while fileIndex < @@files.length do 

				# Zip file not to exceed @@zipSizeMax global variable
				if zipSizeCurrent + File.size(@@files[fileIndex]) < @@zipSizeMax
					# Keep track of file sizes entering the zip
					zipSizeCurrent += File.size(@@files[fileIndex])

					# Images contained within a directory in the zip file
					# Change the file names to format "path_to_file.extension"
					path = @@files[fileIndex].gsub("/","_")

					# Apply string mapping rules specified in "mapping.txt"
					path = ext.mapName(path)

					# Remove unnecessary character from file name
					if path[0] == "_"
						path.slice!(0)
					end

					# Add file to the zip file
					begin
						zipfile.add(path,@@files[fileIndex])
						# Increment fileIndex and filesInZip
						fileIndex += 1
						filesInZip += 1

					# Handle EntryExistsError if script is re-run without removing zip file(s)
					rescue
					end
				else 
					break
				end
			end
			# Create manifest with known indexes of files for this specific zip file
			ext.createManifest(fileIndex - filesInZip, fileIndex - 1)

			# Add manifest file to the zip file
			begin
				zipfile.add("manifest.JSON", Dir.pwd+"/manifest.JSON")
			# Handle EntryExistsError if script is re-run 
			rescue 
			end

			zipfile.close()
		end
		# Increment number of zip files
		zipCount += 1

	end

	# Delete the manifest file from the parent directory
	File.delete(Dir.pwd+"/manifest.JSON")

	# Create a file in the parent directory to list rejected files
	File.open(Dir.pwd+"/rejects.txt", 'w') do |file|
		file.write("Reject files\n")
		file.write("Script runtime: " + time.inspect + "\n\n")
		@@rejects.each do |r|
			file.write(r+"\n")
		end
	end
end

