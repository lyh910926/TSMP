# /bin/ksh

initSetup(){
  defaultFDCLM="/p/project/chbn33/hbn331/database/bonnRadar/clm"
  defaultFDCOS="/p/project/chbn33/hbn331/database/bonnRadar/cosmo/2014111500"
  defaultFDOAS="/p/project/chbn33/hbn331/database/bonnRadar/oasis3"
  defaultFDPFL="/p/project/chbn33/hbn331/database/bonnRadar/parflow"


  defaultNLCLM=$rootdir/bldsva/setups/bonnRadar/lnd.stdin 
  defaultNLCOS=$rootdir/bldsva/setups/bonnRadar/lmrun_uc 
  defaultNLPFL=$rootdir/bldsva/setups/bonnRadar/coup_oas.tcl

  defaultNppn=48
  defaultCLMProcX=42
  defaultCLMProcY=1
  defaultCOSProcX=12
  defaultCOSProcY=12
  defaultPFLProcX=21
  defaultPFLProcY=14

  defaultStartDate="2014-11-15 00"
  defaultInitDate="2014-11-15 00"
  defaultRunhours=72

  defaultDumpCLM=1
  defaultDumpCOS=1
  defaultDumpPFL=1

  gx_clm=294
  gy_clm=294
  dt_clm=3600
  res="0294x0294"

  gx_cos=300
  gy_cos=300
  dt_cos=6
  nbndlines=3

  gx_pfl=294
  gy_pfl=294
  dt_pfl=1.0
  pflrunname="rurlaf"
  base_pfl=0.01

  cplfreq1=90
  cplfreq2=3600

  if [[ $withPFL == "false" && $withCOS == "true" ]]; then
    if [[ $cplscheme == "false" ]]; then
      defaultNLOAS=$rootdir/bldsva/data_oas3/namcouple_cos_clm_a1
    else
      defaultNLOAS=$rootdir/bldsva/data_oas3/namcouple_cos_clm
    fi
  fi
  if [[ $withPFL == "true" && $withCOS == "false" ]]; then
    defaultNLOAS=$rootdir/bldsva/data_oas3/namcouple_pfl_clm
  fi
  if [[ $withPFL == "true" && $withCOS == "true" ]]; then
    if [[ $cplscheme == "false" ]]; then
      defaultNLOAS=$rootdir/bldsva/data_oas3/namcouple_cos_clm_pfl_a1
    else
      defaultNLOAS=$rootdir/bldsva/data_oas3/namcouple_cos_clm_pfl
    fi
  fi


}

finalizeSetup(){
route "${cblue}>> finalizeSetup${cnormal}"
  if [[ $withOAS == "true" ]] then
    comment "   copy clmgrid into rundir"
      cp $forcingdir_clm/grid* $rundir/clmgrid.nc >> $log_file 2>> $err_file
    check  

    comment "   copy oasis remappingfiles into rundir"
      cp $forcingdir_oas/* $rundir >> $log_file 2>> $err_file
    check
    if [[ $withOASMCT == "true" ]] then
      for x in $rundir/*BILINEA* ;do 
        comment "   rename oasis3 remapping files" 
          mv $x $(echo $x | sed "s/BILINEA/BILINEAR/") >> $log_file 2>> $err_file
        check 
      done
    fi  
  fi  

  if [[ $withCOS == "true" ]]; then
    comment "   TWOMOM lookup tables into rundir"
    cp $rootdir/bldsva/setups/bonnRadar/dmin* $rundir >> $log_file 2>> $err_file
    check
  fi  

  if [[ $withPFL == "true" ]] then
        comment "   cd to rundir"
          cd $rundir >> $log_file 2>> $err_file
        check

        comment "   copy slopes and slope script into rundir"
          cp $forcingdir_pfl/ascii2pfb_slopes.tcl $rundir/ascii2pfb_slopes.tcl >> $log_file 2>> $err_file
	check
          cp $forcingdir_pfl/*slope.pfb* $rundir >> $log_file 2>> $err_file
	check
          chmod u+w $rundir/*slope*  $rundir/ascii2pfb_slopes.tcl >> $log_file 2>> $err_file
        check
	comment "   sed procs into slopescript"
          sed "s,lappend auto_path.*,lappend auto_path $bindir/bin," -i $rundir/ascii2pfb_slopes.tcl >> $log_file 2>> $err_file
	check
          sed "s,__nprocx_pfl__,$px_pfl," -i $rundir/ascii2pfb_slopes.tcl >> $log_file 2>> $err_file
	check
          sed "s,__nprocy_pfl__,$py_pfl," -i $rundir/ascii2pfb_slopes.tcl >> $log_file 2>> $err_file
	check
	comment "   create sloap pfb with tclsh"
          tclsh ./ascii2pfb_slopes.tcl >> $log_file 2>> $err_file
	check		
	
	comment "   copy soilind and soilind script into rundir"
          cp $forcingdir_pfl/ascii2pfb_SoilInd.tcl $rundir/ascii2pfb_SoilInd.tcl >> $log_file 2>> $err_file
	check
          cp $forcingdir_pfl/*Soil* $rundir >> $log_file 2>> $err_file
	check
          chmod u+w $rundir/*Soil* $rundir/ascii2pfb_SoilInd.tcl >> $log_file 2>> $err_file
        check
	comment "   sed procs into soilindscript"
          sed "s,lappend auto_path.*,lappend auto_path $bindir/bin," -i $rundir/ascii2pfb_SoilInd.tcl >> $log_file 2>> $err_file
	check
          sed "s,__nprocx_pfl__,$px_pfl," -i $rundir/ascii2pfb_SoilInd.tcl >> $log_file 2>> $err_file
	check
          sed "s,__nprocy_pfl__,$py_pfl," -i $rundir/ascii2pfb_SoilInd.tcl >> $log_file 2>> $err_file
	check
	comment "   create soilInd pfb with tclsh"
        tclsh ./ascii2pfb_SoilInd.tcl >> $log_file 2>> $err_file
	check
  fi 
route "${cblue}<< finalizeSetup${cnormal}"
}
