#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF60.CH"
#INCLUDE "FWMVCDEF.CH"

Static oNoMarked:= Nil
Static oMarked  := Nil
Static lTMS3GFE := TmsIntGFE('02')
Static lTmsRdpU := lTMS3GFE .Or. ( SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N' )  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho

//-------------------------------------------------------------------
/* {Protheus.doc} TF60BmpDoc
Função para acionar a chamada da consulta para multiplos documentos
@author  Caio Murakami
@since   11/09/2020
@version 1.0
*/
//-------------------------------------------------------------------
Function TF60BmpDoc()
Local lRet	   := .T. 
Local oModel   := FWModelActive()
Local oMdFldDTQ:= oModel:GetModel("MdFieldDTQ")

If oModel:GetOperation() <> MODEL_OPERATION_INSERT .And. oModel:GetOperation() <> MODEL_OPERATION_UPDATE
	lRet	:= .F. 
ElseIf Empty(oMdFldDTQ:GetValue("DTQ_SERTMS"))
	lRet	:= .F. 
	Help('',1,"OBRIGAT",,FWX3Titulo('DTQ_SERTMS'),04,01)
ElseIF Empty( oMdFldDTQ:GetValue("DTQ_ROTA") )
	lRet	:= .F. 
	Help('',1,"OBRIGAT",,FWX3Titulo('DTQ_ROTA'),04,01)
Else

	TF60F3Doc(.T.)

EndIf 

Return lRet 

//-------------------------------------------------------------------
/* {Protheus.doc} TF60AddDoc
Função para adicionar documentos na DM3
@author  Caio Murakami
@since   10/09/2020
@version 1.0
*/
//-------------------------------------------------------------------
Function TF60AddDoc(cFilDoc,cDoc,cSerie,lSeek,oModel,oView,aMsgErr,nAcao)
Local lRet			:= .T. 
Local oMdlDM3		:= Nil
Local oMdlDTA       := Nil
Local aArea         := GetArea()
Local nLin          := 1
Local aErro         := {}
Local nLinAtu       := 0

Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default oModel		:= FWModelActive()
Default oView		:= FwViewActive()
Default nAcao       := 0

If nAcao == 1	//-- Viagem
	oMdlDM3:= oModel:GetModel("MdGridDM3")
	//--- Linha Posicionada na Grid
	nLinAtu:= oMdlDM3:GetLine()
	If oMdlDM3:Length() >= 1 
		lSeek:= oMdlDM3:SeekLine({{"DM3_FILDOC",cFilDoc},{"DM3_DOC",cDoc},{"DM3_SERIE",cSerie}})
	EndIf
ElseIf nAcao == 2	//-- Carregamento
	oMdlDTA:= oModel:GetModel("MdGridDTA")
	//--- Linha Posicionada na Grid
	nLinAtu:= oMdlDTA:GetLine()
	If oMdlDTA:Length() >= 1 
		lSeek:= oMdlDTA:SeekLine({{"DTA_FILDOC",cFilDoc},{"DTA_DOC",cDoc},{"DTA_SERIE",cSerie}})
	EndIf
EndIf

If !lSeek
	If nAcao == 1	//-- Viagem
		oMdlDM3:GoLine( nLinAtu )
		//-- Controle caso esteja posicionado em uma linha em branco 
		If !Empty(FwFldGet("DM3_FILDOC")) .And. !Empty(FwFldGet("DM3_DOC"))
			nLin:=  oMdlDM3:Length()
			oMdlDM3:GoLine( nLin )
	
			If !oMdlDM3:IsEmpty() 
				oMdlDM3:AddLine()
				nLin:= oMdlDM3:GetLine()
			EndIf 
		EndIf
		
		lRet	:= Iif(lRet,oMdlDM3:SetValue("DM3_SEQUEN" ,StrZero(nLin,Len(DM3->DM3_SEQUEN))   ),.F.)
		lRet	:= Iif(lRet,oMdlDM3:SetValue("DM3_FILDOC" ,cFilDoc),.F.)
		lRet	:= Iif(lRet,oMdlDM3:SetValue("DM3_DOC"	  ,cDoc   ),.F.)
		lRet	:= Iif(lRet,oMdlDM3:SetValue("DM3_SERIE"  ,cSerie ),.F.)
	
		If lRet
			lRet:= oMdlDM3:VldLineData()    
		EndIf
	ElseIf nAcao == 2	//-- Carregamento
		oMdlDTA:GoLine( nLinAtu )
		//-- Controle caso esteja posicionado em uma linha em branco 
		If !Empty(FwFldGet("DTA_FILDOC")) .And. !Empty(FwFldGet("DTA_DOC"))
			nLin:=  oMdlDTA:Length()
			oMdlDTA:GoLine( nLin )
	
			If !oMdlDTA:IsEmpty() 
				oMdlDTA:AddLine()
				nLin:= oMdlDTA:GetLine()
			EndIf 
		EndIf
		
		lRet	:= Iif(lRet,oMdlDTA:SetValue("DTA_FILDOC" ,cFilDoc),.F.)
		lRet	:= Iif(lRet,oMdlDTA:SetValue("DTA_DOC"	  ,cDoc   ),.F.)
		lRet	:= Iif(lRet,oMdlDTA:SetValue("DTA_SERIE"  ,cSerie ),.F.)
	
		If lRet
			lRet:= oMdlDTA:VldLineData()    
		EndIf
	EndIf

	If !lRet
		aErro := oModel:GetErrorMessage()
	    If !Empty( aErro[6] )
	        Aadd( aMsgErr, { /*"Mensagem do erro: " +*/ AllToChar( aErro[6] ) , 00, '' } )  //-- "Mensagem do erro: "
    	EndIf
    	If nAcao == 1
			oMdlDM3:DeleteLine()
		Else
			oMdlDTA:DeleteLine()
		EndIf
	EndIf
	oView:Refresh()
EndIf

RestArea(aArea)
Return lRet 

/*/{Protheus.doc} TMF60CodBr
Leitura Cód Barras dos Documentos da Viagem
@type Function
@author Katia
@since 21/09/2020
@version P12 R12.1.30
@param 
@return Nil
Função extraida do fonte TMSA210 (TM210CodBr)
*/
Function TMF60CodBr()
Local cCodbar  := Space(Len(DT6->DT6_CHVCTE)+1)
Local cCodbar2 := Space(Len(DT6->DT6_CHVCTE)+1)
Local oGetBar  := Nil
Local lRet     := .T.
Local oModel   := FwModelActive()
Local oView    := FwViewActive()

Local oDlgBar := NIl

DEFINE DIALOG oDlgBar FROM 0,0 TO 100,400 TITLE STR0030 Of oMainWnd PIXEL  //--"Leitura do Cód. de Barras por Documento"

@ 16,10 SAY STR0031 Of oDlgBar PIXEL SIZE 100,10 //--Cód de barras"
@ 26,10 MSGET oGetBar VAR cCodbar SIZE 160,10 Picture '@!' VALID (TMF60PRE(@cCodBar,@oGetBar,oModel,oView,1)) PIXEL
@ 25,11 MSGET oGetBar2 VAR cCodbar2 SIZE 1,1 //-- campo para mudanca de foco e execucao do valid

ACTIVATE DIALOG oDlgBar CENTERED 

Return lRet

/*/{Protheus.doc} TMF60PRE
Função que realiza a consulta da chave informada na leitura do Doc
@type Function
@author Katia
@since 22/09/2020
@version P12 R12.1.30
@param  cCodBar,oGetBar,oModel,oView
@return lRet
Função extraida do fonte TMSA210.PRW (Tmsa210Pre)
*/
Function TMF60PRE(cCodBar,oGetBar,oModel,oView,nAcao)
Local    lRet 		:= .T.
Local    lSeek      := .F.
Local    aMsgErr    := {}

Default  cCodBar	:= ""
Default  oModel     := FwModelActive()
Default  oView      := FwViewActive()
Default  nAcao      := 0

If !Empty(cCodbar)
	dbSelectArea("DT6")
	DT6->(dbSetOrder(18)) //DT6_FILIAL+DT6_CHVCTE
	
	If DT6->(dbSeek(xFilial("DT6") + cCodBar))
		lRet:= TF60AddDoc(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,@lSeek,oModel,oView,@aMsgErr,nAcao)
		If lRet 
			If !lSeek
				cCodBar := Space(Len(DT6->DT6_CHVCTE)+1)				
				oGetBar:SetFocus()					
			Else
				Help ("",1,"TMSA21060") // Documento informado anteriormente.
				lRet := .F.
			EndIf
		Else 
			If Len(aMsgErr) > 0
				Help('' , 1, 'HELP',, aMsgErr[1][1] ,3,0)
			EndIf
		EndIf			
	Else
		Help ("",1,"TMSA21059") // Chave de Documento não localizada ou inválida
		lRet := .F.
	EndIf
	
EndIf

If !lRet
	cCodBar := Space(Len(DT6->DT6_CHVCTE)+1)
EndIf

FwFreeArray(aMsgErr)
Return lRet 

/*/{Protheus.doc} TMF60RdVge
Redespacho Adicional
@type Function
@author Katia
@since 22/09/2020
@version P12 R12.1.30
@param oModel
@return Nil
*/
Function TMF60RdVge(oModel)
Local oRadio     := Nil
Local nRadio     := 1
Local oDlg		 := Nil
Local oBold		 := Nil
Local nOpca		 := 0
Local nOperation := oModel:GetOperation()
Local lContinua  := .T.

lContinua:= nOperation == MODEL_OPERATION_INSERT .Or. nOperation ==  MODEL_OPERATION_UPDATE
If lContinua .And. M->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS))
	lContinua:= .F.
