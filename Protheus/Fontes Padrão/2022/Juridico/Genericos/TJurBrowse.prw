#INCLUDE "PROTHEUS.CH"
#include "FWBrowse.ch"

#DEFINE HEADER_TITULO 1
#DEFINE HEADER_CAMPO 2
#DEFINE HEADER_PICTURE 3
#DEFINE HEADER_TAMANHO 4
#DEFINE HEADER_DECIMAL 5
#DEFINE HEADER_VALID 6
#DEFINE HEADER_USADO 7
#DEFINE HEADER_TIPO 8
#DEFINE HEADER_F3 9
#DEFINE HEADER_CONTEXT 10
#DEFINE HEADER_CBOX 11
#DEFINE HEADER_RELACAO 12
#DEFINE HEADER_WHEN 13
#DEFINE HEADER_VISUAL 14
#DEFINE HEADER_VLDUSER 15
#DEFINE HEADER_CAMPOORG 16
#DEFINE HEADER_INIBRW 17
#DEFINE HEADER_PICTVAR 18
#DEFINE HEADER_MRKCHECK 19
#DEFINE HEADER_MRKDBLCLK 20
#DEFINE HEADER_MRKHDRCLK 21
#DEFINE GRID_MOVEUP       0
#DEFINE GRID_MOVEDOWN     1
#DEFINE GRID_MOVEHOME     2
#DEFINE GRID_MOVEEND      3
#DEFINE GRID_MOVEPAGEUP   4
#DEFINE GRID_MOVEPAGEDOWN 5 

Static _lFwPDCanUse := FindFunction("FwPDCanUse")

//-------------------------------------------------------------------
Function __JurBrowse() // Function Dummy
ApMsgInfo( 'JurBrowse -> Utilizar Classe ao inves da funcao' )
Return NIL 

