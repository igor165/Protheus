#Include 'Protheus.ch'
#Include 'PLSA746.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA746   บAutor  ณMicrosiga           บ Data ณ  15/04/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Calendario de pagamento  				           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE VERSAO 12                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PLSA746()
Local oBrowse
LOCAL cNewCALPG    := GetNewPar("MV_PLCALPG","1")

IF cNewCALPG == "1"
	MsgInfo(STR0017)//"Parโmetro MV_PLCALPG do Novo Calendario de pagamento nใo estแ ativado, Verifique a utiliza็ใo desta Rotina ")
Endif

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B2J' )
oBrowse:SetDescription(STR0001)//"Calendแrio para envio/entrega de Fatura"
oBrowse:Activate()

Return( NIL )


//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}


aAdd( aRotina, { STR0002,'PesqBrw'        , 0, 1, 0, .T. } ) //'Pesquisar'
aAdd( aRotina, { STR0003,'VIEWDEF.PLSA746', 0, 2, 0, NIL } ) //'Visualizar'
aAdd( aRotina, { STR0004,'VIEWDEF.PLSA746', 0, 3, 0, NIL } ) //'Incluir'
aAdd( aRotina, { STR0005,'VIEWDEF.PLSA746', 0, 4, 0, NIL } ) //'Alterar'
aAdd( aRotina, { STR0006,'VIEWDEF.PLSA746', 0, 5, 0, NIL } ) //'Excluir'
aAdd( aRotina, { STR0007,'VIEWDEF.PLSA746', 0, 8, 0, NIL } ) //'Imprimir'
aAdd( aRotina, { STR0008,'VIEWDEF.PLSA746', 0, 9, 0, NIL } ) //'Copiar'

aAdd( aRotina, { "Compet๊ncias",'PLSA265C', 0, 2, 0, NIL } )

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

Local oStruB2J := FWFormStruct( 1, 'B2J', , )
Local oStruB2K := FWFormStruct( 1, 'B2K', , )
Local bLinePre := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| PLS746ATIV(oGridModel, nLine, cAction, "B2K_STATUS", xValue, xCurrentValue)}

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSA746MD', /*bPreValidacao*/ ,{|| PL7CALPA(oModel) }  /*bPosValidacao*/ , /*bCommit*/, /*bCancel*/ ) 

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
oModel:AddFields( 'B2JMASTER', NIL, oStruB2J )

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por grid 
oModel:AddGrid( 'B2KDETAIL', 'B2JMASTER', oStruB2K, bLinePre,{ |oGrid| bLine746(oGrid, "NUS" ) } /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


oModel:SetPrimaryKey({"B2J_FILIAL","B2J_CODINT","B2J_COD"})


// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'B2KDETAIL', { { 'B2K_FILIAL', 'xFilial( "B2J" ) ' } ,;
	                                { 'B2K_COD', 'B2J_COD' } } ,  "B2K_FILIAL+B2K_COD" )

// Indica que ้ opcional ter dados informados na Grid
oModel:GetModel( 'B2KDETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B2JMASTER' ):SetDescription(STR0001) //"Calendแrio para envio/entrega de Fatura"

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0001) //"Calendแrio para envio/entrega de Fatura"

//Valida se existem codigos duplicados no aCols
oModel:GetModel('B2KDETAIL'):SetUniqueLine({'B2K_ANO','B2K_MES','B2K_DIAINI','B2K_DIAFIM','B2K_DIAPGT','B2K_CODRDA'})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oStruB2K := FWFormStruct( 2, 'B2K' )
Local oStruB2J := FWFormStruct( 2, 'B2J' )

