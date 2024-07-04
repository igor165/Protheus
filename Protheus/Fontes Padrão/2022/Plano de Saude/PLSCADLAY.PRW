#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA809
Tela para cadastro e gerenciamento de Layouts no portal (paginas/cadastros)
@author Rogério Tabosa
@since 23/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSCADLAY()
Local oBrowse


oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B90')
oBrowse:SetDescription("Layout Portal")
			
oBrowse:Activate()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Rogério Tabosa
@since 23/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {}

Add Option aRotina Title 'Visualizar' Action 'VIEWDEF.PLSCADLAY' Operation 2 Access 0
Add Option aRotina Title 'Incluir'    Action 'VIEWDEF.PLSCADLAY' Operation 3 Access 0
Add Option aRotina Title 'Alterar'    Action 'VIEWDEF.PLSCADLAY' Operation 4 Access 0
Add Option aRotina Title 'Excluir'    Action 'VIEWDEF.PLSCADLAY' Operation 5 Access 0
Add Option aRotina Title 'Imprimir'   Action 'VIEWDEF.PLSCADLAY' Operation 8 Access 0
Add Option aRotina Title 'Copiar'     Action 'VIEWDEF.PLSCADLAY' Operation 9 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Rogério Tabosa
@since 23/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel // Modelo de dados construído
// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que irá considerar
Local oStrB90 := FWFormStruct(1,'B90',  )
Local oStrB7C := FWFormStruct(1,'B7C',  ) 
Local oStrB91 := FWFormStruct(1,'B91',  )
Local oStrB2C := FWFormStruct(1,'B2C',  )

// Cria o objeto do Modelo de Dados e insere a funçao de pós-validação
oModel := MPFormModel():New( 'PLSCADLAY',{|| PLCADLAPRE(oModel,1) } ,{|| PLCADLAPRE(oModel,2) } )

// Adiciona ao modelo um componente de formulário
oModel:addFields('MasterB90',/*cOwner*/,oStrB90)  

// Adiciona ao modelo uma componente de grid
oModel:AddGrid('B7CDetail', 'MasterB90', oStrB7C)

// Adiciona ao modelo uma componente de grid 
oModel:AddGrid('B91Detail', 'B7CDetail', oStrB91,,{ |oModelGrid| B91PosValid(oModelGrid) }) 

// Adiciona ao modelo uma componente de grid 
oModel:AddGrid('B2CDetail', 'B91Detail', oStrB2C) 

//oModel:GetModel('B9QDetail'):SetOptional(.T.) //Torna o preenchimento da Grid opicional
// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'B7CDetail', { { 'B7C_FILIAL', 'xFilial( "B7C" )' } , { 'B7C_SEQB90', 'B90_SEQUEN' } },B7C->( IndexKey( 2 ) ) )  
oModel:SetRelation( 'B91Detail', { { 'B91_FILIAL', 'xFilial( "B91" )' } , { 'B91_SEQUEN', 'B7C_SEQB90' } , { 'B91_GRUPO', 'B7C_ORDEM' } },B91->( IndexKey( 1 ) ) ) 
oModel:SetRelation( 'B2CDetail', { { 'B2C_FILIAL', 'xFilial( "B2C" )' } , { 'B2C_SEQB90', 'B91_SEQUEN' } , { 'B2C_CMPB91', 'B91_NOMXMO' } },B2C->( IndexKey( 2 ) ) )

oModel:GetModel( 'B2CDetail' ):SetOptional( .T. )
//Nao deixa cadastrar dois registros iguais 
//oModel:GetModel( 'B9QDetail' ):SetUniqueLine( { 'B9Q_CODESP' } ) 
//oModel:GetModel( 'B9VDetail' ):SetUniqueLine( { 'B9V_CODSEQ', 'B9V_CODPRO', 'B9V_CIDADE', 'B9V_ENDER'} ) 

 // Adiciona a descrição do Modelo de Dados										
oModel:SetDescription("Cadastro Layout WEB")


Return oModel // Retorna o Modelo de dados
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Karine Riquena Limp
@since 28/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

 // Interface de visualização construída
Local oView 

// Carrega o model existente
Local oModel := FWLoadModel( 'PLSCADLAY' )

