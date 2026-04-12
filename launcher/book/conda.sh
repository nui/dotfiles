# 1. Create new conda environment and install "ipython" package
env_name=new_conda_env
conda create -c conda-forge -n $env_name ipython

# (optionally) activate into new environment
conda activate $env_name



# 2. Register existing conda environment as jupyterlab kernel
# Following script assumming that jupyterlab is installed in conda environment named "jupyter"

env_name=replace_with_EXISTING_conda_environment_name

# install required packages
conda install -n $env_name --yes ipykernel
# register conda env to jupyter
conda run -n $env_name python -m ipykernel install \
  --prefix ~/.conda/envs/jupyter \
  --name $env_name \
  --display-name $env_name

# REMOVE kernel from jupyter
jupyter_env_name=jupyter
conda run -n $jupyter_env_name jupyter kernelspec remove -y $env_name

