#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2
#DEFINE VBOX       080
#DEFINE HMARGEM    030


//-------------------------------------------------------------------
/*/{Protheus.doc} PrtGNRE
Rotina de impressão GNRE

@author Simone dos Santos de Oliveira
@since 07/03/2016

/*/
//-------------------------------------------------------------------
user function PrtGNRE(cIdEnt, oImpGNRE, oSetup, cFilePrint)

local aArea      := GetArea()
local lExistGnre := .F. 

private nConsNeg := 0.4 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
private nConsTex := 0.5 // Constante para concertar o cálculo retornado pelo GetTextWidth.
private lLote	 := IsInCallStack("FISA214")

oImpGNRE:SetResolution(78) //Tamanho estipulado para a impressão da GNRE
oImpGNRE:SetPortrait()
oImpGNRE:SetPaperSize(DMPAPER_A4)
oImpGNRE:SetMargin(60,60,60,60)
oImpGNRE:lServer := oSetup:GetProperty(PD_DESTINATION)==AMB_SERVER

// ----------------------------------------------
// Define saida de impressão
// ----------------------------------------------

if oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
	oImpGNRE:nDevice := IMP_SPOOL
	// ----------------------------------------------
	// Salva impressora selecionada
	// ----------------------------------------------
	fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
	oImpGNRE:cPrinter := oSetup:aOptions[PD_VALUETYPE]
elseif oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
	oImpGNRE:nDevice := IMP_PDF
	// ----------------------------------------------
	// Define para salvar o PDF
	// ----------------------------------------------
	oImpGNRE:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
endif

private PixelX := oImpGNRE:nLogPixelX()
private PixelY := oImpGNRE:nLogPixelY()


RptStatus({|lEnd| GnreProc(@oImpGNRE,@lEnd,cIdEnt,@lExistGnre)},'Imprimindo Gnre...')  

if lExistGnre
	oImpGNRE:Preview()//Visualiza antes de imprimir
else
	Aviso('GNRE','Nenhuma GNRE a ser impressa nos parametros utilizados.',{'OK'},3) 
endif

freeobj(oImpGNRE)
oImpGNRE := nil
RestArea(aArea)
return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} GnreProc
Rotina de impressão GNRE

@author Simone dos Santos de Oliveira
@since 07/03/2016

