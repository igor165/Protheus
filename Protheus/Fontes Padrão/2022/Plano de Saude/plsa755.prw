#Include "PROTHEUS.CH"
#Include 'FWMVCDef.ch'
#INCLUDE "plsa755.ch"
#Include 'TOTVS.ch'

Static lOri368	:= .F.

//-------------------------------------------------------------------
/*/
{Protheus.doc} PLSA755
Débitos/Créditos
@author Julio Cesar C. Teixeira
@since 08/06/2015
@version 12
/*/
//-------------------------------------------------------------------
Function PLSA755()
    
Local oBrowse 

lOri368	:= .F.

dbSelectArea('BGQ')
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BGQ' )
oBrowse:SetDescription( STR0001 )//"Debitos/Creditos Redes de Atendimento"
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/
{Protheus.doc} MenuDef
Definicao das acoes da rotina
@author Julio Cesar C. Teixeira
@since 08/06/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

If lOri368
	ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.PLSA755'	OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0010	ACTION 'VIEWDEF.PLSA755'	OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE "Beneficiários cobertos"	ACTION 'PLS368BenC()'	OPERATION 2 ACCESS 0 //'Visualizar'
else
	ADD OPTION aRotina TITLE STR0006	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0 //'Pesquisar'
	ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.PLSA755'	OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0008	ACTION 'VIEWDEF.PLSA755'	OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0009	ACTION 'VIEWDEF.PLSA755'	OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0010	ACTION 'VIEWDEF.PLSA755'	OPERATION 5 ACCESS 0 //'Excluir'
endif

Return aRotina

//-------------------------------------------------------------------
/*/
{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Julio Cesar C. Teixeira
@since 08/06/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStr1 := FWFormStruct(1,'BGQ')

oModel := MPFormModel():New('PLSA755', /*bPreValidacao*/,{ |oModel| PLSA755Chk(oModel) }, {|oModel| PLSAGrv(oModel) }/*bGrvModel*/, /*bCancel*/ )
oModel:SetDescription(STR0001)		//"Debitos/Creditos Redes de Atendimento"
oModel:addFields('BGQMASTER',,oStr1)
oModel:getModel('BGQMASTER'):SetDescription(STR0001)		//"Debitos/Creditos Redes de Atendimento"
oModel:SetPrimaryKey( {} )

Return oModel
	
