
# arg1 is anat image
# arg2 is anat mask
# arg3 in standard space image
# arg4 is output prefix

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
"$4"QC_anat2std_space.gif

rm *.png
