# auto_install_pyenv.sh
echo "# Automatic Deploy Python Virtual Environment."
echo "## Date:: "`date`
echo "@ Python: python.org"
echo "@ adamhuan: d-prototype.org"

# Config YUM repo
curl http://mirrors.163.com/.help/CentOS6-Base-163.repo -o /etc/yum.repos.d/CentOS6-Base-163.repo

# Install git
echo "## Install: git"

rpm -qa | grep --color ^git;
isExsist_git=`echo $?`

if [ $isExsist_git -eq 0 ]
then
   echo "@ git has been installed."
else
   echo "@ git is not installed."
   echo "@ installing:: git"
   echo "-----------"
      yum install -y git
   echo "-----------"
   echo "@ installing:: git, done."
fi

# Un-Install git
# rpm -e --nodeps git

# Get: PyEnv
echo "## Get: PyEnv"
git clone https://github.com/yyuu/pyenv.git ~/.pyenv
isDone_cmd=`echo $?`

if [ $isDone_cmd -eq 0 ]
then
   echo "@ Command has been execute, successed."
else
   echo "@ Command failed."
fi

# Environment Variable
echo "## Prepare User ENV Variable."
string_USER_HOME=`env | grep --color HOME | cut -d'=' -f2`
echo "@ Current User HOME:: $string_USER_HOME"
echo "@ Configuring User Env Variable."

cat <<PyENV >> $string_USER_HOME/.bash_profile

# -------------
# for PYENV
export PYENV_ROOT="$string_USER_HOME/.pyenv"
export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init -)"

PyENV

# enable ENV Variable
source $string_USER_HOME/.bash_profile

echo "@ Configuring User Env Variable, done."

# Yum Install Relate RPM
echo "# Install RPM"
echo "@ -----------------"
yum install -y zlib* readline* bzip2* openssl* sqlite* gcc*
echo "@ -----------------"

# PyENV: Install python
echo "# PyENV:: Install Python"
echo "# PyENV Install:: Python 3.5.2"
pyenv install -v 3.5.2

echo "# PyENV Install:: Python 2.7.12"
pyenv install -v 2.7.12

# virtualenv
echo "# PyENV VirtualENV"
git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv

echo "# VirtualENV User Environment Variable"
cat <<PyENV >> $string_USER_HOME/.bash_profile

# -------------
# for PYENV VIRTUALENV
eval "\$(pyenv virtualenv-init -)"

PyENV

echo "# PyENV VirtualEnv:: Create for python 3.5.2"
pyenv virtualenv 3.5.2 env_python_352

echo "# PyENV VirtualEnv:: Create for python 2.7.12"
pyenv virtualenv 2.7.12 env_python_2712

echo "=================="
echo "Python Virtual Envrionment, Deploy, Done."
echo "## Date:: "`date`
