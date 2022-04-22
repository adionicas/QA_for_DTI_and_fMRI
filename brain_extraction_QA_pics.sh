#!/bin/bash

# arg1 is underlay
# arg2 is overlay (or the mask)
# arg3 is the output prefix

# Ex command: 
# bash brain_extraction_QA_pics.sh sub-ACAP1023_space-MNIPediatricAsym_cohort-5_desc-preproc_T1w.nii.gz sub-ACAP1023_space-MNIPediatricAsym_cohort-5_desc-brain_mask.nii.gz my_pretty_image

@chauffeur_afni \
-ulay "$1" -olay "$2" -opacity 4 -prefix  afni_pic -montx 9 -monty 1 -set_xhairs OFF -label_mode 1 -label_size 3 -do_clean

 img="afni_pic.cor.png"
 convert $img -crop 0x0+333+0 $img
 convert $img -crop 3150x0+0+0 $img

 img="afni_pic.axi.png"
 convert $img -crop 0x0+380+0 $img
 convert $img -crop 3150x0+0+0 $img

 img="afni_pic.sag.png"
 convert $img -crop 0x0+420+0 $img
 convert $img -crop 3250x0+0+0 $img

 convert afni_pic.*.png \
 -append \
 $3.png

 rm afni_pic*.png
