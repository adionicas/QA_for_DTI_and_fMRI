#!/bin/bash

# Arg1 is func image
# Arg2 is func mask
# Arg3 is anat
# Arg4 is anat mask
# Arg5 is output prefix

# Ex call:
#sh epi2anat.sh sub-ACAP1016_task-rest_space-MNIPediatricAsym_cohort-5_res-2_desc-preproc_bold.nii.gz sub-ACAP1016_task-rest_space-MNIPediatricAsym_cohort-5_res-2_desc-brain_mask.nii.gz sub-ACAP1016_space-MNIPediatricAsym_cohort-5_desc-preproc_T1w.nii.gz sub-ACAP1016_space-MNIPediatricAsym_cohort-5_desc-brain_mask.nii.gz ACAP1016_epi2anat


# Generate mean func vol

3dcalc -a "$1" -b "$2" -expr 'a*b' -prefix maskED_func.nii.gz

3dcalc -a "$3" -b "$4" -expr 'a*b' -prefix maskED_anat.nii.gz


# resample func mask mean vol -> anat dims

3dresample -master maskED_anat.nii.gz \
-prefix maskED_func_resampled2anat.nii.gz \
-input maskED_func.nii.gz

# Generate edges for func

3dedge3 -prefix edges_bold_maskED.nii.gz \
-input maskED_func_resampled2anat.nii.gz

# Put edges and func together

@chauffeur_afni \
-ulay maskED_func_resampled2anat.nii.gz \
-olay edges_bold_maskED.nii.gz \
-prefix func_with_edges \
-func_range_perc 40 \
-cbar "red_monochrome" \
-montx 9 -monty 1 \
-opacity 9 \
-set_xhairs OFF \
-label_mode 1 -label_size 3 \
-do_clean


# Put T1 and func edges together

@chauffeur_afni \
-ulay maskED_anat.nii.gz \
-olay edges_bold_maskED.nii.gz \
-prefix anat_and_func_edges_transparent \
-func_range_perc 40 \
-opacity 9 \
-cbar "red_monochrome" \
-montx 9 -monty 1 \
-set_xhairs OFF \
-label_mode 1 -label_size 3 \
-do_clean

# rm shit


tmp_niftis="edges_bold_maskED.nii.gz
maskED_anat.nii.gz
maskED_func.nii.gz
maskED_func_resampled2anat.nii.gz
mean_func_vol.nii.gz"

rm $tmp_niftis

# crop useless part of imgs

imgs=`ls *.cor.png`
for img in $imgs; do
convert $img -gravity east -chop 11.2%x0 $img; done

imgs=`ls *.axi.png`
for img in $imgs; do
convert $img -gravity east -chop 11.2%x0 $img; done


imgs=`ls *.sag.png`
for img in $imgs; do
convert $img -gravity west -chop 11%x0 $img
convert $img -gravity east -chop 13%x0 $img; done

# Concatenate the axial, saggital and coronal sections for each sub and ses


scans=`ls func_with_edges.axi.png | cut -d "." -f 1`
for scan in $scans; do
convert "$scan".*.png \
-gravity center \
-background black \
-append \
-brightness-contrast -10x10 \
"$scan"_all_panes.png; done


scans=`ls anat_and_func_edges_transparent.axi.png | cut -d "." -f 1`
for scan in $scans; do
convert "$scan".*.png \
-gravity center \
-background black \
-append \
"$scan"_all_panes.png; done




# Generate the actual gifs

convert -delay 100 -loop 0 \
anat_and_func_edges_transparent_all_panes.png \
func_with_edges_all_panes.png \
"$5"_QA_epi2anat.gif


pngimgs="anat_and_func_edges_transparent_all_panes.png
anat_and_func_edges_transparent.axi.png
anat_and_func_edges_transparent.cor.png
anat_and_func_edges_transparent.sag.png
func_with_edges_all_panes.png
func_with_edges.axi.png
func_with_edges.cor.png
func_with_edges.sag.png"

rm $pngimgs

#rm maskED_func.nii.gz


#anat_imgs/"$sub"_space-MNIPediatricAsym_cohort-5_desc-preproc_T1w_all_panes.png \
#func_imgs/"$sub"_transparent_all_panes.png \
#func_imgs/"$sub"_ses-B0_op9_all_panes.png \
#func_imgs/"$sub"_QA_epi2anat.gif; done





