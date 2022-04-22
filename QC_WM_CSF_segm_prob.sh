#!/bin/bash

 # 1st arg is the seg img with label 1
 # 2nd arg is the seg img with label 2
 # 3rd arg is the anat img (underlay)
 # 4th arg is the desierd threshold for the probabilistic segmentations
 # 5th arg is the output suffix

#{@_@}

# example: 

# bash QC_WM_CSF_segm_prob.sh ants_segm_tissue-label_1_space-MNIPediatricAsym.nii.gz \
# ants_segm_tissue-label_3_space-MNIPediatricAsym.nii.gz \
# sub-ACAP1023_space-MNIPediatricAsym_cohort-5_desc-preproc_T1w.nii.gz 0.75 output

#{@_@}

3dcalc -a "$1" -expr "ispositive(a-$4)" -prefix maskimage_l1.nii.gz
3dcalc -a "$2" -expr "ispositive(a-$4)" -prefix maskimage_l2.nii.gz
3dcalc -a maskimage_l1.nii.gz \
-b maskimage_l2.nii.gz \
-expr '(a+b*2)' \
-prefix all_segm.nii.gz

3dresample -master $3 \
-prefix this_sub_res.nii.gz \
-input all_segm.nii.gz

@chauffeur_afni \
-olay this_sub_res.nii.gz \
-ulay "$3" \
-opacity 9 -prefix afni_pic1 \
-montx 9 -monty 1 -set_xhairs OFF -label_mode 0 -do_clean

@chauffeur_afni \
-ulay "$3" \
-opacity 9 -prefix afni_pic2 \
-montx 9 -monty 1 -set_xhairs OFF -label_mode 1 -label_size 3 -do_clean

for i in {1..2}; do
convert afni_pic"$i".cor.png -gravity east -chop 11.2%x0 afni_pic"$i".cor.png
convert afni_pic"$i".axi.png -gravity east -chop 11.2%x0 afni_pic"$i".axi.png

convert afni_pic"$i".sag.png -gravity west -chop 11%x0 afni_pic"$i".sag.png
convert afni_pic"$i".sag.png -gravity east -chop 13%x0 afni_pic"$i".sag.png
# Concatenate the axial, saggital and coronal sections for each sub and ses
convert afni_pic"$i".*.png \
-gravity center \
-background black \
-append \
all_planes"$i".png
done

# #-alpha Set \


# # Make transparent background for the segmentation image

# convert all_planes1.png \
# -fill transparent \
# -draw 'color 0,0 replace' \
# all_planes1.png


convert all_planes1.png -fuzz 40% \
-fill transparent -opaque black all_planes1.png
convert all_planes1.png -fuzz 10% -transparent black all_planes1.png

# # Make the white green

# convert all_planes1.png -fuzz 40% \
# -fill green -opaque white all_planes1.png

# # # Generate the actual gifs

convert -delay 100 -loop 0 \
all_planes2.png \
all_planes1.png \
"$5"_QC_segment_WM_CSF.gif

# #rm *.png

rm this_sub_res.nii.gz
rm *.png
rm all_segm.nii.gz maskimage_l*.nii.gz
