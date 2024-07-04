#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FWBrowse.ch'
#Include 'FINA689.ch'

Static __cAliasTMP	:= ""
Static __cArqTrab	:= ""
Static __lBlind		:= IsBlind()
Static oFIN689TX1	:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA689TXM
Rotina responsável pela manutencao de cotações em Lote para 
Adiantamentos de Viagem

@author Mauricio Pequim Jr
@since 28/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FINA689TXM(cAlias,nReg,nOpc,lAutomato)
Local lOk		:= .f.
Local aArea		:= GetArea()
Local aTmpFil	:= {}
Local nX		:= 0

Default	lAutomato	:= .F.

__cAliasTMP	:= ""
__cArqTrab	:= ""

While .T.
	IF Pergunte("FINA689TXM",!(__lBlind),,,,!lAutomato)
		If mv_par04 > 0		//MV_PAR04 = Cotação da moeda
			lOk := F689TFWMarkB(aTmpFil,lAutomato)
			If !Empty(__cArqTrab) .AND. Select(__cArqTrab) > 0
				(__cArqTrab)->(DbCloseArea())
			EndIf
			If !Empty(__cAliasTMP) .AND. Select(__cAliasTMP) > 0
				(__cAliasTMP)->(DbCloseArea())
			EndIf

			__cAliasTMP	:= ""
			__cArqTrab	:= ""
			
			//Apaga a tabela temporaria das filiais
			For nX := 1 TO Len(aTmpFil)
				CtbTmpErase(aTmpFil[nX])
			Next

			If oFIN689TX1 <> Nil
				oFIN689TX1:Delete()
				oFIN689TX1:= Nil
			EndIf

			If lAutomato	
				Exit
			EndIf
		Else
			If !(__lBlind)
	   			Help("  ",1,"NOCOTA689",,STR0006 ,1,0)	//"É necessário, nesse processo, informar-se uma cotação para a moeda."		
			EndIf
		Endif
	ELSE
		Exit
	ENDIF
EndDo

RestArea(aArea)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} F689TFWMarkB
Tela de seleção de documentos relacionado ao DH
@author Mauricio Pequim Jr
@since 29/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F689TFWMarkB(aTmpFil,lAutomato)

Local oDlg 		:= Nil
Local cQuery	:= ""
Local nX		:= 0
Local aStrMrk	:= {}
Local aCampos	:= {'FLD_FILIAL','FLD_VIAGEM','FLD_ADIANT','FLD_NOMEPA','FLD_DTSOLI','FLD_VALOR'}	//'FLD_PARTIC '
Local nRet 		:= 0
Local bOk 		:= {||(nRet := 1,  oDlg:End())}
Local bCancel	:= {||(nRet := 0,  oDlg:End())}
Local aArea 	:= Nil
Local cCampos 	:= ""
Local cChave 	:= ""
Local cMoeda 	:= If(MV_PAR03 == 1, "2","3")
Local cDescMoed	:= If(MV_PAR03 == 1, "Dolar","Euro")
Local lRet 		:= .T.
Local aSelFil	:= {}
local cTmpFLDFil:= ""
Local aCpoBro	:= {}
Local cMarca	:= GetMark()
Local oCotacao	:= NIL
Local aRetAuto	:= {}
Local cChavAut	:= ''
Local cRecTab	:= '' 
Local nAuto		:= 0

Default lAutomato	:= .F.

If !lAutomato
	aArea 	:= GetArea()
EndIf

//Seleciona filiais
If MV_PAR05 == 1 //Sim
	aSelFil := AdmGetFil(.F.,.T.,"FLD")
Else
	aSelFil := {cFilAnt}
Endif

Aadd(aStrMrk, {"FLD_OK","C",2,0,})
Aadd(aStrMrk, {"FLDRECNO","N",10,0,})

SX3->(DBSETORDER(2))
For nX := 1 To Len(aCampos)
	If SX3->(DBSEEK(aCampos[nX]))
		aAdd(aStrMrk, {aCampos[nX], SX3->X3_TIPO, TamSx3(aCampos[nX])[1],SX3->X3_DECIMAL,SX3->X3_PICTURE})
		cCampos += ","+SX3->X3_ARQUIVO+"."+ aCampos[nX] + CRLF
	EndIf
Next nX	

If !Empty(__cArqTrab) .AND. Select(__cArqTrab) > 0
	(__cArqTrab)->(DbCloseArea())
	__cArqTrab := ""
EndIf

