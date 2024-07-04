#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "LOCARG.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SiRetPer       ³Autor ³ Danilo Santos       ³Data³ 23/09/20 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³ Funcion de geracion del archivo SiretPer                   ³±±
±±º          ³ encargada de administrar las sucursales o no               ³±±
±±º          ³ dependiendo si se selecciona consolidado o no.             ³±±
±±º          ³ Argentina.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function SiRetPer(cDtIni,cDtFim,aCodTab,lEsCons,cArq,cTpArq)

Local nProcFil	:= 0
Local nPos := 0
Local nCanReg := 0
Local nPos			:= 0
Local nCanReg		:= 0
Local nX 			:= 0
Local cBkpFil		:= ""
Local cArqTrab := ""
Local aTabs   	:= {}
Local aRel			:= {}
Local nNumFil := 0
Local aProCEmp := {}


Default cDtIni := CTOD("  /  /    ")
Default cDtFim := CTOD("  /  /    ")
Default aCodTab := {}
Default lEsCons := .F.
Default cArq := ""
DEfault cTpArq := ""
	
cBkpFil:= cFilAnt
SiRPTrbs(cArq,@aTabs,lEsCons,cTpArq) // Cursores temporales y nombres fisicos de los archivos.

If  !lAglfil	 //Significa que sera consolidado y que hubo seleccion de Sucursales, Cambiar logico para que NO continue procesando filiales
	aRel := LcArgRP(cArq,cDtIni,cDtFim,aCodTab,,,lEsCons,cTpArq)				
ElseIf  lAglfil
 	aProCEmp := AClone(aFilsCalc)
	For nProcFil:=1 to len(aProCEmp)		 
		If aProCEmp[nProcFil,1] == .T.
			cFilAnt := aProCEmp[nProcFil,2] // cFilAnt es la variable global que indica en que sucursal estamos trabajando
			aRel := LcArgRP(cArq,cDtIni,cDtFim,aCodTab,,,lEsCons,cTpArq)
			For nNumFil:=1 to len(aProCEmp)
				aProCEmp[nNumFil,1] := .F.
			Next nNumFil		
		Endif		
	Next nProcFil	
