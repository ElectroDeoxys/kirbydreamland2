IF !DEF(__RGBDS_MAJOR__) || !DEF(__RGBDS_MINOR__) || !DEF(__RGBDS_PATCH__)
	fail "kirbydreamland2 requires rgbds 7.0 or newer."
ENDC

IF (__RGBDS_MAJOR__ == 0 && __RGBDS_MINOR__ < 7)
	fail "kirbydreamland2 requires rgbds 7.0 or newer."
ENDC
