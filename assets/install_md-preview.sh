#! /bin/bash

pushd /alfresco/amps
wget https://github.com/cetra3/md-preview/releases/download/1.1.0/parashift-mdpreview-repo-1.1.0.amp
wget https://github.com/cetra3/md-preview/releases/download/1.1.0/parashift-mdpreview-share-1.1.0.amp
/alfresco/bin/apply_amps
popd