//-------------------------------------------------------------------
/*/{Protheus.doc} JurBrowse
CLASS TJurBrowse

@author André Spirigoni Pinto
@since 22/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TJurBrowse FROM FWBROWSE

  DATA aCols
  DATA aHeader
  DATA brClicked
  DATA bHeaderClick
  DATA nClicked
  DATA cOrder
  DATA cQuery
  DATA nCurLinha //linha atual do grid
  DATA oParent //objeto que contém o método gOnMove da movimentação do grid
  DATA lPagina //indica se a paginação está ativa ou não

  METHOD New (oParent) CONSTRUCTOR
  METHOD Activate ()
  METHOD setHeader (aHeader)
  METHOD setArray (aCols)
  METHOD clearColumns ()
  METHOD clearData ()
  METHOD SetRightClick(bData)
  METHOD RefreshRClick()
  METHOD SetHeaderClick(bData)
  METHOD RefreshHeaderClick()
  METHOD OrdenaColuna(nCol, nClicked)
  METHOD getHeader()
  METHOD setHeadTabSX3(cTabela)
  METHOD setCboxValue(cCbox, cValue)
  METHOD setX5Value(cTabela, cValue)
  METHOD setHeaderSX3(aCampos, aHead)
  METHOD montaSQL(aCampos,cTabPadrao)
  METHOD SetQuery(cQuery)
  METHOD SetDataQueryX3(aCampos,cTabPadrao)
  METHOD SetPaginacao(bChange)
  METHOD onMove(o,nMvType,nCurPos,nOffSet,nVisRows)
  METHOD runPaginacao(nLinha,lEnd)
  METHOD clearPaginacao()
  METHOD LineRefresh() 
  METHOD CreateColumn(nCt)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} JurBrowse
CLASS TJurBrowse

@author André Spirigoni Pinto
@since 22/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (oParent) CLASS TJurBrowse	
	_Super:New (oParent)
	
	Self:DisableReport()
	Self:DisableConfig()
	
	Self:aCols := {}
	Self:aHeader := {}
	Self:aColumns := {}
	
	Self:clearPaginacao() //zera os componentes da paginação
	
Return nil

METHOD Activate(lHeaderOrd) CLASS TJurBrowse
	
	Default lHeaderOrd := .T.
	
	_Super:Activate ()
	
	//Ordenação das colunas
	If lHeaderOrd
		Self:SetHeaderClick({|oBrw,nCol,Adim| Self:nClicked := Self:OrdenaColuna(nCol, Self:nClicked)})
	EndIf

Return nil

METHOD SetQuery(cQuery) CLASS TJurBrowse
	Local cSQL
	self:cQuery := cQuery
	
	If !Empty(self:cOrder)
		cSQL := cQuery + CRLF + self:cOrder
	Else
		cSQL := cQuery
	Endif
	
	_Super:SetQuery(cSQL)
	
Return Nil

METHOD SetDataQueryX3(aCampos,cTabPadrao) CLASS TJurBrowse
	_Super:SetDataQuery()
	//monta a query que será executada
	self:SetQuery(self:montaSQL(aCampos,cTabPadrao))
	//define o cabeçalho
	self:setHeaderSX3(aCampos)
	//ativa o browse
	//self:Activate()  // Retirado para não duplicar as colunas do grid da tela de Pesquisa
	self:UpdateBrowse()
	
	//habilita o grid
	self:Enable()	

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} setHeader
Método que atribui o array da colunas ao TGRID

@Param	aCols		Array com as colunas que serão exibidas no grid

@author André Spirigoni Pinto
@since 22/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD setHeader (aHeader) CLASS TJurBrowse
	Local nCt
	Local oColumn
	Local aColumns   := {} 
	Local aNoAccLGPD := {}
	Local aDisabLGPD := {}
	Local lOfuscate  := _lFwPDCanUse .And. FwPDCanUse(.T.)
	Local aCpos      := {}

	Self:aHeader := aClone(aHeader)

	aEval(Self:aHeader, { |h| aAdd(aCpos, h[16])})

	If lOfuscate
		aNoAccLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCpos)
		AEval(aNoAccLGPD, {|x| AAdd( aDisabLGPD, AllTrim(x:CFIELD))})
	EndIf	

	self:aColumns := {}
	self:aDefaultColumns := {}
	lOfuscate := Len(aDisabLGPD) > 0
	For nCt := 1 to Len(Self:aHeader)
		If Len(Self:aHeader[nCt]) > 18 .And. !Empty(Self:aHeader[nCt][19])
			oColumn := Self:AddMarkColumns(Self:aHeader[nCt][19], Self:aHeader[nCt][20], Self:aHeader[nCt][21])
		Else
			oColumn := Self:CreateColumn(nCt)

			If lOfuscate
				oColumn:SetObfuscateCol( aScan(aDisabLGPD, AllTrim(Self:aHeader[nCt][16])) > 0) 
			EndIf
			aAdd(aColumns,oColumn)

		EndIf
	Next

	self:SetColumns(aColumns)
	
	Self:Disable()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} setArray
Método que atribui o array das linhas ao grid

@Param	aCols		Array com os dados que serão exibidos no grid

@author André Spirigoni Pinto
@since 22/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD setArray (aCols) CLASS TJurBrowse

	aSize(Self:aCols,0)
	Self:aCols := aClone(aCols)
	_Super:SetArray(aCols)
	//Self:Activate()
	self:UpdateBrowse()	// Retirado para não duplicar os campos do grid da tela de pequisa de processo
	
	Self:Enable()
	
	Self:RefreshRClick()
	self:RefreshHeaderClick() 
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} clearData
Método que limpa as linhas e colunas do Grid

@author André Spirigoni Pinto
@since 22/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD clearData () CLASS TJurBrowse
Local nCt
self:SetArray({})
self:oBrowse:ClearRows()

For nCt := 1 to Len(Self:aHeader)
	Self:oBrowse:RemoveColumn(nCt)
Next

self:aHeader := aSize(Self:aHeader, 0)
self:aHeader := {}

self:aCols := aSize(Self:aCols, 0)
self:aCols := {}

//Mudança do nome da propriedade das colunas.
self:aColumns := aSize(Self:aColumns, 0)
self:aColumns := {}

self:nAt := 0

self:oBrowse:Refresh()
self:Refresh()
self:UpdateBrowse()

self:Disable()

Return NIl

//-------------------------------------------------------------------
/*/{Protheus.doc} SetRightClick
Método que atribui o evento do botão direito do mouse ao TGRID