EndIf

If lContinua
	DEFINE MSDIALOG oDlg TITLE STR0021 FROM 09,0 TO 20,70 OF oMainWnd // "Tela"
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	@ 03, 14 SAY STR0023 FONT oBold PIXEL //"Repetir o Redespacho Adicional:"
	@ 14, 00 TO 16 ,400 LABEL '' OF oDlg  PIXEL // Linha
	@ 30, 30 RADIO oRadio VAR nRadio 3D SIZE 190, 11 PROMPT STR0025,STR0026 of oDlg PIXEL 					
	oRadio:SetEnable( .T. )
						
	DEFINE SBUTTON  oBut1 FROM 065,120 TYPE 1 OF oDlg ENABLE ACTION (nOpca := 1,oDlg:End())
	DEFINE SBUTTON  oBut2 FROM 065,150 TYPE 2 OF oDlg ENABLE ACTION (nOpca := 0,oDlg:End())	
	oBut2:SetFocus()						
	ACTIVATE MSDIALOG oDlg CENTERED  

	If nOpca == 1
		FwMsgRun( ,{|| TF65RedAdc(nRadio)} , STR0024 , STR0021 )  //Processando
	EndIf
EndIf

Return Nil


/*/{Protheus.doc} TMSAF60Rdp
Função do botao do Documento de Redespacho  
@type Function
@author Katia
@since 23/09/2020
@version P12 R12.1.30
*/
Function TMSAF60Rdp()
Local lRet := .T.
Local aArea:= GetArea()