// Cria as estruturas a serem usadas na View 
Local oStrB90:= FWFormStruct(2, 'B90')
Local oStrB7C:= FWFormStruct(2, 'B7C', { |cCampo| cCampo <> "B7C_TIPGUI" .AND. cCampo <> "B7C_TISVER"} )
Local oStrB91:= FWFormStruct(2, 'B91')
Local oStrB2C:= FWFormStruct(2, 'B2C', { |cCampo| cCampo <> "B2C_CMPB91" .AND. cCampo <> "B2C_SEQB90" .AND. cCampo <> "B2C_CODSEQ"})

oView := FWFormView():New() // Cria o objeto de View

// Define qual Modelo de dados será utilizado
oView:SetModel(oModel)

// Adiciona nas views um controle do tipo formulário 
oView:AddField('ViewB90' , oStrB90,'MasterB90' ) 
oView:AddGrid( 'ViewB7C' , oStrB7C,'B7CDetail' ) 
oView:AddGrid( 'ViewB91' , oStrB91,'B91Detail' ) 
oView:AddGrid( 'ViewB2C' , oStrB2C,'B2CDetail' ) 

//Adiciona Campo incremental na View
//oView:AddIncrementField( 'ViewB90' , 'B90_SEQUEN') 
 
// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 25 ) 
oView:CreateHorizontalBox( 'INFERIOR1', 30 ) 
oView:CreateHorizontalBox( 'INFERIOR2', 45 )
//Cria os "boxes" com as duas grids dentro
//oView:CreateVerticalBox( 'A', 100,,, 'MEIO', 'T1'  ) 

oView:CreateVerticalBox( 'VERTICAL1', 75, 'INFERIOR2')
oView:CreateVerticalBox( 'VERTICAL2', 25, 'INFERIOR2')

//Atribui a cada view os respectivos "box" criados acima
oView:SetOwnerView('ViewB90','SUPERIOR') 
oView:SetOwnerView('ViewB7C','INFERIOR1')
oView:SetOwnerView('ViewB91','VERTICAL1') 
oView:SetOwnerView('ViewB2C','VERTICAL2')

oStrB7C:SetProperty( 'B7C_ORDEM'  , MVC_VIEW_ORDEM, "02" )
oStrB7C:SetProperty( 'B7C_ALIAS'  , MVC_VIEW_ORDEM, "03" )

//Atribui título para as Views de detalhe
oView:EnableTitleView( 'ViewB7C', 'Grupos de campos') 
oView:EnableTitleView( 'ViewB91', 'Campos') 
oView:EnableTitleView( 'ViewB2C', 'Configuração complementar') 

oView:SetFieldAction('B7C_ALIAS', { |oView| PLSCLY001(oView, oModel)}) //Carrega grid de campos ao preencher o alias

Return oView 


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCLY001
Funcao que preenche os campos do SX3 de acordo com o alias preenchido (facilitador)
@author Rogério Tabosa
@since 20/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSCLY001(oView, oModel)

LOCAL oModelMaster	:= oModel:GetModel( 'MasterB90' )
LOCAL oB7C		     	:= oModel:GetModel( 'B7CDetail' ) 
LOCAL oB91         	:= oModel:GetModel( 'B91Detail' )
LOCAL cAliasNew 		:= AllTrim(oB7C:GetValue('B7C_ALIAS'))
LOCAL aArea   		:= GetArea()
LOCAL cSequen			:= "000"

LOCAL nCountB91      := oB91:Length()