@Param	bData		Bloco de código que deve ser atribuido

@author André Spirigoni Pinto
@since 22/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetRightClick(bData) CLASS TJurBrowse
	self:brClicked := bData
	self:RefreshRClick()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RefreshRClick
Método que atualiza o evento de botão direito do TGRID

@author André Spirigoni Pinto
@since 22/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD RefreshRClick() CLASS TJurBrowse
	self:oBrowse:brClicked := self:brClicked
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetHeaderClick
Método que atribui o evento de clique do header ao TGRID

@Param	bData		Bloco de código que deve ser atribuido

@author André Spirigoni Pinto
@since 22/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetHeaderClick(bData) CLASS TJurBrowse
	self:bHeaderClick := bData
	self:RefreshHeaderClick() 
Return	

//-------------------------------------------------------------------
/*/{Protheus.doc} RefreshHeaderClick
Método que atualiza o evento de clique do header do TGRID

@author André Spirigoni Pinto
@since 22/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD RefreshHeaderClick() CLASS TJurBrowse
	self:nClicked := 0
	self:oBrowse:SetHeaderClick(self:bHeaderClick)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OrdenaColuna
Método que ordena as colunas por ordem alfabética

@author André Spirigoni Pinto
@since 22/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD OrdenaColuna(nCol, nClicked) CLASS TJurBrowse
	Local nRet
	Local lQuery := self:DataQuery() //valida de esta no modo de query.
	Local nLinha := self:At()
	
	If nClicked == nCol
		If !lQuery
			if Self:lPagina //valida se o grid está paginado
				self:runPaginacao(0, .T.)
			Endif
			aSort(self:aCols, , , {|x,y| x[nCol] > y[nCol]})
		Else
			self:cOrder := "ORDER BY " + self:aHeader[nCol][HEADER_CAMPO] + " DESC "
			self:setQuery(self:cQuery)
		Endif
		  
		nRet := 0
	Else
		If !lQuery
			if Self:lPagina //valida se o grid está paginado
				self:runPaginacao(0,.T.)
			Endif
			aSort(self:aCols, , , {|x,y| x[nCol] < y[nCol]})
		Else
			self:cOrder := "ORDER BY " + self:aHeader[nCol][HEADER_CAMPO] + " ASC "
			self:setQuery(self:cQuery)
		Endif
		
		nRet := nCol
	EndIf
	self:Refresh()
	self:oBrowse:GoColumn(nCol)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getHeader()
Retorna o Array com os itens que compõe o título

@author André Spirigoni Pinto
@since 22/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getHeader() CLASS TJurBrowse
Return self:aHeader

//-------------------------------------------------------------------
/*/{Protheus.doc} setHeadTabSX3()
Cria o aHeader utilizando a função JGetSX3 a partir de uma tabela.

@author André Spirigoni Pinto
@since 17/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD setHeadTabSX3(cTabela) CLASS TJurBrowse
Local aHeader   := {}
Local lRet      := .T.

Default cTabela := ""

If !Empty(cTabela)
   aHeader := JGetSx3("X3_ARQUIVO == '"+cTabela+"' .And. X3_CONTEXT == 'R' .And. SX3->X3_BROWSE == 'S' .AND. X3USO( SX3->X3_USADO ) .AND. cNivel >= SX3->X3_NIVEL", ;
                     {"X3_TITULO","X3_CAMPO","X3_PICTURE","X3_TAMANHO","X3_DECIMAL","X3_VALID","X3_USADO","X3_TIPO","X3_F3","X3_CONTEXT","X3_CBOX","X3_RELACAO",;
                      "X3_WHEN","X3_VISUAL","X3_VLDUSER","X3_CAMPO","X3_INIBRW","X3_PICTVAR"})