/*/
//-------------------------------------------------------------------
static function GnreProc(oImpGNRE,lEnd,cIdEnt,lExistGnre) 

local aAreaSF6		:= {}
local aPerg   		:= {}
local aGnre			:= {}
local aArea			:= GetArea()
local aParam  		:= {space(len(SF6->F6_NUMERO)),space(len(SF6->F6_NUMERO)),Space(Len(SF6->F6_EST))}

local cNaoAut		:= ''
local cAliasGNRE	:= GetNextAlias()
local cGnreIni		:= ''
local cGnreFim		:= ''
local cUFGnre		:= ''
local cWhere		:= ''
local cAutoriza  	:= ''
local cCondicao		:= ''
local cIndex	 	:= ''
local cParGnreImp	:= SM0->M0_CODIGO+SM0->M0_CODFIL+IIF(lLote,"FISA214MIMP","FISA119IMP" )
local cTela			:= "Impressão GNRE " 
Local cPerg  		:= Iif(lLote,"Número lote ","Número GNRE ")
local cIdGuia		:= ''
local cXmlGnre		:= ''

local lQuery		:= .F.
local lOkParam		:= .F.

local oGnre			:= nil

local nLenNotas
local nIndex		:= 0
local nX			:= 0


MV_PAR01 := aParam[01] := PadR(ParamLoad(cParGnreImp,aPerg,1,aParam[01]),len(SF6->F6_NUMERO))
MV_PAR02 := aParam[02] := PadR(ParamLoad(cParGnreImp,aPerg,2,aParam[02]),len(SF6->F6_NUMERO))
MV_PAR03 := aParam[03] := PadR(ParamLoad(cParGnreImp,aPerg,3,aParam[03]),Len(SF6->F6_EST))


aadd(aPerg,{1, cPerg + ' Inicial:',aParam[01],'','.T.','','.T.',50,.T.}) 	
aadd(aPerg,{1, cPerg + ' Final:',aParam[02],'','.T.','','.T.',50,.T.})		
aadd(aPerg,{1,"UF : ",aParam[01],'@!','.T.','12','.T.',40,.F.}) 	

lOkParam 	:= ParamBox(aPerg,cTela,@aParam,,,,,,,cParGnreImp,.T.,.T.)

if lOkParam
	
	cGnreIni	:= alltrim(MV_PAR01)
	cGnreFim	:= alltrim(MV_PAR02)
	cUFGnre		:= alltrim(MV_PAR03)
	
	dbSelectArea("SF6")
	SF6->(dbSetOrder(1))	
	
	dbSelectArea("CIB")
	CIB->(dbSetOrder(1))

	#IFDEF TOP
				
		lQuery		:= .T.
		If lLote
			cWhere := "%"		
			cWhere += "CIB.CIB_FILIAL = '"+xFilial ("CIB")+"' AND"
			cWhere += " CIB.CIB_ID >= '"+ cGnreIni +"' AND CIB.CIB_ID <= '"+ cGnreFim +"' " 
			if ! empty(cUFGnre)
				cWhere		+= " AND CIB.CIB_EST = '" + cUFGnre + "' " 
			endif 
			cWhere		+= " AND CIB.CIB_GNREWS = 'S' "  //Somente autorizada
			cWhere		+= " AND CIB.D_E_L_E_T_ = ' '" 
			cWhere		+= ' %' 
			BeginSql Alias cAliasGNRE
				SELECT
					CIB_IDTSS, CIB_CDBARR, CIB_NUMCTR, R_E_C_N_O_
				FROM 
					%Table:CIB% CIB
				WHERE
					%Exp:cWhere%
				ORDER BY %Order:CIB%
			EndSql		
		Else
			cWhere := "%"		
			cWhere += "SF6.F6_FILIAL = '"+xFilial ("SF6")+"' AND"
			cWhere += " SF6.F6_NUMERO>= '"+ cGnreIni +"' AND SF6.F6_NUMERO<= '"+ cGnreFim +"' " 
			if ! empty(cUFGnre)
				cWhere		+= " AND SF6.F6_EST = '" + cUFGnre + "' " 
			endif 
			cWhere		+= " AND SF6.F6_GNREWS = 'S' "  //Somente autorizada
			cWhere		+= " AND SF6.D_E_L_E_T_ = ''" 
			cWhere		+= ' %'
			BeginSql Alias cAliasGNRE
				SELECT
					F6_IDTSS, F6_CDBARRA, F6_NUMCTRL, R_E_C_N_O_
				FROM
					%Table:SF6% SF6
				WHERE
					%Exp:cWhere%
				ORDER BY
					%Order:SF6%
			EndSql			
		EndIf
						
	#ELSE
		cIndex    		:= CriaTrab(NIL, .F.)
		cChave			:= IndexKey(1)
		cCondicao 		:= 'F6_FILIAL == "' + xFilial("SF6") + '" .And. '
		cCondicao 		+= 'SF6->F6_NUMERO >= "'+ cGnreIni+'" .And. '
		cCondicao 		+= 'SF6->F6_NUMERO <="'+ cGnreFim+'" .And. '
		if ! empty(cUFGnre)
			cCondicao	+= 'SF6->F6_EST =="'+ cUFGnre+'" .And. '
		endif
		cCondicao		+= 'SF6->F6_GNREWS == "S"  '
		IndRegua(cAliasGNRE, cIndex, cChave, , cCondicao)
		nIndex := RetIndex(cAliasMDF)
        dbsetindex(cIndex + OrdBagExt())
        dbsetorder(nIndex + 1)
		dbgotop()
	
	#ENDIF
	
	dbselectarea('SF6')
	while !(cAliasGNRE)->(Eof())
		
		aadd(aGnre,{})
		aadd(atail(aGnre),Iif( lLote , (cAliasGNRE)->CIB_IDTSS  , (cAliasGNRE)->F6_IDTSS ))  //id TSS
		aadd(atail(aGnre),Iif( lLote , (cAliasGNRE)->CIB_CDBARR , (cAliasGNRE)->F6_CDBARRA ))//Código de Barras
		aadd(atail(aGnre),Iif( lLote , (cAliasGNRE)->CIB_NUMCTR , (cAliasGNRE)->F6_NUMCTRL ))//Código de Barras
		
		nRecno	:= (cAliasGNRE)->R_E_C_N_O_
			
		//Tratamento para campo Memo
		Iif( lLote , CIB->(dbgoto(nRecno)) , SF6->(dbgoto(nRecno)) ) 
		
		aadd(atail(aGnre), Iif( lLote , CIB->CIB_XMLENV , SF6->F6_XMLENV  )) //XML enviado para TSS
				 				
		(cAliasGNRE)->(dbSkip())
		
	enddo	
	SF6->(dbclosearea())
	(cAliasGNRE)->( DbCloseArea() )

	if len(aGnre) > 0
		aAreaSF6 := SF6->(GetArea())
				
		for nX := 1 to len(aGnre)
			
			if ! empty( aGnre[nX][2])  //Código de Barras
				
				cIdGuia  := alltrim(aGnre[nX][1])
				cAutoriza:= alltrim(aGnre[nX][2])
				cNumCtrl := alltrim(aGnre[nX][3])
				cXmlGnre := alltrim(aGnre[nX][4])   //xml enviado TSS
				
				ImpDetGnre(@oImpGNRE,cAutoriza,cXmlGnre,cNumCtrl)
				lExistGnre := .T.
				
				oGnre      := nil
			else
			
				cNaoAut += aGnre[nX][1]+aGnre[nX][2]+CRLF
			
			endif
			
		next nX
		
		RestArea(aAreaSF6)
		delclassintf()
	endif
	if !lQuery
		dbclearfilter()
		ferase(cIndex+OrdBagExt())
	endif
	if !Empty(cNaoAut)
		Aviso('GNRE','As seguintes GNREs foram autorizadas, porém não contém Código de Barras: '+CRLF+CRLF+cNaoAut ,{'Ok'},3) 
	endif

endif

RestArea(aArea)
return(.T.)

//----------------------------------------------------------------------
/*/{Protheus.doc} ImpDetGnre
Controle do Fluxo do relatorio.

@author Simone Oliveira
@since 10/03/2016
@version 1.0 

/*/
//-----------------------------------------------------------------------
static function ImpDetGnre(oImpGNRE, cAutoriza, cXmlGnre, cNumCtrl)
	
private oFont07    	:= TFont():New('Arial',07,07,,.F.,,,,.T.,.F.)	//Fonte Arial 07
private oFont07N   	:= TFont():New('Arial',07,07,,.T.,,,,.T.,.F.)	//Fonte Arial 07
private oFont08		:= TFont():New('Arial',08,08,,.F.,,,,.T.,.F.)
private oFont08N	:= TFont():New('Arial',08,08,,.T.,,,,.T.,.F.)
private oFont10		:= TFont():New('Arial',10,10,,.F.,,,,.T.,.F.)
private oFont10N	:= TFont():New('Arial',10,10,,.T.,,,,.T.,.F.)
private oFont12N   	:= TFont():New('Arial',12,12,,.T.,,,,.T.,.F.)	//Fonte Arial 12 Negrito
private oFont14N   	:= TFont():New('Arial',14,14,,.T.,,,,.T.,.F.)	//Fonte Arial 14 Negrito

PrtGnreWS(@oImpGNRE, cAutoriza, cXmlGnre, cNumCtrl)

return(.T.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} PrtDamdfe
Impressao do formulario DANFE grafico conforme laytout no formato retrato

@author Simone Oliveira
@since 10/03/2016
@version 1.0 

@return .T.
/*/
//-----------------------------------------------------------------------
static function PrtGnreWS(oImpGNRE, cAutoriza, cXmlGnre, cNumCtrl)

local oGnreXml:= nil

local aRetSF6		:= {0,0,0,0,''}