If MsgYesNo("Deseja carregar os campos da tabela [" + cAliasNew + "] ?")
	
	//Pego os endereços que tem os codigos encontrados acima
	SX3->(DbSelectArea("SX3"))
	SX3->(DbSetOrder(1))
				
	If SX3->(MsSeek(cAliasNew))
		While (SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == cAliasNew)						
			//Pego a descrição da cidade e do logradouro
			

			oB91:AddLine()
			nCountB91 ++
						
			oB91:Goline( nCountB91 )
			
			cSequen := soma1(cSequen)
			oB91:SetValue("B91_FILIAL"	, xFilial("B91"))
			oB91:SetValue("B91_CAMPO"	, SX3->X3_CAMPO)
			oB91:SetValue("B91_NOMXMO"  , Lower(SX3->X3_TIPO) + SX3->X3_CAMPO)
			oB91:SetValue("B91_EDITAR"	, SX3->X3_VISUAL <> "V" )
			oB91:SetValue("B91_OBRIGA"	, X3Obrigat(SX3->X3_CAMPO) ) 
			oB91:SetValue("B91_VISUAL"	, X3USO(SX3->X3_USADO))
			oB91:SetValue("B91_TAMANH"	, SX3->X3_TAMANHO )
			oB91:SetValue("B91_TIPO" 	, IIf(!Empty(SX3->X3_CBOX), "G", SX3->X3_TIPO) ) // C=Texto;M=Memo;G=Combo;N=Numerico
			oB91:SetValue("B91_GRUPO"   , oB7C:GetValue("B7C_ORDEM") )
			oB91:SetValue("B91_CBOX" 	, Alltrim(SX3->X3_CBOX) )
			oB91:SetValue("B91_DESCRI" 	, Alltrim(SX3->X3_TITULO) )
			oB91:SetValue("B91_ORDEM"	, Alltrim(SX3->X3_ORDEM) )
			oB91:SetValue("B91_VIRTUA"  , SX3->X3_CONTEXT == "V" )
			//oB91:SetValue("B91_SEQUEN"	, oModelMaster:GetValue('B90_SEQUEN') )
			SX3->(DbSetOrder(1)) //precisou ser forçada a ordem do campo pq quando passa no setvalue do B91_NOMXMO a ordem troca para 2.	
			SX3->(DbSkip())
			
		EndDo	
	EndIf
						
	SX3->(DbCloseArea())
	oB91:Goline( 1 )
	oView:Refresh()
EndIf	
			
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLGRVLWEB
Grava os dados do layout web generico
@author Rogério Tabosa
@since 20/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLGRVLWEB(cChave, aDados, cRecnus, cRecnoReg, lWeb)
//Formato do adados (Versão de 10/07/2015)
//[X][Y]
//[X]		= Posição	
//[X][1]	= Alias
//[X][2]	= Campo (variável do portal)
//[X][3]	= Valor (após alterar)
//[X][4]	= Sequencial da Grid (
//[X][5]	= Booleano (Define se altera o outro booleano)
//[X][6]	= Campo (Tabela)
//[X][7]	= RECNO

Local aArea 	:= GetArea()
Local nI		:= 0
Local nL		:= 0
Local nJ		:= 0
Local aTable	:= {}
Local cAliAtu	:= ""
Local lUpd		:= .F.
Local lRet		:= .F.
Local cTpCpo	:= ""
Local cSeq		:= ""
Local aCpoOut	:= {}
Local lUnlock	:= .T.
Local lSxEnum := .F. 
Local lB91		:= .F.
Local nTaDados	:= Len(aDados)
Local aRecno		:= {}

Default cChave := ""
Default cRecnus := ""
Default cRecnoReg := ""
Default lWeb := .F.

If cChave == "PPLALTSOL"
	Return .T.
EndIf

B90->(DbSetOrder(2))
B90->(MsSeek(xFilial("B90") + cChave))

B7C->(DbSetOrder(2))
B7C->(MsSeek(xFilial("B7C") + B90->B90_SEQUEN ))

While !B7C->(Eof()) .AND. xFilial("B7C") + B7C->B7C_SEQB90 == xFilial("B7C") + B90->B90_SEQUEN 
	AADD(aTable, { B7C->B7C_ALIAS, B7C->B7C_ORDEM , B7C->B7C_GRUPAI, B7C->B7C_TIPO} )
	B7C->(DbSkip())					 
EndDo