Endif
cFilAnt := cBkpFil // Restaura Sucursal que se estaba utilizando

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³SiRPTrbs        ºAutor  ³ Danilo Santos   º Data ³  23/09/20   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³Montagem dos arquivos de trabalho.                             º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno³ExpA -> aTrbs - Array contendo alias abertos pela funcao       º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SiRPTrbs(cArq,aArTmp,lEsCons,cTpArq)
	Local cArqPer		:= ""//PERCEPCAO
	Local cArqRet		:= ""//RETENCAO
	Local Tab
	Local aOrdem  := {}
	Local aOrdem2 := {}
	Local aOrdem3 := {}
	Local aOrdem4 := {}
	
	Default lEsCons	:= .F.
	Default cTpArq	:= ""
	
	Private oTmpTable
	Private oTmpTable2
	Private oTmpTable3
	Private oTmpTable4
	Private oTmpTable5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao os arquivos de trabalho                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cArq =="SIRETPER"
		If cTpArq == "DATOS_R"
			cArqRet:="Retencion"
			aStrutRet:={}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Registro Regime de Retencion        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD(aStrutRet,{"FECHA"	    ,"C",008,0})
			AADD(aStrutRet,{"TIPODOC"	,"C",002,0})
			AADD(aStrutRet,{"DOC"	    ,"C",011,0})
			AADD(aStrutRet,{"TIPOCOMP"	,"C",002,0})
			AADD(aStrutRet,{"LETRA"	    ,"C",001,0})
			AADD(aStrutRet,{"NUMERO"	,"C",012,0})
			AADD(aStrutRet,{"MONTOIMP"	,"C",015,2})
			AADD(aStrutRet,{"ALICUOTA"	,"C",006,2})
			AADD(aStrutRet,{"MONTORET"	,"C",015,2})
			//AADD(aStrutPer,{"NINGBRU"	,"C",011,0})
			//
			//Creacion de Objeto DATOS_R 
			oTmpTable := FWTemporaryTable():New("DATOSR") 
			oTmpTable:SetFields( aStrutRet ) 
	
			aOrdem	:=	{"FECHA","TIPODOC","DOC"} 
	
			oTmpTable:AddIndex("IND1", aOrdem) 
	
			oTmpTable:Create() 	
		ElseIf cTpArq == "DATOS_P"
			cArqPer:="Percepcion"
			aStrutPer:={}
			AADD(aStrutPer,{"FECHA"    ,"C",008,0})
			AADD(aStrutPer,{"TIPODOC"  ,"C",002,0})
			AADD(aStrutPer,{"DOC"      ,"C",011,0})
			AADD(aStrutPer,{"TIPOCOMP" ,"C",002,0})
			AADD(aStrutPer,{"LETRA"    ,"C",001,0})
			AADD(aStrutPer,{"TERMINAL" ,"C",004,0})
			AADD(aStrutPer,{"NUMERO"   ,"C",008,0})
			AADD(aStrutPer,{"MONTOIMP" ,"C",015,0})
			AADD(aStrutPer,{"ALICUOTA" ,"C",006,0})
			AADD(aStrutPer,{"MONTORET" ,"C",015,0})
			
			//Creacion de Objeto DATOS_P 
			oTmpTable2 := FWTemporaryTable():New("DATOSP") 
			oTmpTable2:SetFields( aStrutPer ) 
		
			aOrdem2	:=	{"FECHA","TIPODOC","DOC"} 
		
			oTmpTable2:AddIndex("IN2", aOrdem2) 
		
			oTmpTable2:Create()
		
		ElseIf cTpArq == "RETPER_R"
			cArqPer:="Retencion"
			aStrRtPrr:={}
			
			AADD(aStrRtPrr,{"CTIPODOC"  ,"C",002,0})
			AADD(aStrRtPrr,{"DOC"       ,"C",011,0})
			AADD(aStrRtPrr,{"TIPBRE"    ,"C",040,0})
			AADD(aStrRtPrr,{"DOMICILIO" ,"C",040,0})
			AADD(aStrRtPrr,{"PUERTA"    ,"C",005,0})
			AADD(aStrRtPrr,{"LOCALIDAD" ,"C",015,0})
			AADD(aStrRtPrr,{"PROVINCIA" ,"C",015,0})
			AADD(aStrRtPrr,{"NINGBRU"   ,"C",011,0})
			AADD(aStrRtPrr,{"C_POSTAL"  ,"C",008,0})
			
			//Creacion de Objeto RETPER_R 
			oTmpTable3 := FWTemporaryTable():New("RETPERR") 
			oTmpTable3:SetFields( aStrRtPrr ) 
		
			aOrdem3	:=	{"CTIPODOC","DOC"} 
			
			oTmpTable3:AddIndex("IND", aOrdem3) 
			oTmpTable3:Create()
			
		ElseIf cTpArq == "RETPER_P"
			cArqPer:="Percepcion"
			aStrRtPrp:={}
			
			AADD(aStrRtPrp,{"TIPODOC"   ,"C",002,0})
			AADD(aStrRtPrp,{"DOC"       ,"C",011,0})
			AADD(aStrRtPrp,{"NOMBRE"    ,"C",040,0})
			AADD(aStrRtPrp,{"DOMICILIO" ,"C",040,0})
			AADD(aStrRtPrp,{"PUERTA"    ,"C",005,0})
			AADD(aStrRtPrp,{"LOCALIDAD" ,"C",015,0})
			AADD(aStrRtPrp,{"PROVINCIA" ,"C",015,0})
			AADD(aStrRtPrp,{"NINGBRU"   ,"C",011,0})
			AADD(aStrRtPrp,{"C_POSTAL"  ,"C",008,0})
			
			//Creacion de Objeto RETPER_P 
			oTmpTable4 := FWTemporaryTable():New("RETPERP") 
			oTmpTable4:SetFields( aStrRtPrp ) 
		
			aOrdem4	:=	{"TIPODOC","DOC"} 
			
			oTmpTable4:AddIndex("IND", aOrdem4) 
			oTmpTable4:Create()
		Endif
	Endif