EndIf

If !Empty(aHeader)
	self:SetHeader(aHeader)	
Else
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} setCboxValue()
Trata o valor das colunas quando são do tipo lista de opções.

@param cCbox lista de opções
@param cValue Valor preenchido.

@return cValor Retorna a descrição do valor da lista de opções.

@author André Spirigoni Pinto
@since 17/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD setCboxValue(cCbox, cValue) CLASS TJurBrowse
Local cValor := ''
Local aTemp  := {}
Local nCti

If ( !Empty(cCbox) )

	aTemp := StrTokArr(cCbox,';')

	If (Len(aTemp) > 0)
		For nCti := 1 To Len(aTemp)
			aTemp[nCti] := StrTokArr(aTemp[nCti], '=')
		Next
	
		nI:= aScan( aTemp, { |aX| aX[1] == cValue } ) // Resgata a informação de campos combo
	
		If nI > 0
			cValor := aTemp[nI][2]
		Else
			cValor := cValue
		EndIf
	EndIf

EndIf

//Limpa o array
aSize(aTemp,0)

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} setX5Value()
Trata o valor das colunas quando possuem origem no X5.

@param cTabela tabela da X5
@param cValue Valor preenchido.

@return cValor Retorna a descrição do valor da tabela do X5

@author André Spirigoni Pinto
@since 17/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD setX5Value(cTabela, cValue) CLASS TJurBrowse
Local cValor := ''

If !Empty(FWGetSX5(AllTrim(cTabela)))
 //Preenche valor a partir do SX5
	cValor := Posicione("SX5", 1, XFILIAL("SX5") + AllTrim(cTabela) + cValue, "X5_DESCRI")
EndIf

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} setHeaderSX3()
Função que preenche as colunas com informações da SX3.

@param aCampos Array com os campos da consulta.
@param aHead Array com valores iniciais

@return lRet Retorna .T. ou .F. depoendendo do sucesso da operação.

@author André Spirigoni Pinto
@since 23/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD setHeaderSX3(aCampos, aHead) CLASS TJurBrowse
Local lRet    := .T.
Local nI
Local aArea   := GetArea()
Default aHead := {}

dbSelectArea('SX3')
SX3->( dbSetOrder(2) )

For nI := 1 to LEN(aCampos)
	If SX3->( dbSeek(AllTrim(StrTran( aCampos[nI][1], "''", "" ) ) ) )		
		
		aAdd( aHead, { ;
		AllTrim(aCampos[nI][2]), ;  // 01 - Titulo
		AllTrim(aCampos[nI][8])     , ;    // 02 - Nome Query
		(IIF( aCampos[nI][1] == "A1_CGC", " ", SX3->X3_PICTURE )),;  // 03 - Picture  
		SX3->X3_TAMANHO    , ;    // 04 - Tamanho
		SX3->X3_DECIMAL    , ;    // 05 - Decimal
		SX3->X3_VALID      , ;    // 06 - Valid
		SX3->X3_USADO      , ;    // 07 - Usado
		SX3->X3_TIPO       , ;    // 08 - Tipo
		SX3->X3_F3         , ;    // 09 - F3
		SX3->X3_CONTEXT    , ;    // 10 - Contexto
		X3Cbox()           , ;    // 11 - ComboBox
		SX3->X3_RELACAO    , ;    // 12 - Relacao
		SX3->X3_WHEN       , ;    // 13 - Alterar
		SX3->X3_VISUAL     , ;    // 14 - Visual
		SX3->X3_VLDUSER    , ;    // 15 - Valid Usuario
		SX3->X3_CAMPO	   , ;    // 16 - Nome original campo
		SX3->X3_INIBRW	   , ;    // 17 - Ini Browse		
		(IIF( aCampos[nI][1] == "A1_CGC", " ", SX3->X3_PICTVAR )), ;    // 18 - Picture Variavel
		                            , ;    // 19 - Mark Column - Check
		                            , ;    // 20 - Mark Column - DoubleClick
		                            } )    // 21 - Mark Column - HeaderClick
	EndIf
