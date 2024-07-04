#Include "Oga430.ch"
#Include "Protheus.ch"
#Include "fwMvcDef.ch"
#Include "TopConn.ch"

/** {Protheus.doc} OGA430
Rotina de amarraçoes de Contratos x Fixacoes x Documento Fiscal

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	18/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA430( pcCodCtr)

	Local aAreaNJR		:= {}
	Local aCords 		:= FWGetDialogSize( oMainWnd )
	Local oDlg			:= Nil
	Local oFwLayer		:= Nil
	Local oPnTOP		:= Nil
	Local oPnD1			:= Nil
	Local oPnD2			:= Nil

	Private _oBrwNN8		:= Nil
	Private _oBrwNNC		:= Nil
	Private _oBrwNN5		:= Nil
	Private _oRelX			:= Nil
	Private _oRelY			:= Nil
	
	DbSelectArea( "NJR" )
	DbSetOrder( 1 )
	If !DbSeek( FWxFilial( "NJR" )  + pcCodCtr )
		Help( , , STR0009, , STR0029 + ": " + pcCodCtr, 1, 0 ) //"AJUDA"###"Não foi possível localizar o contrato na tabela de Contratos (NJR) "
		Return( Nil )
	ElseIF NJR->NJR_TIPO $ "3|4"	
		Help( , , STR0009, , STR0030 + ": " + pcCodCtr, 1, 0 ) //"AJUDA"###"Operação permitida somente para contratos de Compra e Venda. "
		Return( Nil )
	ElseIF NJR->(ColumnPos('NJR_CODNGC' )) > 0 .and. NJR->(ColumnPos('NJR_VERSAO' )) > 0 .and. (!empty(NJR->NJR_CODNGC) .and. !empty(NJR->NJR_VERSAO))	
		Help( , , STR0009, , STR0042 + ": " + pcCodCtr, 1, 0 ) //"AJUDA"###"Operação permitida somente para contratos de Compra e Venda. "
		Return( Nil )
	EndIf
	
	aAreaNJR		:= NJR->( GetArea() )  // Salva Area da NJR para N. desposicionar

	
    oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ], aCords[ 4 ], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Fixações dos Contratos"

    oFwLayer := FwLayer():New()
    oFwLayer:Init( oDlg, .f., .t. )

    oFWLayer:AddLine( 'UP', 45, .F. )
    oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
    oPnTOP := oFWLayer:GetColPanel( 'ALL', 'UP' )

    oFWLayer:AddLine( 'DOWN', 55, .F. )
    oFWLayer:AddCollumn( 'LEFT' , 50, .T., 'DOWN' )
    oFWLayer:AddCollumn( 'RIGHT', 50, .T., 'DOWN' )

    oPnD1 := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' )
    oPnD2 := oFWLayer:GetColPanel( 'RIGHT', 'DOWN' )
    aDescLeg	:= {}

    //////
    /// Inserir mais uma aba aqui para mostrar Pagamentos e Recebimentos
    //////
    _oBrwNN5 := FwMBrowse():New()
    _oBrwNN5:SetOwner( oPnD2 )
    _oBrwNN5:SetAlias( "NN5" )
    _oBrwNN5:SetMenuDef( "OGA360" )
    _oBrwNN5:SetDescription( STR0024 ) //"Financeiro"
    //_oBrwNN5:SetFilterDefault( "NN5_CODCTR=='"+pcCodCtr+"'" )
    _oBrwNN5:SetProfileID( "3" )
    _oBrwNN5:DisableDetails()
    _oBrwNN5:ForceQuitButton()

    _oBrwNN5:SetWalkThru(.F.)
    _oBrwNN5:SetAmbiente(.F.)

    _oBrwNN5:Activate()

    RestArea( aAreaNJR ) // Restaura Para Garantir que n. monstagem do Browse n. Despoicionou a Area

    _oBrwNN8 := FwMBrowse():New()
    _oBrwNN8:SetOwner( oPnTOP )
    _oBrwNN8:SetAlias( "NN8" )
    _oBrwNN8:SetMenuDef( "OGA430F" )
    _oBrwNN8:SetDescription( STR0001 + ": " + pcCodCtr ) //"Fixações do Contrato"
    
    If (cPaisLoc == "PAR" .or. cPaisLoc == "ARG")
        _oBrwNN8:SetFilterDefault( "NN8_CODCTR=='"+pcCodCtr+"' .and. NN8_SITCTR<> 'C'" )
        _oBrwNN8:AddLegend( "NN8_TIPOFX=='0'", 						  "WHITE"	, X3CboxDesc( "NN8_TIPOFX", "0" ) ) //a Fixar   dekalpar
        _oBrwNN8:AddLegend( "NN8_TIPOFX=='2'", "BLUE"	, X3CboxDesc( "NN8_TIPOFX", "2" ) ) // Basis  dekalpar
        _oBrwNN8:AddLegend( "NN8_TIPOFX=='1'.And.NN8_STATUS=='1'", "RED"	, X3CboxDesc( "NN8_TIPOFX", "1" ) ) // Fixo  dekalpar
        _oBrwNN8:AddLegend( "NN8_TIPOFX=='1'.And.NN8_STATUS=='2'", "YELLOW", X3CboxDesc( "NN8_STATUS", "2" ) ) //Parcial 
        _oBrwNN8:AddLegend( "NN8_TIPOFX=='1'.And.NN8_STATUS=='3'", "GREEN"	, X3CboxDesc( "NN8_STATUS", "3" ) ) //Fechada
        _oBrwNN8:AddLegend( "NN8_TIPOFX=='3'", "PINK"	, X3CboxDesc( "NN8_TIPOFX", "3" ) ) // Provisorio  dekalpar	 	
    else
        _oBrwNN8:SetFilterDefault( "NN8_CODCTR=='"+pcCodCtr+"'" )
        _oBrwNN8:SetOnlyFields({'NN8_CODCTR','NN8_ITEMFX','NN8_DATA','NN8_DATINI','NN8_DATFIN','NN8_QTDFIX','NN8_QTDENT','NN8_VLRUNI','NN8_VLRLIQ','NN8_VLRTOT'})
        _oBrwNN8:AddLegend( "NN8_TIPOFX=='0'", 						  "WHITE"	, X3CboxDesc( "NN8_STATUS", "0" ) ) //Prevista
        _oBrwNN8:AddLegend( "NN8_TIPOFX=='1'.And.NN8_STATUS=='1'", "RED"	, X3CboxDesc( "NN8_STATUS", "1" ) ) //Aberta
        _oBrwNN8:AddLegend( "NN8_TIPOFX=='1'.And.NN8_STATUS=='2'", "YELLOW", X3CboxDesc( "NN8_STATUS", "2" ) ) //Parcial
        _oBrwNN8:AddLegend( "NN8_TIPOFX=='1'.And.NN8_STATUS=='3'", "GREEN"	, X3CboxDesc( "NN8_STATUS", "3" ) ) //Fechada
    EndIf
    
    _oBrwNN8:SetChange ({|| IIF(!TYPE('_oBrwNNC') = 'U',_oBrwNNC:SetDescription( STR0039 /*+ NN8->NN8_ITEMFX*/ ),'') })
    _oBrwNN8:SetProfileID( "2" )
    _oBrwNN8:DisableDetails()
    _oBrwNN8:Activate()
    RestArea( aAreaNJR ) // Restaura Para Garantir que n. monstagem do Browse n. Despoicionou a Area
    //EMERSON

    ///f_oBrwNNC(OpnD1)   //Criando o BroWse DA NNC

    aCposBrowse := {"NNC_CODROM","NNC_ITEROM","NNC_NUMDOC","NNC_SERDOC","NNC_QTDENT","NNC_VLENT","NNC_QTDFIX","NNC_VRENPF",'NNC_VLCMPL'}	
    _oBrwNNC := FwMBrowse():New() 
    _oBrwNNC:SetOwner( oPnD1 )
    _oBrwNNC:SetAlias( "NNC" )
    _oBrwNNC:SetMenuDef( "OGA430" )
    _oBrwNNC:SetDescription( STR0039 + NN8->NN8_ITEMFX ) //"Movimentos"
    _oBrwNNC:SetOnlyFields( aCposBrowse )
    ///_oBrwNN8:SetFilterDefault( "NN8_CODCTR=='"+pcCodCtr+"'" )
    _oBrwNNC:SetProfileID( "4" )
    _oBrwNNC:DisableDetails()

    // -- Adicionando Legenda no Browse --//

    aDescLeg := OG430STAT(nil,1) 				// Encontrando a Descrição dos Possiveis Status de forma Centralizada

    nPosDscSt	:= Ascan(aDescLeg,{ |x| x[1] == '1'})
    _oBrwNNC:AddLegend( "NNC_STATUS == '1'", "RED",	 		aDescLeg[nPosDscSt,2]	)  //#Requer  Nf. Complementar
    
    nPosDscSt	:= Ascan(aDescLeg,{ |x| x[1] == '2'})
    _oBrwNNC:AddLegend( "NNC_STATUS == '2'", "YELLOW",	aDescLeg[nPosDscSt,2]	)  //#Requer  Nf. Complementar Produtor
    
    nPosDscSt	:= Ascan(aDescLeg,{ |x| x[1] == '5'})
    _oBrwNNC:AddLegend( "NNC_STATUS == '5'", "PINK",			aDescLeg[nPosDscSt,2]	) //#Valor da Fixação a Menor
    _oBrwNNC:AddLegend( "NNC_STATUS $ '3|4|6|7|'", "GREEN",		STR0038					) //#Ajuste Decrescimo Financeiro Efetuado


    _oBrwNNC:SetWalkThru(.F.)
    // -- Fim Adicionando Leg. Browse   --//
    _oBrwNNC:Activate()
    RestArea( aAreaNJR ) // Restaura Para Garantir que n. monstagem do Browse n. Despoicionou a Area

    _oRelY := FwBrwRelation():New()
    _oRelY:AddRelation( _oBrwNN8 , _oBrwNNC, { { "NNC_FILIAL", "xFilial( 'NNC' )" }, { "NNC_CODCTR" , "NN8_CODCTR" },{ "NNC_ITEMFX" , "NN8_ITEMFX" } } )
    _oRelY:Activate()
    //EMERSON

    _oRelX := FwBrwRelation():New()
    _oRelX:AddRelation( _oBrwNN8 , _oBrwNN5, { { "NN5_FILIAL", "xFilial( 'NN5' )" }, { "NN5_CODCTR" , "NN8_CODCTR" },{ "NN5_CODFIX" , "NN8_ITEMFX" } } )
    _oRelX:Activate()

    oDlg:Activate( , , , .t., { || .t. }, , { || } )

    _oBrwNN5:DeActivate()
    _oBrwNNC:DeActivate()
    _oBrwNN8:DeActivate()

	Restarea( aAreaNJR )
