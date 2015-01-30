#!/bin/sh
base=../
basesrc=${base}src
baseselector=${base}res/drawable
baselayout=${base}res/layout
basepic=${base}res
basevalue=${base}res/values

TEMPDIR=${base}bin/temp

rm -rf ${TEMPDIR};
mkdir -p ${TEMPDIR}


USERLAYOUT=${TEMPDIR}/UseLayout.txt
rm -rf ${USERLAYOUT}
touch ${USERLAYOUT};



echo "读出所有的java里面的layout"
TEMPLAYOUT=${TEMPDIR}/UseLayout_temp.txt
for line in `find  ${basesrc}   -type f  -name "*.java" `;do

    content=`echo  \`cat ${line} | awk -F R.layout.  '{for(i=2;i<=NF;i++)print "###"$i}'\``;
#    echo ${content}
    for line in ${content} ;do
        echo ${line}|awk -F "###" '{print $2}'| awk -F "[;),]" '{print $1}' >> ${TEMPLAYOUT}
    done;

#    echo `echo  \`cat  ${line}\`  | awk -F R.layout.  'NR>2{print $2}' | awk -F "[;),]" '{print $1}'` >> ${TEMPLAYOUT}

done


echo  "找出所有layout里面include 布局"
# <include layout="@layout/actionbar" />
rm -rf  ${USERLAYOUT}


#最多扫描嵌套2层的layout
for((i=1;i<=2;i++));do
    for layout in `cat ${TEMPLAYOUT}` ;do
        content=`echo  \`cat "${baselayout}/${layout}.xml" | awk -F @layout/  '{for(i=2;i<=NF;i++)print "###"$i}'\``;
        #    echo ${content}
        for line in ${content} ;do
            echo ${line}|awk -F "###" '{print $2}'| awk -F "[\"]" '{print $1}' >> ${TEMPLAYOUT}
        done;
#        echo `echo  \`cat  "${baselayout}/${layout}.xml"\`  | awk -F @layout/  '{print $2}' | awk -F "[\"]" '{print $1}'`  >> ${TEMPLAYOUT}
    done
done


for layout in `cat ${TEMPLAYOUT}` ;do
     echo "${layout}.xml" >> ${USERLAYOUT}
done;
rm -rf ${TEMPLAYOUT}
#for layout in `cat ${USERLAYOUT}` ;do
#     echo "${layout}.xml" >> ${TEMPLAYOUT}
#done;

#mv ${TEMPLAYOUT} ${USERLAYOUT}



echo  "移除没有使用的layout"

MOVEDIR=${TEMPDIR}/storesLayout
rm -rf ${MOVEDIR}
mkdir ${MOVEDIR}


for layout in `find  ${baselayout}   -type f  -name "*.xml" `;do

        new_layout_file=`basename ${layout}`
#        echo " scan file "${new_layout_file}
        if grep -q ${new_layout_file} ${USERLAYOUT}
        then
            holde=""
#            echo "used ${layout} "
        else
            mv ${layout} ${MOVEDIR}/
        fi
done;


echo  "移除所有没有使用的layout 到  ${MOVEDIR}"

echo  "……………………………………………………"

echo  "………………………开始检查没有使用的图片资源……………………………"



echo "读出所有的java里面的drawable"
TEMPLAYOUT=${TEMPDIR}/UseDrawable_temp.txt
DRAWBALE_TEXT=${TEMPDIR}/UseDrawable.txt
rm -rf ${TEMPLAYOUT}
touch ${TEMPLAYOUT}
for line in `find  ${basesrc}   -type f  -name "*.java" `;do
    content=`echo  \`cat ${line} | awk -F R.drawable.  '{for(i=2;i<=NF;i++)print "###"$i}'\``;
    for line in ${content} ;do
        echo ${line}|awk -F "###" '{print $2}'| awk -F "[\";),:]" '{print $1}' >> ${TEMPLAYOUT}
    done;
done




echo  "找出所有使用的layout，也就是上面扫描出来的里面include 布局"

for layout in `cat ${USERLAYOUT}` ;do
        content=`echo  \`cat "${baselayout}/${layout}" | awk -F @drawable/  '{for(i=2;i<=NF;i++)print "###"$i}'\``;
        #    echo ${content}
        for line in ${content} ;do
            echo ${line}|awk -F "###" '{print $2}'| awk -F "[\";),:]" '{print $1}' >> ${TEMPLAYOUT}
        done;
done




for drawable in `cat ${TEMPLAYOUT}` ;do
     echo "${drawable}" >> ${DRAWBALE_TEXT}
done;


echo "scan sytle drawable"
for drawableItem in `find  ${basepic}   -type f  -name "*style*.xml" ` ;do
            content=`echo  \`cat "${drawableItem}" | awk -F @drawable/  '{for(i=2;i<=NF;i++)print "###"$i}'\``;
            for line in ${content} ;do
                echo ${line}|awk -F "###" '{print $2}'| awk -F "[\"<]" '{print $1}' >> ${DRAWBALE_TEXT}
            done;
done;

echo  "找出所有 drawable.xml 里面的drawable"
#最多扫描嵌套3层的drawable
for((i=1;i<=3;i++));do
    for drawable in `cat ${DRAWBALE_TEXT}` ;do
      for drawableItem in `find  ${basepic}   -type f  -name "*${drawable}*.xml" ` ;do
            content=`echo  \`cat "${drawableItem}" | awk -F @drawable/  '{for(i=2;i<=NF;i++)print "###"$i}'\``;
            for line in ${content} ;do
                echo ${line}|awk -F "###" '{print $2}'| awk -F "[\"]" '{print $1}' >> ${DRAWBALE_TEXT}
            done;
      done;
    done;
