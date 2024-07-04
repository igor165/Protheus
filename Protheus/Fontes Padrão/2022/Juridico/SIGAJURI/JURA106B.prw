#INCLUDE "JURA106B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static oResJ106Tr := JsonObject():New()
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106B
Follow-ups

@author Juliana Iwayama Velho
@since 06/10/09
@version 1.0
/*/

//--------------------------------------------------------------------
/*/{Protheus.doc} JA106GFWIU
Rotina para inclusão de follow-ups por intervenção do usuário a
partir do follow-up padrão

@param  cAssJur  - Código do assunto jurídico
@param  cCodFw   - Código do follow-up
@param  dDtFw    - Data do follow-up
@param  cTipoFw  - Tipo do follow-up
@param  cFwPai   - Código do follow-up pai
@param lDtProxEv - Se a data vem do campo prox evento

@author Juliana Iwayama Velho
@since 06/10/09
@version 1.0

@obs NTAMASTER - Dados do Follow-ups
@obs NTEDETAIL - Responsáveis

/*/
//-------------------------------------------------------------------
Function JA106GFWIU(cAssJur, cCodFw, dDtFw , cTipoFw, cFwPai, lDtProxEv, cCodAnd)
Local aArea     := GetArea()
Local aAreaNRT  := NRT->( GetArea() )
Local aAreaNVD  := NVD->( GetArea() )
Local dNvDtFw   := ctod('')
Local cDescr    := NRT->NRT_DESC
Local lWSTLegal := JModRst()

Default lDtProxEv := .F.
Default cCodAnd   := ""

	If !lWSTLegal
		IF Empty(NRT->NRT_DATAT ) .And. Empty( NRT->NRT_QTDED ) //verificar se é totvsLegal e setar dDtFw, tipo data e qtd dias
			dNvDtFw := JA106GERAF(dDtFw,,,, lDtProxEv)
		Else
			dNvDtFw := JUR106DTFU(NRT->NRT_DATAT, dDtFw, NRT->NRT_QTDED) 
		EndIf
	Else
		dNvDtFw := JUR106DTFU("2", dDtFw, 0) 
	EndIf

	If !Empty ( dNvDtFw )
		
		//-------------------------------------------------------------------------	
		//seta variáveis estáticas para utilizar na inicialização padrão dos campos
		//campo em branco é o antigo advogado correspondente
		//-------------------------------------------------------------------------

		If Empty(cDescr)
			cDescr := Iif(Empty(NTA->NTA_DESC),NT4->NT4_DESC,NTA->NTA_DESC)
		EndIf

		JURSETXVAR( { NRT->NRT_CTIPOF, dNvDtFw, NRT->NRT_HORAF, NRT->NRT_DURACA, NRT->NRT_CPREPO, ;
					'', NRT->NRT_CRESUL, NRT->NRT_CSUATO, NRT->NRT_CFASE, NRT->NRT_SUGDES, cDescr,;
					NRT->NRT_COD, cAssJur, cCodFw } )
		
		If !lWSTLegal
			FWExecView(STR0001,'JURA106',3,,{||.T.}) //"Incluir"
		Else
			J100IUJson(dNvDtFw, cCodFw, cCodAnd)
		EndIf

		JURCLEXVAR()
		
	EndIf

	RestArea( aAreaNRT )
	RestArea( aAreaNVD )
	RestArea( aArea )

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106GERAF
Rotina para abrir a tela de gerar novo follow-up

@param dData   - Data do follow-up
@param aCoord  - Coordenadas do tamanho da tela
@param cTpData - Tipo de Calculo.
		[1] - Retroativa
		[2] - Futura - dias corridos
		[3] - Futura - dias úteis
@param nQtdeDias - Quantidades a se calculado
@param lDtProxEv - Se a data vem do campo prox evento, se sim, não calcula as datas 

@return dRet        Nova data

@author Juliana Iwayama Velho
@since 07/10/09
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA106GERAF(dData, aCoord, cTipoData, nQtdeDias, lDtProxEv)
Local aArea     := GetArea()
Local dRet      := ctod('')
Local dDataFw   := ctod('')
Local aItems    := {'1=Retroativa','2=Futura - dias corridos', '3=Futura - dias úteis'}
Local oDlg, oBtnOk, oBtnCan
Local oGetQtdeDias,oSayQtdeDias,oSayData,oCmbTipoData,oSayTipoData,oSayData2
Local oPnlTop, oPnlMid, oPnlMidR, oPnlMidL,oPnlBtn

ParamType 1 Var aCoord  As Array Optional Default { 0, 0, 160, 230 }

DEFAULT nQtdeDias := 0
DEFAULT cTipoData := '2'
Default lDtProxEv := .F.

	dDataFw   := JUR106DTFU(cTipoData, dData, nQtdeDias, lDtProxEv)
	dRet      := dDataFw    //Se nao atribuir aqui e nada for mudado no dialogo irá sair em branco.

	Define MsDialog oDlg FROM aCoord[1], aCoord[2] To aCoord[3], aCoord[4] Title STR0002 Pixel Of oMainWnd //"Gera Novo Follow-up"

	oPnlTop       := tPanel():New(0,0,'',oDlg,,,,,,0,30)
	oPnlMid       := tPanel():New(0,0,'',oDlg,,,,,,0,0)
	oPnlBtn       := tPanel():New(0,0,'',oDlg,,,,,,0,20)
	oPnlTop:Align := CONTROL_ALIGN_TOP
	oPnlMid:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlBtn:Align := CONTROL_ALIGN_BOTTOM

	oPnlMidR 	  := tPanel():New(0,0,'',oPnlMid,,,,,,0,0)
	oPnlMidL 	  := tPanel():New(0,0,'',oPnlMid,,,,,,40,0)
	oPnlMidR:Align:= CONTROL_ALIGN_ALLCLIENT
	oPnlMidL:Align:= CONTROL_ALIGN_LEFT

	oPnlBtnR      := tPanel():New(0,0,'',oPnlBtn,,,,,,0,0)
	oPnlBtnL      := tPanel():New(0,0,'',oPnlBtn,,,,,,40,0)
	oPnlBtnR:Align:= CONTROL_ALIGN_ALLCLIENT
	oPnlBtnL:Align:= CONTROL_ALIGN_LEFT

	oSayTipoData := tSay():New(01,03,{||STR0003},oPnlTop,,,,,,.T.,,,50,10) //"Tipo Data"
	oSayTipoData:lWordWrap   := .T.
	oSayTipoData:lTransparent:= .T.

	oCmbTipoData := TComboBox():New(10,03,{|u|if(PCount()>0,cTipoData:=u,cTipoData)},;
	aItems,100,20,oPnlTop,,{||dRet:= JUR106DTFU(cTipoData, dData, nQtdeDias, lDtProxEv),;
	oSayData2:SetText(dRet)/*Ação*/},,,,.T.,,,,,,,,,'cTipoData')

	oSayQtdeDias := tSay():New(01,03,{||STR0004},oPnlMidL,,,,,,.T.,,,50,10) //"Num de Dias"
	oSayQtdeDias:lWordWrap   := .T.
	oSayQtdeDias:lTransparent:= .T.

	oGetQtdeDias := TGet():New( 10,03,{|u|if(PCount()>0,nQtdeDias:=u,nQtdeDias)},oPnlMidL,30,10,"999",;
	{||dRet:= JUR106DTFU(cTipoData, dData, nQtdeDias, lDtProxEv),;
	oSayData2:SetText(dRet)},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'nQtdeDias',,,, )

	oSayData := tSay():New(01,03,{||STR0005},oPnlMidR,,,,,,.T.,,,50,10) //"Data Follow-up"
	oSayData:lWordWrap   := .T.
	oSayData:lTransparent:= .T.

	oSayData2 := tSay():New(10,03,{||dDataFw},oPnlMidR,,,,,,.T.,,,50,10)
	oSayData2:lWordWrap   := .F.

	@ 03,03 Button oBtnOk  Prompt STR0008  Size 30,10 Pixel Of oPnlBtnL Action ( oDlg:End() ) //'Ok'
	@ 03,03 Button oBtnCan Prompt STR0006  Size 30,10 Pixel Of oPnlBtnR Action ( If( ApMsgYesNo(STR0007) ,; //"Cancelar" "Deseja realmente cancelar a inclusão deste follow-up?"
	( dRet := ctod(''), oDlg:End() ), .F.) )

	Activate MsDialog oDlg Centered

	RestArea( aArea )

