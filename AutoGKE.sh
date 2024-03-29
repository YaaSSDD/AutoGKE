#!/bin/sh

read -p " entrée l'ID de votre projet : " IDPROJECT
export PROJECT_ID=$IDPROJECT

GKE ()
{
    
gcloud compute zones list
read -p "set-up your zone : " ZONE

read -p " entrée le nom de votre cluster : " CLUSTERNAME
echo $CLUSTERNAME
read -p " entrée le port use par le load-balancer : " LBPORT
echo $LBPORT
read -p " entrée le nombre de nodes dans votre cluster : " NBNODES
echo $NBNODES
read -p " entrée le nom de notre deployment : " DEPLOYNAME
echo $DEPLOYNAME
read -p " entrée le nombre de minimum (NODES) : " MINNODES
echo $MINNODES
read -p " entrée le nombre de scalling maximum (NODES) : " MAXNODES
echo $MAXNODES
gcloud config set project $PROJECT_ID

gcloud config set compute/zone $ZONE

gcloud container clusters create $CLUSTERNAME \
  --num-nodes=$NBNODES \
  --enable-autoscaling \
  --min-nodes=$MINNODES \
  --max-nodes=$MAXNODES


gcloud compute instances list

}

GCR()
{
read -p "entrée le nombre de projet à  containeuriser : " CONTAINERNB

i=1

###boucle build tag->push->images on GoogleContainerRegistry
  for x in `seq 1 $CONTAINERNB`;
  do
    echo $i
    read -p "nom de votre container $i : " CONTAINER

    i=$(($i + 1))
    echo "$CONTAINER${i}"

    read -p "entrée le nommage de votre image : " IMAGENAME
    echo $IMAGENAME

    read -p "entrée votre tag : " TAG
    echo $TAG

    read -p "entrée le port use par le pod : " PODPORT
    echo $PODPORT

    read -p "entrée le repertoire contenant votre app/Dockerfile : " DIRPROJECT
    echo $DIRPROJECT

    echo "gcr.io/${PROJECT_ID}/$IMAGENAME:$TAG ./$DIRPROJECT "

    docker build -t gcr.io/${PROJECT_ID}/$IMAGENAME:$TAG ./$DIRPROJECT

    gcloud auth configure-docker
    
    docker push gcr.io/${PROJECT_ID}/$IMAGENAME:$TAG
    kubectl create deployment $DEPLOYNAME --image=gcr.io/${PROJECT_ID}/$IMAGENAME:$TAG
    kubectl get pods     

  done
}
   
EXPOSE ()
{
##test pull from GCR 
#docker run --rm -p $PODPORT:$PODPORT gcr.io/${PROJECT_ID}/$IMAGENAME:$TAG

#curl http://localhost:$PODPORT

  read -p "entrée le nom de votre deployment à exposé : " CONTAINERPHARE

#L'indicateur --port spécifie le numéro de port configuré sur l'équilibreur de charge 
#L'indicateur --target-port indique le numéro de port utilisé par le pod 
  kubectl expose deployment $CONTAINERPHARE --type=LoadBalancer --port $LBPORT --target-port $PODPORT
}

GKE
GCR
#EXPOSE
