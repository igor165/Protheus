#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE  "FISA080.CH"

/***************************************************************************************************************************************************************
																		ATENCAO !!
As funcoes XUFCheckSX() e XUFSetAbas() foram criadas com o intuito de controlar o dicionario de campos da tabela CFC e, a partir disso, manipular o formato
de utilizacao da rotina. Por exemplo permitir ou nao acesso a rotina e manipular as Abas e Folders criados na tela do cadastro.
Devido a esse controle, a ViewDef condiciona a criacao de Folders e Sheets a partir do resultado dessas funcoes.

								Sempre que for criado um novo campo, devera ser incluido no controle dessas funcoes!!!!!

A partir da virada de versao da P11 para P12, este controle nao sera mais necessario, e a rotina podera ter um unico tratamento para montar a tela de cadastro.

***************************************************************************************************************************************************************/

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA080

@author Erick G. Dias
@since 26/09/2013
@version 11.90

/*/
//-------------------------------------------------------------------
Function FISA080

Local	oBrw	:= FWmBrowse():New()

AjuCMP()

oBrw:SetDescription(STR0001)
oBrw:SetAlias( 'CFC')
oBrw:SetMenuDef( 'FISA080' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina		:= {}
Local lHistFiscal	:= IIf(FindFunction("HistFiscal"),HistFiscal(), .F.)

	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA080' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA080' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA080' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA080' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0020 ACTION 'A080Facil'	   OPERATION 3 ACCESS 0 // Facilitador
	//Somente adiciona a tela de histório se estiver habilitado este tratamento		
	IF lHistFiscal
		ADD OPTION aRotina TITLE STR0009  ACTION 'A080HISTOR'	   OPERATION 3 ACCESS 0 // Histótico
	EndIF

	IF FindFunction("OGAA770") .And. SuperGetMv('MV_AGRA001', , .F.) .And. SuperGetMv('MV_SIGAAGR', , .F.) //Módulo do agro
		ADD OPTION aRotina TITLE "Pauta ICMS - Tipo"  ACTION "OGAA770"   OPERATION 2 ACCESS 0 // Pauta agro
	EndIF

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCFC	:=	FWFormStruct( 1, 'CFC')
Local oModel
Local aAux := {}

oModel	:=	MPFormModel():New('FISA080',,{ |oModel| ValidForm(oModel) }, {|oModel| Grava(oModel) } )

//Adiciona a estrutura da CFC
oModel:AddFields( 'MODEL_CFC' , /*cOwner*/ , oStruCFC )

