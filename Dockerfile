################### Build Painless
FROM satcomp-infrastructure
USER root

#  Install required softwares (Boost needed for Painless)

# Install required packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y vim cmake build-essential zlib1g-dev libopenmpi-dev wget unzip python3 gfortran curl

# g++-10 for better c++20 support
RUN apt-get --install-recommends install -y libboost-all-dev g++-10 protobuf-compiler
RUN ln -sf /usr/bin/g++-10 /usr/bin/g++
#--branch satcomp-25
RUN git config --global http.postBuffer 1048576000
# RUN git clone https://github.com/Zihao-Ding/pl-mab-hypre.git --branch develop-mab-hypre

RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf && \
    git clone https://github.com/Zihao-Ding/pl-mab-hypre.git --branch develop-mab-hypre

# RUN mkdir /pl-mab-hypre
# COPY --chown=ecs-user pl-mab-hypre-develop-mab-hypre /pl-mab-hypre

# Build Painless
RUN chmod 777 -R /pl-mab-hypre
WORKDIR /pl-mab-hypre
# RUN make clean
RUN make -j $(nproc)

#####

WORKDIR /

COPY --chown=ecs-user run_solver.sh /
RUN chmod +x /run_solver.sh

RUN cp /pl-mab-hypre/build/release/painless_release /painless_release
RUN cp /pl-mab-hypre/build/satsuma/satsuma /satsuma
COPY solver_cmd.py /opt/amazon/scripting/harness/entrypoints/

#####

# RUN apt-get update && apt-get --install-recommends install -y libboost-all-dev protobuf-compiler

# COPY --chown=ecs-user leader/init_solver.sh /competition/init_solver.sh
# COPY --chown=ecs-user leader/run_solver.sh /competition/run_solver.sh

# USER ecs-user
# RUN chmod +x /competition/init_solver.sh
# RUN chmod +x /competition/run_solver.sh