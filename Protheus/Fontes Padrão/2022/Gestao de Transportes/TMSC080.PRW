#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TMSC080.CH"

Static lTMC80Cpo //-- Static para verificar existência de PE
Static lTMC80FIL 	:= ExistBlock("TMC80FIL")	//--Ponto de entrada para acrescentar condicoes de filtro na query de selecao dos documentos

/*/{Protheus.doc} TMSC080
Realiza a consulta de Documentos (via F3)

@type		function
@author  	Daniel Leme
@version 	P12
@since   	07/06/2017
@return  	Nil
/*/

Function TMSC080( cFiltroDUD, lSelDoc, nOpcx, cRota, aLoteVge, cSerTmsAux, cTipTraAux, cSerAdiAux )
Local aSizeDlg   := FwGetDialogSize(oMainWnd)
Local aButtons   := {}
Local nHeight    := aSizeDlg[3]
Local nWidth     := aSizeDlg[4]
Local nOpca      := 0
Local cAliasBrw  := GetNextAlias()
Local cMarkBrw   := GetMark()
Local aSeek		 := {}
Local aIndex	 := {}
Local aColunas   := {}

//-- Variaveis da tela
Local oDlgConsult
Local oFWLayer                         

//-- Variaveis dos filtros 
Local oPanelUp

Local oNumNfc 
Local oSerNfc 
Local oDataDe 
Local oDataAte
Local oNfeId  
Local oCTEId  

Local oButtonFil       

Local oBrwDoc
Local aCpoFil := { Space(Len(DTC->DTC_NUMNFC));
				  ,Space(Len(DTC->DTC_SERNFC));
				  ,CToD("  /  /  ");
				  ,CToD("  /  /  ");
				  ,Space(Len(DTC->DTC_NFEID)) ;
				  ,Space(Len(DT6->DT6_CHVCTE)) ;
				  }

//-- Blocos da tela
//-- Botão "OK" da tela
Local bBtOk := Nil

//-- Botão "Cancel" da tela
Local bBtCancel := {|| Iif(lSelDoc,;
							(aAllDocto := {}, oDlgConsult:End()),; 
							oDlgConsult:End()) }
//-- Marcação de um documento
Local bMarkDoc 	:= {||  }
//-- Desmarcação de um documento
Local bDesMark 	:= { || Iif((cAliasBrw)->DUD_OK != cMarkBrw .And. !Empty(nRecMark),; 
						(nSavRec := (cAliasBrw)->(Recno()), ;
						 dbGoto(nRecMark), ;
						 RecLock(cAliasBrw,.F.), ;
						 (cAliasBrw)->DUD_OK := "", ;
						 MsUnlock(), ;
						 (cAliasBrw)->(dbGoto(nSavRec)) ;
						),;
						Nil) }
//-- Array para teclas de atalho
Local aSetKey 	:= {}

Local cFunction := 'TMSC080'

//-- Posições dos filtros de nota fiscal
#DEFINE NUMNFC  01
#DEFINE SERNFC  02
#DEFINE DATADE  03
#DEFINE DATAATE 04
#DEFINE NFEID   05
#DEFINE CTEID   06

Default lSelDoc 	:= .F.
Default nOpcx   	:= Iif(Type("INCLUI")!="U".And.Inclui,3,Iif(Type("ALTERA")!="U".And.Altera,4,2))
Default cRota   	:= Iif(Type("M->DTQ_ROTA")=="C",M->DTQ_ROTA,"")
Default lTMC80Cpo 	:= ExistBlock("TMC80Cpo")
Default aLoteVge  	:= {}
Default cSerTmsAux 	:= ""
Default cTipTraAux	:= ""
Default cSerAdiAux	:= ""

//-- Variaveis Private
Private nRecMark  := 0
Private cCadastro := STR0001 //-- "Consulta Documentos" 

If Type("cSerTMS") <> "U"
	cSerTmsAux	:= cSerTMS
EndIf

If Type("cTipTra") <> "U"
	cTipTraAux	:= cTipTra
EndIf

If Type("cSerAdi") <> "U"
	cSerAdiAux	:= cSerAdi 
EndIf

bMarkDoc 	:= {|| RecLock(cAliasBrw,.F.), ;
						Iif((cAliasBrw)->DUD_OK==cMarkBrw, ;
							((cAliasBrw)->DUD_OK:="", If( !lSelDoc, nRecMark:=0, Nil ) ),;
							((cAliasBrw)->DUD_OK :=cMarkBrw, nRecMark:= (cAliasBrw)->(Recno()));
							),;
						MsUnlock()}

