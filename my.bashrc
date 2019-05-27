export VAULT_TOKEN=cd4a26de-f4cb-3833-2277-225e4df30684
export VAULT_ADDR=https://secrets.id.hpcwp.com:8200
export BASEDIR=${BASEDIR:=~}
export GITDIR=${BASEDIR}/git
export GITDIR_EXTERNAL=${BASEDIR}/git_external
alias build='mvn clean install'
alias buildskiptests='mvn clean install -DskipTests'
alias buildskipall='mvn clean install -DskipTests -Dfindbugs.skip=true -Dpmd.skip=true -Dmaven.javadoc.skip=true'
alias buildcover='mvn clean install -Djacoco.coverage -Dfull.coverage'
alias aws-login='ecr-login && aws-it-login && ecr-login saml' 
alias bs='buildskip'
alias bf='mvn license:format install'
#alias make='clear && mvn clean install'
alias client='cd $GITDIR/hpid-audit-client'
alias backend='cd $GITDIR/hpid-audit-backend'
alias kibana='cd $GITDIR/hpid-audit-kibana'
alias aws_prov='cd $GITDIR/hpid-aws-provisioning'
alias saml_idp='cd $GITDIR/hpid-saml-idp'
alias saml_idp_test='cd $GITDIR/hpid-saml-idp-test-sp'
alias devenv='cd $GITDIR/gcd-devenv'
alias reset_net='sudo ifdown -a && sudo ifup -a'
alias external='cd $GITDIR_EXTERNAL'
alias ck='cd build/cookbook'
alias qc='CLEANUP=TRUE kitchen converge'
alias vu='vagrant up'
alias vr='vagrant reload'
alias vh='vagrant halt'
alias vssh='vagrant ssh'
alias rmk='rm -rf .kitchen Berksfile.lock'
# git commands
alias master='git checkout master'
alias gs='git status'
alias status='git status'
alias diff='git diff'
alias fo='git fetch origin'
alias fg='git fetch gerrit'
alias fetch='git fetch --all'
alias gp='git pull'
alias pull='git pull'
alias reset='git reset --soft origin/master'
alias rhard="git reset --hard HEAD"
alias grh='rhard'
alias prune='git fetch --all --prune --tags'
alias lbranch='git branch'
alias rbranch='git branch -r'
alias branches='lbranch && rbranch'
alias ll='ls -la'
ci() {
  git commit -m "$1"
}
co() {
  git checkout $1
}
merge() {
  git merge --squash $1
}
commit() {
  git commit -m "$1"
}
branch() {
  git checkout -b $1
}
delbranch() {
  git branch -D $1
}
[ -n "`alias -p | grep '^alias review='`" ] && unalias review
review() {
  if [[ -z "$1" ]]; then
    git review
  else
    git review -d $1
  fi
}
[ -n "`alias -p | grep '^alias srskc='`" ] && unalias srskc
oickc() {
  oicck
  APPLICATION_PORT=8080 APPLICATION_SSL_PORT=8443 DATABASE_PORT=3306 DEBUG_PORT=8000 kc
}
idmkc() {
  idmck
  APPLICATION_PORT=8081 APPLICATION_SSL_PORT=8444 DATABASE_PORT=3307 DEBUG_PORT=8001 RABBITMQ_PORT=5672 RABBITMQ_PORT_SSL=5671 RABBITMQ_MANAGER_PORT=15672 kc
}
srskc() {
  srsck
  APPLICATION_PORT=8082 APPLICATION_SSL_PORT=8445 DATABASE_PORT=3308 DEBUG_PORT=8002 RABBITMQ_PORT=5674 RABBITMQ_PORT_SSL=5673 RABBITMQ_MANAGER_PORT=15674 kc
}
iwskc() {
  iwsck
  APPLICATION_PORT=8083 APPLICATION_SSL_PORT=8446 DATABASE_PORT=3309 DEBUG_PORT=8003 RABBITMQ_PORT=5675 RABBITMQ_PORT_SSL=5674 RABBITMQ_MANAGER_PORT=15675 kc
}

alias listssh='ps aux | grep ssh-agent'
alias killssh="ps x | grep ssh-agent | awk {'print $1'} | xargs kill"
#vm commands
back() {
  kitchen exec -c "sudo date -s '1 minute ago'"
}
ahead() {
  kitchen exec -c "sudo date -s '1 minute'"
}

function push_upstream(){

	remote="origin"

	if [[ -n "$1" ]]; then
		remote="$1"
	fi

	aux=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'`
	branch=${aux:2:-1}

	#echo "git push -u ${remote} ${branch}"
	git push -u ${remote} ${branch}
}

