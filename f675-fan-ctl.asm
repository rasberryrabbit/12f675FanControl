
_Interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;f675-fan-ctl.mpas,61 :: 		begin
;f675-fan-ctl.mpas,62 :: 		if T0IF_bit=1 then begin
	BTFSS      T0IF_bit+0, BitPos(T0IF_bit+0)
	GOTO       L__Interrupt2
;f675-fan-ctl.mpas,64 :: 		if PWM_OUT=0 then begin
	BTFSC      GP2_bit+0, BitPos(GP2_bit+0)
	GOTO       L__Interrupt5
;f675-fan-ctl.mpas,65 :: 		ON_PWM:=PWM;
	MOVF       _PWM+0, 0
	MOVWF      _ON_PWM+0
;f675-fan-ctl.mpas,66 :: 		if ON_PWM=0 then
	MOVF       _PWM+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__Interrupt8
;f675-fan-ctl.mpas,67 :: 		TMR0:=ON_PWM
	MOVF       _ON_PWM+0, 0
	MOVWF      TMR0+0
	GOTO       L__Interrupt9
;f675-fan-ctl.mpas,68 :: 		else begin
L__Interrupt8:
;f675-fan-ctl.mpas,69 :: 		TMR0:=CPWM_MAX-ON_PWM;
	MOVF       _ON_PWM+0, 0
	SUBLW      255
	MOVWF      TMR0+0
;f675-fan-ctl.mpas,70 :: 		PWM_OUT:=1;
	BSF        GP2_bit+0, BitPos(GP2_bit+0)
;f675-fan-ctl.mpas,71 :: 		end;
L__Interrupt9:
;f675-fan-ctl.mpas,72 :: 		end else begin
	GOTO       L__Interrupt6
L__Interrupt5:
;f675-fan-ctl.mpas,73 :: 		TMR0:=ON_PWM;
	MOVF       _ON_PWM+0, 0
	MOVWF      TMR0+0
;f675-fan-ctl.mpas,74 :: 		PWM_OUT:=0;
	BCF        GP2_bit+0, BitPos(GP2_bit+0)
;f675-fan-ctl.mpas,75 :: 		end;
L__Interrupt6:
;f675-fan-ctl.mpas,76 :: 		T0IF_bit:=0;
	BCF        T0IF_bit+0, BitPos(T0IF_bit+0)
;f675-fan-ctl.mpas,77 :: 		end;
L__Interrupt2:
;f675-fan-ctl.mpas,78 :: 		end;
L_end_Interrupt:
L__Interrupt51:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _Interrupt

_tempidx:

;f675-fan-ctl.mpas,85 :: 		begin
;f675-fan-ctl.mpas,86 :: 		Result:=0;
	CLRF       tempidx_local_result+0
;f675-fan-ctl.mpas,87 :: 		if PWM_HIGH=0 then
	BTFSC      GP4_bit+0, BitPos(GP4_bit+0)
	GOTO       L__tempidx12
;f675-fan-ctl.mpas,88 :: 		idx:=0     // 20 celcius - ground GP4
	CLRF       tempidx_idx+0
	GOTO       L__tempidx13
;f675-fan-ctl.mpas,89 :: 		else
L__tempidx12:
;f675-fan-ctl.mpas,90 :: 		idx:=20; // 30 celcius - NC GP4
	MOVLW      20
	MOVWF      tempidx_idx+0
L__tempidx13:
;f675-fan-ctl.mpas,91 :: 		while (idx<72) do begin
L__tempidx15:
	MOVLW      72
	SUBWF      tempidx_idx+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L__tempidx16
;f675-fan-ctl.mpas,92 :: 		Lo(tempr):=EEPROM_Read(idx);
	MOVF       tempidx_idx+0, 0
	MOVWF      FARG_EEPROM_Read_address+0
	CALL       _EEPROM_Read+0
	MOVF       R0+0, 0
	MOVWF      tempidx_tempr+0
