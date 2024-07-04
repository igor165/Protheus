#Include 'Protheus.ch'
#Include 'OFICSC01.ch'

#DEFINE X3_USADO_EMUSO "€€€€€€€€€€€€€€ "	// TORNA USADO POR TODOS OS MODULOS

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFICSC01   | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Informacoes de Garantia de um Chassi                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFICSC01(lNoMBrowse,nOpcAux,aRetorno,lImporta)

Default lNoMBrowse := .f.
Default lImporta := .f.

Private cCadastro := STR0001
Private aRotina := MenuDef()

If !AMIIn(14)
	Return
EndIf

//AADD(aRegs,{STR0022,STR0022,STR0022,'MV_CH1','C',02,0,,'G','Vazio().or.Existcpo("SX5","DJ"+MV_PAR01)','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','DJ' ,'','','','@!',{},{},{}}) // Operacao
//AADD(aRegs,{STR0023,STR0023,STR0023,'MV_CH2','C',03,0,,'G','Vazio().or.ExistCPO("SF4",MV_PAR02,1)'   ,'MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','SF4','','','','@!',{},{},{}}) // TES
//AADD(aRegs,{STR0024,STR0024,STR0024,'MV_CH3','C',01,0,,'G','Vazio().or.Existcpo("SX5","VF"+MV_PAR03)','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','VF' ,'','','','@!',{},{},{}}) // Depto. Garantia
//AADD(aRegs,{STR0025,STR0025,STR0025,'MV_CH4','C',03,0,,'G','Vazio().or.ExistCPO("VOK",MV_PAR04)'     ,'MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','VOK','','','','@!',{},{},{}}) // Tipo Serviço
//AADD(aRegs,{STR0026,STR0026,STR0026,'MV_CH5','C',03,0,,'G','Vazio().or.ExistCPO("VOD",MV_PAR05)'     ,'MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','VOD','','','','@!',{},{},{}}) // Cod. Seção
//AADD(aRegs,{STR0027,STR0027,STR0027,'MV_CH6','C',60,0,,'G',''                                        ,'MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','',''   ,'','','','@!',{"Informe os tipo de veiculos","que serão considerados como","caminhão. (VV2_TIPVEI)","Informar valores separados por '/'"},{},{}}) // Tipo de Veiculo - Caminhao
//AADD(aRegs,{STR0028,STR0028,STR0028,'MV_CH7','C',60,0,,'G',''                                        ,'MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','',''   ,'','','','@!',{"Informe os tipo de veiculos","que serão considerados como","onibus. (VV2_TIPVEI)","Informar valores separados por '/'"},{},{}}) // Tipo de Veiculo - Onibus
//AADD(aRegs,{STR0029,STR0029,STR0029,'MV_CH8','C',60,0,,'G',''                                        ,'MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','',''   ,'','','','@!',{"Informe os tipo de veiculos","que serão considerados como","motor industrial/maritimo. (VV2_TIPVEI)","Informar valores separados por '/'"},{},{}}) // Tipo de Veiculo - Motor Ind./Maritimo
//AADD(aRegs,{STR0030,STR0030,STR0030,'MV_CH9','C',60,0,,'G',''                                        ,'MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','',''   ,'','','','@!',{"Informe os grupos de peças ","que serão utilizados para  ","consulta no cadastro de produto (SB1)","Informar valores separados por '/'"},{},{}})
Pergunte("OFICSC01",.f.,,,,.f.)

SetKey(VK_F12,{ || Pergunte( "OFICSC01" , .T. ,,,,.f.)})

dbSelectArea("VV1")
If lNoMBrowse
	If ( nOpcAux <> 0 ) .And. !Deleted()
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpcAux,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpcAux,@aRetorno,lImporta)
	EndIf
Else
	mBrowse( 6, 1,22,75,"VV1",,,,,,,,,,,,,,(" VV1_CODMAR='"+FMX_RETMAR("SCA")+"' "))