devenv-login() {
  vagrant ssh $(vagrant global-status | awk '{if ($2 == "gcd-devenv") print $1}')
}

##################
# Docker Aliases #
##################
alias docim='docker images'
alias docimg='docker images'
alias docrmi='docker rmi'
alias docrmall='docker rmi -f $(docker images -q)'
alias docrmall='docker rm $(docker ps -aq)'
alias docps='docker ps'
alias docpsa='docker ps -aq'
alias docstop='docker stop $1'
alias docstopall='docker stop $(docpsa)'
alias docwipeout='docstopall && docker rm -v $(docpsa)'
alias docnontagged='docker rmi $(docker images | awk '"'"'{if ($2 == "<none>") print $3}'"'"')'
alias docrunsh='docker run -it --rm --entrypoint=sh $1 $2 $3'
alias docsh='docrunsh'
alias docrunemg='docker run -it --rm --entrypoint=sh -v $(pwd)/emg/etc:/config $1'
alias docprune='docker system prune -f'
docfindrmi() {
  if [ "$#" -eq 2 ]; then
    docrmi $2 $(docfindimg $1)
  elif [ "$#" -eq 1 ]; then
    docrmi $(docfindimg $1)
  else
    echo -e "Usage: docfindrmi [image name]\n   or: docfindrmi [image name] [optional argument, ex: -f]"
  fi
}
docfindimg() {
  if [ "$#" -eq 1 ]; then
  #docimg | eval $(echo "awk '/$1/ {print \$3;}'")  
  docimg | awk '/'$1'/ {print $3;}'
  else
    echo "Usage: docfindimg [image]"
  fi
}
docdeltoken() {
  if [ "$#" -eq 1 ]; then
    mkdir /tmp/vault
    cp $(pwd)/local-settings/vault/* /tmp/vault
    docker run -it --rm --entrypoint=sh -v $(pwd)/local-settings/vault:/var/run/secrets/vaultproject.io $1 -c "rm /var/run/secrets/vaultproject.io/*"
    mv /tmp/vault/* $(pwd)/local-settings/vault
    rm -rf /tmp/vault
    echo "vault_token reloaded"
  else
    echo "Usage: docdeltoken [app image]"
  fi
}
docdelcerebro() {
  if [ "$#" -eq 1 ]; then
    mkdir /tmp/cerebro
    cp $(pwd)/local-settings/cerebro/* /tmp/cerebro
    docker run -it --rm --entrypoint=sh -v $(pwd)/local-settings/cerebro:/conf $1 -c "rm /conf/cerebro*"
    mv /tmp/cerebro/* $(pwd)/local-settings/cerebro
    rm -rf /tmp/cerebro
    echo "cerebro reloaded"
  else
    echo "Usage: docdelcerebro [app image]"
  fi
}
docdelemg() {
  if [ "$#" -eq 1 ]; then
    mkdir /tmp/emg
    cp $(pwd)/emg/etc/500* /tmp/emg
    docker run -it --rm --entrypoint=sh -v $(pwd)/emg/etc:/config $1 -c "rm /config/500*"
    mv /tmp/emg/* $(pwd)/emg/etc/
    rm -rf /tmp/emg
    echo "/config/500* reloaded"
  else
    echo "Usage: docdelemg [EMG image]"
  fi
}
docrunit() {
  docker run -it --rm $@
}
docrun() {
  docker run -d --rm $@
}
doclogin() {
  docker exec -it $@
}
docreload-emg() {
  docdelemg $(docfindimg hpid-audit-emg-docker)
}
docreload-emg2() {
  docdelemg $(docfindimg apigee-edgemicro-docker)
}
docreload-apitoken() {
  docdeltoken $(docfindimg audit-backend-admin-api)
}
docreload-samltoken() {
  docdeltoken $(docfindimg hpid-saml-idp)
}
docreload-token-kibana() {
  docdeltoken $(docfindimg es-proxy)
}
docreload-cerebro-kibana() {
  docdelcerebro $(docfindimg es-proxy)
}
docprom() {
  if [ "$#" -eq 0 ]; then
    docker run --rm --interactive --tty --volume ${PWD}:/etc/prometheus/rules --workdir /etc/prometheus/rules --entrypoint '/bin/promtool' $(docfindimg gcd-prometheus) 'check-rules' *.rules
  elif [ "$#" -eq 1 ]; then
    docker run --rm --interactive --tty --volume ${PWD}:/etc/prometheus/rules --workdir /etc/prometheus/rules --entrypoint '/bin/promtool' $(docfindimg gcd-prometheus) 'check-rules' $1
  else
    echo -e "Usage: docprom [optional file(s) to analyze]"
  fi
}

alias refbash='source ${BASEDIR}/.bashrc'