Next

RestArea(aArea)

Self:setHeader(aHead)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} montaSQL(aCampos,aManual,cTab)
Função que preenche as colunas com informações da SX3.

@param aCampos Array com os campos da consulta.
@param aHead Array com valores iniciais

@return lRet Retorna .T. ou .F. depoendendo do sucesso da operação.

@author André Spirigoni Pinto
@since 10/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD montaSQL(aCampos, cTabPadrao) CLASS TJurBrowse
Local cRet := ''
Local aTmp := {}
Local cTmp := ''
Local nCt
Local cTmpTabela
Local cTmpApelido
Local aSX9 := {}
Local aTmpTab1 := {}
Local aTmpTab2 := {}
Local nCtr
Local cApTab1
Local cApTab2
Local cCampos := ''
Local cSQL := ''
Local aWhere := {}
Local aFilUsr := {}

aFilUsr := JURFILUSR( __CUSERID, cTabPadrao )

For nCt := 1 to Len(aCampos)

	//Verifica se a tabela não é obrigatória e inclui o default do campo
	If Len(aCampos[nCt]) >= 10 .And. !aCampos[nCt][9]
		cCampos += "COALESCE(" + AllTrim(aCampos[nCt][4])+"."+AllTrim(aCampos[nCt][1]) + ", " + aCampos[nCt][10] + ") " + AllTrim(aCampos[nCt][1]) + ", "
	Else
		cCampos += AllTrim(aCampos[nCt][4])+"."+AllTrim(aCampos[nCt][1]) + ","
	EndIf

Next nCt

//retira a vírgula do final
cCampos := Left(cCampos,Len(cCampos)-1)

cSQL := " SELECT " + cCampos + CRLF
cSQL += " FROM " + RetSqlName(cTabPadrao) + " " + cTabPadrao + "001 "

cRet := cSQL

//Campos selecionados

For nCt := 1 to Len(aCampos)
	//valida tabela
	cTmpTabela := Alltrim(RetSqlName(aCampos[nCt][3]))
	cTmpApelido := AllTrim(aCampos[nCt][4]) 
	If (At(cTmpTabela + " " + cTmpApelido,cRet) == 0)//valida a tabela
			
		aSx9 := JURSX9(aCampos[nCt][6],aCampos[nCt][3])
		
		//não é a primeira ocorrência, assim, será preciso adicionar a tabela no sql
		cTmp += IIF(aCampos[nCt][9]," "," LEFT") + " JOIN "+cTmpTabela+" "+cTmpApelido+" ON " + CRLF
		cTmp += "                ("
		
		If Len(aSx9)>0
			aTmpTab1 := StrTokArr(aSX9[1][1], '+')
			aTmpTab2 := StrTokArr(aSX9[1][2], '+')
						
			For nCtr := 1 to Len(aTmpTab1)
				//Determina o apelido que deve ser usado. A função IIF valida se a tabela é do tipo SA1, onde o nome do campo é A1_ por exemplo
				If IIf(At('_',Left(aTmpTab1[nCtr],3))>0,'S'+Left(aTmpTab1[nCtr],2),Left(aTmpTab1[nCtr],3)) == aCampos[nCt][3]
					cApTab1 := aCampos[nCt][4]
					cApTab2 := aCampos[nCt][7]
				Else
					cApTab1 := aCampos[nCt][7]
					cApTab2 := aCampos[nCt][4]
				Endif
			
				cTmp += cApTab1 + "." + AllTrim(aTmpTab1[nCtr]) + ;
				" = " + cApTab2 + "." + AllTrim(aTmpTab2[nCtr]) + " AND "
			Next
			
			cTmp := Left(cTmp,Len(cTmp)-5) + CRLF
			
		Endif
			//valida se existe filtro
			If !Empty(aCampos[nCt][5])
				//valida se existia algo no sx9
				cTmp += IIF(RIGHT(AllTrim(cTmp),1)=='(','',"               AND ") + AllTrim(aCampos[nCt][5])
			Endif
			
			cTmp += " AND " + cTmpApelido +".D_E_L_E_T_ = ' ' AND " + cTmpApelido + "." + AllTrim(aCampos[nCt][3]) + "_FILIAL='" + FwxFilial(Left(cTmpTabela,3)) + "')" + CRLF
		
		aSX9 := {}
		
		If At(IIF(cApTab2!=Nil,cApTab2,cTmpTabela)+" ",cTmp) == 0
			aAdd(aTmp,cTmp)
		Else
			cRet += cTmp
		Endif
		
		cTmp := ''
	Else //valida se existe filtro na tabela.
		If !Empty(AllTrim(aCampos[nCt][5]))
			If At(AllTrim(aCampos[nCt][5]),cTmp)==0
				aAdd(aWhere,AllTrim(aCampos[nCt][5]))
			Endif
		Endif
	Endif //valida tabela
