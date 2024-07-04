#INCLUDE "JURA041.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA041
Tabela de Servicos

@author David Gon�alves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA041()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRE" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRE" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transa��o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Altera��o sem inclus�o de registros
7 - C�pia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author David Gon�alves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA041", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA041", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA041", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA041", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA041", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tabela de Servicos

@author David Gon�alves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA041" )
Local oStructNRE //Tabela de Servi�os
Local oStructNS5 //Valores dos Servi�os
Local oStructNU1 //Hist�rico da Tabela
Local oStructNTS //Hist�rico dos Valores

oStructNRE := FWFormStruct( 2, "NRE" )
oStructNS5 := FWFormStruct( 2, "NS5" )

oStructNU1 := FWFormStruct( 2, "NU1" )
oStructNTS := FWFormStruct( 2, "NTS" )

oStructNS5:RemoveField( "NS5_CTAB" )
oStructNU1:RemoveField( "NU1_CTAB" )
oStructNU1:RemoveField( "NU1_COD" )

oStructNTS:RemoveField( "NTS_CTAB" )
oStructNTS:RemoveField( "NTS_CHIST" )
oStructNTS:RemoveField( "NTS_COD" )

JurSetAgrp( 'NRE',, oStructNRE )

oView := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( "JURA041_TABSRV" , oStructNRE, "NREMASTER"  )
oView:AddGrid(  "JURA041_DETSRV" , oStructNS5, "NS5DETAIL"  )

oView:AddGrid( "JURA041_HSTTAB" , oStructNU1, "NU1DETAIL"  )
oView:AddGrid( "JURA041_HSTDET" , oStructNTS, "NTSDETAIL"  )

oView:CreateFolder("FOLDER_01")
oView:AddSheet("FOLDER_01", "ABA_01_01", STR0013 ) // "Tab. Servi�os"
oView:AddSheet("FOLDER_01", "ABA_01_02", STR0014 ) // "Hist�rico"

oView:CreateHorizontalBox( "FORMTABSRV"  , 30 ,,,"FOLDER_01","ABA_01_01")
oView:CreateHorizontalBox( "FORMDETSRV"  , 70 ,,,"FOLDER_01","ABA_01_01")
oView:CreateHorizontalBox( "FORMHSTTAB"  , 30 ,,,"FOLDER_01","ABA_01_02")
oView:CreateHorizontalBox( "FORMHSTDET"  , 70 ,,,"FOLDER_01","ABA_01_02")

oView:SetOwnerView( "JURA041_TABSRV"  , "FORMTABSRV"  )
oView:SetOwnerView( "JURA041_DETSRV"  , "FORMDETSRV"  )

oView:SetOwnerView( "JURA041_HSTTAB"  , "FORMHSTTAB"  )
oView:SetOwnerView( "JURA041_HSTDET"  , "FORMHSTDET"  )

oStructNU1:SetProperty('NU1_CTIPO' , MVC_VIEW_CANCHANGE, .T.) //Retirar a linha ap�s a vers�o 12.1.8 (foi ajustado no dicionario) Luciano

oView:SetUseCursor( .T. )
oView:SetDescription( STR0007 ) // "Tabela de Servicos"
oView:EnableControlBar( .T. )