bBtOk := {|| Iif(!Empty(nRecMark), ;
						((cAliasBrw)->(DbGoto(nRecMark)),;
							DUD->(DbGoto((cAliasBrw)->DUDRECNO)),;
							nOpca:= 1, ;
							Iif(lSelDoc,;
								MakeAllDoc(cAliasBrw,cRota,nOpcx, cSerTmsAux , cTipTraAux, cSerAdiAux ),;
								Nil),;
							oDlgConsult:End();
						),;
						Nil;
					  );
                }

IIf(ExistFunc('FwPdLogUser'),FwPdLogUser(cFunction),)

//-- Teclas de Atalho
AAdd(aSetKey, { 15 ,  bBtOk     } ) //-- "OK" - Ctrl + O
AAdd(aSetKey, { 24 ,  bBtCancel } ) //-- "Cancel" - Ctrl + X

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

DEFINE MSDIALOG oDlgConsult FROM 0,0 TO nHeight, nWidth TITLE cCadastro PIXEL of oMainWnd

	/////////////////////////////////////////////////////////////////////////////////
	//                              Monta objeto FWLayer                           //
	/////////////////////////////////////////////////////////////////////////////////
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlgConsult,.F.)

	//-- Quando serviço de coleta, não apresenta filtro por NF
	If cSerTmsAux != '1'

		oFWLayer:AddLine("LinFil",15,.F.)
		oFWLayer:addCollumn("ColFil",100,.F.,"LinFil")
		oFWLayer:addWindow("ColFil","JanFil",STR0002,100,.T.,.F.,{|| },"LinFil") //-- "Filtro Notas Fiscais"
		oPanelUp := oFWLayer:GetWinPanel("ColFil",'JanFil',"LinFil")
		
		oFWLayer:AddLine("LinRas",75,.F.)
		oFWLayer:addCollumn("ColRas",100,.F.,"LinRas")
		oFWLayer:addWindow("ColRas","JanRas",STR0003,100,.T.,.F.,{|| },"LinRas") //-- "Documentos "
		oPanelDown := oFWLayer:GetWinPanel("ColRas",'JanRas',"LinRas")
	
		/////////////////////////////////////////////////////////////////////////////////
		//                            Monta Janela de Filtros                          //
		/////////////////////////////////////////////////////////////////////////////////

		@ 000,000 SAY   RetTitle('DTC_NUMNFC')              SIZE 040,009 OF oPanelUp PIXEL
		@ 007,000 MSGET oNumNFC   VAR aCpoFil[NUMNFC]  PICTURE PesqPict("DTC","DTC_NUMNFC") SIZE 060,009 OF oPanelUp PIXEL

		@ 000,065 SAY   RetTitle('DTC_SERNFC')              SIZE 030,009 OF oPanelUp PIXEL
		@ 007,065 MSGET oSerNFC   VAR aCpoFil[SERNFC]  PICTURE PesqPict("DTC","DTC_NUMNFC")  SIZE 030,009 OF oPanelUp PIXEL

		@ 000,100 SAY   AllTrim(RetTitle('DTC_EMINFC')) + STR0005     SIZE 040,009 OF oPanelUp PIXEL //-- " de:"
		@ 007,100 MSGET oDataDe   VAR aCpoFil[DATADE]  PICTURE PesqPict("DTC","DTC_EMINFC") SIZE 060,009 OF oPanelUp PIXEL

		@ 000,165 SAY   AllTrim(RetTitle('DTC_EMINFC')) + STR0006     SIZE 040,009 OF oPanelUp PIXEL //-- " Até:"
		@ 007,165 MSGET oDataAte  VAR aCpoFil[DATAATE] PICTURE PesqPict("DTC","DTC_EMINFC") SIZE 060,009 OF oPanelUp PIXEL

		@ 000,230 SAY   RetTitle('DTC_NFEID')              SIZE 040,009 OF oPanelUp PIXEL
		@ 007,230 MSGET oNfeID  VAR aCpoFil[NFEID]     PICTURE PesqPict("DTC","DTC_EMINFC") SIZE 180,009 OF oPanelUp PIXEL

		@ 000,420 SAY   STR0009 SIZE 040,009 OF oPanelUp PIXEL    //Chave CT-e
		@ 007,420 MSGET oCTEID  VAR aCpoFil[CTEID]     PICTURE PesqPict("DT6","DT6_CHVCTE") SIZE 180,009 OF oPanelUp PIXEL

		//-- Botao do Filtro
		@ 007,620 BUTTON oButtonFil PROMPT STR0004 SIZE 035, 010 OF oPanelUp PIXEL ACTION TMSC080Fil(.T.,oBrwDoc,aColunas,cFiltroDUD,aCpoFil,lSelDoc,cRota,nOpcx,aLoteVge,cSerTmsAux , cTipTraAux, cSerAdiAux) //-- "Filtrar"

	ElseIf cSerTmsAux == '1'

		oFWLayer:AddLine("LinRas",90,.F.)
		oFWLayer:addCollumn("ColRas",100,.F.,"LinRas")
		oFWLayer:addWindow("ColRas","JanRas",STR0003,100,.T.,.F.,{|| },"LinRas") //-- "Documentos "

		oPanelDown := oFWLayer:GetWinPanel("ColRas",'JanRas',"LinRas")
 	EndIf

	/////////////////////////////////////////////////////////////////////////////////
	//                         Monta Janela                                        //
	/////////////////////////////////////////////////////////////////////////////////

	//-------------------------------------------------------------------
	// Indica os campos da tabela temporária
	//-------------------------------------------------------------------
	TMSC080Cpo(@aColunas, cSerTmsAux , cSerAdiAux)
	
	//-------------------------------------------------------------------
	// Indica os índices da tabela temporária
	//-------------------------------------------------------------------
	cQuery := TMSC080Fil(.F.,oBrwDoc,aColunas,cFiltroDUD,aCpoFil,lSelDoc,cRota,nOpcx,aLoteVge, cSerTmsAux , cTipTraAux, cSerAdiAux)

	//-------------------------------------------------------------------
	// Indica os índices da tabela temporária
	//-------------------------------------------------------------------
	Aadd( aIndex, "DUD_DOC" )

	//-------------------------------------------------------------------
	// Indica as chaves de Pesquisa
	//-------------------------------------------------------------------
	Aadd( aSeek, { allTrim(RetTitle("DUD_DOC"))		, {{"","C",TamSX3("DUD_DOC")[1],0, AllTrim(RetTitle("DUD_DOC"))			,,}} } )

	//-------------------------------------------------------------------
	// Define o Browse
	//-------------------------------------------------------------------
	DEFINE FWBROWSE oBrwDoc DATA QUERY ALIAS cAliasBrw QUERY cQuery FILTER SEEK ORDER aSeek INDEXQUERY aIndex OF oPanelDown

	If !lSelDoc
		//-- *********************************************************************/
		//-- SELEÇÃO DE APENAS 1 DOCTO
		//-- *********************************************************************/

		//-- Double Click em qualquer coluna da Linha
		oBrwDoc:bLDblClick := {|| 	Eval(bDesMark),; //-- Desmarca o doc atual, se existir algum marcado
									Eval(bMarkDoc),; //-- Marca o novo doc
									Eval(bBtOk)}     //-- Fecha a Tela pelo "OK"

		//-- Double Click Header e coluna de marcação
		oBrwDoc:AddMarkColumns ( {|| Iif(DUD_OK==cMarkBrw,'IndicatorRadioOnVista','IndicatorRadioOffVista')},;
								oBrwDoc:bLDblClick /* bLDblClick*/,;
								{||  } /*bHeaderClick*/ )
	Else
		//-- *********************************************************************/
		//-- SELEÇÃO MÚLTIPLOS DOCTOS
		//-- *********************************************************************/

		//-- Double Click em qualquer coluna da Linha
		oBrwDoc:bLDblClick := bMarkDoc

		//-- Double Click Header e coluna de marcação
		oBrwDoc:AddMarkColumns ( {|| Iif(DUD_OK==cMarkBrw,'LBOK','LBNO')},;
								oBrwDoc:bLDblClick /* bLDblClick*/,;
								{|| (cAliasBrw)->(DbGoTop()), ;
								    (cAliasBrw)->(DbEval(bMarkDoc)),;
									(cAliasBrw)->(DbGoTop()),;															 
									oBrwDoc:Refresh(.F.,.T.) } /*bHeaderClick*/ )
	EndIf
						  
	oBrwDoc:SetColumns(aColunas[1])
	oBrwDoc:SetFieldFilter(aColunas[3])
	
	//-------------------------------------------------------------------
	// Ativação do Browse
	//-------------------------------------------------------------------
	ACTIVATE FWBROWSE oBrwDoc

	//-- Botões da tela
	AAdd(aButtons, {'DEVOLNF',{||TMSViewDoc((cAliasBrw)->DUD_FILDOC,(cAliasBrw)->DUD_DOC,(cAliasBrw)->DUD_SERIE) }, STR0007, STR0007 }) //--"Docto"