Return( )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Marlon Richard Trettin
@since: 	18/11/20144
@Uso: 		OGA010 - Entidades
*/
Static Function MenuDef()
	Local aRotina 	:= {}

	aAdd( aRotina, { STR0040		,"sTaticcall(OGA430,fPendencias)"			, 0, 4, 0, Nil } ) //#Pendências
	aAdd( aRotina, { STR0041		,"Staticcall(OGA430,fListDocs)" 			, 0, 6, 0, Nil } ) //#"Lista Nfs. Complemento"

Return( aRotina )


/** {Protheus.doc} fPendencias
Função que Chama a Rotina de Pendencias das Entregas
relacionadas a fixação

@param: 	Nil
@return:	nil
@author: 	Emerson Coelho
@since: 	13/07/2016
@Uso: 		SIGAAGR
*/
Static Function fPendencias()

	OGA430A(NN8->NN8_CODCTR, NN8->NN8_ITEMFX)

Return(  )

/*{Protheus.doc} OG430STAT
Função Generica para tratar estatus da NNC ( Vide Observação )
O Default do ntpAcao é (0) 

@param      nRecnoNNC -> Recno do Registro da NNC a Posicionar (opcional)
nTpAcao  -> 0 Indica que deve Atualizar o Status da NNC e Retornar o Status Atual
nTpAcao  -> 1 Indica que deve Retornar Array com possiveis Status da NNC e Suas Descrições
nTpAcao  -> 2 Indica que deve Retornar String com Status de Pendencia separados por (;)
@return     Variavel de Acordo com a nTPAcao
nTpAcao  -> 0 Indica que deve Atualizar o Status da NNC e retornar o Status Atual
nTpAcao  -> 1 Indica que deve Retornar Array com possiveis Status da NNC e Suas Descrições
nTpAcao  -> 2 Indica que deve Retornar String com Status de Pendencia separados por (;)
nTpAcao     -> 3 Indica que deve Retornar String com os possiveis status no formato opções  (deve ser colocado no x3_cbox do NNC_STATUS)
@author    Emerson coelho

Obs: 
Tratei tudo nessa função para tentar manter tudo ref. a eses status  de vinculos
do romaneio de forma centralizada

Os Possiveis Retornos São hj (29/06/20116)
Pode ser Array com a Lista de Status Possiveis
Status Atualizado do registro da NNC informado ou posicionado;

Ex Chamada OG430STAT() o mesmo que; OG430STAT(0;0)       // Indica que irá Recalcular o Status do Registro da NNC Posicionado e retornar Status Atual 
OG430STAT( 21256 ) o mesmo que OG430STAT( 21256; 0 )   // Indica que irá Recalcular o Status do Registro da NNC Ref. ao Recno Passado e retornar Status Atual
OG430STAT(,1)             // Indica que irá Retornar   array com os Possiveis Status e suas descriçoes
OG430STAT(,2)             // 2 Indica que deve Retornar String com Status de Pendencia separados por (;)
OG430STAT(,3)             // 3 Indica que deve Retornar String com os possiveis status no formato opções  (deve ser colocado no x3_cbox do NNC_STATUS)S
e Tambem a atualização dos status da NNC de forma centralizada
e como a função já stava sendo utilizada essa foi a melhor forma que
encontrar para centralizar
/*/