If M->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. Val(M->DTQ_TIPVIA) == 5 
	SaveInter()
	TMF60LtRdp()
	RestInter()
Else
	Help( ,, 'HELP',, 'Opção disponivel somente para Viagem do Tipo Redespacho.' , 1, 0)	
	lRet:= .F.
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return lRet

/*{Protheus.doc} TMSAF60Doc
Visualização do documento da GRID
@type Function
@author Valdemar Roberto Mognon
@since 14/10/2020
@version P12 R12.1.30
@param 
@return Nil
*/
Function TMSAF60Doc()
Local lRet      := .T.

Private aRotina := {{"","",0,1,0,Nil},;
					{"","",0,2,0,Nil}}

TMSViewDoc(FwFldGet("DM3_FILDOC"),FwFldGet("DM3_DOC"),FwFldGet("DM3_SERIE"))

FwFreeArray(aRotina)

Return lRet

/*{Protheus.doc} TMF60LtRdp
Lista os Doc. relacionados a Redespachante, gatilhando os 
Doctos selecionados na viagem do tipo Redespacho.  
@type Function
@author Katia
@since 23/09/2020
@version P12 R12.1.30
@param oModel
@return Nil
Função extraida do fonte TMSA144.PRW (Tmsa144Rdp)
*/
Function TMF60LtRdp()
Local oDlgRed, oLbx1, oLbx2
Local aTitCab   := {}
Local aTitIte   := {}
Local aRedesp   := {}
Local aDoctos   := {}
Local aDoc      := {}
Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local lFindDoc  := .T.
Local nOpcA     := 0
Local aArea     := GetArea()
Local bClick    := { || Iif(TF60AVldCk(aRedesp,aRedesp[oLbx1:nAT,1],aRedesp[oLbx1:nAT,2],aRedesp[oLbx1:nAT,3],aRedesp[oLbx1:nAT,8]), aRedesp[oLbx1:nAT,7,oLbx2:nAT,1]:= !aRedesp[oLbx1:nAT,7,oLbx2:nAT,1],.F.), oLbx2:Refresh() }  // Iif(Len(aCompViag)>0,aRedesp[oLbx1:nAT,7,oLbx2:nAT,1]:= !aRedesp[oLbx1:nAT,7,oLbx2:nAT,1],.F.), oLbx2:Refresh() }
Local nA        := 0
Local lDoc      :=.T.
Local oAllMark
Local nX        := 0
Local nY        := 0
Local cSeekRed  := ""
Local nIndRed   := 1
Local cRedespAnt:= ""
Local aMsgErr   := {}
Local oModel    := FwModelActive()
Local oView     := FwViewActive()
Local oMdGrdDJN := oModel:GetModel("MdGridDJN")
Local oMdFldDTQ := oModel:GetModel("MdFieldDTQ")  
Local cSeqDJN   := StrZero(1,Len(DJN->DJN_SEQRDP)) 
Local nRecDUD   := 0
Local nFirst    := 1
Local lSeek     := .F.
Local lMarkAll  := .T.

If	oMarked == Nil
	oMarked := LoadBitmap( GetResources(),'LBOK')
EndIf
If	oNoMarked == Nil
	oNoMarked := LoadBitmap( GetResources(),'LBNO' )
EndIf

//-- Define os titulos do cabecalho.
AAdd( aTitCab, RetTitle( "DFT_NUMRED" ) )
AAdd( aTitCab, RetTitle( "DFT_CODFOR" ) )
AAdd( aTitCab, RetTitle( "DFT_LOJFOR" ) )
AAdd( aTitCab, RetTitle( "DFT_NOMFOR" ) )
AAdd( aTitCab, RetTitle( "DFT_NMREDU" ) )
AAdd( aTitCab, RetTitle( "DFT_QTDDOC" ) )

//-- Define os titulos dos itens.
AAdd( aTitIte, RetTitle( "DFV_NUMRED" ) )
AAdd( aTitIte, RetTitle( "DFV_ITEM"   ) )
AAdd( aTitIte, RetTitle( "DFV_STATUS" ) )
AAdd( aTitIte, RetTitle( "DFV_FILDOC" ) )
AAdd( aTitIte, RetTitle( "DFV_DOC"    ) )
AAdd( aTitIte, RetTitle( "DFV_SERIE"  ) )

