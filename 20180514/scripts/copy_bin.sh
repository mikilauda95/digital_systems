old=/tmp/simili/20180423/top.runs/impl_1
new=$tmp/vv/top.runs/impl_1
mkdir -p $new
cd $old
cp top_wrapper.bit top_wrapper.sysdef $new
cd -