ACTIVATE MSDIALOG oDlgConsult ON INIT EnchoiceBar( oDlgConsult,bBtOk,bBtCancel,, aButtons )

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

Return nOpcA

/*/{Protheus.doc} MakeAllDoc
Constrói o array utilizado para retornar os documentos marcados
@type		function
@author  	Daniel Leme
@version 	P12
@since   	2-/08/2017
@return  	Nil
/*/
Static function MakeAllDoc(cAliasBrw,cRota,nOpcx, cSerTmsAux , cTipTraAux, cSerAdiAux )
Local cFiltroDUD := ""
Local cQuery     := ""
Local cAliasNew  := ""
Local lVgeMod3   := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local lCarMod3   := Iif(FindFunction("TmsCarMod3"),TmsCarMod3(),.F.)
Local nRecnoDUD	 := 0

//-- Percorre o alias do MarkBrowse montando a cláusula "IN" para montagem do retorno - array aAllDocto
(cAliasBrw)->(DbGoTop())
Do While (cAliasBrw)->(!Eof())
	If !Empty((cAliasBrw)->DUD_OK)
		nRecnoDUD	:= (cAliasBrw)->DUDRECNO
		cFiltroDUD 	+= "'"+AllTrim(Str((cAliasBrw)->DUDRECNO))+"',"
	EndIf
	(cAliasBrw)->(DbSkip())