cQuery := "SELECT DISTINCT DFV_FILORI, DFV_NUMRED "
cQuery += "FROM " + RetSqlName("DFV") + " DFV, " + RetSqlName("DUD") + " DUD "
cQuery += " WHERE DFV.DFV_FILIAL = '" + xFilial("DFV") + "' AND "
cQuery += " DFV.DFV_STATUS = '1' AND "
cQuery += " DFV.D_E_L_E_T_ = ' ' AND "
cQuery += " DUD.DUD_FILIAL = '" + xFilial("DUD") + "' AND "
cQuery += " DUD.DUD_FILDOC = DFV.DFV_FILDOC AND "
cQuery += " DUD.DUD_DOC    = DFV.DFV_DOC   AND "
cQuery += " DUD.DUD_SERIE  = DFV.DFV_SERIE AND "
cQuery += " DUD.DUD_FILORI ='" + cFilAnt + "' AND "
cQuery += " DUD.DUD_VIAGEM = ' ' AND "
cQuery += " DUD.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery ( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .F. )
While (cAlias)->(!Eof())
	cSeekRed:= TMSRetInd('DFT',(cAlias)->DFV_NUMRED,(cAlias)->DFV_FILORI,@nIndRed)
			
	DFT->(DbSetOrder(nIndRed))			
	If DFT->(DbSeek( xFilial("DFT") + cSeekRed ))
		AAdd( aRedesp, {	DFT->DFT_NUMRED,;
							DFT->DFT_CODFOR,;
							DFT->DFT_LOJFOR,;
							Posicione("SA2", 1, xFilial("SA2") + DFT->( DFT_CODFOR + DFT_LOJFOR ), "A2_NOME" ),;
							Posicione("SA2", 1, xFilial("SA2") + DFT->( DFT_CODFOR + DFT_LOJFOR ), "A2_NREDUZ" ),;
							DFT->DFT_QTDDOC,;
							{} ,;
							DFT->DFT_FILORI,;
							Posicione("SA2", 1, xFilial("SA2") + DFT->( DFT_CODFOR + DFT_LOJFOR ), "A2_PAGGFE" ),;
							DFT->DFT_CDTPOP,;
							DFT->DFT_CDCLFR,;
							DFT->DFT_UFORI,;
							DFT->DFT_CDMUNO,;
							DFT->DFT_CEPORI,;
							DFT->DFT_UFDES,;
							DFT->DFT_CDMUND,;
							DFT->DFT_CEPDES,;
							DFT->DFT_TIPVEI	 })
							
	EndIf
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

If Empty( aRedesp )
	Help(' ', 1, 'TMSA14421')	//-- "Não existem documentos em aberto no poder de Redespachantes."
	lFindDoc := .F.
EndIf

If lFindDoc

	ASort( aRedesp,,,{|x,y| x[1] < y[1] } )
	
	DEFINE MSDIALOG oDlgRed FROM 120,072 TO 660,1044 TITLE "Associação de Documentos por Redespachante"  OF oMainWnd PIXEL

	@ 015, 010 SAY "Redespachantes:" SIZE 50,7 OF oDlgRed PIXEL

	@ 240,010 CHECKBOX oAllMark VAR lMarkAll PROMPT "Inverte a Selecao" SIZE 168, 08;
	ON CLICK(Tmsa144Mak(oLbx1,oLbx2,@aRedesp)) OF oDlgRed PIXEL

	@ 035, 010 LISTBOX oLbx1 VAR cLbx1 FIELDS HEADER;
	aTitCab[1], aTitCab[2], aTitCab[3],	aTitCab[4],	aTitCab[5],	aTitCab[6],	SIZE 467,095 OF oDlgRed PIXEL
	oLbx1:SetArray( aRedesp )
	oLbx1:bChange  := { || aDoctos := {}, GatDocto(	aRedesp[oLbx1:nAT,1],;
												 	aRedesp[oLbx1:nAT,2],;
												 	aRedesp[oLbx1:nAT,3],;
												 	@aDoctos,oLbx2,oNoMarked,oMarked,@aRedesp,oLbx1:nAT,;
													aRedesp[oLbx1:nAT,8] ) }  

	oLbx1:bLine	:= { || {aRedesp[oLbx1:nAT,1],aRedesp[oLbx1:nAT,2],aRedesp[oLbx1:nAT,3],aRedesp[oLbx1:nAT,4],;
						aRedesp[oLbx1:nAT,5],aRedesp[oLbx1:nAT,6] } }

	@ 135, 010 SAY "Documentos por Redespachantes:" SIZE 120,7 OF oDlgRed PIXEL
	@ 145, 010 LISTBOX oLbx2 VAR cLbx2 FIELDS HEADER "", aTitIte[1],aTitIte[2],aTitIte[3],aTitIte[4],aTitIte[5],aTitIte[6],;
	        	SIZE 467,095 OF oDlgRed ON DBLCLICK ( Eval( bClick ) ) PIXEL

	oLbx2:SetArray( aDoctos )
		
	oLbx2:bLine	:= { || { Iif(	aRedesp[oLbx2:nAT,7,oLbx2:nAT,1] , oMarked, oNoMarked ),;
											aRedesp[oLbx2:nAT,7,oLbx2:nAT,2],;
											aRedesp[oLbx2:nAT,7,oLbx2:nAT,3],;
											aRedesp[oLbx2:nAT,7,oLbx2:nAT,4],;
											aRedesp[oLbx2:nAT,7,oLbx2:nAT,5],;
											aRedesp[oLbx2:nAT,7,oLbx2:nAT,6],;
											aRedesp[oLbx2:nAT,7,oLbx2:nAT,7] } } 											

	ACTIVATE MSDIALOG oDlgRed ON INIT EnchoiceBar(oDlgRed, {|| nOpcA := 1, oDlgRed:End() } , {|| oDlgRed:End()})
