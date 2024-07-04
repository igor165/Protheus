#Include 'Protheus.ch'
#Include 'PLSA746.ch'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA746   �Autor  �Microsiga           � Data �  15/04/2015���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de Calendario de pagamento  				           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SEGMENTO SAUDE VERSAO 12                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function PLSA746()
Local oBrowse
LOCAL cNewCALPG    := GetNewPar("MV_PLCALPG","1")

IF cNewCALPG == "1"
	MsgInfo(STR0017)//"Par�metro MV_PLCALPG do Novo Calendario de pagamento n�o est� ativado, Verifique a utiliza��o desta Rotina ")
Endif

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B2J' )
oBrowse:SetDescription(STR0001)//"Calend�rio para envio/entrega de Fatura"
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

aAdd( aRotina, { "Compet�ncias",'PLSA265C', 0, 2, 0, NIL } )

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

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'B2JMASTER', NIL, oStruB2J )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid 
oModel:AddGrid( 'B2KDETAIL', 'B2JMASTER', oStruB2K, bLinePre,{ |oGrid| bLine746(oGrid, "NUS" ) } /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


oModel:SetPrimaryKey({"B2J_FILIAL","B2J_CODINT","B2J_COD"})


// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'B2KDETAIL', { { 'B2K_FILIAL', 'xFilial( "B2J" ) ' } ,;
	                                { 'B2K_COD', 'B2J_COD' } } ,  "B2K_FILIAL+B2K_COD" )

// Indica que � opcional ter dados informados na Grid
oModel:GetModel( 'B2KDETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B2JMASTER' ):SetDescription(STR0001) //"Calend�rio para envio/entrega de Fatura"

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0001) //"Calend�rio para envio/entrega de Fatura"

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

// Define qual o Modelo de dados ser� utilizado
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
		MsgInfo(STR0009) //"Calend�rio Informado n�o Possui Dia de Pagamento Informado!"
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

	// Essas s�o as datas da linha atual.
	nDiaIni := oGrid:GetValue("B2K_DIAINI",oGrid:nLine)
	nDiaFim := oGrid:GetValue("B2K_DIAFIM",oGrid:nLine)
	if lAtuB2K
		nDiaIn2 := oGrid:GetValue("B2K_DIAIN2",oGrid:nLine)
		nDiaFi2 := oGrid:GetValue("B2K_DIAFI2",oGrid:nLine)
	endif
	nAno	:= oGrid:GetValue("B2K_ANO   ",oGrid:nLine)
	nMes	:= oGrid:GetValue("B2K_MES   ",oGrid:nLine)
	nDpag	:= oGrid:GetValue("B2K_DIAFIM",oGrid:nLine)

	//����������������������������������������������������������������������������������Ŀ
	//� Se data inicio for maior que final nao permite									 �
	//������������������������������������������������������������������������������������
	If nDiaIni > nDiaFim .And. ! Empty(nDiaFim)
		Help("",1,STR0010) //"Dia Final n�o pode ser Maior que Dia Inicial"
		lRet := .F.
	Endif

	if lAtuB2K
		If nDiaIn2 > nDiaFi2 .And. ! Empty(nDiaFi2)
			Help("",1,"Dia Final n�o pode ser Menor que Dia Inicial") //"Dia Final n�o pode ser Maior que Dia Inicial"
			lRet := .F.
		Endif
	endif

	If nDpag < nDiaFim .And. ! Empty(nDiaFim)
		Help("",1,STR0011) //"Dia Pagamento n�o pode ser Maior que Dia Final"	
		lRet := .F.
	Endif

/*Verificar ano Bissexto*/

	If 	!Empty(nAno) .or. !Empty(nMes)
		lAnoB:=PL746AnoBi(val(nAno))
		IF  !Empty(nDiaIni)
			lDia:=PL746DM(nDiaIni,nMes,nAno)
			If !lDia
				Help("",1,STR0012) //"Dia Inicial n�o � Valido para o Mes Informado"
				lRet := .F.
			Endif
		Endif

		IF  !Empty(nDiaFim)
			lDia:=PL746DM(nDiaFim,nMes,nAno)
			If !lDia
				Help("",1,STR0013)//"Dia Final n�o � Valido para o Mes Informado"
				lRet := .F.
			Endif
		Endif

		if lAtuB2K
			IF  !Empty(nDiaIn2)
				lDia:=PL746DM(nDiaIn2,nMes,nAno)
				If !lDia
					Help("",1,STR0012) //"Dia Inicial n�o � Valido para o Mes Informado"
					lRet := .F.
				Endif
			Endif

			IF  !Empty(nDiaFi2)
				lDia:=PL746DM(nDiaFi2,nMes,nAno)
				If !lDia
					Help("",1,STR0013)//"Dia Final n�o � Valido para o Mes Informado"
					lRet := .F.
				Endif
			Endif
		endif

		IF  !Empty(nDpag)
			lDia:=PL746DM(nDpag,nMes,nAno)
			If !lDia
				Help("",1,STR0014) //"Dia do Pagamento n�o � Valido para o Mes Informado"
				lRet := .F.
			Endif
	
		Endif
				
	Endif

If 	Empty(nAno) .and. Empty(nMes)
	Help("",1,STR0018) //"Necess�rio Informar um M�s ou um Ano para o Calendario de Pagamento"
	lRet := .F.
Endif 

RETURN(lRet)




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Funcao   � PL746AnoBi  �Autor  � Saude      � Data �  28/07/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se � ano bissexto.                                ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PL746AnoBi(nAno) 