For nI := 1 To Len(aTable)
	//Variaveis de controle por tabela
	cSeq := ""
	aCpoOut := {}
	lSxEnum := .F.
	cAliAtu := aTable[nI, 1]
	
	// Aqui eu guardo todos os campos que nao foram exibidos no portal e precisam ser gravados (Ex.: Codigo relacionado, combos com valor padrão)
	B91->(DbSetOrder(1))
	B91->(MsSeek(xFilial("B91") + B90->B90_SEQUEN + aTable[nI, 2] ))
	While !B91->(Eof()) .AND. xFilial("B91") + B91->B91_SEQUEN + B91->B91_GRUPO == xFilial("B91") + B90->B90_SEQUEN + aTable[nI, 2]
		If !B91->B91_VISUAL .AND. (!Empty(B91->B91_DADSRV) .OR. B91->B91_TIPO == "S")// esse campo sera executado macro para pegar o valor
			AADD(aCpoOut, {B91->B91_CAMPO, B91->B91_DADSRV, B91->B91_TIPO})						
		EndIf
		B91->(DbSkip()) 
	EndDo
	
	// reposiciono no inicio para nao perder a referencia
	B91->(DbSetOrder(1))
	If B91->(MsSeek(xFilial("B91") + B90->B90_SEQUEN + aTable[nI, 2] ))
		
		If  aTable[nI, 4] <> "G" // se nao for grid só vou passar uma vez entao posso dar reclock somente aqui			
			cSeq := ""
			
			if nTaDados > 0
				If (Len(aDados[nI]) >= 7 .AND. Valtype(aDados[nI][7]) == "N" .AND. aDados[nI][7] > 0)
					lUpd := .T.
					&(cAliAtu)->(DbGoTo(aDados[nI][7]))
				else
					lUpd := .F.
				EndIF
				
				&(cAliAtu)->(RecLock(cAliAtu, !lUpd))
				If lGrvDadServ
					&(cAliAtu+"->" + cAliAtu + "_FILIAL") :=  xFilial(cAliAtu)			
				EndIf
			EndIf
		EndIf			
		
		For nL := 1 To nTaDados
			If aDados[nL,1] <> cAliAtu
				Loop
			EndIf
			B91->(DbSetOrder(1))
			If B91->(MsSeek(xFilial("B91") + B90->B90_SEQUEN + aTable[nI, 2] + aDados[nL,2] ))
				lB91 := .T.
			Else
				lB91 := .F.
			EndIf
				
			If  aTable[nI, 4] == "G" // se for grid e mudou de linha eu gravo		

				If  aTable[nI, 4] == "G" .AND. cSeq <>  aDados[nL,4] .AND. !Empty(cSeq)   // se nao for grdi só vou passar uma vez entao posso dar reclock somente aqui	
					// Gravo os campos que tem função para gravação no servidor fora do js e htm						
					For nJ := 1 To Len(aCpoOut)							
						&(cAliAtu+"->" + aCpoOut[nJ,1]) :=  &(aCpoOut[nJ,2])							
					Next nJ
					&(cAliAtu)->(MsUnlock())	

					If	(Len(aDados[nL]) >= 7 .AND. Valtype(aDados[nL][7]) == "N" .AND. aDados[nL][7] > 0)
						lUpd := .T.
						&(cAliAtu)->(DbGoTo(aDados[nL][7]))
					else
						lUpd := .F.
					EndIF
											
					&(cAliAtu)->(RecLock(cAliAtu, !lUpd))
					&(cAliAtu+"->" + cAliAtu + "_FILIAL") :=  xFilial(cAliAtu)
				//GRAVA O CABEÇALHO AQUI
				ElseIf Empty(cSeq)
				
					If	(Len(aDados[nL]) >= 7 .AND. Valtype(aDados[nL][7]) == "N" .AND. aDados[nL][7] > 0)
						lUpd := .T.
						&(cAliAtu)->(DbGoTo(aDados[nL][7]))
					else
						lUpd := .F.
					EndIF
					
					&(cAliAtu)->(RecLock(cAliAtu, !lUpd))
					&(cAliAtu+"->" + cAliAtu + "_FILIAL") :=  xFilial(cAliAtu)						
				EndIf
				cSeq := aDados[nL,4]						
			EndIf
			lRet := .T.	
			
			//Verifica se o campo existe no X3, ou foi criado pelo usuário no configurador do layout genérico
			cContex := GetSx3Cache(B91->B91_CAMPO, "X3_CONTEXT")	//Atribui o valor do X3_CONTEXT. V = Virtual, demais = Real

			//Se o campo for virtual, deleta a posição e diminui do adados
			If !(cContex == "V")
				If lB91
					cTpCpo := B91->B91_TIPO  // C,M,G,N,D
					
					If cTpCpo == "G"
						cTpCpo := "C"
					EndIf  
					
					If cTpCpo == "N"
						&(cAliAtu+"->" + B91->B91_CAMPO) :=  Val(aDados[nL, 3])
					ElseIf cTpCpo == "D"
						&(cAliAtu+"->" + B91->B91_CAMPO) :=  CTOD(aDados[nL, 3])
					Else
						&(cAliAtu+"->" + B91->B91_CAMPO) :=  aDados[nL, 3]
					EndIf
				Else
					&(cAliAtu+"->" + aDados[nL,6]) :=  aDados[nL, 3]
				EndIf
				
			EndIF 
				 
		Next nL		
		
		If lRet .AND. lGrvDadServ
			// Gravo os campos que tem função para gravação no servidor fora do js e htm						
			For nJ := 1 To Len(aCpoOut)
				If (!(lSxeNum))
					lSxEnum := (("GETSX8NUM" $ UPPER(aCpoOut[nJ,2])) .OR. ("GETSXENUM" $ UPPER(aCpoOut[nJ,2]))) // Faço isso pra poder confirmar depois o sequencial
				EndIf
				If !lSxEnum .AND. aTable[nI, 4] <> "G" .AND. aCpoOut[nJ, 3] == "S" .AND. Empty(aCpoOut[nJ,2]) // Aqui eu verifico se é um sequencial e nao informada a função
					lSxEnum := .T.
					&(cAliAtu+"->" + aCpoOut[nJ,1]) :=  &("GETSXENUM('"+ cAliAtu +"','" + aCpoOut[nJ,1] + "')")					
				ElseIf lSxEnum 
					&(cAliAtu+"->" + aCpoOut[nJ,1]) :=  &(aCpoOut[nJ,2])					
				EndIf
				If !lSxEnum
					&(cAliAtu+"->" + aCpoOut[nJ,1]) :=  &(aCpoOut[nJ,2])					
				EndIf
			Next nJ	
			&(cAliAtu)->(MsUnlock())
			If lSxEnum
				&(cAliAtu+"->(ConfirmSX8())") // confirmo a utilização do sequencial
			EndIf	
		EndIf					
	EndIf
