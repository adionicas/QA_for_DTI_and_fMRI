
# arg1 is anat image
# arg2 is anat mask
# arg3 in standard space image
# arg4 is func image
# arg5 is func mask
# arg6 is segmentation label1
# arg7 is segmentation label2


# prepare the anat images

3dedge3 -prefix edges_T1w_mask.nii.gz \
-input $2

@chauffeur_afni \
-ulay $1 \
-olay edges_T1w_mask.nii.gz \
-prefix afni_pic_anat_edges \
-montx 9 -monty 1 \
-set_xhairs OFF \
-label_mode 1 -label_size 3 \
-do_clean

rm edges_T1w_mask.nii.gz

@chauffeur_afni \
-ulay $3 \
-prefix afni_pic_std_space \
-montx 9 -monty 1 \
-set_xhairs OFF \
-label_mode 1 -label_size 3 \
-do_clean


imgs="_anat_edges _std_space"
for i in $imgs; do
convert afni_pic"$i".cor.png -gravity east -chop 11.2%x0 afni_pic"$i".cor.png
convert afni_pic"$i".axi.png -gravity east -chop 11.2%x0 afni_pic"$i".axi.png

convert afni_pic"$i".sag.png -gravity west -chop 11%x0 afni_pic"$i".sag.png
convert afni_pic"$i".sag.png -gravity east -chop 13%x0 afni_pic"$i".sag.png
# Concatenate the axial, saggital and coronal sections for each sub and ses
convert afni_pic"$i".*.png \
-gravity center \
-background black \
-append \
all_panes"$i".png
done

composite -blend 30 all_panes_anat_edges.png \
all_panes_std_space.png \
all_panes_transparent.png

convert -delay 80 -loop 0 \
all_panes_anat_edges.png \
all_panes_transparent.png \
all_panes_std_space.png \
"$6"QC_anat2std_space.gif

rm *.png


# Generate anat image without edges

3dcalc -a "$4" -b "$4" -expr 'a*b' -prefix maskED_func.nii.gz

3dcalc -a "$1" -b "$2" -expr 'a*b' -prefix maskED_anat.nii.gz

3dresample -master maskED_anat.nii.gz \
-prefix maskED_func_resampled2anat.nii.gz \
-input maskED_func.nii.gz

3dedge3 -prefix edges_bold_maskED.nii.gz \
-input maskED_func_resampled2anat.nii.gz

# Put edges and func together

@chauffeur_afni \
-ulay maskED_func_resampled2anat.nii.gz \
-olay edges_bold_maskED.nii.gz \
-prefix afni_pic_func_with_edges \
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
-prefix afni_pic_anat_and_func_edges_transparent \
-func_range_perc 40 \
-opacity 9 \
-cbar "red_monochrome" \
-montx 9 -monty 1 \
-set_xhairs OFF \
-label_mode 1 -label_size 3 \
-do_clean


imgs="_func_with_edges _anat_and_func_edges_transparent"
for i in $imgs; do
convert afni_pic"$i".cor.png -gravity east -chop 11.2%x0 afni_pic"$i".cor.png
convert afni_pic"$i".axi.png -gravity east -chop 11.2%x0 afni_pic"$i".axi.png

convert afni_pic"$i".sag.png -gravity west -chop 11%x0 afni_pic"$i".sag.png
convert afni_pic"$i".sag.png -gravity east -chop 13%x0 afni_pic"$i".sag.png
# Concatenate the axial, saggital and coronal sections for each sub and ses
convert afni_pic"$i".*.png \
-gravity center \
-background black \
-append \
all_panes"$i".png
done


convert afni_pic_func_with_edges.*.png \
-append \
-brightness-contrast -10x10 \
afni_pic_func_with_edges_all_panes.png; done

convert afni_pic_anat_and_func_edges_transparent.*.png \
-append \
afni_pic_anat_and_func_edges_transparent_all_panes.png; done




convert -delay 100 -loop 0 \
afni_pic_anat_and_func_edges_transparent_all_panes.png \
afni_pic_func_with_edges_all_panes.png \
"$6"_QA_epi2anat.gif

rm maskED_func.nii.gz maskED_anat.nii.gz maskED_func_resampled2anat.nii.gz func_with_edges* anat_and_func_edges_transparent*