oStruCFC:SetProperty( 'CFC_UFORIG' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
oStruCFC:SetProperty( 'CFC_UFDEST' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
oStruCFC:SetProperty( 'CFC_CODPRD' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local	oModel		:=	FWLoadModel( 'FISA080' )
Local	oStCFCChv	:=	Nil
Local	oStCFCICM	:=	Nil
Local	oStCFCFcp	:=	Nil
Local	oStruCFC	:=	Nil
Local	cCmpFolder	:=	''
Local	oView		:=	FWFormView():New()
Local	lTAba01		:=	XUFSetAbas( 'ABA01' )
Local	lTAba02		:=	XUFSetAbas( 'ABA02' )
Local	lTAba0201	:=	XUFSetAbas( 'ABA0201' )
Local	lTWithAbas	:=	lTAba01 .And. lTAba02	// --> A variavel lWithAbas indica se a tela sera montada com ou sem abas, verificando atraves de FieldPos feito
												//   na funcao XUFSetAbas() para os campos das Abas 'Pai'. Se todas as abas pai possuirem os campos no dicionario, 
												//   monto a tela com abas, senao monto sem abas.
Local	cMvaFru		:=	Alltrim(StrTran(GetNewPar("MV_MVAFRU", ""),"CFC->",""))+'|'

oView:SetModel( oModel )

If lTWithAbas

	// ------------------------------------------
	// Campos para a Aba de Chave:
	//	- CFC_UFORIG; CFC_UFDEST; CFC_CODPRD
	// ------------------------------------------
	cCmpFolder	:=	'CFC_UFORIG|CFC_UFDEST|CFC_CODPRD|CFC_DESCR1|'
	oStCFCChv	:=	FwFormStruct( 2, 'CFC', {|x| AllTrim( x ) + "|" $ cCmpFolder } )
	// ------------------------------------------
	// Campos para a Aba de ICMS:
	//	- CFC_MARGEM; CFC_MGLQST; CFC_ALQSTL
	// ------------------------------------------
	cCmpFolder	:=	'CFC_MARGEM|CFC_MGLQST|CFC_ALQSTL|CFC_PRECST|CFC_RDCTIM|CFC_MVAES|CFC_NUMCON|CFC_ADICST|CFC_PICM|CFC_VLICMP|CFC_VL_ICM|CFC_VL_ANT|CFC_ALFEEF|CFC_PAUTFB|CFC_ALQANT|'+cMvaFru
	oStCFCICM	:=	FwFormStruct( 2, 'CFC', {|x| AllTrim( x ) + "|" $ cCmpFolder } )
	// ------------------------------------------
	// Campos para a Aba de FECP:
	//	- CFC_ALQFCP; CFC_ALFCPO; CFC_FCPAUX; CFC_FCPINT; CFC_FCPXDA
	// ------------------------------------------
	cCmpFolder	:=	'CFC_ALQFCP|CFC_ALFCPO|CFC_FCPAUX|CFC_FCPINT|CFC_FCPXDA|CFC_BFCPPR|CFC_BFCPST|CFC_BFCPCM|CFC_AFCPST|CFC_FCPBSR|CFC_FCPAJT|'
	oStCFCFcp	:=	FwFormStruct( 2, 'CFC', {|x| AllTrim( x ) + "|" $ cCmpFolder } )

	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	// Relaciona campos com os quadros que serao visualizados
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	oView:AddField( 'VIEW_CFCCHV'	, oStCFCChv	,	'MODEL_CFC' )
	oView:AddField( 'VIEW_CFCICM'	, oStCFCICM	,	'MODEL_CFC' )

	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	// Estabelece os Titulos dos quadros
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	oView:EnableTitleView( 'VIEW_CFCCHV', "UF x UF" )
	oView:EnableTitleView( 'VIEW_CFCICM', "ICMS" )

	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	// Cria a Box Principal
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	oView:CreateHorizontalBox( 'PAINEL', 100 )

	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	// Cria o Folder Principal
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	oView:CreateFolder( 'FOLDER', 'PAINEL' )

	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	// Cria as Abas Principais
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	oView:AddSheet( 'FOLDER'	, 'ABA01'	, "UF x UF" )
	oView:AddSheet( 'FOLDER'	, 'ABA02'	, "ICMS" )

	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	// Cria o Box de caba Aba Principal
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	oView:CreateHorizontalBox( 'BOX_CHAVE', 		100,,,	'FOLDER', 'ABA01' )
	oView:CreateHorizontalBox( 'BOX_ICMS', 			50,,,	'FOLDER', 'ABA02' )

	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	// Verifica se as aba filha '0201' deve ser criada
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	If lTAba0201

		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		// Relaciona campos com os quadros que serao visualizados
		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		oView:AddField( 'VIEW_CFCFCP'	, oStCFCFcp	,	'MODEL_CFC' )

		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		// Estabelece os Titulos dos quadros
		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		oView:EnableTitleView( 'VIEW_CFCFCP', "FECP" )

		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		// Cria o Box de Aba Filha
		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		oView:CreateHorizontalBox( 'BOX_ICMS_INFERIOR',	50,,,	'FOLDER', 'ABA02' )

		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		// Cria Folder Auxiliar
		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		oView:CreateFolder( 'FOLDER_BOX_ICMS_INFERIOR', 'BOX_ICMS_INFERIOR' )

		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		// Cria Abas de Folder Auxiliar
		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		oView:AddSheet( 'FOLDER_BOX_ICMS_INFERIOR', 'ABA0201', "FECP" )

		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		// Cria Box de caba Aba do Folder Auxiliar
		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		oView:CreateHorizontalBox( 'BOX_ICMS_FECP',	100,,,	'FOLDER_BOX_ICMS_INFERIOR', 'ABA0201' )

		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		// Visualizacao dos quadros
		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		oView:SetOwnerView( 'VIEW_CFCFCP' , 'BOX_ICMS_FECP')
	Endif
	
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	// Visualizacao dos quadros
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	oView:SetOwnerView( 'VIEW_CFCCHV' , 'BOX_CHAVE')
	oView:SetOwnerView( 'VIEW_CFCICM' , 'BOX_ICMS')

Else

	oStruCFC	:= 	FWFormStruct( 2, 'CFC' )
	oView:AddField( 'VIEW_CFC', oStruCFC, 'MODEL_CFC' )
	oView:EnableTitleView( 'VIEW_CFC', "UF x UF" )

Endif

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Função para fazer validações do formulário

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

Local lRet			:= .T.
Local nOperation	:= oModel:GetOperation()
Local lHistFiscal	:= IIf(FindFunction("HistFiscal"),HistFiscal(), .F.)
Local cUfOri		:= oModel:GetValue ('MODEL_CFC','CFC_UFORIG')
Local cUfDest		:= oModel:GetValue ('MODEL_CFC','CFC_UFDEST')
Local cCodpro		:= oModel:GetValue ('MODEL_CFC','CFC_CODPRD')

IF nOperation == 3 // Inclusão irei verificar se já existe registro da CGA gravado
	dbSelectArea("CFC")
	If CFC->(dbSeek(xFilial("CFC")+cUfOri+cUfDest+cCodpro))
		Help(,,"A080",,STR0010,1,0) //"Alíquota para Estado de Origem, de Destino e Código de Produto já cadastrada."			
		lRet := .F.
	EndIf
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Função será chamada para realizar a gravação do histórico na tabela SS9

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function Grava(oModel)
Local lret := .T.
Local lHistFiscal	:= IIf(FindFunction("HistFiscal"),HistFiscal(), .F.)
Local nOperation	:= oModel:GetOperation()
Local bCampoCFC		:= { |x| CFC->(Field(x)) }
Local aCmps			:= {}
Local cIdHistFis	:= IdHistFis()

//Verificar se irá gravar Histórico para operações de edição e exclusão
If lHistFiscal
	//Busca estrutura dos campos da tabela CFC
	aCmps :=  RetCmps("CFC",bCampoCFC)
	//Grava o histórico da tabela CFC na tabela SS9
	GrvHistFis("CFC", "SS9", aCmps)
EndiF

FWFormCommit( oModel )

If lHistFiscal
	//Para operação de Inclusão e edição grava ID
	If nOperation == 3 .Or. nOperation == 4 
		RecLock("CFC",.F.)
		CFC_IDHIST	:= cIdHistFis
		MsUnLock()
	EndIF
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A080HISTOR
Função que irá buscar o histórico de alterações e inclusões da tabela SS9

@return oView - Objeto da View MVC

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------                     
Function A080HISTOR()
Local aCampos	:= {}
Local lRet		:= .T.

AADD(aCampos,{CFC->CFC_CODPRD,"S9_CODPRD"})
AADD(aCampos,{CFC->CFC_UFORIG,"S9_UFORIG"})
AADD(aCampos,{CFC->CFC_UFDEST,"S9_UFDEST"})

//Chama função para buscar o histórico gravado na tabela SS9
lRet:= HistOperFis("SS9",,"Histórico de alterações:","",,aCampos) //Descrição

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A080Facil
Função que irá processar o Facilitador de cadastro, realizando o cadastro
em lote.

@return 

@author Erick G. Dias
@since 11/10/2013
@version 11.80
/*/
//------------------------------------------------------------------- 
Function A080Facil()
Local aHeader	:= {}
Local aCols		:= {}
Local aCmp		:= {}
Local cCmpExcl	:= "CFC_FILIAL/CFC_CODPRD/CFC_UFORIG/CFC_UFDEST/CFC_IDHIST/CFC_DESCR1/" // Campos que não serão apresentados para edição
Local nAlt		:= 0
Local nInc		:= 0
Local nX		:= 0
local lCancel	:= .F.
Local lEnd		:= .F.
Local oDlg
Local oGetD

If LockByName("A080Facil",.T.,.T.)

	#IFDEF TOP
		If TcSrvType() <> "AS/400"
			lTop := .T.
		Endif
	#ENDIF

	//Chama pergunta para montar o filtro do facilitador
	IF Pergunte("ASA080",.T.)
		//Irá buscar campos na SX3 da tabela CFC
		dbSelectArea("SX3")
		SX3->(dbSetOrder(1))
		If SX3->(dbSeek("CFC"))
			Do While !SX3->( EOF()) .AND. X3_ARQUIVO == "CFC"
				If  !X3_CAMPO $ cCmpExcl .AND. X3_CONTEXT <> 'V'
					Aadd(aHeader,{X3_TITULO,X3_CAMPO,X3_PICTURE,X3_TAMANHO,0,'','€€€€€€€€€€€€€€ ',X3_TIPO,'',''})
					aAdd(aCmp,{X3_CAMPO,X3_TIPO,0})
				EndIf
				SX3->( DBSKIP())
			EndDo
		EndIf

		//Monta a tela com os campos disponíveis para edição do usuário no facilitador.
		oDlg := MSDIALOG():New(000,000,340,600, STR0008,,,,,,,,,.T.)
		nOpc := GD_INSERT+GD_DELETE+GD_UPDATE

		@ 155,258 Button STR0012 Size 037,012 PIXEL OF oDlg ACTION (nOpca := 1, oDlg:End())
		@ 155,216 Button STR0017 Size 037,012 PIXEL OF oDlg ACTION (nOpca := 0, oDlg:End())
		oGetD:= MsNewGetDados():New(001,001,150,300, nOpc,,,,,000,1,,,,oDLG,aHeader,aCols)

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0,.F.)

		//Se clicou no OK e a linha não está deleteda irá processar.
		IF nOpca == 1 .AND. !oGetD:aCols[1] [Len(oGetD:aCols[1])]

			//Percorre o array de campos para buscar o conteúdo no array da getdados
			For nX:= 1 to Len(aCmp)
				aCmp[nX][3]:= oGetD:aCols[1][nX]
			Next nX

			//Monta o filtro para buscar no cadastro de Produtos conforme as informações do usuário na pergunta.
			cFiltro	:= "B1_POSIPI >= '"+MV_PAR03+"' "+ Iif(lTop," AND "," .AND. " )+" B1_POSIPI <= '" +MV_PAR04 +"' "
			cFiltro	+= Iif(lTop," AND "," .AND. " )+"B1_GRTRIB >= '"+MV_PAR05+"' "+ Iif(lTop," AND "," .AND. " )+" B1_GRTRIB <= '" +MV_PAR06 +"' "
			cFiltro	+= Iif(lTop," AND "," .AND. " )+ "B1_COD 	>= '"+MV_PAR07+"' "+ Iif(lTop," AND "," .AND. " )+" B1_COD    <= '" +MV_PAR08 +"' "
			cFiltro	+= Iif(!Empty(Alltrim(MV_PAR10)),Iif(lTop," AND "," .AND. " )+ "B1_ORIGEM = '"+Alltrim(MV_PAR10)+"' ", "")

			lAtualiza := MV_PAR09 == 1

			Processa({|lEnd| ProcFacCFC(MV_PAR01, MV_PAR02, aCmp, cFiltro,lAtualiza,@nAlt,@nInc,@lCancel,@lEnd)},,,.T.)

			IF lCancel
				Alert(STR0018)
			Else
				MsgInfo(STR0013 +Chr (13)+Chr (10) + Chr (13)+Chr (10)+ STR0014 +Alltrim(str(nInc)) +Chr (13)+Chr (10) + Chr (13)+Chr (10)+ STR0015 +Alltrim( str(nAlt)) )		
			EndIF
			CFC->(DBGOTOP())
		EndIf
	EndIf
	UnLockByName( 'A080Facil', .T. , .T. )
Else
	Help("",1,"Rotina Já está sendo executada","Rotina Já está sendo executada","Rotina Já está sendo executada",1,0) // "Tabela CF5 não cadastrada no sistema!"
		Help("",1,STR0003,STR0003,STR0019,1,0) // "Facilitador já está em processamento em outra instância"
EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcFacCFC
Função que irá realizar cadastro na tabela CFC em lote, através do facilitador de cadastro.

@param	cUfOri		-> UF de origem
		cUfDest		-> UF de destino
		aCmp		-> Array com os campos e valores informados pelo usuário para o processamento
		cFiltro		-> Filtro na SB1 informado pelo usuário
		lAtualiza	-> Indica se irá alterar um registro ou não caso já exista.
		nAlt		-> Contador de registros alterados
		nInc		-> Contador de registros incluídos
		lCancel		-> Variável para controle de cancelamento
		lEnd		-> Variável para controle de cancelamento


@return lRet

@author Erick G. Dias
@since 11/10/2013
@version 11.90
/*/
//------------------------------------------------------------------- 
Static Function ProcFacCFC(cUfOri, cUfDest, aCmp, cFiltro, lAtualiza,nAlt,nInc,lCancel,lEnd)

Local lRet := .F.
Local cAliasSB1	:= "SB1"
Local cWhere		:= ""
Local nX			:= 0
Local nUfO			:= 0
Local nUfD			:= 0
Local aCmps			:= {}
//Local cIdHistFis	:= ""
Local cIdAux		:= "AA"
Local cIdSec		:= IdHistFis()
Local bCampoCFC		:= { |x| CFC->(Field(x)) }
Local lHistFiscal	:= IIf(FindFunction("HistFiscal"),HistFiscal(), .F.)
Local lTodasUFO		:= Iif("**"$cUfOri , .T., .F.)
Local lTodasUFD		:= Iif("**"$cUfDest , .T., .F.)
Local aUFO			:= {}
Local aUFD			:= {}
Local lVirtual	 	:= CFC->(FieldPos("CFC_DESCR1"))>0

If !Empty(cUfOri) .And. !Empty(cUfDest) .And. (lTodasUFO .Or. SX5->(dbSeek(xFilial("SX5")+'12'+cUfOri))) .And. (lTodasUFD .Or. SX5->(dbSeek(xFilial("SX5")+'12'+cUfDest)))
	lRet := .T.
	
	//Se processar todas as UF de destino, rodo X5 e alimento array com UF, caso contrário alimento somente com UF específica informada
	IF lTodasUFO .Or. lTodasUFD
		SX5->(dbSeek(xFilial("SX5")+'12'))
		While !SX5->(Eof()) .AND. SX5->X5_TABELA == "12"
			If lTodasUFO
				AADD(aUFO,Alltrim(SX5->X5_CHAVE))
			EndIf
			If lTodasUFD
				AADD(aUFD,Alltrim(SX5->X5_CHAVE))
			EndIf
			SX5->(DbSkip())
		EndDo
	EndIF

	If !lTodasUFO
		AADD(aUFO,cUfOri)
	EndIf

	If !lTodasUFD
		AADD(aUFD,cUfDest)
	EndIf

	DbSelectArea (cAliasSB1)
	(cAliasSB1)->(DbSetOrder (1))

	DbSelectArea("CFC")
	CFC->(DbSetOrder(1))

	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			cAliasSB1	:=	GetNextAlias()
			cWhere := "%" + cFiltro + "%"
			BeginSql Alias cAliasSB1

				SELECT
					SB1.B1_COD, SB1.B1_DESC
				FROM
					%Table:SB1% SB1
				WHERE
					SB1.B1_FILIAL=%xFilial:SB1% AND
					%Exp:cWhere% AND
					SB1.%NotDel%
			EndSql
		Else
	#ENDIF
			cIndex	:= CriaTrab(NIL,.F.)
			cWhere	:= 'SB1_FILIAL=="'+xFilial ("SB1")+'" .AND. '
			cWhere	+= cFiltro
			IndRegua (cAliasSB1, cIndex, SB1->(IndexKey ()),, cWhere)
			nIndex := RetIndex(cAliasSB1)
			#IFNDEF TOP
				DbSetIndex (cIndex+OrdBagExt ())
			#ENDIF
			DbSelectArea (cAliasSB1)
			DbSetOrder (nIndex+1)
	#IFDEF TOP
		Endif
	#ENDIF

	DbSelectArea (cAliasSB1)
	(cAliasSB1)->(DbGoTop ())
	ProcRegua ((cAliasSB1)->(RecCount ())* (Len(aUfO) * Len(aUfD))) 

	Do While !(cAliasSB1)->(Eof ())	

		For nUfO	:= 1 to Len(aUFO)
			For nUfD := 1 to Len(aUFD)

				If Interrupcao(lEnd)
					lCancel := lEnd
					#IFDEF TOP
						If (TcSrvType ()<>"AS/400")
							DbSelectArea (cAliasSB1)
							(cAliasSB1)->(DbCloseArea ())
						Else
					#ENDIF
							RetIndex("SB1")
							FErase(cIndex+OrdBagExt ())
					#IFDEF TOP
						EndIf
					#ENDIF
		
					Return
				EndIf

				IncProc(STR0016 + (cAliasSB1)->B1_COD)
				//Verifica se registro já existe, se estiver com opção para alterar irá editar, caso contrário não fará nada. 
				If CFC->(MsSeek(xFilial("CFC")+aUfO[nUfO]+aUfD[nUfD]+(cAliasSB1)->B1_COD))
					If lAtualiza
						IF lHistFiscal
							//Busca estrutura dos campos da tabela CFC
							aCmps :=  RetCmps("CFC",bCampoCFC)
							//Grava o histórico da tabela CFC na tabela SS9
							GrvHistFis("CFC", "SS9", aCmps)
						EndIF
						RecLock("CFC",.F.)
						For nX:= 1 to Len(aCmp)
							&("CFC->"+aCmp[nX][1] ):=aCmp[nX][3]
						Next nX	
						MsUnLock()
						nAlt++
						IF lHistFiscal
							cIdHistFis:=IdLote(@cIdSec, @cIdAux)
							//Para operação de Inclusão e edição grava ID
							RecLock("CFC",.F.)
							CFC_IDHIST	:= cIdHistFis
							MsUnLock()
						EndIF
					EndIF
				Else
					//Inclui registro se não existir.
					IF lHistFiscal
						//Busca estrutura dos campos da tabela CFC
						aCmps :=  RetCmps("CFC",bCampoCFC)
						//Grava o histórico da tabela CFC na tabela SS9
						GrvHistFis("CFC", "SS9", aCmps)
					EndIF
					RecLock("CFC",.T.)
					CFC->CFC_FILIAL := xFilial ("CFC")
					CFC->CFC_UFORIG := cUfOri
					CFC->CFC_UFORIG := aUfO[nUfO]
					CFC->CFC_UFDEST := aUfD[nUfD]
					CFC->CFC_CODPRD := (cAliasSB1)->B1_COD
					If lVirtual
						CFC->CFC_DESCR1 := (cAliasSB1)->B1_DESC
					EndIf
					For nX:= 1 to Len(aCmp)
						&("CFC->"+aCmp[nX][1] )	:=aCmp[nX][3]
					Next
					MsUnLock()
					nInc++
		
					IF lHistFiscal
						cIdHistFis:=IdLote(@cIdSec, @cIdAux)
						//Para operação de Inclusão e edição grava ID
						RecLock("CFC",.F.)
						CFC_IDHIST	:= cIdHistFis
						MsUnLock()
					EndIF
				EndIF
			Next nUfD
		Next nUfO

		(cAliasSB1)->(DbSkip ())
	EndDo

	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			DbSelectArea (cAliasSB1)
			(cAliasSB1)->(DbCloseArea ())
		Else
	#ENDIF
			RetIndex("SB1")
			FErase(cIndex+OrdBagExt ())
	#IFDEF TOP
		EndIf
	#ENDIF
EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IdLote
Função para gerar ID de gravação de histórico. Como o processamento é em lote
, irá ocorrer de gravar mais de um registro por segundo na tabela espelho,
causando registro duplicado na chave de ID. Por este motivo, quando houver processamento
em lote, irei gerar mais dois caracteres no ID, utilizando soma1, assim o id continuará
com data e hora, e um contador.

@param	cIdSec		-> ID gerado pela função IdHistFis()
		cIdAux		-> ID auxiliar contador que será concatenado no ID de histórico.

@return cIdHistFis 

@author Erick G. Dias
@since 11/11/2013
@version 11.80
/*/
//------------------------------------------------------------------- 
Static Function IdLote(cIdSec, cIdAux)

Local cIdHistFis	:= ""

//Quando a gravação é feita por lote, pode acontecer de gravar vários registro no mesmo segundo
//Neste cenário, quando ocorrer gravação no mesmo segundo, irei adicionar mais dois caracteres no final do código ID, com duas letras
//Assim para o mesmo segundo o id não se repetirá.
cIdHistFis	:= IdHistFis()
If cIdSec <> cIdHistFis
	cIdSec	:= cIdHistFis
	cIdAux	:= "AA"
EndIF
cIdAux:= Soma1(cIdAux)
cIdHistFis	:= cIdHistFis+cIdAux

Return cIdHistFis

//-------------------------------------------------------------------
/*/{Protheus.doc} XUFSetAbas

Verifica se a aba devera ser criada na tela do cadastro, baseando-se
nos campos amarrados a cada aba.

@param	cAba	-	ID da aba a ser verificada

@return lRet	-	Indica se a aba devera ser criada (T) ou nao (F)

@author Luccas Curcio
@since 30/01/2014
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function XUFSetAbas( cAba )
Local	lRet	:=	.F.
Local	aCmpAba	:=	{}
Local	nX		:=	0
Local cMvaFru	:=	Alltrim(StrTran	(GetNewPar ("MV_MVAFRU", ""),	"CFC->",	""))

If cAba == 'ABA01'
	aCmpAba	:=	{ "CFC_UFORIG" , "CFC_UFDEST" , "CFC_CODPRD" }

Elseif cAba == 'ABA02'
	aCmpAba	:=	{ "CFC_MARGEM" , "CFC_MGLQST" , "CFC_ALQSTL", "CFC_PRECST", "CFC_RDCTIM", "CFC_MVAES" ,cMvaFru, "CFC_ALQSTL", "CFC_PICM", "CFC_VLICMP", "CFC_VL_ICM", "CFC_VL_ANT","CFC_ALFEEF","CFC_PAUTFB" }

Elseif cAba == 'ABA0201'	
	aCmpAba	:=	{ "CFC_ALQFCP" , "CFC_ALFCPO" , "CFC_FCPAUX" , "CFC_FCPINT" , "CFC_FCPXDA" }

Endif

For nX := 1 To Len( aCmpAba )
	If CFC->( FieldPos( aCmpAba[nX] ) ) > 0
		lRet	:=	.T.
		Exit
	Endif
Next nX

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cBoxBsProp

Funcao para geracao da lista de opcoes do campo CFC_BFCPPR.

@author joao.pellegrini
@since 15/09/2017
@version 12.1.17
/*/
//------------------------------------------------------------------- 
Function cBoxBsProp()

Local cRet := ""

cRet := "1=ICMS Próprio"

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cBoxBsProp

Funcao para geracao da lista de opcoes do campo CFC_BFCPST.

@author joao.pellegrini
@since 15/09/2017
@version 12.1.17
/*/
//------------------------------------------------------------------- 
Function cBoxBsST()

Local cRet := ""

cRet := "1=ICMS Solid.;2=ICMS Solid. - ICMS Próprio;3=ICMS Próprio + IPI + Frete + Seguro + Despesas"

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cBoxBsCMP

Funcao para geracao da lista de opcoes do campo CFC_BFCPCM.

@author joao.pellegrini
@since 15/09/2017
@version 12.1.17
/*/
//------------------------------------------------------------------- 
Function cBoxBsCMP()

Local cRet := ""

cRet := "1=Base Dest.;2=ICMS Próprio"

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
 
Função que irá criar O SX1 complementar do Relatorio
 
@author Erich Buttner
@since 12/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function AjuCMP()
Local aDados := {}
Local aHelpPor := {} 

aHelpPor := {"Indica se haverá cálculo do FECP  ",;
	"nas operações internas e importações." ,;
	"Esta opção não se aplica para",;
	"operações destinadas a Consumidor",;
	"Final, onde sempre haverá cálculo."}				 
	// Ajuste do TITULO, DESCRICAO e HELP do campo CFC_FCPINT - NF-e 4.00.
	aAdd( aDados, {{"CFC_FCPINT"}, {{"X3_TITULO", "Op.Int./Imp."}, {"X3_DESCRIC", "Calc. FECP Oper. Int/Imp"}}})
	aAdd( aDados, { { 'CFC_MVAES' 	}, { { 'X3_USADO'	, '€€€€€€€€€€€€€€ ' } } } )


If FindFunction("EngSX3116")
				

	EngHLP116("PCFC_FCPINT",aHelpPor,aHelpPor,aHelpPor)
	EngSX3116( aDados ) 

EndIf

If FindFunction("EngSX3117")
				

	EngHLP117("PCFC_FCPINT",aHelpPor,aHelpPor,aHelpPor)
	EngSX3117( aDados ) 

EndIf