;f675-fan-ctl.mpas,93 :: 		Hi(tempr):=EEPROM_Read(idx+1);
	INCF       tempidx_idx+0, 0
	MOVWF      FARG_EEPROM_Read_address+0
	CALL       _EEPROM_Read+0
	MOVF       R0+0, 0
	MOVWF      tempidx_tempr+1
;f675-fan-ctl.mpas,94 :: 		if tempr>r then
	MOVF       tempidx_tempr+1, 0
	SUBWF      FARG_tempidx_r+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__tempidx53
	MOVF       tempidx_tempr+0, 0
	SUBWF      FARG_tempidx_r+0, 0
L__tempidx53:
	BTFSC      STATUS+0, 0
	GOTO       L__tempidx20
;f675-fan-ctl.mpas,95 :: 		idx:=idx+2
	MOVLW      2
	ADDWF      tempidx_idx+0, 1
	GOTO       L__tempidx21
;f675-fan-ctl.mpas,96 :: 		else begin
L__tempidx20:
;f675-fan-ctl.mpas,97 :: 		break;
	GOTO       L__tempidx16
;f675-fan-ctl.mpas,98 :: 		end;
L__tempidx21:
;f675-fan-ctl.mpas,99 :: 		Inc(Result);
	INCF       tempidx_local_result+0, 1
;f675-fan-ctl.mpas,100 :: 		end;
	GOTO       L__tempidx15
L__tempidx16:
;f675-fan-ctl.mpas,101 :: 		end;
	MOVF       tempidx_local_result+0, 0
	MOVWF      R0+0
L_end_tempidx:
	RETURN
; end of _tempidx

_main:

;f675-fan-ctl.mpas,104 :: 		begin
;f675-fan-ctl.mpas,105 :: 		GPIO:=0;
	CLRF       GPIO+0
;f675-fan-ctl.mpas,106 :: 		NOT_GPPU_bit:=0;
	BCF        NOT_GPPU_bit+0, BitPos(NOT_GPPU_bit+0)
;f675-fan-ctl.mpas,107 :: 		WPU4_bit:=1;      // weak pullup for GP4
	BSF        WPU4_bit+0, BitPos(WPU4_bit+0)
;f675-fan-ctl.mpas,108 :: 		WPU5_bit:=1;
	BSF        WPU5_bit+0, BitPos(WPU5_bit+0)
;f675-fan-ctl.mpas,109 :: 		WPU2_bit:=1;
	BSF        WPU2_bit+0, BitPos(WPU2_bit+0)
;f675-fan-ctl.mpas,110 :: 		CMCON:=7;
	MOVLW      7
	MOVWF      CMCON+0
;f675-fan-ctl.mpas,111 :: 		ANSEL:=%00000001; // Analog channnel 1 only.
	MOVLW      1
	MOVWF      ANSEL+0
;f675-fan-ctl.mpas,112 :: 		TRISIO:=%11111011;
	MOVLW      251
	MOVWF      TRISIO+0
;f675-fan-ctl.mpas,118 :: 		PWM:=0;
	CLRF       _PWM+0
;f675-fan-ctl.mpas,119 :: 		LPWM:=0;
	CLRF       _LPWM+0
;f675-fan-ctl.mpas,120 :: 		PWM_State:=0;
	BCF        _PWM_State+0, BitPos(_PWM_State+0)
;f675-fan-ctl.mpas,121 :: 		TMR0:=0;
	CLRF       TMR0+0
;f675-fan-ctl.mpas,122 :: 		T0CS_bit:=0;
	BCF        T0CS_bit+0, BitPos(T0CS_bit+0)
;f675-fan-ctl.mpas,123 :: 		PSA_bit:=0;      // 1:8 prescale ~ 465Hz @ 4MHz
	BCF        PSA_bit+0, BitPos(PSA_bit+0)
;f675-fan-ctl.mpas,124 :: 		PS2_bit:=0;
	BCF        PS2_bit+0, BitPos(PS2_bit+0)
