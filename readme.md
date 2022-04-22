Functions for QA images depend on:
- AFNI: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/index.html
- ImageMagick: https://imagemagick.org/script/download.php

Inputs need to be in the same space (either T1 space or template space).

Check epi to anat registration and anat to templat registration:

```bash
for scan in $scans; do
bash anat2tpl.sh "$scan"_space-MNIPediatricAsym_cohort-5_desc-preproc_T1w.nii.gz \
"$scan"_space-MNIPediatricAsym_cohort-5_desc-brain_mask.nii.gz \
tpl-MNIPediatricAsym_cohort-5_res-1_T1w.nii.gz \
"$scan"
bash epi2anat.sh "$scan"_task-rest_space-MNIPediatricAsym_cohort-5_res-2_boldref.nii.gz \
"$scan"_task-rest_space-MNIPediatricAsym_cohort-5_res-2_desc-brain_mask.nii.gz \
"$scan"_space-MNIPediatricAsym_cohort-5_desc-preproc_T1w.nii.gz \
"$scan"_space-MNIPediatricAsym_cohort-5_desc-brain_mask.nii.gz \
"$scan"
done
```

Segmentatioin:

![](https://github.com/adionicas/QA_for_DTI_and_fMRI/blob/main/output_QC_segment_WM_CSF.gif?raw=true)


Brain extraction:

![](https://github.com/adionicas/QA_for_DTI_and_fMRI/blob/main/QC_brain_extraction.png?raw=true)