EndIf
//

SetKey(VK_F12,Nil)

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFCSC01CLA | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Campanha de um Chassi Scania                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFCSC01CLA(cAlias,nReg,nOpc,aRetorno,lImporta)

Local oBrowser
Local oSizePrinc
Local cURL
Local aHCamp := {}
Local nCont
Local aParam := StrTokArr(GetMV("MV_MIL0004"),"¨")

Local lClawBrowser := .t. // Indica se o Claw sera aberto no browse externo

Default aRetorno := {}
Default lImporta := .f.

Private oWS
Private lOk := .f.

If Empty(VV1->VV1_CHARED)
	MsgStop(STR0009,STR0031) // "Veículo sem número de chassi reduzido"
	Return .f.
EndIf

// Requisita um Token de Conexao ...
If !OFCSC01TOK(@oWS)
	Return .f.
EndIf
//

cURL := aParam[4] + '?t=' + oWS:oWSGetSSOTokenResult:cSSOToken + ;
	"&cn?=" + ALlTrim(VV1->VV1_CHARED)

// Calculo da Janela Principal
oSizePrinc := FwDefSize():New(.t.)
//
DEFINE MSDIALOG oDlgClaw TITLE STR0004 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]
	
//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botão de fechar
oLayer := FWLayer():new()
oLayer:Init(oDlgClaw,.f.)

//Cria as colunas do Layer
oLayer:addCollumn('Browser',85,.F.)  
oLayer:addCollumn('Campanha',14.5,.T.)

//Adiciona Janelas as colunas
If lClawBrowser
	oLayer:addWindow('Browser' ,'Browser_W02' ,STR0008,100,.T.,.F., /* bAction */ ,, /* bGotFocus */ )	// "Detalhes da Campanha"
Else
	oLayer:addWindow('Browser' ,'Browser_W01' ,STR0003,070,.T.,.F., /* bAction */ ,, /* bGotFocus */ )	// "Claw"
	oLayer:addWindow('Browser' ,'Browser_W02' ,STR0008,030,.T.,.F., /* bAction */ ,, /* bGotFocus */ )	// "Detalhes da Campanha"
EndIf

oLayer:addWindow('Campanha','Campanha_W01',STR0005,070,.F.,.F., /* bAction */ ,, /* bGotFocus */ )	// "Utilizar"
oLayer:addWindow('Campanha','Campanha_W02',STR0007,030,.F.,.F., /* bAction */ ,, /* bGotFocus */ )	// "Opções"

//Coloca o botão de split na coluna
oLayer:setColSplit('Campanha',CONTROL_ALIGN_LEFT)
//

// Cria getDados para usuario informar as campanhas que serão consultadas 	
M->CAMPANHA := Space(8)
aCols := { { M->CAMPANHA , .f. } }
AADD( aHCamp , { STR0006, "CAMPANHA" , "@!", 8 , 0, "AllWaysTrue()", X3_USADO_EMUSO , "C", "   ", "R", "", "" })
oGetCamp := MsNewGetDados():New( 0,0,0,0,;
		    (GD_INSERT+GD_UPDATE+GD_DELETE),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
		    "AllwaysTrue()",;
		    "AllwaysTrue()",;
		    ,;		// Nome dos campos do tipo caracter que utilizacao incremento automatico
		    { "CAMPANHA" } ,; 	// Campos alteraveis da GetDados
		    /*nFreeze*/,;	// Campos estaticos da GetDados
		    999,;
		    "AllwaysTrue()",;
		    /*cSuperDel*/,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
		    /* cDelOk */ ,; 		// Funcao executada para validar a exclusao de uma linha
		    oLayer:getWinPanel('Campanha','Campanha_W01' ),;
		    aHCamp,;
		    aCols)
oGetCamp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
//

// Cria botoes de Opcoes
oWBtn := oLayer:getWinPanel('Campanha','Campanha_W02' )