;f675-fan-ctl.mpas,125 :: 		PS0_bit:=0;
	BCF        PS0_bit+0, BitPos(PS0_bit+0)
;f675-fan-ctl.mpas,126 :: 		TMR0IE_bit:=1;
	BSF        TMR0IE_bit+0, BitPos(TMR0IE_bit+0)
;f675-fan-ctl.mpas,127 :: 		PEIE_bit:=1;
	BSF        PEIE_bit+0, BitPos(PEIE_bit+0)
;f675-fan-ctl.mpas,128 :: 		GIE_bit:=1;
	BSF        GIE_bit+0, BitPos(GIE_bit+0)
;f675-fan-ctl.mpas,130 :: 		while True do begin
L__main24:
;f675-fan-ctl.mpas,132 :: 		PWM_FLAG:=0;
	CLRF       _PWM_FLAG+0
;f675-fan-ctl.mpas,133 :: 		if PWM_75_0=1 then
	BTFSS      GP5_bit+0, BitPos(GP5_bit+0)
	GOTO       L__main29
;f675-fan-ctl.mpas,134 :: 		SetBit(PWM_FLAG,0);
	BSF        _PWM_FLAG+0, 0
L__main29:
;f675-fan-ctl.mpas,135 :: 		if PWM_50_0=1 then
	BTFSS      GP1_bit+0, BitPos(GP1_bit+0)
	GOTO       L__main32
;f675-fan-ctl.mpas,136 :: 		SetBit(PWM_FLAG,1);
	BSF        _PWM_FLAG+0, 1
L__main32:
;f675-fan-ctl.mpas,138 :: 		3: begin
	MOVF       _PWM_FLAG+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L__main37
;f675-fan-ctl.mpas,139 :: 		PWM_BASE:=CPWM_BASE_40;
	MOVLW      102
	MOVWF      _PWM_BASE+0
;f675-fan-ctl.mpas,140 :: 		PWM_INC:=CPWM_INC_40;
	MOVLW      59
	MOVWF      _PWM_INC+0
;f675-fan-ctl.mpas,141 :: 		end;
	GOTO       L__main34
L__main37:
;f675-fan-ctl.mpas,143 :: 		2: begin
	MOVF       _PWM_FLAG+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L__main40
;f675-fan-ctl.mpas,144 :: 		PWM_BASE:=CPWM_BASE_50;
	MOVLW      127
	MOVWF      _PWM_BASE+0
;f675-fan-ctl.mpas,145 :: 		PWM_INC:=CPWM_INC_50;
	MOVLW      50
	MOVWF      _PWM_INC+0
;f675-fan-ctl.mpas,146 :: 		end;
	GOTO       L__main34
L__main40:
;f675-fan-ctl.mpas,148 :: 		1: begin
	MOVF       _PWM_FLAG+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__main43
;f675-fan-ctl.mpas,149 :: 		PWM_BASE:=CPWM_BASE_75;
	MOVLW      192
	MOVWF      _PWM_BASE+0
;f675-fan-ctl.mpas,150 :: 		PWM_INC:=CPWM_INC_75;
	MOVLW      25
	MOVWF      _PWM_INC+0
;f675-fan-ctl.mpas,152 :: 		else begin
	GOTO       L__main34
L__main43:
;f675-fan-ctl.mpas,153 :: 		PWM_BASE:=CPWM_BASE_30;
	MOVLW      79
	MOVWF      _PWM_BASE+0
;f675-fan-ctl.mpas,154 :: 		PWM_INC:=CPWM_INC_30;
	MOVLW      68
	MOVWF      _PWM_INC+0
;f675-fan-ctl.mpas,155 :: 		end;
L__main34:
;f675-fan-ctl.mpas,158 :: 		rdata:=ADC_Read(0);
	CLRF       FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVF       R0+0, 0
	MOVWF      _rdata+0
	MOVF       R0+1, 0
	MOVWF      _rdata+1