Next nI

if !lGrvDadServ
	lRet := .T.
EndIf

if cChave == "PPLALTBEN" 
	PLAFBNWRA('PPLALTBEN', "1", BA1->BA1_MATVID, BA1->(RECNO()), lWeb)
endif	

RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCBOXGEN
Carrega combobox genérico
@author Karine Riquena Limp
@since 10/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSCBOXGEN(cAlias, cDados, cWhere, cAliAux, cIndicAux, cChaveAux, cCampoAux,aDadB40)  
LOCAL aCampos := StrToArray(cDados,"|")
LOCAL cCpoCod := aCampos[1]
LOCAL cCpoDes := aCampos[2]
LOCAL aDescri := IIF(";" $ cCpoDes, StrToArray(cCpoDes,";"), {})
LOCAL cString := ""
LOCAL cValor  := "" 
LOCAL cDescri := ""
LOCAL nI 		:= 0
Local cFil := if (substr(cAlias,0,1)=='S',substr(cAlias,2,2),cAlias) // Tratamento para atencer as tabela BackOffice Exemplp SA6 (BANCODS)
Local aFili := iif( (cAlias)->(fieldpos(cFil   + "_FILIAL" )>0), {.t.,cFil   + "_FILIAL"} , {.f.,""})
local cSql		:= ""
Local nTamB40   := 0
Local nB40	:= 0 
Local cContrat := " "
Local cSubCont := " "
DEFAULT cWhere := ""

If ValType(aDadB40) == "A"
	nTamB40 := LEN(aDadB40)
EndIF