Function OG430STAT( nRecnoNNC, nTpAcao )
	Local aAliasAtu  	:= GetArea()
	Local aAliasNNC  	:= NNC->( GetArea() )
	Local cStatus  		:= ''
	Local nNNCVLFIXB 	:= 0
	Local aLstStatus 	:= {}  
	Local cStatsPend 	:= ''
	Local nI   			:= 0
	Local cOpcoes 		:= ''

	Default nRecnoNNC	:= 0
	Default nTpAcao  	:= 0

	IF nTpAcao == 1  .or. nTpAcao == 3  //Indica que somene devemos retornar os possiveis Status e suas Descrições
		/*Status e suas Legendas até o Momento 29/06/2016 
		aLstStatus  Posicao 1  = Status Atual
		Posicao 2 = Descrição do Status 
		Posicao 3 = Indica o Status Encontrado na Vinculação
		*/
		aAdd(aLstStatus, {'1', STR0031  ,'1'}) //"Requer NF.Complemento/Propria"
		aAdd(aLstStatus, {'2', STR0032  ,'2'}) //"Requer NF.Complemento/Produtor"
		aAdd(aLstStatus, {'3', STR0033  ,'3'}) //"Não Possui pendencia"
		aAdd(aLstStatus, {'4', STR0034  ,'1'}) //"Nf. Complemento Propia Emitida"
		aAdd(aLstStatus, {'5', STR0035  ,'5'}) //"VR.Fixação a Menor/Requer Ajuste Financeiro"
		aAdd(aLstStatus, {'6', STR0036  ,'5'}) //"Ajuste Financeiro processado"
		aAdd(aLstStatus, {'7', STR0037  ,'2'}) //"Nf. Complemento/Produtor Vinculada"

		IF nTpAcao == 1   // Retorna Array com os possiveis Status
			Return( aLstStatus )
		ElseIF nTpAcao == 3  // Retorna String dos status para x3_cbox do campo nnc_status
			For nI:=1 To Len( aLstStatus )
				cOpcoes += IIf(empty(cOpcoes),'',';') + aLstStatus[nI,1] + "="  + aLstStatus[nI,2]
			Next
			Return( cOpcoes )
		EndIF

	ElseIF nTpAcao == 2   //Indica que devo retornar Status de pendencia separado por ;
		//Status de Pendencias até o Momento 29/06/2016 
		cStatsPend := '1;2;5'

		Return( cStatsPend )

	ElseIF nTpAcao == 0  // Indica que devo Atualizar o Status de um romaneio vinculado posicionando ou não de acordo com o Recno
		IF nRecnoNNC > 0  //Veifica se deve posicionar o Recno
			NNC->( DbGoTo( nRecnoNNC ) )
		EndIf

		IF NNC->NNC_VLFBAJ > 0      // Se o Vr. de ajuste esta preenchido siginifica que o Vr. foi mudado, qdo foi gerar a nf de complemento
			nNNCVLFIXB := NNC->NNC_VLFBAJ
		Else
			nNNCVLFIXB := NNC->NNC_VLFIXB
		EndIF

		Do Case
			Case ( NNC->NNC_VRENPF + NNC->NNC_VLCMPL ) < nNNCVLFIXB
			If NNC->NNC_FORMUL=='S' 
				cStatus := '1'
			Else
				cStatus := '2'
			EndIf
			Case NNC->NNC_VRENPF + NNC->NNC_VLCMPL == nNNCVLFIXB 
			cStatus := '3'
			Case NNC->NNC_VRENPF <  nNNCVLFIXB .and. ( NNC->NNC_VRENPF + NNC->NNC_VLCMPL )== nNNCVLFIXB
			If NNC->NNC_FORMUL=='S' 
				cStatus := '4'
			Else
				cStatus := '7'
			EndIf
			Case NNC->NNC_VRENPF + NNC->NNC_VLCMPL >  nNNCVLFIXB  .and. !( (NNC->NNC_VRENPF + NNC->NNC_VLCMPL) - NNC->NNC_DECFIN  ) == nNNCVLFIXB
			cStatus := '5'
			Case NNC->NNC_VRENPF + NNC->NNC_VLCMPL >  nNNCVLFIXB  .and. ( (NNC->NNC_VRENPF + NNC->NNC_VLCMPL) - NNC->NNC_DECFIN  ) == nNNCVLFIXB
			cStatus := '6'
		EndCase

		RestArea( aAliasAtu )
		RestArea( aAliasNNC )

		If cPaisLoc = "PAR"
			Return ( '3' )
		Else
			Return ( cStatus )
		EndIf
	EndIF
