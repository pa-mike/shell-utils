$BASE_SCRIPT = "../setup-nodes/macos/macos.sh"
$BASEDEV_SCRIPT = "../setup-nodes/macos/basedev.sh"
$DEV_SCRIPT = "../setup-nodes/macos/dev.sh"
$DATA_SCRIPT ="../setup-nodes/macos/data.sh"

printf "\\n"
printf "Please select one install: [business|data|development] >>> "
read -r ans


while [ "$ans" != "business" ] && [ "$ans" != "data" ] && [ "$ans" != "development" ] 
do
    printf "Please answer with one of [business|data|development]:'\\n"
    printf ">>> "
    read -r ans
done
if [ $ans = "business" ]
then
    echo BUSINSS_SCRIPT
elif [ $ans = "dev" ]
    echo BASE_SCRIPT
    echo QOL_SCRIPT
    echo BASEDEV
    echo DEV_SCRIPT
elif [ $ans = "data" ]
    echo BASE_SCRIPT
    echo QOL_SCRIPT
    echo BASEDEV
    echo DATA_SCRIPT
fi