oView:EnableTitleView( "JURA041_DETSRV" )
oView:EnableTitleView( "JURA041_HSTTAB" )
oView:EnableTitleView( "JURA041_HSTDET" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tabela de Servicos

@author David Gon�alves Fernandes
@since 28/04/09
@version 1.0

@obs NREMASTER - Dados do Tabela de Servicos
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oCommit    := JA041Commit():New()
Local oStructNRE //Tabela de Servi�os
Local oStructNS5 //Valores dos Servi�os
Local oStructNU1 //Hist�rico da Tabela
Local oStructNTS //Hist�rico dos Valores

oStructNRE := FWFormStruct( 1, "NRE" )
oStructNS5 := FWFormStruct( 1, "NS5" )
oStructNU1 := FWFormStruct( 1, "NU1" )
oStructNTS := FWFormStruct( 1, "NTS" )

//-----------------------------------------
//Monta o modelo do formul�rio
//-----------------------------------------
oModel:= MPFormModel():New( "JURA041", /*Pre-Validacao*/,{ | oX | JA041TUDOK( oX ) }  /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Tabela de Servi�os"
oModel:AddFields( "NREMASTER",           /*cOwner*/, oStructNRE, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid( "NS5DETAIL", "NREMASTER" /*cOwner*/, oStructNS5, /*bLinePre*/,  /*bLinePost*/, /*bPre*/,  /*bPost*/ )
oModel:AddGrid( "NU1DETAIL", "NREMASTER" /*cOwner*/, oStructNU1,  /*bLinePre*/, /*bLinePost*/,  /*bPre*/, /*bPost*/ , { |oGrid| LoadNU1( oGrid ) } )
oModel:AddGrid( "NTSDETAIL", "NU1DETAIL" /*cOwner*/, oStructNTS,  /*bLinePre*/, /*bLinePost*/,  /*bPre*/, /*bPost*/ )

oModel:GetModel( "NREMASTER"  ):SetDescription( STR0009 ) //"Cabecalho da Tabela de Servi�os"
oModel:GetModel( "NS5DETAIL"  ):SetDescription( STR0010 ) //"Detalhes da tabela de Servi�os"
oModel:GetModel( "NU1DETAIL"  ):SetDescription( STR0011 ) //"Hist�rico das Tabelas de Servi�os"
oModel:GetModel( "NTSDETAIL"  ):SetDescription( STR0012 ) //"Hist�rico dos Detalhes da tabela de Servi�os"

oModel:GetModel( "NS5DETAIL" ):SetUniqueLine( { "NS5_CSERV" } )
oModel:GetModel( "NU1DETAIL" ):SetUniqueLine( { "NU1_AMINI" } )
oModel:GetModel( "NTSDETAIL" ):SetUniqueLine( { "NTS_CSERV"  } )

oModel:SetRelation( "NS5DETAIL", { { "NS5_FILIAL", "xFilial('NS5')" } , { "NS5_CTAB", "NRE_COD" } } , NS5->( IndexKey( 1 ) ) )
oModel:SetRelation( "NU1DETAIL", { { "NU1_FILIAL", "xFilial('NU1')" } , { "NU1_CTAB", "NRE_COD" } } , NU1->( IndexKey( 1 ) ) )
oModel:SetRelation( "NTSDETAIL", { { "NTS_FILIAL", "xFilial('NTS')" } , { "NTS_CTAB", "NRE_COD" }, { "NTS_CHIST", "NU1_COD" } } , NTS->( IndexKey( 2 ) ) )

oModel:GetModel( "NU1DETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NTSDETAIL" ):SetDelAllLine( .T. )

oModel:SetOptional( "NU1DETAIL" , .T. )
oModel:SetOptional( "NTSDETAIL" , .T. )

oStructNU1:SetProperty('NU1_CTIPO' , MODEL_FIELD_VALID,  {|| Vazio().Or.(ExistCpo('NRK',M->NU1_CTIPO,1).And.JA041TPSRV('NU1_CTIPO'))} )//Retirar a linha ap�s a vers�o 12.1.8 (foi ajustado no dicionario) Luciano
oStructNRE:SetProperty('NRE_CTIPO' , MODEL_FIELD_VALID,  {|| Vazio().Or.(ExistCpo('NRK',M->NRE_CTIPO,1).And.JA041TPSRV('NRE_CTIPO'))} )

oModel:InstallEvent("JA041Commit", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NREMASTER',, 'NRE' )
JurSetRules( oModel, 'NS5DETAIL',, 'NS5' )
JurSetRules( oModel, 'NU1DETAIL',, 'NU1' )
JurSetRules( oModel, 'NTSDETAIL',, 'NTS' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA041HST
Atualiza os hist�ricos conforme as altera��es nas tabelas de Servi�os

@author David Gon�alves Fernandes
@since 17/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA041HST( oModel )
Local lRet       := .T.
Local oView      := FWViewActive()
Local cMsg       := ''

Local oModelNRE //Tabela de Servi�os
Local oModelNS5 //Valores dos Servi�os
Local oModelNU1 //Hist�rico da Tabela
Local oModelNTS //Hist�rico dos Valores

Local dData      := date()
Local nI         := 0
Local cAnoMes    := "190001"
Local cMaxAnoMes := "190001"
Local cAnoMesINI := ""
Local cAnoMesFim := ""

Local lUsaHist   := SuperGetMV( 'MV_JURHS1',, .F. )  //Habilita a grava��o dos hist�ricos
Local lHstMesAnt := SuperGetMV( 'MV_JURHS2',, .F. )  //Valida a patir do m�s anterior

Local aArea      := GetArea()
Local aAreaNRE   := NRE->( GetArea() )

Local nLinha     := 0
Local nLinhaNS5  := 0
Local nLinhaNU1  := 0
Local nLinhaNTS  := 0
Local lMudou     := .F.
Local nQtdLinNTS := 0

Local npos       := 0

Local nLinNS5Old := 0
Local nLinNU1Old := 0
Local nLinNTSOld := 0

Local cDataFim   := ""

oModelNRE := oModel:GetModel( "NREMASTER" )
oModelNS5 := oModel:GetModel( "NS5DETAIL" )

oModelNU1 := oModel:GetModel( "NU1DETAIL" )
oModelNTS := oModel:GetModel( "NTSDETAIL" )

//Salva as linhas posicionadas para restaur�-las quando atualizar a tela
nLinNS5Old := oModelNS5:nLine
nLinNU1Old := oModelNU1:nLine
nLinNTSOld := oModelNTs:nLine

If !lUsaHist
	dData      := MsDate()  // Ver qual data
	cAnoMesINI := AnoMes(dData)

	//Retorna o Menor Ano-M�s que estiver no Grid de hist�rico
	nQtdLinNU1 := oModelNU1:GetQtdLine()

	For nLinhaNU1 := 1 To nQtdLinNU1
		If !Empty(oModelNU1:GetValue( "NU1_AMINI", nLinhaNU1 )  ) .AND. (oModelNU1:GetValue( "NU1_AMINI", nLinhaNU1 ) < cAnoMesIni)
			cAnoMesIni := oModelNU1:GetValue( "NU1_AMINI", nLinhaNU1 )
			cAnoMesFim := oModelNU1:GetValue( "NU1_AMINI", nLinhaNU1 )
		endIf
	Next nLinhaNU1

Else
	If !lHstMesAnt
		cAnoMesINI := AnoMes(dData)
		cAnoMesFim := AnoMes(MsSomaMes(dData,-1))
	Else
		cAnoMesINI := AnoMes(MsSomaMes(dData,-1))
		cAnoMesFim := AnoMes(MsSomaMes(dData,-2))
	EndIf

EndIf

If lRet
	cMsg := ''
	//VerIfica se a 1� linha (padr�o FW) est� vazia
	If oModelNU1:IsEmpty()
		nLinha := 1
	Else
		//Busca o hist�rico mais recente no grid de hist�rico
		nQtdLinNU1 := oModelNU1:GetQtdLine()

		For nLinhaNU1 := 1 To nQtdLinNU1
			//Se o maior hist�rico j� estiver encerrado antes do per�odo, n�o poder� ajustar o ano-m�s final
			If Empty(oModelNU1:GetValue( "NU1_AMFIM", nLinhaNU1)) .OR. (!Empty(oModelNU1:GetValue("NU1_AMFIM", nLinhaNU1)) .AND. oModelNU1:GetValue("NU1_AMFIM", nLinhaNU1) >= cAnoMesFim )
				If cMaxAnoMes == ''
					cMaxAnoMes := oModelNU1:GetValue("NU1_AMINI", nLinhaNU1)
					If cMaxAnoMes > cAnoMesIni
						cMaxAnoMes := cAnoMesIni
					EndIf
					nLinha := nLinhaNU1
				ElseIf cMaxAnoMes < cAnoMesIni .OR. !lUsaHist //O maior per�odo n�o pode ser maior do que o atual
					If lUsaHist //se usar hist�rico localiza a linha com o maior per�odo.
						If oModelNU1:GetValue("NU1_AMINI", nLinhaNU1) >= cMaxAnoMes
							cMaxAnoMes := oModelNU1:GetValue("NU1_AMINI", nLinhaNU1)
							nLinha := nLinhaNU1
						EndIf
					Else //Sen�o, localiza a linha com o menor per�odo
						If oModelNU1:GetValue("NU1_AMINI", nLinhaNU1) <= cMaxAnoMes
							cMaxAnoMes := cAnoMesIni
							nLinha := nLinhaNU1
						EndIf
					EndIf
				EndIf
			EndIf
		Next nLinhaNU1

	EndIf

	//Se n�o encontrou hist�rico mais recente a alterar, cria a linha de hist�rico
	If nLinha == 0
		oModelNU1:AddLine()
	Else
		//Posiciona na linha do hist�rico que deve ser alterada
		oModelNU1:GoLine(nLinha)
		If cMaxAnoMes = ''
			cAnoMes    := cAnoMesINI
			cMaxAnoMes := cAnoMesINI
		else
			cAnoMes := cMaxAnoMes
		EndIf
		If lUsaHist
			//VerIfica o cadastro mudou em rela��o ao hist�rico (se o hist. n�o est� vazio)
			If (!Empty(oModelNU1:GetValue("NU1_AMINI")) .AND. !Empty(oModelNU1:GetValue("NU1_DTAB")) .AND. !Empty(oModelNU1:GetValue("NU1_CMOEDA")))
				//Tabela de servi�os
				If (oModelNU1:GetValue("NU1_CMOEDA") <> oModelNRE:GetValue("NRE_MOEDA") .OR. ;
						oModelNU1:GetValue("NU1_CTIPO") <> oModelNRE:GetValue("NRE_CTIPO") .OR. ;
						oModelNU1:GetValue("NU1_DTAB") <> oModelNRE:GetValue("NRE_DESC"))
					lMudou := .T.
				ElseIf !Empty(oModelNU1:GetValue( "NU1_AMFIM"))
					lMudou := .T.
				EndIf
				//Valor por servi�o
				If !lMudou .AND. !Empty(oModelNTS:GetValue('NTS_CSERV'))
					nQtdLinNS5 := oModelNS5:GetQtdLine()
					For nLinhaNS5 := 1 to nQtdLinNS5

						If oModelNS5:IsDeleted(nLinhaNS5)
							lMudou := .T.
							Exit
						EndIf

						nPos := 0
						For nI := 1 To oModelNTS:GetQtdLine()
							If !oModelNTS:IsDeleted(nI) .And. !oModelNTS:IsEmpty(nI) .And. ;
									oModelNTS:GetValue('NTS_CSERV',  nI) == oModelNS5:GetValue('NS5_CSERV', nLinhaNS5)  .And. ;
									oModelNTS:GetValue('NTS_VALORH', nI) == oModelNS5:GetValue('NS5_VALORH', nLinhaNS5) .And. ;
									oModelNTS:GetValue('NTS_MAXSER', nI) == oModelNS5:GetValue('NS5_MAXSER', nLinhaNS5) .And. ;
									oModelNTS:GetValue('NTS_ADISER', nI) == oModelNS5:GetValue('NS5_ADISER', nLinhaNS5) .And. ;
									oModelNTS:GetValue('NTS_MOEDAT', nI) == oModelNS5:GetValue('NS5_MOEDAT', nLinhaNS5) .And. ;
									oModelNTS:GetValue('NTS_VALORT', nI) == oModelNS5:GetValue('NS5_VALORT', nLinhaNS5) .And. ;
									oModelNTS:GetValue('NTS_MAXTAX', nI) == oModelNS5:GetValue('NS5_MAXTAX', nLinhaNS5) .And. ;
									oModelNTS:GetValue('NTS_ADITAX', nI) == oModelNS5:GetValue('NS5_ADITAX', nLinhaNS5)
								nPos := nI
								Exit
							EndIf
						Next nI

						If nPos == 0
							lMudou := .T.
							Exit
						EndIf
					Next nLinhaNS5
				EndIf
			EndIf

			//Caso haja dIferen�a, encerra o periodo antigo para incluir o novo em aberto.
			If lMudou .AND. oModelNU1:GetValue( "NU1_AMINI") <> cAnoMesIni
				If !( oModelNU1:SetValue( "NU1_AMFIM" ,  If( oModelNU1:GetValue( "NU1_AMINI") > cAnoMesFim, oModelNU1:GetValue( "NU1_AMINI"), cAnoMesFim ) ) )
					lRet := .F.
					oModelNU1:DeleteLine()
					cMsg := STR0024 //"Erro ao Gravar o hist�rico da Tabela de Servi�os"
				Else
					cAnoMes    := cAnoMesINI
					cMaxAnoMes := cAnoMesIni
					oModelNU1:AddLine()
				EndIf
			EndIf
		EndIf
	EndIf

	If oModelNU1:IsDeleted()
		oModelNU1:UnDeleteLine()
	EndIf

	//Copia os dados do cadastro para o hist�rico
	//Copia para hist�rico - Tabela de Servi�os
	If lRet .AND. ;
			!( oModelNU1:SetValue("NU1_AMINI" , cAnoMes ) .AND. ;
			oModelNU1:SetValue("NU1_AMFIM" , '' )         .AND. ;
			oModelNU1:SetValue("NU1_DTAB" , oModelNRE:GetValue("NRE_DESC") ) .AND. ;
			oModelNU1:LoadValue("NU1_CTIPO" , oModelNRE:GetValue("NRE_CTIPO") ) .AND. ;
			oModelNU1:LoadValue("NU1_CMOEDA", oModelNRE:GetValue("NRE_MOEDA") ) )
		lRet := .F.
		oModelNU1:DeleteLine()
		cMsg := STR0024 //"Erro ao Gravar o hist�rico da tabela de Servi�os"
	EndIf

	//Copia para hist�rico - Valor por servi�o
	If lRet
		nQtdLinNS5 := oModelNS5:GetQtdLine()

		For nLinhaNS5 := 1 to nQtdLinNS5
			oModelNS5:GoLine(nLinhaNS5)
			If !oModelNS5:IsDeleted() .And. !oModelNS5:IsEmpty()
				nPos := 0
				nQtdLinNTS := oModelNTS:GetQtdLine()
				For nI := 1 To nQtdLinNTS
					If !oModelNTS:IsDeleted(nI) .And. !oModelNTS:IsEmpty(nI) .And. ;
							oModelNTS:GetValue('NTS_CSERV', nI) == oModelNS5:GetValue('NS5_CSERV')
						nPos := nI
					EndIf
				Next

				If nPos > 0 .OR. ( nQtdLinNTS == 1 .AND. Empty(oModelNTS:GetValue( "NTS_CSERV")) )
					//Aproveita a 1� linha do FW em branco
					If nPos == 0
						oModelNTS:GoLine(1) // H� apenas uma linha em branco.
					Else
						oModelNTS:GoLine(npos)
					EndIf
				Else
					oModelNTS:AddLine()
				EndIf

				//Se a linha for apagada do registro, exclui do hist�rico.
				If !oModelNS5:isDeleted() .AND. !oModelNTS:isDeleted() .AND. ;
						!( oModelNTS:LoadValue('NTS_CSERV'  , oModelNS5:GetValue('NS5_CSERV'  ) ) .AND. ;
						oModelNTS:SetValue(  'NTS_VALORH' , oModelNS5:GetValue('NS5_VALORH' ) ) .AND. ;
						oModelNTS:SetValue(  'NTS_MAXSER' , oModelNS5:GetValue('NS5_MAXSER' ) ) .AND. ;
						oModelNTS:SetValue(  'NTS_ADISER' , oModelNS5:GetValue('NS5_ADISER' ) ) .AND. ;
						oModelNTS:LoadValue( 'NTS_MOEDAT' , oModelNS5:GetValue('NS5_MOEDAT' ) ) .AND. ;
						oModelNTS:SetValue(  'NTS_VALORT' , oModelNS5:GetValue('NS5_VALORT' ) ) .AND. ;
						oModelNTS:SetValue(  'NTS_MAXTAX' , oModelNS5:GetValue('NS5_MAXTAX' ) ) .AND. ;
						oModelNTS:SetValue(  'NTS_ADITAX' , oModelNS5:GetValue('NS5_ADITAX' ) ) )
					lRet := .F.
					oModelNTS:DeleteLine()
					cMsg := STR0019 //"Erro ao Gravar o hist�rico do valor por servi�o"
				ElseIf oModelNS5:isDeleted()
					oModelNTS:DeleteLine()
				ElseIf oModelNTS:isDeleted()
					oModelNTS:UnDeleteLine()
				EndIf
			EndIf
		Next

	EndIf

	//Remove inconsist�ncias
	If lRet
		nQtdLinNU1 := oModelNU1:GetQtdLine()
		For nLinhaNU1 := 1 to nQtdLinNU1
			oModelNU1:GoLine( nLinhaNU1 )
			cDataFim := oModelNU1:GetValue('NU1_AMFIM')

			//Exclui do hist�rico atual o valor por servi�o que n�o est� no cadastro
			nQdtLinNTS := oModelNTS:GetQtdLine()
			For nLinhaNTS := 1 to nQdtLinNTS
				oModelNTS:GoLine(nLinhaNTS)

				nPos := 0
				For nI := 1 To oModelNS5:GetQtdLine()
					If !oModelNS5:IsDeleted(nI) .And. !oModelNS5:IsEmpty(nI) .And. ;
							oModelNTS:GetValue('NTS_CSERV')  == oModelNS5:GetValue('NS5_CSERV',   nI)  .And. ;
							oModelNTS:GetValue('NTS_VALORH') == oModelNS5:GetValue('NS5_VALORH',  nI) .And. ;
							oModelNTS:GetValue('NTS_MAXSER') == oModelNS5:GetValue('NS5_MAXSER',  nI) .And. ;
							oModelNTS:GetValue('NTS_ADISER') == oModelNS5:GetValue('NS5_ADISER',  nI) .And. ;
							oModelNTS:GetValue('NTS_MOEDAT') == oModelNS5:GetValue('NS5_MOEDAT',  nI) .And. ;
							oModelNTS:GetValue('NTS_VALORT') == oModelNS5:GetValue('NS5_VALORT',  nI) .And. ;
							oModelNTS:GetValue('NTS_MAXTAX') == oModelNS5:GetValue('NS5_MAXTAX',  nI) .And. ;
							oModelNTS:GetValue('NTS_ADITAX') == oModelNS5:GetValue('NS5_ADITAX',  nI)
						nPos := nI
					EndIf
				Next

				If (nPos == 0) .And. Empty(cDataFim)
					oModelNTS:DeleteLine()
				EndIf

			Next

		Next

		nQtdLinNU1 := oModelNU1:GetQtdLine()
		//Exclui os hist�ricos futudos
		For nLinhaNU1 := 1 To nQtdLinNU1
			oModelNU1:GoLine( nLinhaNU1 )
			If ( oModelNU1:GetValue( "NU1_AMINI" ) > cAnoMesIni ) .OR. ;
					(!Empty(oModelNU1:GetValue( "NU1_AMFIM" )) .AND. oModelNU1:GetValue( "NU1_AMFIM" )  > cAnoMesFim)
				oModelNU1:DeleteLine()
			EndIf
		Next

	EndIf

EndIf

RestArea( aAreaNRE )
RestArea( aArea )

//Restaura as linhas posicionadas para n�o perder as fere�ncias em tela
oModelNS5:GoLine(nLinNS5Old)
oModelNTS:GoLine(nLinNTSOld)
oModelNU1:GoLine(nLinNU1Old)

If !Empty(oView) .And. oView:lActivate
	oView:Refresh()
EndIf

If !lRet
	JurMsgErro(cMsg)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadNU1
Faz a carga dos dados da grid do NU1 e ordena decrescente

@author Ernani Forastieri
@since 29/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadNU1( oGrid )
Local nOperacao := oGrid:GetModel():GetOperation()
Local aStruct   := oGrid:oFormModelStruct:GetFields()
Local nAt       := 0
Local aRet      := {}

If nOperacao <> OP_INCLUIR

	aRet := FormLoadGrid( oGrid )

	// Ordena decrescente pelo Ano/Mes
	If ( nAt := aScan( aStruct, { |aX| aX[MODEL_FIELD_IDFIELD] == 'NU1_AMINI' } ) ) > 0
		aSort( aRet,,, { |aX,aY| aX[2][nAt] > aY[2][nAt] } )
	EndIf

EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA041NRD
Valida se o tipo da tabela do servi�o da tabela NS5 est� de acordo com
o tipo de servi�o da tabela de servi�os

@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o

@author David Gon�alves Fernandes
@since 29/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA041NRD()
Local lRet      := .F.
Local aArea     := GetArea()
Local aAreaNRE  := NRE->( GetArea() )
Local aAreaNRD  := NRD->( GetArea() )
Local oModel    := FWModelActive()
Local oModelNS5 := oModel:GetModel( "NS5DETAIL")

If !Empty(oModelNS5:GetValue('NS5_CSERV'))

	NRD->( dbSetOrder( 1 ) )
	If NRD->( dbSeek( xFilial( 'NS5' ) + oModelNS5:GetValue('NS5_CSERV') ) )

		If (NRE->NRE_CTIPO == NRD->NRD_CTIPO)
			lRet := .T.
		EndIf

		If !lRet
			JurMsgErro( STR0017 ) //"O servi�o n�o est� configurado para este tipo de tabela"
			lRet := .F.
		EndIf
	EndIf

Else
	lRet := .T.
EndIf

RestArea( aAreaNRE )
RestArea( aAreaNRD )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA041VALID
Valida se o tipo dos servi�os est�o de acordo com
o tipo de servi�o da tabela de servi�os

@Return  lRet   .T./.F. As informa��es s�o v�lidas ou n�o

@author David Gon�alves Fernandes
@since 29/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA041VALID(cCampo)
Local lRet        := .T.
Local lMsg        := .T. //Define se esta fun��o deve mostrar msg ou n�o, pois s�o usadas fun��es que demonstram, tal como JVldAnoMes
Local aArea       := GetArea()
Local aAreaNRE    := NRE->( GetArea() )
Local aAreaNRD    := NRD->( GetArea() )
Local oModel      := FWModelActive()
Local oModelNRE   := Nil
Local oModelNS5   := Nil
Local oModelNU1   := Nil
Local oModelNTS   := Nil
Local cValorOrdem := ''
Local cValorComp  := ''
Local cTable      := ''
Local cMsg        := ''

If cCampo == 'NS5_CSERV'
	oModelNS5   := oModel:GetModel( "NS5DETAIL")
	oModelNRE   := oModel:GetModel( "NREMASTER")
	cValorOrdem := oModelNS5:GetValue('NS5_CSERV')
	cValorComp  := oModelNRE:GetValue("NRE_CTIPO")
	cTable      := 'NS5'
ElseIf cCampo == 'NTS_CSERV'
	oModelNU1   := oModel:GetModel( "NU1DETAIL" )
	oModelNTS   := oModel:GetModel( "NTSDETAIL" )
	cValorOrdem := oModelNTS:GetValue('NTS_CSERV')
	cValorComp  := oModelNU1:GetValue('NU1_CTIPO')
	cTable      := 'NTS'
EndIf

If !Empty(cValorOrdem) .AND. !Empty(cValorComp)

	NRD->( dbSetOrder( 1 ) )
	If NRD->( dbSeek( xFilial( cTable ) + cValorOrdem ) )

		If !( cValorComp == NRD->NRD_CTIPO)
			lRet := .F.
			cMsg := STR0017 //"O servi�o n�o est� configurado para este tipo de tabela"
		EndIf
	EndIf
EndIf

If lRet .And. ( cCampo == 'NU1_AMINI' .OR. cCampo == 'NU1_AMFIM' )

	oModelNU1   := oModel:GetModel( "NU1DETAIL" )
	If !Empty(oModelNU1:GetValue('NU1_AMINI'))
		lRet := JVldAnoMes(oModelNU1:GetValue('NU1_AMINI'))
		lMsg := .F.
	EndIf

	If lRet .And. !Empty(oModelNU1:GetValue('NU1_AMFIM'))
		lRet := JVldAnoMes(oModelNU1:GetValue('NU1_AMFIM'))
		lMsg := .F.
	EndIf


	If lRet .And. !Empty(oModelNU1:GetValue('NU1_AMFIM')) .AND. !Empty(oModelNU1:GetValue('NU1_AMINI'))
		lRet := ( oModelNU1:GetValue('NU1_AMINI') <= oModelNU1:GetValue('NU1_AMFIM') )
		cMsg := STR0019//"O ano-m�s final deve ser maior do que o inicial"
	EndIf
EndIf

If !lRet .And. lMsg
	JurMsgErro( cMsg ) //"O servi�o n�o est� configurado para este tipo de tabela"
EndIf

If lRet .And. (cCampo == 'NS5_CSERV' .Or. cCampo == 'NTS_CSERV')
	If JurGetDados('NRD', 1, xFilial('NRD') + cValorOrdem, 'NRD_ATIVO') == '2'
		JurMsgErro(STR0026, , I18N(STR0031, {cValorOrdem}) ) //"O c�digo do servi�o tabelado esta inativo."
		lRet := .F.
	EndIf
EndIf

RestArea( aAreaNRE )
RestArea( aAreaNRD )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA041TUDOK
Valida se as Regras das Structs est�o OK
Cria os hist�ricos do cadastro
(campos obrigat�rios)

@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o

@author David Gon�alves Fernandes
@since 29/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA041TUDOK(oModel)
Local lRet      := .T.
Local oModelNRE := Nil //Tabela de Servi�os
Local oModelNS5 := Nil //Valores dos Servi�os
Local oModelNU1 := Nil //Hist�rico da Tabela
Local oModelNTS := Nil //Hist�rico dos Valores
Local aArea     := GetArea()
Local aAreaNRE  := NRE->( GetArea() )
Local nQtdNS5   := 0
Local nQtdNTS   := 0
Local nQtdNU1   := 0
Local nSavNU1   := 0
Local nI        := 0
Local nJ        := 0
Local cMsg      := ''
Local cSolucao  := ''
Local cSoluca1  := ''

If oModel:GetOperation() == 3 .OR. oModel:GetOperation() == 4

	oModelNRE := oModel:GetModel( "NREMASTER" )
	oModelNS5 := oModel:GetModel( "NS5DETAIL" )
	oModelNU1 := oModel:GetModel( "NU1DETAIL" )
	oModelNTS := oModel:GetModel( "NTSDETAIL" )

	If lRet
		lRet := JA041TPSRV('NRE_CTIPO', .T. )  //Valida se os campos do cabe�alho da tabela de servi�os
		lRet := lRet .And. JA041TPSRV('NRE_CTIPO', .T. )
		lRet := lRet .And. JA041TPSRV('NRE_MOEDA', .T. )
		lRet := lRet .And. JA041TPSRV('NRE_DESC', .T. )
	EndIf

	If lRet // Valida��es do Chamado THLAH6
		nQtdNS5 := oModelNS5:GetQtdLine()

		For nI := 1 to nQtdNS5

			If !oModelNS5:IsDeleted(nI)

				//Valida os campos obrigat�rios do cadastro do servi�os
				If lRet .And. Empty(oModelNS5:GetValue( "NS5_CSERV", nI ) )
					cMsg :=  STR0027 +"'"+ Alltrim(RetTitle("NS5_CSERV")) +"'"+ STR0028 + STR0013 +"." // "Deve ser preenchido o campo Moeda Taxa da Aba Tab. Servi�os"
					lRet := .F.
				EndIf

				//Valida��o de servi�os tabelados inativos.
				If lRet .And. (JurGetDados('NRD', 1, xFilial('NRD') + oModelNS5:GetValue( "NS5_CSERV", nI ), 'NRD_ATIVO') == '2')
					cMsg :=  STR0026 //"O c�digo do servi�o tabelado est� inativo."
					cSoluca1 :=  I18N(STR0031, {oModelNS5:GetValue( "NS5_CSERV", nI )} )  //"Remova o registro da tabela ou ative o c�digo de servi�o tabelado '#1'."
					lRet := .F.
				EndIf

				If Empty(oModelNS5:GetValue( "NS5_VALORH", nI ))
					cMsg := STR0027 +"'"+ Alltrim(RetTitle("NS5_VALORH")) +"'"+ STR0028 + STR0013+"." // "Deve ser preenchido o campo Valor Honor da Aba Tab. Servi�os"
					lRet := .F.
				EndIf

				If lRet .And. !Empty(oModelNS5:GetValue( "NS5_MAXSER", nI )) .And. Empty(oModelNS5:GetValue( "NS5_ADISER", nI ))
					cMsg := STR0027 +"'"+ Alltrim(RetTitle("NS5_ADISER")) +"'"+ STR0028 + STR0013+"." // "Deve ser preenchido o campo Vl Adic Serv da Aba Tab. Servi�os"
					cSoluca1 := I18N(STR0035, {Alltrim(RetTitle("NS5_ADISER")), Alltrim(RetTitle("NS5_MAXSER")) } ) //"Informe o campo #1 ou remova o conte�do do campo #2."
					lRet := .F.
				EndIf

				If lRet .And. Empty(oModelNS5:GetValue( "NS5_MAXSER", nI )) .And. !Empty(oModelNS5:GetValue( "NS5_ADISER", nI ))
					cMsg := STR0027 +"'"+ Alltrim(RetTitle("NS5_MAXSER")) +"'"+ STR0028 + STR0013+"." // "Deve ser preenchido o campo Qtd M�x Serv da Aba Tab. Servi�os"
					cSoluca1 := I18N(STR0035, {Alltrim(RetTitle("NS5_MAXSER")), Alltrim(RetTitle("NS5_ADISER"))} ) //"Informe o campo #1 ou remova o conte�do do campo #2."
					lRet := .F.
				EndIf

				If lRet .And. !Empty(oModelNS5:GetValue( "NS5_MAXTAX", nI )) .And. Empty(oModelNS5:GetValue( "NS5_ADITAX", nI ))
					cMsg := STR0027 +"'"+ Alltrim(RetTitle("NS5_ADITAX")) +"'"+ STR0028 + STR0013+"." // "Deve ser preenchido o campo Vl Adic Taxa da Aba Tab. Servi�os"
					cSoluca1 := I18N(STR0035, {Alltrim(RetTitle("NS5_ADITAX")), Alltrim(RetTitle("NS5_MAXTAX"))} ) //"Informe o campo #1 ou remova o conte�do do campo #2."
					lRet := .F.
				EndIf

				If lRet .And. Empty(oModelNS5:GetValue( "NS5_MAXTAX", nI )) .And. !Empty(oModelNS5:GetValue( "NS5_ADITAX", nI ))
					cMsg := STR0027 +"'"+ Alltrim(RetTitle("NS5_MAXTAX")) +"'"+ STR0028 + STR0013+"." // "Deve ser preenchido o campo Qtd M�x Taxa da Aba Tab. Servi�os"
					cSoluca1 := I18N(STR0035, {Alltrim(RetTitle("NS5_MAXTAX")), Alltrim(RetTitle("NS5_ADITAX"))} ) //"Informe o campo #1 ou remova o conte�do do campo #2."
					lRet := .F.
				EndIf

				If lRet .And. !Empty(oModelNS5:GetValue( "NS5_MAXTAX", nI )) .And. !Empty(oModelNS5:GetValue( "NS5_ADITAX", nI )) .And. Empty(oModelNS5:GetValue( "NS5_VALORT", nI ))
					cMsg := STR0027 +"'"+ Alltrim(RetTitle("NS5_VALORT")) + STR0028 + STR0013+"." // "Deve ser preenchido o campo Valor Taxa da Aba Tab. Servi�os"
					cSoluca1 := I18N(STR0036, {Alltrim(RetTitle("NS5_VALORT")), Alltrim(RetTitle("NS5_ADITAX")), Alltrim(RetTitle("NS5_MAXTAX"))} ) //"Informe o campo #1 ou remova o conte�do dos campos #2 e #3."
					lRet := .F.
				EndIf

				If lRet .And. !Empty(oModelNS5:GetValue( "NS5_VALORT", nI )) .And. Empty(oModelNS5:GetValue( "NS5_MOEDAT", nI ))
					cMsg :=  STR0027 +"'"+ Alltrim(RetTitle("NS5_MOEDAT")) +"'"+ STR0028 + STR0013+"." // "Deve ser preenchido o campo Moeda Taxa da Aba Tab. Servi�os"
					cSoluca1 := I18N(STR0035, {Alltrim(RetTitle("NS5_MOEDAT")), Alltrim(RetTitle("NS5_VALORT"))} ) //"Informe o campo #1 ou apague o conte�do do campo #2."
					lRet := .F.
				EndIf

				If !lRet
					cSolucao := I18N(STR0034, {AllToChar(nI)} ) //"Verifique o registro na linha #1."
					JurMsgErro(cMsg, oModelNS5:GetDescription(), Iif(!Empty(cSoluca1), cSoluca1+ " "+ cSolucao, cSolucao) )
					Exit
				EndIf

			EndIf

		Next nI

		If lRet  //Valida lacunas de per�odo no Hist�rico
			lRet :=  JURPerHist(oModelNU1, .T.)
		EndIf

		If lRet  //Grava e valida o hist�rico
			lRet :=  JA041HST( oModel )
		EndIf

		If lRet
			nQtdNU1 := oModelNU1:GetQtdLine()
			nSavNU1 := oModelNU1:GetLine()

			For nJ := 1 to nQtdNU1

				If !oModelNU1:IsDeleted(nJ)
					oModelNU1:GoLine(nJ)

					lRet := lRet .And. JA041TPSRV('NU1_CTIPO', .T.) //Valida se os tipos da tabela correspondem aos tipos dos servi�os
					lRet := lRet .And. JA041TPSRV('NU1_DTAB', .T.)
					lRet := lRet .And. JA041TPSRV('NU1_CMOEDA', .T.)

					If (lRet := lRet .And. JA041GRDOK(oModelNU1))

						nQtdNTS := oModelNTS:GetQtdLine()

						For nI :=  1 to nQtdNTS

							If !oModelNTS:IsDeleted(nI)

								//Valida os campos obrigat�rios do cadastro do servi�os
								If lRet .And. Empty(oModelNTS:GetValue("NTS_CSERV", nI ) )
									cMsg :=  STR0027 +"'"+ Alltrim(RetTitle("NTS_CSERV")) +"'"+ STR0028 + STR0014+"." // "Deve ser preenchido o campo Moeda Taxa da Aba Tab. Servi�os"
									lRet := .F.
								EndIf

								If Empty(oModelNTS:GetValue( "NTS_VALORH", nI ))
									cMsg := STR0027 +"'"+ Alltrim(RetTitle("NTS_VALORH")) +"'"+ STR0028 + STR0014+"." // "Deve ser preenchido o campo Valor Honor da Aba Hist�rico"
									lRet := .F.
								EndIf

								If lRet .And. !Empty(oModelNTS:GetValue( "NTS_MAXSER", nI )) .And. Empty(oModelNTS:GetValue( "NTS_ADISER", nI ))
									cMsg := STR0027 +"'"+ Alltrim(RetTitle("NTS_ADISER")) +"'"+ STR0028 + STR0014+"." // "Deve ser preenchido o campo Vl Adic Serv da Aba Hist�rico"
									cSoluca1 := I18N(STR0035, {Alltrim(RetTitle("NTS_ADISER")), Alltrim(RetTitle("NTS_MAXSER"))} ) //"Informe o campo #1 ou remova o conte�do do campo #2."
									lRet := .F.
								EndIf

								If lRet .And. Empty(oModelNTS:GetValue( "NTS_MAXSER", nI )) .And. !Empty(oModelNTS:GetValue( "NTS_ADISER", nI ))
									cMsg := STR0027 +"'"+ Alltrim(RetTitle("NTS_MAXSER")) +"'"+ STR0028 + STR0014+"." // "Deve ser preenchido o campo Qtd M�x Serv da Aba Hist�rico"
									cSoluca1 := I18N(STR0035, {Alltrim(RetTitle("NTS_MAXSER")), Alltrim(RetTitle("NTS_ADISER"))} ) //"Informe o campo #1 ou remova o conte�do do campo #2."
									lRet := .F.
								EndIf

								If lRet .And. !Empty(oModelNTS:GetValue( "NTS_MAXTAX", nI )) .And. Empty(oModelNTS:GetValue( "NTS_ADITAX", nI ))
									cMsg := STR0027 +"'"+ Alltrim(RetTitle("NTS_ADITAX")) +"'"+ STR0028 + STR0014+"." // "Deve ser preenchido o campo Vl Adic Taxa da Aba Hist�rico"
									cSoluca1 := I18N(STR0035, {Alltrim(RetTitle("NTS_ADITAX")), Alltrim(RetTitle("NTS_MAXTAX"))} ) //"Informe o campo #1 ou remova o conte�do do campo #2."
									lRet := .F.
								EndIf

								If lRet .And. Empty(oModelNTS:GetValue( "NTS_MAXTAX", nI )) .And. !Empty(oModelNTS:GetValue( "NTS_ADITAX", nI ))
									cMsg := STR0027 +"'"+ Alltrim(RetTitle("NTS_MAXTAX")) +"'"+ STR0028 + STR0014+"." // "Deve ser preenchido o campo Qtd M�x Taxa da Aba Hist�rico"
									cSoluca1 := I18N(STR0035, {Alltrim(RetTitle("NTS_MAXTAX")), Alltrim(RetTitle("NTS_ADITAX"))} ) //"Informe o campo #1 ou remova o conte�do do campo #2."
									lRet := .F.
								EndIf

								If lRet .And. !Empty(oModelNTS:GetValue( "NTS_MAXTAX", nI )) .And. !Empty(oModelNTS:GetValue( "NTS_ADITAX", nI )) .And. Empty(oModelNTS:GetValue( "NTS_VALORT", nI ))
									cMsg :=  STR0027 +"'"+ Alltrim(RetTitle("NTS_VALORT")) +"'"+ STR0028 + STR0014+"." // "Deve ser preenchido o campo Valor Taxa da Aba Hist�rico"
									cSoluca1 := I18N(STR0036, {Alltrim(RetTitle("NTS_VALORT")), Alltrim(RetTitle("NTS_MAXTAX")), Alltrim(RetTitle("NTS_ADITAX"))} ) //"Informe o campo #1 ou remova o conte�do dos campos #2 e #3."
									lRet := .F.
								EndIf

								If lRet .And. !Empty(oModelNTS:GetValue( "NTS_VALORT", nI )) .And. Empty(oModelNTS:GetValue( "NTS_MOEDAT", nI ))
									cMsg :=  STR0027 +"'"+ Alltrim(RetTitle("NTS_MOEDAT")) +"'"+ STR0028 + STR0014+"." // "Deve ser preenchido o campo Moeda Taxa da Aba Hist�rico"
									cSoluca1 := I18N(STR0035, {Alltrim(RetTitle("NTS_MOEDAT")), Alltrim(RetTitle("NTS_VALORT"))} ) //"Informe o campo #1 ou remova o conte�do do campo #2."
									lRet := .F.
								EndIf

								If !lRet
									cSolucao := I18N(STR0038, {Transform(oModelNU1:GetValue('NU1_AMINI'),'@R 9999-99'), Transform(oModelNU1:GetValue('NU1_AMFIM'),'@R 9999-99'), oModelNU1:GetDescription(), AllToChar(nI)}  ) //"Verifique o registro da linha #1 no periodo de '#1' � '#2' do #3."
									JurMsgErro(cMsg, oModelNS5:GetDescription(), Iif(!Empty(cSoluca1), cSoluca1+ " "+ cSolucao, cSolucao) )
									Exit
								EndIf

							EndIf

						Next nI

					Else
						Exit
					EndIf
				EndIf

			Next nJ

			oModelNU1:GoLine(nSavNU1)

		EndIf
	EndIf

EndIf
RestArea( aAreaNRE )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA041GRDOK
Valida se as Regras das Structs est�o OK
(campos obrigat�rios)
Structs:
	"NREMASTER" - Tab. de Servi�os
	"NS52NIVEL" - Valor para os Servi�os
	"NU1DETAIL" - Hist. Tab. de Servi�os
	"NTSDETAIL" - Hist. Valor para os Servi�os
@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o

@author David Gon�alves Fernandes
@since 29/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA041GRDOK( oGrid )
Local lRet       := .T.
Local cStruct    := ''
Local nOperation := oGrid:GetModel():GetOperation()
Local oStructNU1 := Nil
Local oStructNTS := Nil
Local nposBranco := Nil
Local cMsg       := ''
Local cSolucao   := ''
Local aColsOrd   := {}
Local nLinha     := 0
Local nI         := 0
Local nPosSobre  := 0
Local nPosAMIni  := 1
Local nPosAMFim  := 2

If nOperation == 3 .OR. nOperation == 4 //Inclus�o (3) ou Altera��o (4)

	cStruct := oGrid:GetID()

	//Hist�rico da Tab. de Servi�os
	If cStruct == "NU1DETAIL"
		oStructNU1 := oGrid:GetModel():GetModel( "NU1DETAIL" )
		nLinha := oStructNU1:nLine

		For nI := 1 to oGrid:GetQtdLine()
			If !oGrid:IsDeleted(nI) .And. !oGrid:IsEmpty(nI)
				aAdd(aColsOrd, {oGrid:GetValue("NU1_AMINI",nI), oGrid:GetValue("NU1_AMFIM",nI), nI})
			EndIf
		Next

		//N�o permitir hist�ricos Futuros
		If oStructNU1:GetValue('NU1_AMINI') > AnoMes(MsDate())
			cMsg     := STR0020 +" "+AllTrim(Transform(oStructNU1:GetValue('NU1_AMINI'),'@R 9999-99'))+"."    // "N�o � permitido gravar hist�rico para o Ano-m�s"
			cSolucao := STR0032 //"VerIfique as configura��es do m�s de encerramento conforme o paramentro MV_JURHS2."
			lRet     := .F.
		EndIf

		If lRet .AND. !Empty(oStructNU1:GetValue('NU1_AMFIM')) .AND. oStructNU1:GetValue('NU1_AMFIM') > AnoMes(MsDate())
			cMsg     := STR0020 +" "+AllTrim(Transform(oStructNU1:GetValue('NU1_AMINI'),'@R 9999-99'))+"."    // "N�o � permitido gravar hist�rico para o Ano-m�s"
			cSolucao := STR0032 //"VerIfique as configura��es do m�s de encerramento conforme o paramentro MV_JURHS2."
			lRet     := .F.
		EndIf

		//N�o permitir inclus�o de mais de 1 hist com ano-m�s final em branco para o mesmo participante e mesma tabela
		If lRet
			If lRet .AND. Empty(oStructNU1:GetValue("NU1_AMFIM"))

				nposBranco := aScan(aColsOrd, {|x| !oStructNU1:IsDeleted(x[3]) .And. Empty( x[ nPosAMFim ]  ) .AND. ;
					x[ nPosAMIni ] <> oStructNU1:GetValue("NU1_AMINI") }  )

				If nposBranco > 0
					cMsg := STR0033 //O Ano-M�s fim do hist�rico n�o foi preenchido.
					cSolucao := STR0022 // "� preciso preencher o ano-n�s final deste hist�rico"
					lRet := .F.
				EndIf

			EndIf
			//N�o permitir per�odos sobrepostos
			// Ordena os dados em uma copia, para nao prejudicar a referencia do aCols
			aSort( aColsOrd,,, { |aX,aY| aX[nPosAmIni] > aY[nPosAmIni] } )

			//VerIfica se o ano-m�s inicial � menor ou igual a algum ano-m�s final de per�odo anterior
			If nPosSobre == 0 .AND. !Empty(oStructNU1:GetValue("NU1_AMFIM"))
				nposSobre := ascan(aColsOrd, {|x| !oStructNU1:IsDeleted() .And. ;
					x[ nPosAMIni ] < oStructNU1:GetValue("NU1_AMINI") .AND. ; //per�odos anteriores
				x[ nPosAMFim ]  >= oStructNU1:GetValue("NU1_AMINI") .AND.  ;
					x[ nPosAMIni ] <> x[ nPosAMFim ] }  )
			EndIf
			//VerIfica se o ano-m�s final � maior ou igual a algum ano-m�s inicial de per�odo posterior
			If nPosSobre == 0 .AND. !Empty(oStructNU1:GetValue("NU1_AMFIM"))
				nposSobre := ascan(aColsOrd, {|x| !oStructNU1:IsDeleted() .And. ;
					x[ nPosAMIni ]   > oStructNU1:GetValue("NU1_AMINI") .AND. ; //per�odos posteriores
				x[ nPosAMIni ]  <= oStructNU1:GetValue("NU1_AMFIM") .AND.  ;
					x[ nPosAMIni ] <> x[ nPosAMFim ] }  )
			EndIf
			//VerIfica se o ano-m�s inicial do per�odo aberto � menor ou igual a algum ano-m�s final
			If nPosSobre == 0 .AND. Empty(oStructNU1:GetValue("NU1_AMFIM"))
				nposSobre := ascan(aColsOrd, {|x| !oStructNU1:IsDeleted() .And. ;
					x[ nPosAMFim ] >= oStructNU1:GetValue("NU1_AMINI") .AND.   ; //Per�odos fechados
				!Empty( x[ nPosAMFim ] ) }  )
			EndIf
			//VerIfica se o ano-m�s inicial � maior que algum ano-m�s inicial em aberto
			If nPosSobre == 0 .AND. !Empty(oStructNU1:GetValue("NU1_AMFIM"))
				nposSobre := ascan(aColsOrd, {|x| !oStructNU1:IsDeleted() .And. ;
					x[ nPosAMIni ] <= oStructNU1:GetValue("NU1_AMINI") .AND.   ; //Per�odo aberto
				Empty( x[ nPosAMFim ] ) }  )
			EndIf

			If nposSobre > 0
				lRet := .F.
				cMsg := STR0021 //"Per�odos sobrepostos no hist�rico."
				cSolucao := I18N(STR0034, {AlltoChar(aColsOrd[nposSobre][3])})  //"VerIfique o hist�rico da linha #1."
			EndIf

			oStructNU1:GoLine(nLinha)

		EndIf

		If !lRet
			JurMsgErro(cMsg, ,cSolucao)
		EndIf
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURNRDFIXB()
Funcao para efetuar o filtro na consulta padr�o NRD - Srvi�os tabelados

@Sample
// Filstro da consulta padr�o NRD2
	// NRD->NRD_CTIPO==@#JURNRDFIXB()
//
@author Ernani Forastieri
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNRDFIXB()
Local oModel := FwModelActive()
Local cCampo := AllTrim( ReadVar() )
Local cRet   := Criavar( 'NRE_CTIPO', .F. )

If oModel:GetId() == 'JURA041'

	If cCampo == 'M->NS5_CSERV'
		cRet := FwFldGet( 'NRE_CTIPO' )

	ElseIf cCampo == 'M->NTS_CSERV'
		cRet :=  FwFldGet( 'NU1_CTIPO' )

	EndIf

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA041CHAV
Fun��o para valida��o das chaves dos registors

@author David Gon�alves Fernandes
@since 23/11/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA041CHAV(cAlias)
Local lRet := .T.

If cAlias == 'NRE' //Tab Servi�os
	lRet := ExistChav('NRE', FWFldGet('NRE_COD') )
ElseIf cAlias == 'NS5' //Valor por servi�o
	lRet := ExistChav('NS5', FWFldGet('NRE_COD') + FWFldGet('NS5_CSERV') )

ElseIf cAlias == 'NU1' //Hist. da Tab. Servi�os
	lRet := ExistChav('NU1', FWFldGet('NRE_COD') + FWFldGet('NU1_COD') )
ElseIf cAlias == 'NTS' //Hist. do valor por servi�o
	lRet := ExistChav('NTS',  FWFldGet('NRE_COD') + FWFldGet('NU1_COD') +  FWFldGet('NTS_COD') )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA041TPSRV()
Valida se o tipo da tabela � igual ao tipo dos servi�os

@author David Gon�alves Fernandes
@since 24/11/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA041TPSRV(cCampo, lIsEmpty)
Local lRet     := .T.
Local oModel   := FwModelActive()
Local aArea    := GetArea()
Local aAreaNRD := NRD->( GetArea() )
Local oModel1  := Nil
Local oModel2  := Nil
Local nI       := 0
Local cTabela  := ''
Local cMsg     := ''
Local cSolucao := ''
Local lIsVldOk := IsInCallStack("JA041TUDOK")
Local cDescrip := ''

Default lIsEmpty := .F.

If Substr(cCampo,1,3) == 'NRE'
	oModel1 := oModel:GetModel('NREMASTER')
	oModel2 := oModel:GetModel('NS5DETAIL')
	cTabela := 'NS5'
ElseIf Substr(cCampo,1,3) == 'NU1'
	oModel1 := oModel:GetModel('NU1DETAIL')
	oModel2 := oModel:GetModel('NTSDETAIL')
	cTabela := 'NTS'
EndIf

If lIsEmpty .And. Empty(oModel1:GetValue(cCampo))
	If oModel1:GetId() == 'NU1DETAIL' .and. !oModel1:IsDeleted() // O 'NREMASTER' n�o tem metodo Isdeleted por ser Field
		cSolucao := I18N(STR0034, {AllToChar(oModel1:GetLine())} ) //"Verifique o registro na linha #1."
	Else
		cSolucao := I18N(STR0037, {Alltrim(RetTitle(cCampo))} ) //"Informe o campo '#1' antes de confirmar."
	EndIf
	cMsg := STR0027 + "'" + Alltrim(RetTitle(cCampo)) + "'" + STR0028 + Iif(oModel1:GetId() == 'NU1DETAIL', STR0014, STR0013) + "." // "Deve ser preenchido o campo "
	cDescrip := Iif(lIsVldOk, oModel1:GetDescription(), '')
	lRet := .F.
EndIf

If lRet .And. cCampo $ 'NRE_CTIPO|NU1_CTIPO'
	For nI := 1 To oModel2:GetQtdLine()
		If !oModel2:IsDeleted(nI) .And. !Empty(oModel2:GetValue(cTabela+'_CSERV', nI) )
			NRD->( dbSetOrder(1) )
			If NRD->(dbSeek(xFilial('NRD')+oModel2:GetValue(cTabela+'_CSERV', nI) ) )
				If (oModel1:GetValue(cCampo) != NRD->NRD_CTIPO)
					cMsg := STR0029 + oModel2:GetValue(cTabela+'_CSERV', nI) //"O tipo da tabela est� dIferente do tipo do servi�o: "
					lRet := .F.
					cDescrip := Iif(lIsVldOk, oModel2:GetDescription(), '')
					cSolucao := I18N(STR0034, {AllToChar(nI)} ) //"Verifique o registro na linha #1."
					Exit
				EndIf
			Else
				cMsg := STR0030 + oModel2:GetValue(cTabela+'_CSERV', nI) //"C�digo de servi�o tabelado inv�lido: "
				lRet := .F.
				cDescrip := Iif(lIsVldOk, oModel2:GetDescription(), '')
				cSolucao := I18N(STR0034, {AllToChar(nI)} ) //"Verifique o registro na linha #1."
				Exit
			EndIf

		EndIf

	Next nI

EndIf

If !lRet
	JurMsgErro(cMsg, cDescrip, cSolucao)
EndIf

RestArea( aAreaNRD )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA041COMMIT
Classe interna implementando o FWModelEvent, para execu��o de fun��o 
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA041COMMIT FROM FWModelEvent
    Method New()
    Method InTTS()
End Class

Method New() Class JA041COMMIT
Return

Method InTTS(oSubModel, cModelId) Class JA041COMMIT
	JFILASINC(oSubModel:GetModel(), "NRE", "NREMASTER", "NRE_COD")
Return