EndIf

For nX:=1 To Len(aRedesp)
	For nY:=1 To Len(aRedesp[nX][7]) 
		If aRedesp[nX][7][nY][1]
			AAdd( aDoc, { aRedesp[nX][7][nY][5],;  // Filial Docto 
						  aRedesp[nX][7][nY][6],;  // Docto
						  aRedesp[nX][7][nY][7] }) // Serie
		EndIf
	Next nY
Next nX

If nOpcA == 1
	DT6->(DbSetOrder( 1 ) )

	For nA := 1 To Len( aDoc )
		lDoc     := .T.
		cFilDoc  := aDoc[ nA, 1]
		cDoc     := aDoc[ nA, 2]
		cSerie   := aDoc[ nA, 3]

        cSeekTab := ""

		nRecDUD  := TMSFPosDUD(cFilDoc,cDoc,cSerie,'1')
		If nRecDUD > 0
			DUD->( DbGoTo( nRecDUD ))
		
			If lTmsRdpU 
				If !Empty(cRedespAnt) 
					If  DUD->DUD_NUMRED <> cRedespAnt 
						cSeekRed:= TMSRetInd('DFT',DUD->DUD_NUMRED,DUD->DUD_FILORI,@nIndRed)
						DFT->(DbSetOrder(nIndRed))			
						If DFT->(DbSeek( xFilial("DFT") + cSeekRed ))							
							//--- Verifica se o redespacho selecionado possui as mesmas caracteristicas do primeiro.
							If M->DTQ_CDTPOP <> DFT->DFT_CDTPOP .Or. ; 
								M->DTQ_CDCLFR <> DFT->DFT_CDCLFR .Or. ;
								M->DTQ_UFORI  <> DFT->DFT_UFORI .Or. ;
								M->DTQ_CDMUNO <> DFT->DFT_CDMUNO .Or. ;
								M->DTQ_CEPORI <> DFT->DFT_CEPORI .Or. ;
								M->DTQ_UFDES  <> DFT->DFT_UFDES .Or. ;
								M->DTQ_CDMUND <> DFT->DFT_CDMUND .Or. ;
								M->DTQ_CEPDES <> DFT->DFT_CEPDES .Or. ;
								M->DTQ_TIPVEI <> DFT->DFT_TIPVEI
									MsgAlert( "Lote Não Pertence Ao Conjunto de Agrupamentos Do(s) Redespacho(s) Selecionado(s) Anteriormente. Selecione Lotes Pertencentes Ao Mesmo Grupo De Redespacho para geração do Romaneio Unico.")  //"Lote Não Pertence Ao Conjunto de Agrupamentos Do(s) Redespacho(s) Selecionado(s) Anteriormente. Selecione Lotes Pertencentes Ao Mesmo Grupo De Redespacho para geração do Romaneio Unico."  
									lDoc:= .F.
									Exit
							EndIf	
						EndIf	
					EndIf
				EndIf
				cRedespAnt := DUD->DUD_NUMRED
			EndIf
					
			If lDoc
				lRet:= TF60AddDoc(cFilDoc,cDoc,cSerie,lSeek,oModel,oView,@aMsgErr,1)
				If !lRet
					If lSeek
						Aviso("Aviso" , "Fil. Docto" + cFilDoc + "Documento" + cDoc + "Série" + cSerie + "está contido nesta viagem." ,{"OK"})  //Está contido nesta viagem
					EndIf
					lDoc := .F.
					Exit
				EndIf
			EndIf

			If lDoc	.And. lTmsRdpU
				//--- Preenche campos para integracao GFE
				If nFirst == 1    //Somente a primeira vez
					cSeekRed:= TMSRetInd('DFT',DUD->DUD_NUMRED,DUD->DUD_FILORI,@nIndRed)
					DFT->(DbSetOrder(nIndRed))			
					If DFT->(DbSeek( xFilial("DFT") + cSeekRed ))	
						oMdFldDTQ:SetValue('DTQ_TIPVEI', DFT->DFT_TIPVEI)
						oMdFldDTQ:SetValue('DTQ_CDTPOP', DFT->DFT_CDTPOP)
						oMdFldDTQ:SetValue('DTQ_CDCLFR', DFT->DFT_CDCLFR)
						oMdFldDTQ:SetValue('DTQ_UFORI ', DFT->DFT_UFORI)
						oMdFldDTQ:SetValue('DTQ_CDMUNO', DFT->DFT_CDMUNO)
						oMdFldDTQ:SetValue('DTQ_CEPORI', DFT->DFT_CEPORI)
						oMdFldDTQ:SetValue('DTQ_UFDES ', DFT->DFT_UFDES)
						oMdFldDTQ:SetValue('DTQ_CDMUND', DFT->DFT_CDMUND)
						oMdFldDTQ:SetValue('DTQ_CEPDES', DFT->DFT_CEPDES)
						nFirst+= 1
					EndIf	
				EndIf
								
				DFV->( DbSetOrder ( 2 ) )
				If DFV->( DbSeek( xFilial('DFV') + DUD->( DUD_FILDOC + DUD_DOC + DUD_SERIE )  ) )
					nLine := oMdGrdDJN:Length()
                    cSeekTab := xFilial("DJO")+DFV->(DFV_FILORI+DFV_NUMRED+DFV_FILDOC+DFV_DOC+DFV_SERIE)
                    lRet := TMFAddDJN(oMdGrdDJN,"DFV",nLine,cSeqDJN,oModel,@aMsgErr,DFT->DFT_CODFOR, DFT->DFT_LOJFOR)			
				EndIf

				//--- Inclusao dos redespachos adicionais (DJO para DJN)
				If !Empty(cSeekTab)
					TMF60RdDJO(oMdGrdDJN,cSeekTab,cSeqDJN,oModel,@aMsgErr)					
				EndIf
			EndIf

			If ValType('oView') <> "U"
				oView:Refresh()
			EndIf

		EndIf			
	Next nA