if ( (empty(cAliAux) .and. empty(cIndicAux)) .or. (len(aDescri) == 0 .AND. Empty(cCampoAux)))
	cSql := " SELECT " + cCpoCod + ", " + cCpoDes 
	csql += " FROM " + RetSqlname(cAlias)
	cSql += " WHERE "
	if aFili[1]
		cSql += aFili[2] + " = '" + xFilial(cAlias) + "' "
	endif
	if (!Empty(cWhere))
		cWhere := strtran(cWhere, '.', "")
		csql += iif (aFili[1], " AND ", " ") + strtran(cWhere, '"', "'")
	endif

	if nTamB40 > 0
		For nB40 := 1 to nTamB40
			If cAlias == "BT5"				
				cContrat += "'" + Substr(aDadB40[nB40][2],9,12) + iIf(nB40 < nTamB40,"',", "'")
			ElseIf cAlias == "BQC"				
				cContrat += "'" + Substr(aDadB40[nB40][2],9,12) + iIf(nB40 < nTamB40,"',", "'")
				cSubCont += "'" + Substr(aDadB40[nB40][2],21,9) + iIf(nB40 < nTamB40,"',", "'")
			EndIF
		Next
		  If cAlias == "BT5"	
		  	cSql += " AND BT5_NUMCON IN (" + cContrat + ")"
			cSql += " AND D_E_L_E_T_ = ' ' "
		  ElseIf cAlias == "BQC"
		    cSql += " AND BQC_NUMCON IN (" + cContrat + ")" 
			cSql += " AND BQC_SUBCON IN (" + cSubCont + ")"	
			cSql += " AND D_E_L_E_T_ = ' ' " 
		  Else
		  	cSql += " AND D_E_L_E_T_ = ' ' " 
		EndIF
	Else
		cSql += " AND D_E_L_E_T_ = ' ' "
	EndIF	
	
	csql := ChangeQuery(cSql)
	TcQuery csql New Alias "TabTmp1"
	
	While !TabTmp1->(EOF())
		
		If !EMPTY(cAliAux) .AND. !EMPTY(cIndicAux) 

			If !EMPTY(cChaveAux)
				cChaveAux := StrTran( cChaveAux, "|", "+" )
			EndIf			
			If Empty(cDescri)
				&(cAliAux)->(dbSetOrder( VAL(cIndicAux) ))						
				&(cAliAux)->(MsSeek( xFilial( cAliAux ) + &(cAlias+"->(" + cChaveAux + ")") ) )
			ElseIf !&(cAliAux)->(EOF())
				&(cAliAux)->(dbskip())
			EndIF
			cDescri := &(cAliAux+"->("+cCampoAux+")")			
		EndIF

		cString += alltrim(TabTmp1->&(cCpoCod)) + "=" + iIf(cDescri == "", Alltrim(TabTmp1->&(cCpoDes)), Alltrim(cDescri)) + ";"
		TabTmp1->(dbskip())
	enddo
	
	TabTmp1->(dbclosearea())
		
else
	&(cAlias+"->(dbGotop())")
		While &(cAlias+"->(!EOF())")
			If !Empty(cWhere)
				If &(cAlias+"->( " + cWhere + ")")       
					cValor  := &(cAlias+"->("+cCpoCod+")")
					
					If !EMPTY(cAliAux) .AND. !EMPTY(cIndicAux)   

						If !EMPTY(cChaveAux)
							cChaveAux := StrTran( cChaveAux, "|", "+" )
						EndIf
						&(cAliAux)->(dbSetOrder( VAL(cIndicAux) ))
						
						&(cAliAux)->(MsSeek( xFilial( cAliAux ) + &(cAlias+"->(" + cChaveAux + ")") ) )
						cDescri := &(cAliAux+"->("+cCampoAux+")")
					Else

						cDescri := &(cAlias+"->("+cCpoDes+")")
					EndIf 

				cString += cValor + "=" + Alltrim(cDescri) + ";"
				EndIf
			Else
				cValor  := &(cAlias+"->("+cCpoCod+")")
                        
				If Len(aDescri) > 0
					For nI := 1 to Len(aDescri)
						cDescri += alltrim(&(cAlias+"->("+aDescri[nI]+")")) + '-'
					Next nI
                             
					If RIGHT(cDescri, 1) == "-" //tiro o '-' do final 
						cDescri := left(cDescri, (len(cDescri)-1))
					EndIf
				Else
					cDescri := &(cAlias+"->("+cCpoDes+")")
				EndIf
                        
				cString += cValor + "=" + Alltrim(cDescri) + ";"
				cDescri := ""
			EndIf
            
			&(cAlias+"->(dbSkip())")
		EndDo
