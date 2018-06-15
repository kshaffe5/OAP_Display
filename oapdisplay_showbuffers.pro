PRO OAPdisplay_showbuffers, tmp

common block1

  ;The follow statements build the data records based on probe type
  
  
  CASE 1 of 
    prbtype EQ '2DS' : BEGIN
      data_record = BYTARR(4,128,1700)
      ;convert to binary
      FOR m=0,3 DO BEGIN
        FOR k=0,1700-1 DO BEGIN
          FOR j=0,7 DO BEGIN
            FOR i = 16, 31 DO BEGIN
              pow2 = 2L^(i-16)
              IF (LONG(tmp[m,j,k]) AND pow2) NE 0 THEN $
                data_record[m,j*16L+(i-16),k]=0 ELSE data_record[m,j*16L+(i-16),k]=1
            ENDFOR
            data_record[m,j*16L:j*16L+15,k] = REVERSE(data_record[m,j*16L:j*16L+15,k],2)
          ENDFOR
        ENDFOR
      ENDFOR

      data_record = REFORM(data_record)
      ;for 2DS data, if all diodes are blocked, the cdf file shows everything unblocked....following fixes that
      FOR m=0,3 DO BEGIN
        end_buf=1
        FOR i=1700-1,0,-1 DO BEGIN
          CASE end_buf of
            0: IF(TOTAL(data_record[m,*,i]) EQ 128 ) THEN data_record[m,*,i]=0
            1: IF(TOTAL(data_record[m,*,i]) NE 128 ) THEN end_buf=0
          ENDCASE
        ENDFOR
      ENDFOR   
       
      ;the following draws a border around the buffer
      tmp = data_record
      data_record=LONARR(4,134,1706)
      data_record[*,3:130,3:1702]=tmp
     
    END
    
    
    
    prbtype EQ 'CIP' : BEGIN
      data_record=BYTARR(4,64,850)
      ;convert to binary
      FOR m=0,3 DO BEGIN
        FOR k=0,850-1 DO BEGIN
          FOR j=0,7 DO BEGIN
            FOR i = 24, 31 DO BEGIN
              pow2 = 2L^(i-24)
              IF (LONG(tmp[m,j,k]) AND pow2) NE 0 THEN $
                data_record[m,j*8L+(i-24),k]=1 ELSE data_record[m,j*8L+(i-24),k]=0
            ENDFOR
            data_record[m,j*8L:j*8L+7,k] = REVERSE(data_record[m,j*8L:j*8L+7,k],2)
          ENDFOR
        ENDFOR
      ENDFOR

      data_record = REFORM(data_record)
      ;for CIP data, if all diodes are blocked, the cdf file shows everything unblocked....following fixes that
      FOR m=0,3 DO BEGIN
        end_buf=1
        FOR i=850-1,0,-1 DO BEGIN
          CASE end_buf of
            0: IF(TOTAL(data_record[m,*,i]) EQ 64 ) THEN data_record[m,*,i]=0
            1: IF(TOTAL(data_record[m,*,i]) NE 64 ) THEN end_buf=0
          ENDCASE
        ENDFOR
      ENDFOR

      ;the following draws a border around the buffer
      tmp = data_record
      data_record=LONARR(4,68,854)
      data_record[*,2:65,2:851]=tmp

    END
  ENDCASE


 
  i=image(transpose(LONG(data_record[0,*,*])), /current, POSITION=[0,0.76,1,1])                                             ; Prints the 4 buffer images
  i=image(transpose(LONG(data_record[1,*,*])), /current, POSITION=[0,0.515,1,0.75])
  i=image(transpose(LONG(data_record[2,*,*])), /current, POSITION=[0,0.27,1,0.5])
  i=image(transpose(LONG(data_record[3,*,*])), /current, POSITION=[0,0.03,1,0.25])

  

bad_timestamps=0                                          ; Checks to see if timestamps have been selected to display
IF (timestamp_sel[0]) THEN bad_timestamps=1
IF (bad_timestamps) THEN BEGIN



;***************************************************

For m=0,3 DO BEGIN
  
buffer_total_part=where(time_disp[m,*] NE -999)
buffer_last_part= MAX(buffer_total_part)
buffer_first_time= time_disp[m,0]
buffer_last_time= time_disp[m,buffer_last_part]
forward_function hhmmss2sec
buffer_first_time=hhmmss2sec(buffer_first_time)
buffer_last_time=hhmmss2sec(buffer_last_time)
buffer_total_time = buffer_last_time - buffer_first_time

buffer_spacing= ceil((buffer_total_time)/6)   ; Determines the amount of time between timestamps.
CASE buffer_spacing OF
  0: buffer_spacing=1   ; If the total time of the buffer is less than 6, then there should be one second between timestamps.
  ELSE: buffer_spacing=buffer_spacing
ENDCASE

IF (buffer_total_time LT 1) THEN buffer_first_time=buffer_first_time         ; If the buffer is less than one second long, then print one timestamp.
IF (buffer_total_time GE 1) THEN buffer_first_time = buffer_first_time + 1   ; If it is at least one second long, then the first timestamp is at the first new second.
buffer_second_time = buffer_first_time + buffer_spacing
buffer_third_time = buffer_second_time + buffer_spacing
buffer_fourth_time = buffer_third_time + buffer_spacing
buffer_fifth_time = buffer_fourth_time + buffer_spacing
buffer_sixth_time = buffer_fifth_time + buffer_spacing

forward_function sec2hhmmss
buffer_first_time=sec2hhmmss(buffer_first_time)
buffer_second_time=sec2hhmmss(buffer_second_time)                     ; Converts the times from seconds to hhmmss
buffer_third_time=sec2hhmmss(buffer_third_time)
buffer_fourth_time=sec2hhmmss(buffer_fourth_time)
buffer_fifth_time=sec2hhmmss(buffer_fifth_time)
buffer_sixth_time=sec2hhmmss(buffer_sixth_time)