Return

 /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³LcArgRP    º Autor ³                        º Data ³  23/09/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Montagem das informacoes arquivo magnetico                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LcArgRP(cArquivo,cDtIni,cDtFim,aCodTab,lConfirm,aArTmp,lEsCons,cTpArq)

	Local lOk       :=.T.
	Local lPer	    :=.T.
	Local lRet	    :=.T.
	Local aLogReg   :={}
	Local cFchPri := ""
	Local cTRBRET := ""
	Local cPerini := Substr(cDtIni,1,4) + Substr(cDtIni,5,2) + "01" // Inicio de periodo 
	Local cPerfin := Substr(cDtIni,1,4) + Substr(cDtIni,5,2) + StaticCall( Locarg, UltDiaMes,0,0,cDtIni)  // Fin de periodo 
	Local cQrySf3	:= ""
	Local nTpAliq  := 0
	Local nSinal := 1
	Local nAliq     := ""    
	Local cTpRecaud := "" 
	Local lGetDB   := AllTrim(Upper(TCGetDB())) $ "ORACLE|POSTGRES"  //.T. - Oracle, .F. - Otros manejadores
	Local aAreaAt:=GetArea()
	Local nQtdFil:= 0
	Local nImp := 0
	Local nProsFil := 0
	Local nPrcFil  := 0
	Local cNumCer := ""
	Local nBasAcm:= 0
	Local nRetAcm := 0 

	Default aCodTab :={}
	Default lConfirm:= .T.
	Default aArTmp  := {}
	Default lEsCons := .F.
	Default cTpArq  := ""

	If  IIf(UPPER(cArquivo)$"SIRETPER",Iif(!lEsCons,.T.,.F.),.T.)
		Aadd(aLogreg,Replicate("-",80))
		Aadd(aLogreg,STR0001)//"Parametros"
		Aadd(aLogreg,Replicate("=",80))
	EndIf 
		
	If UPPER(cArquivo)$"SIRETPER"

		If cTpArq $"DATOS_P"					
			//========================================================================================================================
			//PERCEPCAO
			//========================================================================================================================
			cTRBPER  := ""
			cQryPer := ""	
			cQryPer += " SELECT * FROM "+  InitSqlName("SF3") + "  SF3"
			cQryPer += " WHERE "
			cQryPer += " F3_EMISSAO>= '" + cPerini + "' " 
			cQryPer += " AND F3_EMISSAO<= '" + cPerfin + "' "
			
			If MV_PAR06 == 1 .And. MV_PAR07 == 1  .And.  SF3->(ColumnPos('F3_MSFIL'))>0 .And.  !Empty(SF3->F3_MSFIL)
				For nProsFil:=1 to len(aFilsCalc)		 
					If  aFilsCalc[nProsFil,1] == .T.								
						IF nQtdFil==0				
							cQryPer+=" AND( F3_MSFIL = '"+aFilsCalc[nProsFil][2]+"' "
							nQtdFil:= nQtdFil+1									
						Else
							cQryPer+=" OR F3_MSFIL = '"+aFilsCalc[nProsFil][2]+"' "
						EndIf							
					EndIf
				Next nProsFil	
				cQryPer+=")"
			Elseif MV_PAR06 == 1 .And. MV_PAR07 == 1  .And. !SF3->(ColumnPos('F3_MSFIL'))>0
					For nProsFil:=1 to len(aFilsCalc)		 
					If aFilsCalc[nProsFil,1] == .T.								
						IF nQtdFil==0				
							cQryPer+=" AND( F3_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
							nQtdFil:= nQtdFil+1									
						Else
							cQryPer+=" OR F3_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
						EndIf							
					EndIf
				Next nProsFil	
				cQryPer+=")"						
			Elseif MV_PAR06 == 1 .and. MV_PAR07 == 2 .And.  SF3->(ColumnPos('F3_MSFIL'))>0 .And.  !Empty(SF3->F3_MSFIL)
					
				cQryPer+=" AND F3_MSFIL = '"+ cfilant +"' "
			Elseif  SF3->(ColumnPos('F3_MSFIL'))>0 .And.  !Empty(SF3->F3_MSFIL) 
				cQryPer+=" AND F3_MSFIL = '"+FWCODFIL()+"' "
			Else		
				cQryPer+=" AND F3_FILIAL = '" + xFilial("SF3") + "' "
			EndIf

			cQryPer += " AND F3_VALIMP" + _aTotal[96] + " > 0 "
			cQryPer += " AND (F3_TIPOMOV = 'V' "
			cQryPer += " OR F3_ESPECIE ='NDI' "
			cQryPer += " OR F3_ESPECIE ='NCI') "
			cQryPer += " AND SF3.D_E_L_E_T_=' ' "
			cQryPer += " ORDER BY F3_FILIAL, 
			cQryPer += " F3_CLIEFOR," 
			cQryPer += " F3_LOJA," 
			cQryPer += " F3_NFISCAL," 
			cQryPer += " F3_SERIE"


			If Select("TEMPPER")>0
				DbSelectArea("TEMPPER")
				TEMPRET->(DbCloseArea())
			EndIf
			
			cTRBPER := ChangeQuery(cQryPer)
			dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBPER ) ,"TEMPPER", .T., .F.)
						
			DbSelectArea("TEMPPER")
			TEMPPER->(dbGoTop())
			
			Aadd(aLogreg,Replicate("=",80))
			Aadd(aLogreg,STR0016+" "+cTpArq)//"PERCEPCAO"
			Aadd(aLogreg,Replicate("=",80))

			nImp := 0

			Do While TEMPPER->(!Eof()) //.And. lOk
				nImp ++				
				If (TEMPPER->F3_TIPO == "C" .or. Alltrim(TEMPPER->F3_ESPECIE)$'NDI|NCI') 
					SA2->(DbSeek (xFilial ("SA2")+TEMPPER->F3_CLIEFOR+TEMPPER->F3_LOJA))
					_aTotal[03]:=.T. 
				ElseIF (TEMPPER->F3_TIPO == "N" .or. Alltrim(TEMPPER->F3_ESPECIE)$'NF')	
					SA1->(DbSeek (xFilial ("SA1")+TEMPPER->F3_CLIEFOR+TEMPPER->F3_LOJA))
					_aTotal[03]:=.T.
				Endif
				If (TEMPPER->F3_TIPO == "C" .or. Alltrim(TEMPPER->F3_ESPECIE)$'NDI|NCI')	
					_aTotal[05] := SA2->A2_CGC 
				ElseIf (TEMPPER->F3_TIPO == "N" .or. Alltrim(TEMPPER->F3_ESPECIE)$'NF')
					_aTotal[05] := SA1->A1_CGC 
				EndIf

				_aTotal[07] := TipDocTU(Alltrim(  SerieNfId("SF3",2,"F3_SERIE")  ),TEMPPER->F3_ESPECIE)
				_aTotal[31] := Iif (_aTotal[03], SA2->A2_NIGB, SA1->A1_NIGB)
										
				DbSelectArea("DATOSP")
				DATOSP->(dbSetOrder(1))
				DATOSP->(dbGoTop())
					
				If RecLock("DATOSP",.T.)
					DATOSP->FECHA     := TEMPPER->F3_ENTRADA					
					If (TEMPPER->F3_TIPO == "C" .or. Alltrim(TEMPPER->F3_ESPECIE)$'NDI|NCI')
						If Empty(SA2->A2_AFIP)
							DATOSP->TIPODOC   := "80"
						Else  
							DATOSP->TIPODOC   := Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + SA2->A2_AFIP,"X5_DESCSPA"),1,2)
						EndIf
					Elseif (TEMPPER->F3_TIPO == "N" .or. Alltrim(TEMPPER->F3_ESPECIE)$'NF|NCC|NDC')
						If Empty(SA1->A1_AFIP)
							DATOSP->TIPODOC   := "80"
						Else
							DATOSP->TIPODOC   := Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + SA1->A1_AFIP,"X5_DESCSPA"),1,2)
						EndIf
					EndIf	 
					DATOSP->DOC       := Replicate("0",11-Len(Alltrim(_aTotal[05]))) + _aTotal[05]
					DATOSP->TIPOCOMP  := Replicate("0",2-Len(Alltrim(_aTotal[07]))) + _aTotal[07]
					DATOSP->LETRA     := Substr( SerieNfId("SF3",2,"F3_SERIE") ,1,1)
					DATOSP->TERMINAL  := IIf(Len(TEMPPER->F3_NFISCAL)== 12 , Substr(TEMPPER->F3_NFISCAL,1,4), Substr(TEMPPER->F3_NFISCAL,1,5))
					DATOSP->NUMERO    := Replicate("0",8-Len(AllTrim(Substr(TEMPPER->F3_NFISCAL,5,TamSX3("F3_NFISCAL")[1]-4))))+Substr(TEMPPER->F3_NFISCAL,5,TamSX3("F3_NFISCAL")[1]-4)
					DATOSP->MONTOIMP  := STRZERO(Iif ( "NC"$ TEMPPER->F3_ESPECIE , -1*&("TEMPPER->F3_BASIMP"+_aTotal[96]) , &("TEMPPER->F3_BASIMP"+_aTotal[96]) ),15,2)
					DATOSP->ALICUOTA  := STRZERO(&("TEMPPER->F3_ALQIMP"+_aTotal[96]),6,3)
					DATOSP->MONTORET  := STRZERO(Iif ( "NC"$ TEMPPER->F3_ESPECIE, -1*&("TEMPPER->F3_VALIMP"+_aTotal[96]) , &("TEMPPER->F3_VALIMP"+_aTotal[96]) ),15,2)
					//DATOS_R->NINGBRU :=  Replicate("0",11-Len(Alltrim(_aTotal[31]))) + _aTotal[31]	
					DATOSP->(MsUnlock())
				EndIf
				TEMPPER->(DbSkip())
				Loop
			Enddo																															
			TEMPPER->(DbClosearea())
			
		ElseIf cTpArq $"DATOS_R" 
			//========================================================================================================================
			//RETENCAO
			//========================================================================================================================
			cTRBRET := ""
			cQryRet := ""
			cQryRet += "SELECT * FROM " + InitSqlName("SFE") + "  SFE"
			cQryRet += " WHERE FE_FORNECE <> '' "
			
			If MV_PAR06 == 1 .And. MV_PAR07 == 1  .And.  SFE->(ColumnPos('FE_MSFIL'))>0 .And.  !Empty(SFE->FE_MSFIL)
				For nProsFil:=1 to len(aFilsCalc)		 
					If  aFilsCalc[nProsFil,1] == .T.								
						IF nQtdFil==0				
							cQryRet+=" AND( FE_MSFIL = '"+aFilsCalc[nProsFil][2]+"' "
							nQtdFil:= nQtdFil+1									
						Else
							cQryRet+=" OR FE_MSFIL = '"+aFilsCalc[nProsFil][2]+"' "
						EndIf							
					EndIf
				Next nProsFil	
				cQryRet+=")"
			Elseif MV_PAR06 == 1 .And. MV_PAR07 == 1  .And. !SFE->(ColumnPos('FE_MSFIL'))>0
					For nProsFil:=1 to len(aFilsCalc)		 
					If aFilsCalc[nProsFil,1] == .T.								
						IF nQtdFil==0				
							cQryRet+=" AND( FE_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
							nQtdFil:= nQtdFil+1									
						Else
							cQryRet+=" OR FE_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
						EndIf							
					EndIf
				Next nProsFil	
				cQryRet+=")"						
			Elseif MV_PAR06 == 1 .and. MV_PAR07 == 2 .And.  SFE->(ColumnPos('FE_MSFIL'))>0 .And.  !Empty(SFE->FE_MSFIL)
					
				cQryRet+=" AND FE_MSFIL = '"+cfilant+"' "
			Elseif  SFE->(ColumnPos('FE_MSFIL'))>0 .And.  !Empty(SFE->FE_MSFIL) 
				cQryRet+=" AND FE_MSFIL = '"+FWCODFIL()+"' "
			Else		
				cQryRet+=" AND FE_FILIAL = '"+xFilial("SFE")+"' "
			EndIf
			
			cQryRet += " AND FE_EMISSAO>= '" + cPerini + "' "
			cQryRet += " AND FE_EMISSAO<= '" + cPerfin + "' "
			cQryRet	+= " AND ( FE_DTESTOR < '" + cPerini + "' Or" 
			cQryRet	+= " FE_DTESTOR > '" + cPerfin + "' Or" 
			cQryRet	+= " FE_DTESTOR = ' ' Or"
			cQryRet	+= " FE_NRETORI <> ' '"
			cQryRet	+= " ) And ( "
			cQryRet	+= " FE_DTRETOR < '" + cPerini + "' Or"
			cQryRet	+= " FE_DTRETOR > '" + cPerfin + "' Or"
			cQryRet	+= " FE_DTRETOR = ' ' Or"
			cQryRet	+= " FE_NRETORI = ' ' )"
			cQryRet += " AND FE_TIPO ='B'"
			cQryRet += " AND FE_EST = 'TU'"
			cQryRet += " AND SFE.D_E_L_E_T_=' '"
			cQryRet += " ORDER BY FE_FILIAL,"
			cQryRet += " FE_NROCERT,"
			cQryRet += " FE_ITEM "				

			If Select("TEMPRET")>0
				DbSelectArea("TEMPRET")
				TEMPRET->(DbCloseArea())
			EndIf
			cTRBRET := ChangeQuery(cQryRet)
			dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBRET ) ,"TEMPRET", .T., .F.)
			
			DbSelectArea("TEMPRET")
			TEMPRET->(dbGoTop())	
			If TEMPRET->(!Eof())
				Aadd(aLogreg,Replicate("=",80))
				Aadd(aLogreg,STR0016+" "+cTpArq)//RETENCAO
				Aadd(aLogreg,Replicate("=",80))
				nImp := 0
				Do While TEMPRET->(!Eof()) //.And. lOk
					nImp ++
					//(!Empty(SFE->FE_FORNECE))
					_aTotal[08] := (!Empty(TEMPRET->FE_FORNECE))
					If _aTotal[08]
						SA2->(DbSeek (xFilial ("SA2")+TEMPRET->FE_FORNECE+TEMPRET->FE_LOJA))
					Else 
						SA1->(DbSeek (xFilial ("SA1")+TEMPRET->FE_CLIENTE+TEMPRET->FE_LOJCLI))
					Endif	
					_aTotal[09] := Iif (_aTotal[08], SA2->A2_CGC, SA1->A1_CGC)
					_aTotal[31] := Iif (_aTotal[08], SA2->A2_NIGB, SA1->A1_NIGB)
					_aTotal[75] := (TamSX3("FE_NROCERT")[1])- 11
					_aTotal[75] := IIf(_aTotal[75]>0,_aTotal[75],1)
					_aTotal[76] := Subs(TEMPRET->FE_NROCERT,_aTotal[75],12)					
					
					DbSelectArea("DATOSR")					
					If cNumCer <> Alltrim(_aTotal[76])
						nBasAcm := TEMPRET->FE_VALBASE 
						nRetAcm := TEMPRET->FE_RETENC 
						If RecLock("DATOSR",.T.)						    
							DATOSR->FECHA     := TEMPRET->FE_EMISSAO
							DATOSR->TIPODOC   := Iif (Empty(Iif (_aTotal[08], SA2->A2_AFIP, SA1->A1_AFIP)),"80",STRZERO(VAL(Iif (_aTotal[08],Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + SA2->A2_AFIP,"X5_DESCSPA"),1,2),Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + SA1->A1_AFIP,"X5_DESCSPA"),1,2))),2) ) 
							DATOSR->DOC       := Replicate("0",11-Len(Alltrim(_aTotal[09]))) + _aTotal[09]
							DATOSR->TIPOCOMP  := "99"
							DATOSR->LETRA     := " "
							DATOSR->NUMERO    := Replicate("0",12-Len(AllTrim(_aTotal[76])))+Alltrim(_aTotal[76])
							DATOSR->MONTOIMP  := STRZERO(Iif ( SF3->F3_TIPO == "D" , -1*TEMPRET->FE_VALBASE , TEMPRET->FE_VALBASE ),15,2)
							DATOSR->ALICUOTA  := STRZERO(TEMPRET->FE_ALIQ,6,3)
							DATOSR->MONTORET  := STRZERO(Iif ( SF3->F3_TIPO == "D" , -1*TEMPRET->FE_RETENC , TEMPRET->FE_RETENC ),15,2)					
							//DATOS_R->NINGBRU    C 011 0 Replicate("0",11-Len(Alltrim(_aTotal[31]))) + _aTotal[31]	
							DATOSR->(MsUnlock())
						EndIf
					Else
						nBasAcm +=  TEMPRET->FE_VALBASE
						nRetAcm += TEMPRET->FE_RETENC						 
						If RecLock("DATOSR",.F.)						
							DATOSR->MONTOIMP  := STRZERO(nBasAcm ,15,2)					   
							DATOSR->MONTORET  := STRZERO(nRetAcm ,15,2)
							DATOSR->(MsUnlock())  												
						EndIf								
					EndIf										 					 					    
					TEMPRET->(DbSkip())
					cNumCer:= Alltrim(_aTotal[76])				
					Loop					
				End
				TEMPRET->(DbClosearea())
			EndIf
		
		ElseIf cTpArq $"RETPER_R"
			//========================================================================================================================
			//RETENCAO
			//========================================================================================================================
			cTRBRET := ""
			cQryRet := ""
			cQryRet += " SELECT FE_FORNECE, FE_LOJA, FE_CLIENTE, FE_LOJCLI "
			cQryRet += " FROM " + InitSqlName("SFE") + "  SFE"//FROM SFE990
			cQryRet += " WHERE FE_FORNECE <> ' ' "
			
			If MV_PAR06 == 1 .And. MV_PAR07 == 1  .And.  SFE->(ColumnPos('FE_MSFIL'))>0 .And.  !Empty(SFE->FE_MSFIL)
				For nProsFil:=1 to len(aFilsCalc)		 
					If  aFilsCalc[nProsFil,1] == .T.								
						IF nQtdFil==0				
							cQryRet+=" AND( FE_MSFIL = '"+aFilsCalc[nProsFil][2]+"' "
							nQtdFil:= nQtdFil+1									
						Else
							cQryRet+=" OR FE_MSFIL = '"+aFilsCalc[nProsFil][2]+"' "
						EndIf							
					EndIf
				Next nProsFil	
				cQryRet+=")"
			Elseif MV_PAR06 == 1 .And. MV_PAR07 == 1  .And. !SFE->(ColumnPos('FE_MSFIL'))>0
					For nProsFil:=1 to len(aFilsCalc)		 
					If aFilsCalc[nProsFil,1] == .T.								
						IF nQtdFil==0				
							cQryRet+=" AND( FE_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
							nQtdFil:= nQtdFil+1									
						Else
							cQryRet+=" OR FE_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
						EndIf							
					EndIf
				Next nProsFil	
				cQryRet+=")"						
			Elseif MV_PAR06 == 1 .and. MV_PAR07 == 2 .And.  SFE->(ColumnPos('FE_MSFIL'))>0 .And.  !Empty(SFE->FE_MSFIL)
					
				cQryRet+=" AND FE_MSFIL = '"+cfilant+"' "
			Elseif  SFE->(ColumnPos('FE_MSFIL'))>0 .And.  !Empty(SFE->FE_MSFIL) 
				cQryRet+=" AND FE_MSFIL = '"+FWCODFIL()+"' "
			Else		
				cQryRet+=" AND FE_FILIAL = '"+xFilial("SFE")+"' "
			EndIf
			
			cQryRet += " AND FE_EMISSAO>='" + cPerini + "' "
			cQryRet += " AND FE_EMISSAO<='" + cPerfin + "' "
			cQryRet	+= " AND ( FE_DTESTOR < '" + cPerini + "' Or" 
			cQryRet	+= " FE_DTESTOR > '" + cPerfin + "' Or" 
			cQryRet	+= " FE_DTESTOR = ' ' Or"
			cQryRet	+= " FE_NRETORI <> ' '"
			cQryRet	+= " ) And ( "
			cQryRet	+= " FE_DTRETOR < '" + cPerini + "' Or"
			cQryRet	+= " FE_DTRETOR > '" + cPerfin + "' Or"
			cQryRet	+= " FE_DTRETOR = ' ' Or"
			cQryRet	+= " FE_NRETORI = ' ' )"
			cQryRet += " AND FE_TIPO ='B' " 
			cQryRet += " AND FE_EST = 'TU' "
			cQryRet += " AND SFE.D_E_L_E_T_=' ' "
			cQryRet += " GROUP BY FE_FORNECE, "
			cQryRet += "FE_LOJA,FE_CLIENTE,FE_LOJCLI"
			         
			If Select("TEMPRTPR")>0
				DbSelectArea("TEMPRTPR")
				TEMPRTPR->(DbCloseArea())
			EndIf
			
			cTRBRET := ChangeQuery(cQryRet)
			dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBRET ) ,"TEMPRTPR", .T., .F.)	

			DbSelectArea("TEMPRTPR")
			TEMPRTPR->(dbGoTop())	
			If TEMPRTPR->(!Eof())
				Aadd(aLogreg,Replicate("=",80))
				Aadd(aLogreg,STR0016+" "+cTpArq)//RETENCAO
				Aadd(aLogreg,Replicate("=",80))
				nImp := 0
				Do While TEMPRTPR->(!Eof()) //.And. lOk
					nImp ++
					_aTotal[20] := (!Empty(TEMPRTPR->FE_FORNECE))
					If _aTotal[20]  
						SA2->(DbSeek (xFilial ("SA2")+TEMPRTPR->FE_FORNECE+TEMPRTPR->FE_LOJA))
					Else
						SA1->(DbSeek (xFilial ("SA1")+TEMPRTPR->FE_CLIENTE+TEMPRTPR->FE_LOJCLI))
					Endif
					_aTotal[21] := Iif (_aTotal[20], SA2->A2_CGC, SA1->A1_CGC)
					_aTotal[22] := Iif (_aTotal[20], SA2->A2_NOME, SA1->A1_NOME)
					_aTotal[23] := Iif (_aTotal[20], SA2->A2_END, SA1->A1_END)
					_aTotal[24] := Iif (_aTotal[20], SA2->A2_MUN, SA1->A1_MUN)
					_aTotal[26] := Iif (_aTotal[20], SA2->A2_CX_POST, SA1->A1_CXPOSTA)
					_aTotal[31] := Iif (_aTotal[20], SA2->A2_NIGB, SA1->A1_NIGB)
					_aTotal[88] := Len(_aTotal[87])
					
					DbSelectArea("RETPERR")
					RETPERR->(dbSetOrder(1))
					RETPERR->(dbGoTop())
					
					If RecLock("RETPERR",.T.)
						RETPERR->CTIPODOC  := Iif (Empty(Iif (_aTotal[20], SA2->A2_AFIP, SA1->A1_AFIP)),"80",STRZERO(VAL(Iif (_aTotal[20], Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + SA2->A2_AFIP,"X5_DESCSPA"),1,2), Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + SA1->A1_AFIP,"X5_DESCSPA"),1,2))),2) ) 
						RETPERR->DOC       := Replicate("0",11-Len(Alltrim(_aTotal[21]))) + _aTotal[21] 
						RETPERR->TIPBRE    := _aTotal[22]
						RETPERR->DOMICILIO := Substr( _aTotal[23], 1, Iif(At(",",_aTotal[23]) > 2,At(",",_aTotal[23])-1,40) )
						RETPERR->PUERTA    := Replicate("0",5-Len(Alltrim(Str(_aTotal[19])))) + AllTrim(Str(_aTotal[19]))
						RETPERR->LOCALIDAD := _aTotal[24]
					    SX5->(DbSeek (xFilial("SX5")+"12"+Iif (_aTotal[20], SA2->A2_EST, SA1->A1_EST)))
						RETPERR->PROVINCIA := X5Descri()
						RETPERR->NINGBRU   := Space(11)
						RETPERR->C_POSTAL  := Space(8-len(Alltrim(_aTotal[26]))) + _aTotal[26]				
						RETPERR->(MsUnlock())
					EndIf
					TEMPRTPR->(DbSkip())
					Loop
				End
				TEMPRTPR->(DbClosearea())
			EndIf

		ElseIf cTpArq $"RETPER_P"
			cTRBPER  := ""
			cQryPer := ""
			cQryPer += " SELECT F3_TIPOMOV, F3_CLIEFOR, F3_LOJA, F3_ESPECIE "
			cQryPer += " FROM "  + InitSqlName("SF3") + "  SF3"//SF3
			cQryPer += " WHERE F3_EMISSAO>='" + cPerini + "' "
			cQryPer += " AND F3_EMISSAO<='" + cPerfin + "' "
			If MV_PAR06 == 1 .And. MV_PAR07 == 1  .And.  SF3->(ColumnPos('F3_MSFIL'))>0 .And.  !Empty(SF3->F3_MSFIL)
				For nProsFil:=1 to len(aFilsCalc)		 
					If  aFilsCalc[nProsFil,1] == .T.								
						IF nQtdFil==0				
							cQryPer+=" AND( F3_MSFIL = '"+aFilsCalc[nProsFil][2]+"' "
							nQtdFil:= nQtdFil+1									
						Else
							cQryPer+=" OR F3_MSFIL = '"+aFilsCalc[nProsFil][2]+"' "
						EndIf							
					EndIf
				Next nProsFil	
				cQryPer+=")"
			Elseif MV_PAR06 == 1 .And. MV_PAR07 == 1  .And. !SF3->(ColumnPos('F3_MSFIL'))>0
					For nProsFil:=1 to len(aFilsCalc)		 
					If aFilsCalc[nProsFil,1] == .T.								
						IF nQtdFil==0				
							cQryPer+=" AND( F3_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
							nQtdFil:= nQtdFil+1									
						Else
							cQryPer+=" OR F3_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
						EndIf							
					EndIf
				Next nProsFil	
				cQryPer+=")"						
			Elseif MV_PAR06 == 1 .and. MV_PAR07 == 2 .And.  SF3->(ColumnPos('F3_MSFIL'))>0 .And.  !Empty(SF3->F3_MSFIL)
					
				cQryPer+=" AND F3_MSFIL = '"+cfilant+"' "
			Elseif  SFE->(ColumnPos('F3_MSFIL'))>0 .And.  !Empty(SF3->F3_MSFIL) 
				cQryPer+=" AND F3_MSFIL = '"+FWCODFIL()+"' "
			Else		
				cQryPer+=" AND F3_FILIAL = '"+xFilial("SF3")+"' "
			EndIf
			cQryPer += " AND F3_VALIMP" + _aTotal[96] + " > 0 "
			cQryPer += " AND (F3_TIPOMOV = 'V' "
			cQryPer += " OR F3_ESPECIE ='NDI' "
			cQryPer += " OR F3_ESPECIE ='NCI') "
			cQryPer += " AND SF3.D_E_L_E_T_=' ' "
			cQryPer += " GROUP BY F3_TIPOMOV, "
			cQryPer += " F3_CLIEFOR, "
			cQryPer += " F3_LOJA, "
			cQryPer += " F3_ESPECIE "
			
			If Select("TEMPRTPP")>0
				DbSelectArea("TEMPRTPP")
				TEMPRTPP->(DbCloseArea())
			EndIf
			
			cTRBPER := ChangeQuery(cQryPer)
			dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBPER ) ,"TEMPRTPP", .T., .F.)	

			DbSelectArea("TEMPRTPP")
			TEMPRTPP->(dbGoTop())	
			If TEMPRTPP->(!Eof())
			
				Aadd(aLogreg,Replicate("=",80))
				Aadd(aLogreg,STR0016+" "+cTpArq)//Percepcion
				Aadd(aLogreg,Replicate("=",80))
				nImp := 0
				Do While TEMPRTPP->(!Eof())
					nImp ++					
					If (TEMPRTPP->F3_TIPOMOV == "C" .or. Alltrim(TEMPRTPP->F3_ESPECIE)$'NDI|NCI') 
						SA2->(DbSeek (xFilial ("SA2")+TEMPRTPP->F3_CLIEFOR+TEMPRTPP->F3_LOJA))
						_aTotal[12] :=.T.
					ElseIf (TEMPRTPP->F3_TIPOMOV == "N" .or. Alltrim(TEMPRTPP->F3_ESPECIE)$'NF')
						SA1->(DbSeek (xFilial ("SA1")+TEMPRTPP->F3_CLIEFOR+TEMPRTPP->F3_LOJA))
						_aTotal[12] :=.T.
					Endif
					If (TEMPRTPP->F3_TIPOMOV == "C" .or. Alltrim(TEMPRTPP->F3_ESPECIE)$'NDI|NCI')
						_aTotal[13] := SA2->A2_CGC
						_aTotal[14] := SA2->A2_NOME
						_aTotal[15] := SA2->A2_END
						_aTotal[16] := SA2->A2_MUN
						_aTotal[18] := SA2->A2_CX_POST
						_aTotal[31] := SA2->A2_NIGB
						_aTotal[88] := Len(_aTotal[87])
						SX5->(DbSeek (xFilial("SX5")+"12"+SA2->A2_EST))
					ElseIf (TEMPRTPP->F3_TIPOMOV $ "N|V" .or. Alltrim(TEMPRTPP->F3_ESPECIE)$'NF')
						_aTotal[13] := SA1->A1_CGC
						_aTotal[14] := SA1->A1_NOME
						_aTotal[15] := SA1->A1_END
						_aTotal[16] := SA1->A1_MUN
						_aTotal[18] := SA1->A1_CXPOSTA
						_aTotal[31] := SA1->A1_NIGB
						_aTotal[88] := Len(_aTotal[87])
						SX5->(DbSeek (xFilial("SX5")+"12"+SA1->A1_EST))
					EndIf			
			
					DbSelectArea("RETPERP")
					RETPERP->(dbSetOrder(1))
					RETPERP->(dbGoTop())
					
					If RecLock("RETPERP",.T.)						
						If (TEMPRTPP->F3_TIPOMOV == "C" .or. Alltrim(TEMPRTPP->F3_ESPECIE)$'NDI|NCI')
							If Empty(SA2->A2_AFIP)
								RETPERP->TIPODOC   := "80"
							Else
								RETPERP->TIPODOC   := Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + SA2->A2_AFIP,"X5_DESCSPA"),1,2)
							EndIf	
							SX5->(DbSeek (xFilial("SX5")+"12"+SA2->A2_EST))
							RETPERP->PROVINCIA := X5Descri()
						ElseIf (TEMPRTPP->F3_TIPOMOV $ "N|V" .or. Alltrim(TEMPRTPP->F3_ESPECIE)$'NF')
							If Empty(SA1->A1_AFIP)
								RETPERP->TIPODOC   := "80"
							Else
								RETPERP->TIPODOC   := Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + SA1->A1_AFIP,"X5_DESCSPA"),1,2)
							EndIf							
							SX5->(DbSeek (xFilial("SX5")+"12"+SA1->A1_EST))
							RETPERP->PROVINCIA := X5Descri()
						EndIf
						RETPERP->DOC       := Replicate("0",11-Len(Alltrim(_aTotal[13]))) + _aTotal[13] 
						RETPERP->NOMBRE    := _aTotal[14]
						RETPERP->DOMICILIO := Substr(_aTotal[15], 1, Iif(At(",",_aTotal[15]) > 2,At(",",_aTotal[15])-1,40) )
						RETPERP->PUERTA    := Replicate("0",5-Len(Alltrim(Str(_aTotal[19])))) + AllTrim(Str(_aTotal[19]))
						RETPERP->LOCALIDAD := _aTotal[16]
						RETPERP->NINGBRU   := Space(11)
						RETPERP->C_POSTAL  := Space(4) + _aTotal[18]				
						RETPERP->(MsUnlock())
					EndIf
					TEMPRTPP->(DbSkip())
					Loop
				End
				TEMPRTPP->(DbClosearea())
			Endif	
		EndIf
	EndIf

	If cTpArq $"RETPER_P" .And. lEsCons
		For nPrcFil:=1 to len(aFilsCalc)
			aFilsCalc[nPrcFil,1] := .F.
		Next nPrcFil ++
	Endif
Return(aLogReg)
