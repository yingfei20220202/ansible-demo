#!/bin/bash
# 判断要打那些包
# 把整个目录存放在/home/devops下
# TODO 变量大全
# ansible工作目录
BUILD_PACKAGE="/home/zhao"
BUILD_TIME=$(date +%Y%m%d%H%M)


function MKDIR_BUILD_PWD() {
    if [ ! -e ${BUILD_PACKAGE}/server ]; then
      mkdir -p ${BUILD_PACKAGE}/server/{buildWorkSpace/war_sum,conf,logs}
      cp -r ${BUILD_PACKAGE}/templates/* ${BUILD_PACKAGE}/server/conf/
    fi
}

function BUILD_VERSION() {
    echo "开始创建相关日期目录"
    mkdir -p ${BUILD_PACKAGE}/server/buildWorkSpace/${BUILD_TIME}
    rm -rf ${BUILD_PACKAGE}/ansible/ansible_yml/conf
    ln -s ${BUILD_PACKAGE}/server/conf/ ${BUILD_PACKAGE}/ansible/ansible_yml/conf
}

# TODO 打包失败
function CHECK_BUILD_OK() {
    if [ $? -ne 0 ]; then
      echo "打包失败，请检查！！！"
      echo "正在回滚"
      rm -rf ${BUILD_PACKAGE}/ansible/ansible_yml/conf
      rm -rf ${BUILD_PACKAGE}/server/buildWorkSpace/${BUILD_TIME}/
      exit 1
    fi
}

# TODO 执行playbook_MSBM
function BUILD_MSBM_WAR() {
#    # 先替换版本
#    sed -i '/MSBM_branch: / d' ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml
#    echo "  MSBM_branch: ${1}" >> ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml
#    ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/MSBM.yml
    MSBM_branch=$(grep "MSBM_branch" ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml | awk '{print $2}')
    MSBM_serviceCode=$(grep "MSBM_serviceCode" ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml | awk '{print $2}')
    cp /opt/gitlab/temporary/MSBM/MSBM-Web/target/*.war ${BUILD_PACKAGE}/server/buildWorkSpace/${BUILD_TIME}/${MSBM_serviceCode}-${MSBM_branch}.war
    cp -r ${BUILD_PACKAGE}/server/buildWorkSpace/${BUILD_TIME}/${MSBM_serviceCode}-${MSBM_branch}.war ${BUILD_PACKAGE}/server/buildWorkSpace/war_sum/${MSBM_serviceCode}.war
}
#
# TODO 执行playbook_SMBM
  function BUILD_SMBM_WAR() {
#    # 先替换版本
#    sed -i '/SMBM_branch: / d' ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml
#    echo "  SMBM_branch: ${1}" >> ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml
#    ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
    SMBM_branch=$(grep "SMBM_branch" ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml | awk '{print $2}')
    SMBM_serviceCode=$(grep "SMBM_serviceCode" ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml | awk '{print $2}')
    cp /opt/gitlab/temporary/SMBM/smbm-web/target/*.war ${BUILD_PACKAGE}/server/buildWorkSpace/${BUILD_TIME}/${SMBM_serviceCode}-${SMBM_branch}.war
    cp -r ${BUILD_PACKAGE}/server/buildWorkSpace/${BUILD_TIME}/${SMBM_serviceCode}-${SMBM_branch}.war ${BUILD_PACKAGE}/server/buildWorkSpace/war_sum/${SMBM_serviceCode}.war
}
#
# TODO 执行playbook_WSMS
function BUILD_WSMS_WAR() {
#    # 先替换版本
#    sed -i '/WSMS_branch: / d' ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml
#    echo "  WSMS_branch: ${1}" >> ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml
#    ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/WSMS.yml
    WSMS_branch=$(grep "WSMS_branch" ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml | awk '{print $2}')
    WSMS_serviceCode=$(grep "WSMS_serviceCode" ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml | awk '{print $2}')
    cp /opt/gitlab/temporary/WSMS/WSMS-Web/target/*.war ${BUILD_PACKAGE}/server/buildWorkSpace/${BUILD_TIME}/${WSMS_serviceCode}-${WSMS_branch}.war
    cp -r ${BUILD_PACKAGE}/server/buildWorkSpace/${BUILD_TIME}/${WSMS_serviceCode}-${WSMS_branch}.war ${BUILD_PACKAGE}/server/buildWorkSpace/war_sum/${WSMS_serviceCode}.war
}

function interaction() {
  while true
  do
    # TODO 是否全量打包
    echo "是否全量打包: Y全量, N非全量, Q退出"
    read -p "[Y / N]: " YesAndNoAllPack
    # TODO Y全量
    if [ "${YesAndNoAllPack}" = "y" ] || [ "${YesAndNoAllPack}" = "Y" ]; then
      echo "正在进入..."
      sleep 1
      while true
      do
        # TODO 全量-是否是统一版本号
        echo "是否是统一版本号: Y是, N否, Q上一级"
        read -p "[Y / N]: " YesAndNoVersion
        if [ "${YesAndNoVersion}" = "y" ] || [ "${YesAndNoVersion}" = "Y" ]; then
          while true
          do
            read -p "请输入版本号: " FullDoseVersion
            echo "统一版本号为: ${FullDoseVersion}"
            while true
            do
              echo "是否确认: Y确认, X修改"
              read -p "[Y / X]: " FullDoseVersionYX
              if [ "${FullDoseVersionYX}" = "y" ] || [ "${FullDoseVersionYX}" = "Y" ]; then
                echo "开始打包"
                sed -i '/MSBM_branch: / d' ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml
                sed -i '/SMBM_branch: / d' ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml
                sed -i '/WSMS_branch: / d' ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml
                echo "  MSBM_branch: ${FullDoseVersion}" >> ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml
                echo "  SMBM_branch: ${FullDoseVersion}" >> ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml
                echo "  WSMS_branch: ${FullDoseVersion}" >> ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml
                ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
                CHECK_BUILD_OK
                ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
                CHECK_BUILD_OK
                ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
                CHECK_BUILD_OK
                BUILD_MSBM_WAR
                BUILD_SMBM_WAR
                BUILD_WSMS_WAR
                exit 1

              elif [ "${FullDoseVersionYX}" = "x" ] || [ "${FullDoseVersionYX}" = "X" ]; then
                read -p "请重新输入统一版本号: " FullDoseVersionCongfu
                echo "统一版本号为: ${FullDoseVersionCongfu}"
                echo "开始打包"
                sed -i '/MSBM_branch: / d' ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml
                sed -i '/SMBM_branch: / d' ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml
                sed -i '/WSMS_branch: / d' ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml
                echo "  MSBM_branch: ${FullDoseVersionCongfu}" >> ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml
                echo "  SMBM_branch: ${FullDoseVersionCongfu}" >> ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml
                echo "  WSMS_branch: ${FullDoseVersionCongfu}" >> ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml
                ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
                CHECK_BUILD_OK
                ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
                CHECK_BUILD_OK
                ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
                CHECK_BUILD_OK
                BUILD_MSBM_WAR
                BUILD_SMBM_WAR
                BUILD_WSMS_WAR
                exit 1

              else
                echo " "
                echo "+++++++++++++++++++++++"
                echo "输入错误！请从新输入..."
                echo "+++++++++++++++++++++++"
                echo " "
              fi
            done
          done
        elif [ "${YesAndNoVersion}" = "n" ] || [ "${YesAndNoVersion}" = "N" ]; then
          # TODO 这里的版本号直接写入到相对应的配置文件中去，如果有修改的，直接用sed替换
          read -p "请输入MSBM需要打包的版本号: " MSBM_NoFullDoseVersion
          echo "MSBM版本: ${MSBM_NoFullDoseVersion}"
          read -p "请输入SMBM需要打包的版本号: " SMBM_NoFullDoseVersion
          echo "SMBM版本: ${SMBM_NoFullDoseVersion}"
          read -p "请输入WSMS需要打包的版本号: " WSMS_NoFullDoseVersion
          echo "WSMS版本: ${WSMS_NoFullDoseVersion}"
          echo "+++++++++++++++++++++++++++++++++++++"

          while true
          do
            # TODO 获取到配置文件中的版本号
            echo "请确认版本号: "
            echo "MSBM版本: ${MSBM_NoFullDoseVersion}"
            echo "SMBM版本: ${SMBM_NoFullDoseVersion}"
            echo "WSMS版本: ${WSMS_NoFullDoseVersion}"
            echo "版本是否正确: Y正确, X修改"
            read -p "[Y / X]: " VersionYesAmend
            if [ "${VersionYesAmend}" = "y" ] || [ "${YesAndNoVersion}" = "Y" ]; then
              # TODO 开始打包，不在返回上一级
              echo "开始打包"
              sed -i '/MSBM_branch: / d' ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml
              sed -i '/SMBM_branch: / d' ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml
              sed -i '/WSMS_branch: / d' ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml
              echo "  MSBM_branch: ${MSBM_NoFullDoseVersion}" >> ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml
              echo "  SMBM_branch: ${SMBM_NoFullDoseVersion}" >> ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml
              echo "  WSMS_branch: ${WSMS_NoFullDoseVersion}" >> ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml
              ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
              CHECK_BUILD_OK
              ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
              CHECK_BUILD_OK
              ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
              CHECK_BUILD_OK
              BUILD_MSBM_WAR
              BUILD_SMBM_WAR
              BUILD_WSMS_WAR
              exit 1

            elif [ "${VersionYesAmend}" = "x" ] || [ "${YesAndNoVersion}" = "X" ]; then
              while true
              do
                read -p "请输入要修改的模块名: " VersionAmendName
                read -p "请输入要修改的版本号: " VersionAmendVersion
                echo "最新${VersionAmendName}版本为: ${VersionAmendVersion}"
                sed -i '/'${VersionAmendName}'_branch: / d' ${BUILD_PACKAGE}/server/conf/${VersionAmendName}_conf.yml
                echo "  ${VersionAmendName}_branch: ${VersionAmendVersion}" >> ${BUILD_PACKAGE}/server/conf/${VersionAmendName}_conf.yml
                while true
                do
                  echo "是否继续修改: Y继续, N退出并打包"
                  read -p "[Y / N]: " VersionAmendNameYN
                  if [ "${VersionAmendNameYN}" = "y" ] || [ "${VersionAmendNameYN}" = "Y" ]; then
                    break
                  elif [ "${VersionAmendNameYN}" = "n" ] || [ "${VersionAmendNameYN}" = "N" ]; then
                    # TODO 开始打包
                    echo "开始打包"
                    ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/MSBM.yml
                    CHECK_BUILD_OK
                    ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
                    CHECK_BUILD_OK
                    ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/WSMS.yml
                    CHECK_BUILD_OK
                    BUILD_MSBM_WAR
                    BUILD_SMBM_WAR
                    BUILD_WSMS_WAR
                    exit 1
                  else
                    echo " "
                    echo "+++++++++++++++++++++++"
                    echo "输入错误！请从新输入..."
                    echo "+++++++++++++++++++++++"
                    echo " "
                  fi
                done
              done
            else
              echo " "
              echo "+++++++++++++++++++++++"
              echo "输入错误！请从新输入..."
              echo "+++++++++++++++++++++++"
              echo " "
            fi
          done
        elif [ "${YesAndNoVersion}" = "q" ] || [ "${YesAndNoVersion}" = "Q" ]; then
          echo "返回上一级目录。"
          sleep 1
          # 跳出某次循环
          break
        else
          echo " "
          echo "+++++++++++++++++++++++"
          echo "输入错误！请从新输入..."
          echo "+++++++++++++++++++++++"
          echo " "
        fi
      done
    # TODO N非全量
    elif [ "${YesAndNoAllPack}" = "n" ] || [ "${YesAndNoAllPack}" = "N" ]; then
      echo "正在进入..."
      while true
      do
        echo "请选择打包的模块"
        echo "        1.MSBM        "
        echo "        2.SMBM        "
        echo "        3.WSMS        "
        echo "        4.退出         "
        read -p "请选择: " YesAndNoAllPackxuanze
        case ${YesAndNoAllPackxuanze} in
        1)
          read -p "请输入MSBM需要打包的版本号: " MSBMVersion
          echo "请确认MSBM版本号为: ${MSBMVersion}"
          while true
          do
            echo "版本是否正确: Y正确, X修改"
            read -p "[Y / X]: " MSBMVersionYx
            if [ "${MSBMVersionYx}" = "y" ] || [ "${MSBMVersionYx}" = "Y" ]; then
              # TODO 开始打包，不在返回上一级
              echo "开始打包"
              sed -i '/MSBM_branch: / d' ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml
              echo "  MSBM_branch: ${MSBMVersion}" >> ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml
              ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/MSBM.yml
              CHECK_BUILD_OK
              BUILD_MSBM_WAR
              break

            elif [ "${MSBMVersionYx}" = "x" ] || [ "${MSBMVersionYx}" = "X" ]; then
                read -p "请输入要修改的版本号: " VersionAmendVersion
                echo "最新MSBM版本为: ${VersionAmendVersion}"
                # TODO 开始打包
                echo "开始打包"
                sed -i '/MSBM_branch: / d' ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml
                echo "  MSBM_branch: ${VersionAmendVersion}" >> ${BUILD_PACKAGE}/server/conf/MSBM_conf.yml
                ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/MSBM.yml
                CHECK_BUILD_OK
                BUILD_MSBM_WAR
                break
            else
              echo " "
              echo "+++++++++++++++++++++++"
              echo "输入错误！请从新输入..."
              echo "+++++++++++++++++++++++"
              echo " "
            fi
          done
        ;;
        2)
          read -p "请输入SMBM需要打包的版本号: " SMBMVersion
          echo "请确认SMBM版本号为: ${SMBMVersion} "
          while true
          do
            echo "版本是否正确: Y正确, X修改"
            read -p "[Y / X]: " SMBMVersionYx
            if [ "${SMBMVersionYx}" = "y" ] || [ "${SMBMVersionYx}" = "Y" ]; then
              # TODO 开始打包，不在返回上一级
              echo "开始打包"
              sed -i '/SMBM_branch: / d' ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml
              echo "  SMBM_branch: ${SMBMVersion}" >> ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml
              ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
              CHECK_BUILD_OK
              BUILD_MSBM_WAR
              break

            elif [ "${SMBMVersionYx}" = "x" ] || [ "${SMBMVersionYx}" = "X" ]; then
                read -p "请输入要修改的版本号: " VersionAmendVersion
                echo "最新SMBM版本为: ${VersionAmendVersion}"
                # TODO 开始打包
                echo "开始打包"
                sed -i '/SMBM_branch: / d' ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml
                echo "  SMBM_branch: ${VersionAmendVersion}" >> ${BUILD_PACKAGE}/server/conf/SMBM_conf.yml
                ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/SMBM.yml
                CHECK_BUILD_OK
                BUILD_SMBM_WAR
                break
            else
              echo " "
              echo "+++++++++++++++++++++++"
              echo "输入错误！请从新输入..."
              echo "+++++++++++++++++++++++"
              echo " "
            fi
          done
        ;;
        3)
          read -p "请输入WSMS需要打包的版本号: " WSMSVersion
          echo "请确认WSMS版本号为: ${WSMSVersion}"
          while true
          do
            echo "版本是否正确: Y正确, X修改"
            read -p "[Y / X]: " WSMSVersionYx
            if [ "${WSMSVersionYx}" = "y" ] || [ "${WSMSVersionYx}" = "Y" ]; then
              # TODO 开始打包，不在返回上一级
              echo "开始打包"
              sed -i '/WSMS_branch: / d' ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml
              echo "  WSMS_branch: ${WSMSVersion}" >> ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml
              ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/WSMS.yml
              CHECK_BUILD_OK
              BUILD_MSBM_WAR
              break

            elif [ "${WSMSVersionYx}" = "x" ] || [ "${WSMSVersionYx}" = "X" ]; then
                read -p "请输入要修改的版本号: " VersionAmendVersion
                echo "最新${VersionAmendName}版本为: ${VersionAmendVersion}"
                # TODO 开始打包
                echo "开始打包"
                sed -i '/WSMS_branch: / d' ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml
                echo "  WSMS_branch: ${VersionAmendVersion}" >> ${BUILD_PACKAGE}/server/conf/WSMS_conf.yml
                ansible-playbook ${BUILD_PACKAGE}/ansible/ansible_yml/WSMS.yml
                CHECK_BUILD_OK
                BUILD_WSMS_WAR
                break
            else
              echo " "
              echo "+++++++++++++++++++++++"
              echo "输入错误！请从新输入..."
              echo "+++++++++++++++++++++++"
              echo " "
            fi
          done
        ;;
        4)
          echo "3秒后退出在退出"
          echo "3"
          sleep 1
          echo "2"
          sleep 1
          echo "1"
          exit 1
        ;;
        *)
          echo " "
          echo "+++++++++++++++++++++++"
          echo "输入错误！请从新输入..."
          echo "+++++++++++++++++++++++"
          echo " "
        ;;
        esac
      done
    # TODO Q退出
    elif [ "${YesAndNoAllPack}" = "q" ] || [ "${YesAndNoAllPack}" = "Q" ]; then
      echo "3秒后退出在退出..."
      echo "3"
      sleep 1
      echo "2"
      sleep 1
      echo "1"
      break
    else
      echo " "
      echo "+++++++++++++++++++++++"
      echo "输入错误！请从新输入..."
      echo "+++++++++++++++++++++++"
      echo " "
    fi
  done
}

# TODO 终极
function main() {
  sed -i 's/\r$//' ${BUILD_PACKAGE}/templates/*.yml
  sed -i 's/\r$//' ${BUILD_PACKAGE}/server/conf/*.yml
  # 先创建相关目录
  MKDIR_BUILD_PWD
  # 创建时间戳结尾的版本
  BUILD_VERSION
  # 交互页面
  interaction

}

main