local cCab			:= 'Guia Nacional de Recolhimento de Tributos Estaduais - GNRE'
local cUfFav		:= ''
local cCodRec		:= ''
local cRazEmi		:= ''
local cCnpjCpfEm	:= ''
local cEndEmi		:= ''
local cMunEmi		:= ''
local cUfEmi		:= ''	
local cCepEmi		:= ''	
local cTelEmi		:= ''	
local cDocOrig		:= ''
local cCnpjCpfDs	:= ''
local cMunDest		:= ''
local cPerRef		:= ''
local cParcela		:= ''
local cValPrinc		:= ''
local cConvenio		:= ''
local cProduto		:= ''
local cAtuMon		:= ''
local aInfCpl		:= ''
local cJuros		:= ''
local cMulta		:= ''
local cTotRec		:= ''
local cDtVenc		:= ''
local cCodBar		:= ''
local cCodBar1		:= ''
local cCodBar2		:= ''
local cIdGnre		:= ''
local cDtPagAt		:= ''
local cDtLimite		:= ''

local nX			:= 0
Local nY			:= 0
local nBox1			:= 0
local nBox2			:= 0
local nBox3			:= 0
local nSay1			:= 0
local nSay2			:= 0
local nPosIni		:= 0
local nAtuMon		:= 0
local nJuros		:= 0
local nMulta		:= 0
local nAtuMonF6		:= 0
local nJurosF6		:= 0
local nMultaF6		:= 0
local nTotRecF6		:= 0
local nPosCtrl		:= 0
Local cVersao		:= ""
Local cVide			:= "VIDE DETALHAMENTO"
Local nTotItens		:= 24 // Total de itens que podem ser exibidos em uma única página (múltiplo itens)
Local nPages		:= 0 // Total de páginas - Múltiplos itens
Local cAviso 		:= ""
Local cErro  		:= ""
Local nValorFecp	:= 0
Local nValorIcm		:= 0

Private oIdent		:= nil
Private oGnre		:= nil
Private oItem		:= nil
Private aItens		:= {}
Private lMultItens		:= .F.  // Define se a guia possui mais de item e veio da rotina FISA214


//Inicializacao do objeto grafico 
if oImpGNRE == nil
	lPreview := .T.
	oImpGNRE 	:= FWMSPrinter():New('GNRE', IMP_SPOOL)
	oImpGNRE:SetPortrait()
	oImpGNRE:Setup()
endif
	
//Inicializacao da pagina do objeto grafico
oImpGNRE:StartPage()
nHPage := oImpGNRE:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oImpGNRE:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX

