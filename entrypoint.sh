#!/bin/bash

if [ "$1" == "start" ]; then

    shift 

    if [ ! -f "/data/config.json" ]; then
        echo "You must map the folder with your config.json to /data"
        exit 1
    fi

    if [ ! -f "/data/survey.tsv" ]; then
        echo "You must map the folder with your survey.tsv to /data"
        exit 1
    fi

    # Output folder should contain survey.tsv and config.json
    python3 /code/survey.py -o /data --folder /data "$@"

    ret=$?

    if [ ${ret} -eq 0 ]; then


        echo "index.html"
        folders=( "js" "css")

        # Move static files
        for i in "${folders[@]}"
        do
            echo $i
            if [ ! -e "/data/${i}" ]; then
                cp -R "/code/${i}" /data
            fi
        done

        if [ -e "/data/LICENSE" ]; then
            echo "Found LICENSE in output destination, will not overwrite"
        else
            cp /code/LICENSE /data
            echo "LICENSE"
        fi

        # Move GitHub workflow if does not exist
        mkdir -p /data/.github/workflows
        if [ -e "/data/.github/workflows/build-deploy.yaml" ]; then
            echo "Found .github/workflows/build-deploy.yaml in output destination, will not overwrite"
        else
            cp /code/.github/workflows/build-deploy.yaml
        fi        
        if [ -e "/data/README.md" ]; then
            echo "Found README.md in output destination, will not overwrite"
        else
            if [ -e "/code/README.md" ]; then
                cp /code/README.md /data
                echo "README.md"
            fi
        fi

        chmod -R 0755 /data/*
    fi 

else
    echo "Usage

          docker run -v my-survey:/data expfactory/survey-generator start [options]"
          python3 /code/survey.py --help
fi
