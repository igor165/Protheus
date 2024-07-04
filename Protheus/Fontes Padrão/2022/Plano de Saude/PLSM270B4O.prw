#DEFINE CRLF chr(13) + chr(10)
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

#define DIGITACAO "1"
#define PAGAMENTO "2"
#define BAIXA 	  "3"
#define REEMBOLSO "4"
#define FORDIRETO "5"
#define ALTERACAO "6"

static lcmpUNM := B4O->(fieldPos("B4O_CODUNM")) > 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Lucas Nonato
@version   1.xx
@since     19/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB4O := FWFormStruct( 1, 'B4O', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel
	
	//--< DADOS DA GUIA >---
	oModel := MPFormModel():New( 'Monitoramento' )
	oModel:AddFields( 'MODEL_B4O',,oStruB4O )	
	oModel:SetDescription( "Monitoramento Itens TISS" )
	oModel:GetModel( 'MODEL_B4O' ):SetDescription( ".:: Monitoramento TISS ::." ) 
	oModel:SetPrimaryKey( { "B4O_FILIAL","B4O_SUSEP","B4O_CMPLOT","B4O_NUMLOT","B4O_NMGOPE","B4O_CODGRU","B4O_CODTAB","B4O_CODPRO","B4O_CODRDA" } )
return oModel
		 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef - MVC

@author    Lucas Nonato
@version   1.xx
@since     19/08/2016 
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FWLoadModel( 'PLSM270B4O' )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef - MVC

@author    Lucas Nonato
@since     02/09/2016
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina Title 'Ver Pacote'		Action 'StaticCall(PLSM270B4O,PLDLGPAC)'	OPERATION MODEL_OPERATION_VIEW ACCESS 0

return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL270B4O
Preenchimento e gravacao dos dados do Monitoramento TISS (tabela B4O)

@param		[cAlias], lógico, Alias gerado pela query na função carregaDados
@param		[aRDA], array, Array com os dados da RDA.
@param		[aUsuario], array, Array com os dados do Usuário.	
@param		[aLote], array, Array com os dados do Lote que está sendo gerado, faz a relação com as tabelas B4N e B4M.
@author    Lucas Nonato
@since     18/08/2016
/*/
//------------------------------------------------------------------------------------------
Function PL270B4O(cAlias, aRDA, aUsuario, aLote, lAtuProc, cAliasGui, dDTPRGU, dDTPAGT, cAliBase, cSusep, lZera)

Local aPacote		:= {}
Local aProced		:= {}
Local cCnpjFor		:= ""
Local cGrupo		:= ""
Local cNumGui		:= ""
Local cStatus		:= '1'
Local cNumGuiPre	:= ""
Local cTipCon		:= ""
Local cChave		:= ""
Local cCodRDA		:= ""
Local cCBOS			:= ""
Local cDente		:= ""
Local cFace			:= ""
Local cRegiao		:= ""
Local dDtInFt		:= SToD("  /  /   ")
Local dDtAut		:= SToD("  /  /   ")
Local dDtSol		:= SToD("  /  /   ") 
Local dDtFiFt		:= SToD("  /  /   ") 
Local dDtRea		:= SToD("  /  /   ") 
Local nTotForn		:= 0
Local nVlrTbProp	:= 0
Local lPacote		:= .F.
Local lRet			:= .T.
Local lOdonto		:= GetNewPar("MV_PLATIOD","0") == "1"
Local lPagoDps		:= .f.
Local nVlrCop		:= 0 //Valor coparticipacao
Local nVlrInf		:= 0 //Valor informado
Local nVlrPag		:= 0 //Valor pago procedimento
Local lUnimed		:= allTrim(getNewPar("MV_PLSUNI","1")) == "1"
Local cCodEsp		as char
Local cChaveBX6		:= ""
Local cCodUnm		:= ""

DEFAULT cAlias		:= ""	
DEFAULT aRDA		:= {}
DEFAULT aUsuario	:= {}
DEFAULT aLote		:= {}
DEFAULT lAtuProc	:= .F.
DEFAULT cAliasGui	:= PlRetAlias( ( cAlias )->( BD6_CODOPE ),( cAlias )->( BD6_TIPGUI ) )
DEFAULT dDTPRGU		:= STOD("  /  /   ")
DEFAULT dDTPAGT		:= STOD("  /  /   ")
DEFAULT lZera		:= .f.

BCI->( dbSetOrder(1)) // BCI_FILIAL, BCI_CODOPE, BCI_CODLDP, BCI_CODPEG, BCI_FASE, BCI_SITUAC
BAQ->( dbSetOrder(1)) // BAQ_FILIAL, BAQ_CODINT, BAQ_CODESP
SF1->( dbSetOrder(1)) // F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO    
SA2->( dbSetOrder(1)) // A2_FILIAL,  A2_COD_A2_LOJA
B19->( dbSetOrder(2)) // B19_FILIAL, B19_GUIA
SD1->( dbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
BEA->( dbSetOrder(12))// BEA_FILIAL, BEA_OPEMOV, BEA_CODLDP, BEA_CODPEG, BEA_NUMGUI, BEA_ORIMOV
B4O->( dbSetOrder(1)) // B4O_FILIAL, B4O_SUSEP, B4O_CMPLOT, B4O_NUMLOT, B4O_NMGOPE, B4O_CODGRU, B4O_CODTAB, B4O_CODPRO, B4O_CODRDA                                                                               
BR8->( dbSetOrder(1)) // BR8_FILIAL, BR8_CODPAD, BR8_CODPSA, BR8_ANASIN

if !empty((cAliBase)->DTPAGT)
	dDTPRGU := stod((cAliBase)->DTPAGT)
	dDTPAGT := stod((cAliBase)->DTPAGT)
else
	dDTPRGU := stod((cAliBase)->DTDIGI)	 
	lPagoDps := .t.
endif

cCodEsp := ""

cChaveBX6 := xFilial('BX6') + (cAlias)->BD6_CODOPE + (cAlias)->BD6_CODLDP + (cAlias)->BD6_CODPEG + (cAlias)->BD6_NUMERO + (cAlias)->BD6_ORIMOV + (cAlias)->BD6_SEQUEN
BX6->(dbsetOrder(1))
if BX6->(MsSeek(cChaveBX6))
	cCodUnm := BX6->BX6_CODUNM
endif

// Código CBOS
If ( (cAlias)->(BD6_TIPGUI) == "01" .or. ( (cAlias)->(BD6_TIPGUI) == "02" .and. PLSISCON((cAlias)->(BD6_CODPAD),(cAlias)->(BD6_CODPRO))) )
	if lUnimed
		cSql := " SELECT BD7_CODESP FROM " + RetSqlName("BD7") + " BD7 "  
		cSql += " WHERE BD7_FILIAL =  '" + xFilial("BD7") + "' "
		cSql += " AND BD7_CODOPE = '" + (cAlias)->BD6_CODOPE + "' " 
		cSql += " AND BD7_CODLDP = '" + (cAlias)->BD6_CODLDP + "' " 
		cSql += " AND BD7_CODPEG = '" + (cAlias)->BD6_CODPEG + "' " 
		cSql += " AND BD7_NUMERO = '" + (cAlias)->BD6_NUMERO + "' " 
		cSql += " AND BD7_ORIMOV = '" + (cAlias)->BD6_ORIMOV + "' " 
		cSql += " AND BD7_SEQUEN = '" + (cAlias)->BD6_SEQUEN + "' " 
		cSql += " AND BD7_CODESP <> '   ' " 
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"tmpCBOS",.F.,.T.)
		cCodEsp := tmpCBOS->BD7_CODESP
		tmpCBOS->(dbclosearea())
    endif  

	if empty(cCodEsp)
		cCodEsp := (cAlias)->BD6_CODESP
	endif
	If BAQ->(dbSeek(xFilial("BAQ")+(cAlias)->(BD6_CODOPE) + cCodEsp) ) .And. !Empty(BAQ->BAQ_CBOS)
		cCBOS	:= BAQ->BAQ_CBOS	
	EndIf
ElseIf (cAlias)->(BD6_TIPGUI) == "04" .AND. len(aRDA) == 3
	If BAQ->(dbSeek(xFilial("BAQ")+aRDA[3] ) ) .And. !Empty(BAQ->BAQ_CBOS)
		cCBOS	:= BAQ->BAQ_CBOS
	EndIf
EndIf 

// Valor Pago ao Fornecedor  
If cAliasGui == "BE4" .Or. cAliasGui == "BD5" .or. (cAliBase)->TIPO == FORDIRETO
	
	If B19->(dbSeek(xFilial("B19")+(cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
		If SD1->(dbSeek(xFilial("SD1")+B19->(B19_DOC+B19_SERIE+B19_FORNEC+B19_LOJA+B19_COD+B19_ITEM)))
			nTotForn := SD1->D1_TOTAL			
			if SA2->(DbSeek(xFilial("SA2")+SD1->(D1_FORNECE+D1_LOJA)))
				cCnpjFor:= Strzero(Val(SA2->A2_CGC),14,0)			
			endif
		endif
	EndIf 
	
EndIf

//CNPJ fornecedor, verifico se o evento foi atrelado a uma NF
If nTotForn > 0 .And. SF1->(dbSeek(Substr((cAlias)->BD6_NFE,1,len(SF1->F1_FILIAL)+len(SF1->F1_DOC)+len(SF1->F1_SERIE)+len(SF1->F1_FORNECE)+len(SF1->F1_LOJA))))
	If SA2->(DbSeek(xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA)))
		cCnpjFor:= Strzero(Val(SA2->A2_CGC),14,0)			
	EndIf
EndIf

//--< Campos Internação >--
if( ( cAlias )->( BD6_TIPGUI ) $ "03#05#11" ) 
	dDtAut		:= iif(!empty((cAlias)->(DTSOLINT)),STOD((cAlias)->(DTSOLINT)),STOD((cAlias)->(BE4_DTDIGI)))	
	dDtInFt		:= iif(Empty((cAlias)->(BE4_DTINIF)),STOD((cAlias)->(BE4_DATPRO)),STOD((cAlias)->(BE4_DTINIF)))
	dDtSol		:= iif(!empty((cAlias)->(DTSOLINT)),STOD((cAlias)->(DTSOLINT)),STOD((cAlias)->(BE4_DTDIGI)))	
	dDtFiFt		:= iif(Empty((cAlias)->(BE4_DTFIMF)),STOD((cAlias)->(BE4_DTALTA)),STOD((cAlias)->(BE4_DTFIMF)))
	cNumGui		:= ( cAlias )->( BE4_CODLDP + BE4_CODPEG + BE4_NUMERO )
	cNumGuiPre	:= (cAlias)->(BE4_NUMIMP)
	dDtRea		:= STOD((cAlias)->(BE4_DATPRO))
	
//--< Campos SADT >--
Else
	If BEA->(dbSeek( xFilial("BEA") + (cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) ))
		dDtAut	:= 	Iif(Empty(BEA->BEA_DATSOL),STOD((cAlias)->(BD5_DATPRO)),BEA->BEA_DATSOL)
		dDtInFt	:= 	STOD((cAlias)->(BD5_DATPRO))
		dDtSol	:= 	BEA->BEA_DATSOL
	Else
		dDtAut	:= 	STOD((cAlias)->BD5_DATPRO)
		dDtInFt	:= 	STOD((cAlias)->BD5_DATPRO)
		dDtSol	:= 	STOD((cAlias)->BD5_DATSOL)	
	EndIf

	cTipCon		:= 	iif((cAlias)->BD5_TIPCON=="5","2",(cAlias)->BD5_TIPCON)
	cNumGui		:= 	(cAlias)->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO )
	cNumGuiPre	:= 	(cAlias)->BD5_NUMIMP  
	dDtRea		:= 	GetMinDtRea(cAlias,STOD((cAlias)->BD6_DATPRO))  
EndIf

if BCI->(dbSeek(xFilial("BCI") + (cAlias)->BD6_CODOPE + (cAlias)->BD6_CODLDP + (cAlias)->BD6_CODPEG)) .and. dDtRea > BCI->BCI_DATREC 
	dDTPROT := BCI->BCI_DATREC
else
	dDTPROT := dDtRea
endif

if ( cAlias )->( BD6_TIPGUI ) == '10'  //Recurso de Glosa
	cNumGui 	:= Subs(alltrim(( cAlias )->( BD5_GUIORI )),5,20) //Exclui OPEMOV, ORIMOV e SEQUEN da chave
endif

//Retorna o procedimento padrão TISS
aProced	:= PLGETPROC(Alltrim((cAlias)->(BD6_CODPAD)),Alltrim((cAlias)->(BD6_CODPRO)))
If aProced[1]
	cCodPad := aProced[2]
	cCodPro := aProced[3]
	nQtdPct := (cAlias)->(BD6_QTDPRO)
	
	If BR8->BR8_TPPROC == "6"
		aPacote := PLGETPAC(Alltrim((cAlias)->(BD6_CODPAD)),Alltrim((cAlias)->(BD6_CODPRO)), (cAlias)->(BD6_CODOPE) + cNumGui, (cAlias)->(BD6_SEQUEN))
		If aPacote[1]
			PL270B4U(cAlias, aPacote[2], aLote, cSusep, cNumGui, cCodPad, cCodPro, nQtdPct )			
		EndIf
	EndIF
		
Else
	cStatus := '2'
	cCodPad := aProced[2]
	cCodPro := aProced[3]	
EndIf

//Retorna o Grupo de procedimento e itens assistenciais padrão TISS
cGrupo		:= PLGETGRUP(cCodPro, cCodPad)

if( !empty( aRDA[ 2 ][ 1 ] ) )
	cCodRDA := padR( aRDA[ 2 ][ 1 ],tamSX3( "B4O_CODRDA" )[ 1 ] )
else
	cCodRDA := padR( B4N->B4N_CODRDA,tamSX3( "B4O_CODRDA" )[ 1 ] )
endIf

//Dente, face e regiao
if lOdonto
	B04->( dbSetOrder(1)) //B04_FILIAL+B04_CODIGO+B04_TIPO       
	if B04->(dbSeek( xFilial("B04") + (cAlias)->BD6_DENREG ))                                                                                                                            
		if !Empty((cAlias)->BD6_DENREG) .Or. !Empty((cAlias)->BD6_FADENT)
			if( allTrim( B04->B04_TIPO ) == "1" )//1-Dente,2-Segmento,3-M-Arco,4-Supranumerario,5-Demais areas
				cDente	:= PLGETPROC( "28",( cAlias )->( BD6_DENREG ),"B04" )[ 3 ]
				cFace		:= PLGETPROC( "32",( cAlias )->( BD6_FADENT ),"B09" )[ 3 ]
			endif
			cRegiao	:= PLGETPROC( "42",( cAlias )->( BD6_DENREG ),"B04" )[ 3 ]
		endif
	endif
endif

//B4O_FILIAL+B4O_SUSEP+B4O_CMPLOT+B4O_NUMLOT+B4O_NMGOPE+B4O_DATREA+B4O_CODGRU+B4O_CODTAB+B4O_CODPRO+B4O_CDDENT+B4O_CDFACE+B4O_CDREGI+B4O_CODRDA
cChave := xFilial( "B4O" )
cChave += padR( cSusep,tamSX3( "B4O_SUSEP" )[ 1 ] )
cChave += padR( aLote[ 2 ],tamSX3( "B4O_CMPLOT" )[ 1 ] )
cChave += padR( aLote[ 1 ],tamSX3( "B4O_NUMLOT" )[ 1 ] )
cChave += padR( cNumGui,tamSX3( "B4O_NMGOPE" )[ 1 ] )
cChave += DTOS(dDtRea)
cChave += padR( cGrupo,tamSX3( "B4O_CODGRU" )[ 1 ] )
cChave += padR( cCodPad,tamSX3( "B4O_CODTAB" )[ 1 ] )
If Empty(cGrupo)
	cChave += padR( cCodPro,tamSX3( "B4O_CODPRO" )[ 1 ] )
Else
	cChave += padR( " ",tamSX3( "B4O_CODPRO" )[ 1 ] )
EndIf
cChave += padR( cDente,tamSX3( "B4O_CDDENT" )[ 1 ] )
cChave += padR( cFace,tamSX3( "B4O_CDFACE" )[ 1 ] )
cChave += padR( cRegiao,tamSX3( "B4O_CDREGI" )[ 1 ] )
cChave += cCodRDA

If (cAlias)->BD6_VLRAPR > 0 .And. (cAlias)->BD6_VLRAPR >= (cAlias)->BD6_VLRPAG
	nVlrInf := (cAlias)->BD6_VLRAPR * (cAlias)->BD6_QTDPRO
ElseIf (cAlias)->BD6_VLRMAN > 0 .And. (cAlias)->BD6_VLRMAN >= (cAlias)->BD6_VLRPAG
	nVlrInf :=  (cAlias)->BD6_VLRMAN
ElseIf (cAlias)->BD6_VLRGLO > 0 .And. (cAlias)->BD6_VLRMAN < (cAlias)->BD6_VLRPAG
	nVlrInf := (cAlias)->BD6_VLRGLO + (cAlias)->BD6_VLRPAG
ElseIf (cAlias)->BD6_VLRAPR == 0 .and. (cAlias)->BD6_VLRPAG == 0 .and. (cAlias)->BD6_VLRGLO > 0
	nVlrInf := (cAlias)->BD6_VLRGLO	
Else
	nVlrInf := 0//Para evitar critica 1706 - VALOR APRESENTADO A MENOR
EndIf

nVlrPag := (cAlias)->BD6_VLRPAG

// Preenchido com zeros quando o tipo de guia for igual a 3-Resumo de Internação ou o tipo de guia for igual 5-Honorários.
if !(AllTrim(B4N->B4N_TPEVAT) $ "3;5") 
	nVlrCop := (cAlias)->BD6_VLRTPF
endif

if alltrim(B4N->B4N_TPEVAT) == '2' .and. (cAlias)->( BD5_TIPATE ) == "07"
	nVlrCop := 0
endif

If cCodPad $ GetNewPar("MV_PLTABPR","00,90,98")
	nVlrTbProp := nVlrPag
EndIf

//Valor de co-participacao
If (cAlias)->(BD6_BLOCPA) == '1'
	nVlrCop := 0
EndIf

if (cAliBase)->TIPO == FORDIRETO
	nVlrPag := nTotForn
	lPagoDps:=.f.
endif

if nVlrInf - (cAlias)->BD6_VLRGLO < nVlrPag 
	nVlrInf := nVlrPag + (cAlias)->BD6_VLRGLO
EndIf

if ( cAlias )->( BD6_TIPGUI ) == '10'  //Recurso de Glosa
	nVlrPag 	:= (cAlias)->BD6_VLRPAG//iif( (cAlias)->TPGUIS == "ORI", 0, (cAlias)->BD6_VLRPAG)
	nVlrInf 	:= (cAlias)-> (VLRPAGORI) + (cAlias)-> (VLRGLOORI)
	nVlrCop  += iif( (cAlias)->TPGUIS == "GLO", (cAlias)->(VLRTPFORI),0)
endif


// Eventualmente prestadores contratados sob o regime de remuneração de contrato preestabelecido fazem cobranças indevidas no faturamento tiss.
// Para não aumentar o número de glosas da operadora e melhorar seu IDSS removemos a glosa.
if lZera
	nVlrInf := 0
endif

//B4O_FILIAL+B4O_SUSEP+B4O_CMPLOT+B4O_NUMLOT+B4O_NMGOPE+B4O_DATREA+B4O_CODGRU+B4O_CODTAB+B4O_CODPRO+B4O_CDDENT+B4O_CDFACE+B4O_CDREGI+B4O_CODRDA
//Se nao encontrou o item OU e o mesmo item em data diferente OU e o mesmo item em dente diferente
If !B4O->( dbSeek( cChave ) ) .Or. dDtRea <> B4O->B4O_DATREA .Or. MudouDenReg(cDente,cFace,cRegiao)

	nQtdInf := (cAlias)->(BD6_QTDPRO)
	
	If nQtdInf <= 0
		nQtdInf := 1
	EndIf
	B4O->(reclock("B4O",.t.))
	//--< Campos Genéricos >--
	B4O->B4O_FILIAL := 	xFilial( "B4O" ) 				// Filial
	B4O->B4O_SUSEP 	:= 	cSusep 							// Operadora
	B4O->B4O_NUMLOT := 	aLote[ 1 ] 						// Numero de lote
	B4O->B4O_CMPLOT := 	aLote[ 2 ] 						// Competencia lote
	B4O->B4O_IDEEXC := 	aRda[2][4]						// Identificador do executante
	B4O->B4O_CPFCNP := 	aRda[2][5]						// CPF ou CNJ do prestador
	B4O->B4O_DATAUT := 	dDtAut							// Data de autorização
	B4O->B4O_DTINFT := 	dDtInFt 						// Data início faturamento
	B4O->B4O_DTFIFT := 	dDtFiFt							// Data término faturamento 
	B4O->B4O_NMGOPE :=  cNumGui  				 		// Número da Guia Operadora 
	B4O->B4O_NMGPRE :=  cNumGuiPre 						// Número da Guia Prestador
	B4O->B4O_DATREA := 	dDtRea 							// Data de realização 
	B4O->B4O_TIPCON := 	cTipCon							// Tipo de Consulta
	B4O->B4O_DATSOL := 	dDtSol							// Data de Solicitação  
	B4O->B4O_DTPAGT := 	dDTPAGT 						// Data de pagamento
	B4O->B4O_DTPROT := 	dDTPROT							// Data protocolo cobrança 
	B4O->B4O_CBOS 	:= 	cCBOS							// Código CBOS  	
	B4O->B4O_CODTAB := 	cCodPad							// Código da tabela
	If !Empty(cGrupo) 
		B4O->B4O_CODGRU :=  cGrupo						// Código do grupo
	Else 
		B4O->B4O_CODPRO :=  cCodPro						// Código do procedimento
	EndIf 
	B4O->B4O_CDDENT :=  cDente 							// Código do dente
	B4O->B4O_CDFACE :=  cFace 							// Código da face do dente
	B4O->B4O_CDREGI :=  cRegiao 						// Código da região
	B4O->B4O_QTDINF :=  nQtdInf							// Quantidade informada 
	B4O->B4O_VLRINF :=  nVlrInf							// Valor informado 
	B4O->B4O_QTDPAG :=  Iif(lPagoDps,0,(cAlias)->(BD6_QTDPRO))			// Quantidade paga 
	B4O->B4O_VLPGPR :=  Iif(lPagoDps,0,nVlrPag)			// Valor pago procedimento 
	B4O->B4O_VLRPGF := 	nTotForn						// Valor pago ao fornecedor 
	B4O->B4O_CNPJFR :=  cCnpjFor						// CNPJ fornecedor 
	B4O->B4O_VLRCOP :=  nVlrCop							// Valor de coparticipação 
	B4O->B4O_STATUS :=  cStatus							// Status
	B4O->B4O_PACOTE :=  lPacote							// Flag Pacote
	B4O->B4O_CODRDA :=  cCodRDA							// Codigo RDA
	if lcmpUNM
		B4O->B4O_CODUNM := cCodUnm
	endif
	B4O->(msunlock())
	//lRet := gravaMonit( 3,aCampos,'MODEL_B4O','PLSM270B4O' )
Else
	B4O->(reclock("B4O",.F.))
	nQtdInf := (cAlias)->(BD6_QTDPRO)	

	If lAtuProc
		B4O->B4O_VLRPGF :=  B4O->B4O_VLRPGF + nTotForn				 // Valor pago fornecedor
		B4O->B4O_QTDPAG :=  B4O->B4O_QTDPAG + Iif(lPagoDps,0,(cAlias)->(BD6_QTDPRO))		// Quantidade paga
		B4O->B4O_QTDINF :=  B4O->B4O_QTDINF + nQtdInf						// Quantidade informada
	Endif

	B4O->B4O_VLPGPR := 	B4O->B4O_VLPGPR + Iif(lPagoDps,0,nVlrPag)	 // Valor pago procedimento
	B4O->B4O_VLRCOP := 	B4O->B4O_VLRCOP + nVlrCop					 // Valor de coparticipação
	B4O->B4O_VLRINF := 	B4O->B4O_VLRINF + nVlrInf					 // Valor informado

	B4O->(msunlock())

EndIf

If nVlrTbProp > 0 .And. !lPagoDps //Atualiza a guia com o valor pago em tabela propria
	B4N->(reclock("B4N",.f.))
	B4N->B4N_VLTTBP := B4N->B4N_VLTTBP + nVlrTbProp
	B4N->(msunlock())
endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MudouDenReg
Verifica se mudou o dente / face ou regiao para procedimentos repetidos na guia

@param	cDente
@param	cFace
@param	cRegiao
@author	timoteo.bega
@since	17/03/2017
/*/
//------------------------------------------------------------------------------------------
Static Function MudouDenReg(cDente,cFace,cRegiao)
Local	lRet	:= .F.
Default	cDente	:= ""
Default	cFace	:= ""
Default	cRegiao	:= ""

If !Empty(cDente) .And. !Empty(cFace) .And. ( AllTrim(B4O->B4O_CDDENT) != AllTrim(cDente) .Or. AllTrim(B4O->B4O_CDFACE) != AllTrim(cFace) )
	lRet := .T.
EndIf

If !lRet .And. !Empty(cRegiao) .And. AllTrim(B4O->B4O_CDREGI) != AllTrim(cRegiao)
	lRet := .T.
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLGETPROC
Faz o DE-PARA dos procedimentos Tiss x Protheus

@param		[cCodPad], caracter, Código da tabela
@param		[cCodPro], caracter, Código do procedimento
@author    Lucas Nonato
@since     23/08/2016
/*/
//------------------------------------------------------------------------------------------
Function PLGETPROC(cCodPad,cCodPro,cAliTerm) 					
Local lAchou   	:= .F.  
Local cTabPro  	:= GetNewPar("MV_PLTABPR","00,90,98") // Tabelas Proprias.
Local aRetPto  	:= {}
Local cSql 		:= ""

DEFAULT cAliTerm	:= "BR8"
// Ponto Entrada para tratar casos especificos em tabelas de clientes	
If ExistBlock("PLSTMON2")
	aRetPto:= ExecBlock("PLSTMON2",.F.,.F.,{lAchou,cCodPad,cCodPro,cAliTerm})
	Return (aRetPto)
EndIf

cSql := " SELECT BTU_CODTAB, BTU_CDTERM FROM " + RetSqlName("BTU")
cSql += " WHERE BTU_FILIAL = '" + xfilial("BTU") + "'"
cSql += " AND BTU_ALIAS = '" + cAliTerm + "'"
cSql += " AND BTU_VLRSIS = '" + xfilial("BR8")+cCodPad+cCodPro + "'"
cSql += " AND D_E_L_E_T_ = ' '
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBTU",.F.,.T.)
if !TrbBTU->(eof())
	cCodPro := Alltrim(TrbBTU->BTU_CDTERM)
	cCodPad := Alltrim(TrbBTU->BTU_CODTAB)	
	TrbBTU->(dbclosearea())
	return {.t.,cCodPad,cCodPro}
endif
TrbBTU->(dbclosearea())

BTU->(dbSetOrder(2))//BTU_FILIAL, BTU_CODTAB, BTU_ALIAS, BTU_VLRSIS	
BTQ->(DbsetOrder(1))				
If BTU->(dbSeek(xFilial("BTU")+"87"+"BR4"+xFilial("BR8")+cCodPad))
	While !BTU->(Eof()) .And. BTU->(BTU_FILIAL+BTU_CODTAB+BTU_ALIAS)+ Rtrim(BTU->BTU_VLRSIS) == xFilial("BTU")+"87"+"BR4"+xFilial("BR8")+ Alltrim(cCodPad)
		
		If BTQ->(MsSeek(xFilial("BTQ")+ Alltrim(BTU->BTU_CDTERM)+Alltrim(cCodPro)))
			cCodPad := Alltrim(BTU->BTU_CDTERM)
			Exit
		Endif
		BTU->(dbSkip())		
	EndDo
EndIf
		
If !lAchou
	BTU->(dbSetOrder(2))//BTU_FILIAL, BTU_CODTAB, BTU_ALIAS, BTU_VLRSIS					
	If BTU->(dbSeek(xFilial("BTU")+"87"+"BR4"+xFilial("BR8")+cCodPad))
		While !BTU->(Eof()) .And. BTU->(BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS);
			= xFilial("BTU")+"87"+"BR4"+xFilial("BR8")+cCodPad
		   
			cCodPad := Alltrim(BTU->BTU_CDTERM) 
			
			// Se for tabela Propria nao tem BTQ
			If cCodPad $ cTabPro
				lAchou := .T.
			Else
				// Verifica se encontra procedimento no cadastro de Itens e portanto nao necessita Depara
				BTQ->(dbSetOrder(1))//BTQ_FILIAL, BTQ_CODTAB, BTQ_CDTERM
				If BTQ->(dbSeek(xFilial("BTQ")+cCodPad+Alltrim(cCodPro)))
					lAchou := .T.
				Endif
			Endif
			// Se encontrou Sai do Loop
			If lAchou
				Exit
			Endif
		 	BTU->(dbSkip())
		End 
	Endif	
Endif		

//Procuro os procedimentos ODONTO
If !lAchou
	BTU->(dbSetOrder(2))//BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS+
	If BTU->(dbSeek(xFilial("BTU")+cCodPad+cAliTerm+xFilial(cAliTerm)+cCodPro))
		cCodPad:= Alltrim(BTU->BTU_CODTAB)
		cCodPro := Alltrim(BTU->BTU_CDTERM)
		lAchou := .T.
	EndIf
EndIf

If !lAchou//Busca direta na BTQ pois o cliente pode ter a tuss como alguma tabela de preco e nao precisa de-para

	BTQ->(dbSetOrder(1))//BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM
	If BTQ->(dbSeek(xFilial("BTQ")+cCodPad+cCodPro))
		lAchou := .T.
	EndIf 
 
EndIf

cCodPad	:= Alltrim(cCodPad)
cCodPro := Alltrim(cCodPro)

Return {lAchou,cCodPad,cCodPro}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLGETGRUP
Faz o DE-PARA dos Grupos de Procedimento Tiss(Terminologia 63) x Protheus

@param		[cCodPro], caracter, Código do procedimento
@param		[cCodPad], caracter, Código da tabela
@author    Lucas Nonato
@since     23/08/2016
/*/
//------------------------------------------------------------------------------------------
Function PLGETGRUP(cCodPro, cCodPadPro) 					
Local cRetGru   :=	"   "
Local cCodPad	:= 	'64'
DEFAULT cCodPadPro := ""

BTQ->(dbSetOrder(1))//BTQ_FILIAL, BTQ_CODTAB, BTQ_CDTERM

If ExistBlock("PLSTMON3")
	cRetGru:= ExecBlock("PLSTMON3",.F.,.F.,{cCodPro,cCodPadPro})	
ElseIf BTQ->(dbSeek(xFilial("BTQ")+cCodPad+Alltrim(cCodPro))) .And. UPPER(Alltrim(BTQ->BTQ_FENVIO)) == "CONSOLIDADO"
	cRetGru := Iif(!Empty(Alltrim(BTQ->BTQ_CODGRU)),BTQ->BTQ_CODGRU,"   ")	
Endif

Return cRetGru

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLGETPAC
Retorna os itens do pacote.

@param		[cCodPad], caracter, Código da tabela do procedimento
@param		[cCodPro], caracter, Código do procedimento
@param		[cNumGui], caracter, Numero da guia
@author    Lucas Nonato
@since     23/08/2016
/*/
//------------------------------------------------------------------------------------------
Function PLGETPAC(cCodPad, cCodPro, cNumGui, cSequen) 					
Local aPacote		:=	{}
Local aRetTiss		:= {}
Local lPacote		:= .F.
Default cCodPad	:= ""
Default cCodPro	:= ""
Default cNumGui	:= ""
Default cSequen	:= ""

B43->(dbSetOrder(1))//B43_FILIAL, B43_CODOPE, B43_CODLDP, B43_CODPEG, B43_NUMERO, B43_ORIMOV, B43_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
If B43->(dbSeek(xFilial('B43') + cNumGui))  
	While !B43->(Eof()) .And. B43->(B43_CODOPE+B43_CODLDP+B43_CODPEG+B43_NUMERO) == cNumGui 
	
		If B43->B43_SEQUEN == cSequen 
			aRetTiss:= PLGETPROC(B43->B43_CODPAD,B43->B43_CODPRO) 
			Aadd(aPacote,{aRetTiss[2],aRetTiss[3],B43->B43_VALFIX,cCodPad,cCodPro})
			lPacote := .T.
		EndIf	
		B43->(dbSkip())

	EndDo

	If Len(aPacote) > 0
		lPacote := .T.
	Endif
Endif

Return {lPacote, aPacote}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLDLGPAC
Tela com os itens do pacote

@author    Lucas Nonato
@since     02/09/2016
/*/
//------------------------------------------------------------------------------------------
Function PLDLGPAC()
Local aPac			:= {}
Local cDesc			:= "Não encontrado De/Para Tiss"
Local cAliasPac	:= GetNextAlias()

BeginSql Alias cAliasPac
	
	SELECT
	
  	B4U_CDTBIT, B4U_CDPRIT, B4U_VALFIX, B4U_QTPRPC
  	
  	FROM
  	
	%table:B4U% B4U
				
	WHERE
	B4U_FILIAL = %exp:B4O->B4O_FILIAL% AND
	B4U_SUSEP  = %exp:B4O->B4O_SUSEP% 	AND
	B4U_CMPLOT = %exp:B4O->B4O_CMPLOT% AND
	B4U_NUMLOT = %exp:B4O->B4O_NUMLOT% AND
	B4U_NMGOPE = %exp:B4O->B4O_NMGOPE% AND
	B4U_CDTBPC = %exp:B4O->B4O_CODTAB% AND
	B4U_CDPRPC = %exp:B4O->B4O_CODPRO% AND
	B4U.%notDel%							
		
EndSql

If B4O->B4O_CODTAB $ "90#98"

	BTQ->(dbSetOrder(1))
	While !(cAliasPac)->(EOF())
		If BTQ->(dbSeek(xFilial('BTQ') + (cAliasPac)->B4U_CDTBIT + (cAliasPac)->B4U_CDPRIT))
			cDesc := AllTrim(BTQ->BTQ_DESTER)
		EndIf
		aAdd(aPac, {(cAliasPac)->B4U_CDTBIT, (cAliasPac)->B4U_CDPRIT, cDesc, (cAliasPac)->B4U_QTPRPC, (cAliasPac)->B4U_VALFIX})
		(cAliasPac)->(dbSkip())
	EndDo
	(cAliasPac)->(dbclosearea())
	PLSCRIGEN(aPac,{ {"Tabela","@!",6},{"Código ","@!",8},{"Descrição","@!",30},{"Quantidade ","@E 999.99",10},{"Valor ","@E 99,999,999.99",11} },"Itens do Pacote",nil,nil)

Else
	MsgInfo("O procedimento selecionado não é um pacote")
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetMinDtRea
Pega a menor data dos itens da guia para ser enviada como data de realizacao 

@author    timoteo.bega
@since     16/05/2017
/*/
//------------------------------------------------------------------------------------------
Static Function GetMinDtRea(cAlias,dDtRea)
Local cSql			:= ""
Local cAliSql		:= GetNextAlias()
Default dDtRea	:= dDataBase

cSql := "SELECT MIN(BD6_DATPRO) BD6_DATPRO FROM " + RetSqlName("BD6") + " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' "
cSql += "AND BD6_CODOPE = '" + (cAlias)->BD6_CODOPE + "' "
cSql += "AND BD6_CODLDP = '" + (cAlias)->BD6_CODLDP + "' "
cSql += "AND BD6_CODPEG = '" + (cAlias)->BD6_CODPEG + "' "
cSql += "AND BD6_NUMERO = '" + (cAlias)->BD6_NUMERO + "' "
cSql += "AND D_E_L_E_T_ = ' ' "

If PLSM270QRY(cSql,cAliSql)
	dDtRea := STOD((cAliSql)->BD6_DATPRO) 
EndIf

(cAliSql)->(dbCloseArea())

Return dDtRea
 