oBtnDetalhe := TButton():Create( oLayer:getWinPanel('Campanha','Campanha_W02' ) , ;
	2 , 2 ,;
	STR0010 ,{ || OFCSC01DET() },;
	Int( oWBtn:nClientWidth / 2 ) - 6,10,;
	,,,.T.,,STR0011,,,,) // "Detalhar Campanhas" / "Consulta detalhes das campanhas informadas no browse"

oBtnUtilizar := TButton():Create( oLayer:getWinPanel('Campanha','Campanha_W02' ) , ;
	14 , 2 ,;
	STR0012,{ || OFCSC01CMP(@aRetorno) },;
	Int( oWBtn:nClientWidth / 2 ) - 6,10,;
	,,,.t.,,STR0013,,{ || lImporta } ,,) // "Utilizar Campanhas" / "Utiliza campanhas informadas no browse"

oBtnSair := TButton():Create( oLayer:getWinPanel('Campanha','Campanha_W02' ) , ;
	26 , 2 ,;
	STR0014,{ || lOk := .f. , oDlgClaw:End() },;
	Int( oWBtn:nClientWidth / 2 ) - 6,10,;
	,,,.T.,,STR0014,,,,) // "Sair"
//
oWBtn := oLayer:getWinPanel('Browser','Browser_W02')
oFDet := TFolder():New( 2 , 2 ,;
						{ STR0015 , STR0016 } , , oLayer:getWinPanel('Browser','Browser_W02' ) , , , , .t. , ,;
						Int( oWBtn:nClientWidth / 2 ) - 6 ,;
						Int( oWBtn:nClientHeight / 2 ) - 6 ) // "Peças" / "Serviços"
oFDet:Align := CONTROL_ALIGN_ALLCLIENT
						
//////////////////////////////
// Monta GetDados das pecas //
//////////////////////////////
aCpoPec := {}
AADD( aCpoPec , "VS3_GRUITE" )
AADD( aCpoPec , "VS3_CODITE" )
AADD( aCpoPec , "VS3_DESITE" )
AADD( aCpoPec , "VS3_QTDITE" )
AADD( aCpoPec , "VS3_QTDEST" )
AADD( aCpoPec , "VS3_OPER"   )
AADD( aCpoPec , "VS3_CODTES" )
AADD( aCpoPec , "VS3_DEPGAR" )

aHPeca := {}
aAlter := {}

AADD( aHPeca , { STR0006, "PEC_CAMPAN" , "@!", 6 , 0 , "AllWaysTrue()",	X3_USADO_EMUSO , "C" , "   " , "R",	"",	"" })
M->PEC_CAMPAN := Space(aHPeca[1,4]) 

SX3->(dbSetOrder(2))
For nCont := 1 to Len(aCpoPec)

	cAuxCpo := "PEC_" + Right(aCpoPec[nCont],Len(aCpoPec[nCont])-4)

	SX3->(dbSeek(aCpoPec[nCont]))
	AADD( aHPeca , { AllTrim(X3Titulo()), cAuxCpo ,	SX3->X3_PICTURE, 	SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,     "AllWaysTrue()",		X3_USADO_EMUSO , 	SX3->X3_TIPO,;
					SX3->X3_F3,		  "R",			"",	 				"" })
					
	AADD(aAlter,cAuxCpo)
	
	wVar  := "M->"+cAuxCpo
	&wVar := CriaVar(SX3->X3_CAMPO,.f.)
	
	wVar := "M->"+aCpoPec[nCont]
	&wVar := CriaVar(SX3->X3_CAMPO,.f.)
	
Next nCont

aCols := {}
// Adiciona linha em branco na aCols
If Len(aCols) == 0
	AADD(aCols,Array(Len(aHPeca)+1))
	For nCont := 1 to Len(aHPeca)
		wVar  := "M->"+aHPeca[nCont,2]
		aCols[1,nCont] := &wVar
	Next nCont
	aCols[1,Len(aCols[1])] := .f.
