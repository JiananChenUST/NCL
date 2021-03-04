load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl" 
begin

    files   = systemfunc("ls ./first/D3-C11-DP/wrfout_d03*")
    a       = addfiles(files,"r")
    simulation=(/"D3-C11-DP","D3-C05-DP","D3-C05-NC","D3-C06-DP","D3-C06-NC"/)
    name_of_simulation=simulation(0)
    dir      = "./first/D3-C05-DP/"
    filename = "wrfout_d03_2012-07-24_00:00:00"
    fmap        = addfile(dir+filename+".nc","r")
   
    minlat =   22
    maxlat =   22.7
    minlon =  113.5
    maxlon =  114.5

   ; minlat =   22.1597
   ; maxlat =   22.5875
   ; minlon =  113.8700
   ; maxlon =  114.3797
    lats = (/ minlat, maxlat /)
    lons = (/ minlon, maxlon /)
    loc  = wrf_user_ll_to_xy(fmap, lons, lats, True)
    print(loc)
    print("loc(1,0) is " + loc(1,0))
    print("loc(0,1) is " + loc(0,1))
    print("loc(1,1) is " + loc(1,1))
    print("loc(0,0) is " + loc(0,0))
 do it=0,96,1
   rain       = wrf_user_getvar(a,"RAINNC",it)    
   rain@lat2d = wrf_user_getvar(a,"XLAT",it)   
   rain@lon2d = wrf_user_getvar(a,"XLONG",it)   
   print("the cycle is "+ it)
 
  if it.gt.0 then
      rain_0= wrf_user_getvar(a,"RAINNC",it-1)
      rain=rain-rain_0
  end if
   
  bc= ispan(0,96,1)
  b=tostring(bc)
  wks = gsn_open_wks("png",b(it))

  

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
  res_tot@gsnLeftString        = name_of_simulation
  
  res_tot@cnLevelSelectionMode = "ManualLevels"
  res_tot@cnMaxLevelValF       = 50  
  res_tot@cnMinLevelValF       =  5
  res_tot@cnLevelSpacingF      =  2
  
  
  res_tot@mpOutlineBoundarySets = "AllBoundaries"
  res_tot@mpDataSetName         = "Earth..4"      ; Gives us provincial boundaries
  res_tot@mpGeophysicalLineThicknessF = 3       ; thickness of map outlines
  res_tot@mpProvincialLineThicknessF  = 2.
  res_tot@mpProvincialLineColor       = "black"

  res_tot@tfDoNDCOverlay        = True
  res_tot = wrf_map_resources(fmap, res_tot)     
  res_tot@tfDoNDCOverlay        = True


  time_title=fspan(0,48,97)
  time      =flt2string(time_title)
  res_tot@tiMainString  = time(it)+" hour(s) since 072300,per half hour rainfall (mm)"

;---Necessary for contours to be overlaid correctly on WRF projection
  res_tot@tfDoNDCOverlay      = True          ; Tell NCL you are doing a native plot
  res_tot@gsnAddCyclic        = False

  res_tot@ZoomIn = True        ; These five resources are required
  res_tot@Xstart = loc(0,0)    ; when zooming in on WRF data and
  res_tot@Xend   = loc(0,1)    ; keeping the same map projection.
  res_tot@Ystart = loc(1,0)
  res_tot@Yend   = loc(1,1)
  res_tot = wrf_map_resources(fmap,res_tot)

  plot_rain = gsn_csm_contour_map(wks,rain(loc(1,0):loc(1,1),loc(0,0):loc(0,1)),res_tot) 

draw(plot_rain)  
frame(wks)
end do 
end