Local oModel   := FWLoadModel( 'PLSA746' )
Local oView    := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B2J' , oStruB2J, 'B2JMASTER'   )     

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_B2K' , oStruB2K, 'B2KDETAIL'   )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL', 50 )
oView:CreateHorizontalBox( 'GRID' , 50 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B2J' , 'GERAL' )
oView:SetOwnerView( 'VIEW_B2K' , 'GRID'  )

oView:EnableTitleView( 'VIEW_B2K' )

oView:AddIncrementField( 'VIEW_B2K' , 'B2K_CODSEQ') //Adiciona Campo incremental na View

Return oView  



Function PL746VALD()
Local lRet:=.T.


DbSelectArea("B2K")
dbSetorder(1)
If !Empty(M->BAU_CALPGT)
	If !B2K->(DbSeek(xFilial("B2K")+M->BAU_CALPGT)) 
		MsgInfo(STR0009) //"Calendแrio Informado nใo Possui Dia de Pagamento Informado!"
		lRet:=.F.
	Endif
Endif

RETURN(lRet)



Function bLine746(oGrid)
Local lRet:=.T.
Local lDia:=.T.
Local lAnoB:=.T.
Local nOperation:= oGrid:GetOperation()
Local aArea 	:= GetArea()
Local aAcolsAx	:= aClone(oGrid:aCols)
Local nLines 	:= oGrid:GetQtdLine()
Local nPosDtIni := GdFieldPos("B2K_DIAINI",oGrid:aHeader)
Local nPosDtFim := GdFieldPos("B2K_DIAFIM",oGrid:aHeader)
Local nPosAno	:= GdFieldPos("B2K_ANO   ",oGrid:aHeader)
Local nPosMes	:= GdFieldPos("B2K_MES   ",oGrid:aHeader)
Local nX
Local aMat 		:= {}
Local nPos		:= 0
Local lAtuB2K	:= B2K->(FieldPos("B2K_DIAIN2")) > 0 .AND. B2K->(FieldPos("B2K_DIAFI2")) > 0
Local nDiaFi2	:= 0
Local nDiaIn2	:= 0

	// Essas sใo as datas da linha atual.
	nDiaIni := oGrid:GetValue("B2K_DIAINI",oGrid:nLine)
	nDiaFim := oGrid:GetValue("B2K_DIAFIM",oGrid:nLine)
	if lAtuB2K
		nDiaIn2 := oGrid:GetValue("B2K_DIAIN2",oGrid:nLine)
		nDiaFi2 := oGrid:GetValue("B2K_DIAFI2",oGrid:nLine)
	endif
	nAno	:= oGrid:GetValue("B2K_ANO   ",oGrid:nLine)
	nMes	:= oGrid:GetValue("B2K_MES   ",oGrid:nLine)
	nDpag	:= oGrid:GetValue("B2K_DIAFIM",oGrid:nLine)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se data inicio for maior que final nao permite									 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nDiaIni > nDiaFim .And. ! Empty(nDiaFim)
		Help("",1,STR0010) //"Dia Final nใo pode ser Maior que Dia Inicial"
		lRet := .F.
	Endif

	if lAtuB2K
		If nDiaIn2 > nDiaFi2 .And. ! Empty(nDiaFi2)
			Help("",1,"Dia Final nใo pode ser Menor que Dia Inicial") //"Dia Final nใo pode ser Maior que Dia Inicial"
			lRet := .F.
		Endif
	endif

	If nDpag < nDiaFim .And. ! Empty(nDiaFim)
		Help("",1,STR0011) //"Dia Pagamento nใo pode ser Maior que Dia Final"	
		lRet := .F.
	Endif

/*Verificar ano Bissexto*/

	If 	!Empty(nAno) .or. !Empty(nMes)
		lAnoB:=PL746AnoBi(val(nAno))
		IF  !Empty(nDiaIni)
			lDia:=PL746DM(nDiaIni,nMes,nAno)
			If !lDia
				Help("",1,STR0012) //"Dia Inicial nใo ้ Valido para o Mes Informado"
				lRet := .F.
			Endif
		Endif

		IF  !Empty(nDiaFim)
			lDia:=PL746DM(nDiaFim,nMes,nAno)
			If !lDia
				Help("",1,STR0013)//"Dia Final nใo ้ Valido para o Mes Informado"
				lRet := .F.
			Endif
		Endif

		if lAtuB2K
			IF  !Empty(nDiaIn2)
				lDia:=PL746DM(nDiaIn2,nMes,nAno)
				If !lDia
					Help("",1,STR0012) //"Dia Inicial nใo ้ Valido para o Mes Informado"
					lRet := .F.
				Endif
			Endif

			IF  !Empty(nDiaFi2)
				lDia:=PL746DM(nDiaFi2,nMes,nAno)
				If !lDia
					Help("",1,STR0013)//"Dia Final nใo ้ Valido para o Mes Informado"
					lRet := .F.
				Endif
			Endif
		endif

		IF  !Empty(nDpag)
			lDia:=PL746DM(nDpag,nMes,nAno)
			If !lDia
				Help("",1,STR0014) //"Dia do Pagamento nใo ้ Valido para o Mes Informado"
				lRet := .F.
			Endif
	
		Endif
				
	Endif

If 	Empty(nAno) .and. Empty(nMes)
	Help("",1,STR0018) //"Necessแrio Informar um M๊s ou um Ano para o Calendario de Pagamento"
	lRet := .F.
Endif 

RETURN(lRet)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณ PL746AnoBi  บAutor  ณ Saude      บ Data ณ  28/07/15   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se ้ ano bissexto.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PL746AnoBi(nAno) 

Local lRet	:= .F.

If Mod( nAno, 4 ) == 0 .AND. Mod( nAno, 100 ) <> 0
	lRet := .T.
Endif

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณ PL746DM  บAutor  ณ Saude      บ Data ณ  13/08/15   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 		 Valida็ใo do Dia		                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function PL746DM(cDia,cMes,cAno)
Local lRet :=.T.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Tratamento para meses com 30 dias e o dia disponivel cai no dia 31		 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cDia == "31" .And. cMes $ "04/06/09/11"
	LRet:=.F.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Tratamento para fevereiro valida se e ano bissexto para liberar o dia 29 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf cMes == "02"
   	If (cDia == "29" .And. Val(cAno) % 4 <> 0) .Or. (cDia >= "30")
   		lRet:=.F.
   	EndIf
Endif

return(lRet)


/*Valida็ใo calendario Padrใo*/
Static Function PL7CALPA(oModel)
Local lRet :=.F.
Local lRcal :=.F.
LOCAL oModelDetail	:= oModel:GetModel( 'B2JMASTER' )
LOCAL cMsg     		:= ""
LOCAL cDescri  		:= ""
LOCAL nOpc				:= oModel:GetOperation()
LOCAL cCod  			:= oModelDetail:GetValue('B2J_COD   ')
LOCAL cCalPad  		:= oModelDetail:GetValue('B2J_CALPAD')
LOCAL cCodInt			:= PLSINTPAD()
Local cCodCal 		:= ""
Local nRecnoCal		:= 0

B2J->(DbSelectArea("B2J"))
B2J->(dbSetorder(1))//B2J_FILIAL+B2J_CODINT+B2J_COD
B2J->(DbGoTop())

While ! B2J->(Eof()) .AND. B2J->(B2J_FILIAL+B2J_CODINT)== xFilial("B2J")+cCodInt  .AND. !(lRcal)
	If B2J->B2J_CALPAD=='1' 
		lRcal		:= .T.
		cCodCal	:= B2J->B2J_COD
		nRecnoCal 	:= B2J->(Recno())
	Endif
	B2J->(dbskip())
enddo

B2J->(DbCloseArea())

IF nOpc == 3 .OR.	nOpc == 4
	If lRcal .AND. cCalPad == '1' .and. cCodCal <> cCod
		If MsgYesNo(STR0019 /*"Deseja definir este como o calendแrio padrใo?"*/ +CRLF+ STR0020 /*"Esta a็ใo substituirแ o calendแrio padrใo atual por este"*/, STR0021 /*"Aten็ใo!"*/)
			B2J->(DbGoTo(nRecnoCal))
				B2J->(RecLock("B2J", .F.))
					B2J->B2J_CALPAD := '0'
				B2J->(MsUnLock())
			lRet := .T.
		else
		   	cMsg := STR0015// "Ja existe um calendario Padrใo cadastrado" 
		   	Help( ,, 'HELP',, cMsg, 1, 0)
	   	endif
	
	ElseIf cCalPad <>'1' .AND. !(lRcal)
	   	cMsg := STR0016//"Nใo existe nenhum calendario Padrใo cadastrado" 
	   	Help( ,, 'HELP',, cMsg, 1, 0)
	
	elseIf cCalPad <> '1' .AND. cCodCal == cCod
		cMsg := STR0022 /*"Nใo ้ possํvel definir o calendแrio padrใo como nใo padrใo"*/ +CRLF+ STR0023 /*"Para nใo usar mais este calendแrio como padrใo, defina um novo calendแrio padrใo!"*/
		Help( ,, 'HELP',, cMsg, 1, 0)
		
	else
		lRet := .T.
	EndIf

elseIf nOpc == 5
	If cCalPad == '1'	
		cMsg := STR0024 /*"Nใo ้ possํvel excluir o calendแrio padrใo, defina o novo calendแrio padrใo antes de excluir este"*/
		Help( ,, 'HELP',, cMsg, 1, 0)
	else
		lRet := .T.
	EndIf
Else
	lRet := .T.   		
Endif

return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS746CAL
Verificar o Tipo de  Calendario
@author Sa๚de
@since 17/08/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS746CAL(cOpemov,cAnoPag,cMespag)
LOCAL cNewCALPG    := GetNewPar("MV_PLCALPG","1")
Local aRetCal:={}

IF cNewCALPG == "1"
	BDT->(DbSetOrder(1))
	BDT->(MsSeek(xFilial("BDT")+cOpemov+cAnoPag+cMespag))
    aRetCal := {.T.,{},BDT->BDT_DATPRE,BDT->BDT_ANO,BDT->BDT_MES,,,BDT->BDT_DATINI,BDT->BDT_DATFIN}
Else
	aRetCal := PLSXVLDCAL(dDataBase,PLSINTPAD(),.T.,"","")      		
Endif

Return(aRetCal)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS746ATIV
Validar se para que haja somente um calendแrio ativo para cada uma das 6 regras:
1) Informado somente Ano
2) Informado somente M๊s
3) Informado somente Ano e M๊s
4) Informado somente Ano e RDA
5) Informado somente M๊s e RDA
6) Informado Ano, M๊s e RDA
@author Oscar Zanin
@since 02/02/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLS746ATIV(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
Local lRet := .T.
Local cAno := "" 
Local cMes := ""
Local cRDA := ""
Local nI   := 1
local nCnt := 0
Local aLin := {}

If cIDField == "B2K_STATUS"
	If xValue == "1" .AND. xCurrentValue == "0"
		cAno := AllTrim(oGridModel:getValue("B2K_ANO"))
		cMes := AllTrim(oGridModel:getValue("B2K_MES"))
		cRDA := Alltrim(oGridModel:getValue("B2K_CODRDA"))
		
		//Busca outra configura็ใo igual na Grid
		For nI := 1 To oGridModel:Length()
			oGridModel:GoLine( nI )
			
			If !(oGridModel:IsDeleted())
				if cAno == AllTrim(oGridModel:getValue("B2K_ANO")) .AND. cMes == AllTrim(oGridModel:getValue("B2K_MES")) .AND. cRDA == Alltrim(oGridModel:getValue("B2K_CODRDA"))
					nCnt++
					Aadd(aLin, nI)
				endIf
			EndIf
		Next nI
				
		If nCnt > 1
			If MsgYesNo(STR0025 /*"Existe outra configura็ใo com esses mesmos Ano, M๊s e C๓digo da RDA. Deseja tornar esta configura็ใo ativa?"*/ + CRLF + STR0026 /*"Esta a็ใo irแ tornar Inativa a configura็ใo anterior"*/, STR0021 /*"Aten็ใo!"*/)
				For nI := 1 to Len(aLin)
					oGridModel:GoLine( nI )
					oGridModel:SetValue("B2K_STATUS", "0")
				Next nI
			else
				lRet := .F.         
				Help( ,, 'HELP',, STR0027 /*'Nใo confirmada a altera็ใo'*/, 1, 0)
			EndIf
		EndIf
	EndIf
	
	oGridModel:GoLine( nLine )
	
EndIf
  
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PLS746VLDP
Validar se o calendแrio jแ estแ vinculado a uma RDA ou na RDA se existe configura็ใo no calendแrio informado
@author Sa๚de
@since 04/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLS746VLDP(cAlias, cCodCal, cCodRda)
local lRet := .T.
local cMsg := ""
local cCodInt := PLSINTPAD()
local aArea := getArea()
default cCodCal := ""
default cCodRda := ""
//Este Valid foi desabilitado pq a regra agora irแ permitir que sejam criadas exce็๕es com base em c๓digo de RDA
//para calendแrios vinculados เ RDAs
/*
if (!empty(cCodCal))
	if cAlias == "BAU"
		//caso venha da BAU: fazer um seek no calendแrio e verificar se alguma regra possui RDA vinculada
		lRet := PLCALRDANB(cCodCal) 
		cMsg := iif(lRet, "", "Nใo ้ permitido vincular calendแrios que contenham regras especํficas para redes de atendimento!")
	elseif cAlias == "B2K" .and. !empty(cCodRda)
		//caso venha do calendแrio: fazer um seek na BAU para verificar se este calendแrio estแ vincu็ado a 
		//a uma Rede de Atendimento
		BAU->(dbSetOrder(12))
		if BAU->(msSeek(xFilial("BAU")+cCodCal))
			lRet := .F.
			cMsg := "Nใo ้ permitido especificar RDA's neste calendแrio, pois este jแ estแ vinculado no cadastro da Rede de atendimento a uma ou mais RDA's (BAU_CALPGT)"
		endIf
	endIf
endIf

if !empty(cMsg)
	MsgAlert("", cMsg)
endIf
*/	
restArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PLCALRDANB
Retorna se o calendแrio nใo possui RDA especํfica configurada nos itens
@author Sa๚de
@since 04/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLCALRDANB(cCodCal)
local lRet := .T.
//Com a mudan็a da regra para permitir exce็๕es por RDA em calendแrios vinculados เ RDAs, essa verifica็ใo nใo faz mais sentido.
/*
cCodCal := iif(!empty(cCodCal), cCodCal, iif( B2J->(!EOF()) ,B2J->B2J_COD, ""))
if !empty(cCodCal)
	B2K->(dbSetOrder(1))
	B2K->(msSeek(xFilial("B2K")+cCodCal))	
	while lRet .and. B2K->(!EOF()) .and. ( B2K->(B2K_FILIAL+B2K_COD) == (xFilial("B2K")+cCodCal) )
		lRet := empty(B2K->B2K_CODRDA)
		B2K->(dbSkip())
	endDo
endIf
*/
return lRet

//Retorna qual o calendแrio padrใo
Function PLSCalPad()

Local cSql := ""
Local cRet := "   "

cSql += " Select B2J_COD From " + RetSqlName("B2J")
cSql += " Where "
cSql += " B2J_FILIAL = '" + xFilial('B2J') + "' AND "
cSql += " B2J_CALPAD = '1' AND "
cSql += " D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"CALPAD",.F.,.T.)

if !CALPAD->(EoF())
	cRet := CALPAD->B2J_COD
endif

CALPAD->(DbCloseArea())

return cRet