Return dRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J106FlxInt
Responsável por obter os dados do modelo de geração do FUP por meio
do tipo de fup ou ato processual

@param cCodigo:   Código do Tipo do Fup ou Ato Processual.
@param cTpFilter: Tipo da busca
		[1] - Por ato processual
		[2] - Por tipo do FUP

@since 19/11/2020
/*/
//-------------------------------------------------------------------
Function J106FlxInt(cCodPai, cTpFilter)
Local cQuery     := ''
Local cSelect    := ''
Local cJoin      := ''
Local cWhere     := ''
Local cTpEntid   := IIF(cTpFilter == '1', 'ato', 'tipoFUP')
Local aDadosTpFp := {}

	cSelect := 'SELECT NRT.NRT_TIPOGF, '
	cSelect +=        'NRT.NRT_CTIPOF, '
	cSelect +=        'NRT.NRT_QTDED, '
	cSelect +=        'NRT.NRT_DATAT, '
	cSelect +=        'NRT.NRT_HORAF, '
	cSelect +=        'NRT.NRT_DURACA, '
	cSelect +=        'NRT.NRT_CPREPO, '
	cSelect +=        'NRT.NRT_CADVGC, '
	cSelect +=        'NRT.NRT_CRESUL, '
	cSelect +=        'NRT.NRT_CSUATO, '
	cSelect +=        'NRT.NRT_CFASE, '
	cSelect +=        'NRT.NRT_SUGDES, '
	cSelect +=        'NRT.NRT_COD, '
	cSelect +=        'NRR.NRR_CPART, '

	If cTpFilter == '1'
		cSelect +=        'NQS.NQS_DESC '
		cSelect += 'FROM '+ RetSqlName('NRO') + ' NRO '

		cJoin := 'INNER JOIN '+ RetSqlName('NRT') + ' NRT ON ( '
		cJoin +=     "NRT.NRT_FILIAL = '" + xFilial('NRT') + "' "
		cJoin +=     'AND NRT.NRT_COD = NRO.NRO_CFWPAD '
		cJoin +=     "AND NRT.D_E_L_E_T_ = ' '"
		cJoin += ") "

		cJoin += 'LEFT JOIN '+ RetSqlName('NQS') + ' NQS ON ( '
		cJoin +=     "NQS.NQS_FILIAL = '" + xFilial('NQS') + "' "
		cJoin +=     'AND NQS.NQS_COD = NRT.NRT_CTIPOF '
		cJoin +=     "AND NQS.D_E_L_E_T_ = ' '"
		cJoin += ") "

		cWhere := "WHERE NRO.D_E_L_E_T_ = ' ' "
		cWhere +=     "AND NRO.NRO_FILIAL = '" + xFilial('NRO') + "'"
		cWhere +=     "AND NRO.NRO_COD = '" + cCodPai + "'"
	Else
	
		cSelect +=        'NQS1.NQS_DESC '
		cSelect += 'FROM '+ RetSqlName('NQS') + ' NQS '

		cJoin := 'INNER JOIN '+ RetSqlName('NVD') + ' NVD ON ( '
		cJoin +=     "NVD.NVD_FILIAL = '" + xFilial('NVD') + "' "
		cJoin +=     'AND NVD.NVD_CTIPOF = NQS.NQS_COD '
		cJoin +=     "AND NVD.D_E_L_E_T_ = ' '"
		cJoin += ") "

		cJoin += 'LEFT JOIN '+ RetSqlName('NRT') + ' NRT ON ( '
		cJoin +=     "NRT.NRT_FILIAL = '" + xFilial('NRT') + "' "
		cJoin +=     'AND NRT.NRT_COD = NVD.NVD_CTFPAD '
		cJoin +=     "AND NRT.D_E_L_E_T_ = ' '"
		cJoin += ") "

		cJoin += 'LEFT JOIN '+ RetSqlName('NQS') + ' NQS1 ON ( '
		cJoin +=     "NQS1.NQS_FILIAL = '" + xFilial('NQS') + "' "
		cJoin +=     'AND NQS1.NQS_COD = NRT.NRT_CTIPOF '
		cJoin +=     "AND NQS1.D_E_L_E_T_ = ' '"
		cJoin += ") "

		cWhere := "WHERE NQS.D_E_L_E_T_ = ' ' "
		cWhere +=     "AND NQS.NQS_FILIAL = '" + xFilial('NQS') + "'"
		cWhere +=     "AND NQS.NQS_COD = '" + cCodPai + "'"

		aDadosTpFp := JurGetDados('NQS', 1, xFilial('NQS') + cCodPai, { 'NQS_TIPOGA',;
																		'NQS_SUGERE',;
																		'NQS_DESCRI',;
																		'NQS_CSUGES',;
																		'NQS_CRESUL'})
	EndIf
	
	cJoin += 'LEFT JOIN '+ RetSqlName('NRR') + ' NRR ON ( '
	cJoin +=     "NRR.NRR_FILIAL = '" + xFilial('NRR') + "' "
	cJoin +=     'AND NRR.NRR_CFOLWP = NRT.NRT_COD '
	cJoin +=     "AND NRR.D_E_L_E_T_ = ' '"
	cJoin += ") "

	cQuery := cSelect + cJoin + cWhere

Return { cTpEntid, cCodPai, aDadosTpFp, JurSQL(cQuery, '*') }

//-------------------------------------------------------------------
/*/{Protheus.doc} J106SetFlx
Responsável por preencher a estrutura de retorno do fluxo de geração de FUP
ou atos manuais e automático do TOTVS JURÍDICO.