EndDo

If !Empty(cFiltroDUD)
	cFiltroDUD := " AND DUD.R_E_C_N_O_  IN(" + Substr(cFiltroDUD,1,Len(cFiltroDUD)-1) + ") "
EndIf

//-- Monta a query com todos os campos para montagem do array, filtrando os Recnos marcados.
cQuery := C080Query(nOpcx,cRota,.T.,cFiltroDUD , cSerTmsAux , cTipTraAux, cSerAdiAux ) 
cAliasNew := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
   
If (cAliasNew)->(ColumnPos("DT5_DATPRV")>0)
	TCSetField(cAliasNew,"DT5_DATPRV","D",8,0)
EndIf	
If (cAliasNew)->(ColumnPos("DT5_DATSOL")>0)
	TCSetField(cAliasNew,"DT5_DATSOL","D",8,0)
EndIf	
TCSetField(cAliasNew,"DT6_DATEMI","D",8,0)
TCSetField(cAliasNew,"DT6_PRZENT","D",8,0)
TCSetField(cAliasNew,"DT6_QTDVOL","N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])
TCSetField(cAliasNew,"DT6_PESO"  ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
TCSetField(cAliasNew,"DT6_PESOM3","N",TamSx3("DT6_PESOM3")[1],TamSx3("DT6_PESOM3")[2])
TCSetField(cAliasNew,"DT6_VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])

If (cAliasNew)->(ColumnPos("DT5_DATENT")>0)
	TCSetField(cAliasNew,"DT5_DATENT","D",8,0)
EndIf

(cAliasNew)->( DbGoTop() )
aAllDocto := {}

If lCarMod3
	AtuGridDM3( cAliasNew, 2 )
ElseIf lVgeMod3
	AtuGridDM3( cAliasNew, 1 )
Else
	AtuGridDoc( cSerTmsAux , cRota , nOpcx , cAliasNew )
EndIf

//-- Fecha a query
(cAliasNew)->(DbCloseArea())

Return

/*/{Protheus.doc} TMSC080Fil
Retorna a query e reconstrói dados no Browse
@type		function
@return		cQuery
@author  	Daniel Leme
@version 	P12
@since   	02/08/2017
@return  	Nil
/*/
Static Function TMSC080Fil(lRefazObj,oBrwDoc,aColunas,cFiltroDUD,aCpoFil,lSelDoc,cRota,nOpcx,aLoteVge,cSerTmsAux , cTipTraAux, cSerAdiAux)
Local cAliasObj 
Local cWhereDTC := ""
Local cRetPe    := ""
Local cLoteVge  := ""
Local nX        := 0

Local aAreas    := {DT6->(GetArea()),GetArea()}
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

Default lRefazObj 	:= .F.
Default aLoteVge  	:= {}
Default cSerTmsAux	:= ""
Default cTipTraAux	:= ""
Default cSerAdiAux	:= ""

If Len(aLoteVge) > 0
	For nX := 1 To Len(aLoteVge)
		cLoteVge+=  "'" + aLoteVge[nx] + Iif(nX == Len(aLoteVge),"'", "',")
	Next nX
EndIf

CursorWait()

//-- Monta a Query
//-- Coloca prefixo nas colunas
If At("DUD.",aColunas[2]) == 0
	aColunas[2] := StrTran(aColunas[2],"DUD_","DUD.DUD_")
	aColunas[2] := StrTran(aColunas[2],"DT6_","DT6.DT6_")
EndIf

cQuery := " SELECT DUD.R_E_C_N_O_ DUDRECNO, DUD.DUD_OK, " + aColunas[2] 
If !lSelDoc .Or. IsInCallStack("TF90LSTDoc")
	cQuery += " FROM "  + RetSqlName("DUD") + " DUD "
Else
	cQuery += " FROM ("  + C080Query( nOpcx,cRota,.F., , cSerTmsAux , cTipTraAux, cSerAdiAux  ) +") QRY1" 
	cQuery += " JOIN "  + RetSqlName("DUD") + " DUD ON "
	cQuery += "        DUD.R_E_C_N_O_ = QRY1.DUDRECNO"
EndIf
cQuery += " JOIN "  + RetSqlName("DT6") + " DT6 ON "
cQuery += "        DT6.DT6_FILIAL = '"+xFilial("DT6")+"'"
cQuery += "    AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
cQuery += "    AND DT6.DT6_DOC    = DUD.DUD_DOC"
cQuery += "    AND DT6.DT6_SERIE  = DUD.DUD_SERIE "
cQuery += "    AND DT6.DT6_STATUS  <> '7' "
cQuery += "    AND DT6.D_E_L_E_T_ = ' ' "
If !Empty(aCpoFil[CTEID])
	cQuery += " AND DT6_CHVCTE  = '"+AllTrim(aCpoFil[CTEID]) +"'"
EndIf

If lVgeMod3 .And. !TmsCarMod3() .And. !IsInCallStack("TMSA360MNT")
	DTQ->(DbSetOrder(1))
	If DTQ->(DbSeek(xFilial("DTQ") + FwFldGet("DTQ_VIAGEM")))
		If DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))
			cQuery += " LEFT OUTER JOIN "  + RetSqlName("DTP") + " DTP ON "
			cQuery += "        DTP.DTP_FILIAL = '"+xFilial("DTP")+"'"
			cQuery += "    AND DTP.DTP_LOTNFC = DT6.DT6_LOTNFC"
			cQuery += "    AND DTP.D_E_L_E_T_ = ' ' "
		EndIf
	EndIf
EndIf

cQuery += " WHERE DUD.D_E_L_E_T_ = ' ' "

If !Empty(cLoteVge) .And. !Empty(cSerAdiAux)  //cSerAdi --- TMSXFUNA
	If cSerAdiAux <> '0'
		cQuery += "AND ((DT6.DT6_SERIE <> 'COL' AND DT6.DT6_LOTNFC IN (" + cLoteVge + ")) OR DT6.DT6_SERIE = 'COL') "
	Else
		cQuery += "AND DT6.DT6_LOTNFC IN (" + cLoteVge + ") "
	EndIf
EndIf

If !Empty(cFiltroDUD) 
	cQuery += "    AND " + cFiltroDUD
EndIf

//-- Avalia Filtro DTC
If !Empty(aCpoFil[NUMNFC])
	cWhereDTC += " AND DTC_NUMNFC LIKE '%"+AllTrim(aCpoFil[NUMNFC])+"%'"
EndIf
If !Empty(aCpoFil[SERNFC])
	cWhereDTC += " AND DTC_SERNFC LIKE '%"+AllTrim(aCpoFil[SERNFC])+"%'"
EndIf
If !Empty(aCpoFil[NFEID])
	cWhereDTC += " AND DTC_NFEID  LIKE '%"+AllTrim(aCpoFil[NFEID]) +"%'"
EndIf
If !Empty(aCpoFil[DATADE]) .Or. !Empty(aCpoFil[DATAATE])
	cWhereDTC += " AND DTC_EMINFC BETWEEN '"+DtoS(aCpoFil[DATADE]) +"' AND '"+DtoS(aCpoFil[DATAATE])+"'"
EndIf

If !Empty(cWhereDTC)
	cQuery += " AND EXISTS(SELECT 1 COL1 FROM " + RetSqlName("DTC") + " DTC" 
	cQuery += "            WHERE DTC.D_E_L_E_T_ = ' ' "
	cQuery += "              AND DTC.DTC_FILIAL = '" +xFilial("DTC")+"' "
	cQuery += "    			 AND DTC.DTC_FILDOC = DUD.DUD_FILDOC"
	cQuery += "    			 AND DTC.DTC_DOC    = DUD.DUD_DOC"
	cQuery += "    			 AND DTC.DTC_SERIE  = DUD.DUD_SERIE"
	cQuery +=                cWhereDTC
	cQuery += "            UNION " 
	cQuery += "            SELECT 1 COL1 FROM " + RetSqlName("DY4") + " DY4" 
 	cQuery += "            JOIN " + RetSqlName("DTC") + " DTC ON " 
	cQuery += "                  DTC.D_E_L_E_T_ = ' ' "
	cQuery += "              AND DTC.DTC_FILIAL = '" +xFilial("DTC")+"' "
	cQuery += "    			 AND DTC.DTC_NUMNFC = DY4_NUMNFC"
	cQuery += "    			 AND DTC.DTC_SERNFC = DY4_SERNFC"
	cQuery += "    			 AND DTC.DTC_CLIREM = DY4_CLIREM"
	cQuery += "    			 AND DTC.DTC_LOJREM = DY4_LOJREM"
	cQuery += "    			 AND DTC.DTC_CODPRO = DY4_CODPRO"
	cQuery +=                cWhereDTC
	cQuery += "            WHERE DY4.D_E_L_E_T_ = ' ' "
	cQuery += "              AND DY4.DY4_FILIAL = '" +xFilial("DY4")+"' "
	cQuery += "    			 AND DY4.DY4_FILDOC = DUD.DUD_FILDOC"
	cQuery += "    			 AND DY4.DY4_DOC    = DUD.DUD_DOC"
	cQuery += "    			 AND DY4.DY4_SERIE  = DUD.DUD_SERIE"
	cQuery += "           )"
EndIf

If lTMC80FIL
	cRetPe := ExecBlock("TMC80FIL",.F.,.F., {'DT6'})
	If Valtype(cRetPe) == "C"
		cQuery += cRetPe
	EndIf
EndIf

If lVgeMod3 .And. !TmsCarMod3() .And. !IsInCallStack("TMSA360MNT")
	If DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))
		cQuery += " AND (DTP_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' OR DUD_SERTMS = '1' ) "
	EndIf
