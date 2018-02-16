#!/bin/bash

test -f sci_bear_data.R || \
	wget https://raw.githubusercontent.com/bioatlas/data-mobilization-pipeline/master/sweref99-to-wgs84/sci_bear_data.R

# NB: escaping the "$run" with backslash below!
docker run -d -p 8000:8000 --name mywebservice \
	-v $(pwd)/sci_bear_data.R:/tmp/sci_bear_data.R \
	bioatlas/mirroreum R -e "pr <- plumber::plumb('/tmp/sci_bear_data.R'); pr\$run(host='0.0.0.0', port=8000, swagger=TRUE)"

echo "Please wait for service startup ...." && sleep 5

# request data and docs for web service
firefox http://localhost:8000/scibears?n=10 &
firefox http://localhost:8000/__swagger__/ &
curl -s http://localhost:8000/scibears?n=2 | json_pp
