#!/bin/bash
#
#  pin_check_run.sh -- ccmparison 0 degree image after sample testing
#                       Samuel Clark, 20 November 2020
#
#  Version 1.0 - 20 Nov 2020
full_path="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"

if [ -d /GPFS/CENTRAL/XF17ID2/sclark1/pin_check-master ]; then
    export PIN_ALIGN_ROOT=/GPFS/CENTRAL/XF17ID2/sclark1/pin_check-master
fi

PIN_ALIGN_DEFAULT_ROI_WIDTH=$((161))
PIN_ALIGN_DEFAULT_ROI_HEIGHT=$((400))
PIN_ALIGN_DEFAULT_ROI_HEIGHT_OFFSET=$((295))

PIN_CROP_DEFAULT_IMAGE_HEIGHT=$((80))
PIN_BOTTOM_WIDTH_OFFSET=$((10))
PIN_BOTTOM_HIEGHT_OFFSET=$((270))

PIN_ALIGN_SECONDARY_PIN_TIP_WINDOW="${PIN_ALIGN_DEFAULT_ROI_WIDTH}x${PIN_ALIGN_DEFAULT_ROI_HEIGHT}+505+${PIN_ALIGN_DEFAULT_ROI_HEIGHT_OFFSET}"

TOP_PIN_CROP_WINDOW="0x${PIN_CROP_DEFAULT_IMAGE_HEIGHT}+0+0"
BOTTOM_PIN_CROP_WINDOW="0x${PIN_CROP_DEFAULT_IMAGE_HEIGHT}+${PIN_BOTTOM_WIDTH_OFFSET}+${PIN_BOTTOM_HIEGHT_OFFSET}"

image_in=$PIN_ALIGN_ROOT$(python pin_check.py 2>&1)".jpg"
echo $image_in
image="test"
tmp_dir=$PWD/${USER}_pin_align_$$
mkdir $tmp_dir

convert $image_in -contrast  -contrast ${tmp_dir}/${image}".jpg"

# Creates a new ROI to test if the pin is present and allows to account for short pins
convert ${tmp_dir}/${image}".jpg" -crop $PIN_ALIGN_SECONDARY_PIN_TIP_WINDOW -canny 2x1 -negate -colorspace Gray -morphology Erode Octagon:1 -morphology Dilate Octagon:1 ${tmp_dir}/${image}_pin.pgm

convert ${tmp_dir}/${image}_pin.pgm -crop ${TOP_PIN_CROP_WINDOW} ${tmp_dir}/${image}_pin_top_crop.pgm
convert ${tmp_dir}/${image}_pin.pgm  -crop ${BOTTOM_PIN_CROP_WINDOW} ${tmp_dir}/${image}_pin_bottom_crop.pgm

pin_top_compare=$(identify -format %k ${tmp_dir}/${image}_pin_top_crop.pgm)
pin_bottom_compare=$(identify -format %k ${tmp_dir}/${image}_pin_bottom_crop.pgm)

if [ $pin_top_compare == 1 ]; then
    pin_check_one=true
fi

if [ $pin_bottom_compare == 1 ]; then
    pin_check_two=true
fi

if [[ "$pin_check_one" = true && "$pin_check_two" = true ]]; then
    echo "PIN PRESENT"
else
    echo "PIN MISSING"
fi