Next

//Inclui os relacionamentos que devem ficar por último
For nCt := 1 to Len(aTmp)
	If At(aTmp[nCt],cRet) == 0
		cRet += aTmp[nCt]
	Endif
Next

If ( VerSenha(114) .or. VerSenha(115) ) 
	cRet += " WHERE " + cTabPadrao + "001." + cTabPadrao + "_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2]) 
Else
	cRet += " WHERE " + cTabPadrao + "001." + cTabPadrao + "_FILIAL = '" + xFilial(cTabPadrao)+"'" +  CRLF
Endif

//parte do where
For nCt := 1 to Len(aWhere)
	If At(aWhere[nCt],cRet)==0
		cRet += CRLF + " AND " + aWhere[nCt]
	Endif 
NExt

Return cRet //Retorna cRet que é a junção do cSQL e cTmp

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPaginacao(bChange)
Método que recebe o bloco que deverá ser executado ao mudar de linhas

@param oParent Objeto que contém o método gOnMove que será acionado nas movimentações do grid.

@author André Spirigoni Pinto
@since 22/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetPaginacao(oParent) CLASS TJurBrowse
Self:oParent := oParent
Self:lPagina := .T.
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} onMove(o,nMvType,nCurPos,nOffSet,nVisRows)
Override do método onMove para  

@param bChange Bloco que deve ser chamado

0 GRID_MOVEUP Move uma linha para cima.
1 GRID_MOVEDOWN Move uma linha para baixo.
2 GRID_MOVEHOME Move para o topo da base de dados.
3 GRID_MOVEEND Move para o fim da base de dados.
4 GRID_MOVEPAGEUP Move uma página de dados para cima.
5 GRID_MOVEPAGEDOWN Move uma página de dados para baixo.

@author André Spirigoni Pinto
@since 22/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD onMove(o,nMvType,nCurPos,nOffSet,nVisRows) CLASS TJurBrowse

if Self:oParent != Nil .And. self:lPagina
	if nMvType == GRID_MOVEUP 
	    Self:nCurLinha -= nOffSet
	elseif nMvType == GRID_MOVEDOWN      
	    Self:nCurLinha += nOffSet
	elseif nMvType == GRID_MOVEHOME          
	    Self:nCurLinha :=0
	elseif nMvType == GRID_MOVEEND
	    Self:nCurLinha := len(self:aCols)
	elseif nMvType == GRID_MOVEPAGEUP
	    Self:nCurLinha -= (nVisRows + nOffSet)
	elseif nMvType == GRID_MOVEPAGEDOWN
	    Self:nCurLinha += (nVisRows + nOffSet)
	endif
	
	if Self:nCurLinha < 0
		Self:nCurLinha := 0
	Endif
	
	self:runPaginacao(Self:nCurLinha,(nMvType == GRID_MOVEEND))