EndIf
//

cLinOk   := "AllwaysTrue()"
cTudoOk  := "AllwaysTrue()"
cFieldOk := "OFCSC01FOK()"

oGetPeca := MsNewGetDados():New( 2,2,10,10,;
		(GD_INSERT+GD_UPDATE+GD_DELETE),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
		cLinOk,;
		cTudoOk,;
		,;		// Nome dos campos do tipo caracter que utilizacao incremento automatico
		aAlter ,; 	// Campos alteraveis da GetDados
		/*nFreeze*/,;	// Campos estaticos da GetDados
		999,;
		cFieldOk,;
		/*cSuperDel*/,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
		/* cDelOk */ ,; 		// Funcao executada para validar a exclusao de uma linha
		oFDet:aDialogs[1],;
		aHPeca,;
		aCols)
oGetPeca:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetPeca:oBrowse:bChange := {|| FG_MEMVAR(oGetPeca:aHeader,oGetPeca:aCols,oGetPeca:nAt) }
//

////////////////////////////////
// Monta GetDados de Servicos //
////////////////////////////////
aCpoSrv := {}
AADD( aCpoSrv , "VS4_GRUSER" )
AADD( aCpoSrv , "VS4_CODSER" )
AADD( aCpoSrv , "VS4_DESSER" )
AADD( aCpoSrv , "VS4_TEMPAD" )
AADD( aCpoSrv , "VS4_TIPSER" )
AADD( aCpoSrv , "VS4_DEPGAR" )
AADD( aCpoSrv , "VS4_CODSEC" )

aHSrvc := {}
aAlter := {}

AADD( aHSrvc , { STR0006, "SER_CAMPAN" , "@!", 6 , 0 , "AllWaysTrue()",	X3_USADO_EMUSO , "C" , "   " , "R",	"",	"" })
M->SER_CAMPAN := Space(aHPeca[1,4]) 

SX3->(dbSetOrder(2))
For nCont := 1 to Len(aCpoSrv)

	cAuxCpo := "SER_" + Right(aCpoSrv[nCont],Len(aCpoSrv[nCont])-4)

	SX3->(dbSeek(aCpoSrv[nCont]))
	AADD( aHSrvc , { AllTrim(X3Titulo()), cAuxCpo ,	SX3->X3_PICTURE, 	SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,     "AllWaysTrue()",		X3_USADO_EMUSO , 	SX3->X3_TIPO,;
					SX3->X3_F3,		  	 "R",			"",	 				"" })
					
	AADD(aAlter,cAuxCpo)

	wVar  := "M->"+cAuxCpo
	&wVar := CriaVar(SX3->X3_CAMPO,.f.)
	
	wVar := "M->"+aCpoSrv[nCont]		
	&wVar := CriaVar(SX3->X3_CAMPO,.f.)		
	
Next nCont

aCols := {}

// Adiciona linha em branco na aCols
If Len(aCols) == 0
	AADD(aCols,Array(Len(aHSrvc)+1))
	For nCont := 1 to Len(aHSrvc)
		wVar  := "M->"+aHSrvc[nCont,2]
		aCols[1,nCont] := &wVar
	Next nCont
	aCols[1,Len(aCols[1])] := .f.
EndIf
//

cLinOk   := "AllwaysTrue()"
cTudoOk  := "AllwaysTrue()"
cFieldOk := "AllwaysTrue()"

oGetSrvc := MsNewGetDados():New(  2,2,10,10,;
		(GD_INSERT+GD_UPDATE+GD_DELETE),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
		cLinOk,;
		cTudoOk,;
		,;		// Nome dos campos do tipo caracter que utilizacao incremento automatico
		aAlter ,; 	// Campos alteraveis da GetDados
		/*nFreeze*/,;	// Campos estaticos da GetDados
		999,;
		cFieldOk,;
		/*cSuperDel*/,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
		/* cDelOk */ ,; 		// Funcao executada para validar a exclusao de uma linha
		oFDet:aDialogs[2],;
		aHSrvc,;
		aCols)
