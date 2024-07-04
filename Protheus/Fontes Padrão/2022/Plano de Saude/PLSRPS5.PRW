#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static aJaValido	:= {}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPS5
Fonte de modelo de dados para gravação automática e funções gerais
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRPS5(lAutoma)

Local oBrowse
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 //Para fins de automação

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B4K')
oBrowse:SetDescription('Lote RPS')
iif(!lAutoma, oBrowse:Activate(), '')

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel // Modelo de dados construído
Local oStrB4K:= FWFormStruct(1,'B4K')// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que iráconsiderar
Local oStrB5B:= FWFormStruct(1,'B5B' ) // Cria as estruturas a serem usadas no Modelo de Dados

oModel := MPFormModel():New( 'PLSRPS5' ) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação

oModel:addFields('MasterB4K',/*cOwner*/,oStrB4K)  // Adiciona ao modelo um componente de formulário

oModel:AddGrid('B5BDetail', 'MasterB4K', oStrB5B) // Adiciona ao modelo uma componente de grid

oModel:SetRelation( 'B5BDetail', { ;
	{ 'B5B_FILIAL' 	, 'xFilial("B5B")' },;
	{ 'B5B_CODOPE'	, 'B4K_CODOPE'     },;
	{ 'B5B_NUMLOT'	, 'B4K_NUMLOT'     } },;
	B5B->( IndexKey( 1 ) ) )  // Faz relacionamento entre os componentes do model

oModel:GetModel('MasterB4K'):SetDescription('Lote RPS') // Adiciona a descrição do Modelo de Dados
oModel:getModel('B5BDetail'):SetOptional(.T.)

oModel:SetPrimaryKey( {"B4K_FILIAL", "B4K_CODOPE", "B4K_NUMLOT"} )

Return oModel // Retorna o Modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oView  // Interface de visualização construída
Local oModel := FWLoadModel( 'PLSRPS5' ) // Cria as estruturas a serem usadas na View
Local oStrB4K:= FWFormStruct(2, 'B4K' )
Local oStrB5B:= FWFormStruct(2, 'B5B' )

oView := FWFormView():New() // Cria o objeto de View

oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

oView:AddField('ViewB4K' , oStrB4K,'MasterB4K' ) // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:addgrid( 'ViewB5B' , oStrB5B,'B5BDetail' )