//CriaTrab o arquivo temporário, caso o mesmo já não tenha sido criado
If __cArqTrab == ""
	cQuery := "SELECT FLD_FILIAL,FLD_VIAGEM,FLD_ADIANT,FLD_PARTIC,FLD_DTSOLI,FLD_VALOR,FLD.R_E_C_N_O_ AS FLDRECNO "
	cQuery += "FROM "+RetSqlName("FLD")+" FLD "+ CRLF
	cQuery += "WHERE "
	cQuery += " FLD.FLD_FILIAL " + GetRngFil( aSelFil, "FLD", .T., @cTmpFLDFil ) + " AND " 
	aAdd(aTmpFil, cTmpFLDFil)

	cQuery += "FLD.FLD_STATUS = '2' AND "+ CRLF 
	cQuery += "FLD.FLD_MOEDA <> '1' AND "+ CRLF
	cQuery += "FLD.FLD_TAXA = 0 AND " + CRLF
	cQuery += "FLD.FLD_DTSOLI BETWEEN '"+ DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND "+ CRLF
	cQuery += "FLD.FLD_MOEDA = '"+ cMoeda +"' AND "+CRLF
	cQuery += "FLD.D_E_L_E_T_ = ' '  "
	
	cQuery := ChangeQuery( cQuery )
	
	__cAliasTMP := CriaTrab(,.F.)
	
	MPSysOpenQuery(cQuery,__cAliasTMP)

	If oFIN689TX1 <> Nil
		oFIN689TX1:Delete()
		oFIN689TX1:= Nil
	EndIf

	__cArqTrab := CriaTrab(,.F.) // Nome do arquivo temporario

	// -- Cria tabela temporaria
	oFIN689TX1 := FwTemporaryTable():New(__cArqTrab)
	oFIN689TX1:SetFields(aStrMrk)
	oFIN689TX1:AddIndex("1", {"FLD_VIAGEM"} )
	oFIN689TX1:Create()
	// --
	
	//Preenche Tabela TMP com as informações filtradas
	If !(__cAliasTMP)->(Eof()) .AND. !(__cAliasTMP)->(Bof())
		While !(__cAliasTMP)->(Eof())
			RecLock( __cArqTrab, .T. )
			
			For nX := 1 To Len(aStrMrk)
				If aStrMrk[nX][1] == 'FLD_OK'
					(__cArqTrab)->&(aStrMrk[nX][1]) := '  '
				ElseIf aStrMrk[nX][1] == 'FLD_NOMEPA'
					(__cArqTrab)->&(aStrMrk[nX][1]) := GETADVFVAL("RD0","RD0_NOME",XFILIAL("RD0")+FLD->FLD_PARTIC,1,"")
				ElseIf aStrMrk[nX][2] == "D"
					(__cArqTrab)->&(aStrMrk[nX][1]) := STOD((__cAliasTMP)->&(aStrMrk[nX][1]))
				Else 
					(__cArqTrab)->&(aStrMrk[nX][1]) := (__cAliasTMP)->&(aStrMrk[nX][1])
				EndIf
					
			Next nX
			
			(__cArqTrab)->( MsUnlock() )
	
			(__cAliasTMP)->( dbSkip() )
		EndDo

		(__cArqTrab)->(dbgotop())
		For nX := 1 To Len(aStrMrk)
			If !aStrMrk[nX][1] $ "FLDRECNO" .and. !(xFilial("FLD") == '  ' .AND. aStrMrk[nX][1] == 'FLD_FILIAL')
				aadd(aCpoBro,{ aStrMrk[nX][1],, RetTitle(aStrMrk[nX][1]),aStrMrk[nX][5]})
			EndIf
		Next nX 

		If !lAutomato
			oSize := FWDefSize():New(.T.)
			oSize:AddObject("MASTER",100,100,.T.,.T.)
			oSize:lLateral := .F.				
			oSize:lProp := .T.
		
			oSize:Process()
	
			DEFINE MSDIALOG oDlg TITLE STR0001 PIXEL FROM oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd		//"Cotação da Moeda Estrangeira"
		
			nLinIni := oSize:GetDimension("MASTER","LININI")
			nColIni := oSize:GetDimension("MASTER","COLINI")
			nLinFin := oSize:GetDimension("MASTER","LINEND")
			nColFin := oSize:GetDimension("MASTER","COLEND")
	
			@ nLinIni+3	, 05 Say STR0002	FONT oDlg:oFont  PIXEL Of oDlg		//"Moeda:" 
			@ nLinIni	, 30 MSGET cDescMoed	FONT oDlg:oFont  WHEN .F. PIXEL Of oDlg 
		
			@ nLinIni+3	,100 Say STR0003	FONT oDlg:oFont  PIXEL Of oDlg		//"Cotação:" 
			@ nLinIni	,125 MSGET oCotacao VAR MV_PAR04	PICTURE PesqPict("FLD","FLD_TAXA") FONT oDlg:oFont PIXEL Of oDlg HASBUTTON
			oCotacao:lReadOnly := .T.

			oMark := MsSelect():New(__cArqTrab,"FLD_OK" ,"",aCpoBro,.F.,@cMarca,{nLinIni+20, nColIni, nLinFin, nColFin},,)
			oMark:bMark := {||F689TMark(cMarca,lAutomato)}
			oMark:bAval	:= {||F689TMark(cMarca,lAutomato)}
			oMark:oBrowse:lhasMark := .t.
			oMark:oBrowse:lCanAllmark := .t.
			oMark:oBrowse:bAllMark := {|| F689TMkAll(cMarca,lAutomato) }
		
			
			ACTIVATE MSDIALOG oDlg  ON INIT EnchoiceBar(oDlg, bOk , bCancel) CENTERED 
		Else
			If FindFunction("GetParAuto")
				aRetAuto	:= GetParAuto("FINA667TestCase")
			EndIf
			cRecTab := (__cArqTrab)->(RECNO())
			(__cArqTrab)->(dbGoTop())
			While !(__cArqTrab)->(Eof())
				For nAuto := 1 TO Len(aRetAuto)
				cChavAut:= (__cArqTrab)->FLD_VIAGEM + '|' + (__cArqTrab)->FLD_ADIANT
					If cChavAut == aRetAuto[nAuto][1]
						F689TMark(cMarca,lAutomato)
					EndIf
				(__cArqTrab)->(DbSkip())
				Next nAuto
			EndDo
			(__cArqTrab)->(dbGoto(cRecTab))
			nRet := 1
		EndIf
		
		If nRet == 1
			(__cArqTrab)->(dbGoTop())
			While !(__cArqTrab)->(Eof())
				If (__cArqTrab)->FLD_OK == cMarca
					
					FLD->(DBGOTO((__cArqTrab)->FLDRECNO))
					FLD->(RecLock("FLD", .F.))
					FLD->FLD_TAXA := MV_PAR04
					FLD->(MSUNLOCK())
					
				EndIf
				(__cArqTrab)->(DbSkip())
			EndDo
			
			(__cArqTrab)->(DbGOTOP())
		Endif

		dbSelectArea("FLD")
		MsUnlockall()

		If !lAutomato
			RestArea(aArea)
		EndIf
	Else
		If !(__lBlind)
	    	Help("  ",1,"NOREGS689",,STR0004,1,0)		//"Não foi localizado nenhum registro com os dados informados"
		EndIf
	   	lRet := .F.
	EndIf
		
