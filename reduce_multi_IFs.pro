;;;   .r /scratch/sjc/gbt/reduce_multi_IFs      TO COMPILE
;;;   reduce_multi_IFs,/SCAN   TO RUN
;;;
;;;   VERSION OF reduce.pro  TO DEAL WITH MULTIPLE IFs
;;;
;;;
;;;   
;;; scp reduce_multi_IFs.pro sjc@astro1.phys.unsw.edu.au:/scratch/sjc/gbt/

pro reduce_multi_IFs, file_name, scan=scan, new_index=new_index ; open line 
   if (!g.line) then begin
        new_io = sdfitsin(file_name, new_index=new_index)
        if (obj_valid(new_io)) then begin
            if (obj_valid(!g.lineio)) then obj_destroy, !g.lineio
            !g.lineio = new_io
            !g.line_filein_name = file_name
        endif
        summary    
        z = ' '                 ; initialises string
        read, z, prompt='Keep zoom factor? [y/n]: '
        if strcmp(z,"n") then unzoom  
        unfreeze   
              if keyword_set(scan) then begin
                  g = ' '
                  emptystack    ; clear the stack

                  READ, ifn, PROMPT='Enter IF [0,1,2 or 3]:'
                 
                 READ, s1, PROMPT='Enter start scan - ensure that this is the ON scan!:' 
                  READ, s2, PROMPT='Enter finish scan: '
                 
                  ; READ, poln, PROMPT='Enter POL [0 = YY, 1 = XX]: '
                 ; now setting to do each pol in turn 
                 poln = 0 ; 
                 print, uint(poln),'...is the polarisation being done now'
               
                ;    print, uint(ifn) + 1; IFs go from 0-3 but buffers from 1-4
                    
;;;;;;;;;start with an uflagged average in order to set the scale;;;;;;;;;;;;;;;;;;;
                  va = ' '                 ; initialises string
                  read, va, prompt='View the average? [y/n]: '
                  if strcmp(va,"y") then begin
                      sclear 
                      freeze ; turn OFF autoupdates, or will take forever plotting each scan
                    
                   for i = uint(s1), uint(s2), 2  do begin 
;;; setting to integer via ifnum=uinit(ifn) didn't work, so using ifnum=fix(ifn)                        
                     getps, units='Jy',plnum=fix(poln), ifnum=fix(ifn), string(i) &  hanning,/decimate & accum
                  endfor
                   unfreeze     ; autoupdates back on
                   ave          ;, fix(ifn);;;+1;  average data in buffer fix(ifn)+1
                   endif                  ; confuses IF = 3. don't need as have sclear above
                                          ; p21 GBTIDL manual
               
            zof = ' '      
           read, zof, prompt='Zoom in on frequency? [y/n]: '
           while strcmp(zof,"y") do begin
              READ, lf, PROMPT='Enter lower frequency in MHz (e.g. 441): '
              READ, uf, PROMPT='Enter upper frequency in MHz (e.g. 445): '
              setx,lf,uf   
              read, zof, prompt='Zoom in on frequency? [y/n]: '
           endwhile

                  zo = ' '      ; initialises string
                  read, zo, prompt='General zoom? [y/n]: '
                  while strcmp(zo,"y") do begin
                     setxy      ; this is the zoom command
                     read, zo, prompt='Zoom? [y/n]: '
                  endwhile  
                  unzo = ' '    ; initialises string
                  read, unzo, prompt='Unzoom? [y/n]: '
                  while strcmp(unzo,"y") do begin unzoom ; totally unzooms
                     zo = ' '                            ; initialises string
                    
                  endwhile
                  z = ' '       ; initialises string
                  read, z, prompt='Change y-scale? [y/n]: '
                  while  strcmp(z,"y") do begin
                     READ, ly, PROMPT='Enter lower flux in Jy: '
                     READ, uy, PROMPT='Enter upper flux in Jy: '
                     sety,ly,uy
                     read, z, prompt='Zoom in on y-scale? [y/n]: '
                  endwhile

                   sm = ' '  ; initialises string
                  read, sm, prompt='Smooth data? [y/n]: '

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            sclear ;Clears the default global accumulator
           
            for i = uint(s1), uint(s2), 2 do begin ; 1st value (integer), last, increment (leave blank for 1)
               print, 'scan: ', i
              
               getps, units='Jy',plnum=fix(poln), ifnum=fix(ifn), string(i) &  hanning,/decimate 
               
               if strcmp(sm,"y") then gsmooth,10,/decimate ; smoothing by factor of 10 - can remove    
               
               read, g, prompt='Keep this one [y/n]: '
               ; if g eq uint(1) then appendstack, i
               if strcmp(g,"y",1,/fold_case) then appendstack, i
            endfor
            ;;;;;;;;;;SAVE IN A FILE WHAT'S BEING saved;;;;;;;;;;;
       ;     openw, 1, 'out.dat'
       ;     printf,1, file_name
        ;    printf,1, poln
        ;    printf,1, liststack
        ;    close, 1
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            liststack           ; list what's in the stack
         endif
           endif 