@param oResponse:  Objeto de estrutura do fluxo de FUP com os andamentos
@param cAto:       Código do Ato Processual.
@param cTpFUP:     Código do Tipo do Fup.
@param cTpFilter:  Tipo da busca
				   [1]: Por ato processual
				   [2]: Por tipo do FUP
@param lRecursivo: Indica se a chamada é recursiva.
@param aSubItems:  Array contendo o objeto de subitens para a chamada recursiva.

@return oResJ106Tr: Objeto local de estrutura do fluxo de FUP com os andamentos.

@since 20/11/2020
/*/
//-------------------------------------------------------------------
Function J106SetFlx(oResponse, cAto, cTpFUP, cTpFilter, lRecursivo, aSubItems, cResulFup)
Local aDados    := {}
Local aItemsFlx := {}
Local nI        := 1
Local cAtoRec   := ''
Local cTpFupRec := ''
Local cDesc     := ''
Local aInfoOrig := {}
Local lShowDesc := .F.

Default cResulFup  := ''
Default lRecursivo := .F.
Default aSubItems  := {}

	If !lRecursivo
		oResJ106Tr := oResponse
	
		oResJ106Tr['fluxo'] := {}
		aAdd( oResJ106Tr['fluxo'], JsonObject():New() )
	EndIf

	Do Case
		Case cTpFilter == '1' // Busca por ato processual
			aDados    := J106FlxSub(cAto, '1')

			If !lRecursivo
				aInfoOrig := JurGetDados('NRO', 1, xFilial('NRO') + cAto, { 'NRO_DESC',;
																			'NRO_SUGDES',;
																			'NRO_DESPAD',;
																			'NRO_CFASE'})
			EndIf

		Case cTpFilter == '2' // Busca por Tipo de FUP
			aDados    := J106FlxSub(cTpFUP, '2', ,cResulFup)

			If !lRecursivo
				aInfoOrig := JurGetDados('NQS', 1, xFilial('NQS') + cTpFUP, { 'NQS_DESC',;
																			  'NQS_SUGDES',;
																			  'NQS_DESPAD'})
			EndIf
	EndCase

	If Len(aDados) > 0
		If !lRecursivo
			lShowDesc := (cTpFilter == '1' .And. aInfoOrig[2] == '1') .OR.;
						 (cTpFilter == '2' .And. aInfoOrig[2] == '2')

			aTail(oResJ106Tr['fluxo'])['items']       := {}
			aTail(oResJ106Tr['fluxo'])['name']        := JurEncUTF8( Alltrim(aInfoOrig[1]) )
			aTail(oResJ106Tr['fluxo'])['description'] := JurEncUTF8( Alltrim(aInfoOrig[3]) )
			aTail(oResJ106Tr['fluxo'])['fase']        := IIf(Len(aInfoOrig) > 3, aInfoOrig[4], '')
			aTail(oResJ106Tr['fluxo'])['type']        := cTpFilter
			aTail(oResJ106Tr['fluxo'])['isShowDesc']  := lShowDesc
			aTail(oResJ106Tr['fluxo'])[aDados[1]]     := aDados[2]
			
			aItemsFlx := aTail(oResJ106Tr['fluxo'])['items']
		Else
			aItemsFlx := aSubItems
		EndIf

		If Len(aDados[3]) > 0
			For nI := 1 to Len(aDados[3])
				aAdd(aItemsFlx, JsonObject():New())
				aTail(aItemsFlx)['type']        := aDados[3][nI][1]
				aTail(aItemsFlx)['id']          := aDados[3][nI][3]
				aTail(aItemsFlx)['isAutomatic'] := aDados[3][nI][2]
				aTail(aItemsFlx)['name']        := JurEncUTF8( Alltrim(aDados[3][nI][5]) )
				aTail(aItemsFlx)['isShowDesc']  := aDados[3][nI][6]

				aTail(aItemsFlx)['subItem']     := {}
				aSubItems := aTail(aItemsFlx)['subItem']

				If aDados[3][nI][1] == "1"
					cAtoRec := aDados[3][nI][3]
					cDesc   := IIf(aDados[3][nI][6], aDados[3][nI][7], aDados[3][nI][4])

					aTail(aItemsFlx)['description'] := JurEncUTF8( Alltrim(cDesc) )
					aTail(aItemsFlx)['fase']        := aDados[3][nI][8]
				Else
					cTpFupRec := aDados[3][nI][3]

					aTail(aItemsFlx)['description'] := JurEncUTF8( Alltrim(aDados[3][nI][4]) )
					aTail(aItemsFlx)['typeDate']    := aDados[3][nI][7]
					aTail(aItemsFlx)['hour']        := aDados[3][nI][8]
					aTail(aItemsFlx)['responsavel'] := aDados[3][nI][9]
					aTail(aItemsFlx)['status']      := aDados[3][nI][10]
					aTail(aItemsFlx)['preposto']    := aDados[3][nI][11]
					aTail(aItemsFlx)['fase']        := aDados[3][nI][12]
					aTail(aItemsFlx)['qtdDays']     := aDados[3][nI][13]
					aTail(aItemsFlx)['descType']    := aDados[3][nI][14]

					cResulFup := aDados[3][nI][10]
				EndIf
				
				J106SetFlx(, cAtoRec, cTpFupRec, aDados[3][nI][1], .T., aSubItems, cResulFup)
			Next
			
		EndIf
	EndIf

Return oResJ106Tr

//-------------------------------------------------------------------
/*/{Protheus.doc} J106FlxSub
Responsável por disponibilizar os dados obtidos e filtrados do modelo
que vai gerar novos FUPs e andamentos para o TOTVS JURÍDICO.

