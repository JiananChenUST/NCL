load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl" 
begin

    files   = systemfunc("ls ./first/D3-C11-DP/wrfout_d03*")
    a       = addfiles(files,"r")
    
    geo= wrf_user_getvar(a,"geopotential",-1)
    ;printVarSummary(geo)
    
    minlat =   22
    maxlat =   22.7
    minlon =  113.5
    maxlon =  114.5

    time_step=0 
    vertical_layer=10
    grid_size_x=5000
    grid_size_y=5000


    lats = (/ minlat, maxlat /)
    lons = (/ minlon, maxlon /)
    loc  = wrf_user_ll_to_xy(a, lons, lats, True)
    x_start = loc(0,0)     
    x_end   = loc(0,1)    
    y_start = loc(1,0)
    y_end   = loc(1,1)
   
 
    grid_number_x= x_end-x_start
    grid_number_y= y_end-y_start
    geo_start = geo(time_step,vertical_layer,x_start,y_start)
    geo_end   = geo(time_step,vertical_layer,x_end,y_end)


    ;---calculate the pressure gradient force
   
   grad_diff_x_array = new((/grid_number_y,grid_number_x/),float)
   grad_diff_y_array = new((/grid_number_y,grid_number_x/),float)
   

    do j=1,grid_number_y,1

        do i = 1,grid_number_x,1
          

          geo_x_plus=geo(time_step,vertical_layer,x_start+i,y_start)

          geo_x= geo(time_step,vertical_layer,x_start+i-1,y_start)

          grad_diff_x_array(j-1,i-1)=geo_x_plus-geo_x
 
        end do    
    
    end do

    do  m= 1, grid_number_x,1

        do n = 1, grid_number_y,1
        
          geo_y_plus=geo(time_step,vertical_layer,x_start,y_start+n)

          geo_y=geo(time_step,vertical_layer,x_start,y_start+n-1)
  
          grad_diff_y_array(n-1,m-1)=geo_y_plus-geo_y

        end do
    end do
    
    
    
    grad_force_x= grad_diff_x_array/grid_size_x
    grad_force_y= grad_diff_y_array/grid_size_y
    grad_force= (grad_force_x^2+grad_force_y^2)^(0.5)
    printVarSummary(grad_force_x)
  ;---calculate the reference wind speed
    


end