;;; WANT DO AVERAGE, DO OTHER POL AND KEEP NOT OF SCANS IN A FILE
worth = ' ' ; initialises string
read, worth, prompt='Are there any scans worth keeping [y/n]: '
if  strcmp(worth,"y") then begin 

   freeze ;;;; no onto avg bit
   sclear,0

   ls                           ; should list fits files
   fo = ' '                     ; initialises string 
   read, fo, prompt='Name for output file (e.g. J0414+0534_IF1_850MHz.fits): '
   fileout, fo
   for i=0,!g.acount-1 do begin
 
      getps,astack(i),plnum=fix(poln),ifnum=fix(ifn),units='Jy',_extra=extra ; &  hanning,/decimate & accum
      accum, 0                  ; IFs go from 0-3 but buffers from 1-4
   endfor 
   ave, 0                       ; average data in this buffer
;;;;;avgstack ; this is a serious pain in the arse - which one is it?
   hanning,/decimate
   unfreeze
   keep
   show
endif

emptystack ;;; THIS IS WHAT WE NEED - THAT sclear DOES BUGGER ALL!
print, '--------------------------NEXT POLARISATION--------------------'
poln = 1                        ; 
print, uint(poln),'...is the polarisation being done now'
 
             sclear             ;Clears the default global accumulator
             
             for i = uint(s1), uint(s2), 2 do begin ; 1st value (integer), last, increment (leave blank for 1)
               print, 'scan: ', i
               getps, units='Jy',plnum=fix(poln), ifnum=fix(ifn), string(i) &  hanning,/decimate 

               if strcmp(sm,"y") then gsmooth,10,/decimate ; smoothing by factor of 10 - can remove    
               
               read, g, prompt='Keep this one [y/n]: '
               ; if g eq uint(1) then appendstack, i
               if strcmp(g,"y",1,/fold_case) then appendstack, i
            endfor
            ;;;;;;;;;;SAVE IN A FILE WHAT'S BEING saved;;;;;;;;;;;
       ;     openw, 1, 'out.dat'
       ;     printf,1, file_name
        ;    printf,1, poln
        ;    printf,1, liststack
        ;    close, 1
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          ;  liststack           ; list what's in the stack
       
;;; WANT DO AVERAGE, DO OTHER POL AND KEEP NOT OF SCANS IN A FILE

worth2 = ' ' ; initialises string
read, worth2, prompt='Any of these worth keeping [y/n]: '
if  strcmp(worth2,"y") then begin

   freeze ;;;; now onto avg bit
   sclear,1

   if  strcmp(worth,"n") then begin 
      read, fo, prompt='Name for output file (e.g. J0414+0534_IF1_850MHz.fits): '
   endif  ; as this file name would not have been put in

   fileout, fo
   for i=0,!g.acount-1 do begin
 
      getps,astack(i),plnum=fix(poln),ifnum=fix(ifn),units='Jy',_extra=extra ; &  hanning,/decimate & accum
      accum,1                   ; putting in buffer after the previous
   endfor 
   ave,1
;;;;;avgstack ; this is a serious pain in the arse - which one is it?
   hanning,/decimate
   unfreeze
   keep
   show
   print, 'NEXT AVERAGE WILL BE APPENDED TO THIS IS NOT RENAMED!'
   print, ' '
   print, 'gsmooth,10,/decimate                   WILL SMOOTH BY FACTOR OF 10'

   print, '------------------ EXIT GBTIDL THEN .....--------------------'
   print, 'filein,fo'
   print, 'emptystack'
   print, 'addstack,FIRST,LAST,INCREMENT'
   print, 'avgstack'
endif

end
