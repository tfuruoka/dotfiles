#! /bin/sh

function link_dotfile () {
    conffile=$1
    if [ -f ~/${conffile} -o -L ~/${conffile} ]; then 
        echo -n "Is it ok to overwrite existing ${conffile} [Y/N]? > "
        read INPUT
        if [ ${INPUT} = "Y" -o ${INPUT} = "y" ]; then
            ln -sf $PWD/${conffile} ~/${conffile}
        elif [ ${INPUT} = "N" -o ${INPUT} = "n" ]; then
            echo "Canceled: deploy ${conffile}"
        else
            echo "Enter Y or N"
        fi
    else 
        ln -s $PWD/${conffile} ~/${conffile}
    fi
}

# Deploy .tmux.conf
link_dotfile ".tmux.conf"

# Deploy .zshrc
link_dotfile ".zshrc"
