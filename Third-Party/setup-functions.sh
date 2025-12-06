#!/usr/bin/env bash
#
#  Copyright (C) 2025  Giuseppe Rocco
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.

if [[ -z "${SCRIPTPATH}" ]]; then
    exit 1
fi

merge_lipo_universal() {

    local product_name="$1"
    local product_path="${SCRIPTPATH}/$1"
    
    # Create universal product folder
    mkdir -p "${product_path}/lib" "${product_path}/include"
    
    find "${product_path}-arm64" -type f | while read -r src_file; do
    
        # Compute relative path from arm64 root
        local rel_path="${src_file#${product_path}-arm64/}"
    
        # Define counterpart and destination paths
        local x86_file="${product_path}-x86_64/${rel_path}"
        local dst_file="${product_path}/${rel_path}"
    
        # Make sure destination directory exists
        mkdir -p "$(dirname "$dst_file")"
    
        # Merge with lipo or copy depending on type
        if [[ "$src_file" == *.a || "$src_file" == *.dylib ]] ||
           ([ -x "$src_file" ] && file "$src_file" | grep -q 'Mach-O'); then
        
            echo "Merging: $rel_path"
            lipo -create "$src_file" "$x86_file" -output "$dst_file"
            
        else
            echo "Copying: $rel_path"
            cp "$src_file" "$dst_file"
        fi
    done
    
    # Fixing the PKGCONFIG prefix path for universal build
    for pcfile in "${product_path}/lib/pkgconfig"/*.pc; do
        sed -i '' -e "s|^prefix=.*|prefix=${product_path}|" "$pcfile"
    done
    
    rm -fr "${product_path}-arm64" "${product_path}-x86_64"
}

build_cmake_universal() {

    local product_name="$1" && shift 1
    local product_cmake_args=("$@")

    cd "${product_name}-src"

    for arch in "arm64" "x86_64"; do
    
        local build_dir="build-${arch}"
        local prefix_path="${SCRIPTPATH}/${product_name}-${arch}"
    
        mkdir "${build_dir}"
        cd "${build_dir}"

        cmake .. \
            -DCMAKE_INSTALL_PREFIX="${prefix_path}" \
            -DCMAKE_OSX_ARCHITECTURES="${arch}" \
            ${product_cmake_args[@]}

        make -j$(sysctl -n hw.logicalcpu)
        mkdir "${prefix_path}"
        make install
        cd ..

    done; cd ..
}