Endif

//chama o método padrão de movimentação do grid
_Super:onMove(o,nMvType,nCurPos,nOffSet,nVisRows)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} onMove(o,nMvType,nCurPos,nOffSet,nVisRows)
Override do método onMove para  

@param nLinha Linha posicionada no Browse
@param lEnd Indica se o usuário solicitou o final do grid ou não

@author André Spirigoni Pinto
@since 22/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD runPaginacao(nLinha,lEnd) CLASS TJurBrowse
//Chama o método da classe que instanciou o TJURBROWSE.
Eval({|nLinha,lEnd| self:oParent:gOnMove(nLinha,lEnd) },nLinha,lEnd)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} onMove(o,nMvType,nCurPos,nOffSet,nVisRows)
Zera as configurações da classe de paginação.  

@author André Spirigoni Pinto
@since 22/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD clearPaginacao() CLASS TJurBrowse
Self:oParent := Nil
Self:lPagina := .F.
Self:nCurLinha := 0
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LineRefresh()
cria o metodo LineRefresh na classe TJurBrowse para chamar o método padrão da FWBROWSE  

@author leandro.silva
@since 20/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD LineRefresh(nAt) CLASS TJurBrowse
      If self:nAt <= len(self:acols) .Or. self:lDataQuery .Or. self:lDataTable .Or. self:lDataText
            _Super:LineRefresh(nAt)          //chama o metodo contido na classe Pai FWBROWSE
	Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateColumn(nCt)
Cria a coluna do Grid

