# Usage:
# (Linux) ./.test/run.sh
# (MacOS) ./.test/run.sh "x86_64-macos"

if [ $# -eq 0 ]; then
	PLATFORM="x86_64-linux"
else
	PLATFORM="$1"
fi

echo "${PLATFORM}"

# {"version": "1.2.89", "sha1": "5ca3dd134cc960c35ecefe12f6dc81a48f212d40"}
SHA1=$(curl -s http://d.defold.com/stable/info.json | sed 's/.*sha1": "\(.*\)".*/\1/')
echo "Using Defold dmengine_headless version ${SHA1}"

DMENGINE_URL="http://d.defold.com/archive/${SHA1}/engine/${PLATFORM}/dmengine_headless"
BOB_URL="http://d.defold.com/archive/${SHA1}/bob/bob.jar"

if [[ ! -f dmengine_headless ]]; then
	echo "Downloading ${DMENGINE_URL}"
	curl -L -o dmengine_headless ${DMENGINE_URL}
	chmod +x dmengine_headless
fi	

if [[ ! -f bob.jar ]]; then
	echo "Downloading ${BOB_URL}"
	curl -L -o bob.jar ${BOB_URL}
fi

echo "Running bob.jar"
java -jar bob.jar --variant=headless build

echo "Starting dmengine_headless"
./dmengine_headless
