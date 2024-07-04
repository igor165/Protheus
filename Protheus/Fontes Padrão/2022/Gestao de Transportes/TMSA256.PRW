#INCLUDE "TMSA256.ch"
#INCLUDE "Protheus.ch"

#DEFINE LT_MARCA  1
#DEFINE LT_CIOT   2
#DEFINE LT_CODVEI 3
#DEFINE LT_PLAVEI 4
#DEFINE LT_DATINI 5
#DEFINE LT_DATFIM 6
#DEFINE LT_STATUS 7
#DEFINE LT_CODOPE 8 

#DEFINE LT_SIZE   8 //-- Tamanho da linha no array

//--------------------------------------------------------------------
/*/{Protheus.doc} TMSA256
Encerramento do CIOT

@author Daniel Carlos Leme
@since  03/10/2016
@obs    Encerramento de CIOT
@version 1.0
/*/
//--------------------------------------------------------------------
Function TMSA256(aParam)
Local aSize     := {}
Local aObjects  := {}
Local aPosObj   := {}
Local aInfo     := {}

Local aListBox  := {}
Local cPerg     := 'TMSA256'
Local oOk,oNo

Local oDlg      := Nil
Local lJob 		:= .F.
Local lPergunte := .F.                                  
Local oBtn01,oBtn02
Local lPagbem   := .F.  

Default aParam := {}

Private oListBox:= Nil

//-- Checkbox
Private lAllMark:= .F.	//-- Usado para o controle da marca de todos os documentos


lJob := IIf(Len(aParam) > 1,.T.,.F.)

If lJob
	RpcSetType(3)
	RpcSetEnv(aParam[1],aParam[2],,,"TMS","TMSA256")    
	nModulo := 43
	
	Pergunte(cPerg,.F.)
	mv_par01 := CtoD('')
	mv_par02 := date() + 30 
	mv_par03 := ""
		
	LoadList(@aListBox,lJob)
	
	TmsLogMsg(,">> TMSA256 "+STR0001+  " - "+Dtoc(Date())+" "+Time() + STR0002)//-- "Encerramento de CIOT por período"##" Preparando ambiente..."

	BatchProcess(STR0001, STR0003, "TMSA256", { || TMSA256Prc(@aListBox,2,lJob) } , { || .F. } )	//-- 'Verificando...'

	TmsLogMsg(,"<< TMSA256 "+STR0001+ " - "+Dtoc(Date())+" "+Time() + STR0001) //-- "Encerramento de CIOT por período"##" Finalizando ambiente..."
	RPCClearEnv()

Else
	lPagBem:= FindFunction("TMSIntgPB") .AND. DJL->(FieldPos("DJL_CODOPE")) > 0
	
	oOk := LoadBitMap( GetResources(),"LBOK" )
	oNo := LoadBitMap( GetResources(),"LBNO" )
	
	
	lPergunte := Pergunte(cPerg,.T.)
	
	If lPergunte
		CursorWait()
		LoadList(@aListBox)
		CursorArrow()
	
		aSize    := MsAdvSize(.F. )
		aObjects := {}
	
		AAdd( aObjects, { 100, 020, .T., .F., .T.  } )
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 100, 020, .F., .F. } )
	
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3, .T.  }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
		DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //-- "Encerramento de CIOT por período"	
	
			oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)
	
			@ 005,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0005 SIZE 168, 08 ; //-- "Marca/Desmarca Todos"  
			ON CLICK TMSA256All(aListBox) OF oPanel PIXEL 
	
			//-- Cabecalho dos campos do Monitor.
			@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER;
				"",RetTitle("DJL_CIOT"),RetTitle("DJL_STATUS"),RetTitle("DJL_CODVEI"),RetTitle("DA3_PLACA"),RetTitle("DJL_DATINI"),RetTitle("DJL_DATFIM"),Iif(lPagbem,RetTitle("DJL_CODOPE"),"");
				SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL 
	
			oListBox:SetArray( aListBox )
			oListBox:bLDblClick := { || TMSA256Mrk(aListBox) }
			oListBox:bLine      := { || { Iif(	aListBox[ oListBox:nAT,LT_MARCA  ] == '1',oOk,oNo),;
												aListBox[ oListBox:nAT,LT_CIOT   ],;
												aListBox[ oListBox:nAT,LT_STATUS ],;
												aListBox[ oListBox:nAT,LT_CODVEI ],;
												Posicione('DA3',1,xFilial('DA3')+aListBox[ oListBox:nAT,LT_CODVEI ],'DA3_PLACA'),;
												aListBox[ oListBox:nAT,LT_DATINI ],;
												aListBox[ oListBox:nAT,LT_DATFIM ],;
												aListBox[ oListBox:nAT,LT_CODOPE ],;
												}}
	
			//-- Botoes 
			@ aPosObj[3,1],aPosObj[3,4]-100 BUTTON oBtn01 PROMPT STR0006 ACTION MsgRun(STR0009,STR0010,; //-- "Fechar CIOT" ## 'Realizando comunicacao com a Operadora...' ## "Aguarde" 
																				{|| TMSA256Prc(@aListBox,1), oDlg:End()})			 	 OF oDlg PIXEL SIZE 045,011	
			@ aPosObj[3,1],aPosObj[3,4]-040 BUTTON oBtn01 PROMPT STR0007 ACTION MsgRun(STR0009,STR0010,; //-- "Encerrar CIOT" ## 'Realizando comunicacao com a Operadora...' ## "Aguarde"
																				{|| TMSA256Prc(@aListBox,2), oDlg:End()})			 	 OF oDlg PIXEL SIZE 045,011	
			@ aPosObj[3,1],aPosObj[3,4]+020 BUTTON oBtn02 PROMPT STR0008 ACTION oDlg:End()	                   OF oDlg PIXEL SIZE 045,011 //-- "Sair"	
	
		ACTIVATE MSDIALOG oDlg
	EndIf
