# Notes

in `lowpass_sox.sh`, we use `sox` to do lowpass filtering. 

`lowpass 120 2 norm -3` - two pole 120hz with width = 2. 
we run this filter twice to achieve a stronger filtering profile