oGetSrvc:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetSrvc:oBrowse:bChange := {|| FG_MEMVAR(oGetSrvc:aHeader,oGetSrvc:aCols,oGetSrvc:nAt) }

If lClawBrowser
	ShellExecute( "Open", cURL , "", "C:\", 1 )
Else
	// cria objeto de Browser 
	oBrowser := TIBrowser():New( 0 , 0 , 100 , 100 , cURL ,oLayer:getWinPanel('Browser','Browser_W01' ) )
	oBrowser:Align := CONTROL_ALIGN_ALLCLIENT
	//
EndIf


ACTIVATE MSDIALOG oDlgClaw

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFCSC01CMP | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Retorna informacoes das campanhas selecionadas               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OFCSC01CMP(aRetorno)

Local nAuxPos
Local nCont

aRetorno := {{},{},{}}

// Retornar pecas / ambos
If Len(oGetPeca:aCols) > 1 .or. !Empty(oGetPeca:aCols[1,1])

	// Adiciona na primeira posicao as campanhas retornadas ...
	nAuxPos := FG_POSVAR("PEC_CAMPAN","oGetPeca:aHeader")
	For nCont := 1 to Len(oGetPeca:aCols)
		If aScan(aRetorno[1],oGetPeca:aCols[nCont,nAuxPos]) == 0
			AADD(aRetorno[1],oGetPeca:aCols[nCont,nAuxPos])
		EndIf
	Next nCont
	//
	
	AADD( aRetorno[2] , aClone(oGetPeca:aHeader) )
	AADD( aRetorno[2] , aClone(oGetPeca:aCols) )
EndIf
//

// Retornar servico / ambos
If Len(oGetSrvc:aCols) > 1 .or. !Empty(oGetSrvc:aCols[1,1])

	// Adiciona na primeira posicao as campanhas retornadas ...
	nAuxPos := FG_POSVAR("SER_CAMPAN","oGetSrvc:aHeader")
	For nCont := 1 to Len(oGetSrvc:aCols)
		If aScan(aRetorno[1],oGetSrvc:aCols[nCont,nAuxPos]) == 0
			AADD(aRetorno[1],oGetSrvc:aCols[nCont,nAuxPos])
		EndIf
	Next nCont
	//
	
	AADD( aRetorno[3] , aClone(oGetSrvc:aHeader) )
	AADD( aRetorno[3] , aClone(oGetSrvc:aCols) )
EndIf
//

oDlgClaw:End()

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFCSC01TOK | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Requisita um Token de Conexao com o Web Service              |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFCSC01TOK(oAuxWS)

If !GM060VLDPSW()
	Return .f.
EndIf

// Solicita um token de conexao ...
oAuxWS := WSMIL_ScaniaClaw():New()
//oAuxWS:SetDebug()

lProcessado:= .f.
MsgRun(STR0017,STR0018,{|| lProcessado := oAuxWS:GetSSOToken() })  // "Requisitando Token" / "Processando"
If !lProcessado
	oAuxWS:ExibeErro("GetSSOToken")
	Return .f.
EndIf
If oAuxWS:oWSGetSSOTokenResult:cresultCode <> "00"
	MsgInfo(oAuxWS:oWSGetSSOTokenResult:cdescription)
	Return .f.
EndIf

Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFCSC01DET | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Informacoes da Campanha no Web Service              |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OFCSC01DET()

Local nPos
Local nCont
Local nPosReq
Local nCntFor

oWS:oWScampaign:oWScampRec := MIL_ScaniaClaw_ArrayOfcampCampRec():New()

Pergunte("OFICSC01",.f.,,,,.f.)

VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI))