endif
      
cString := LEFT(cString, Len(cString)-1)
      
Return cString

//-------------------------------------------------------------------
/*/{Protheus.doc} PLaRecno
Carrega combobox genérico
@author Oscar Zanin
@since 10/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLaRecno(cRecnoReg, cRecnus, aDados)

Local aRet := {}
Local nPos := 0
Local nPosRec	:= 0
Local nPosArr	:= 0
Local cAux  := ""
Local cAuxR := ""
Local cAuxArr := ""

Local nNumero := 0
Local nAA 		:= 0
Local nBB 		:= 0

If !(Empty(AllTrim(cRecnoReg)))
	Aadd(aRet, {aDados[1][1], Val(cRecnoReg), ""})
EndIf

If !(Empty(AllTrim(cRecnus)))

	//Verifica a String para retirar as "junções", igual na função de verificação de homônimos
	While ( (nPos := AT("@", UPPER(cRecnus))) > 0 .and. !Empty(cRecnus) )
		cAux   := Substr(UPPER(cRecnus), nPos+1, nPos+2)
		cRecnus := UPPER(substr(cRecnus,nPos+3,len(cRecnus)))
		
		nPosRec := At("@", UPPER(cRecnus))
		
		If (nPosRec > 0)
			cAuxR	:= Substr(cRecnus, nPos+2, nPosRec-3)
		else
			cAuxR	:= Substr(cRecnus, nPos+2)//, At("@", UPPER(cRecnus)))
		EndIf
		
		//Fazer um for para pegar cada pedaço da string e montar o array
		While ( (nPosArr := AT("~", UPPER(cAuxR + "~"))) >0 .AND. !(Vazio(cAuxR)) )
			
			nNumero++
			cAuxArr := SubStr(UPPER(cAuxR), 1, nPosArr-1)
			Aadd(aRet, {cAux, Val(cAuxArr), nNumero})
			
			cAuxR := SubStr(cAuxR, nPosArr+1, len(cAuxR))
			
		EndDo
		
		nNumero := 0
		cRecnus := UPPER(substr(cRecnus,nPosRec,len(cRecnus)))
		
	EndDo	
EndIF

If Len(aRet) > 0

	For nAA := 1 To Len(aDados)
		For nBB := 1 To Len(aRet)
		
			If ValType(aRet[nBB][3]) == "N"
				aRet[nBB][3] := Str(aRet[nBB][3])
			EndIF
			
			If( aDados[nAA][1]+aDados[nAA][4] == aRet[nBB][1]+ AllTrim(aRet[nBB][3]) )
				Aadd(aDados[nAA], aRet[nBB][2])
			EndIF
		Next
	Next

Else

	For nAA := 1 To Len(aDados)
		Aadd(aDados[nAA], 0)
	Next
EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PLCADLAPRE
Valida o X2_UNICO no layout genérico
@author Karine Riquena Limp
@since 23/07/2015
@version P12
/*/
//-------------------------------------------------------------------
function PLCADLAPRE(oModel,nTipo)
local oB7C         := oModel:GetModel('B7CDetail')
local oB90         := oModel:GetModel('MasterB90')
local oB91         := oModel:GetModel('B91Detail')
local nOpc         := oModel:GetOperation()
local nI           := 0
local nJ           := 0
local nL           := 0
local cMsg         := ""
local lAchou       := .F.
local aX2Un        := {}
local nX		   := 0	

Default ntipo := 2