EndIf

cQuery += " ORDER BY DUD.DUD_DOC"								  

cQuery := ChangeQuery(cQuery)
If lRefazObj
	cAliasObj := oBrwDoc:Alias()
	(cAliasObj)->(DbCloseArea())
	oBrwDoc:SetAlias(cAliasObj)
	oBrwDoc:SetQuery( cQuery )
	oBrwDoc:oData:DeActivate(.T.)
	oBrwDoc:oData:Activate() 
	oBrwDoc:Refresh(.F.,.T.)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

CursorArrow()

Return cQuery

/*/{Protheus.doc} TMSC080Cpo
Função para montar os campos da consulta
@type		function
@return		cQuery
@author  	Daniel Leme
@version 	P12
@since   	09/10/2017
@return  	Nil
/*/
Static Function TMSC080Cpo(aColunas,cSerTmsAux , cSerAdiAux )
Local aCpos    := {}
Local aCposUsr := {}               //-- Usado no PE TMC80CPO
Local aAliasPE := {'DT6','DUD'}    //-- Usado no PE TMC80CPO
Local nCntFor1

Default cSerTmsAux	:= ""
Default cSerAdiAux	:= ""

aAdd(aCpos,{"DT6_BLQDOC"})
aAdd(aCpos,{"DUD_FILDOC"}) 
aAdd(aCpos,{"DUD_DOC"   }) 
aAdd(aCpos,{"DUD_SERIE" })
aAdd(aCpos,{"DUD_FILORI"}) 
aAdd(aCpos,{"DUD_VIAGEM"})
aAdd(aCpos,{"DTC_REGORI","Posicione('DUY',1,xFilial('DUY')+DT6_CDRORI,'DUY_DESCRI')"})
aAdd(aCpos,{"DUG_ESTORI","Posicione('DUY',1,xFilial('DUY')+DT6_CDRORI,'DUY_EST')"   })
aAdd(aCpos,{"DTC_REGDES","Posicione('DUY',1,xFilial('DUY')+DT6_CDRDES,'DUY_DESCRI')"})
aAdd(aCpos,{"DUG_ESTDES","Posicione('DUY',1,xFilial('DUY')+DT6_CDRDES,'DUY_EST')"   })
//-- Verifica coleta
If cSerAdiAux == '1' .Or. cSerTmsAux == "1"
	aAdd(aCpos,{"DT5_CODSOL","Posicione('DT5',4,xFilial('DT5')+DUD_FILDOC+DUD_DOC+DUD_SERIE,'DT5_CODSOL')" })
	aAdd(aCpos,{"DUE_NREDUZ","Posicione('DUE',1,xFilial('DUE')+DT5->DT5_CODSOL,'DUE_NREDUZ')" })