For nPos := 1 to Len(oGetCamp:aCols)

	If oGetCamp:aCols[nPos,Len(oGetCamp:aCols[nPos])]
		Loop
	EndIf

	oWS:oWScampaign:oWScampRec:AddCamp()
	oWS:oWScampaign:oWScampRec:oWScampCampRec[nPos]:ccustNo     := GetNewPar("MV_MIL0005","") //"00221"
	oWS:oWScampaign:oWScampRec:oWScampCampRec[nPos]:cchassiNo   := AllTrim(VV1->VV1_CHARED)
	oWS:oWScampaign:oWScampRec:oWScampCampRec[nPos]:ccampNo     := AllTrim(oGetCamp:aCols[nPos,1])
	oWS:oWScampaign:oWScampRec:oWScampCampRec[nPos]:cnationCode := "BR"
	oWS:oWScampaign:oWScampRec:oWScampCampRec[nPos]:crepDate    := FormatDate(dDataBase)
	//oWS:oWScampaign:oWScampRec:oWScampCampRec[nPos]:cSpCostLimitCurrency := 
	
	// Caminhao
	If VV2->VV2_TIPVEI $ AllTrim(MV_PAR06)
		oWS:oWScampaign:oWScampRec:oWScampCampRec[nPos]:cprodType := "1"
	// Onibus
	ElseIf VV2->VV2_TIPVEI $ AllTrim(MV_PAR07)
		oWS:oWScampaign:oWScampRec:oWScampCampRec[nPos]:cprodType := "2"
	// Montor Industrial / Maritimo
	ElseIf VV2->VV2_TIPVEI $ AllTrim(MV_PAR08)
		oWS:oWScampaign:oWScampRec:oWScampCampRec[nPos]:cprodType := "3"
	EndIf
	//
	
	If Empty(oWS:oWScampaign:oWScampRec:oWScampCampRec[nPos]:cprodType)
		MsgStop(STR0032 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0033 + ": " + VV2->VV2_TIPVEI ) // "Não foi possível identificar o tipo do veiculo." / "Tipo do veiculo (VV2_TIPVEI)"
		Return
	EndIf
	
Next nPos

lProcessado:= .f.
MsgRun(STR0019,STR0018,{|| lProcessado := oWS:GetCampaignDetails() }) // "Requisitando Detalhamento de Campanha"
If !lProcessado
	oWS:ExibeErro("GetCampaignDetails")
	Return
EndIf


nTamCodIte := TamSX3("VS3_CODITE")[1]
nTamCodSer := TamSX3("VO6_CODSER")[1]

If Empty(MV_PAR09)
	MV_PAR09 := "SCG/SCC"
EndIf
cSQLSB1 := "SELECT R_E_C_N_O_ FROM " + RetSQLName("SB1") + " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND B1_GRUPO IN " + FormatIN(AllTrim(MV_PAR09),"/") + " AND B1_CODITE = '#CODITE' AND D_E_L_E_T_ = ' '"
cSQLVO6 := "SELECT R_E_C_N_O_ FROM " + RetSQLName("VO6") + " WHERE VO6_FILIAL = '" + xFilial("VO6") + "' AND VO6_CODSER = '#CODSER' AND D_E_L_E_T_ = ' '"

oGetPeca:aCols := {}
oGetSrvc:aCols := {}