@param cCodigo:   Código do Tipo do Fup ou Ato Processual.
@param cTpFilter: Tipo da busca
		[1] - Por ato processual
		[2] - Por tipo do FUP
@param aDados:
		*** ADADOS[2] ***
			ADADOS[2][1]:  cIndex  = Registro é Ato processual ou Tipo de FUP
			ADADOS[2][2]:  cCodigo = Cód. Ato ou tipo do Fup que originou
		
		*** ADADOS[3] ***
		ADADOS[3][1]:  NQS_TIPOGA = Define se o cadastro do andamento vai ser forma
										1 - automática / 2 - intervenção do usuário
		ADADOS[3][2]:  NQS_SUGERE = Define se este FUP gera andamento
		ADADOS[3][3]:  NQS_DESCRI = Descrição para ser gravado no Andamento
		ADADOS[3][4]:  NQS_CSUGES = Cód. do ato processual que será gravado 
										no andamento

		*** ADADOS[4] ***
		ADADOS[4][1]:  NRT_TIPOGF = Define se o cadastro que o modelo irá realizar
										será 1 - automático / 2 - intervenção do usuário
		ADADOS[4][2]:  NRT_CTIPOF = Cód. tipo do Fup que será gerado do modelo
		ADADOS[4][3]:  NRT_QTDED  = Quantidade de dias para calculo da data
		ADADOS[4][4]:  NRT_DATAT  = Define se o calculo da data será
										1- Retroativa / 2 - Futura
		ADADOS[4][5]:  NRT_HORAF  = Hora do FUP
		ADADOS[4][6]:  NRT_DURACA = Hora de duração do FUP
		ADADOS[4][7]:  NRT_CPREPO = Cód. do preposto do FUP
		ADADOS[4][8]:  NRT_CADVGC = Cód. do advogado do FUP
		ADADOS[4][9]:  NRT_CRESUL = Cód. do resultado do FUP
		ADADOS[4][10]: NRT_CSUATO = Cód. ato do andamento do FUP
		ADADOS[4][11]: NRT_CFASE  = Cód. fase processual do FUP
		ADADOS[4][12]: NRT_SUGDES = Define se a descrição do FUP vem do
										1 - Andamento ou Follow Up Origem / 2 - Modelo
		ADADOS[4][13]: NTR_COD    = Código do Modelo
		ADADOS[4][14]: NRR_CPART  = Cód. do responsável do FUP
		ADADOS[4][15]: NQS_DESC   = Descrição do tipo do FUP

