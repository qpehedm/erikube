FROM centos:7.2.1511

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ “/sys/fs/cgroup” ]
RUN yum -y update && yum clean all
RUN printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n' \
    '[kubernetes]' \
    'name=Kubernetes'\
    'baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64'\
    'enabled=1'\
    'gpgcheck=1'\
    'repo_gpgcheck=1'\
    'gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg'\
    '       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg'\
    >> /etc/yum.repos.d/kubernetes.repo
RUN yum install -y kubelet kubeadm kubectl kubernetes-cni
RUN mkdir -p /etc/selinux/targeted/contexts/
RUN echo '<busconfig><selinux></selinux></busconfig>' > /etc/selinux/targeted/contexts/dbus_contexts
RUN chmod 644 /etc/systemd/system/kubelet.service
RUN set sestatus 0
RUN echo "root:peter" | chpasswd
RUN systemctl enable kubelet