//-------------------------------------------------------------------
/*/
{Protheus.doc} ViewDef
Definição do interface
@author Julio Cesar C. Teixeira
@since 08/06/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel	:= ModelDef()
Local oStr1	:= FWFormStruct(2, 'BGQ')

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('FORM1' , oStr1,'BGQMASTER' ) 
oView:CreateHorizontalBox( 'BOXFORM1', 100)
oView:SetOwnerView('FORM1','BOXFORM1')
oView:EnableTitleView('FORM1' , STR0001 ) //"Debitos/Creditos Redes de Atendimento"

Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ o           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA755Qtd(cCodOpe,nQtdCH,cAno,cMes,cPrestador,cFldAtu,cUsAtu)

Local oModel := FWMODELACTIVE()
Local oView  := FWVIEWACTIVE()

BFM->(DbSetOrder(1))
If ! BFM->(DbSeek(xFilial("BFM")+cCodOpe+cAno+cMes))
   Help("",1,"PLSA755QTD")
   Return(.F.)
Endif

If ! Empty(cFldAtu)
	oModel:SetValue('BGQMASTER', cFldAtu, BFM->BFM_VALRDA * nQtdCH)                                                  
Endif

If ! Empty(cUsAtu)                                                 
   oModel:LoadValue('BGQMASTER',cUsAtu,BFM->BFM_VALRDA) 
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AJSVAL    º Autor ³ Nelson Junior      º Data ³  14/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ajusta valor do adicional                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Inclusao de Debito/Credito em Pronto Atendimento           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA755Val()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
Local _Valor1 := 0 
Local _Valor2 := 0 
Local _Hora   := 0
Local _Min    := 0
Local oModel := FWMODELACTIVE()

Static nVlAux755 := 0//Variável criada para controlar a validação do campo "BGQ_VALOR" após conversão para MVC.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Corpo do Programa                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If !Empty(oModel:GetValue('BGQMASTER','BGQ_HORACN'))
	If Substr(oModel:GetValue('BGQMASTER',"BGQ_HORACN"),5,2) == "00"
		_Hora := Val(Substr(oModel:GetValue('BGQMASTER',"BGQ_HORACN"),1,4))
	Else
		_Min  := Val(Alltrim(Substr(oModel:GetValue('BGQMASTER',"BGQ_HORACN"),5,2)))/60
		_Hora := (Val(Substr(oModel:GetValue('BGQMASTER',"BGQ_HORACN"),1,4)) + _Min)
	EndIf
	_Valor1 := (_Hora * (oModel:GetValue('BGQMASTER',"BGQ_USMES") * oModel:GetValue('BGQMASTER',"BGQ_QTDCH")))
EndIf          

If !Empty(oModel:GetValue('BGQMASTER',"BGQ_QTDPAC"))
	If!Empty(oModel:GetValue('BGQMASTER',"BGQ_QTDCH1"))
		_Valor2 := (oModel:GetValue('BGQMASTER',"BGQ_QTDPAC") * oModel:GetValue('BGQMASTER',"BGQ_QTDCH1") * oModel:GetValue('BGQMASTER',"BGQ_USMES"))
	EndIf
Endif

_Valor := (_Valor1 + _Valor2)

nVlAux755 := _Valor

Return _Valor


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA256Chk ³ Autor ³ Angelo Sperandio      ³ Data ³ 19.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de tela                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA755Chk(oModel)

LOCAL lRet := .T.
Local nOpc := oModel:GetOperation()
Local lBGQ_IDCOPR := BGQ->(FieldPos("BGQ_IDCOPR")) > 0

If  BGQ->BGQ_LANAUT == "1"
    lRet := .F.
    If  nOpc == MODEL_OPERATION_UPDATE
    	Help( ,, 'PLSA755ALT',, STR0004, 1, 0)//"Este lançamento não pode ser alterado porque foi gerado de forma automática por outra rotina do sistema."
    Elseif nOpc == MODEL_OPERATION_DELETE
    	Help( ,, 'PLSA755EXC',, STR0002, 1, 0)//"Este lançamento não pode ser excluído porque foi gerado de forma automática por outra rotina do sistema."
    Else
    	lRet := .T.
    Endif	
Else
    If  ! empty(BGQ->BGQ_NUMLOT)
        If  nOpc == MODEL_OPERATION_UPDATE
        	lRet := .F.
        	Help( ,, 'PLSA755ALT',, STR0005, 1, 0)//"Este lançamento não pode ser alterado porque já foi processado pela rotina de pagamento."
        Elseif nOpc == MODEL_OPERATION_DELETE
        	lRet := .F.
        	Help( ,, 'PLSA755EXC',, STR0003, 1, 0)//"Este lançamento não pode ser excluído porque já foi processado pela rotina de pagamento."
        Endif	
    Endif
Endif   

//Valida contrato pré-estabelecido
if lRet .AND. nOpc == MODEL_OPERATION_UPDATE .AND. lBGQ_IDCOPR
	If !(empty(oModel:getModel("BGQMASTER"):getValue("BGQ_IDCOPR")))
		lRet := .F.
		Help(nil, nil , "Atenção", nil, "Não é permitido alterar créditos gerados pela rotina de contrato pré-estabelecido", 1, 0, nil, nil, nil, nil, nil, {""} ) 
	endif
endif

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAGrv()
Comita a inclusão/exlusão do Débito/Crédito nas tabelas BGQ, FJW e FLX 

@author Lucas de Oliveira
@since 17/08/2015
@version P12.1.7
/*/
//-------------------------------------------------------------------
Function PLSAGrv(oModel)
Local lRet			:= .T.
Local nOpc			:= oModel:GetOperation()
Local cPLSCIOE	:= SUPERGETMV("MV_PLSCIOE", .T., "")
Local cFornec		:= Posicione("BAU",1,xFilial("BAU")+BGQ->BGQ_CODIGO,"BAU_CODSA2")
Local cLoja		:= Posicione("BAU",1,xFilial("BAU")+BGQ->BGQ_CODIGO,"BAU_LOJSA2")
Local lImpfinPos	:= BGQ->(fieldPos("BGQ_IMPFIN")) > 0

If oModel:VldData()
	If FwFormCommit(oModel)
		If  nOpc == MODEL_OPERATION_INSERT	
			If BGQ->BGQ_CODLAN == cPLSCIOE
				F027AATU()
			EndIf
		ElseIf nOpc == MODEL_OPERATION_DELETE 
			If lImpfinPos .AND. BGQ->BGQ_CODLAN == cPLSCIOE .AND. BGQ->BGQ_IMPFIN == "1" // Importado				
				F027ADEL(	cFornec;
							,cLoja;								
							,FirstDay(ctod("01/"+ BGQ->BGQ_MES +"/"+ BGQ->BGQ_ANO));
							,LastDay(ctod("01/"+ BGQ->BGQ_MES +"/"+ BGQ->BGQ_ANO)))				
			EndIF
		EndIf
	EndIf
Else   
	cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
	cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
	cLog += cValToChar(oModel:GetErrorMessage()[6])             

	Help( ,,"PLSAGrv",,cLog, 1, 0 )
	lRet := .F.
EndIf

Return lRet


function PLSstat755(lvar)
lOri368 := lVar
return