@param cResulFup: Resultado do FUP do modelo pai

@return aDados[1]: Tipo da endidade
		aDados[2]: Código da entidade
		aRet: 
			Para Andamentos:
				aRet[1]: tipo entidade = Andamento  
				aRet[2]: 1 - automático / 2 - intervenção do usuário 
				aRet[3]: ato 
				aRet[4]: sugestão descrição do Tipo do Fup para o Ato 
				aRet[5]: nome ato 
				aRet[6]: 1 - Sugere descrição / 2 - Não sugere descrição 
				aRet[7]: Descrição de Sugestão do Ato
				aRet[8]: Fase processual do Ato 

			Para Follow-ups:
				aRet[1]: tipo entidade = FUP
				aRet[2]: 1 - automático / 2 - intervenção do usuário
				aRet[3]: tipo FUP
				aRet[4]: sugestão descrição origem
				aRet[5]: nome tipo FUP
				aRet[6]: 1 - Andamento/Follow Up - Origem / 2 - Modelo
				aRet[7]: tipo data (1- Retroativa / 2 - Futura)
				aRet[8]: hora FUP
				aRet[9]: Responsável do FUP
				aRet[10]: Status do FUP
				aRet[11]: Preposto do FUP
				aRet[12]: Fase do FUP
				aRet[13]: Quantidade de dias para calcular a data de sugestão

