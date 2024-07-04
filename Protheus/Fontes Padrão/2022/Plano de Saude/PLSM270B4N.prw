#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE CRLF chr(13) + chr(10)

#define DIGITACAO "1"
#define PAGAMENTO "2"
#define BAIXA 	  "3"
#define REEMBOLSO "4"
#define FORDIRETO "5"
#define ALTERACAO "6"

Static lAtuTiss4 := B4N->(fieldPos("B4N_REGATE")) > 0 .AND. B4N->(fieldPos("B4N_SAUOCU")) > 0 .AND. B4N->(fieldPos("B4N_CPFUSR")) > 0 .AND. BD5->(FieldPos("BD5_SAUOCU")) > 0 .AND. BD5->(FieldPos("BD5_TMREGA")) > 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Lucas Nonato
@version   1.xx
@since     19/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB4N := FWFormStruct( 1, 'B4N', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel
	
	//--< DADOS DA GUIA >---
	oModel := MPFormModel():New( 'Monitoramento' )
	oModel:AddFields( 'MODEL_B4N',,oStruB4N )	
	oModel:SetDescription( "Monitoramento Guias TISS" )
	oModel:GetModel( 'MODEL_B4N' ):SetDescription( ".:: Monitoramento TISS ::." ) 
	oModel:SetPrimaryKey( { "B4N_FILIAL","B4N_SUSEP","B4N_CMPLOT","B4N_NUMLOT","B4N_NMGOPE","B4N_CODRDA" } )
return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef - MVC

@author    Lucas Nonato
@since     02/09/2016
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina Title 'Confirmar'		Action 'oDlgSec:End()'	OPERATION MODEL_OPERATION_VIEW ACCESS 0

return aRotina

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
	Local oModel	:= FWLoadModel( 'PLSM270B4N' )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL270B4N
Preenchimento e gravacao dos dados do Monitoramento TISS (tabela B4N)

@param		[cAlias], lógico, Alias gerado pela query na função carregaDados
@param		[aRDA], array, Array com os dados da RDA.
@param		[aUsuario], array, Array com os dados do Usuário.		
@param		[aLote], array, Array com os dados do Lote que está sendo gerado, faz a relação com as tabelas B4O e B4M.
@author    Lucas Nonato
@since     18/08/2016
/*/
//------------------------------------------------------------------------------------------
Function PL270B4N(cAlias, aRDA, aUsuario, aLote, lAtuProc, nTpProcess, cAliBase, cSusep) 
Local cGuiPri		:= ""
Local cIdReemb		:= ""
Local cAliasGui		:= PlRetAlias( ( cAlias )->( BD6_CODOPE ),( cAlias )->( BD6_TIPGUI ) )
Local cCNES			:= "9999999"
Local cVerTiss		:= ""
Local cGuiPrest		:= ""
Local cCodMunEx		:= ""
Local cTpReg		:= ""
Local cChave		:= ""
Local cTpAdm		:= ""
Local cRefIni		:= __aRet[2] + SubStr(__aRet[3],0,2) + "00"
Local cRefFim		:= __aRet[2] + SubStr(__aRet[3],0,2) + "99"
Local cTpEvt		:= ""
Local cFase			:= "3"
Local cNumGui		:= ""
Local cOrigEvt		:= ""
Local cEmpInter		:= GetNewPar("MV_PLSGEIN","9999")
Local nTotForn		:= 0
Local nVlrTbProp	:= 0
Local nTotInt		:= 0
Local nVlrTotInf	:= 0 //Valor total informado
Local nVlrProces	:= 0 //Valor processado
Local nVlrGloGui	:= 0 //Valor glosa guia
Local nVlrTotCop 	:= 0 //Valor total da coparticipacao
Local lRet			:= .t.
Local lOdonto		:= GetNewPar("MV_PLATIOD","0") == "1"
Local nI			:= 0
Local cCodOpeInt 	:= ""
Local cMotSai		:= ""
Local cSolInt		:= ""
Local cCodCID		:= ""
Local dDATPAG		:= STOD("  /  /   ")
Local dDTPRGU		:= STOD("  /  /   ")
Local cIDCOPR		:= ""
Local nVLRCON		:= 0
Local cPLIDCPR		:= GetNewPar("MV_PLIDCPR","")
Local cTpFat		:= ""
Local lPagoDps		:= .f.
Local lZerou		:= .f.

DEFAULT cAlias		:= ""	
DEFAULT aRDA		:= {}
DEFAULT aUsuario	:= {}
DEFAULT aLote		:= {}
DEFAULT lAtuProc	:= .F.
DEFAULT nTpProcess		:= 1

BEA->( dbSetOrder(12)) 	// BEA_FILIAL, BEA_OPEMOV, BEA_CODLDP, BEA_CODPEG, BEA_NUMGUI, BEA_ORIMOV
BXX->( dbSetOrder(2))	// BXX_CODINT, BXX_CODRDA, BXX_CODPEG
BB8->( dbSetOrder(1))	// BB8_FILIAL, BB8_CODIGO, BB8_CODINT, BB8_CODLOC, BB8_LOCAL
BAG->( dbSetOrder(1)) 	// BAG_FILIAL, BAG_CODIGO
B19->( dbSetOrder(2))	// B19_FILIAL, B19_GUIA
SD1->( dbSetOrder(1)) 	// D1_FILIAL,  D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
B4N->( dbSetOrder(1))	// B4N_FILIAL, B4N_SUSEP, B4N_CMPLOT, B4N_NUMLOT, B4N_NMGOPE, B4N_CODRDA
BDR->( dbSetOrder(1))	// BDR_FILIAL, BDR_CODOPE, BDR_CODTAD
BAU->( dbSetOrder(1))	// BAU_FILIAL, BAU_CODIGO
BVL->( dbSetOrder(2))  	// BVL_FILIAL, BVL_ALIAS, BVL_CODTAB 
BR8->( dbSetOrder(1))  	// BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN                                                                                                                      

BAU->(dbSeek(xFilial("BAU") + (cAlias)->(BD6_CODRDA)))
BR8->(dbSeek(xFilial("BR8") + ((cAlias)->(BD6_CODPAD))+ ((cAlias)->(BD6_CODPRO) )))

if !empty((cAliBase)->DTPAGT)
	dDTPRGU := stod((cAliBase)->DTPAGT)
	dDATPAG := stod((cAliBase)->DTPAGT)
else
	dDTPRGU := stod((cAliBase)->DTDIGI)	 
	lPagoDps := .t.
endif

if substr(DToS(dDTPRGU),1,6) <> alltrim(aLote[ 2 ])
	PlsPtuLog("Skip -> Data diferente da competencia - Guia:" + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) , "logMonit.log")		
	return .f.
endif

// Número da Guia
cNumGui:= 	(cAlias)->( BD6_CODLDP+BD6_CODPEG+BD6_NUMERO )

// Número da SADT Principal
If BEA->(dbSeek( xFilial("BEA") + (cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) )) .and. ( cAlias )->( BD6_TIPGUI ) == "02"
	cGuiPri := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
EndIf

// 	Código Nacional de Estabelecimento de Saúde
If BB8->( dbSeek( xFilial("BB8")+(cAlias)->(BD6_CODRDA+BD6_CODOPE+ &(cAliasGui + "_CODLOC") ) )) 
	If !Empty(BB8->BB8_CNES) 
		cCNES		:= BB8->BB8_CNES
	ElseIf !Empty(BAU->BAU_CNES) 
		cCNES 		:= BAU->BAU_CNES
	Else
		cCNES 	:= "9999999"
	EndIf 
	cCodMunEx	:= Iif( !Empty( BB8->BB8_CODMUN ),BB8->BB8_CODMUN,BAU->BAU_MUN )
EndIf

If GetNewPar( "MV_PLMONCN", .F.)
	If !Empty(BAU->BAU_CNES) 
		cCNES 	:= BAU->BAU_CNES
	Else
		cCNES 	:= "9999999"
	EndIf
EndIf

// Identificação reembolso
If (cAlias)->( BD6_TIPGUI ) == '04' 
	cIdReemb := (cAlias)->( BD6_CODLDP+BD6_CODPEG+BD6_NUMERO )
Else
	cIdReemb := "00000000000000000000" 
EndIf

// Versão TISS
if !empty((cAlias)->TISVER)	
	cVerTiss := (cAlias)->TISVER
else
	If BXX->( dbSeek( xFilial("BXX")+(cAlias)->(BD6_CODOPE+BD6_CODRDA+BD6_CODPEG) ) ) 
		cVerTiss := Iif(!Empty(BXX->BXX_TISVER),BXX->BXX_TISVER,aRDA[2][2])
	Else	
		cVerTiss := aRDA[2][2]
	EndIf
endif

//	Código do município do executante 
If Empty(cCodMunEx)
	cCodMunEx := aRDA[2][3]
EndIf

//--< Valor Pago ao Fornecedor >--
If cAliasGui == "BE4" .Or. cAliasGui == "BD5" .or. (cAliBase)->TIPO == FORDIRETO
	
	If B19->(dbSeek(xFilial("B19")+(cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
		If SD1->(dbSeek(xFilial("SD1")+B19->(B19_DOC+B19_SERIE+B19_FORNEC+B19_LOJA+B19_COD+B19_ITEM)))
			nTotForn := SD1->D1_TOTAL
		EndIf
	EndIf  
EndIf

// Origem Evento
If (cAlias)->( BD6_TIPGUI ) == '04' 
	cOrigEvt := '4'
Else
	BAU->(dbSeek(xFilial("BAU") + (cAlias)->(BD6_CODRDA)))
	cOrigEvt  := PLSGETVINC("BTU_CDTERM", 'BAU',.F.,"40")
	If Empty(cOrigEvt)
		BAG->(dbSeek(xFilial("BAG")+(cAlias)->&(cAliasGui+"_TIPPRE")))
		cOrigEvt  := PLSGETVINC("BTU_CDTERM", "BAG",.F.,"40")
	 
		If Empty(cOrigEvt) .And. BVL->(MsSeek(xFilial("BVL")+'BAU'+"40"))
	 
			cChaveBVL := "BAU->(xFilial('BAU')+"+BVL->BVL_CHVTAB+")"
			nSpace := TamSX3("BTU_VLRSIS")[1] - Len(cChaveBVL)
			aChvTab := StrTokArr(AllTrim(BVL->BVL_CHVTAB),"+")
			cTip :=  BVL->BVL_TIPVIN
	 
	  		//Verifica se os campos chaves estão preenchidos
			If Len(aChvTab) > 0
				for nI:= 1 to Len(aChvTab)
					cOrigEvt := &("BAU->" + aChvTab[nI])
				next
			EndIf
		EndIf
	Endif
EndIf

// Caracter de Atendimento
cTpAdm 	:=  AllTrim(PLSGETVINC("BTU_CDTERM", "BDR", .F., "23", (cAlias)->(&(cAliasGui+"_TIPADM")), .F.))   

cTpReg 	:= TpRegEnv(cAlias, cAliasGui,(cAliBase)->TIPO)
//	Acumulado do valor total da internacao.                                                                  
// (cAlias)->B19_GUIA, Indica que e um procedimento de alto custo e deve ser somado ao custo da internacao. 
If (cAlias)->BD6_TIPGUI == '05'
	If 	((cAlias)->BD6_LIBERA <> "1" .And. (cAlias)->BD6_FASE $ '3#4' .And. (cAlias)->BD6_SITUAC $ '1' .And. (cAlias)->BD6_BLOPAG <> "1" ) .Or. !Empty((cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN))
		
		//Somando o custo da interncao
		If (cAlias)->BD6_BLOPAG <> '1'  				
			nTotInt	:= (cAlias)->BD6_VLRPAG				
		Else//Se tenho motivo de bloqueio , o valor de pagamento deve estar na guia de honorario
			//encontrar o valor de pagamento da guia que não tem bd7_blopag=1 mas tem bd7_motblo <> de vazio
			nTotInt	:= MONVLRBD7((cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO),(cAlias)->BD6_CODOPE,cRefIni,cRefFim,cEmpInter,BR8->BR8_CODPAD,BR8->BR8_CODPSA,(cAlias)->BD6_DATPRO,"",cFase)
		EndIf	
	EndIf
	
Else
	nTotInt	:= (cAlias)->BD6_VLRPAG
EndIf

//Tipo de evento atenção
If lOdonto .And. BR8->BR8_ODONTO == "1"
	cTpEvt := "4"
Else
	cTpEvt := PLTPEVAT((cAlias)->(BD6_TIPGUI), (cAlias)->(&(cAliasGui+"_TIPPRE")), Alltrim((cAlias)->(BD6_CODPAD)),Alltrim((cAlias)->(BD6_CODPRO)))
EndIf

if ( cAlias )->( BD6_TIPGUI ) == '10'  //Recurso de Glosa
	cNumGui 	:= Subs(alltrim(( cAlias )->( BD5_GUIORI )),5,20) //Exclui OPEMOV, ORIMOV e SEQUEN da chave
endif

// Guia Prestador
If !Empty((cAlias)->( &(cAliasGui + "_NUMIMP") )) .And. AllTrim(cOrigEvt) <> "4"
	cGuiPrest	:= (cAlias)->&(cAliasGui + "_NUMIMP")
ElseIf AllTrim(cOrigEvt) == "4" 
	cGuiPrest 	:= "00000000000000000000"
	//cNumGui	Sera zerado somente na geração Arquivo para não influenciar nas chaves do indice.
EndIf

if (cAliBase)->TIPO == FORDIRETO .and. B19->(dbSeek(xFilial("B19")+(cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
	cGuiPrest := cNumGui
endif

//Codigo da operadora intermediaria
If GetNewPar("MV_PLSUNI","1") == "1" .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")
	cCodOpeInt := RegOpeInt("",(cAlias)->(BD6_CODRDA))
ElseIf (cAlias)->(BD6_OPEORI) <> (cAlias)->(BD6_CODOPE)
	cCodOpeInt := RegOpeInt((cAlias)->(BD6_OPEORI),"") 
ElseIf !(empty(BAU->BAU_ANSOPI))
	cCodOpeInt := BAU->BAU_ANSOPI
EndIf

// Preenchido com zeros quando o tipo de guia for igual a 3-Resumo de Internação ou o tipo de guia for igual 5-Honorários.
If !(AllTrim(cTpEvt) $ "3;5")
	nVlrTotCop := ( cAlias )->BD6_VLRTPF
EndIf

if (AllTrim(cTpEvt) == '2' .and. (cAlias)->( BD5_TIPATE ) == "07")
	nVlrTotCop := 0
endif

If (cAlias)->(BD6_BLOCPA) == '1' .Or. (cAlias)->(BD6_TIPGUI) == '05' .Or. ((cAlias)->(BD6_TIPGUI) == '02' .And. aUsuario[2,15])
	nVlrTotCop := 0
EndIf

If (cAlias)->BD6_VLRAPR > 0 .And. (cAlias)->BD6_VLRAPR >= (cAlias)->BD6_VLRPAG 
	nVlrTotInf := (cAlias)->BD6_VLRAPR * (cAlias)->BD6_QTDPRO
ElseIf (cAlias)->BD6_VLRMAN > 0 .And. (cAlias)->BD6_VLRMAN >= (cAlias)->BD6_VLRPAG
	nVlrTotInf := (cAlias)->BD6_VLRMAN
ElseIf (cAlias)->BD6_VLRGLO > 0 .And. (cAlias)->BD6_VLRMAN < (cAlias)->BD6_VLRPAG
	nVlrTotInf := (cAlias)->BD6_VLRGLO + (cAlias)->BD6_VLRPAG
Else
	nVlrTotInf := 0//Para evitar critica 1706 - VALOR APRESENTADO A MENOR
EndIf

nVlrGloGui := (cAlias)->BD6_VLRGLO
//Para evitar criticas 	
//5042 - VALOR INFORMADO DA GUIA DIFERENTE DO SOMATÓRIO DO VALOR INFORMADO DOS ITENS 
//1706 - VALOR APRESENTADO A MENOR
If nVlrTotInf - nVlrGloGui < nTotInt
	nVlrTotInf := nTotInt + nVlrGloGui
EndIf

If nVlrTotInf > 0 .And. nVlrGloGui > 0
	nVlrProces := nVlrTotInf - nVlrGloGui
EndIf

if (cAliBase)->TIPO == FORDIRETO
	nTotInt := nTotForn
	nVlrProces := nTotForn
	nVlrTotInf := nTotForn
	lPagoDps   := .f.
endif

cTpGrv := Iif( (cAlias)->(BD6_TPGRV) > "4" .or. empty((cAlias)->(BD6_TPGRV)),"4",(cAlias)->(BD6_TPGRV)) 

//cTpGrv = 1=Remote Protheus;2=Internet(RPC);3=POS;4=Importacao Manual 
//TISS : 1-Portal, 2-Upload de Arquivo, 3-WebService, 4-Papel
If cTpGrv == '4'
	ctpgrv := '2'
elseIf cTpGrv == '2'
	cTpGrv := '1'
elseIf cTpGrv == '1'
	ctpGrv := '4'
endIf //O 3 é igual

If cTpEvt == "4" .And. cAliasGui == "BD5" .And. Empty((cAlias)->( BD5_TIPFAT ) ) 
	cTpFat := "4"
ElseIf cAliasGui == "BD5"	
	cTpFat := (cAlias)->( BD5_TIPFAT ) 
EndIf

//Reembolso 
If ( cAlias )->( BD6_TIPGUI ) == '04' 
	nVlrProces := nVlrTotInf - nVlrGloGui
elseif ( cAlias )->( BD6_TIPGUI ) == '10'  //Recurso de Glosa
	nTotInt 	:= iif( (cAlias)->TPGUIS == "GLO", (cAlias)->BD6_VLRPAG, 0) 
	nVlrProces 	:= iif( (cAlias)->TPGUIS == "GLO", 	(cAlias)->(VLRPAGORI) + (cAlias)->BD6_VLRPAG, (cAlias)->(VLRPAGORI) ) 
	nVlrTotInf 	:= (cAlias)->(VLRPAGORI) + (cAlias)-> (VLRGLOORI)
	nVlrGloGui	:= iif( (cAlias)->TPGUIS == "GLO", 	(cAlias)->(VLRGLOORI) - (cAlias)->BD6_VLRPAG, (cAlias)->(VLRGLOORI) )
	nVlrTotCop  += iif( (cAlias)->TPGUIS == "GLO", (cAlias)->(VLRTPFORI),0)
EndIf

// Passado cNumGui chave por causa Reembolso
cChave := xFilial( 'B4N' )
cChave += padR( cSusep,tamSX3( "B4N_SUSEP" )[ 1 ] )
cChave += padR( aLote[ 2 ],tamSX3( "B4N_CMPLOT" )[ 1 ] )
cChave += padR( aLote[ 1 ],tamSX3( "B4N_NUMLOT" )[ 1 ] )
cChave += padR( cNumGui   ,tamSX3( "B4N_NMGOPE" )[ 1 ] )
cChave += padR( ( cAlias )->( BD6_CODRDA ),tamSX3( "B4N_CODRDA" )[ 1 ] )

If !B4N->( dbSeek( cChave ) )//Inclusao 
	
	PLS270Lote(@aLote, nTpProcess, (cAliBase)->TIPO)	
	B4N->(reclock("B4N",.t.))
	B4N->B4N_FILIAL := 	xFilial( "B4N" ) 		// Filial
	B4N->B4N_NUMLOT := 	aLote[ 1 ] 				// Numero de lote
	B4N->B4N_CMPLOT := 	aLote[ 2 ] 				// Competencia lote
	B4N->B4N_SUSEP 	:= 	cSusep					// Operadora
	B4N->B4N_NMGOPE :=  cNumGui  				// Número da Guia Operadora
	B4N->B4N_NMGPRE :=  cGuiPrest 				// Número da Guia Prestador 
	B4N->B4N_CODOPE :=  (cAlias)->(BD6_CODOPE) 	// Número da Operadora  
	B4N->B4N_CODLDP :=  (cAlias)->(BD6_CODLDP) 	// Código Local de Atendimento 
	B4N->B4N_CODPEG :=  (cAlias)->(BD6_CODPEG) 	// Número da PEG
	B4N->B4N_NUMERO :=  (cAlias)->(BD6_NUMERO) 	// Número sequencial guia
	B4N->B4N_STATUS := 	'1' 					// Status
	B4N->B4N_IDEREE :=  cIdReemb  				// Identificação de Reembolso
	B4N->B4N_TPRGMN :=  cTpReg 					// Tipo de Registro do Monitoramento - 1-Inclusão, 2-Alteração ou 3-Exclusão;	 
	B4N->B4N_CNES 	:= 	cCNES					// Código Nacional de Estabelecimento de Saúde	 
	B4N->B4N_VTISPR :=  padr( allTrim( cVerTiss ),tamSX3( "B4N_VTISPR" )[ 1 ] )		// 	Versão TISS Prestador
	B4N->B4N_FORENV := 	cTpGrv					// Forma de Envio	 
	B4N->B4N_CODRDA := 	(cAlias)->(BD6_CODRDA)	// Cód Rda	
	B4N->B4N_CDMNEX :=  cCodMunEx   			//	Código do município do executante
	B4N->B4N_RGOPIN :=  cCodOpeInt				//	Registro operadora intermediária
	B4N->B4N_NUMCNS :=  aUsuario[2,10]   		//	CNS do beneficiário
	B4N->B4N_SEXO 	:= 	aUsuario[2,11]   		//	Sexo do beneficiário
	B4N->B4N_DATNAS :=  STOD(aUsuario[2,12])	//	Data de nascimento 
	B4N->B4N_CDMNRS :=  aUsuario[2,13]			//	Código do município de residência
	B4N->B4N_SCPRPS :=  aUsuario[3]  			//	Número de registro do plano 
	B4N->B4N_TPEVAT :=  cTpEvt					// Tipo de evento atenção
	B4N->B4N_OREVAT :=  cOrigEvt  				// Origem do evento atenção 
	B4N->B4N_TIPADM :=  cTpAdm  				// Caráter de Atendimento

	//Tem definido o parametro que informa o local de digitacao referente a valor preestabelecido
	If (cAlias)->(BD6_TABDES) == "B8O" .And. B4N->(FieldPos("B4N_IDCOPR")) > 0 .And. B4N->(FieldPos("B4N_VLRCON")) > 0
		//BuscaConPre(@cIDCOPR,@nVLRCON,cAlias,cRefIni,cRefFim,dDTPRGU)
		cIDCOPR := ContratoUsado(cAlias)
		B4N->B4N_IDCOPR :=  cIDCOPR              // Identificacao de valor preestabelecido
//		B4N->B4N_VLRCON :=  nVLRCON             // Valor preestabelecido
	EndIf

	// Eventualmente prestadores contratados sob o regime de remuneração de contrato preestabelecido fazem cobranças indevidas no faturamento tiss.
	// Para não aumentar o número de glosas da operadora e melhorar seu IDSS removemos a glosa.
	if ( (cAlias)->(BD6_TABDES) == "B8O" .and. nVlrGloGui == nVlrTotInf .and. !empty(B4N->B4N_IDCOPR) ) .OR. nTotForn > 0
		nVlrTotInf := 0
		nVlrGloGui := 0
		lZerou := .t.
	endif

	B4N->B4N_VLTINF :=  nVlrTotInf				// Valor total informado
	B4N->B4N_VLTPRO :=  nVlrProces 				// Valor total processado
	if (cAlias)->( BD6_TIPGUI ) $  "03#05#11" 
		B4N->B4N_INAVIV := 	Iif((cAlias)->( BE4_ATERNA) == "0", "N","S")   	// Indicação de Nascido Vivo
	else
		B4N->B4N_INAVIV := 	Iif((cAlias)->( BD5_ATERNA) == "0", "N","S")   	// Indicação de Nascido Vivo
	endif

	Do Case
		Case BR8->BR8_TPPROC $ '069# ' 
			B4N->B4N_VLTPGP :=   	B4N->B4N_VLTPGP + Iif(lPagoDps,0,nTotInt)  	// Valor total de todos procedimentos, pacotes(6) e Outros(9)
		Case BR8->BR8_TPPROC == '4'
			B4N->B4N_VLTDIA :=   	B4N->B4N_VLTDIA + Iif(lPagoDps,0,nTotInt)  	// Valor total de todas diarias	
		Case BR8->BR8_TPPROC $ '387'
			B4N->B4N_VLTTAX :=   	B4N->B4N_VLTTAX + Iif(lPagoDps,0,nTotInt)  	// Valor total de todas taxas e Alugueis(8) e Gases(7) 
		Case BR8->BR8_TPPROC == '1'
			B4N->B4N_VLTMAT :=   	B4N->B4N_VLTMAT + Iif(lPagoDps,0,nTotInt)  	// Valor total de todos materias 
		Case BR8->BR8_TPPROC == '5'
			B4N->B4N_VLTOPM :=   	B4N->B4N_VLTOPM + Iif(lPagoDps,0,nTotInt)  	// Valor total de todos OPMEs
		Case BR8->BR8_TPPROC == '2'
			B4N->B4N_VLTMED :=   	B4N->B4N_VLTMED + Iif(lPagoDps,0,nTotInt)  	// Valor total de todos medicamentos
	EndCase
	
	B4N->B4N_VLTGLO :=  nVlrGloGui 		// Valor total de glosa 
	B4N->B4N_VLTGUI :=  Iif(lPagoDps,0,nTotInt) 		// Valor total pago
	B4N->B4N_VLTFOR :=	nTotForn 		// Valor total pago aos fornecedores  
	B4N->B4N_VLTTBP :=  nVlrTbProp 		// Valor total pago tabela propria
	B4N->B4N_VLTCOP :=  nVlrTotCop 		// Valor total de coparticipação

	//--< Internação, GHI, GRI >--
	If (cAlias)->( BD6_TIPGUI ) $  "03#05#11" 

		cMotSai := PLSGETVINC("BTU_CDTERM", "BIY", .F., "39", (cAlias)->(BE4_TIPALT), .F.)
		cSolInt := AllTrim( SubStr( (cAlias)->( BE4_GUIINT ),5,20) )
		If !Empty( (cAlias)->BE4_CIDREA )
			cCodCID := AllTrim(SubStr((cAlias)->BE4_CIDREA,1,4))
		Else
			cCodCID := AllTrim(SubStr((cAlias)->BE4_CID,1,4))
		EndIf
				
		B4N->B4N_SOLINT := 	cSolInt  										// Solicitação de Internação
		B4N->B4N_TIPINT := 	(cAlias)->( BE4_GRPINT )  			 			// Tipo de Internação
		B4N->B4N_REGINT := 	(cAlias)->( BE4_REGINT ) 			 			// Grupo de Internação
		B4N->B4N_CODCID := 	cCodCID 				 			 			// Código CID 10
		B4N->B4N_MOTSAI := 	cMotSai								 			// Motivo de Saída

		B4N->B4N_NRDCNV := 	(cAlias)->( BE4_NRDCNV )  			 			// Número da declaração de nascido vivo
		B4N->B4N_NRDCOB := 	(cAlias)->( BE4_NRDCOB )  			 			// Número da declaração de óbito
		B4N->B4N_TIPFAT := 	(cAlias)->( BE4_TIPFAT ) 			 			// Tipo de faturamento
		B4N->B4N_DIAACP := 	cValToChar((cAlias)->( BE4_DIASIN+BE4_DIASPR ))	// Diárias Acompanhante		
		B4N->B4N_DIAUTI := 	cValToChar((cAlias)->( BE4_DIASIN+BE4_DIASPR ))	// Diárias UTI 		
		B4N->B4N_INDACI := 	(cAlias)->( BE4_INDACI )  						// Indicação Clinica
		B4N->B4N_DTPAGT := 	Iif(lPagoDps,STOD("  /  /   "),dDATPAG)  		// Data de Pagamento
		B4N->B4N_DTPRGU := 	dDTPRGU 							 			// Data de Processamento da Guia
	
	//--< SADT, Reembolso, Consulta, Odonto, Honorario >--
	Else		
		
		If (cAlias)->(BD6_TIPGUI) == "06"
			B4N->B4N_SOLINT := 	SubStr((cAlias)->( BD5_GUIINT ),5,20)  // Solicitação de Internação
		EndIf
		B4N->B4N_NMGPRI := cGuiPri  						// Número da SADT Principal
		B4N->B4N_INDACI := (cAlias)->( BD5_INDACI )		// Indicação Clinica   
		B4N->B4N_TIPATE := (cAlias)->( BD5_TIPATE )		// Tipo de Atendimento
		If (cAlias)->( BD5_TIPATE ) == "07"
			B4N->B4N_SOLINT := 	(cAlias)->( BD5_GUIPRI ) // Solicitação de Internação
		EndIf           
		B4N->B4N_DTPAGT := Iif(lPagoDps,STOD("  /  /   "),dDATPAG)		// Data de Pagamento             
		B4N->B4N_DTPRGU := dDTPRGU 						// Data de Processamento da Guia
		If lOdonto
			B4N->B4N_TIPFAT :=  cTpFat  	// Tipo de faturamento
		EndIf

		if lAtuTiss4
			B4N->B4N_REGATE := (cAlias)->( BD5_TMREGA )
			B4N->B4N_SAUOCU := (cAlias)->( BD5_SAUOCU )
			B4N->B4N_CPFUSR := aUsuario[2][16]
		endif
	EndIf

	if allTrim(B4N->B4N_TPEVAT) == "1" .and. cTpEvt == "2"
		B4N->B4N_TPEVAT := "2"
	endif

	B4N->(msunlock())
	//lRet := gravaMonit( 3,aCampos,'MODEL_B4N','PLSM270B4N', .t., @aLote, nTpProcess )

Else// Alteracao - If !B4N->( dbSeek( cChave ) )
	
	// Eventualmente prestadores contratados sob o regime de remuneração de contrato preestabelecido fazem cobranças indevidas no faturamento tiss.
	// Para não aumentar o número de glosas da operadora e melhorar seu IDSS removemos a glosa.
	if ( (cAlias)->(BD6_TABDES) == "B8O" .and. nVlrGloGui == nVlrTotInf .and. !empty(B4N->B4N_IDCOPR) ) .OR. nTotForn > 0
		nVlrTotInf := 0
		nVlrGloGui := 0
		lZerou := .t.
	endif

	B4N->(reclock("B4N",.f.))
	B4N->B4N_VLTGLO :=  B4N->B4N_VLTGLO + nVlrGloGui 	// Valor total de glosa 
	B4N->B4N_VLTGUI :=  B4N->B4N_VLTGUI + Iif(lPagoDps,0,nTotInt)  			// Valor total pago
	B4N->B4N_VLTFOR :=	B4N->B4N_VLTFOR + nTotForn		// Valor total pago aos fornecedores  
	B4N->B4N_VLTTBP :=  B4N->B4N_VLTTBP + nVlrTbProp	// Valor total pago tabela propria
	B4N->B4N_VLTCOP :=  B4N->B4N_VLTCOP + nVlrTotCop 	// Valor total de coparticipação
	B4N->B4N_VLTINF := 	B4N->B4N_VLTINF + nVlrTotInf	// Valor total informado	 
	B4N->B4N_VLTPRO :=  B4N->B4N_VLTPRO + nVlrProces	// Valor total processado

	Do Case
		Case BR8->(BR8_TPPROC) $ '069# ' 
			B4N->B4N_VLTPGP :=   B4N->B4N_VLTPGP + Iif(lPagoDps,0,nTotInt)  	// Valor total de todos procedimentos, pacotes(6) e Outros(9)
		Case BR8->(BR8_TPPROC) == '4'
			B4N->B4N_VLTDIA :=   B4N->B4N_VLTDIA + Iif(lPagoDps,0,nTotInt)  	// Valor total de todas diarias	
		Case BR8->(BR8_TPPROC) $ '387'
			B4N->B4N_VLTTAX :=   B4N->B4N_VLTTAX + Iif(lPagoDps,0,nTotInt)  	// Valor total de todas taxas e Alugueis(8) e Gases(7) 
		Case BR8->(BR8_TPPROC) == '1'
			B4N->B4N_VLTMAT :=   B4N->B4N_VLTMAT + Iif(lPagoDps,0,nTotInt)  	// Valor total de todos materias 
		Case BR8->(BR8_TPPROC) == '5'
			B4N->B4N_VLTOPM :=   B4N->B4N_VLTOPM + Iif(lPagoDps,0,nTotInt)  	// Valor total de todos OPMEs
		Case BR8->(BR8_TPPROC) == '2'
			B4N->B4N_VLTMED :=   B4N->B4N_VLTMED + Iif(lPagoDps,0,nTotInt)  	// Valor total de todos medicamentos
	EndCase

	B4N->(msunlock())

EndIf

//--< DADOS DA TABELA DE ITENS DO MONITORAMENTO >---

lRet := PL270B4O( cAlias, aRDA, aUsuario, aLote, lAtuProc, cAliasGui, dDTPRGU, dDATPAG, cAliBase, cSusep, lZerou )

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLTPEVAT
Retorna o Tipo Evento Atenção

Segundo Padrão TISS (tissSimpleTypesV3_03_03.xsd):
 1 - Consulta
 2 - SP/SADT
 3 - Internação
 4 - Tratamento Odontológico
 5 - Honorarios

@param		[cTipGui], caracter, BD6_TIPGUI 
@param		[cTipPre], caracter, BD5_TIPPRE
@author    Lucas Nonato
@since     18/08/2016
/*/
//------------------------------------------------------------------------------------------
Function PLTPEVAT(cTipGui,cTipPre,cCodPad,cCodPro)
Local cRet := ''
Do Case
	Case cTipGui == '01'//GUIA DE CONSULTA              
		cRet  := "1" //1 para Consulta
	Case cTipGui == '02'//GUIA DE SP_SADT / ODONTOLOGIA
		cRet  := IIF(cTipPre =="DEN","4","2") //2 - SP/SADT
	Case cTipGui == '03' //GUIA DE SOL. INTERNACAO       
		cRet  := "3" //3 - Internação 
	Case cTipGui == '05' //Resumo Internação       
		cRet  := "3" //3 - Internação 
	Case cTipGui == "06" //GUIA DE HONORARIO INDIVIDUAL        
		cRet  := "5" //5 - Honorarios 
	Case cTipGui == "04" //GUIA DE REEMBOLSO. No momento, não há como diferenciar reembolso de consulta, exame, etc. Em conversa com a Márcia, será enviado Tipo de Evento 2.
	    cRet := "2"  //2 - SP/SADT
	Otherwise
		cRet  := "2"
EndCase
		
Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MONVLRBD7
No monitoramento eh considerado sempre o evento da GRI quando este tambem existe na GHI. 
Aqui eu vou retornar o valor do evento pago na GHI, pois na GRI ele tem motivo de bloqueio ou esta
bloqueado o pagamento 
@author    Lucas Nonato
@since     05/09/2016
/*/
//------------------------------------------------------------------------------------------
Static Function MONVLRBD7(pGuiInt,pOpeLot,pLotIni,pLotFin,pCodEmp,pCodPad,pCodPro,pDatPro,pHorPro,pFase)
Local nValorBD7 := 0
Local cQuery    := ""
Default pGuiInt := ""
Default pOpeLot := PlsIntPad()
Default pLotIni := ""
Default pLotFin := ""
Default pCodEmp := ""
Default pCodPad := ""
Default pCodPro := ""
Default pDatPro := ""
Default pHorPro := ""
Default pFase   := "4"

cQuery := "SELECT BD7_VLRPAG FROM " + RetSqlName("BD7") + " BD7 "
cQuery += " INNER JOIN " + RetSqlName("BD5") + " BD5 ON "
cQuery += "     BD5_FILIAL = BD7_FILIAL "
cQuery += " AND BD5_GUIINT = '" + pGuiInt + "'"
cQuery += " AND BD5_CODOPE = BD7_CODOPE "
cQuery += " AND BD5_CODLDP = BD7_CODLDP "
cQuery += " AND BD5_CODPEG = BD7_CODPEG "
cQuery += " AND BD5_NUMERO = BD7_NUMERO "
cQuery += " AND BD5_SITUAC = BD7_SITUAC "
cQuery += " AND BD5_FASE   = BD7_FASE   "
cQuery += " AND BD5.D_E_L_E_T_ = ' ' "
cQuery += " WHERE BD7_FILIAL  = '" + xFilial("BD5") + "' "
cQuery += "   AND BD7_OPELOT  = '" + pOpeLot + "' "
cQuery += "   AND BD7_NUMLOT >= '" + pLotIni + "'"
cQuery += "   AND BD7_NUMLOT <= '" + pLotFin + "'"
cQuery += "   AND BD7_CODEMP <> '" + pCodEmp + "'"
cQuery += "   AND BD7_CODPAD  = '" + pCodPad + "'"
cQuery += "   AND BD7_CODPRO  = '" + pCodPro + "'"
cQuery += "   AND BD7_DATPRO  = '" + pDatPro + "'"
cQuery += "   AND BD7_LIBERA <> '1' "
cQuery += "   AND BD7_FASE    >= '" + pFase + "' "
cQuery += "   AND BD7_SITUAC  = '1' "
cQuery += "   AND (BD7_BLOPAG <> '1' Or BD7_MOTBLO = ' ')"
cQuery += "   AND BD7_VLRPAG  > 0 "
cQuery += "   AND BD5_TIPGUI = '06'"
cQuery += "   AND BD7.D_E_L_E_T_ = ' '"
cQuery += "   AND BD5.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBMON",.F.,.T.)

If !TRBMON->(Eof())
	nValorBd7 := TRBMON->BD7_VLRPAG
EndIf

TRBMON->(dbCloseArea())

Return nValorBd7

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TpRegEnv
Retorna o tipo de envio do monitoramento

@param		[cTipGui], caracter, BD6_TIPGUI 
@param		[cTipPre], caracter, BD5_TIPPRE
@author    Lucas Nonato
@since     18/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function TpRegEnv(cAlias, cAliasGui,cOpcao)
Local cTpReg	:= Iif(SubStr(cValToChar(__aRet[10]),1,1) == '1','3' ,'1' )//1- Inclusão,2-Alteração, 3-Exclusão

DEFAULT cOpcao := '1'

If cTpReg == '1' .And. (cOpcao == ALTERACAO )
	cTpReg := '2' 
EndIf

Return cTpReg

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RegOpeInt
Retorna o numero de registro da operadora intermediaria

@param		codigo da operadora 
@author		timoteo.bega
@since		06/01/2017
/*/
//------------------------------------------------------------------------------------------
Static Function RegOpeInt(cCodOpeInt,cCodRDA)
Local cRegANS			:= ""
Default cCodOpeInt	:= ""
Default cCodRDA		:= ""

If !Empty(cCodOpeInt)

	BA0->(dbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	If BA0->(dbSeek(xFilial("BA0")+cCodOpeInt))
		cRegANS := BA0->BA0_SUSEP
	EndIf 

ElseIf !Empty(cCodRDA) .And. PlsCkInd("BA06")

	BA0->(dbSetOrder(6))//BA0_FILIAL+BA0_CODRDA
	If BA0->(dbSeek(xFilial("BA0")+cCodRDA))
		cRegANS := BA0->BA0_SUSEP
	EndIf 

EndIf

Return cRegAns

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} BuscaConPre
Consulta os contratos preestabelecidos cadastrados e chama a gravacao da B8Q

@author    timoteo.bega
@since     04/05/2017
/*/
//------------------------------------------------------------------------------------------
Static Function BuscaConPre(cIDCOPR,nVLRCON,cAlias,cRefIni,cRefFim,dDTPRGU)
Local	cSql		:= ""
Local	cAliSql	:= GetNextAlias()
Default	cIDCOPR	:= ""
Default	nVLRCON	:= 0
Default cAlias	:= ""
Default	cRefIni	:= STOD("  /  /   ")
Default	cRefFim	:= STOD("  /  /   ")
Default	dDTPRGU	:= STOD("  /  /   ")

B8O->(dbSetOrder(1))

cSql := "SELECT B8O_CODRDA, B8O_IDCOPR, B8O_VLRCON, B8O_VIGINI, B8O_VIGFIM FROM " + RetSqlName("B8O") + " B8O " 
cSql += " INNER JOIN " + RetSqlName("B8P") + " B8P ON "
cSql += " B8P_FILIAL = B8O_FILIAL "
cSql += " AND B8P_CODRDA = B8O_CODRDA "
cSql += " AND B8P_IDCOPR = B8O_IDCOPR "
cSql += " AND B8P_CODPAD = '" + (cAlias)->BD6_CODPAD + "' "
cSql += " AND B8P_CODPRO = '" + (cAlias)->BD6_CODPRO + "' "
cSql += " AND B8P.D_E_L_E_T_ = ' ' "
cSql += " WHERE B8O_FILIAL = '" + xFilial("B8O") + "' "
cSql += " AND B8O_CODRDA = '" + (cAlias)->BD6_CODRDA + "' "
cSql += " AND B8O.D_E_L_E_T_ = ' '"
if B8O->(FieldPos("B8O_ALLPRO")) > 0
	cSql += " UNION ALL " 
	cSql += " SELECT B8O_CODRDA, B8O_IDCOPR, B8O_VLRCON, B8O_VIGINI, B8O_VIGFIM FROM " + RetSqlName("B8O") + " B8O " 
	cSql += " WHERE B8O_FILIAL = '" + xFilial("B8O") + "' "
	cSql += " AND B8O_CODRDA = '" + (cAlias)->BD6_CODRDA + "' "
	cSql += " AND B8O_ALLPRO = '1' "
	cSql += " AND B8O.D_E_L_E_T_ = ' '"
endif
If PLSM270QRY(cSql,cAliSql)
	While !(cAliSql)->(Eof())
		plsTField(cAliSql,.f.,{ "B8O_VIGINI","B8O_VIGFIM" } )
		If PLSINTVAL(cAliSql,"B8O_VIGINI","B8O_VIGFIM",dDTPRGU)
			cIDCOPR := (cAliSql)->B8O_IDCOPR
			nVLRCON := (cAliSql)->B8O_VLRCON
		EndIf
		(cAliSql)->(dbSkip())
	EndDo	
EndIf

(cAliSql)->(dbCloseArea())

Return

Static Function ContratoUsado(cAlias)
Local cRet := ""

plsAAA720((cAlias)->(BD6_CODRDA),(cAlias)->(BD6_OPEUSR + BD6_CODEMP + BD6_MATRIC + BD6_TIPREG + BD6_DIGITO),StoD((cAlias)->(BD6_DATPRO)),(cAlias)->(BD6_CODPAD),(cAlias)->(BD6_CODPRO),@cRet)

return cRet