EndIf

RestArea( aArea )
FwFreeArray( aArea )
FwFreeArray( aMsgErr )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GatDocto ºAutor  ³ Andre Godoi        º Data ³  20/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GatDocto( cNumRed, cCodFor, cLojFor, aDoctos, oLbx2, oNoMarked, oMarked, aRedesp, nX, cFilOri )
Local cAlias := GetNextAlias()

Default cFilOri:= ""

cQuery := "SELECT DFV.DFV_NUMRED, DFV.DFV_ITEM, DFV.DFV_STATUS, DFV.DFV_FILDOC, DFV.DFV_DOC, DFV.DFV_SERIE "
cQuery += ", DFV.DFV_FILORI, DFV.DFV_CDTPOP, DFV.DFV_CDCLFR, DFV.DFV_UFORI, DFV.DFV_CDMUNO, DFV.DFV_CEPORI, DFV.DFV_UFDES, DFV.DFV_CDMUND, DFV.DFV_CEPDES  "
cQuery += " FROM " + RetSqlName( "DFV" ) + " DFV," + RetSqlName( "DUD" ) + " DUD "
cQuery += " WHERE DFV.DFV_FILIAL = '" + xFilial("DFV") + "' AND"
cQuery += " DUD.DUD_FILIAL = '" + xFilial("DUD") + "' AND "
cQuery += " DUD.DUD_FILDOC = DFV.DFV_FILDOC AND "
cQuery += " DUD.DUD_DOC    = DFV.DFV_DOC    AND "
cQuery += " DUD.DUD_SERIE  = DFV.DFV_SERIE  AND "
cQuery += " DUD.DUD_STATUS = '" + StrZero(1, Len(DUD->DUD_STATUS)) + "' AND "
cQuery += " DFV.DFV_FILORI = '" + cFilOri + "' AND "
cQuery += " DFV.DFV_NUMRED = '" + cNumRed + "' AND "
cQuery += " DFV.DFV_CODFOR = '" + cCodFor + "' AND "
cQuery += " DFV.DFV_LOJFOR = '" + cLojFor + "' AND "
cQuery += " DFV.DFV_STATUS = '" + StrZero(1, Len(DFV->DFV_STATUS)) + "' AND "
cQuery += " DUD.DUD_VIAGEM = ' ' AND "
cQuery += " DUD.D_E_L_E_T_ = ' ' AND "
cQuery += " DFV.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery ( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .F. )
While (cAlias)->(!Eof())
      AAdd( aDoctos, {	.F.,;
						(cAlias)->DFV_NUMRED,;
						(cAlias)->DFV_ITEM,;
						'1',;					//-- Status do documento em aberto.
						(cAlias)->DFV_FILDOC,;
						(cAlias)->DFV_DOC,;
						(cAlias)->DFV_SERIE,;
						Iif(lTmsRdpU,(cAlias)->DFV_CDTPOP ,''),;						
						Iif(lTmsRdpU,(cAlias)->DFV_CDCLFR ,''),;
						Iif(lTmsRdpU,(cAlias)->DFV_UFORI  ,''),;
						Iif(lTmsRdpU,(cAlias)->DFV_CDMUNO ,''),;
						Iif(lTmsRdpU,(cAlias)->DFV_CEPORI ,''),;
						Iif(lTmsRdpU,(cAlias)->DFV_UFDES  ,''),;
						Iif(lTmsRdpU,(cAlias)->DFV_CDMUND ,''),;
						Iif(lTmsRdpU,(cAlias)->DFV_CEPDES ,'') })
	
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

oLbx2:SetArray(aDoctos)

If Empty(aRedesp[nX,7])
	aRedesp[nX,7] := aDoctos
EndIf

If !Empty( aDoctos )
   oLbx2:bLine	:= { || {	Iif(aRedesp[nX,7,oLbx2:nAT,1] , oMarked, oNoMarked ),;
								aRedesp[nX,7,oLbx2:nAT,2],;
								aRedesp[nX,7,oLbx2:nAT,3],;
								aRedesp[nX,7,oLbx2:nAT,4],;
								aRedesp[nX,7,oLbx2:nAT,5],;
								aRedesp[nX,7,oLbx2:nAT,6],;
								aRedesp[nX,7,oLbx2:nAT,7] } }