Endif

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F689TMkAll
Função para marcar todos os itens da markbrowse.

@author Mauricio Pequim Jr
@since 02/07/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function F689TMkAll(cMarca,lAutomato)

(__cArqTrab)->(dbGoTop())
While !(__cArqTrab)->(Eof())
	F689TMark(cMarca,lAutomato)
	(__cArqTrab)->(DBSKIP())
EndDo
(__cArqTrab)->(dbGoTop())

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F689TMark
Função para marcar todos os itens da markbrowse.

@author Mauricio Pequim Jr
@since 02/07/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function F689TMark(cMarca,lAutomato)

//Posiciono a tabela FLD para bloquear o uso por outro terminal
FLD->(dbGoto((__cArqTrab)->FLDRECNO))

If FLD->(MsRLock())
	RecLock(__cArqTrab, .F.)
	If (__cArqTrab)->FLD_OK == cMarca		
		(__cArqTrab)->FLD_OK := ' '		
	Else
		(__cArqTrab)->FLD_OK :=cMarca
	EndIf
	(__cArqTrab)->(MsUnlock())
	lRet := .T.
Else
	If !(__lBlind)
		Help("  ",1,"REGBLOCKED689",,STR0005,1,0)		//"Este titulo não pode ser selecionado pois se encontra em uso por outro terminal."
	EndIf
	lRet := .F.
Endif
If !lAutomato
	oMark:oBrowse:Refresh()
EndIf	

Return lRet