@since 19/11/2020
/*/
//-------------------------------------------------------------------
Static Function J106FlxSub(cCodigo, cTpFilter, aDados, cResulFup)
Local aRet       := {}
Local aInfoAnd   := {}
Local nI         := 1
Local cDesc      := ''
Local cSiglaResp := ''
Local lAddAnd    := .F.

Default aDados    := J106FlxInt(cCodigo, cTpFilter)
Default cResulFup := ''

	If Len(aDados) > 0
		// FUP
		If Len(aDados[4]) > 0
			For nI := 1 to Len(aDados[4])
				If !Empty(aDados[4][nI][2])
					cDesc      := JurGetDados('NRT', 1, xFilial('NRT') + aDados[4][nI][13], 'NRT_DESC')
					cSiglaResp := JurGetDados('RD0', 1, xFilial('RD0') + aDados[4][nI][14], 'RD0_SIGLA')

					aAdd(aRet, { '2',                      /* 1  / tipo entidade = FUP */;
								 aDados[4][nI][1] == '1',  /* 2  / 1 - automático / 2 - intervenção do usuário */;
								 aDados[4][nI][2],         /* 3  / tipo FUP */;
								 cDesc,                    /* 4  / sugestão descrição origem */;
								 aDados[4][nI][15],        /* 5  / nome tipo FUP */;
								 aDados[4][nI][12] == '2', /* 6  / 1 - Andamento/Follow Up - Origem / 2 - Modelo */;
								 aDados[4][nI][4],         /* 7  / tipo data (1- Retroativa / 2 - Futura - Dias corridos/ 3 - Futura - Dias úteis) */;
								 aDados[4][nI][5],         /* 8  / hora FUP */;
								 cSiglaResp,               /* 9  / Responsável do FUP */;
								 aDados[4][nI][9],         /* 10 / Status do FUP */;
								 aDados[4][nI][7],         /* 11 / Preposto do FUP */;
								 aDados[4][nI][11],        /* 12 / Fase do FUP */;
								 aDados[4][nI][3],         /* 13 / Quantidade de dias para calcular a data de sugestão */;
								 aDados[4][nI][12],        /* 14  / 1 - Andamento/Follow Up - Origem / 2 - Modelo */;
							   })
				EndIf
			Next
		EndIf

		// Andamento
		If (Len(aDados[3]) > 0 .And. aDados[3][2] == '1' .And. !Empty(aDados[3][4]))
			If Empty(aDados[3][5]) .Or. aDados[3][5] == cResulFup
				lAddAnd := .T.
			EndIf

			If lAddAnd
				aInfoAnd := JurGetDados('NRO', 1, xFilial('NRO') + aDados[3][4], { 'NRO_DESC',;
																				   'NRO_SUGDES',;
																				   'NRO_DESPAD',;
																				   'NRO_CFASE'})
				aAdd(aRet, { '1',                 /* 1 / tipo entidade = Andamento */;
							 aDados[3][1] == '1', /* 2 / 1 - automático / 2 - intervenção do usuário */;
							 aDados[3][4],        /* 3 / ato */;
							 aDados[3][3],        /* 4 / sugestão descrição do Tipo do Fup para o Ato */;
							 aInfoAnd[1],         /* 5 / nome ato */;
							 aInfoAnd[2] == '1',  /* 6 / 1 - Sugere descrição / 2 - Não sugere descrição */;
							 aInfoAnd[3],         /* 7 / Descrição de Sugestão do Ato*/;
							 aInfoAnd[4]          /* 8 / Fase processual do Ato */;
							})
			EndIf
		EndIf
	EndIf

Return { aDados[1] /*tipo endidade*/, aDados[2] /*cód. entidade*/, aRet }