if nOpc == 3

	SX2->(dbSetOrder(1))
	
	for nI := 1 to oB7C:Length()
	
		oB7C:Goline( nI ) 
		
		if SX2->(msSeek(alltrim(oB7C:GetValue('B7C_ALIAS'))))
		
		    aX2Un := strtokarr(FWX2Unico(alltrim(oB7C:GetValue('B7C_ALIAS'))), "+")    	    
		    nL := 1
		    while nL <= Len(aX2Un)
		    
		       nJ := 1
		       lAchou := .F.
		       lDel := .F.
		       
				while nJ <= oB91:Length()  .AND. !lAchou
				
					oB91:Goline( nJ )
					
					if alltrim(oB91:GetValue('B91_CAMPO')) == alltrim(aX2Un[nL])
						
						If oB91:IsDeleted()
						
							cMsg += oB91:GetValue('B91_CAMPO') + " está deletado" + chr(13) + chr(10)
							
						ElseIf !(oB91:GetValue('B91_EDITAR')) .AND. Empty(oB91:GetValue('B91_DADSRV')) .AND. Empty(oB91:GetValue('B91_INIPAD'))
							
							cMsg += oB91:GetValue('B91_CAMPO') + " está inabilitado para edição e sem inicializador ou dado padrão" + chr(13) + chr(10)
						
						ElseIf !(oB91:GetValue('B91_VISUAL')) .AND. Empty(oB91:GetValue('B91_DADSRV'))
							
							cMsg += oB91:GetValue('B91_CAMPO') + " está não visível e sem dado padrão" + chr(13) + chr(10)
						
						Else
							
							lAchou := .T.
						
						EndIf
						
					endIf
					
					nJ++
					
				endDo
				
				nL++
				                                                                                                                                                                       
			endDo
			
		endIf
		
	next nI
	
	if !(Empty(cMsg))
		msgAlert(cMsg)
	endIf

	//Tratativa para que seja gravado a sequencia correta com base na B90 assim não ocorrendo chave duplicada.
	If ntipo == 2
	
		for nI := 1 to oB7C:Length()
		
			oB7C:Goline( nI )

			oB7c:SetValue("B7C_SEQB90"	, oB90:GetValue('B90_SEQUEN') )
			for nX := 1 to oB91:Length()
				oB91:Goline( nX )
				oB91:SetValue("B91_SEQUEN"	, oB90:GetValue('B90_SEQUEN') )

			Next nX

		next nI
	EndIf


	
endIf


Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} B91PosValid
Verifica se os campos de obrigatoriedade e termo de consentimento
estão preenchidos juntos
@author V.Alves
@since 29/04/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function B91PosValid(oModelGrid)

	Local lRetorno := .T.

	If B91->(FieldPos("B91_TERCON")) > 0 .And. B91->(FieldPos("B91_FINALI")) > 0
		Do Case	
			Case oModelGrid:GetValue("B91_OBRIGA") .And. oModelGrid:GetValue("B91_TERCON")
				lRetorno := .F.
				Help(,, "Não Permitido",, "Não é possível habilitar o Termo de Consentimento caso o campo seja obrigatório.", 1, 0)
			
			Case oModelGrid:GetValue("B91_TERCON") .And. Empty(oModelGrid:GetValue("B91_FINALI"))
				lRetorno := .F.
				Help(,, "Não Permitido",, "Finalidade do campo é obrigatório quando habilitado o Termo de Consentimento.", 1, 0)
		EndCase
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} WhenFinali
Habilita o campo B91_FINALI apenas se o B91_TERCON for .T. 
@author V.Alves
@since 29/04/2021
@version P12
/*/
//-------------------------------------------------------------------
Function WhenFinali()

	Local oModel := FWModelActive()
	Local oModelB91 := oModel:GetModel("B91Detail")
	Local lRetorno := .F.

	If B91->(FieldPos("B91_TERCON")) > 0
		If oModelB91:GetValue("B91_TERCON")
			lRetorno := .T.
		EndIf
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVLDFAM
	Verifica se a família está bloqueada (Portal Beneficiario).
	@author Cesar Almeida
	@since 04/07/2022
	@version P12
/*/
//-------------------------------------------------------------------
Function PLVLDFAM(cMatric)

Local aArea := GetArea()
Local lRetorno  := .T.
Local cMat		:= SUBSTR(cMatric,1,14)

BA3->(dbsetorder(1))
If BA3->(msseek(xfilial("BA3") + cMat))
	If !EMPTY(BA3->BA3_DATBLO)
		lRetorno 	 := .F. 
	Endif
Endif

RestArea(aArea)

Return lRetorno