EndIf
Return( Nil )

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadList
Carrega array para processamento e listbox

@author Daniel Carlos Leme
@since  03/10/2016
@obs    Carrega array para processamento e listbox
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LoadList( aListBox, lJob )
Local cQuery    := ''
Local cAlias    := GetNextAlias()
Local nPosVei   := 0
Local aCbxSta   := RetSx3Box(Posicione('SX3',2,'DJL_STATUS','X3CBox()'),,,1)
Local lPagbem   := FindFunction("TMSIntgPB") .AND. DJL->(FieldPos("DJL_CODOPE")) > 0 

Default lJob	:= .F.

If lPagbem
	cQuery := " SELECT DJL_CIOT, DJL_CODVEI, DJL_DATINI, DJL_DATFIM, DJL_STATUS, DJL_CODOPE "
Else
	cQuery := " SELECT DJL_CIOT, DJL_CODVEI, DJL_DATINI, DJL_DATFIM, DJL_STATUS "
EndIf

cQuery += "  FROM " + RetSqlName('DJL') + " DJL "
cQuery += " WHERE DJL.DJL_FILIAL  = '" + xFilial('DT6') + "'"
cQuery += "   AND DJL.D_E_L_E_T_  = ' ' "
cQuery += "   AND DJL.DJL_STATUS  IN('1','2') " //-- 1-Em aberto/2-Fechado
cQuery += "   AND DJL.DJL_DATFIM BETWEEN '" + DtoS( mv_par01 ) + "' AND '" + DtoS( mv_par02 ) + "'"

If !Empty(mv_par03)
	cQuery += "   AND DJL.DJL_CODVEI = '"+mv_par03+"'"
EndIf

If lPagbem
	cQuery += "   AND DJL.DJL_CODOPE = '"+mv_par04+"'"
EndIf

cQuery += " AND DJL.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
TcSetField(cAlias,"DJL_DATINI","D",8,0)
TcSetField(cAlias,"DJL_DATFIM","D",8,0)

If (cAlias)->(!Eof())
	While (cAlias)->(!Eof())

		Aadd(aListBox,Array(LT_SIZE))
		nPosVei := Len(aListBox)
		aListBox[nPosVei,LT_MARCA ] := Iif(lJob,'1','2')
		aListBox[nPosVei,LT_CIOT  ] := (cAlias)->DJL_CIOT
		aListBox[nPosVei,LT_CODVEI] := (cAlias)->DJL_CODVEI
		aListBox[nPosVei,LT_PLAVEI] := ''
		aListBox[nPosVei,LT_DATINI] := DtoC( (cAlias)->DJL_DATINI )
		aListBox[nPosVei,LT_DATFIM] := DtoC( (cAlias)->DJL_DATFIM )
		aListBox[nPosVei,LT_STATUS] := AllTrim( aCbxSta[ Ascan( aCbxSta, { |x| x[ 2 ] == (cAlias)->DJL_STATUS } ), 3 ])
		If lPagbem
			aListBox[nPosVei,LT_CODOPE] := (cAlias)->DJL_CODOPE
		EndIf  

		(cAlias)->(dbSkip())
	EndDo
Else
	Help("",1,"REGNOIS")
	Aadd(aListBox,Array(LT_SIZE))
	nPosVei := Len(aListBox)
	aListBox[nPosVei,LT_MARCA ] := '2'
	aListBox[nPosVei,LT_CIOT  ] := ''
	aListBox[nPosVei,LT_CODVEI] := ''
	aListBox[nPosVei,LT_PLAVEI] := ''
	aListBox[nPosVei,LT_DATINI] := DtoC( CtoD('') )
	aListBox[nPosVei,LT_DATFIM] := DtoC( CtoD('') )
	aListBox[nPosVei,LT_STATUS] := AllTrim( aCbxSta[ Ascan( aCbxSta, { |x| x[ 2 ] == "1" } ), 3 ])
	If lPagbem
		aListBox[nPosVei,LT_CODOPE] := ''
	EndIf 