for nX:= 1 to 3 //Gera via Banco # Contribuinte # Contribuinte/Fisco
	cAviso 		:= ""
	cErro  		:= ""
	//Alimentando as variáveis
	if ! empty( cXmlGnre )
		oGnreXml := XmlParser(NoAcentReco(cXmlGnre),"_",@cAviso,@cErro)

		If !Empty(cAviso) .And. !Empty(cErro)
			Help("",1,"Help","Help","Problema na leitura do XML. Impossível efetuar a impressão do relatório",1,0)
			return .f.
		EndIf
		//  Harmonizando as versões 1.00 e 2.00 do tipo 0- Guia Simples na impressão do relatório
		cVersao	:= "1.00"
		oGNRE	:= oGnreXml
		lMultItens		:= .F.
		
		If Type("oGNRE:_gnre:_versaoguia") == "O"
			cVersao	:= oGnreXml:_gnre:_versaoguia:text
		EndIf

		If cVersao == "1.00"
			oGNRE	:= oGnreXml:_gnre
			oItem	:= oGNRE
			oIdent	:= oGNRE:_identgnre
		ElseIf cVersao >= "2.00"
			If lLote
				oGNRE	:= oGnreXml:_gnre:_DADOSGNRE
				// Quando temos vários itens mostramos apenas o primeiro no cabeçalho do relatório, seguindo exemplo da própria Sefaz PE.
				If Type("oGNRE:_ITENSGNRE:_ITEM") == "A"
					aItens	:= oGNRE:_ITENSGNRE:_ITEM
					oItem	:= aItens[1]
				Else
					oItem	:= oGNRE:_ITENSGNRE:_ITEM
				EndIf
				oIdent	:= oItem:_IDENTGNRE
				lMultItens  := Len(aItens) > 1
			Else
				oGNRE	:= oGnreXml:_gnre:_DADOSGNRE
				oItem	:= oGNRE:_ITENSGNRE:_ITEM
				oIdent	:= oItem:_IDENTGNRE			
			EndIf
		EndIf

	else //Tratamento casa haja algum erro no retorno do xml
		Alert('Não há dados para imprimir.')
		return
	endif
	
	// ----------------------------------------------
	// Variáveis de Posicionamento
	// ----------------------------------------------
	nBox1	:= iif(nX==1,0,nBox1 + 20)
	nBox2	:= 000
	nBox3	:= iif(nX==1, 20, nBox1 + 20)
	
	nSay1	:= iif(nX==1, 13, nBox1 + 13)
	nSay2	:= iif(nX==1, 60, nBox2 + 80)

	// ----------------------------------------------
	// BOX: Cabeçalho
	// ----------------------------------------------
	oImpGNRE:Box(nBox1,000,nBox3,450,'-6')	
	oImpGNRE:Say(nSay1, nSay2, cCab, oFont12N)  
			
	// ----------------------------------------------
	// BOX: UF Favorecida
	// ----------------------------------------------
	cUfFav 	:= alltrim( oIdent:_uf:text )
	
	nSay1	:= nBox1 + 8
	nSay1A	:= nBox1 + 16
	
	oImpGNRE:Box(nBox1,450,nBox3,520,'-6')
	oImpGNRE:Say(nSay1, 453, 'UF Favorecida', oFont07N)
	oImpGNRE:Say(nSay1A, 453, cUfFav, oFont08)
	
	// ----------------------------------------------
	// BOX: Código da Receita
	// ----------------------------------------------
	cCodRec	:= alltrim( oIdent:_receita:text )
		
	oImpGNRE:Box(nBox1,520,nBox3,600,'-6')
	oImpGNRE:Say(nSay1, 523, 'Código da Receita', oFont07N) 
	oImpGNRE:Say(nSay1A, 523, cCodRec, oFont08)  
	
	
	// ----------------------------------------------
	// BOX: Dados do Contribuinte Emitente
	// ----------------------------------------------	
	cRazEmi	:= alltrim( oGNRE:_emitente:_nome:text )
	
	//cnpj/cpf/ie
	if !Empty( oGNRE:_emitente:_ie:text )
		cCnpjCpfEm	:= alltrim( oGNRE:_emitente:_ie:text )
	else
		cCnpjCpfEm	:= transform(oGNRE:_emitente:_cnpjcpf:text,iif(len(oGNRE:_emitente:_cnpjcpf:text)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99"))
	endif

	cEndEmi	:= alltrim( oGNRE:_emitente:_endereco:text )
	cMunEmi	:= alltrim( oGNRE:_emitente:_descmun:text )
	cUfEmi		:= alltrim( oGNRE:_emitente:_uf:text )
	cCepEmi	:= alltrim( oGNRE:_emitente:_cep:text )
	
	cTelEmi	:= alltrim( oGNRE:_emitente:_telefone:text )
	cTelEmi	:= transform(cTelEmi, iif(len(cTelEmi) == 11, '@R (99) 99999-9999', '@R (99) 9999-9999' ))
	
	oImpGNRE:Box(nBox1 + 20,000,nBox3 + 060,450,'-6')	
	oImpGNRE:Say(nBox1 + 28, 0180, 'Dados do Contribuinte Emitente' , oFont07N)
	oImpGNRE:Say(nBox1 + 36, 0005, 'Razão Social:' , oFont07N)
	oImpGNRE:Say(nBox1 + 46, 0005, cRazEmi , oFont08)
	oImpGNRE:Say(nBox1 + 36, 0350, 'CNPJ/CPF/Insc. Est.:' , oFont07N)
	oImpGNRE:Say(nBox1 + 46, 0350, cCnpjCpfEm , oFont08)
	oImpGNRE:Say(nBox1 + 54, 0005, 'Endereço:' , oFont07N)
	oImpGNRE:Say(nBox1 + 54, 0045, cEndEmi , oFont08)
	oImpGNRE:Say(nBox1 + 64, 0005, 'Município:' , oFont07N)
	oImpGNRE:Say(nBox1 + 64, 0045, cMunEmi , oFont08)
	oImpGNRE:Say(nBox1 + 64, 0350, 'UF:' , oFont07N)
	oImpGNRE:Say(nBox1 + 64, 0365, cUfEmi , oFont08)
	oImpGNRE:Say(nBox1 + 74, 0005, 'CEP:' , oFont07N)
	oImpGNRE:Say(nBox1 + 74, 0025, cCepEmi , oFont08)
	oImpGNRE:Say(nBox1 + 74, 0350, 'Telefone:' , oFont07N)
	oImpGNRE:Say(nBox1 + 74, 0385, cTelEmi , oFont08)
		
	// ----------------------------------------------
	// BOX: Número de Controle
	// ----------------------------------------------
	nPosCtrl := iif(len(cNumCtrl)>16,0513,0528)
		
	oImpGNRE:Box(nBox1 + 20,450,nBox3 + 020,600,'-6')
	oImpGNRE:Say(nBox1 + 28, 0453, 'Nº de Controle', oFont07N) 
	oImpGNRE:Say(nBox1 + 36, nPosCtrl, cNumCtrl, oFont08)  
		
	// ----------------------------------------------
	// BOX: Data de Vencimento
	// ----------------------------------------------
	cDtVenc := substr(oIdent:_vencimento:text,7,2)+'/'+ substr(oIdent:_vencimento:text,5,2)+'/'+ substr(oIdent:_vencimento:text,1,4)
		
	oImpGNRE:Box(nBox1 + 40,450, nBox3 + 040,600,'-6')
	oImpGNRE:Say(nBox1 + 48, 0453, 'Data de Vencimento', oFont07N) 
	If lMultItens
		oImpGNRE:Say(nBox1 + 56, 0470 , cVide , oFont07)
	Else		
		oImpGNRE:Say(nBox1 + 56, 0558, cDtVenc, oFont08)
	EndIf
	
	// ----------------------------------------------
	// BOX: Nº Documento de Origem
	// ----------------------------------------------
	cDocOrig := transform(DocOrig(oIdent:_docorig:text),'@R 999999999')
	
	oImpGNRE:Box(nBox1 + 60,450,nBox3 +  060,600,'-6')
	oImpGNRE:Say(nBox1 + 68, 0453, 'Nº Documento de Origem', oFont07N) 
	If lMultItens
		oImpGNRE:Say(nBox1 + 76, 0470 , cVide , oFont07)
	Else		
		oImpGNRE:Say(nBox1 + 76, 0558, cDocOrig, oFont08)
	EndIf
	
	
	
	// ----------------------------------------------
	// BOX: Dados do Destinatário
	// ----------------------------------------------
	//cnpj/cpf/ie
	if ! empty (oItem:_destinatario:_ie:text)
		cCnpjCpfDs	:= alltrim( oItem:_destinatario:_ie:text )	
	else
		cCnpjCpfDs	:= transForm(oItem:_destinatario:_cnpjcpf:text,iif(len(oItem:_destinatario:_cnpjcpf:text)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")) 
	endif
	
	cMunDest := alltrim( oItem:_destinatario:_descmun:text )
	
	
	oImpGNRE:Box(nBox1 + 080, 000, nBox3 + 090, 450, '-6')	
	oImpGNRE:Say(nBox1 + 088, 0180, 'Dados do Destinatário' , oFont07N)
	oImpGNRE:Say(nBox1 + 096, 0005, 'CNPJ/CPF/Insc. Est.:' , oFont07N)
	oImpGNRE:Say(nBox1 + 096, 0080, cCnpjCpfDs , oFont08)
	oImpGNRE:Say(nBox1 + 106, 0005, 'Município:' , oFont07N)
	oImpGNRE:Say(nBox1 + 106, 0080, cMunDest , oFont08)
	
	
	// ----------------------------------------------
	// BOX: Período de Referência
	// ----------------------------------------------
	cPerRef := alltrim( oItem:_referencia:_mes:text ) + '/' + alltrim( oItem:_referencia:_ano:text )
	
	oImpGNRE:Box(nBox1 + 080,450,nBox3 + 080,530,'-6')
	oImpGNRE:Say(nBox1 + 088, 0453, 'Período de Referência', oFont07N) 
	oImpGNRE:Say(nBox1 + 096, 0500, IIf (lMultItens , '' ,cPerRef ), oFont08) 
	
	
	// ----------------------------------------------
	// BOX: Parcela
	// ----------------------------------------------
	cParcela := alltrim( oItem:_referencia:_parcela:text )
	
	oImpGNRE:Box(nBox1 + 080,530,nBox3 + 080,600,'-6')
	oImpGNRE:Say(nBox1 + 088, 0533, 'Parcela', oFont07N) 
	oImpGNRE:Say(nBox1 + 096, 0588, Iif (lMultItens, '' , cParcela) , oFont08) 
	
	//Tratamento para buscar valores de Atualização Monetária, Juros e Multa da SF6 conforme retorno SEFAZ PE
	//Obs. esta função não atende RJ e ES
	
	if !cUfFav $"RJ#ES"

		If lMultItens
			cIdGnre := alltrim( oGnre:_numerognre:text )
		Else
			cIdGnre := alltrim( oIdent:_numerognre:text )
		EndIf
		aRetSF6:= RetValSF6(cUfFav, cIdGnre , lMultItens )
		
		nAtuMonF6	 	:= aRetSF6[1]
		nJurosF6	 	:= aRetSF6[2]
		nMultaF6	 	:= aRetSF6[3]
		nTotRecF6	 	:= aRetSF6[4]
		cDtLimite	 	:= aRetSF6[5]
		nValPrinc    	:= aRetSF6[6]

	ElseIf cUfFav $ "RJ" .And. ;
		valtype(oItem:_valores:_principal) == "A" .And. ;
		valtype(oItem:_valores:_total) == "A"

		nValorFecp := Val(oItem:_valores:_principal[2]:text)
		nValorIcm  := Val(oItem:_valores:_principal[1]:text)
		nValPrinc := nValorIcm + nValorFecp
		nTotRecF6 := val(oItem:_valores:_total[1]:text)	+ val(oItem:_valores:_total[2]:text)
	Else
		nValPrinc := Val(oItem:_valores:_principal:text)
		nTotRecF6 := val(oItem:_valores:_total:text)	
	endif	

	// ----------------------------------------------
	// BOX: Valor Principal
	// ----------------------------------------------
	cMascara	:= '@e 9,999,999,999,999.99'
	
	cValPrinc	:= PadL( 'R$ '+ alltrim(transform( nValPrinc , cMascara)),len(cMascara))
	
	
	oImpGNRE:Box(nBox1 + 100,450,nBox3 + 100,600,'-6')
	oImpGNRE:Say(nBox1 + 108, 0453, 'Valor Principal', oFont07N) 
	oImpGNRE:SayAlign( nBox1 + 108,0500,cValPrinc,oFont08, 96, 19, , 1)
	
	
	// ----------------------------------------------
	// BOX: Reservado a Fiscalização
	// ----------------------------------------------
	cConvenio	:= alltrim( oIdent:_convenio:text )
	cProduto	:= alltrim( oIdent:_produto:text )
	
	oImpGNRE:Box(nBox1 + 110, 000, nBox3 + 130, 450, '-6')	
	oImpGNRE:Say(nBox1 + 118, 0180, 'Reservado a Fiscalização' , oFont07N)
	oImpGNRE:Say(nBox1 + 128, 0005, 'Convênio/Protocolo:' , oFont07N)
	oImpGNRE:Say(nBox1 + 128, 0080, cConvenio , oFont08)
	oImpGNRE:Say(nBox1 + 138, 0005, 'Produto:' , oFont07N)
	oImpGNRE:Say(nBox1 + 138, 0080, cProduto , oFont08) 
	

	// ----------------------------------------------
	// BOX: Atualização Monetária
	// ----------------------------------------------	
	nAtuMon	:=  iif(!cUfFav $"RJ#ES", nAtuMonF6, val(oItem:_valores:_atumonetaria:text))
	cAtuMon	:= PadL( 'R$ '+ alltrim(transform(nAtuMon, cMascara)),len(cMascara))
	
	oImpGNRE:Box(nBox1 + 120,450,nBox3 + 120,600,'-6')
	oImpGNRE:Say(nBox1 + 128, 0453, 'Atualização Monetária', oFont07N) 
	oImpGNRE:SayAlign( nBox1 + 128,0500,cAtuMon,oFont08, 96, 19, , 1)
	
	// ----------------------------------------------
	// BOX: Informações Complementares
	// ----------------------------------------------
	//Função que retorna Informações Complementares
	aInfCpl := RetInfComp( oGnreXml )
	
	//Tratmento para informar documento válido com a data retornada pela SEFAZ como data limite quando for SEFAZ Nacional PE
	cDtPagAt :=  iif(!cUfFav $"RJ#ES", cDtLimite, cDtVenc)
	
	oImpGNRE:Box(nBox1 + 140, 000, nBox3 + 180, 450, '-6')	
	oImpGNRE:Say(nBox1 + 148, 0005, 'Informações Complementares' , oFont07N)
	If lMultItens
		oImpGNRE:Say(nBox1 + 148, 0300, 'GNRE COM MÚLTIPLOS ITENS' , oFont08)
	EndIf
	oImpGNRE:Say(nBox1 + 157, 0005, aInfCpl[1] , oFont08)
	oImpGNRE:Say(nBox1 + 165, 0005, aInfCpl[2] , oFont08)
	oImpGNRE:Say(nBox1 + 174, 0005, aInfCpl[3] , oFont08)

	If 	nValorIcm > 0
		oImpGNRE:Say(nBox1 + 184, 0005, "ICMS: Valor Total="+ PadL( 'R$ '+ alltrim(transform(nValorIcm, cMascara)),len(cMascara)) + Space(30) + "FECP: Valor Total=" + PadL( 'R$ '+ alltrim(transform(nValorFecp, cMascara)),len(cMascara)) , oFont08) 
	Endif

	If !Empty(cDtPagAt)
		oImpGNRE:Say(nBox1 + 194, 0005, 'Documento Válido para pagamento até ' , oFont08N)
		oImpGNRE:Say(nBox1 + 194, 0200, cDtPagAt , oFont08) 
	EndIf
	
	// ----------------------------------------------
	// BOX: Juros
	// ----------------------------------------------
	nJuros:= iif(!cUfFav $"RJ#ES", nJurosF6, val(oItem:_valores:_juros:text))
	cJuros:= padl( 'R$ '+ alltrim(transform(nJuros, cMascara)),len(cMascara))  
	
	
	oImpGNRE:Box(nBox1 + 140,450,nBox3 + 140,600,'-6')
	oImpGNRE:Say(nBox1 + 148, 0453, 'Juros', oFont07N) 
	oImpGNRE:SayAlign( nBox1 + 148,0500,cJuros,oFont08, 96, 19, , 1)
	
	// ----------------------------------------------
	// BOX: Multa
	// ----------------------------------------------
	nMulta:= iif(!cUfFav $"RJ#ES", nMultaF6, val(oItem:_valores:_multa:text))
	cMulta:= PadL( 'R$ '+ alltrim(transform(nMulta, cMascara)),len(cMascara)) 
		
	oImpGNRE:Box(nBox1 + 160,450,nBox3 + 160,600,'-6')
	oImpGNRE:Say(nBox1 + 168, 0453, 'Multa', oFont07N) 
	oImpGNRE:SayAlign( nBox1 + 168,0500,cMulta,oFont08, 96, 19, , 1)
	
	// ----------------------------------------------
	// BOX: Total a Recolher
	// ----------------------------------------------
	nTotRec:= nTotRecF6
	cTotRec:= PadL( 'R$ '+ alltrim(transform(nTotRec, cMascara)),len(cMascara))	
		
		
	oImpGNRE:Box(nBox1 + 180,450,nBox3 + 180,600,'-6')
	oImpGNRE:Say(nBox1 + 188, 0453, 'Total a Recolher', oFont07N) 
	oImpGNRE:SayAlign( nBox1 + 188,0500,cTotRec,oFont08, 96, 19, , 1)
	
	
	// ----------------------------------------------
	// BOX: Código de Barras
	// ----------------------------------------------
	cCodBar	:= alltrim(cAutoriza)
	
	
	if len(cCodBar) == 44	
		
		cCodBar1A	:= substr(cCodBar,1,11)
		cCodBar1B	:= substr(cCodBar,12,11)
		cCodBar1C	:= substr(cCodBar,23,11)
		cCodBar1D	:= substr(cCodBar,34,11)
		
		cCodBar1X	:= cCodBar1A + ' '
		cCodBar1X	+= Mod11(cCodBar1A)+ ' '
		cCodBar1X	+= cCodBar1B+ ' '
		cCodBar1X	+= Mod11(cCodBar1B)+ ' '
		cCodBar1X	+= cCodBar1C+ ' '
		cCodBar1X	+= Mod11(cCodBar1C)+ ' '
		cCodBar1X	+= cCodBar1D+ ' '
		cCodBar1X	+= Mod11(cCodBar1D)	
		
		cCodBar1 := cCodBar1X
		
		//Tratamento para tirar os digitos
		cCodBar2	:= alltrim(cCodBar)	
	else 
		cCodBar1 := substr(cCodBar,1,11) + ' '+ substr(cCodBar,12,1) + ' ' + substr(cCodBar,13,11) + ' ' + substr(cCodBar,24,1) + ' '+ substr(cCodBar,25,11) + ' ' +substr(cCodBar,36,1) + ' ' + substr(cCodBar,37,11) + ' ' + substr(cCodBar,48,1)
		
		//Tratamento para tirar os digitos
		cCodBar2	:=  alltrim(substr(cCodBar,1,11) + substr(cCodBar,13,11) + substr(cCodBar,25,11) + substr(cCodBar,37,11) )
	endif
	
	
	oImpGNRE:say(nBox1 + 212, 0055, cCodBar1 , oFont10N)
	nFontSize := 40
	
	//Tratamento posição Código Barras 
	if nX==1
		nPosIni:= 18.5
	elseif nX==2
		nPosIni:= 42
	else
		nPosIni:= 65.5
	endif
	
	oImpGNRE:MSBAR("INT25",nPosIni,1,cCodBar2,oImpGNRE,.F.,Nil,Nil,0.020,0.8,Nil,Nil,"A",.F.)
	
	//Via Boleto
	if nX == 1 
		oImpGNRE:say(nBox1 + 215, 0555, '1ª via - Banco' , oFont07)
	elseif nX == 2
		oImpGNRE:say(nBox1 + 215, 0540, '2ª via - Contribuinte' , oFont07)
	else
		oImpGNRE:say(nBox1 + 215, 0522, '3ª via - Contribuinte/Fisco' , oFont07)
	endif 
	
	//Atribuo a ultima posição no nBox 1 para a via do contribuinte
	
	if nX == 1 .or. nX == 2
	    //linha pontilhada
		oImpGNRE:say(nBox1 + 270, 0000, replicate(' - ',100) , oFont07)
		if nX == 1
			nBox1 := 258
		elseif nX==2
			nBox1 := 535
		endif
	endif
	
next
If lMultItens
	cMascara	:= '@e 9,999,999,999,999.99'
	nPages := CalcPag(Len(aItens),nTotItens)
	For nY := 1 To nPages
		oImpGNRE:StartPage()
		nBox1 := 0
		// BOX Cabeçalho 
		oImpGNRE:Box(nBox1 ,0,034 ,600,'-6')
		oImpGNRE:Say(nBox1 + 10 , 0180, "Guia de Recolhimento de Tributos Estaduais - GNRE", oFont12N)  
		oImpGNRE:Say(nBox1 + 18 , 0230, "Itens da GNRE Múltipla nº " + CIB->CIB_NUMCTR , oFont07N)  
		oImpGNRE:Say(nBox1 + 26 , 0260,  "(Conforme ajuste SNIEF 09/2018)" , oFont07)  
		nBox1 := 34 // Atualiza linha
		// BOX Dados da UF e Data de emissão
		oImpGNRE:Box(nBox1 ,0,49 ,600,'-6')
		oImpGNRE:Say(nBox1 +8 , 020, "UF Favorecida:" , oFont07N)
		oImpGNRE:Say(nBox1 +8 , 0130, cUfFav , oFont07)
		// oImpGNRE:Say(nBox1 + 8, 0340 , "Data/Hora de Emissão" , oFont07N)
		// oImpGNRE:Say(nBox1 + 8, 0420 , "18/09/2018" , oFont07N)
		nBox1 := 49

		//  BOx Idenrtificação do emitente
		oImpGNRE:Box(nBox1 ,0,69 ,600,'-6')	
		oImpGNRE:Say(nBox1 +8  , 020, "Identificação Emitente: " , oFont07N)
		oImpGNRE:Say(nBox1 +8  , 0130, cCnpjCpfEm , oFont07)
		oImpGNRE:Say(nBox1 + 16, 020 , "Razão Social/Nome: " , oFont07N)
		oImpGNRE:Say(nBox1 + 16, 0130 , cRazEmi , oFont07)
		
		nBox1 := 71
		oImpGNRE:Say(nBox1 + 8 , 0300,  "Itens da GNRE" , oFont07N)  
		nBox1 := 82
		oImpGNRE:Box(nBox1 ,0  ,98 ,25,'-6') // Item
		oImpGNRE:Say(nBox1 +8  , 5, "Item" , oFont07N)

		oImpGNRE:Box(nBox1 ,25 ,98 ,250,'-6') // Dados do item
		oImpGNRE:Say(nBox1 +8  , 30, "Dados do Item" , oFont07N)

		oImpGNRE:Box(nBox1 ,250,98 ,310,'-6') // Receita
		oImpGNRE:Say(nBox1 +8  , 255, "Receita" , oFont07N)

		oImpGNRE:Box(nBox1 ,310,98 ,370,'-6') // Valor Principal
		oImpGNRE:Say(nBox1 +8  , 315, "Valor Principal" , oFont07N)

		oImpGNRE:Box(nBox1 ,370,98 ,430,'-6') // Multa e juros
		oImpGNRE:Say(nBox1 +8  , 375, "Multa/Juros" , oFont07N)

		oImpGNRE:Box(nBox1 ,430,98 ,490,'-6') // Valor total
		oImpGNRE:Say(nBox1 +8  , 435, "Valor Total" , oFont07N)

		oImpGNRE:Box(nBox1 ,490,98 ,600,'-6') // Controle UF
		oImpGNRE:Say(nBox1 +8  , 495, "Controle UF" , oFont07N)

		nBox1 += 2// Espaço entre cabeçalho do item e itens
		
		For nX := 1 To Len(aItens)
			nBox1 += 28  // Atualiza linha
			oImpGNRE:Box(nBox1 ,0  ,nBox1 + 28 ,25,'-6') // Item
			oImpGNRE:Say(nBox1 +8  , 5, AllTrim(AllTochar(nX)) , oFont07N)
				
			oImpGNRE:Box(nBox1 ,25 ,nBox1 + 28 ,250,'-6') // Dados do item
			
			oImpGNRE:Say(nBox1 +8  , 30, "Doc. Origem: " + aItens[nX]:_identgnre:_chavenf:Text , oFont07)
			 
			oImpGNRE:Say(nBox1 +16 , 30, "Vencimento: " + substr(aItens[nX]:_identgnre:_vencimento:Text,7,2)+'/'+ substr(aItens[nX]:_identgnre:_vencimento:Text,5,2)+'/'+ substr(aItens[nX]:_identgnre:_vencimento:Text,1,4) , oFont07)

			oImpGNRE:Box(nBox1 ,250,nBox1 + 28 ,310,'-6') // Receita
			oImpGNRE:Say(nBox1 +8  , 255, aItens[nX]:_identgnre:_Receita:Text , oFont07)
			
			// Procure os valores atualizados por guia
			cIdGnre := alltrim( aItens[nX]:_identgnre:_numerognre:Text )
			aRetSF6:= RetValSF6(cUfFav, cIdGnre , .F. )
		
			oImpGNRE:Box(nBox1 ,310,nBox1 + 28 ,370,'-6') // Valor Principal
			oImpGNRE:Say(nBox1 +8  , 312, 'R$ '+ AllTrim(Transform( Val(aItens[nX]:_valores:_principal:text) , cMascara))  , oFont07)

			oImpGNRE:Box(nBox1 ,370,nBox1 + 28 ,430,'-6') // Multa e juros
			oImpGNRE:Say(nBox1 +8  , 372,  'R$ '+ AllTrim(Transform( aRetSF6[2] + aRetSF6[3] + aRetSF6[1]  , cMascara))   , oFont07)

			oImpGNRE:Box(nBox1 ,430,nBox1 + 28 ,490,'-6') // Valor total
			oImpGNRE:Say(nBox1 +8  , 432, 'R$ '+ AllTrim(Transform( aRetSF6[4] , cMascara))   , oFont07)

			oImpGNRE:Box(nBox1 ,490,nBox1 + 28 ,600,'-6') // Controle UF
			oImpGNRE:Say(nBox1 +8  , 495, "" , oFont07)

		Next nX 
		nBox1 += 38
		oImpGNRE:Say(nBox1 ,0420 , "Total da GNRE (R$)" , oFont07N)
		oImpGNRE:Box(nBox1 -8 ,490  ,nBox1 + 2 ,600,'-6') // Item
		oImpGNRE:Say(nBox1 , 500 , PadL( 'R$ '+ AllTrim(Transform( nTotRecF6 , cMascara)),len(cMascara))   , oFont07N)

		oImpGNRE:Say(850 ,0550 , "Página " +  AllTrim(AllToChar(nY)) + "/"  + AllTrim(AllToChar(nPages)) + ".", oFont07N)
		oImpGNRE:EndPage()
	Next nY	
EndIf

return(.T.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} NoAcentReco
Funcao responsavel por retirar caracteres especiais das String

@author Danilo.Santos 
@since 20.09.2016
@version 1.0 

@return .T.
/*/
//-----------------------------------------------------------------------
Static Function NoAcentReco(cXmlGnre)

Local cByte,ni
Local s1:= "áéíóú" + "ÁÉÍÓÚ" + "âêîôû" + "ÂÊÎÔÛ" + "äëïöü" + "ÄËÏÖÜ" + "àèìòù" + "ÀÈÌÒÙ"  + "ãõÃÕ" + "çÇ" + "ãõÃÕ"
Local s2:= "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU"  + "aoAO" + "cC" + "aoAO"
Local nPos:=0, nByte
Local cRet:=''
Default cXmlGnre := ""

cXmlGnre := (StrTran(cXmlGnre,"&","&amp;")) 

For ni := 1 To Len(cXmlGnre)
	cByte := Substr(cXmlGnre,ni,1)
	nByte := ASC(cByte)
	If nByte > 122 .Or. nByte < 48 .Or. ( nByte > 57 .And. nByte < 65 ) .Or. ( nByte > 90 .And. nByte < 97 )
		nPos := At(cByte,s1)
		If nPos > 0
			cByte := Substr(s2,nPos,1)
		Else
			If cByte $ "<"
				cByte := "<"
			Elseif cByte $ ">"
				cByte := ">"
			Elseif cByte $ "/"
				cByte := "/"
			Endif

		EndIf
	EndIf
	cRet+=cByte
Next

Return(AllTrim(cRet))

//------------------------------------------------------------------------------
/*/{Protheus.doc} RetInfComp
Função que retorna mensagens a serem apresentadas no box de Inf. Complementares
de acordo com as informações extras

@author Simone dos Santos de Oliveira
@since 27/07/2017

/*/
//-------------------------------------------------------------------------------
static function RetInfComp( oGnreXml )

//alltrim( oIdent:_informacoes:text )

local aMsg	   := {'','',''}
local cEspecie := ''

//Informações Complementares ( F6_INF )
if !empty( alltrim( oIdent:_informacoes:text ))
	aMsg[1]:= alltrim( oIdent:_informacoes:text ) +CRLF
endif

//Observações ( F6_OBSERV )
if !empty( alltrim( oIdent:_observacoes:text ))
	aMsg[2]:= alltrim( oIdent:_observacoes:text ) +CRLF
endif

//Chave NF-e
if !empty( oIdent:_chavenf:text )
	aMsg[3]:= 'Chave NFe: '+ alltrim( oIdent:_chavenf:text ) 
endif

return aMsg

//------------------------------------------------------------------------------
/*/{Protheus.doc} RetValSF6
Função que retorna mensagens a serem apresentadas no box de Inf. Complementares
de acordo com as informações extras

@author Simone dos Santos de Oliveira
@since 27/07/2017

/*/
//-------------------------------------------------------------------------------
static function RetValSF6( cUfFav, cIdGnre , lMultItens)

local aSF6Val	:= {0,0,0,0,'',0}
local lDtlim	:= SF6->(fieldpos("F6_DTLIMI")) > 0

default cUfFav  := ''
default cIdGnre := ''
Default lMultItens	:= .F.

if ! ( empty(cUfFav ) .and. empty(cIdGnre) )
	If lMultItens
		dbSelectArea("CIB")
		CIB->(dbSetOrder(2))
		if CIB->( DbSeek (xFilial("CIB") + cUfFav + cIdGnre ) )	
			aSF6Val[1] := CIB->CIB_ATUMON
			aSF6Val[2] := CIB->CIB_JUROS
			aSF6Val[3] := CIB->CIB_MULTA
			aSF6Val[4] := CIB->CIB_VALOR + CIB->CIB_ATUMON + CIB->CIB_JUROS + CIB->CIB_MULTA
			aSF6Val[6] := CIB->CIB_VALOR 
		endif	
	Else
		dbSelectArea("SF6")
		SF6->(dbSetOrder(1))
		
		if dbSeek(xFilial("SF6")+cUfFav+cIdGnre)	
			aSF6Val[1] := SF6->F6_ATMON
			aSF6Val[2] := SF6->F6_JUROS
			aSF6Val[3] := SF6->F6_MULTA
			aSF6Val[4] := SF6->F6_VALOR + SF6->F6_ATMON + SF6->F6_JUROS + SF6->F6_MULTA
			if lDtlim
				aSF6Val[5] := dtoc(SF6->F6_DTLIMI) 
			endif	
			aSF6Val[6] := SF6->F6_VALOR 
		endif
	EndIf
endif

return aSF6Val
//------------------------------------------------------------------------------
/*/{Protheus.doc} Mod11
Função que retorna Dígito código de barras

@author Simone dos Santos de Oliveira
@since 30/10/2017

/*/
//-------------------------------------------------------------------------------
Static Function Mod11( cNum )
Local nFor    := Len(cNum)
Local nTot    := 0
Local aNumAux := Array(Len(cNum),3) //array com o conteudo do cNum para ser multiplicado
Local aLisMult:= {9,8,7,6,5,4,3,2} //Array/Lista de Multiplicadores
Local nResto  
Local nDv   
Local nPos 	  := Len(aLisMult)

For nFor := Len(cNum) To 1 Step -1
	aNumAux[nFor,1] := Val(SubStr(cNum,nFor,1))
	aNumAux[nFor,2] := aLisMult[nPos]
	nPos--
	If nPos == 0
		nPos := 8
	EndIf
	aNumAux[nFor,3] := aNumAux[nFor,2] * aNumAux[nFor,1]
	nTot += aNumAux[nFor,3]
Next

nResto := nTot % 11
nDv := 11-nResto

If (nResto == 0 .Or.	nResto == 1)
	nDv := 0
ElseIf nResto == 10
	nDv := 1
Else 
	nDv := 11-nResto
EndIf

Return Str(nDv,1)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Versao
Tratativa para exibir o documento de origem no relatório
Dúvidas sobre o preenchimento desse campo basta acessar o site http://www.testegnre.pe.gov.br/gnre/v/guia/index.
@author Raphael Augustos
@since 30/10/2019
/*/
//-------------------------------------------------------------------------------
Static  Function DocOrig(cCodigo)
Local cRet	:= ""
Default cCodigo := ""
// Se o documento de origem é uma chave eletrônico retorno apenas o numero do documento. 
If Len(cCodigo) == 44
	cRet := SubStr(cCodigo,26,9)
Else
	cRet := Alltrim(cCodigo)	
EndIf

Return cRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CalcPag
Função responsável por calcular a quantidade de pagínas. Quando a impressão for de múltiplos documentos
@author Raphael Augustos
@since 30/10/2019
/*/
//-------------------------------------------------------------------------------
Static Function CalcPag(nItens,nTotItens)
Local nPages 	:= 0
DEFAULT nItens 		:= 0
DEFAULT nTotItens 	:= 0
If Mod( nItens , nTotItens ) == 0
	nPages := nItens / nTotItens
Else
	nPages		:= Int(nItens / nTotItens) + 1
EndIf

Return nPages