Else
   oLbx2:bLine	:= { || {	Iif(.F., oNoMarked, oNoMarked ),;
								"",;
								"",;
								"",;
								"",;
								"",;
								"" } } 
EndIf
oLbx2:Refresh()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TmsA144Mak³ Autor ³Andre Godoi            ³ Data ³29/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA144Mak                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa144Mak(oLbx1, oLbx2, aRedesp)
Local nX  := 1
Local lRet:= .T.

lRet:= TF60AVldCk(aRedesp,aRedesp[oLbx1:nAt][1],aRedesp[oLbx1:nAt][2],aRedesp[oLbx1:nAt][3],aRedesp[oLbx1:nAt][8])
If lRet
	
	For nX := 1 To Len(aRedesp[oLbx1:nAt][7])
		aRedesp[oLbx1:nAt][7][nX][1] := !aRedesp[oLbx1:nAt][7][nX][1]
	Next nX
	
	oLbx2:Refresh()
EndIf	

Return( lRet )


/*/-----------------------------------------------------------
{Protheus.doc} A144VldCk()
Valida a seleção do lote quando a integração com o TMSxGFE 
está ativo sendo necessario a informação do VeiculoxFornecedor
para atualizar os trechos do GFE 

Uso: TMSA144

@sample
//A144VldCk()

@author Katia Tiemi
@since 06/09/2017
@version 1.0
-----------------------------------------------------------/*/

Static Function TF60AVldCk(aRedesp,cNumRed,cCodFor,cLojFor,cFilOri)
Local lRet:= .T.
Local nX  := 0
Local nY  := 0
Local aAreaDFT:= DFT->(GetArea())

If lTmsRdpU 
		//-- Verifica se o Redespacho selecionado possui as mesmas caracteristicas.
		For nX:=1 To Len(aRedesp)
			For nY:=1 To Len(aRedesp[nX][7]) 
				If aRedesp[nX][7][nY][1]
					If aRedesp[nX][1] <> cNumRed
						//--- Verifica se o Redespacho possui as mesmas informações
						
						DFT->(DbSetOrder(2))			
						If DFT->(DbSeek( xFilial("DFT") + cFilOri + cNumRed + cCodFor + cLojFor ))
							If aRedesp[nX][10] <> DFT->DFT_CDTPOP .Or. ; 
								aRedesp[nX][11] <> DFT->DFT_CDCLFR .Or. ;
								aRedesp[nX][12] <> DFT->DFT_UFORI .Or. ;
								aRedesp[nX][13] <> DFT->DFT_CDMUNO .Or. ;
								aRedesp[nX][14] <> DFT->DFT_CEPORI .Or. ;
								aRedesp[nX][15] <> DFT->DFT_UFDES .Or. ;
								aRedesp[nX][16] <> DFT->DFT_CDMUND .Or. ;
								aRedesp[nX][17] <> DFT->DFT_CEPDES .Or. ;
								aRedesp[nX][18] <> DFT->DFT_TIPVEI
								
								MsgAlert("Lote Não Pertence Ao Conjunto de Agrupamentos Do(s) Redespacho(s) Selecionado(s) Anteriormente. Selecione Lotes Pertencentes Ao Mesmo Grupo De Redespacho para geração do Romaneio Unico.")  //"Lote Não Pertence Ao Conjunto de Agrupamentos Do(s) Redespacho(s) Selecionado(s) Anteriormente. Selecione Lotes Pertencentes Ao Mesmo Grupo De Redespacho para geração do Romaneio Unico."
								lRet:= .F.
								Exit 
							EndIf
						EndIf
							
					EndIf			
				EndIf
			Next nY
		Next nX

EndIf

RestArea(aAreaDFT)
Return lRet

/*
"Associação de Documentos por Redespachante"
"Redespachantes:"
"Inverte a Selecao"
"Documentos por Redespachantes:"
"Aviso"
"Fil. Docto"
"Documento"
"Série"
"está contido nesta viagem."
 "Lote Não Pertence Ao Conjunto de Agrupamentos Do(s) Redespacho(s) Selecionado(s) Anteriormente. Selecione Lotes Pertencentes Ao Mesmo Grupo De Redespacho para geração do Romaneio Unico."
 "Lote Não Pertence Ao Conjunto de Agrupamentos Do(s) Redespacho(s) Selecionado(s) Anteriormente. Selecione Lotes Pertencentes Ao Mesmo Grupo De Redespacho para geração do Romaneio Unico."
*/


/*/{Protheus.doc} TMSFPosDUD
//Posiciona no Ultimo DUD
@author Katia
@since 28/09/2020
@version 12.1.27
@param cFilDoc, cDoc, cSerie
@return nRecno
@type function
/*/
Function TMSFPosDUD(cFilDoc,cDoc,cSerie,cStatus)
Local cAliasQry := GetNextAlias()
Local cQuery    := ''
Local aAreaDUD  := DUD->(GetArea())
Local nRecDUD   := 0

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cStatus := ""

cQuery := " SELECT MAX(R_E_C_N_O_) DUDRecNo"
cQuery += " FROM " + RetSqlTab("DUD")
cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD")  + "'"
cQuery += "   AND DUD.DUD_FILDOC = '" + cFilDoc + "'"
cQuery += "   AND DUD.DUD_DOC    = '" + cDoc    + "'"
cQuery += "   AND DUD.DUD_SERIE  = '" + cSerie  + "'"
If !Empty(cStatus)
	cQuery += "   AND DUD.DUD_STATUS = '" + cStatus + "'"