EndIf
aAdd(aCpos,{"DT6_CLIREM"})
aAdd(aCpos,{"DT6_LOJREM"})
aAdd(aCpos,{"DT6_NOMREM","Posicione('SA1',1,xFilial('SA1')+DT6_CLIREM+DT6_LOJREM,'A1_NOME')"})
aAdd(aCpos,{"DT6_CLIDES"})
aAdd(aCpos,{"DT6_LOJDES"})
aAdd(aCpos,{"DT6_NOMDES","Posicione('SA1',1,xFilial('SA1')+DT6_CLIDES+DT6_LOJDES,'A1_NOME')"})
aAdd(aCpos,{"DT6_STATUS"})
aAdd(aCpos,{"DT6_CDRORI"})
aAdd(aCpos,{"DT6_CDRDES"})
aAdd(aCpos,{"DT6_DOCTMS"})
aAdd(aCpos,{"DT6_DESDOC","TMSValField('DT6_DOCTMS',.F.)"})

//-- PE para adição de campos do usuário.
If lTMC80Cpo
	aCposUsr := ExecBlock('TMC80CPO',.F.,.F.,{aAliasPE})
	If Valtype(aCposUsr) == 'A'
		For nCntFor1 := 1 To Len(aCposUsr)
			If Len(aCposUsr[nCntFor1]) == 1
				AAdd(aCpos,{aCposUsr[nCntFor1,1]})
			ElseIf Len(aCposUsr[nCntFor1]) >= 2
				AAdd(aCpos,{aCposUsr[nCntFor1,1],aCposUsr[nCntFor1,2]})
			EndIf
		Next nFor
	EndIf