Local lRet	:= .F.

If Mod( nAno, 4 ) == 0 .AND. Mod( nAno, 100 ) <> 0
	lRet := .T.
Endif

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Funcao   � PL746DM  �Autor  � Saude      � Data �  13/08/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � 		 Valida��o do Dia		                                ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


Static Function PL746DM(cDia,cMes,cAno)
Local lRet :=.T.
//��������������������������������������������������������������������������Ŀ
//� Tratamento para meses com 30 dias e o dia disponivel cai no dia 31		 �
//����������������������������������������������������������������������������
If cDia == "31" .And. cMes $ "04/06/09/11"
	LRet:=.F.
//��������������������������������������������������������������������������Ŀ
//� Tratamento para fevereiro valida se e ano bissexto para liberar o dia 29 �
//����������������������������������������������������������������������������
ElseIf cMes == "02"
   	If (cDia == "29" .And. Val(cAno) % 4 <> 0) .Or. (cDia >= "30")
   		lRet:=.F.
   	EndIf
Endif

return(lRet)


/*Valida��o calendario Padr�o*/
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
		If MsgYesNo(STR0019 /*"Deseja definir este como o calend�rio padr�o?"*/ +CRLF+ STR0020 /*"Esta a��o substituir� o calend�rio padr�o atual por este"*/, STR0021 /*"Aten��o!"*/)
			B2J->(DbGoTo(nRecnoCal))
				B2J->(RecLock("B2J", .F.))
					B2J->B2J_CALPAD := '0'
				B2J->(MsUnLock())
			lRet := .T.
		else
		   	cMsg := STR0015// "Ja existe um calendario Padr�o cadastrado" 
		   	Help( ,, 'HELP',, cMsg, 1, 0)
	   	endif
	
	ElseIf cCalPad <>'1' .AND. !(lRcal)
	   	cMsg := STR0016//"N�o existe nenhum calendario Padr�o cadastrado" 
	   	Help( ,, 'HELP',, cMsg, 1, 0)
	
	elseIf cCalPad <> '1' .AND. cCodCal == cCod
		cMsg := STR0022 /*"N�o � poss�vel definir o calend�rio padr�o como n�o padr�o"*/ +CRLF+ STR0023 /*"Para n�o usar mais este calend�rio como padr�o, defina um novo calend�rio padr�o!"*/
		Help( ,, 'HELP',, cMsg, 1, 0)
		
	else
		lRet := .T.
	EndIf

elseIf nOpc == 5
	If cCalPad == '1'	
		cMsg := STR0024 /*"N�o � poss�vel excluir o calend�rio padr�o, defina o novo calend�rio padr�o antes de excluir este"*/
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
@author Sa�de
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
Validar se para que haja somente um calend�rio ativo para cada uma das 6 regras:
1) Informado somente Ano
2) Informado somente M�s
3) Informado somente Ano e M�s
4) Informado somente Ano e RDA
5) Informado somente M�s e RDA
6) Informado Ano, M�s e RDA
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
		
		//Busca outra configura��o igual na Grid
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
			If MsgYesNo(STR0025 /*"Existe outra configura��o com esses mesmos Ano, M�s e C�digo da RDA. Deseja tornar esta configura��o ativa?"*/ + CRLF + STR0026 /*"Esta a��o ir� tornar Inativa a configura��o anterior"*/, STR0021 /*"Aten��o!"*/)
				For nI := 1 to Len(aLin)
					oGridModel:GoLine( nI )
					oGridModel:SetValue("B2K_STATUS", "0")
				Next nI
			else
				lRet := .F.         
				Help( ,, 'HELP',, STR0027 /*'N�o confirmada a altera��o'*/, 1, 0)
			EndIf
		EndIf
	EndIf
	
	oGridModel:GoLine( nLine )
	
EndIf
  
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PLS746VLDP
Validar se o calend�rio j� est� vinculado a uma RDA ou na RDA se existe configura��o no calend�rio informado
@author Sa�de
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
//Este Valid foi desabilitado pq a regra agora ir� permitir que sejam criadas exce��es com base em c�digo de RDA
//para calend�rios vinculados � RDAs
/*
if (!empty(cCodCal))
	if cAlias == "BAU"
		//caso venha da BAU: fazer um seek no calend�rio e verificar se alguma regra possui RDA vinculada
		lRet := PLCALRDANB(cCodCal) 
		cMsg := iif(lRet, "", "N�o � permitido vincular calend�rios que contenham regras espec�ficas para redes de atendimento!")
	elseif cAlias == "B2K" .and. !empty(cCodRda)
		//caso venha do calend�rio: fazer um seek na BAU para verificar se este calend�rio est� vincu�ado a 
		//a uma Rede de Atendimento
		BAU->(dbSetOrder(12))
		if BAU->(msSeek(xFilial("BAU")+cCodCal))
			lRet := .F.
			cMsg := "N�o � permitido especificar RDA's neste calend�rio, pois este j� est� vinculado no cadastro da Rede de atendimento a uma ou mais RDA's (BAU_CALPGT)"
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
Retorna se o calend�rio n�o possui RDA espec�fica configurada nos itens
@author Sa�de
@since 04/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLCALRDANB(cCodCal)
local lRet := .T.
//Com a mudan�a da regra para permitir exce��es por RDA em calend�rios vinculados � RDAs, essa verifica��o n�o faz mais sentido.
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

//Retorna qual o calend�rio padr�o
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