Else
	cQuery += "   AND DUD.DUD_STATUS <> '9' "   //Cancelado
EndIf
cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )
If (cAliasQry)->(!Eof()) 
	nRecDUD:= (cAliasQry)->DUDRecNo 
EndIf
(cAliasQry)->(dbCloseArea())

RestArea(aAreaDUD)
Return nRecDUD

/*/{Protheus.doc} TMF60RdDJO
//Inclusao dos redespachos adicionais (DJO para DJN)
@author Katia
@since 28/09/2020
@version 12.1.27
@param 
@return Nil
@type function
/*/
Static Function TMF60RdDJO(oMdGrdDJN,cSeekTab,cSeqDJN,oModel,aMsgErr)
Local nLine     := 1
Local aArea     := GetArea()
Local aSaveLine	:= FWSaveRows()
Local lRet      := .T.

Default cSeekTab:= ""
Default cSeqDJN := StrZero(1,Len(DJN->DJN_SEQRDP)) 

If !Empty(cSeekTab)
    nLine:= oMdGrdDJN:Length()

	DJO->(dbSetOrder(1))
	If DJO->(MsSeek(cSeekTab))
		Do While !DJO->(Eof()) .And. DJO->(DJO_FILIAL+DJO_FILORI+DJO_NUMRED+DJO->DJO_FILDOC+DJO->DJO_DOC+DJO->DJO_SERIE) == cSeekTab
			cSeqDJN:= Soma1(cSeqDJN)
            
            lRet:= TMFAddDJN(oMdGrdDJN,"DJO",nLine,cSeqDJN,oModel,@aMsgErr)			

			DJO->(dbSkip())
		EndDo
	EndIf
EndIf

FwRestRows( aSaveLine )
RestArea(aArea)
Return

/*/{Protheus.doc} TMFAddDJN
//Adiciona dados na Grid DJN 
@author Katia
@since 28/09/2020
@version 12.1.27
@param 
@return Nil
@type function
/*/

Static Function TMFAddDJN(oMdGrdDJN,cAlias,nLine,cSeqDJN,oModel,aMsgErr,cCodFor,cLojFor)

Local lRet := .T.

Default cCodFor:= ""
Default cLojFor:= ""
	
    oMdGrdDJN:GoLine(nLine)   
	If !oMdGrdDJN:IsEmpty()
		oMdGrdDJN:AddLine()
	EndIf

	oMdGrdDJN:SetValue("DJN_SEQRDP", cSeqDJN)
	oMdGrdDJN:SetValue("DJN_CODFOR", Iif(cAlias == "DFV",cCodFor,DJO->DJO_CODFOR))
	oMdGrdDJN:SetValue("DJN_LOJFOR", Iif(cAlias == "DFV",cLojFor,DJO->DJO_LOJFOR))
	oMdGrdDJN:SetValue("DJN_UFORI",  Iif(cAlias == "DFV",DFV->DFV_UFORI ,DJO->DJO_UFORI))
	oMdGrdDJN:SetValue("DJN_CDMUNO", Iif(cAlias == "DFV",DFV->DFV_CDMUNO,DJO->DJO_CDMUNO))
	oMdGrdDJN:SetValue("DJN_CEPORI", Iif(cAlias == "DFV",DFV->DFV_CEPORI,DJO->DJO_CEPORI))
	oMdGrdDJN:SetValue("DJN_UFDES",  Iif(cAlias == "DFV",DFV->DFV_UFDES ,DJO->DJO_UFDES ))
	oMdGrdDJN:SetValue("DJN_CDMUND", Iif(cAlias == "DFV",DFV->DFV_CDMUND,DJO->DJO_CDMUND))
	oMdGrdDJN:SetValue("DJN_CEPDES", Iif(cAlias == "DFV",DFV->DFV_CEPDES,DJO->DJO_CEPDES))
	oMdGrdDJN:SetValue("DJN_TIPVEI", Iif(cAlias == "DFV",DFV->DFV_TIPVEI,DJO->DJO_TIPVEI))
	oMdGrdDJN:SetValue("DJN_CDTPOP", Iif(cAlias == "DFV",DFV->DFV_CDTPOP,DJO->DJO_CDTPOP))
	oMdGrdDJN:SetValue("DJN_CDCLFR", Iif(cAlias == "DFV",DFV->DFV_CDCLFR,DJO->DJO_CDCLFR))

	lRet:= oMdGrdDJN:VldLineData()    
	If !lRet
		oMdGrdDJN:DeleteLine()
	EndIf

Return lRet

/*/{Protheus.doc} TF60VisRed
//Visualiza o Lote de Redespacho
@author Katia
@since 24/05/2021
@version 12.1.33
@param 
@return Nil
@type function
/*/
Function TF60VisRed()
Local aArea:= GetArea()
	
	DFT->(DbSetOrder(2))			
	If DFT->(DbSeek( xFilial("DFT") + DFV->DFV_FILORI + DFV->DFV_NUMRED ))
		FWExecView (, "TMSAR05" , MODEL_OPERATION_VIEW , ,{|| .T. }, , , , , , ,  ) 	
	EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return