EndIf

aColunas := fColumns(aCpos)

Return

/*/{Protheus.doc} fColumns
Retorna um array, onde a primeira posicao é um vetor de objetos da classe
FWBrwColumn, esses serao responsaveis pelos campos exibidos no mBrowse.
Já a segunda posicao, retorna os campos que serao retornados na query. (from LJSUBNFE.PRW)
@type		function
@return		aRet [1] array com os campos do mBrowse [2] string com os campos que serao retornados na query
@author  	Varejo
@version 	P12
@since   	05/12/2016
@return  	Nil
/*/
Static Function fColumns(aCpos)

Local cColumns	:= ""
Local aRet 		:= {}
Local aColumns	:= {}
Local aArea		:= GetArea()
Local nI
Local aCamposFil := {}
Local aDadosCpo  := {}
Local cCBox	   := ""

For nI := 1 To Len(aCpos)
	cX3Campo := aCpos[nI][1]
	cCBox    := GetSX3Cache(cX3Campo,"X3_CBOX")
	aDadosCpo:= TamSX3(cX3Campo)
	//cria uma instancia da classe FWBrwColum
	Aadd( aColumns, FWBrwColumn():New() )

	If Len(aCpos[nI]) >= 2 .And. !Empty(aCpos[nI][2])
		Atail(aColumns):SetData( &("{||" + aCpos[nI][2] + "}") )
	Else
		cColumns += (cX3Campo +",")
		Aadd(aCamposFil, {cX3Campo, GetSX3Cache(cX3Campo,"X3_TITULO"), aDadosCpo[3], aDadosCpo[1], aDadosCpo[2], X3Picture(cX3Campo) })
			If aDadosCpo[3] == "D"
			Atail(aColumns):SetData( &("{||StoD(" + cX3Campo + ")}") )
		Else
			Atail(aColumns):SetData( &("{||" + cX3Campo + "}") )
		EndIf
	EndIf 
	If !Empty(cCBox) .And. "#" $ cCBox
		Atail(aColumns):SetOptions(StrToKArr(&(StrTran(cCBox,"#","")),";"))
	ElseIf !Empty(cCBox) 
		Atail(aColumns):SetOptions(StrToKArr(cCBox,";"))
	EndIf
	Atail(aColumns):SetSize( Max(Int(aDadosCpo[1]/8),5) ) // Tamanho da coluna não é o tamanho do campo
	Atail(aColumns):SetDecimal( aDadosCpo[2] )
	Atail(aColumns):SetTitle( GetSX3Cache(cX3Campo,"X3_TITULO"))
	Atail(aColumns):SetPicture( X3Picture(cX3Campo) )
	If aDadosCpo[3] == "N"
		Atail(aColumns):SetAlign( CONTROL_ALIGN_RIGHT )
	Else
		Atail(aColumns):SetAlign( CONTROL_ALIGN_LEFT )
	EndIf