For nCont := 1 to Len(oWS:oWSGetCampaignDetailsResult:oWScampRRec:oWScampReplyCampRRec)

	oAuxObj := oWS:oWSGetCampaignDetailsResult:oWScampRRec:oWScampReplyCampRRec[nCont]
	
	// ----------------- //
	// Processando Pecas //
	// ----------------- //
	For nPosReq := 1 to Len(oAuxObj:oWSCampPart:oWSCampReplyCampRRecCampPart)
	
		oAuxObjPec := oAuxObj:oWSCampPart:oWSCampReplyCampRRecCampPart[nPosReq]
		
		// Procura peca ...
		nAuxRecno := FM_SQL(StrTran(cSQLSB1,"#CODITE",PadR(oAuxObjPec:cPartNo,nTamCodIte) ))
		If nAuxRecno == 0
			MsgInfo(STR0020,STR0031) // "Peça não encontrada"
			Loop
		EndIf
		//
		
		AADD(oGetPeca:aCols,Array(Len(oGetPeca:aHeader)+1))
		oGetPeca:aCols[Len(oGetPeca:aCols),Len(oGetPeca:aHeader)+1]:=.F.
		For nCntFor := 2 to Len(oGetPeca:aHeader)
			oGetPeca:aCols[Len(oGetPeca:aCols),nCntFor] := CriaVar(StrTran(oGetPeca:aHeader[nCntFor,2],"PEC_","VS3_"))
		Next
		oGetPeca:nAt := Len(oGetPeca:aCols)
		n := oGetPeca:nAt
		
		SB1->(dbGoTo(nAuxRecno))
		SB1->(dbSetOrder(1))
		
		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ))
		
		oGetPeca:aCols[ oGetPeca:nAt , FG_POSVAR("PEC_CAMPAN","oGetPeca:aHeader") ] := oAuxObj:cCampNO
		oGetPeca:aCols[ oGetPeca:nAt , FG_POSVAR("PEC_GRUITE","oGetPeca:aHeader") ] := SB1->B1_GRUPO
		oGetPeca:aCols[ oGetPeca:nAt , FG_POSVAR("PEC_CODITE","oGetPeca:aHeader") ] := oAuxObjPec:cPartNo
		oGetPeca:aCols[ oGetPeca:nAt , FG_POSVAR("PEC_DESITE","oGetPeca:aHeader") ] := SB1->B1_DESC
		oGetPeca:aCols[ oGetPeca:nAt , FG_POSVAR("PEC_QTDITE","oGetPeca:aHeader") ] := Val(oAuxObjPec:cQty)
		oGetPeca:aCols[ oGetPeca:nAt , FG_POSVAR("PEC_QTDEST","oGetPeca:aHeader") ] := SaldoSB2()
		
		// Operacao 
		If !Empty(MV_PAR01)
			oGetPeca:aCols[ oGetPeca:nAt , FG_POSVAR("PEC_OPER"  ,"oGetPeca:aHeader") ] := MV_PAR01
		EndIf
		// TES
		If !Empty(MV_PAR02)
			oGetPeca:aCols[ oGetPeca:nAt , FG_POSVAR("PEC_CODTES","oGetPeca:aHeader") ] := MV_PAR02
		EndIf
		// Depto. Garantia 
		If !Empty(MV_PAR03)
			oGetPeca:aCols[ oGetPeca:nAt , FG_POSVAR("PEC_DEPGAR","oGetPeca:aHeader") ] := MV_PAR03
		EndIf
		//
		
	Next nPosReq
	//
	
	// -------------------- //
	// Processando Servicos //
	// -------------------- //
	For nPosReq := 1 to Len(oAuxObj:oWSCampOp:oWScampReplyCampRRecCampOp)
	
		oAuxObjSer := oAuxObj:oWSCampOp:oWScampReplyCampRRecCampOp[nPosReq]
		
		// Procura Servico ...
		nAuxRecno := FM_SQL(StrTran(cSQLVO6,"#CODSER",PadR(oAuxObjSer:copCode,nTamCodSer)))
		If nAuxRecno == 0
			MsgInfo(STR0021,STR0031) // "Serviço não encontrado"
			Loop
		EndIf
		// 
		
		VO6->(DbGoTo(nAuxRecno))
		VO6->(dbSetOrder(1))
		
		AADD( oGetSrvc:aCols, Array(Len(oGetSrvc:aHeader)+1))
		oGetSrvc:aCols[Len(oGetSrvc:aCols),Len(oGetSrvc:aHeader)+1] := .f.
		For nCntFor := 2 to Len(oGetSrvc:aHeader)
			oGetSrvc:aCols[Len(oGetSrvc:aCols),nCntFor] := CriaVar(StrTran(oGetSrvc:aHeader[nCntFor,2],"SER_","VS4_"))
		Next nCntFor
		oGetSrvc:nAt := Len(oGetSrvc:aCols)
		n := oGetSrvc:nAt

		oGetSrvc:aCols[ oGetSrvc:nAt , FG_POSVAR("SER_CAMPAN","oGetSrvc:aHeader") ] := oAuxObj:cCampNO
		oGetSrvc:aCols[ oGetSrvc:nAt , FG_POSVAR("SER_GRUSER","oGetSrvc:aHeader") ] := VO6->VO6_GRUSER
		oGetSrvc:aCols[ oGetSrvc:nAt , FG_POSVAR("SER_CODSER","oGetSrvc:aHeader") ] := VO6->VO6_CODSER
		oGetSrvc:aCols[ oGetSrvc:nAt , FG_POSVAR("SER_DESSER","oGetSrvc:aHeader") ] := VO6->VO6_DESSER
		oGetSrvc:aCols[ oGetSrvc:nAt , FG_POSVAR("SER_TEMPAD","oGetSrvc:aHeader") ] := (Val(oAuxObjSer:cQty) * oAuxObjSer:ntime) * 100
		
		// Tipo Serviço
		If !Empty(MV_PAR04)
			oGetSrvc:aCols[ oGetSrvc:nAt , FG_POSVAR("SER_TIPSER","oGetSrvc:aHeader") ] := MV_PAR04
		EndIf
		// Depto. Garantia
		If !Empty(MV_PAR03)
			oGetSrvc:aCols[ oGetSrvc:nAt , FG_POSVAR("SER_DEPGAR","oGetSrvc:aHeader") ] := MV_PAR03
		EndIf
		// Cod. Seção
		If !Empty(MV_PAR05)
			oGetSrvc:aCols[ oGetSrvc:nAt , FG_POSVAR("SER_CODSEC","oGetSrvc:aHeader") ] := MV_PAR05
		EndIf
		//
		
	Next nPosReq