;f675-fan-ctl.mpas,159 :: 		rreg:=VRES*rdata*10 div (1024-rdata) div 10;    // get resister
	MOVLW      0
	MOVWF      R0+2
	MOVWF      R0+3
	MOVLW      152
	MOVWF      R4+0
	MOVLW      8
	MOVWF      R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Mul_32x32_U+0
	MOVLW      10
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Mul_32x32_U+0
	MOVLW      0
	MOVWF      R12+0
	MOVLW      4
	MOVWF      R12+1
	CLRF       R12+2
	CLRF       R12+3
	MOVF       _rdata+0, 0
	MOVWF      R8+0
	MOVF       _rdata+1, 0
	MOVWF      R8+1
	CLRF       R8+2
	CLRF       R8+3
	MOVF       R12+0, 0
	MOVWF      R4+0
	MOVF       R12+1, 0
	MOVWF      R4+1
	MOVF       R12+2, 0
	MOVWF      R4+2
	MOVF       R12+3, 0
	MOVWF      R4+3
	MOVF       R8+0, 0
	SUBWF      R4+0, 1
	MOVF       R8+1, 0
	BTFSS      STATUS+0, 0
	INCFSZ     R8+1, 0
	SUBWF      R4+1, 1
	MOVF       R8+2, 0
	BTFSS      STATUS+0, 0
	INCFSZ     R8+2, 0
	SUBWF      R4+2, 1
	MOVF       R8+3, 0
	BTFSS      STATUS+0, 0
	INCFSZ     R8+3, 0
	SUBWF      R4+3, 1
	CALL       _Div_32x32_U+0
	MOVLW      10
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Div_32x32_U+0
	MOVF       R0+0, 0
	MOVWF      _rreg+0
	MOVF       R0+1, 0
	MOVWF      _rreg+1
	MOVF       R0+2, 0
	MOVWF      _rreg+2
	MOVF       R0+3, 0
	MOVWF      _rreg+3
;f675-fan-ctl.mpas,160 :: 		rtemp:=tempidx(LoWord(rreg));
	MOVF       _rreg+0, 0
	MOVWF      FARG_tempidx_r+0
	MOVF       _rreg+1, 0
	MOVWF      FARG_tempidx_r+1
	CALL       _tempidx+0
	MOVF       R0+0, 0
	MOVWF      _rtemp+0
;f675-fan-ctl.mpas,163 :: 		tpwm:=PWM_BASE+rtemp*PWM_INC div 10;
	MOVLW      0
	MOVWF      R0+1
	MOVF       _PWM_INC+0, 0
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Mul_16x16_U+0
	MOVLW      10
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Div_16x16_U+0
	MOVF       R0+0, 0
	ADDWF      _PWM_BASE+0, 0
	MOVWF      _tpwm+0
	MOVLW      0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      R0+1, 0
	MOVWF      _tpwm+1
;f675-fan-ctl.mpas,164 :: 		if Hi(tpwm)>0 then
	MOVF       _tpwm+1, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L__main45
;f675-fan-ctl.mpas,165 :: 		lo(tpwm):=CPWM_MAX;
	MOVLW      255
	MOVWF      _tpwm+0
L__main45:
;f675-fan-ctl.mpas,166 :: 		if lo(tpwm)>CPWM_MAX then
	MOVF       _tpwm+0, 0
	SUBLW      255
	BTFSC      STATUS+0, 0
	GOTO       L__main48
;f675-fan-ctl.mpas,167 :: 		lo(tpwm):=CPWM_MAX;
	MOVLW      255
	MOVWF      _tpwm+0
L__main48:
;f675-fan-ctl.mpas,168 :: 		PWM:=Lo(tpwm);
	MOVF       _tpwm+0, 0
	MOVWF      _PWM+0
;f675-fan-ctl.mpas,169 :: 		Delay_500us;
	CALL       _Delay_500us+0
;f675-fan-ctl.mpas,170 :: 		end;
	GOTO       L__main24
;f675-fan-ctl.mpas,171 :: 		end.
L_end_main:
	GOTO       $+0
; end of _main
