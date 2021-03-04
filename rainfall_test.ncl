load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl" 
begin
;---Open WRF output file
  dir      = "./first/D3-C05-DP/"
  filename = "wrfout_d03_2012-07-24_00:00:00"
  a        = addfile(dir+filename+".nc","r")
  
;---Read several WRF variables at first time step
  it  = 0 
  rain       = wrf_user_getvar(a,"RAINNC",it)    ; Terrain elevation
  rain@lat2d = wrf_user_getvar(a,"XLAT",it)   ; latitude/longitude
  rain@lon2d = wrf_user_getvar(a,"XLONG",it)  ; required for plotting
  HGT        = wrf_user_getvar(a,"HGT",it)
  HGT@lat2d  = wrf_user_getvar(a,"XLAT",it)   ; latitude/longitude
  HGT@lon2d  = wrf_user_getvar(a,"XLONG",it)  ; required for plotting
;---open a workspace
wks = gsn_open_wks("png","rainfall")

;---terrain height
  res_ter                       = True
  res_ter@gsnFrame              = False
  res_ter@gsnDraw               = False 
  res_ter@cnFillOn              = True             ; color plot desired
  res_ter@cnFillPalette         = "gsltod"         ; Select grayscale colormap
  res_ter@cnLinesOn             = False            ; turn off contour lines
  res_ter@cnLineLabelsOn        = False            ; turn off contour labels
  res_ter@cnFillMode            = "RasterFill"
  res_ter@cnFillOpacityF        = 1.
  res_ter@lbLabelBarOn          = False
  res_ter@gsnRightString        =  ""
  
  res_ter = wrf_map_resources(a, res_ter)      ; set map resources to match those on WRF file
     
  res_ter@tfDoNDCOverlay        = True

  res_ter@mpOutlineBoundarySets = "AllBoundaries"
  res_ter@mpDataSetName         = "Earth..4"      ; Gives us provincial boundaries
  res_ter@mpGeophysicalLineThicknessF = 3       ; thickness of map outlines
  res_ter@mpProvincialLineThicknessF  = 2.
  res_ter@mpProvincialLineColor       = "black" 
  
  res_ter@pmTickMarkDisplayMode = "Always"         ; turn on nicer tickmarks
  res_ter@tmXBLabelFontHeightF  = 0.018
  res_ter@tmYLLabelFontHeightF  = 0.018
  res_ter@tmYLLabelStride       = 2                ; label every other tickmark
  res_ter@tmXBLabelStride       = 2
  res_ter@mpLimitMode = "LatLon"
  res_ter@mpMinLatF     = 22.
  res_ter@mpMaxLatF     = 25
  res_ter@mpMinLonF     = 113.0
  res_ter@mpMaxLonF     = 117.5
  res_ter@mpGeophysicalLineThicknessF= 2.
  res_ter@mpNationalLineThicknessF = 2.
  res_ter@mpMaskAreaSpecifiers = (/"China:states","Taiwan"/) 
    time_title= 2
  time      =flt2string (time_title)
  res_ter@tiMainString  = time + "hhh"

;---Set resources for rain total contour plot
  res_tot                       = True
  res_tot@gsnFrame              = False
  res_tot@gsnDraw               = False

  cmap     := read_colormap_file("BlAqGrYeOrReVi200")
  cmap(0,:) = (/0,0,0,0/)    ; make first color fully transparent

  res_tot@cnFillOn             = True
  res_tot@cnFillMode           = "RasterFill"
  res_tot@cnFillPalette        = cmap
  res_tot@cnLinesOn            = False            ; turn off contour lines
  res_tot@cnLineLabelsOn       = False            ; turn off contour labels
  res_tot@cnFillOpacityF       = 1.               ; .85 

  res_tot@pmLabelBarHeightF    = 0.08        ; Make labelbar less thick
  res_tot@lbLabelFontHeightF   = 0.014
  res_tot@pmLabelBarOrthogonalPosF = -0.008

  res_tot@cnInfoLabelOn        = True
  res_tot@cnInfoLabelString    = "Min= $ZMN$ Max= $ZMX$"
  res_tot@cnInfoLabelOrthogonalPosF = -0.104        ; move info label into plot

  res_tot@tiMainFont           = "Helvetica-bold"
  res_tot@tiMainFontHeightF    = 0.018
  res_tot@gsnRightString       = "RAIN, mm" 
  res_tot@gsnLeftString        =  ""

  res_tot@tfDoNDCOverlay      = True          ; Tell NCL you are doing a native plot
  res_tot@gsnAddCyclic        = False


   plot_terrain= gsn_csm_contour_map(wks,HGT,res_ter)
   plot_rain   = gsn_csm_contour(wks,rain,res_tot)
;---Set map resources based on projection on WRF output file  
overlay(plot_terrain,plot_rain)
draw(plot_terrain)   ; This will draw all overlaid plots and the map
frame(wks)
end