Return ( nil)

/*{Protheus.doc} Og430IniEV
Funcao que inicializa o Cpo NN8_QtEnSV ( Qtidade de Entrega
Sem Vinculo ou a Vincular; 

@param     	nil	
@return    Qtidade de Entregas sem Vinculo ou a Vincular
@author    Emerson coelho
/*/
Function Og430IniEV()
	Local aAreaAtu	:= GetArea()
	Local aAreaNJR	:= NJR->(GetArea() )
	Local cCodCtr	:= IIF( IsInCallStack("OGR344") , NN8->NN8_CODCTR , FwfldGet('NN8_CODCTR') )    
	Local cAliasQry := GetNextAlias()
	Local lCtrCpra
	Local nQtEntAFix := 0
	Local cTpClass := NJR->NJR_CLASSP
	DbSelectArea('NJR')
	NJR->( DbSetOrder(1) )
	NJR->(DbSeek(fwXfilial('NJR') + cCodCtr ))


	IF NJR->NJR_TIPO == '1'			//Ctrato de Compra
		lCtrCpra	:= .t.	
	ElseIF NJR->NJR_TIPO == '2'		//Contrato de Venda
		lCtrCpra := .f.
	EndIF

	//--- Query para trazer os Contratos ---//
	BeginSql Alias cAliasQry

		SELECT NJR_FILIAL
		,NJR_TIPO
		,NJR_MODELO
		,NJR_STATUS
		,NJR_CODCTR
		,NJR_DESCRI
		,NJR_DATA
		,NJR.R_E_C_N_O_ AS NJR_RECNO
		,(SELECT MIN(NNY_DATINI) FROM %Table:NNY% NNY WHERE NNY.%notDel% AND NNY_FILIAL=NJR_FILIAL AND NNY_CODCTR=NJR_CODCTR) AS NNY_DATINI
		,(SELECT MAX(NNY_DATFIM) FROM %Table:NNY% NNY WHERE NNY.%notDel% AND NNY_FILIAL=NJR_FILIAL AND NNY_CODCTR=NJR_CODCTR) AS NNY_DATFIM
		,MAX(NJR_QTDCTR) as NJR_QTDCTR   
		,MAX(NJR_QTEFCO) as NJR_QTEFCO
		,MAX(NJR_QTEFIS) as NJR_QTEFIS
		,MAX(NJR_QTSFCO) as NJR_QTSFCO
		,MAX(NJR_QTSFIS) as NJR_QTSFIS
		,MAX(NJR_QTDRES) as NJR_QTDRES
		,MAX(NJR_QSLFCO) as NJR_QSLFCO
		,MAX(NJR_SLDFIS) as NJR_SLDFIS
		,SUM(NN8_QTDFIX) as NN8_QTDFIX
		,SUM(NN8_QTDENT) as NN8_QTDENT
		FROM %Table:NJR% NJR
		LEFT JOIN %Table:NN8% NN8  ON NN8.%notDel%
		AND NN8_FILIAL = %XFilial:NN8%
		AND NN8_CODCTR = NJR_CODCTR
		AND NN8_TIPOFX = '1'
		WHERE NJR.%notDel%
		AND NJR.NJR_FILIAL = %XFilial:NJR%
		/* 
		AND NJR_CODENT = %exp:NJR->NJR_CODENT%   
		AND NJR_LOJENT = %exp:NJR->NJR_LOJENT%  
		AND NJR_TIPO   = %exp:NJR->NJR_TIPO% 
		AND NJR_CODSAF = %exp:NJR->NJR_CODSAF%
		AND NJR_CODPRO = %exp:NJR->NJR_CODPRO%
		*/
		AND NJR.NJR_CODCTR =  %exp:NJR->NJR_CODCTR%
		GROUP BY  NJR_FILIAL,NJR_TIPO,NJR_MODELO,NJR_STATUS,NJR_CODCTR,NJR_DESCRI,NJR_DATA,NJR.R_E_C_N_O_

	EndSQL

	( cAliasQry )->( DbGotop() )

	if cTpClass == '1' //Fisica
		IF lCtrCpra
			nQtEntAFix:=	( cAliasQry )->(NJR_QTEFCO - NN8_QTDENT) //Quantidade Entrada Física
		Else
			nQtEntAFix:=	( cAliasQry )->(NJR_QTSFCO - NN8_QTDENT) //Quantidade Saída Física
		EndIF
	Else //Fiscal
		IF lCtrCpra
			nQtEntAFix:=	( cAliasQry )->(NJR_QTEFIS - NN8_QTDENT) //Quantidade Entrada Fiscal
		Else
			nQtEntAFix:=	( cAliasQry )->(NJR_QTSFIS - NN8_QTDENT) //Quantidade Saída Fiscal
		EndIF
	EndIf

	( cAliasQry )->( DbCloseArea() )

	RestArea( aAreaAtu )
	RestArea( aAreaNJR )
Return( nQtEntAFix )

/** {Protheus.doc} fListDocs()
Funcãl de chamada da rotina OGA430
que lista as NFS. de compl. emitidas 
ou vinculadas do ctrato,fixação e/ou romaneio
e item de romaneio selecionado no oMrkNNC

@param: 	nil.
@return:	ni.
@author: 	Emerson Coelho
@since: 	29/01/2015
@Uso: 		OGA430
*/

Static function fListDocs()

	Local cCodctr 	:= 	(_oBrwNNC:Alias())->NNC_CODCTR
	Local cItemFix 	:=	(_oBrwNNC:Alias())->NNC_ITEMFX
	Local cCodRom	:=	(_oBrwNNC:Alias())->NNC_CODROM
	Local cItemRom	:=	(_oBrwNNC:Alias())->NNC_ITEROM
	OGA430G(cCodCtr, cItemFix, ccodRom, cItemRom)

Return