oView:CreateHorizontalBox( 'SUPERIOR' , 20 ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente
oView:CreateHorizontalBox( 'INFERIOR' , 80 )

oView:SetOwnerView('ViewB4K','SUPERIOR') // Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewB5B','INFERIOR')

Return oView // Retorna o objeto de View criado


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPSCHK
Retorna se há um lote em aberto de um determinado tipo para uma determinada operadora
Caso haja lote aberto, retorna .T., caso não, retorna .F.
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------

function PLSRPSCHK(cTipArq, cCodOpe, ctipCab)

Local lRet := .F.
Local cSql := ""

default cCodOpe := PLSINTPAD()

cSql += " Select R_E_C_N_O_ REC From " + RetsqlName("B4K") 
csql += " Where "
csql += " B4K_FILIAL = '" + xfilial("B4K") + "' AND "
cSql += " B4K_CODOPE = '" + cCodOpe + "' AND "
cSql += " B4K_TIPARQ = '" + ctipArq + "' AND "
cSql += " B4K_TIPCAB = '" +cTipCab + "' AND "
cSql += " B4K_STATUS = '0' AND "
cSql += " D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,(cSql)),"ExiB5B",.F.,.T.)

lRet := !(ExiB5B->(EoF()))

If lRet
    B4K->(Dbgoto(ExiB5B->(REC)))
endIf
ExiB5B->(dbclosearea())

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPSALT
Insere/Atualiza um registro em um lote do RPS
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLSRPSALT(cCodOpe, nRecnoBAU, nRecnoBB8, nRecnoB84, aAlt, cTpArq, aChvAnt, aIncLoc, ldestroy, lExclRda, l84CabOnly)

Local aTabPos := {.F., .F., .F.}
Local oModel := FWLoadModel( 'PLSRPS5' )
Local oModelIte := FWLoadModel( 'PLSRPS6' )
Local ctipCab	:= " "
Local laltChv	:= .F.
local aLocBB8	:= {}
local nI		:= 1
local aAreaBB8	:= BB8->(getarea())

Default cCodOpe := PLSINTPAD()
Default nRecnoBAU	:= 0
Default nRecnoBB8	:= 0
Default nRecnoB84	:= 0
Default aAlt		:= {}
Default cTpArq	:= "1"
Default aChvAnt	:= { "DEFAULT", "DEFAULT", "DEFAULT" }
Default aIncLoc	:= {}
Default ldestroy	:= .F.
default lExclRda	:= .f.
default l84CabOnly := .F.

If nRecnoB84 > 0
	B84->(dbGoTo(nRecnoB84))
	BAU->(dbGoTo(nRecnoBAU))
	ctipCab := PRP5QUAD6()
endIf
If l84CabOnly
	nRecnoB84 := 0
endIf
//Se não houver lote aberto, cria o novo, se houver, somente adiciona os registros
If ! PLSRPSCHK(cTpArq, cCodOpe, ctipCab)
	// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
	oModel:SetOperation( 3 )
	oModel:Activate()
	PRPSINLOT(cTpArq, cCodOpe, @oModel, ctipCab)
else
	// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
	oModel:SetOperation( 4 )
	oModel:Activate()
endIf

If Len(aAlt) > 0

	If nRecnoBAU > 0
		BAU->(DbgoTo(nRecnoBAU))
		aTabPos[1] := .T.
	endIf
	
	If nRecnoBB8 > 0
		BB8->(DbGoTo(nRecnoBB8))
		aTabPos[2] := .T.
		iif(!lExclRda, aadd(aLocBB8, BB8->(recno())), '')
	
	elseIf !(empTy(aIncLoc))
		aTabPos[2] := .T.
	else
		BB8->(dbSetOrder(1))
		If BB8->(MsSeek(xfilial("BB8") + BAU->BAU_CODIGO))
			aTabPos[2] := .T.
			iif(!lExclRda, aadd(aLocBB8, BB8->(recno())), '')
		endIf
	endIf
	
	If nRecnoB84 > 0
		B84->(DbgoTo(nRecnoB84))
		aTabPos[3] := .T.
	endIf
	
	If aTabPos[3] //Quando há vinculação
		B5B->(dbSetOrder(2))
		If B5B->(MsSeek( xfilial("B5B") + Str(nRecnoB84, 16, 0))) .AND. B5B->B5B_NUMLOT == omodel:getmodel("MasterB4K"):getValue("B4K_NUMLOT") //Já há alteração no vínculo
			oModelIte:SetOperation( 4 )
			oModelIte:Activate()
		else
			B5B->(dbSetOrder(1)) //Já há alguma alteração qualquer pro prestador			
			If B5B->(MsSeek(xfilial("B5B") + cCodOpe + omodel:getmodel("MasterB4K"):getValue("B4K_NUMLOT") + BAU->BAU_CODIGO + BB8->BB8_CODLOC));
			.AND. ( B5B->B5B_SEQVIN == 0 .OR. PlsVldB5B(cCodOpe, omodel:getmodel("MasterB4K"):getValue("B4K_NUMLOT"), BAU->BAU_CODIGO, BB8->BB8_CODLOC, nRecnoB84) )
				oModelIte:SetOperation( 4 )
				oModelIte:Activate()			
				laltChv := .t.				
			else
				oModelIte:SetOperation( 3 )
				oModelIte:Activate()
			endIf
		endIf
	else
		B5B->(dbSetOrder(1))
		If !(empTy(aIncLoc)) .AND. ( B5B->(MsSeek(xfilial("B5B") + cCodOpe + omodel:getmodel("MasterB4K"):getValue("B4K_NUMLOT") + BAU->BAU_CODIGO + "   ")) .OR. B5B->(MsSeek(xfilial("B5B") + cCodOpe + omodel:getmodel("MasterB4K"):getValue("B4K_NUMLOT") + BAU->BAU_CODIGO + aIncLoc[1])))
			oModelIte:SetOperation( 4 )
			oModelIte:Activate()	
		elseIf B5B->(MsSeek(xfilial("B5B") + cCodOpe + omodel:getmodel("MasterB4K"):getValue("B4K_NUMLOT") + BAU->BAU_CODIGO + BB8->BB8_CODLOC))
			oModelIte:SetOperation( 4 )
			oModelIte:Activate()
		else
			oModelIte:SetOperation( 3 )
			oModelIte:Activate()
		endIf
	EndIf
	
	if lExclRda
		PlBscBB8E(BAU->BAU_CODIGO, @aLocBB8)
	endif	 
	
endIf

If (oModel:VldData() )
	// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
	oModel:CommitData()
else
	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro := oModel:GetErrorMessage()
	// A estrutura do vetor com erro é:
	// [1] identificador (ID) do formulário de origem
	// [2] identificador (ID) do campo de origem
	// [3] identificador (ID) do formulário de erro
	// [4] identificador (ID) do campo de erro
	// [5] identificador (ID) do erro
	// [6] mensagem do erro
	// [7] mensagem da solução
	// [8] Valor atribuído
	// [9] Valor anterior
	AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
	AutoGrLog( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
	AutoGrLog( "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
	AutoGrLog( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
	AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
	AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
	AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
	AutoGrLog( "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' )
	AutoGrLog( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']')
	MostraErro()
EndIf

if Len(aLocBB8) > 0
	for nI := 1 to len(aLocBB8)
		BB8->( dbgoto(aLocBB8[ni]) )
		PlVlGrB5B(aAlt, cTpArq, cCodOpe, aTabPos, oModel, @oModelIte, aChvAnt, laltChv, aIncLoc)
	next
elseif !empty(aIncLoc)
	PlVlGrB5B(aAlt, cTpArq, cCodOpe, aTabPos, oModel, @oModelIte, aChvAnt, laltChv, aIncLoc)
EndIf

If !ldestroy
	oModelIte:deactivate()
	oModel:deactivate()
else
	oModelIte:DeActivate()
	oModelIte:Destroy()
	oModelIte := nil
	oModel:DeActivate()
	oModel:Destroy()
	oModel := nil
EndIf	

RestArea(aAreaBB8)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PRPSINREG
Faz a inclusão de um Registro em um lote
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
/* 
function PRPSINREG(aAlt, cTipArq, cCodOpe, aTabPos, oModel)

Local lRet   := .F.
Local nI     := 1

default cCodOpe := PLSINTPAD()
default aTabPos := { .F., .F., .F. } //Posição 1, BAU posicionado, Posição 2, BB8 posicionado, Posição 3, B84 posicionado

If oModel:getModel("B5BDetail"):Length() > 1 .OR. oModel:getOperation() <> 3
	oModel:getModel("B5BDetail"):addLine()
EndIf
oModel:getModel("B5BDetail"):GoLine( oModel:getModel("B5BDetail"):Length() )

oModel:getModel("B5BDetail"):LoadValue("B5B_FILIAL" , xfilial("B5B"))
oModel:getModel("B5BDetail"):LoadValue("B5B_CODOPE" , cCodOpe)
oModel:getModel("B5BDetail"):LoadValue("B5B_NUMLOT" , oModel:getModel("MasterB4K"):getValue("B4K_NUMLOT") )

If aTabPos[1]
	oModel:getModel("B5BDetail"):LoadValue("B5B_CODRDA" , BAU->BAU_CODIGO)
EndIf
If aTabPos[2]
	oModel:getModel("B5BDetail"):LoadValue("B5B_CODLOC" , BB8->BB8_CODLOC)
endIf

for nI := 1 To Len(aAlt)

	Do Case
	
		Case atabPos[1] .AND. aAlt[nI] $ "B5B_CLAEST/BAU_CLAEST"
			oModel:getModel("B5BDetail"):LoadValue("B5B_CLAEST", BAU->BAU_CLAEST)
	
		Case atabPos[1] .AND. aAlt[nI] $ "B5B_RAZSOC/BAU_NOME"
			oModel:getModel("B5BDetail"):LoadValue("B5B_RAZSOC", BAU->BAU_NOME)
	
		Case atabPos[1] .AND. aAlt[nI] $ "B5B_RELOPE/BAU_RECPRO"
			oModel:getModel("B5BDetail"):LoadValue("B5B_RELOPE", iif(BAU->BAU_RECPRO == "1", "P", "C") )
					
		Case atabPos[2] .AND. aAlt[nI] $ "B5B_CPFCGC/BB8_CPFCGC"
			oModel:getModel("B5BDetail"):LoadValue("B5B_CPFCGC", BB8->BB8_CPFCGC)
			
		Case atabPos[2] .AND. aAlt[nI] $ "B5B_CNES/BB8_CNES"
			oModel:getModel("B5BDetail"):LoadValue("B5B_CNES", BB8->BB8_CNES)
	
		Case atabPos[2] .AND. aAlt[nI] $ "B5B_UF/BB8_EST"
			oModel:getModel("B5BDetail"):LoadValue("B5B_UF", BB8->BB8_EST)
	
		Case atabPos[2] .AND. aAlt[nI] $ "B5B_CODMUN/BB8_CODMUN"
			oModel:getModel("B5BDetail"):LoadValue("B5B_CODMUN", Substr(BB8->BB8_CODMUN, 1, 6))
		
		Case aTabPos[1] .AND. aAlt[nI] $ "B5B_URGEMG/BAU_URGEME"
			oModel:getModel("B5BDetail"):LoadValue("B5B_URGEMG", iif(BAU->BAU_URGEME == "1", "S", "N") )

		Case aTabPos[1] .AND. aAlt[nI] $ "B5B_DISPSE/BAU_TIPDIS"
			oModel:getModel("B5BDetail"):LoadValue("B5B_DISPSE", IIF(BAU->BAU_TIPDIS == "1", "P", "T") )

		Case aTabPos[1] .AND. aAlt[nI] $ "B5B_DTCONT/BAU_DTINCT"
			oModel:getModel("B5BDetail"):LoadValue("B5B_DTCONT", BAU->BAU_DTINCT)

		Case aTabPos[1] .AND. aAlt[nI] $ "B5B_DTINIS/BAU_DTINSE"
			oModel:getModel("B5BDetail"):LoadValue("B5B_DTINIS", BAU->BAU_DTINSE)		
								
		Case aTabPos[1] .AND. aAlt[nI] $ "B5B_TPCONT/BAU_CONTRA"
			oModel:getModel("B5BDetail"):LoadValue("B5B_TPCONT", IIF(BAU->BAU_CONTRA == "2", "I", "D") )		

	EndCase
Next

Return lRet
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} PRPSINLOT
Faz a inclusão de um lote
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PRPSINLOT(cTipArq, cCodOpe, oModel, cTipCab)

Local lRet   := .F.
default cCodOpe := PLSINTPAD()
default cTipCab := ""

BA0->(dbSetOrder(1))
BA0->(MsSeek(xfilial("BA0")+cCodope))

oModel:GetModel("MasterB4K"):LoadValue("B4K_FILIAL" , xFilial("B4K"))
oModel:GetModel("MasterB4K"):LoadValue("B4K_CODOPE" , cCodOpe)
oModel:GetModel("MasterB4K"):LoadValue("B4K_STATUS" , "0")
oModel:GetModel("MasterB4K"):LoadValue("B4K_TIPARQ" , cTipArq)
oModel:GetModel("MasterB4K"):LoadValue("B4K_REGANS" , BA0->BA0_SUSEP)
oModel:GetModel("MasterB4K"):LoadValue("B4K_CNPJ  " , BA0->BA0_CGC)
oModel:GetModel("MasterB4K"):LoadValue("B4K_DATINS" , Date())
oModel:GetModel("MasterB4K"):LoadValue("B4K_TIPCAB" , cTipCab)
If cTipCab == "1"
	oModel:GetModel("MasterB4K"):LoadValue("B4K_ISENON" , "1") //Sim
Else
	oModel:GetModel("MasterB4K"):LoadValue("B4K_ISENON" , "0") //Não
endIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PRPSIMPARQ
Direciona para a função de geração de arquivo correspondente e faz a marcação de fechamento do lote
@author Oscar Zanin
@since 03/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PRPSIMPARQ(lAutoma)

Local lProcessa := .F.
Local lMarca	  := .T.
Local cCodOpe	 := PLSINTPAD()
Local lMBAU	:= .F.
Local lMB84	:= .F.
Local lExclusao := .F.
Local aGRU		:= { "", .F.}
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 
Private cArqDes := ""

If B4K->B4K_STATUS == "1"
	lProcessa := .T.
	lMarca	   := .F.
elseIf lAutoma .or. MsgYesNo("O lote atual será fechado, confirma a geração?")
	If B4K->B4K_TIPCAB == "0" .AND. empTy(B4K->B4K_NUMGRU)
		aGRU := PLSRPSNGRU()
		If aGRU[2]
			B4K->(recLock("B4K", .F.))
				B4K->B4K_NUMGRU := aGRU[1]
			B4K->(MsUnLock())
			lProcessa := .T.
		else
			Msgalert("Geração cancelada")
		EndIf
	else	
		lProcessa := .T.
	EndIF
endIf

If lProcessa 

	if !lautoma

		cArqDes := cGetFile("Todos Arquivos|*.*|","Selecione o Diretorio destino",0,"",.F.,GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
		
		If (empTy(cArqDes))
			MsgAlert("Caminho destinho do arquivo não selecionado, geração cancelada")
			return
		endIf
	Endif
	If lMarca
		B5B->(DbSetOrder(1))
		BAU->(DbSetOrder(1))
		
		B5B->(MsSeek(xfilial("B5B") + cCodOpe + B4K->B4K_NUMLOT))
		Begin Transaction
			B4K->(RecLock("B4K", .f.))
				B4K->B4K_STATUS := "1"
				B4K->B4K_DATARQ := dDataBase
			B4K->(MsUnLock())
			
			lMBAU := B4K->B4K_TIPARQ $ "0,1"
			lExclusao := B4K->B4K_TIPARQ == "3"
			lMB84 := B4K->B4K_TIPARQ $ "0,1,2"
			
			While !(B5B->(EoF())) .AND. B5B->(B5B_FILIAL + B5B_CODOPE + B5B_NUMLOT) == xfilial("B5B") + cCodOpe + B4K->B4K_NUMLOT
				
				If lMBAU
					If BAU->(MsSeek(xFilial("BAU")+B5B->B5B_CODRDA))
						BAU->(ReCLock("BAU", .F.))
							BAU->BAU_ENVRPS := "1"
						BAU->(MsUnLock())
					endIf
				ElseIf lExclusao
					If BAU->(MsSeek(xFilial("BAU")+B5B->B5B_CODRDA))
						BAU->(ReCLock("BAU", .F.))
							BAU->BAU_ENVRPS := "2"
						BAU->(MsUnLock())
					endIf
				EndIf
				
				If lMB84
					If !(empTy(B5B->B5B_SEQVIN))
						B84->(DbGoto(B5B->B5B_SEQVIN))
						B84->(RecLock("B84", .F.))
							B84->B84_ENVRPS := "1"
						B84->(MsUnLock())
					EndIf
				EndIf
				B5B->(DbSkip())
			endDo
		end Transaction
	EndIf
	
	If B4K->B4K_TIPARQ == "0"
		PRPSRPI(lAutoma)
	ElseIf B4K->B4K_TIPARQ == "1"
		PRPSRPA(lAutoma)
	elseIf B4K->B4K_TIPARQ == "2"
		PRPSRPV(lAutoma)
	ElseIf B4K->B4K_TIPARQ == "3"
		PRPSRPE(lAutoma)
	endIf
endIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PRPSRPI
Gera o arquivo .RPI (referente à inclusão)
@author Oscar Zanin
@since 03/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PRPSRPI(lAutoma)

Local cXml := ""
Local cNiv0 := CRLF
Local cNiv1 := CRLF + CHR(9)
Local cNiv2 := CRLF + CHR(9) + CHR(9)
Local cNiv3 := CRLF + CHR(9) + CHR(9) + CHR(9)
Local cNiv4 := CRLF + CHR(9) + CHR(9) + CHR(9) + CHR(9)
Local cArqLocal	:= ""
Local oModel	:= FWLoadModel( 'PLSRPS5' )
Local oB5B		:= oModel:getmodel('B5BDetail')
Local nI		:= 1
Local cChvAnt	:= ""
Local cXml2	:= ""
Local cXml3	:= ""
Local nK		:= 1
Local aRegplv := {}
Local aCodplv := {}
Local lRegplv := .F.
Local lCodplv := .F.
Local nRegplv := 0
Local nCodplv := 0
default lAutoma := .F.

B5B->(dbsetOrder(1))
oModel:SetOperation( 4 )
oModel:Activate()

cArqLocal := "Lote_" + B4K->B4K_NUMLOT +".RPI"
nHdl := Fcreate("\Data\"+cArqLocal)	

cXML += '<?xml version="1.0" encoding="UTF-8"?>' + cNiv0
cXML += '<operadora>' + cNiv1
cXml += '<registroANS>'+ oModel:getValue("MasterB4K", "B4K_REGANS") +'</registroANS>' + cNiv1
cXml += '<cnpjOperadora>'+ oModel:getValue("MasterB4K", "B4K_CNPJ") +'</cnpjOperadora>' + cNiv1
cXML += '<solicitacao>' + cNiv2

If !(empTy(oModel:getValue("MasterB4K", "B4K_NUMGRU")))
	cXML += '<nossoNumero>'+ Alltrim(oModel:getValue("MasterB4K", "B4K_NUMGRU")) +'</nossoNumero>' + cNiv2
else
	cXML += '<nossoNumero></nossoNumero>' + cNiv2
EndIf

If !(empTy(oModel:getValue("MasterB4K", "B4K_TIPCAB")))
	If oModel:getValue("MasterB4K", "B4K_ISENON") == "1"
		cXML += '<isencaoOnus>S</isencaoOnus>' + cNiv2
	else
		cXML += '<isencaoOnus>N</isencaoOnus>' + cNiv2
	EndIf
else
	cXML += '<isencaoOnus>N</isencaoOnus>' + cNiv2
EndIf

for nI := 1 To oB5B:Length()
	
	oB5B:GoLine( nI )
	
	If cChvAnt <> oB5B:GetValue("B5B_NUMLOT") + oB5B:GetValue("B5B_CODRDA") + oB5B:GetValue("B5B_CODLOC")
		cChvAnt := oB5B:GetValue("B5B_NUMLOT") + oB5B:GetValue("B5B_CODRDA") + oB5B:GetValue("B5B_CODLOC")
		
		cXml2 += '<inclusaoPrestador>' + cNiv3
		cXml2 += '<classificacao>'+ oB5B:GetValue("B5B_CLAEST") +'</classificacao>' + cNiv3
		cXml2 += '<cnpjCpf>'+ Alltrim(oB5B:getValue("B5B_CPFCGC")) +'</cnpjCpf>' + cNiv3
		
		If !(empTy(oB5B:GetValue("B5B_CNES")))
			cXml2 += '<cnes>'+ oB5B:GetValue("B5B_CNES") +'</cnes>' + cNiv3
		else
			cXml2 += '<cnes></cnes>' + cNiv3
		EndIf
		
		cXml2 += '<uf>'+ oB5B:GetValue("B5B_UF") +'</uf>' + cNiv3
		cXml2 += '<codigoMunicipioIBGE>'+ oB5B:GetValue("B5B_CODMUN") +'</codigoMunicipioIBGE>' + cNiv3
		cXml2 += '<razaoSocial>'+ PlAjstCrcXML( oB5B:GetValue("B5B_RAZSOC") ) +'</razaoSocial>' + cNiv3
		cXml2 += '<relacaoOperadora>'+ oB5B:GetValue("B5B_RELOPE") +'</relacaoOperadora>' + cNiv3
		
		If oB5B:GetValue("B5B_RELOPE") == "C"
			cXml2 += '<tipoContratualizacao>'+ oB5B:GetValue("B5B_TPCONT") +'</tipoContratualizacao>' + cNiv3
			If oB5B:GetValue("B5B_TPCONT") == "I"
				cXml2 += '<registroANSOperadoraIntermediaria>'+ oB5B:GetValue("B5B_ANSOPI") +'</registroANSOperadoraIntermediaria>' + cNiv3
			else
				cXml2 += '<registroANSOperadoraIntermediaria></registroANSOperadoraIntermediaria>' + cNiv3
			EndIf
			If !(empTy(oB5B:GetValue("B5B_DTCONT")))
				cXml2 += '<dataContratualizacao>'+ DtoC(oB5B:GetValue("B5B_DTCONT")) +'</dataContratualizacao>' + cNiv3
			else
				cXml2 += '<dataContratualizacao></dataContratualizacao>' + cNiv3
			EndIf
		else
			cXml2 += '<tipoContratualizacao></tipoContratualizacao>' + cNiv3
			cXml2 += '<registroANSOperadoraIntermediaria></registroANSOperadoraIntermediaria>' + cNiv3		
			cXml2 += '<dataContratualizacao></dataContratualizacao>' + cNiv3
		EndIf
		
		cXml2 += '<dataInicioPrestacaoServico>'+ DtoC(oB5B:GetValue("B5B_DTINIS")) +'</dataInicioPrestacaoServico>' + cNiv3
		cXml2 += '<disponibilidadeServico>'+ oB5B:GetValue("B5B_DISPSE") +'</disponibilidadeServico>' + cNiv3
		cXml2 += '<urgenciaEmergencia>'+ oB5B:GetValue("B5B_URGEMG") +'</urgenciaEmergencia>' + cNiv3
		cXml2 += '<vinculacao>'
		
		If oB5B:GetValue("B5B_CLAEST") == "1" .OR. ( oB5B:GetValue("B5B_CLAEST") $ "2/3" .AND. oB5B:GetValue("B5B_URGEMG") == "S" )

			nK := nI

			//Extração das informações de vinculação
			While 	cChvAnt == oB5B:GetValue("B5B_NUMLOT") + oB5B:GetValue("B5B_CODRDA") + oB5B:GetValue("B5B_CODLOC") .AND. nK <= oB5B:Length()
				If !(empTy(oB5B:GetValue("B5B_REGPLV")))
					aadd(aRegplv,Alltrim(oB5B:GetValue("B5B_REGPLV")))
					lRegplv := .T.
				Elseif !(empTy(oB5B:GetValue("B5B_CODPLV")))
					aadd(aCodplv,Alltrim(oB5B:GetValue("B5B_CODPLV")))
					lCodplv := .T.
				Endif
				nK++
				oB5B:GoLine( nK )
			EndDo

			//Construção do Bloco de vinculação
			If lRegplv
				For nRegplv := 1 to len(aRegplv)
					cXml3 += cNiv4 
					cXml3 += '<numeroRegistroPlanoVinculacao>'+ aRegplv[nRegplv] +'</numeroRegistroPlanoVinculacao>'
				Next
			Else
				cXml3 += cNiv4
				cXml3 += '<numeroRegistroPlanoVinculacao></numeroRegistroPlanoVinculacao>'
			Endif
			If lCodplv
				For nCodplv := 1 to len(aCodplv)
					cXml3 += cNiv4 
					cXml3 += '<codigoPlanoOperadoraVinculacao>'+ aCodplv[nCodplv] +'</codigoPlanoOperadoraVinculacao>'
				Next
			Else
				cXml3 += cNiv4
				cXml3 += '<codigoPlanoOperadoraVinculacao></codigoPlanoOperadoraVinculacao>'
			Endif

			cXml3 += cNiv3
			oB5B:GoLine( nI )

		else
			cXml3 += cNiv4
			cXml3 += '<numeroRegistroPlanoVinculacao></numeroRegistroPlanoVinculacao>'
			cXml3 += cNiv4
			cXml3 += '<codigoPlanoOperadoraVinculacao></codigoPlanoOperadoraVinculacao>'// + cNiv3
			cXml3 += cNiv3
		EndIF
		
		cXml3 += '</vinculacao>' + cNiv2
		cXml3 += '</inclusaoPrestador>' 
		
		If nI == oB5B:Length()
			cXml3 += cNiv1
		Else
			cXml3 += cNiv2
		endIf
		cXML := cXML + cXml2 + cXml3
	EndIf
	cXml2 := ""
	cXml3 := ""
	lRegplv := .F.
	lCodplv := .F.
	aRegplv := {}
	aCodplv := {}
Next

cXML += '</solicitacao>' + cNiv0
cXML += '</operadora>'

oModel:DeActivate()

FWRITE(nHdl,cXML)
FCLOSE(nHdl)

if !lAutoma
	If CpyS2T( "\Data\"+cArqLocal, cArqDes, .F. )
		MsgInfo("Arquivo [" + cArqLocal + "] Gerado com sucesso em [" + cArqDes + "] ")
	Else
		Msgalert("Não foi gerado arquivo")
	endIf

	FERASE("\Data\"+cArqLocal)
Endif
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PRPSRPA
Gera o arquivo .RPA (referente à alteração)
@author Oscar Zanin
@since 03/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PRPSRPA(lAutoma)

Local cXml := ""
Local cNiv0 := CRLF
Local cNiv1 := CRLF + CHR(9)
Local cNiv2 := CRLF + CHR(9) + CHR(9)
Local cNiv3 := CRLF + CHR(9) + CHR(9) + CHR(9)
Local cNiv4 := CRLF + CHR(9) + CHR(9) + CHR(9) + CHR(9)
Local cNiv5 := CRLF + CHR(9) + CHR(9) + CHR(9) + CHR(9) + CHR(9)
Local cArqLocal	:= ""
Local oModel	:= FWLoadModel( 'PLSRPS5' )
Local oB5B		:= oModel:getmodel('B5BDetail')
Local nI		:= 1
default lAutoma := .F.

oModel:SetOperation( 4 )
oModel:Activate()

cArqLocal := "Lote_" + B4K->B4K_NUMLOT +".RPA"
nHdl := Fcreate("\Data\"+cArqLocal)	

cXML += '<?xml version="1.0" encoding="UTF-8"?>' + cNiv0
cXML += '<operadora>' + cNiv1
cXml += '<registroANS>'+ oModel:getValue("MasterB4K", "B4K_REGANS") +'</registroANS>' + cNiv1
cXml += '<cnpjOperadora>'+ oModel:getValue("MasterB4K", "B4K_CNPJ") +'</cnpjOperadora>' + cNiv1
cXML += '<solicitacao>' + cNiv2

iF !(empTy(oModel:getValue("MasterB4K", "B4K_TIPCAB"))) .AND. oModel:getValue("MasterB4K", "B4K_TIPCAB") <> "2"
	If oModel:getValue("MasterB4K", "B4K_TIPCAB") == "0" .AND. !(empTy(Alltrim(oModel:getValue("MasterB4K", "B4K_NUMGRU"))))
		cXML += '<nossoNumero>'+ Alltrim(oModel:getValue("MasterB4K", "B4K_NUMGRU")) +'</nossoNumero>' + cNiv2
		cXML += '<isencaoOnus>N</isencaoOnus>' + cNiv2
	ElseIf !(empTy(oModel:getValue("MasterB4K", "B4K_TIPCAB")))
		cXML += '<nossoNumero></nossoNumero>' + cNiv2
		If oModel:getValue("MasterB4K", "B4K_ISENON") == "1"
			cXML += '<isencaoOnus>S</isencaoOnus>' + cNiv2
		else
			cXML += '<isencaoOnus>N</isencaoOnus>' + cNiv2
		EndIf
	else
		cXML += '<nossoNumero></nossoNumero>' + cNiv2
		cXML += '<isencaoOnus>N</isencaoOnus>' + cNiv2
	EndIf
else
	cXML += '<nossoNumero></nossoNumero>' + cNiv2
	cXML += '<isencaoOnus>N</isencaoOnus>' + cNiv2
EndIf

for nI := 1 To oB5B:Length()
	
	oB5B:GoLine( nI )
	
	cXML += '<alteracaoPrestador>' + cNiv3
	cXML += '<identificacao>' + cNiv4
	cXML += '<cnpjCpf>'+ Alltrim(oB5B:getValue("B5B_CHVID1")) +'</cnpjCpf>' + cNiv4
	
	If !(empty(oB5B:GetValue("B5B_CNES")))
		cXML += '<cnes>'+ oB5B:GetValue("B5B_CHVID2") +'</cnes>' + cNiv4
	else
		cXML += '<cnes></cnes>' + cNiv4
	endIf
	
	cXML += '<codigoMunicipioIBGE>'+ oB5B:GetValue("B5B_CHVID3") +'</codigoMunicipioIBGE>' + cNiv3
	cXML += '</identificacao>' + cNiv3
	cXML += '<alterarDados>' + cNiv4
	
	If !(EmpTy(oB5B:GetValue("B5B_CLAEST"))) //Verificar validação para impedir alterar caso o prestador já seja tipo 1
		cXML += '<classificacao>'+ oB5B:GetValue("B5B_CLAEST") +'</classificacao>' + cNiv4
	else
		cXML += '<classificacao></classificacao>' + cNiv4
	EndIF
	
	If !(empTy(oB5B:getValue("B5B_CPFCGC")))
		cXML += '<cnpjCpf>'+ Alltrim(oB5B:getValue("B5B_CPFCGC")) +'</cnpjCpf>' + cNiv4
	else
		cXML += '<cnpjCpf></cnpjCpf>' + cNiv4
	EndIf
	
	If !(empTy(oB5B:GetValue("B5B_CNES")))
		cXML += '<cnes>'+ oB5B:GetValue("B5B_CNES") +'</cnes>' + cNiv4
	else
		cXML += '<cnes></cnes>' + cNiv4
	EndIf
	
	If !(EmpTy(oB5B:GetValue("B5B_CODMUN")))
		cXML += '<uf>'+ oB5B:GetValue("B5B_UF") +'</uf>' + cNiv4
		cXML += '<codigoMunicipioIBGE>'+ oB5B:GetValue("B5B_CODMUN") +'</codigoMunicipioIBGE>' + cNiv4
	else
		cXML += '<uf></uf>' + cNiv4
		cXML += '<codigoMunicipioIBGE></codigoMunicipioIBGE>' + cNiv4
	EndIf
	
	If !(EmpTy(oB5B:GetValue("B5B_RAZSOC")))
		cXML += '<razaoSocial>'+ PlAjstCrcXML( oB5B:GetValue("B5B_RAZSOC") ) +'</razaoSocial>' + cNiv4
	else
		cXML += '<razaoSocial></razaoSocial>' + cNiv4
	EndIf
	
	If !(empTy(oB5B:GetValue("B5B_RELOPE")))
		cXML += '<relacaoOperadora>'+ oB5B:GetValue("B5B_RELOPE") +'</relacaoOperadora>' + cNiv4
	else
		cXML += '<relacaoOperadora></relacaoOperadora>' + cNiv4
	EndIf
	
	If !(EmpTy(oB5B:GetValue("B5B_TPCONT"))) //.OR. oB5B:GetValue("B5B_RELOPE") == "C"
		cXML += '<tipoContratualizacao>'+ oB5B:GetValue("B5B_TPCONT") +'</tipoContratualizacao>' + cNiv4
	else
		cXML += '<tipoContratualizacao></tipoContratualizacao>' + cNiv4
	EndIf
	
	If !(empty(oB5B:GetValue("B5B_ANSOPI")))//oB5B:GetValue("B5B_RELOPE") == "C" .AND. oB5B:GetValue("B5B_TPCONT") == "I"
		cXML += '<registroANSOperadoraIntermediaria>'+ oB5B:GetValue("B5B_ANSOPI") +'</registroANSOperadoraIntermediaria>' + cNiv4
	else
		cXML += '<registroANSOperadoraIntermediaria></registroANSOperadoraIntermediaria>' + cNiv4
	EndIf
	
	If !(empty(oB5B:GetValue("B5B_DTCONT")))
		cXML += '<dataContratualizacao>'+ DtoC(oB5B:GetValue("B5B_DTCONT")) +'</dataContratualizacao>' + cNiv4
	else
		cXML += '<dataContratualizacao></dataContratualizacao>' + cNiv4
	endIf

	If !(empTy(oB5B:GetValue("B5B_DTINIS")))
		cXML += '<dataInicioPrestacaoServico>'+ DtoC(oB5B:GetValue("B5B_DTINIS")) +'</dataInicioPrestacaoServico>' + cNiv4
	else
		cXML += '<dataInicioPrestacaoServico></dataInicioPrestacaoServico>' + cNiv4
	EndIf
	
	If !(EmpTy(oB5B:GetValue("B5B_DISPSE")))
		cXML += '<disponibilidadeServico>'+ oB5B:GetValue("B5B_DISPSE") +'</disponibilidadeServico>' + cNiv4
	else
		cXML += '<disponibilidadeServico></disponibilidadeServico>' + cNiv4
	EndIf
	
	If !(empTy(oB5B:GetValue("B5B_URGEMG")))
		cXML += '<urgenciaEmergencia>'+ oB5B:GetValue("B5B_URGEMG") +'</urgenciaEmergencia>' + cNiv4
	else
		cXML += '<urgenciaEmergencia></urgenciaEmergencia>' + cNiv4
	EndIf
	
	cXML += '<vinculacao>'
	If oB5B:GetValue("B5B_URGEMG") == "S" .OR. oB5B:GetValue("B5B_CLAEST") == "1"
		cXML += cNiv5
		If !(empTy(oB5B:GetValue("B5B_REGPLV")))
			cXML += '<numeroRegistroPlanoVinculacao>'+ Alltrim(oB5B:GetValue("B5B_REGPLV")) +'</numeroRegistroPlanoVinculacao>'
			cXML += cNiv5
			cXML += '<codigoPlanoOperadoraVinculacao></codigoPlanoOperadoraVinculacao>'
		else
			cXML += '<numeroRegistroPlanoVinculacao></numeroRegistroPlanoVinculacao>'
			cXML += cNiv5
			cXML += '<codigoPlanoOperadoraVinculacao>'+ Alltrim(oB5B:GetValue("B5B_CODPLV")) +'</codigoPlanoOperadoraVinculacao>'
		EndIf
		cXML += cNiv4
	Else
		cXML += cNiv5
		cXML += '<numeroRegistroPlanoVinculacao></numeroRegistroPlanoVinculacao>'
		cXML += cNiv5
		cXML += '<codigoPlanoOperadoraVinculacao></codigoPlanoOperadoraVinculacao>'
		cXML += cNiv4
	EndIf
	cXML += '</vinculacao>' + cNiv3
	cXML += '</alterarDados>' + cNiv2
	cXML += '</alteracaoPrestador>'

	If nI == oB5B:Length()
		cXML += cNiv1
	Else
		cXML += cNiv2
	endIf
	
Next

cXML += '</solicitacao>' + cNiv0
cXML += '</operadora>'

oModel:DeActivate()

FWRITE(nHdl,cXML)
FCLOSE(nHdl)

if !lAutoma		
	If CpyS2T( "\Data\"+cArqLocal, cArqDes, .F. )
		MsgInfo("Arquivo [" + cArqLocal + "] Gerado com sucesso em [" + cArqDes + "] ")
	Else
		Msgalert("Não foi gerado arquivo")
	endIf

	FERASE("\Data\"+cArqLocal)
endif
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PRPSRPE
Gera o arquivo .RPE (referente à exclusão)
@author Oscar Zanin
@since 03/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PRPSRPE(lAutoma)

Local cXml := ""
Local cNiv0 := CRLF
Local cNiv1 := CRLF + CHR(9)
Local cNiv2 := CRLF + CHR(9) + CHR(9)
Local cNiv3 := CRLF + CHR(9) + CHR(9) + CHR(9)
Local cNiv4 := CRLF + CHR(9) + CHR(9) + CHR(9) + CHR(9)
Local cArqLocal	:= ""
Local oModel	:= FWLoadModel( 'PLSRPS5' )
Local oB5B		:= oModel:getmodel('B5BDetail')
Local nI		:= 1
default lAutoma := .F.

oModel:SetOperation( 4 )
oModel:Activate()

cArqLocal := "Lote_" + B4K->B4K_NUMLOT +".RPE"
nHdl := Fcreate("\Data\"+cArqLocal)	

cXML += '<?xml version="1.0" encoding="UTF-8"?>' + cNiv0
cXML += '<operadora>' + cNiv1
cXml += '<registroANS>'+ oModel:getValue("MasterB4K", "B4K_REGANS") +'</registroANS>' + cNiv1
cXml += '<cnpjOperadora>'+ oModel:getValue("MasterB4K", "B4K_CNPJ") +'</cnpjOperadora>' + cNiv1
cXML += '<solicitacao>' + cNiv2

for nI := 1 To oB5B:Length()
	
	oB5B:GoLine( nI )
	cXML += '<exclusaoPrestador>' + cNiv3
	cXML += '<identificacao>' + cNiv4
	cXML += '<cnpjCpf>'+ Alltrim(oB5B:getValue("B5B_CHVID1")) +'</cnpjCpf>' + cNiv4
	cXML += '<cnes>'+ AllTrim(oB5B:GetValue("B5B_CHVID2")) +'</cnes>' + cNiv4 //deve-se enviar a tag cnes mesmo estando vazia, para que não ocorra erro de estrutura no portal da ANS.
	cXML += '<codigoMunicipioIBGE>'+ oB5B:GetValue("B5B_CHVID3") +'</codigoMunicipioIBGE>' + cNiv3
	cXML += '</identificacao>' + cNiv2
	cXML += '</exclusaoPrestador>'

	If nI == oB5B:Length()
		cXML += cNiv1
	Else
		cXML += cNiv2
	endIf
	
Next

cXML += '</solicitacao>' + cNiv0
cXML += '</operadora>'

oModel:DeActivate()

FWRITE(nHdl,cXML)
FCLOSE(nHdl)
		
if !lAutoma		
	If CpyS2T( "\Data\"+cArqLocal, cArqDes, .F. )
		MsgInfo("Arquivo [" + cArqLocal + "] Gerado com sucesso em [" + cArqDes + "] ")
	Else
		Msgalert("Não foi gerado arquivo")
	endIf

	FERASE("\Data\"+cArqLocal)
Endif
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PRPSRPV
Gera o arquivo .RPV (referente à vinculação)
@author Oscar Zanin
@since 03/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PRPSRPV(lAutoma)

Local cXml 		:= ""
Local cNiv0 	:= CRLF
Local cNiv1 	:= CRLF + CHR(9)
Local cNiv2 	:= CRLF + CHR(9) + CHR(9)
Local cNiv3 	:= CRLF + CHR(9) + CHR(9) + CHR(9)
Local cNiv4 	:= CRLF + CHR(9) + CHR(9) + CHR(9) + CHR(9)
Local cArqLocal	:= ""
Local oModel	:= FWLoadModel( 'PLSRPS5' )
Local oB5B		:= oModel:getmodel('B5BDetail')
Local lCnpj 	:= .f.
Local cCnpj 	:= ""
local cOrdB5B 	:= ""
local nZera 	:= 0 
default lAutoma := .F.

oModel:SetOperation( 4 )
oModel:Activate()

cArqLocal := "Lote_" + B4K->B4K_NUMLOT +".RPV"
nHdl := Fcreate("\Data\"+cArqLocal)	

cXML += '<?xml version="1.0" encoding="UTF-8"?>' + cNiv0
cXML += '<operadora>' + cNiv1
cXml += '<registroANS>'+ oModel:getValue("MasterB4K", "B4K_REGANS") +'</registroANS>' + cNiv1
cXml += '<cnpjOperadora>'+ oModel:getValue("MasterB4K", "B4K_CNPJ") +'</cnpjOperadora>' + cNiv1
cXML += '<solicitacao>' + cNiv2

iF !(empTy(oModel:getValue("MasterB4K", "B4K_TIPCAB"))) .AND. oModel:getValue("MasterB4K", "B4K_TIPCAB") <> "2"
	If oModel:getValue("MasterB4K", "B4K_TIPCAB") == "0" .AND. !(empTy(Alltrim(oModel:getValue("MasterB4K", "B4K_NUMGRU"))))
		cXML += '<nossoNumero>'+ Alltrim(oModel:getValue("MasterB4K", "B4K_NUMGRU")) +'</nossoNumero>' + cNiv2
		cXML += '<isencaoOnus>N</isencaoOnus>' + cNiv2
	ElseIf !(empTy(oModel:getValue("MasterB4K", "B4K_TIPCAB")))
		cXML += '<nossoNumero></nossoNumero>' + cNiv2
		If oModel:getValue("MasterB4K", "B4K_ISENON") == "1"
			cXML += '<isencaoOnus>S</isencaoOnus>' + cNiv2
		else
			cXML += '<isencaoOnus>N</isencaoOnus>' + cNiv2
		EndIf
	EndIf
EndIf

cOrdB5B := ordB5B(oModel:getValue("MasterB4K", "B4K_CODOPE"), oModel:getValue("MasterB4K", "B4K_NUMLOT"))

while !(cOrdB5B)->(eof())
 	
	if cCnpj != Alltrim((cOrdB5B)->B5B_CHVID1)
		cCnpj :=  Alltrim((cOrdB5B)->B5B_CHVID1)
		lCnpj := .t.

		if nZera > 0
			cXML += '</vinculacao>' + cNiv2
			cXml += '</vinculacaoPrestadorRede>'
			iif(nZera == oB5B:Length(),cXML += cNiv1,cXML += cNiv2)
		endif

	else 
		lCnpj := .f.
	endif
  
    if lCnpj 
		cXML += '<vinculacaoPrestadorRede>' + cNiv3
		cXML += '<prestador>' + cNiv4
		cXML += '<cnpjCpf>'+ Alltrim((cOrdB5B)->B5B_CHVID1) +'</cnpjCpf>' + cNiv4

		If !(empty(oB5B:GetValue("B5B_CHVID2")))
			cXML += '<cnes>'+ Alltrim((cOrdB5B)->B5B_CHVID2) +'</cnes>' + cNiv4
		else
			cXML += '<cnes></cnes>' + cNiv4
		endIf

		cXML += '<codigoMunicipioIBGE>'+ Alltrim((cOrdB5B)->B5B_CHVID3) +'</codigoMunicipioIBGE>' + cNiv3
		cXML += '</prestador>' + cNiv3 
		cXML += '<vinculacao>' + cNiv4

	ENDIF

	If !empTy((cOrdB5B)->B5B_REGPLV)
		cXML += '<numeroRegistroPlanoVinculacao>'+ Alltrim((cOrdB5B)->B5B_REGPLV)  +'</numeroRegistroPlanoVinculacao>' + cNiv3
		cXML += '<codigoPlanoOperadoraVinculacao></codigoPlanoOperadoraVinculacao>' + cNiv3
	Else
		cXML += '<numeroRegistroPlanoVinculacao></numeroRegistroPlanoVinculacao>' + cNiv3
		cXML += '<codigoPlanoOperadoraVinculacao>'+ Alltrim((cOrdB5B)->B5B_CODPLV)  +'</codigoPlanoOperadoraVinculacao>' + cNiv3
	EndIf

	nZera++

	(cOrdB5B)->(dbskip())
ENDDO

cXML += '</vinculacao>' + cNiv2
cXML += '</vinculacaoPrestadorRede>' + cNiv1

(cOrdB5B)->(dbclosearea())

cXML += '</solicitacao>' + CRLF
cXML += '</operadora>'

oModel:DeActivate()

FWRITE(nHdl,cXML)
FCLOSE(nHdl)

if !lAutoma		
	If CpyS2T( "\Data\"+cArqLocal, cArqDes, .F. )
		MsgInfo("Arquivo [" + cArqLocal + "] Gerado com sucesso em [" + cArqDes + "] ")
	Else
		Msgalert("Não foi gerado arquivo")
	endIf

	FERASE("\Data\"+cArqLocal)
Endif 
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PRPSPERVIN
Função para validar se será permitida a vinculação daquele Prestador
Não é permitido realizar vinculação nas seguintes condições:
- Prestador Não Hospitalar e Não atende UrGência/emergência
- A segmentação do plano Não está cadastrada e ele Não é plano anterior à regulamentação (plano não regulamentado)
- O plano é atendimento somente odontológico
- O Plano Não contempla atendimento hospitalar, o Prestador é hospitalar e o prestador Não atende urgência/emergência
@author Oscar Zanin
@since 09/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PRPSPERVIN(nTp)

Local lRet := .F.
Local cMVSegOdon := GetNewPar("MV_PLRPSO", "")
Local cMVSegAmbu := GetNewPar("MV_PLRPSA", "")

Default nTp := 1

If nTp == 1 .AND. BAU->BAU_TIPPRE <> getNewPar("MV_PLSTPHS", "HOS")
	If BAU->BAU_URGEME == "1"
		lRet := .T.
	else
		Msgalert("Não é possível realizar a vinculação, pois o Prestador não é hospitalar e não consta como atendimento de urgência/emergência")
	EndIF
else	
	If empTy(BI3->BI3_CODSEG) .AND. BI3->BI3_APOSRG <> "1"
		Msgalert("O produto saúde está sem segmentação configurada, necessário rever o cadastro do produto saúde para prosseguir")
	elseIf BI3->BI3_CODSEG $ cMVSegOdon
		Msgalert("Não é permitido vincular à planos odontológicos")
	elseIf BI3->BI3_CODSEG $ cMVSegAmbu .AND. BAU->BAU_URGEME == "0"
		MsgAlert("Não é permitido vincular, pois o plano não contempla hospitalar e o prestador não atende urgência/emergência")
	Else
		lRet := .T.
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PRPSCOUNT
Verifica se há beneficiários ativos em determinado produto saúde.
Retorna .T. caso exista, .F. caso não.
@author Oscar Zanin
@since 09/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PRPSCOUNT(cCodPla)

Local lRet := .F.
Local csql := ""
Local nBusca	:= 0
Default cCodPla := ""

nBusca := aScan(PLRP5Get(), { |x| x[1] == cCodPla})

If nBusca == 0
	cSql += " Select count(1) TOTAL from " + RetsqlName("BA1")
	cSql += " Where BA1_FILIAL = '" + xfilial("BA1") + "' AND "
	cSql += " BA1_CODPLA = '" + cCodPla + "' AND "
	csql += " BA1_DATBLO = ' ' AND "
	cSql += " D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSql)),"RPSCOUNT",.F.,.T.)
	
	lRet := RPSCOUNT->TOTAL > 0
	
	RPSCOUNT->(DbCloseArea())
	
	PLRP5Set(cCodPla, lRet)
else
	lRet := PLRP5Get()[nBusca][2]
endIf

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PRPSONTAP
Retornos possíveis:
(Plano)
1 - Plano que contenha Segmentação Hospitalar Com Beneficiários
2 - Plano que contenha Segmentação Hospitalar Sem Beneficiários
3 - Plano não regulamentado
4 - Plano que contenha Segmentação Ambulatorial, sem hospitalar Com Beneficiários
5 - Plano que contenha Segmentação Ambulatorial, sem hospitalar sem Beneficiários
6 - Plano exclusivamente Odontológico (Com ou sem beneficiário)
(RDA)
A - RDA tipo Hospitalar que atende urgência/emergência
B - RDA tipo Hospitalar que Não atende urgência/emergência
C - RDA tipo não hospitalar que atende urgência/emergência
D - RDA tipo não hospitalar que Não atende urgência/emergência

Resultado do retorno:
Se Combinações:
1A, 1B, 1C, 4A, 4C, retorna 0 (Vinculação com declaração de isenção de ônus somente)
2A, 2B, retorna 1 (vinculação com recolhimento de TAP apenas)
2C, 3A, 3B, 3C, 5A, 5C, retorna 2 (Vinculação livre, sem declaração de isenção de ônus e sem TAP)
1D, 2D, 3D, 4B, 4D, 5B, 5D, 6A, 6B, 6C, 6D, retorna em branco (pq não deveria ter vinculação)
@author Oscar Zanin
@since 09/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PRP5QUAD6()

Local cRetPla := ""
Local cRetRDA := ""
Local cRet		:= ""
Local cCodPla := B84->B84_CODPRO
Local cMVSegOdon := GetNewPar("MV_PLRPSO", "")
Local cMVSegHosp := GetNewPar("MV_PLRPSH", "")
Local cMVSegAmbu := GetNewPar("MV_PLRPSA", "")

If BAU->BAU_TIPPRE == getNewPar("MV_PLSTPHS", "HOS")
	If BAU->BAU_URGEME == "1"
		cRetRDA := "A"
	else
		cRetRDA := "B"
	endIf
Else
	If BAU->BAU_URGEME == "1"
		cRetRDA := "C"
	else
		cRetRDA := "D"
	endIf
EndIf

BI3->(dbsetOrder(1))
If BI3->(MsSeek(xFilial("BI3")+B84->B84_CODINT+ccodPla))	
	If BI3->BI3_APOSRG <> "1"
		cRetPla := "3"
	elseIf BI3->BI3_CODSEG $ cMVSegHosp
		If PRPSCOUNT(cCodPla)
			cRetPla := "1"
		else
			cRetPla := "2"
		EndIf
	elseIf BI3->BI3_CODSEG $ cMVSegAmbu
		If PRPSCOUNT(cCodPla)
			cRetPla := "4"
		else
			cRetPla := "5"
		EndIf
	elseIf BI3->BI3_CODSEG $ cMVSegOdon
		cRetPla := "6"
	EndIF
endIf

If (cRetPla + cRetRDA) $ '1A,1B,1C,4A,4C'
	cret := "1"
elseIf (cRetPla + cRetRDA) $ '2A,2B'
	cRet := "0"
elseIf (cRetPla + cRetRDA) $ '2C,3A,3B,3C,5A,5C'
	cRet := "2"
else
	cRet := " "
EndIf

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRP5Set
Função para por valores no array de reaproveitamneto da query de existência
de beneficiários
@author Oscar Zanin
@since 09/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLRP5Set(ccodPla, lBenef)

aadd(aJaValido, {ccodPla, lBenef})

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRP5Get
retorna o array Static aJaValido
@author Oscar Zanin
@since 09/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLRP5Get()

Return aJaValido


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRP5clr
Limpa os valores do array Static aJaValido
@author Oscar Zanin
@since 09/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLRP5clr()

aJaValido := {}

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PRPS6INREG
Faz a inclusão de um Registro em um lote (usando o Model do PLSRPS6)
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PRPS6INREG(aAlt, cTipArq, cCodOpe, aTabPos, oModel, oModelIte, aChvAnt, laltChv, aIncLoc, aLocExcBB8)

Local lRet   := .F.
Local nI     := 1
local aAreaBB8	:= BB8->(getarea())

default cCodOpe := PLSINTPAD()
default aTabPos := { .F., .F., .F. } //Posição 1, BAU posicionado, Posição 2, BB8 posicionado, Posição 3, B84 posicionado
default aChvAnt := { "DEFAULT", "DEFAULT", "DEFAULT" }
default laltChv := .F.
default aIncLoc := {}
default aLocExcBB8	:= {}

If oModelIte:getOperation() == 3
	oModelIte:getModel("MasterB5B"):LoadValue("B5B_FILIAL" , xfilial("B5B"))
	oModelIte:getModel("MasterB5B"):LoadValue("B5B_CODOPE" , cCodOpe)
	oModelIte:getModel("MasterB5B"):LoadValue("B5B_NUMLOT" , oModel:getModel("MasterB4K"):getValue("B4K_NUMLOT") )
	
	If aTabPos[1]
		oModelIte:getModel("MasterB5B"):LoadValue("B5B_CODRDA" , BAU->BAU_CODIGO)
	EndIf
		
	If aTabPos[2]
		If aChvAnt[1] == "DEFAULT"
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_CHVID1" , BB8->BB8_CPFCGC)
		else
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_CHVID1" , aChvAnt[1])
		endIf
	
		If !(empTy(aIncLoc))
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_CODLOC" , aIncLoc[1])
		else
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_CODLOC" , BB8->BB8_CODLOC)
		endIf
		
		If aChvAnt[2] == "DEFAULT"
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_CHVID2" , BB8->BB8_CNES)
		Else
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_CHVID2" , aChvAnt[2])
		endIf
		
		If aChvAnt[3] == "DEFAULT"
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_CHVID3" , Substr(BB8->BB8_CODMUN, 1, 6))
		else
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_CHVID3" , Substr(aChvAnt[3], 1, 6))
		EndIf
	endIf
	
	If aTabPos[3]
		oModelIte:getModel("MasterB5B"):LoadValue("B5B_SEQVIN" , B84->(recno()))
		oModelIte:getModel("MasterB5B"):LoadValue("B5B_REGPLV" , B84->B84_SUSEP)
		oModelIte:getModel("MasterB5B"):LoadValue("B5B_CODPLV" , B84->(B84_CODINT+B84_CODPRO+B84_VERSAO))
	EndIf
elseIf oModelIte:getOperation() == 4 .AND. aChvAnt[1] <> "DEFAULT" .AND. aChvAnt[2] <> "DEFAULT" .AND. aChvAnt[3] <> "DEFAULT" .AND. !(empTy(aIncLoc))

	If EmpTy(oModelIte:getModel("MasterB5B"):getValue("B5B_CHVID1"))
		oModelIte:getModel("MasterB5B"):LoadValue("B5B_CHVID1" , aChvAnt[1])
	endIf
	If EmpTy(oModelIte:getModel("MasterB5B"):getValue("B5B_CODLOC"))
		oModelIte:getModel("MasterB5B"):LoadValue("B5B_CODLOC" , aIncLoc[1])
	endIf
	If EmpTy(oModelIte:getModel("MasterB5B"):getValue("B5B_CHVID2"))
		oModelIte:getModel("MasterB5B"):LoadValue("B5B_CHVID2" , aChvAnt[2])
	endIf
	If EmpTy(oModelIte:getModel("MasterB5B"):getValue("B5B_CHVID3"))
		oModelIte:getModel("MasterB5B"):LoadValue("B5B_CHVID3" , Substr(aChvAnt[3], 1, 6))
	endIf
elseIf oModelIte:getOperation() == 4 .AND. !(empTy(aIncLoc))

	If EmpTy(oModelIte:getModel("MasterB5B"):getValue("B5B_CHVID1"))
		oModelIte:getModel("MasterB5B"):LoadValue("B5B_CHVID1" , aIncLoc[5])
	endIf
	If EmpTy(oModelIte:getModel("MasterB5B"):getValue("B5B_CODLOC"))
		oModelIte:getModel("MasterB5B"):LoadValue("B5B_CODLOC" , aIncLoc[1])
	endIf
	If EmpTy(oModelIte:getModel("MasterB5B"):getValue("B5B_CHVID2"))
		oModelIte:getModel("MasterB5B"):LoadValue("B5B_CHVID2" , aIncLoc[2])
	endIf
	If EmpTy(oModelIte:getModel("MasterB5B"):getValue("B5B_CHVID3"))
		oModelIte:getModel("MasterB5B"):LoadValue("B5B_CHVID3" , Substr(aIncLoc[4], 1, 6))
	endIf	
	
elseIf laltChv .AND. aTabPos[3]
 
	oModelIte:getModel("MasterB5B"):LoadValue("B5B_SEQVIN" , B84->(recno()))
	oModelIte:getModel("MasterB5B"):LoadValue("B5B_REGPLV" , B84->B84_SUSEP)
	oModelIte:getModel("MasterB5B"):LoadValue("B5B_CODPLV" , B84->(B84_CODINT+B84_CODPRO+B84_VERSAO))
	
EndIf

for nI := 1 To Len(aAlt)

	Do Case
	
		Case atabPos[1] .AND. aAlt[nI] $ "B5B_CLAEST/BAU_CLAEST"
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_CLAEST", BAU->BAU_CLAEST)
	
		Case atabPos[1] .AND. aAlt[nI] $ "B5B_RAZSOC/BAU_NOME"
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_RAZSOC", BAU->BAU_NOME)
	
		Case atabPos[1] .AND. aAlt[nI] $ "B5B_RELOPE/BAU_RECPRO"
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_RELOPE", iif(BAU->BAU_RECPRO == "1", "P", "C") )

		Case aTabPos[1] .AND. aAlt[nI] $ "B5B_URGEMG/BAU_URGEME"
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_URGEMG", iif(BAU->BAU_URGEME == "1", "S", "N") )

		Case aTabPos[1] .AND. aAlt[nI] $ "B5B_DISPSE/BAU_TIPDIS"
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_DISPSE", IIF(BAU->BAU_TIPDIS == "1", "P", "T") )

		Case aTabPos[1] .AND. aAlt[nI] $ "B5B_DTCONT/BAU_DTINCT"
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_DTCONT", BAU->BAU_DTINCT)

		Case aTabPos[1] .AND. aAlt[nI] $ "B5B_DTINIS/BAU_DTINSE"
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_DTINIS", BAU->BAU_DTINSE)		
								
		Case aTabPos[1] .AND. aAlt[nI] $ "B5B_TPCONT/BAU_CONTRA"
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_TPCONT", IIF(BAU->BAU_CONTRA == "2", "I", "D") )		
		
		Case atabPos[1] .AND. aAlt[nI] $ "B5B_ANSOPI/BAU_ANSOPI"
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_ANSOPI", BAU->BAU_ANSOPI)
							
		
		Case atabPos[2] .AND. aAlt[nI] $ "B5B_CPFCGC/BB8_CPFCGC"
			If !(EmpTy(aIncLoc))
				oModelIte:getModel("MasterB5B"):LoadValue("B5B_CPFCGC", aIncLoc[5])
			else
				oModelIte:getModel("MasterB5B"):LoadValue("B5B_CPFCGC", BB8->BB8_CPFCGC)
			endIf
			
		Case atabPos[2] .AND. aAlt[nI] $ "B5B_CNES/BB8_CNES"
			If !(EmpTy(aIncLoc))
				oModelIte:getModel("MasterB5B"):LoadValue("B5B_CNES", aIncLoc[2]) //aIncLoc
			else
				oModelIte:getModel("MasterB5B"):LoadValue("B5B_CNES", BB8->BB8_CNES)
			endIf
	
		Case atabPos[2] .AND. aAlt[nI] $ "B5B_UF/BB8_EST"
			If !(EmpTy(aIncLoc))
				oModelIte:getModel("MasterB5B"):LoadValue("B5B_UF", aIncLoc[3])
			else
				oModelIte:getModel("MasterB5B"):LoadValue("B5B_UF", BB8->BB8_EST)
			endIf
			
		Case atabPos[2] .AND. aAlt[nI] $ "B5B_CODMUN/BB8_CODMUN"
			If !(EmpTy(aIncLoc))
				oModelIte:getModel("MasterB5B"):LoadValue("B5B_CODMUN", Substr(aIncLoc[4], 1, 6) )
			else
				oModelIte:getModel("MasterB5B"):LoadValue("B5B_CODMUN", Substr(BB8->BB8_CODMUN, 1, 6) )
			EndIf
			
		Case atabPos[3]
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_REGPLV", B84->B84_SUSEP)
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_CODPLV", B84->(B84_CODINT+B84_CODPRO+B84_VERSAO) )
			oModelIte:getModel("MasterB5B"):LoadValue("B5B_SEQVIN", B84->(recno()) )
			
	EndCase
Next
RestArea(aAreaBB8)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PRPS5ZZZ
faz a Inclusão manual de um lote.
Nessa rotina somente serão gerados lotes de Inclusão, Exclusão e Vinculação
@author Oscar Zanin
@since 11/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PRPS5ZZZ(nPosBAU)
/*
Selecionar todos os BAU marcados pra gerar o RPS, vinculando os BB8 e B84 Existentes
O select deve conter se o RDA está ativo ou não

Pra cada BAU, verificar o tipo de envio que deve ser procedido

Regra:

/////////////////////////////////////////////////////////////////////////////////


- Vinculação: envios de novos registros de vinculação de uma RDA já Incluída. A condição no sistema é o campo BAU_ENVRPS 
estar com conteúdo 1 ou 3 e ser incluído um novo registro na tabela B84 referente à esta RDA (campo B84_ENVRPS com conteúdo 0 ou em branco)

- Exclusão: Informação do fim da prestação de serviços. A condição no sistema é o campo BAU_ENVRPS estar com conteúdo 1 ou 3 
e sofrer bloqueio. Importante, o desbloqueio irá gerar registros para o RPS de inclusão.


/////////////////////////////////////////////////////////////////////////////////

Desprezar registros marcados com BAU_ENVRPS = 2, pois foram excluídos

- Inclusão: Primeiro envio de informações de uma RDA. Não é necessário haver vinculações (registros na tabela B84). 
A condição no sistema é o campo BAU_ENVRPS com valor 0 ou não preenchido.
- Se o campo BAU_ENVRPS estiver em branco, ou com 0, irá gerar um lote de inclusão/Incuir o registro no lote de inclusão
-- O arquivo de inclusão preenche todos os campos do BAU, BB8 e B84, caso houver.
-- Para cada registro gravado, marcar o BAU_ENVRPS com enviado (1) e se gravou algum B84, marcar o B84_ENVRPS com (1) e o
Campo B84_VINCUL com (1) vinculado


- Alteração: envios posteriores alterando dados já informados. A condição no sistema é o campo BAU_ENVRPS estar com 
status 1 (enviado) ou 3 (enviar alteração) -> Essa opção nova será criada nesta atualização. Alterações de vínculo 
além de respeitar o critério anterior, irão verificar se o campo B84_ENVRPS está com conteúdo 3 (enviar alteração, essa opção também será criada nesta implementação)
- Se o campo BAU_ENVRPS estiver com 1 ou com 3 (enviado, ou enviada alteração)
-- Tem que ver das regras especiais que obrigam uma vinculação devido à alteração!!!
-- 


- Exclusão: Informação do fim da prestação de serviços. A condição no sistema é o campo BAU_ENVRPS estar com conteúdo 1 ou 3 
e sofrer bloqueio. Importante, o desbloqueio irá gerar registros para o RPS de inclusão.
- Ao bloquear um prestador que o campo ENVRPS esteja com conteúdo 1 ou 3.
-- Marcar o BAU_ENVRPS com 2, excluído
- Verificar se o desbloqueio gera uma inclusão nova
*/

Local nI := 1
Local nA := 0
Local aAlt		:= {}
Local cTpArq	:= " " // <-Tem que ter esse espaço pq pode compor chave de busca
Local aChvAnt	  := { "DEFAULT", "DEFAULT", "DEFAULT" }
Local nRecAU	:= 0
Local aRecB8	:= {}
Local aRec84	:= {}
Local lGo		:= .F.
Local cCodOpe	:= PLSINTPAD()

Default nPosBAU := 0

BAU->(DbsetOrder(1))
BB8->(DbSetOrder(1))
B84->(dbSetOrder(2))//B84_FILIAL+B84_CODIGO+B84_CODINT+B84_CODLOC+B84_LOCAL+B84_CODPRO+B84_VERSAO+B84_SUSEP
BAU->(dbGotop())

If nPosBAU > 0
	BAU->(dbGoTo(nPosBAU))
EndIf

procRegua(0)
incProc("Verificando o cadastro de Prestadores ")
ProcessMessages()
While !(BAU->(EoF())) .AND. IIF(nPosBAU > 0, nPosBAU == BAU->(Recno()), .T.)
	
	If BAU->BAU_GERRPS == "1" //Somente RDA que gera RPS
		
		nRecAU := BAU->(Recno())
		
		If BAU->BAU_ENVRPS $ "4" //Se marcado como enviar Exclusão
			cTpArq := "3"
		elseif BAU->BAU_ENVRPS $ " ,0" //se não preenchido, ou marcado como não enviado
			cTpArq := "0"
		EndIf
		
		lGo := !(empTy(cTpArq))
		
		If lGo
			If cTparq == "0" //Se o tipo de arquivo for Inclusão, vai usar todos os campos
				aAlt := {"BAU_NOME"  , "BAU_CPFCGC", "BAU_RECPRO", "BAU_CLAEST", "BAU_DTINCT", "BAU_DTINSE", "BAU_TIPDIS", "BAU_URGEME", "BAU_ANSOPI", "BAU_CONTRA", "BB8_CODMUN", "BB8_EST", "BB8_CNES", "BB8_CPFCGC" }
			Else
				aAlt := {"BAU_NOME"  , "BAU_CPFCGC", "BAU_RECPRO", "BAU_CLAEST", "BAU_DTINCT", "BAU_DTINSE", "BAU_TIPDIS", "BAU_URGEME", "BAU_ANSOPI", "BAU_CONTRA", "BB8_CPFCGC" }
			EndIf
	
			If BB8->(MsSeek(xfilial("BB8") + BAU->BAU_CODIGO))
				While !(BB8->(EoF())) .AND. BB8->BB8_CODIGO == BAU->BAU_CODIGO
					if  empty(BB8->BB8_DATBLO) .OR. BB8->BB8_DATBLO > DATE()
						aadd(aRecB8, BB8->(recno()))
						If B84->(MsSeek(xFilial("B84")+ BAU->BAU_CODIGO + cCodOpe + BB8->BB8_CODLOC))
							while !(B84->(eof())) .AND. BAU->BAU_CODIGO == B84->B84_CODIGO .AND. BB8->BB8_CODLOC == B84->B84_CODLOC
								If BAU->BAU_CLAEST == "1" .OR. ( BAU->BAU_CLAEST $ "2/3" .AND. BAU->BAU_URGEME == "1" )
									aadd(aRec84, {BB8->(recno()), B84->(recno())})
								EndIf
								B84->(dbskip())
							EndDo
						EndIf
					endif
					BB8->(Dbskip())
				endDo
			EndIf

			If !(EmpTy(aRecB8))
				for nI := 1 To Len(aRecB8)
					If !(empTy(aRec84))
						nA := ascan(aRec84, {|x| x[1] == aRecB8[nI]})
						If nA > 0
							While nA > 0
								PLSRPSALT(cCodOpe, nRecAU, aRecB8[nI], aRec84[nA][2], aAlt, cTpArq, aChvAnt,nil,.T.)
								nA := ascan(aRec84, {|x| x[1] == aRecB8[nI]}, nA + 1)
							EndDo
						EndIf
					Else
						PLSRPSALT(cCodOpe, nRecAU, aRecB8[nI], 0, aAlt, cTpArq, aChvAnt,nil,.T.)
					endIf
				Next
			Else
				PLSRPSALT(cCodOpe, nRecAU, 0, 0, aAlt, cTpArq, aChvAnt,nil,.T.)
			endIf
		EndIf
	EndIf

	lGo		:= .F.
	aAlt	:= {}
	cTpArq	:= " "
	nRecAU	:= 0
	aRecB8	:= {}
	aRec84	:= {}
	BAU->(dbskip())
EndDo

PLRP5clr()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPSNGRU
dialog para informar o númeor da GRU utilizada para o recolhimento da TAP
@author Oscar Zanin
@since 24/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRPSNGRU(lAutoma)

LOCAL oFont
LOCAL oDlg
LOCAL nOpca		:= 0
Local aRetorno 	:= {}
Local lStatus		:= .F.
Local cNumGRU		:= Space(TamSx3("B4K_NUMGRU")[1])
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 
//Define a Fonte do Objeto
if !lAutoma
	DEFINE FONT oFont NAME "Arial" SIZE 000,-012 BOLD

	//Cria a Dialog para interação do usuário
	DEFINE MSDIALOG oDlg TITLE "Informe o número da GRU de recolhimento da TAP" FROM 008.2,003.3 TO 020,055 OF GetWndDefault()

	@ 20,30 Say oSay PROMPT "        Para Prosseguir a geração é necessário " SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
	@ 30,30 Say oSay PROMPT "Informar o número da GRU de recolhimento da TAP" SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
	@ 43,65 MSGET oGet1 VAR cNumGRU SIZE 070,10 OF oDlg FONT oFont PIXEL

//Botão Confirmar
	TButton():New(65,080, 'Confirmar',,{|| IIF(PLSRPSVGRU(cNumGRU, @lStatus) /*pré-validação e definição se houve interação com o botão confirmar*/, Eval( {|| nOpca:=1,oDlg:End() } ), nil)},040,012,,,,.T.)
endif
//Ativa a Dialog
if !lAutoma
	ACTIVATE MSDIALOG oDlg CENTERED
Endif
//Grava retorno
AAdd(aRetorno, cNumGRU)
AAdd(aRetorno, lStatus)

Return(aRetorno)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPSVGRU
Validação da tela de informação do número da GRU
@author Oscar Zanin
@since 24/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRPSVGRU(cNumGRU, lStatus)

Local lRet := .F.

If (!Empty(cNumGRU))
	
	lRet := .T.
elseIf MsgYesNo("Não foi informado o número da GRU utilziada para o recolhimento da TAP." + CRLF + "Conforme o manual do RPS, para a situação deste arquivo deve haver recolhimento da TAP." + CRLF + "confirma o prosseguimneto da geração sem esta informação?", "Atenção")

	lRet := .T.
EndIf

lStatus := lRet

Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} PlBscBB8E
Busca os locais de Atendimento no caso de bloqueio de RDA
@author Renan Martins
@since 02/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PlBscBB8E(cCodRda, aRet)
local aAreaBB8 := BB8->(getarea())

BB8->(dbgotop())
BB8->(dbSetOrder(1))
If BB8->(MsSeek(xfilial("BB8") + cCodRda))
	while !BB8->(eof()) .and. BB8->(BB8_FILIAL + BB8_CODIGO) == xFilial("BB8") + cCodRda
		aadd( aRet, BB8->(recno()) )
		BB8->(dbskip())	
	enddo
endif

RestArea(aAreaBB8)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PlVlGrB5B
Gravar itens na B5B
@author Renan Martins
@since 02/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PlVlGrB5B(aAlt, cTpArq, cCodOpe, aTabPos, oModel, oModelIte, aChvAnt, laltChv, aIncLoc)

PRPS6INREG(aAlt, cTpArq, cCodOpe, aTabPos, oModel, @oModelIte, aChvAnt, laltChv, aIncLoc)
	
If (oModelIte:VldData() )
	// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
	oModelIte:CommitData()
else
	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro := oModelIte:GetErrorMessage()
	// A estrutura do vetor com erro é:
	// [1] identificador (ID) do formulário de origem
	// [2] identificador (ID) do campo de origem
	// [3] identificador (ID) do formulário de erro
	// [4] identificador (ID) do campo de erro
	// [5] identificador (ID) do erro
	// [6] mensagem do erro
	// [7] mensagem da solução
	// [8] Valor atribuído
	// [9] Valor anterior
	AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
	AutoGrLog( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
	AutoGrLog( "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
	AutoGrLog( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
	AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
	AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
	AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
	AutoGrLog( "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' )
	AutoGrLog( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']')
	MostraErro()
EndIf
oModelIte:DeActivate()
oModelIte:Destroy()
oModelIte := nil
oModelIte := FWLoadModel( 'PLSRPS6' )
oModelIte:SetOperation( 3 )
oModelIte:Activate()	

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} PlVldB5B
Verifica se já existe um registro na base
@author Pablo Alipio
@since 03/2019
@version P12
/*/
//-------------------------------------------------------------------
function PlsVldB5B( cCodOpe, cNumLot, cCodRda, cCodLoc, nRecnoB84)
local   cSql      := ""
local   lVld	  := .F.

default	cCodOpe	  := ""
default	cNumLot	  := ""
default cCodRda   := ""
default cCodLoc   := ""
default nRecnoB84 := 0

B5B->(dbSetOrder(1))
cSql := " SELECT COUNT(1) REC FROM " + RetSqlName("B5B")
cSql += " WHERE B5B_FILIAL = '" + xFilial("B5B") + "' "
cSql += " AND B5B_CODOPE = '" + cCodOpe + "' "
cSql += " AND B5B_NUMLOT = '" + cNumLot + "' "
cSql += " AND B5B_CODRDA = '" + cCodRda + "' "
cSql += " AND B5B_CODLOC = '" + cCodLoc + "' "
cSql += " AND B5B_SEQVIN =  " + allTrim(str(nRecnoB84)) + " "
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSql)),"VldB5B",.F.,.T.)

if VldB5B->(REC) > 0
	lVld := .T.
endif

VldB5B->(DbCloseArea())

return lVld


//-------------------------------------------------------------------
/*/{Protheus.doc} PlAjstCrcXML
Ajusta caracteres especiais para o formato aceito no XML RPS
@since 07/2021
@version P12
/*/
//-------------------------------------------------------------------
static function PlAjstCrcXML(cTexto)
local aConvert	:= { {"&", "&amp;"}, {'"', "&quot;"}, {"'", "&apos;"}, {"<", "&lt;"}, {">", "&gt;"} }
local nFor		:= 0
default cTexto	:= ""

if !empty(cTexto)
	for nFor := 1 to len(aConvert)
		if aConvert[nFor, 1] $ cTexto
			cTexto := strtran(cTexto, aConvert[nFor, 1], aConvert[nFor, 2])
		endif
	next
endif
return alltrim(cTexto)


//-------------------------------------------------------------------
/*/{Protheus.doc} ordB5B
ORDENA B5B POR CPF  
@author Daniel Silva Dias 
@since 13/03/2022
@version P12
/*/
//-------------------------------------------------------------------

static function ordB5B(cCodope, cNumlote)

local oFwQuery  := FWPreparedStatement():New()

local cSql := ""
local cAlias := ""

cSql := "SELECT B5B_FILIAL,B5B_CODOPE,B5B_NUMLOT,B5B_CODRDA,B5B_CODLOC,B5B_SEQVIN,B5B_CLAEST,B5B_CNES,B5B_UF, "
cSql += "B5B_CODMUN,B5B_RAZSOC,B5B_TPCONT,B5B_REGINT,B5B_DTCONT,B5B_DTINIS,B5B_DISPSE,B5B_URGEMG,B5B_REGPLV, "  
cSql += "B5B_CPFCGC,B5B_CHVID1,B5B_CHVID2,B5B_CHVID3,B5B_ANSOPI,B5B_CODPLV "
cSql += "FROM " + RetSqlName("B5B") + " B5B "
cSql += "WHERE B5B_FILIAL = ? " 
cSql += "AND B5B_CODOPE = ? " 
cSql += "AND B5B_NUMLOT = ? " 
cSql += "ORDER BY B5B_CHVID1 "

cSql := ChangeQuery(cSql)
oFwQuery:SetQuery(cSql)
oFwQuery:SetString(1, xFilial("B5B"))
oFwQuery:SetString(2, cCodope)
oFwQuery:SetString(3, cNumlote)
cSql := oFwQuery:GetFixQuery()
cAlias := MpSysOpenQuery(cSql)


return cAlias
