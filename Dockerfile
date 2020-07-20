FROM quay.io/mbach/ironbank-ubi7:7.8
#FROM redhat/ubi/ubi7:7.8
EXPOSE 8080

ENV APP_ROOT=/opt/app-root

RUN rm -rf /etc/yum.repos.d/ironbank.repo && \
  curl https://raw.githubusercontent.com/mbach04/ocp_remediation_demo/master/ubi.repo -o /etc/yum.repos.d/ubi.repo && \
  curl https://raw.githubusercontent.com/mbach04/ocp_remediation_demo/master/redhat.repo -o /etc/yum.repos.d/redhat.repo && \
  sed -i "/localpkg/s/^/#/" /etc/yum.conf && \
  sed -i "/repo_gpgcheck/s/^/#/" /etc/yum.conf 
RUN INSTALL_PKGS="gcc-c++ \
  make \
  git" && \
  yum install -y $INSTALL_PKGS && \
  curl -sL https://rpm.nodesource.com/setup_12.x | bash - && \
  yum install -y nodejs && \
  yum -y clean all && \
  git clone https://github.com/RedHatGov/openshift-workshops.git ${APP_ROOT} && \
  mv ${APP_ROOT}/dc-metro-map/* ${APP_ROOT} && \
  # Drop the root user and make the content of /opt/app-root owned by user 1001
  chown -R 1001:0 ${APP_ROOT} && chmod -R ug+rwx ${APP_ROOT} && \
  cd ${APP_ROOT} && \
  ls && \
  npm i && \
  npm fund && \
  npm audit fix && \
  npm install debug 
USER 1001

CMD ["npm", "start", "--prefix", "/opt/app-root/"]