done;




rm -rf ${TEMPLAYOUT}




DRAWABLE_STOPE=${TEMPDIR}/StoreDrawable
rm -rf ${DRAWABLE_STOPE}
mkdir -p ${DRAWABLE_STOPE}



echo  "找出所有没有使用的 drawable，把移到"



#
#        new_layout_file=`basename ${layout}|cut -d. -f1`
##        echo " scan file "${new_layout_file}
#        if grep -q ${new_layout_file} ${USERLAYOUT}
#        then
#            echo ""
##            echo "used ${layout} "
#        else
#            mv ${layout} ${MOVEDIR}/
#        fi
Drawables="drawable  drawable-hdpi  drawable-mdpi drawable-nodpi drawable-xhdpi drawable-xxhdpi"

for drawableDir in ${Drawables} ;do

    storeDir=${DRAWABLE_STOPE}/${drawableDir}
    echo "scan ${storeDir}"
    mkdir ${storeDir}

    drawableDir=`echo ${basepic}/${drawableDir}`
    mv ${drawableDir}/*  ${storeDir}/
    for drawable in `cat ${DRAWBALE_TEXT}` ;do
        for drawableFile in `find  ${storeDir}   -type f -name "${drawable}.*" ` ;do
            mv   ${drawableFile}  ${drawableDir}/
        done;
    done;

done;






echo  "………………………开始检查没有使用的string……………………………"


echo "读出所有的java里面的String"
TEMPSTRING=${TEMPDIR}/UseStringId.txt
touch ${TEMPSTRING}
for line in `find  ${basesrc}   -type f  -name "*.java" `;do

    content=`echo  \`cat ${line} | awk -F R.string.  '{for(i=2;i<=NF;i++)print "###"$i}'\``;
#    echo ${content}
    for line in ${content} ;do
            str=`echo ${line}|awk -F "###" '{print $2}'| awk -F "[\");,]" '{print $1".string"}'`

                if grep -q ${str} ${TEMPSTRING}
                then
                    holde=""
                else
                    echo "${str}"  >> ${TEMPSTRING}
                fi

    done;

#    echo `echo  \`cat  ${line}\`  | awk -F R.layout.  'NR>2{print $2}' | awk -F "[;),]" '{print $1}'` >> ${TEMPLAYOUT}

done


echo  "找出所有layout 里面include 布局"
# <include layout="@layout/actionbar" />


#最多扫描嵌套2层的layout
#for((i=1;i<=2;i++));do
    for layout in `find  ${base}   -type f  -name "*.xml"  ` ;do
        content=`echo  \`cat "${layout}" | awk -F @string/  '{for(i=2;i<=NF;i++)print "###"$i}'\``;
        #    echo ${content}
        for line in ${content} ;do
            str=`echo ${line}|awk -F "###" '{print $2}'| awk -F "[\");,]" '{print $1".string"}'`

                if grep -q ${str} ${TEMPSTRING}
                then
                    holde=""
                else
                    echo "${str}"  >> ${TEMPSTRING}
                fi

        done;
    done
#done




newString=${TEMPDIR}/strings.xml
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >>${newString}

cat "${basevalue}/strings.xml"|while read line;
do
   str=`echo \`echo ${line}|awk -F \" '{print $2".string"}'\` `;
   echo ${str}
    if grep -q ${str} ${TEMPSTRING}
                then

                    echo "${line}">>${newString}
                else
                    holde=""
#                    echo "${line}">>${newString}
                fi
 done

 echo "</resources>" >>${newString}

 mv ${basevalue}/strings.xml  ${TEMPDIR}/stringsOld.xml

 cp ${newString} ${basevalue}/strings.xml







echo  "………………………开始检查没有使用的 id……………………………"


echo "读出所有的java里面的id"
TEMPSTRING=${TEMPDIR}/UseIds.txt
touch ${TEMPSTRING}
for line in `find  ${basesrc}   -type f  -name "*.java" `;do

    content=`echo  \`cat ${line} | awk -F R.id.  '{for(i=2;i<=NF;i++)print "###"$i}'\``;
#    echo ${content}
    for line in ${content} ;do
            str=`echo ${line}|awk -F "###" '{print $2}'| awk -F "[\");,]" '{print $1".id"}'`

                if grep -q ${str} ${TEMPSTRING}
                then
                    holde=""
                else
                    echo "${str}"  >> ${TEMPSTRING}
                fi

    done;


done


echo  "找出所有layout 里面include 布局"


    for layout in `find  ${base}   -type f  -name "*.xml"  ` ;do
        content=`echo  \`cat "${layout}" | awk -F @id/  '{for(i=2;i<=NF;i++)print "###"$i}'\``;
        #    echo ${content}
        for line in ${content} ;do
            str=`echo ${line}|awk -F "###" '{print $2}'| awk -F "[\");,]" '{print $1".id"}'`

                if grep -q ${str} ${TEMPSTRING}
                then
                    holde=""
                else
                    echo "${str}"  >> ${TEMPSTRING}
                fi

        done;
    done




newIDs=${TEMPDIR}/ids.xml
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >>${newIDs}

cat "${basevalue}/ids.xml"|while read line;
do
   str=`echo \`echo ${line}|awk -F \" '{print $2".id"}'\` `;
   echo ${str}
    if grep -q ${str} ${TEMPSTRING}
                then

                    echo "${line}">>${newIDs}
                else
                    holde=""
                fi
 done

 echo "</resources>" >>${newIDs}

 mv ${basevalue}/ids.xml  ${TEMPDIR}/idsOld.xml

 cp ${newIDs} ${basevalue}/ids.xml