End	

RestArea(aArea)

//retira a ultima virgula dos campos da query
cColumns := Substr(cColumns, 1, Len(cColumns)-1)

Aadd(aRet, Aclone(aColumns) )	//campos presentes na mBrowse (cada campo é um objeto da classe FWBrwColumn)
Aadd(aRet, cColumns )			//campos que serao retornados na query
Aadd(aRet, aCamposFil )			//campos que serao Utilizados no filtro

//destroi o aColumns
aSize( aColumns,0 )
aColumns := Nil

Return aRet

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PROTEÇÃO CONTRA VERSÃO INCOMPATÍVEL - RETIRAR NA 12.1.18     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function TMSC080Ver()
Return '12.1.17'

/*/{Protheus.doc} AtuGridDoc()
	(long_description)
	@type  Function
	@author Caio Murakami
	@since 21/07/2020
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function AtuGridDoc( cSerTmsAux , cRota , nOpcx , cAliasNew )

If cSerTmsAux == '2'
	//-- A função TMSA144DTP (para viagens de transferência) percorre o alias e não é necessário chamá-la para cada registro
	TMSA144DTp(cRota,nOpcx,cAliasNew,.F.)
Else
	//-- A função TmsA141Add (para viagens de Coleta/Entrega) adiciona 1 documento por vez
	While (cAliasNew)->(!Eof())
		TmsA141Add(,cAliasNew,,cRota,,,,nOpcx)
		(cAliasNew)->( DbSkip() )
	EndDo                
EndIf

//-- Força a marca em todos os elementos do array de documentos
aEval(aAllDocto,{|x| x[1] := .T. })

Processa({|| TMSA144Atu(.T.)}, STR0008 ) //-- "Aguarde"

Return 

/*/{Protheus.doc} C080Query
	(long_description)
	@type  Function
	@author Caio Murakami
	@since 21/07/2020
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function C080Query( nOpcx,cRota,lOrderBy,cFiltroDUD, cSerTmsAux , cTipTraAux, cSerAdiAux  )
Local cQuery	:= ""
Local lVgeMod3   := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local lCarMod3   := Iif(FindFunction("TmsCarMod3"),TmsCarMod3(),.F.)


Default nOpcx		:= 3 
Default cRota		:= ""
Default lOrderBy	:= .F. 
Default cFiltroDUD	:= ""
Default cSerTmsAux	:= ""
Default cTipTraAux	:= ""
Default cSerAdiAux	:= ""

If !lVgeMod3 .And. !lCarMod3
	cQuery	:= TM141Query(nOpcx,cRota,lOrderBy,cFiltroDUD)
Else
	cQuery	:= TMSF60Qry( nOpcx, cRota, lOrderBy, cFiltroDUD , cSerTmsAux , cTipTraAux , cSerAdiAux  )
EndIf

Return cQuery

/*/{Protheus.doc} AtuGridDM3
	Atualiza grid DM3
	@type  Function
	@author Caio Murakami
	@since 10/09/2020
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function AtuGridDM3( cAliasAux, nAcao )
Local aArea		:= GetArea()
Local cFilDoc	:= ""
Local cDoc		:= ""
Local cSerie	:= ""
Local aMsgErr   := {}

Default cAliasAux	:= ""
Default nAcao       := 0

While (cAliasAux)->(!Eof())
	cFilDoc		:= (cAliasAux)->DUD_FILDOC
	cDoc		:= (cAliasAux)->DUD_DOC
	cSerie		:= (cAliasAux)->DUD_SERIE
	
	TF60AddDoc(cFilDoc,cDoc,cSerie,,,,@aMsgErr,nAcao)

	(cAliasAux)->(dbSkip())
EndDo

If Len(aMsgErr) > 0
	TMSMsgErr( aMsgErr )
EndIf

RestArea(aArea)
FwFreeArray(aMsgErr)
Return