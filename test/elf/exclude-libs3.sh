#!/bin/bash
export LANG=
set -e
CC="${CC:-cc}"
CXX="${CXX:-c++}"
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t=out/test/elf/$testname
mkdir -p $t

cat <<EOF | $CC -xc -c -o $t/a.o -
void foo();
void bar() { foo(); }
EOF

rm -f $t/b.a
ar crs $t/b.a $t/a.o

cat <<EOF | $CC -xc -c -o $t/c.o -
void bar();
void foo() { bar(); }
EOF

$CC -B. -shared -o $t/d.so $t/c.o $t/b.a -Wl,-exclude-libs=ALL
readelf --dyn-syms $t/d.so > $t/log
fgrep -q foo $t/log

echo OK