Next nCont

oGetPeca:nAt := 1
oGetSrvc:nAt := 1

oGetPeca:oBrowse:refresh()
oGetSrvc:oBrowse:refresh()

Return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OX100PRFOK | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | FieldOK da GetDados de Pecas                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFCSC01FOK(cReadVar)

Default cReadVar := ReadVar()

If cReadVar == "M->PEC_GRUITE"

	SBM->(dbSetOrder(1))
	If !SBM->(dbSeek(xFilial("SBM") + M->PEC_GRUITE))
		MsgStop(STR0034,STR0031) // "Grupo não encontrado"
		Return .f.
	EndIf
	
EndIf

If cReadVar $ "M->PEC_GRUITE/M->PEC_CODITE"

	SB1->(dbSetOrder(7))
	If !SB1->(dbSeek(xFilial("SB1") + M->PEC_GRUITE + M->PEC_CODITE ))
		MsgStop(STR0035,STR0031) // "Produto não encontrado"
		Return .f.
	EndIf
	SB1->(dbSetOrder(1))
		
	SB2->(dbSetOrder(1))
	SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ))
		
	M->PEC_QTDEST := SaldoSB2()
	oGetPeca:aCols[ oGetPeca:nAt , FG_POSVAR("PEC_QTDEST","oGetPeca:aHeader") ] := M->PEC_QTDEST
	
EndIf		

Return .T.


Static Function FormatDate(dAuxData)
Return (Str(Year(dAuxData),4) + "-" + StrZero(Month(dAuxData),2) + "-" + StrZero(Day(dAuxData),2))

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | MenuDef    | Autor | Takahashi             | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Definicao de Menu                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MenuDef()

Local aRotina:= {{ STR0002 , "PesqBrw"   , 0 , 1},; // Pesquisar
				 { STR0003 , "OFCSC01CLA"  , 0 , 2} } // Claw
Return aRotina