EndIf
(cAlias)->(dbCloseArea())

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} TMSA256Mrk
Marca/desmarca elemento do array para processamento

@author Daniel Carlos Leme
@since  03/10/2016
@obs    Marca/desmarca elemento do array para processamento
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function TMSA256Mrk(aListBox,nItem,lUmItem)
Local nPosMrk := 0
Local nDocMrk := 0

Default nItem   := oListBox:nAt
Default lUmItem := .T.

If lUmItem 
	aListBox[nItem,LT_MARCA] := Iif(aListBox[nItem,LT_MARCA] == '1','2','1')
Else
	If lAllMark
		aListBox[nItem,LT_MARCA] := '1'
	Else
		aListBox[nItem,LT_MARCA] := '2'
	EndIf
EndIf

oListBox:Refresh()

Return( Nil )

//--------------------------------------------------------------------
/*/{Protheus.doc} TMSA256All
Marca/desmarca todos elementos do array para processamento

@author Daniel Carlos Leme
@since  03/10/2016
@obs    Marca/desmarca todos elementos do array para processamento
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function TMSA256All(aListBox)
Local nI      := 0
Local lUmItem := .F.

CursorWait()

For nI := 1 To Len(aListBox)
	TMSA256Mrk(aListBox,nI,lUmItem)
Next nI

CursorArrow()

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} TMSA256Prc
Processa o encerramento do CIOT 

@author Daniel Carlos Leme
@since  03/10/2016
@obs    Processa o encerramento do CIOT 
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function TMSA256Prc(aListBox,nOpc,lJob)
Local nI      := 0
Local lPagbem := FindFunction("TMSIntgPB") .AND. DJL->(FieldPos("DJL_CODOPE")) > 0 
Local aMsgErr := {}
Local nCnt	  := 0
Local lTM256V := ExistBlock('TM256VldF')
Local l256VldF:= .T.

Default nOpc := 2 //-- Encerrar CIOT
Default lJob := .F.

For nI := 1 To Len(aListBox)
	
	l256VldF := .T.

	If aListBox[nI][LT_MARCA] == '1'
	 
		If nOpc == 2 //--Encerrar CIOT
			If lTM256V .AND. lJob
				l256VldF := ExecBlock( 'TM256VldF', .F., .F., { xFilial("DJL"), aListBox[nI][LT_CIOT], aListBox[nI][LT_CODVEI], aListBox[nI][LT_DATINI], aListBox[nI][LT_DATFIM] } )
			EndIf

			If lPagbem .And. aListBox[nI][LT_CODOPE] == '03'	//--Pagbem 
				If l256VldF
					PgBEncCIOT(aListBox[nI][LT_CIOT],aListBox[nI][LT_CODVEI], @aMsgErr)
				EndIf
			Else //--Pamcard 
				PamEncCIOT(aListBox[nI][LT_CIOT],aListBox[nI][LT_CODVEI],aListBox[nI][LT_PLAVEI])
			EndIf

		ElseIf nOpc == 1 //-- Fechar CIOT
	
			DJL->(DbSetOrder(1)) //-- DJL_FILIAL+DJL_CIOT+DJL_CODVEI
			If DJL->(DbSeek(xFilial("DJL")+aListBox[nI][LT_CIOT]+aListBox[nI][LT_CODVEI])) .And. DJL->DJL_STATUS == "1"
				RecLock("DJL",.F.)
				DJL->DJL_STATUS := "2" //--Fechado
				DJL->DJL_DATFEC := dDataBase 
				MsUnLock()
			EndIf
	
		EndIf
	EndIf
Next nI

If !Empty( aMsgErr )
	If lJob
		For nCnt := 1 To Len(aMsgErr)
			AutoGrLog(aMsgErr[nCnt,1])
		Next nCnt
	Else
		TmsMsgErr( aMsgErr )
	EndIf
EndIf

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} Scheddef()
@Função Schedule 
@author Rafael Souza
@since 10/05/2022
@version 1.0
@return cRet
/*/
//--------------------------------------------------------------------
Static Function SchedDef()
Local aParam

aParam := {"P",;  			//Tipo R para relatorio P para processo   
		   "TMSA256",;		// Pergunte do relatorio, caso nao use passar ParamDef            
		   "DJL",;  		// Alias            
		   ,;   			//Array de ordens   
		   'Schedule - Encerra CIOT'} //Schedule - Encerra CIOT    

Return aParam