buffer_first_time_part = where(time_disp[m,*] GE buffer_first_time)
buffer_part_prior_to_first_time = buffer_first_time_part[0]
buffer_first_time_slicnt = pos_disp[m, buffer_part_prior_to_first_time]

buffer_second_time_part = where(time_disp[m,*] GE buffer_second_time)             ; Finds the position of the timestamps
buffer_part_prior_to_second_time = buffer_second_time_part[0]                     ; for the buffer as a slicecount.
buffer_second_time_slicnt = pos_disp[m, buffer_part_prior_to_second_time]

buffer_third_time_part = where(time_disp[m,*] GE buffer_third_time)
buffer_part_prior_to_third_time = buffer_third_time_part[0]
buffer_third_time_slicnt = pos_disp[m, buffer_part_prior_to_third_time]

buffer_fourth_time_part = where(time_disp[m,*] GE buffer_fourth_time)
buffer_part_prior_to_fourth_time = buffer_fourth_time_part[0]
buffer_fourth_time_slicnt = pos_disp[m, buffer_part_prior_to_fourth_time]

buffer_fifth_time_part = where(time_disp[m,*] GE buffer_fifth_time)
buffer_part_prior_to_fifth_time = buffer_fifth_time_part[0]
buffer_fifth_time_slicnt = pos_disp[m, buffer_part_prior_to_fifth_time]

buffer_sixth_time_part = where(time_disp[m,*] GE buffer_sixth_time)
buffer_part_prior_to_sixth_time = buffer_sixth_time_part[0]
buffer_sixth_time_slicnt = pos_disp[m, buffer_part_prior_to_sixth_time]



buffer_first_location = Float(buffer_first_time_slicnt)/1700l
buffer_second_location = Float(buffer_second_time_slicnt)/1700l                 ; Determines the location of the timestamps
buffer_third_location = Float(buffer_third_time_slicnt)/1700l                   ; within the buffer as a decimal from 0 to 1.
buffer_fourth_location = Float(buffer_fourth_time_slicnt)/1700l
buffer_fifth_location = Float(buffer_fifth_time_slicnt)/1700l
buffer_sixth_location = Float(buffer_sixth_time_slicnt)/1700l


CASE m OF
  0: BEGIN
    test= [0.985,0.775]
    test1= 0.74
    END
  1: BEGIN
    test= [0.735,0.525]
    test1=0.4925
    END
  2: BEGIN
    test= [0.488,0.278]
    test1=0.248
    END
  3: BEGIN
    test=[0.242,0.032]
    test1=0
    END
ENDCASE


buffer_first_timeline=POLYLINE([(buffer_first_location),(buffer_first_location - 0.0000000001)],test)
buffer_second_timeline=POLYLINE([(buffer_second_location),(buffer_second_location - 0.0000000001)],test)
buffer_third_timeline=POLYLINE([(buffer_third_location),(buffer_third_location - 0.0000000001)],test)
buffer_fourth_timeline=POLYLINE([(buffer_fourth_location),(buffer_fourth_location - 0.0000000001)],test)
buffer_fifth_timeline=POLYLINE([(buffer_fifth_location),(buffer_fifth_location - 0.0000000001)],test)
buffer_sixth_timeline=POLYLINE([(buffer_sixth_location),(buffer_sixth_location - 0.0000000001)],test)


six_buffer_first_time = STRTRIM(STRING(buffer_first_time),2)
six_buffer_first_time = '000000' + six_buffer_first_time
six_buffer_first_time = six_buffer_first_time.substring(-6)
six_buffer_second_time = STRTRIM(STRING(buffer_second_time),2)
six_buffer_second_time = '000000' + six_buffer_second_time
six_buffer_second_time = six_buffer_second_time.substring(-6)
six_buffer_third_time = STRTRIM(STRING(buffer_third_time),2)
six_buffer_third_time = '000000' + six_buffer_third_time
six_buffer_third_time = six_buffer_third_time.substring(-6)
six_buffer_fourth_time = STRTRIM(STRING(buffer_fourth_time),2)
six_buffer_fourth_time = '000000' + six_buffer_fourth_time
six_buffer_fourth_time = six_buffer_fourth_time.substring(-6)
six_buffer_fifth_time = STRTRIM(STRING(buffer_fifth_time),2)
six_buffer_fifth_time = '000000' + six_buffer_fifth_time
six_buffer_fifth_time = six_buffer_fifth_time.substring(-6)
six_buffer_sixth_time = STRTRIM(STRING(buffer_sixth_time),2)
six_buffer_sixth_time = '000000' + six_buffer_sixth_time
six_buffer_sixth_time = six_buffer_sixth_time.substring(-6)


buffer_timestamp1= TEXT(buffer_first_location,test1, FONT_SIZE=10.5 , six_buffer_first_time)
buffer_timestamp2= TEXT(buffer_second_location,test1, FONT_SIZE=10.5, six_buffer_second_time)
buffer_timestamp3= TEXT(buffer_third_location,test1, FONT_SIZE=10.5, six_buffer_third_time)
buffer_timestamp4= TEXT(buffer_fourth_location,test1, FONT_SIZE=10.5, six_buffer_fourth_time)
buffer_timestamp5= TEXT(buffer_fifth_location,test1, FONT_SIZE=10.5, six_buffer_fifth_time)
buffer_timestamp6= TEXT(buffer_sixth_location,test1, FONT_SIZE=10.5, six_buffer_sixth_time)

Endfor

ENDIF
 
END