@author Willian.Kazahaya
@since 25/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD CreateColumn(nCt) CLASS TJurBrowse
Local oColumn
Local aTemp 	:= {}
Local lQuery 	:= self:DataQuery()
Local cBrwIni 	:= ""
Local nChave 	:= 0
Local nChaveOld	:= 0
Local acPadrao 	:= {{"NTA->NTA_CAJURI", "NSZ_COD"},{"NSZ->NSZ_COD", "_CAJURI"},{"NT4->NT4_CAJURI", "NSZ_COD"},{"NT2->NT2_CAJURI", "NSZ_COD"}}
Local nCi
Local nChavTemp

	ADD COLUMN oColumn ;
	PICTURE Self:aHeader[nCt][HEADER_PICTURE] ;
	SIZE Self:aHeader[nCt][HEADER_TAMANHO] OF self:oBrowse

	oColumn:SetAutoSize(.T.)

	//se for query, a função é diferente
	If Self:DataQuery() .Or. Self:DataTable()
		oColumn:SetData(&('{ || ' + AllTrim(Self:aHeader[nCt][HEADER_CAMPOORG]) + ' }' ))
	Else
		oColumn:SetData(&('{ || Self:aCols[Self:At()][' + AllTrim(str(nCt)) + '] }' ))
	Endif

	oColumn:SetTitle(Self:aHeader[nCt][HEADER_TITULO])

	Do Case
	//Campos virtuais
	Case Self:aHeader[nCt][HEADER_CONTEXT] == "V" .And. !Empty(Self:aHeader[nCt][HEADER_TITULO])
		cBrwIni := Self:aHeader[nCt][HEADER_INIBRW]

		//busca se existe campo do inicializador do browse no grid.
		nChave := aScan(Self:aHeader,{|x| At(AllTrim(x[HEADER_CAMPOORG]), cBrwIni) > 0},2)
		nChaveOld := nChave
		While nChave > 0 //procura por XXX->XXX_CAMPO
			cBrwIni := strTran(cBrwIni,Left(AllTrim(Self:aHeader[nChave][HEADER_CAMPOORG]),3) + "->" + AllTrim(Self:aHeader[nChave][HEADER_CAMPOORG]),'Self:aCols[Self:At()][' + AllTrim(str(nChave)) + ']')
			nChave := aScan(Self:aHeader,{|x| At(AllTrim(x[HEADER_CAMPOORG]), cBrwIni) > 0},2)
			if (nChave == nChaveOld) //se a chave for igual, a substituição não está dando certo
				nChave := -1
			Else
				nChaveOld := nChave
			Endif
		End

		//acPadrao := {{"_CAJURI", "NSZ_COD"},{"NSZ->NSZ_COD", "_CAJURI"}}
		if At("->", cBrwIni) > 0 //faz nova tentativa, usando substituições padrão.
			nCi := 1
			While nCi <= len(acPadrao)
				If At(acPadrao[nCi][1],cBrwIni) > 0
					nChavTemp := aScan(Self:aHeader,{|x| At(acPadrao[nCi][2],AllTrim(x[HEADER_CAMPOORG])) > 0},2)
					if nChavTemp > 0
						cBrwIni := strTran(cBrwIni,acPadrao[nCi][1],'Self:aCols[Self:At()][' + AllTrim(str(nChavTemp)) + ']')
					endif
				Endif
				nCi++
			End
		Endif

		if !Empty(cBrwIni) .And. nChave > -1 .And. At("->", cBrwIni) == 0
			oColumn:SetData(&('{ || ' + cBrwIni + '}' ))
		Else
			oColumn:SetData({ || "---"})
			oColumn:SetAlign("CENTER")
		Endif

		If Self:aHeader[nCt][HEADER_TAMANHO] <= 10
			oColumn:SetAlign("CENTER")
		Endif

	Case Self:aHeader[nCt][HEADER_TIPO] == "N"
		oColumn:SetAlign("RIGHT")

	Case Self:aHeader[nCt][HEADER_TIPO] == "M"
		oColumn:SetType("C")
		oColumn:SetSize(8)
		oColumn:SetData({ || "Memo"})

	Case Self:aHeader[nCt][HEADER_TIPO] == "L"
		oColumn:SetType("C")
		oColumn:SetDecimal(0)
		oColumn:SetImage(.T.)
		oColumn:SetAlign("CENTER")
	Case Self:aHeader[nCt][HEADER_TIPO] == "D"
		oColumn:SetAlign("CENTER")
		oColumn:SetType("D")
		If !lQuery
			oColumn:SetData(&('{ || DtoC(StoD(Self:aCols[Self:At()][' + AllTrim(str(nCt)) + '])) }' ))
		Else
			oColumn:SetData(&('{ || DtoC(StoD(' + AllTrim(Self:aHeader[nCt][HEADER_CAMPOORG]) + ')) }' ))
		Endif

	EndCase

	If UPPER(Self:aHeader[nCt][HEADER_PICTURE]) = "@BMP"
		oColumn:SetImage(.T.)
		oColumn:SetAlign("CENTER")
	EndIf

	If ( !Empty(Self:aHeader[nCt][HEADER_CBOX]) .And. Len(StrTokArr(Self:aHeader[nCt][HEADER_CBOX],';')) > 0 )
		If lQuery
			oColumn:SetData(&('{ || Self:setCboxValue("' + Self:aHeader[nCt][HEADER_CBOX] + '",' + AllTrim(Self:aHeader[nCt][HEADER_CAMPOORG]) + ') }' ))
		Else
			oColumn:SetData(&('{ || Self:setCboxValue("' + Self:aHeader[nCt][HEADER_CBOX] + '",Self:aCols[Self:At()][' + AllTrim(str(nCt)) + ']) }' ))
		Endif
	Endif

	If !Empty(FWGetSX5(AllTrim(Self:aHeader[nCt][HEADER_F3])))
		If lQuery
			oColumn:SetData(&('{ || Self:setX5Value("' + Self:aHeader[nCt][HEADER_F3] + '",' + AllTrim(Self:aHeader[nCt][HEADER_CAMPOORG]) + ') }' ))
		Else
			oColumn:SetData(&('{ || Self:setX5Value("' + Self:aHeader[nCt][HEADER_F3] + '",Self:aCols[Self:At()][' + AllTrim(str(nCt)) + ']) }' ))
		Endif
	Endif

Return oColumn
