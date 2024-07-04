#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "Eicsi410.ch"
#Include "TOPCONN.CH"

/*
Funcao      : EasySI410
Parametros  :
Retorno     :
Objetivos   : Adaptar a rotina de SI para integração com o Logix
Autor       : Jacomo Abenathar Fernandes Lisa
Data/Hora   : 06/05/2014
Revisao     :
Obs.        :
*/

*------------------------*
Function EICSI410()
*------------------------*
Local oBrowse

Private cWork := "",; //nome da work
        aGetDados := {},; // array com informações da GetDados
        cError := ""

Private aColors := {{"BR_VERDE"      , STR0002},; //"Pendente"
                    {"BR_AZUL_CLARO" , STR0014},; //"Pendente - Contrato/ Cotação ERP"
                    {"BR_AZUL"       , STR0003},; //"Em processo de cotação"
                    {"BR_CINZA"      , STR0004},; //"Cotado no mercado nacional"
                    {"BR_AMARELO"    , STR0005},; //"Aguardando Purchase Order"
                    {"BR_PRETO"      , STR0006},; //"Cancelado"
                    {"BR_VERMELHO"   , STR0007}}  //"Atendida - em fase de Purchase Order"
//SetCadSY(.F.)
//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SW1") //Informando o Alias
oBrowse:SetMenuDef("EICSI410") //Nome do fonte do MenuDef
oBrowse:SetExecuteDef(2) //No duplo clique execulta a visualização
oBrowse:SetFilterDefault( "SW1->W1_SEQ == 0" )
oBrowse:SetOnlyFields(AtuSX3()) //Carrega os campos do Sx3 no browse
oBrowse:SetDescription(STR0001) //"Solicitação de Importação"
//Legendas no browse
oBrowse:AddLegend( "W1_STATUS=='A'", aColors[1][1]  , aColors[1][2]) //"Pendente"
oBrowse:AddLegend( "W1_STATUS=='G'", aColors[2][1]  , aColors[2][2]) //"Pendente - Contrato"
oBrowse:AddLegend( "W1_STATUS=='B'", aColors[3][1]  , aColors[3][2]) //"Em processo de cotação"
oBrowse:AddLegend( "W1_STATUS=='C'", aColors[4][1]  , aColors[4][2]) //"Cotado no mercado nacional"
oBrowse:AddLegend( "W1_STATUS=='D'", aColors[5][1]  , aColors[5][2]) //"Aguardando Purchase Order"
oBrowse:AddLegend( "W1_STATUS=='E'", aColors[6][1]  , aColors[6][2]) //"Cancelado"
oBrowse:AddLegend( "W1_STATUS=='F'", aColors[7][1]  , aColors[7][2]) //"Atendida - em fase de Purchase Order"
//oBrowse:AddLegend( "W1_STATUS==''" , "WHITE"  , "Não Preenchido" )

//oBrowse:SetFilterDefault("SW1->W1_MODULO == cModulo")
oBrowse:Activate()

Return Nil
*------------------------*
Static Function MenuDef()
*------------------------*
Local aRotina := {}

//igor chiba 03/06/14 incluri um atalho para as cotaçoes
ADD OPTION aRotina TITLE STR0008 ACTION "CallQC400"    OPERATION 4 ACCESS 0 //"Concorrências"
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.EICSI410" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0016 ACTION "SI410GerPO"    OPERATION 4 ACCESS 0 //"Geração Automática P.O."
ADD OPTION aRotina TITLE STR0015  ACTION "SI410Leg"          OPERATION 2 ACCESS 0  //"Legendas"


Return aRotina


/*
FUNCAO   : CallQC400()
AUTOR    :IGOR CHIBA
DATA     : 03/06/14
OBJETIVO : CHAMAR A ROTINA DE COTAÇÕES COM O PARAMETRO DO ITEM PARA SER FILTRADO
*/
*------------------------*
Function CallQC400()
*------------------------*
If !Empty(SW1->W1_C3_NUM)
   MsgInfo(STR0024,STR0010)  //"Registros de Contratos não devem possuir cotação de preços." ### "Aviso"
Else
   EICQC400(SW1->W1_COD_I,SW1->W1_FILIAL,SW1->W1_CC,SW1->W1_SI_NUM)
EndIf
Return .t.

*-------------------------*
Static Function ModelDef()
*-------------------------*
// Cria a estrutura a ser usada no Modelo de Dados
//Local bCps_SW1 := {|x| ALLTRIM(x) $ "W1_SI_NUM,W1_COD_I,W1_COD_DES,W1_UM,W1_QTDE,W1_SALDO_Q,W1_CC,W1_NR_CONC,W1_DT_CANC,W1_MOTCANC,W1_COMPLEM,W1_C3_NUM,W1_CONDPG,W1_MOEDA,W1_REFER1,W1_PEDERP"}  //SSS - REQ 6.2 INCLUSAO CAMPO W1_UM
Local aCposSW1 := {"W1_SI_NUM","W1_COD_I","W1_COD_DES","W1_UM","W1_QTDE","W1_SALDO_Q","W1_CC","W1_NR_CONC","W1_DT_CANC","W1_MOTCANC","W1_COMPLEM","W1_C3_NUM","W1_CONDPG","W1_MOEDA","W1_REFER1","W1_PEDERP", "W1_DT_SI"}
Local bCps_SYS := {|x| ALLTRIM(x) $ "YS_CC,YS_PERC"}
Local oStruSW1 //:= FWFormStruct( 1, "SW1",bCps_SW1 )
Local oStruELD := FWFormStruct( 1, "ELD")
Local oStruSYS := FWFormStruct( 1, "SYS",bCps_SYS)
Local oModel,npos
Local nRecSX3 , nOrdSX3
Local i, j, cVarCDBloc, bCps_SW1b, aCposUserW1 := {}

aCposUserW1 := AddCpoUser(aCposUserW1,"SW1","1")
cVarCDBloc := '"'
For i:=1 To Len(aCposSW1)
   If i < Len(aCposSW1)
      cVarCDBloc += aCposSW1[i]+','
   Else
      If Len(aCposUserW1)
         For j :=1 To len(aCposUserW1)
            cVarCDBloc += aCposUserW1[j]+','
         Next j
      EndIf
      cVarCDBloc += aCposSW1[i]+'"'
   EndIf
Next i
bCps_SW1b := '{|x| Alltrim(x) $ ' + cVarCDBloc +'}'
bCps_SW1b := &(bCps_SW1b)
oStruSW1 := FWFormStruct( 1, "SW1",bCps_SW1b )

If ( (npos := ascan( oStruSW1:aFields,{|x| alltrim(x[3]) == "W1_COD_DES"})) >0)
   oStruSW1:aFields[npos][11] := {|| Posicione("SB1",1,xFilial("SB1")+SW1->W1_COD_I,"B1_DESC") }
ENDIF

If(Select("ELD") == 0,ChkFile("ELD"),)

oModel := MPFormModel():New( "EICSI410", , {||.T.})

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'SW1MASTER', /*cOwner*/, oStruSW1 )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'ELDDETAIL', 'SW1MASTER', oStruELD, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'SYSDETAIL', 'SW1MASTER', oStruSYS, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )

//Modelo de relação entre Capa(SW1) e detalhe(ELD)
oModel:SetRelation('ELDDETAIL',{{"ELD_FILIAL",'xFilial("ELD")'},{"ELD_CC","W1_CC"},{"ELD_SI_NUM","W1_SI_NUM"}}, ELD->(IndexKey(1)) )
oModel:SetRelation('SYSDETAIL',{{"YS_FILIAL" ,'xFilial("SYS")'},{"YS_TPMODU","'I'"},{"YS_TIPO","'S'"},{"YS_HAWB","W1_SI_NUM"}}, SYS->(IndexKey(1)) )//YS_FILIAL+YS_TPMODU+YS_TIPO+YS_HAWB+YS_FORN+YS_FORLOJ+YS_MOEDA+YS_INVOICE+YS_CC

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001) //##"Solicitação de Importação"


// Adiciona a descrição do Componente do Modelo de Dados
oModel:GetModel( 'SW1MASTER' ):SetDescription(STR0010) //##'Dados da Capa' //Aviso
oModel:GetModel( 'ELDDETAIL' ):SetDescription(STR0011) //##"Dados da Detalhes" //Pesquisar

Return oModel


*------------------------*
Static Function ViewDef()
*------------------------*
// Cria a estrutura a ser usada na View
//Local bCps_SW1 := {|x| ALLTRIM(x) $ "W1_SI_NUM,W1_COD_I,W1_COD_DES,W1_UM,W1_QTDE,W1_SALDO_Q,W1_CC,W1_NR_CONC,W1_DT_CANC,W1_MOTCANC,W1_COMPLEM,W1_C3_NUM,W1_CONDPG,W1_MOEDA,W1_REFER1,W1_PEDERP"} //SSS - REQ 6.2 INCLUSAO CAMPO W1_UM
Local aCposSW1 := {"W1_SI_NUM","W1_COD_I","W1_COD_DES","W1_UM","W1_QTDE","W1_SALDO_Q","W1_CC","W1_NR_CONC","W1_DT_CANC","W1_MOTCANC","W1_COMPLEM","W1_C3_NUM","W1_CONDPG","W1_MOEDA","W1_REFER1","W1_PEDERP","W1_DT_SI"}
Local bCps_SYS := {|x| ALLTRIM(x) $ "YS_CC,YS_PERC"}
Local oStruSW1 //:= FWFormStruct( 2, "SW1",bCps_SW1 )
Local oStruELD := FWFormStruct( 2, "ELD")
Local oStruSYS := FWFormStruct( 2, "SYS",bCps_SYS)
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oView
Local oModel   := FWLoadModel( "EICSI410" )
Local nRecSX3 , nOrdSX3
Local i, j, cVarCDBloc, bCps_SW1b, aCposUserW1 := {}

aCposUserW1 := AddCpoUser(aCposUserW1,"SW1","1")
cVarCDBloc := '"'
For i:=1 To Len(aCposSW1)
   If i < Len(aCposSW1)
      cVarCDBloc += aCposSW1[i]+','
   Else
      If Len(aCposUserW1)
         For j :=1 To len(aCposUserW1)
            cVarCDBloc += aCposUserW1[j]+','
         Next j
      EndIf
      cVarCDBloc += aCposSW1[i]+'"'
   EndIf
Next i
bCps_SW1b := '{|x| Alltrim(x) $ ' + cVarCDBloc +'}'
bCps_SW1b := &(bCps_SW1b)
oStruSW1 := FWFormStruct( 2, "SW1",bCps_SW1b )

oModel:SetPrimaryKey( { "W1_FILIAL", "W1_SI_NUM", "W1_COD_I","W1_REG","W1_SEQ"})
//W1_FILIAL+W1_SI_NUM+W1_COD_I+W1_REG+W1_SEQ

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel )



//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_SW1', oStruSW1, 'SW1MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid( 'VIEW_ELD', oStruELD, 'ELDDETAIL' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid( 'VIEW_SYS', oStruSYS, 'SYSDETAIL' )


oView:CreateHorizontalBox( 'ACIMA'  , 65 /*,,,"IDFOLDER","IDSHEET01"*/) //25
oView:CreateHorizontalBox( 'ABAIXO' , 35 /*,,,"IDFOLDER","IDSHEET01"*/) //75

oView:CreateVerticalBox( 'ESQUERDA' , 70 ,'ABAIXO')
oView:CreateVerticalBox( 'DIREITA'  , 30 ,'ABAIXO')


// Relaciona o ID da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_SW1', 'ACIMA'  )
oView:SetOwnerView( 'VIEW_ELD', 'ESQUERDA' )
oView:SetOwnerView( 'VIEW_SYS', 'DIREITA' )

// Liga a identificação do componente
oView:EnableTitleView( 'VIEW_SW1', STR0001, /*Color - */RGB(240, 248, 255 )) //##"Solicitação de Importação"
oView:EnableTitleView( 'VIEW_ELD', STR0012, /*Color - */RGB(240, 248, 255 ) )//##"Programação de Entregas"
oView:EnableTitleView( 'VIEW_SYS', STR0013, /*Color - */RGB(240, 248, 255 ) )//##"SYS" //"Rateio"

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView

/*
Função  : AtuSX3
Autor   : JACOMO LISA
Data    : 07/05/2014
Objetivo: Atualiza o dicionario para aparecer no browse apenas os campos do aBrowse na nova funcionalidade.
*/
*-----------------------------------------------------*
Static Function AtuSX3()
*-----------------------------------------------------*
LOCAL aBrowse:= {"W1_CC","W1_SI_NUM","W1_COD_I","W1_UM","W1_QTDE","W1_NR_CONC","W1_DT_CANC","W1_MOTCANC","W1_C3_NUM"}  //SSS - REQ 6.2 INCLUSAO CAMPO W1_UM
LOCAL aCpo_SW1 := {}
SX3->(DbSetOrder(1))
If SX3->(DbSeek("SW1"))// .And.
   Do While SX3->( !EOF() ) .And. SX3->X3_ARQUIVO == "SW1"
      IF (ASCAN(aBrowse,ALLTRIM(SX3->X3_CAMPO))>0) .OR. ( (SX3->X3_PROPRI == "U") .AND. (SX3->X3_BROWSE == "S") )
        AADD(aCpo_SW1,ALLTRIM(SX3->X3_CAMPO))
      ENDIF
      SX3->(dbskip())
   ENDDO
EndIf

SX3->(DbSetOrder(1))

Return aCpo_SW1

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix
* Auto: Jacomo Abenathar Fernandes Lisa - 15/05/2014
* =====================================================*/
*--------------------------------------------------------------------*
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
*--------------------------------------------------------------------*
Local oEasyIntEAI
Local cAlias:="SG1"
Private aOrderAuto

    aOrderAuto := {{"SW1",2}}//Para mudar a ordem da validacao da chave

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)

	oEasyIntEAI:oMessage:SetVersion("1.007")
	oEasyIntEAI:oMessage:SetMainAlias("SW0")
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EICSI400(oEasyMessage:GetEAutoArray("SW0"),;
	                                                            oEasyMessage:GetEAutoArray("SW1"),;
	                                                            oEasyMessage:GetOperation()      ,;
	                                                            oEasyMessage:GetEAutoArray("ELD"),;
	                                                            oEasyMessage:GetEAutoArray("SYS"))} )
	oEasyIntEAI:SetModule("EIC",17)
	// Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "SI400RECB") //RECEBIMENTO DE BUSINESS MESSAGE     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "SI400RESB") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)
	//
	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()

*------------------------------------------------*
Function SI400RECB(oMessage)
*------------------------------------------------*
Local oBusinessCont     := oMessage:GetMsgContent(),nCont
Local oBusinesEvent     := oMessage:GetEvtContent()
Local oRequestItem
Local oDeliverySchedule
Local oApportionRequestItem
Local oOtherItem, oOthFields, aOtherFields:= {}
Local cEvento       := Upper(EasyGetXMLinfo(,oBusinesEvent,"_Event"))


Local oBatch     := EBatch():New()
Local oSW0       := ERec():New()//Arrays com os Registros da capa da SI
Local oSW1s      := ETab():New()//Registros da SW1
Local oSW1       := ERec():New()//Arrays com os Registros da SW1
Local oELDs      := ETab():New()//Registros da ELD
Local oSYSs      := ETab():New()//Registros da ELD

Local oExecAuto  := EExecAuto():New()
LOCAL cCodUnReq  := AVKEY("99999","W0__CC")
LOCAL cComprador := AVKEY("999","W0_COMPRA")
LOCAL aArrayELD  := {}, aOthFields := {}, i, aValues := {}
Local cDadosCompl:= ""

//Caso não possua um cadatro padrão, irá cria-lo
SW1->(DBSETORDER(1))
SY1->(DBSETORDER(1))//AAF 24/02/2017 - Para validar o comprador.
//SetCadSY(.F.)

cSi_Num  := EasyGetXMLinfo("W1_SI_NUM" , oBusinessCont, "_Number")
cSi_Num  := AvKey(cSi_Num, "W1_SI_NUM")

If cEvento = "DELETE"

	SW1->(DbSeek(xFilial("SW1")+cCodUnReq+cSi_Num))

	//SW0
	oSW0:SetField("W0__NUM", cSi_Num) //Codigo da SI (W1_SI_NUM)
   	oSW0:SetField("W0__CC" , cCodUnReq) //Codigo da Unidade Requisitante

   	oExecAuto:SetField("SW0",oSW0)//Registros da Capa

   	//SW1
   	oSW1:SetField("W1_SI_NUM", cSi_Num) //Codigo da SI (W1_SI_NUM)
   	oSW1:SetField("W1_COD_I" , SW1->W1_COD_I) //Codigo do Item (W1_COD_I)
   	oSW1:SetField("W1_DTENTR_", SW1->W1_DTENTR_) //Data de Entrega Prevista(W1_DTENTR_)
  	oSW1:SetField("W1_REG"     , SW1->W1_REG )
 	oSW1:SetField("W1_SALDO_Q" , SW1->W1_SALDO_Q) //Saldo
	oSW1:SetField("W1_QTDE"   , SW1->W1_QTDE) //Quantidade Solicitada(W1_QTDE)
   	oSW1s:AddRec(oSW1)//Arrays com os Registros dos Itens
   	oExecAuto:SetField("SW1",oSW1s)//Arrays com os Registros dos Itens

Else

   oRequestItem      		:= oBusinessCont:_ListOfRequestItem:_RequestItem
   //wfs - ListOfDeliverySchedule não obrigatório
   If IsCpoInXML(oRequestItem,"_ListOfDeliverySchedule")
      oDeliverySchedule 		:= oRequestItem:_ListOfDeliverySchedule:_DeliverySchedule
   Else
      oDeliverySchedule:= {}
   EndIf

   If IsCpoInXML(oRequestItem,"_ListOfApportionRequestItem")
      oApportionRequestItem	:= oRequestItem:_ListOfApportionRequestItem:_ApportionRequestItem
   Else
      oApportionRequestItem:= {}
   EndIf

   If IsCpoInXML(oRequestItem,"_Other")
      oOtherItem               := oRequestItem:_Other
   EndIf

   //GFP - 19/05/2016 - Dados de Contratos
   /*If IsCpoInXML(oRequestItem,"_Other")
      Do While Len(aOthFields) == 0
         oOthFields := oOtherItem:_ADDFIELDS:_ADDFIELD
         For i := 1 To Len(oOthFields)
            aAdd(aOthFields,{oOthFields[i]:_Field:Text,oOthFields[i]:_Value:Text})
         Next i
      EndDo
   EndIf*/

   If IsCpoInXML(oRequestItem,"_Other")
      //Do While Len(aOthFields) == 0 //wfs ???? pra que???/
         //wfs - podem existir N oOtherItem na mensagem
         If ValType(oOtherItem:_ADDFIELDS:_ADDFIELD) == "O"
            AAdd(aOtherFields, oOtherItem:_ADDFIELDS:_ADDFIELD)
         Else
            aOtherFields:= AClone(oOtherItem:_ADDFIELDS:_ADDFIELD)
         EndIf
         For nCont:= 1 To Len(aOtherFields)
            oOthFields := aOtherFields[nCont]
            If ValType(oOthFields) == "O" .AND. oOthFields:_Field:Text == "AGRUPADOR"
                //aCampos := {"FORNECEDOR","MOEDA","CONTRATO","AGRUPADOR","PEDIDOLOGIX","IND_COTACAO_LOGIX"} //AAF 07/04/2017 - Novo campo de indicador de cotação realizada no Logix ao invés do fluxo normal de contrato.
                aCampos := {"FORNECEDOR","MOEDA","CONTRATO","AGRUPADOR","CHAVE_COMERCIAL","IND_COTACAO_LOGIX"} //wfs - a informção pedido é descartada pelo LOGIX após a integração da ordem; em set/2016 essa informação foi substituída pela chave comercial, que é composta por: 2 posições para Código da Empresa, 3 pra Condição de Pagamento, 2 para Modo de Embarque e 3 para Código do Comprador
                aValues := StrTokArr(oOthFields:_Value:Text,"|")
                For i := 1 To Len(aValues)
                   If i # 5
                      If i <= Len(aCampos) //AAF 07/04/2017 - Validação para estrutura invalida recebida do Logix.
                          aAdd(aOthFields,{aCampos[i],aValues[i]})
                      Else
                          cEsperado := ""
                          aEval(aCampos,{|X| cEsperado += X+"|"})
                          cEsperado := Left(cEsperado,Len(cEsperado)-1)
                          oMessage:Error("Agrupador inválido: '"+oOthFields:_Value:Text+"'. Era esperada estrutura: "+cEsperado)
                          Return oBatch
                      EndIf
                   Else
                      aOthFields[Len(aOthFields)][2] := oOthFields:_Value:Text //NCF - 31/10/2016 - Pegar o agrupador inteiro.
                   EndIf
                Next i
            EndIf
         Next nCont
      //EndDo
   EndIf

   cCodItem := EasyGetXMLinfo("W1_COD_I"  , oRequestItem , "_ItemCode")
   cCodItem := AvKey(cCodItem, "W1_COD_I")

   //SW0
   oSW0:SetField("W0__NUM"  , AVKEY(cSi_Num,"W1_SI_NUM") ) //Codigo da SI (W1_SI_NUM)
   oSW0:SetField("W0__CC"   , cCodUnReq ) //Codigo da Unidade Requisitante
   oSW0:SetField("W0__DT"   , dDataBase ) //Data da SI
   
   If IsCpoInXML(oBusinessCont,"_UserRequesterCode")
      cComprXML := oBusinessCont:_UserRequesterCode:TEXT //16|33|54557
   Else
      cComprXML := ""
   Endif
   
   If !Empty(cComprXML)      
	  If At("|",cComprXML) > 0
	     cComprXML := Substr(cComprXML,At("|",cComprXML)+1,Len(cComprXML))
		 
		 If At("|",cComprXML) > 0
			cComprXML := Left(cComprXML,At("|",cComprXML)-1)
		 Else
			cComprXML := ""
		 EndIF
	  ELSE
		cComprXML := ""
	  EndIf
   EndIf
   
   If !Empty(cComprXML) .AND. SY1->(DBSeek(xFilial() + AvKey(cComprXML,"W0_COMPRA")))//AAF 24/02/2017 - Tratamento da nova tag de comprador
      oSW0:SetField("W0_COMPRA" , cComprXML )
   ELSE
      oSW0:SetField("W0_COMPRA", cComprador ) //Codigo do Comprador
   EndIf

   //SW1
   oSW1:SetField("W1_SI_NUM" , AVKEY(cSi_Num,"W1_SI_NUM") ) //Codigo da SI (W1_SI_NUM)
   oSW1:SetField("W1_COD_I"  , upper(cCodItem) ) //Codigo do Item (W1_COD_I)
   oSW1:SetField("W1_DTENTR_", EasyGetXMLinfo("W1_DTENTR_", oBusinessCont, "_DeliveryDateTime") ) //Data de Entrega Prevista(W1_DTENTR_)
   IF SW1->(DBSEEK(xFilial("SW1")+cCodUnReq+cSi_Num+cCodItem )) // Caso for Alteração, mandar Saldo e o Reg, se não, só a quantidade
      oSW1:SetField("W1_REG"     , SW1->W1_REG )
      oSW1:SetField("W1_SALDO_Q" , EasyGetXMLinfo("W1_SALDO_Q", oRequestItem , "_Quantity") ) //Saldo
   ELSE
      oSW1:SetField("W1_QTDE"   , EasyGetXMLinfo("W1_QTDE", oRequestItem , "_Quantity") ) //Qntidade Solicitada(W1_QTDE)
   ENDIF


   //WFS 31/07/14 - cancelamento do cancelamento...
   oSW1:SetField("W1_MOTCANC"   , "" )
   oSW1:SetField("W1_DT_CANC"   , StoD("") )

   //GFP - 19/05/2016 - Dados de Contratos
   If Len(aOthFields) # 0 .AND. aScan(aOthFields,{|x| x[1] == "CONTRATO" }) # 0
      For i := 1 To Len(aOthFields)
         Do Case
            Case aOthFields[i][1] == "CONTRATO"
               oSW1:SetField("W1_C3_NUM"   , AvKey(aOthFields[i][2],"W1_C3_NUM"))
            Case aOthFields[i][1] == "FORNECEDOR"
               oSW1:SetField("W1_FORN"   , AvKey(aOthFields[i][2],"W1_FORN"))
               oSW1:SetField("W1_FORLOJ" , ".")
            Case aOthFields[i][1] == "MOEDA"
               //SYF->(DbSetOrder(4)) // YF_FILIAL+YF_CODCERP
               //If SYF->(DbSeek(xFilial("SYF")+AvKey(aOthFields[i][2],"YF_CODCERP")))
               oSW0:SetField("W0_MOEDA"   , EasyConvCod(aOthFields[i][2],"SYF") )
               //EndIf
            Case aOthFields[i][1] == "AGRUPADOR"
               oSW0:SetField("W0_REFER1"   , AvKey(aOthFields[i][2],"W0_REFER1"))
            Case aOthFields[i][1] == "IND_COTACAO_LOGIX" .And. Alltrim(aOthFields[i][2]) == "2"//wfs - cotação criada e designada pelo ERP
               cDadosCompl:= " - Cotação ERP"
         End Case
      Next i
   EndIf

   //igor chiba 18/06/2014 campo novo
   oSW1:SetField("W1_COMPLEM"   , AllTrim(EasyGetXMLinfo("W1_COMPLEM", oRequestItem , "_text")) + cDadosCompl)

   oSW1:SetField("W1_PRECO"   , EasyGetXMLinfo("W1_PRECO", oRequestItem , "_UnitPrice") )

   If IsCpoInXML(oBusinessCont,"_PaymentConditionInternalId")
      //SY6->(DbSetOrder(2))
      //If SY6->(DbSeek(xFilial("SY6")+EasyGetXMLinfo("Y6_CODERP", oBusinessCont , "_PaymentConditionInternalId")))
         oSW1:SetField("W1_CONDPG" , EasyConvCod(EasyGetXMLinfo("Y6_CODERP", oBusinessCont , "_PaymentConditionInternalId"),"SY6") )
      //EndIf
   EndIf

   oSW1s:AddRec(oSW1)//Arrays com os Registros dos Itens
   oExecAuto:SetField("SW0",oSW0)//Registros da Capa
   oExecAuto:SetField("SW1",oSW1s)//Arrays com os Registros dos Itens

   //ELD
   If ValType(oDeliverySchedule) <> "A"
      aArrayELD := {oDeliverySchedule}
   Else
      aArrayELD := oDeliverySchedule
   EndIf

   FOR nCont := 1 TO LEN(aArrayELD)
       oELD := ERec():New()//Arrays com os Registros da ELD

       oELD:SetField("ELD_SI_NUM", AVKEY(cSi_Num,"ELD_SI_NUM") ) //Codigo da SI (W1_SI_NUM)
       oELD:SetField("ELD_CC"    , cCodUnReq ) //Codigo da Unidade Requisitante
       oELD:SetField("ELD_PRGENT", EasyGetXMLinfo("ELD_PRGENT",aArrayELD[nCont],"_DeliveryID" ) )
       oELD:SetField("ELD_DTPREV", EasyGetXMLinfo("ELD_DTPREV",aArrayELD[nCont],"_EstimatedDeliveryDate" ) )
       oELD:SetField("ELD_QTSOLI", EasyGetXMLinfo("ELD_QTSOLI",aArrayELD[nCont],"_QuantityRequested" ) )
       oELD:SetField("ELD_OBSERV", EasyGetXMLinfo("ELD_OBSERV",aArrayELD[nCont],"_Observation" ) )
       oELDs:AddRec(oELD)//Arrays com os Registros dos Itens
   NEXT

   oExecAuto:SetField("ELD",oELDs)//Arrays com os Registros dos Itens

   //SYS
   If ValType(oApportionRequestItem) <> "A"
      aArraySYS := {oApportionRequestItem}
   Else
      aArraySYS := oApportionRequestItem
   EndIf

   FOR nCont := 1 TO LEN(aArraySYS)
       oSYS := ERec():New()//Arrays com os Registros da SYS
       /*
       oSYS:SetField("YS_HAWB"   , AVKEY(cSi_Num,"YS_HAWB"  ) ) //Codigo da SI (W1_SI_NUM)
       oSYS:SetField("YS_TIPO"   , AVKEY("S"    ,"YS_TIPO"  ) ) //Tipo
       oSYS:SetField("YS_TPMODU" , AVKEY("I"    ,"YS_TPMODU") ) //Tipo Modulo
       */

       cYS_CC   := EasyGetXMLinfo("YS_CC"  ,aArraySYS[nCont],"_CostCenterInternalId" )
       nYS_PERC := EasyGetXMLinfo("YS_PERC",aArraySYS[nCont],"_Percentual" )
       IF (!EMPTY(cYS_CC)) .AND. (!EMPTY(nYS_PERC))
          oSYS:SetField("YS_CC"     , EasyGetXMLinfo("YS_CC",aArraySYS[nCont],"_CostCenterInternalId" ) )
          oSYS:SetField("YS_PERC"   , EasyGetXMLinfo("YS_PERC",aArraySYS[nCont],"_Percentual" ) )
          oSYSs:AddRec(oSYS)//Arrays com os Registros dos Itens
       ENDIF
   NEXT
   oExecAuto:SetField("SYS",oSYSs)//Arrays com os Registros dos Itens

EndIf

oBatch:AddRec(oExecAuto)

Return oBatch

*-------------------------------------------------*
Function SI400RESB(oMessage)
*-------------------------------------------------*
Local oXml
Local oBusinessCont:= oMessage:GetMsgContent()
//Local cCompanyId

   /*wfs 24/07/2014
     -- tratamento de retorno */
    If !oMessage:HasErrors()

       	cInternalId	:= EasyGetXMLinfo(, oBusinessCont, "_CompanyId")

       	oXml:= ENode():New()
       	oXml:SetField('CompanyId', cInternalId)
       	oXml:SetField('Number', SW1->W1_SI_NUM)
    Else
       oXMl := oMessage:GetContentList("RESPONSE")
    EndIf


Return oXml

/*
 * EJA - 29/11/2018 - Filtro Contratos / Cotação ERP
 */
Static Function filtroContr(cMoedaInt, cComprador, cCondPag)
Local cSql
cSql := "(SW0.W0_MOEDA = '" + cMoedaInt + "' OR SW0.W0_MOEDA = ' ')";
    + " AND (SW0.W0_COMPRA = '" + cComprador + "' OR SW0.W0_COMPRA = ' ')" ;
    + " AND (SW1.W1_CONDPG = '" + cCondPag + "' OR SW1.W1_CONDPG = ' ')"
Return cSql

*------------------------*
Function SI410Leg()
*------------------------*
Return BrwLegenda(STR0001, STR0015, aColors)//"Legendas"

*------------------------*
Function SI410GerPO()
*------------------------*
Local lCotacao := .T., lOk := .F.
Local nInc, nAcao := 0
Local oBtCotacao, oBtContrato, oDlg, oColumn, oBrowse
Local cQuery := "", cTitulo := ""
Local bOk := {|| If(SI410VALID("TUDO",,,,,aItens),(nAcao := 1 ,oDlg:End()),nAcao := 0)},;
      bCancel := {|| If(MsgYesNo(STR0038,STR0010),(aItens := {}, nAcao := 0 ,oDlg:End()),)},;
      bMarca, bMarcaTodos
Local aItens := {}, aCampos := {}, aIndices := {}, aButtons := {}
Local aValidMvPar := {}
Local aMvParNoVld := {}
Local RecAtuWKSI  := 0
Local i, nPosX, nPosY, aGeraPOs := {}
Local aSeekFWBrw := {}, aFilter:= {}
Local oPanel, oRadio, aOptions:= { STR0020,;//"Contratos/ Cotação ERP"
                                   STR0019} //"Cotação de preço do Easy Import Control"
Local bOk2, bCancel2
Private nRadio
Private cCotaRef := "", cContRef := "", cForn := "", cLoja := "", cMoedaInt := "", nValor := 0, cImport := "", cComprador := "", cAgente := "", cViaTrans := "", cOrigem := "", cDestino := "", cIncoterm := "", cCondPag := "", cNumPo := ""
Private aContratosSX1 := {}

Begin Sequence

   bOk2:= {|| lOk := .T., If(nRadio == 1, lCotacao := .F., lCotacao:= .T.), aContratosSX1 := {}, oDlg:End()}
   bCancel2:= {|| lOk:= .F., oDlg:End()}
   DEFINE MSDIALOG oDlg TITLE STR0017 FROM 0,0 TO 200, 350 Pixel  // "Tipo de Agrupamento"
/* wfs - alterada a interface para seleção da opção (objeto radio)
      @ 8,8 SAY STR0018 PIXEL  //"Qual o tipo de agrupamento desejado?"

      @ 2.5,2  BUTTON oBtCotacao  PROMPT STR0019 SIZE 55,13 ACTION (lOk := .T., lCotacao := .T., SI410SX1(1), aContratosSX1 := {}, oDlg:End())  //"Cotação de Preços"

      @ 2.5,18 BUTTON oBtContrato PROMPT STR0020 SIZE 55,13 ACTION (lOk := .T., lCotacao := .F., SI410SX1(2), aContratosSX1 := {}, oDlg:End())  //"Contratos"
*/


///*************/
      oPanel:= TPanel():New(10,10,, oDlg,, .F., .F.,,, 100, 60)
      oPanel:Align:= CONTROL_ALIGN_TOP

      @ 10,04 TO 47,170 LABEL STR0018 OF oPanel PIXEL //"Qual o tipo de agrupamento desejado?"

      oRadio:= tRadMenu():New(20,10,aOptions, {|u| If(PCount() > 0, nRadio:=u, nRadio)}, oPanel,, {||If(nRadio == 1, lCotacao := .F., lCotacao:= .T.)},,,,,,205,80,,,,.T.)

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk2,bCancel2,,,,,,,.F.)) CENTERED
   
   //Desbloqueio do registro posicionado
   If SW1->(IsLocked())
      SW1->(MsUnlock())
   EndIf

   If lOk
      Do While .T.
         //If Pergunte("EICEAI0001",.T.) //wfs - desmembrado em duas perguntas: uma para cotação e outra para contrato
         If lCotacao
            If !Pergunte("EICEAI0001",.T.)
               Break
            Else
               SI410VALID("COTACAO")
               If !SI410VALID("PO")
                  Loop
               EndIf
               If Empty(mv_par01) .OR. (EasyGParam("MV_NRPO") == "N" .AND. Empty(mv_par14) .OR. Empty(mv_par08))
                  MsgInfo(STR0022,STR0010)  //"Campos obrigatórios não preenchidos." ### "Aviso"
               Else
                  Exit
               EndIf
            EndIf
         Else
            If !Pergunte("EICEAI0002",.T.)
               Break
            Else
               //SI410VALID("CONTRATO") //AAF 24/02/2017 - Retirada a validação do contrato, pois impedia que o usuário alterasse a condicao de pagamento, recarregando do cadastro.

               /*If Empty(mv_par02) .OR. Empty(mv_par04) .OR. Empty(mv_par05) .OR. Empty(mv_par06) .OR. Empty(mv_par07) .OR. Empty(mv_par08) .OR.;
                  Empty(mv_par09) .OR. Empty(mv_par10) .OR. Empty(mv_par11) .OR. Empty(mv_par12) .OR. Empty(mv_par13)
                  */
               //NCF - 01/09/2016 - Chamada da validação dos parâmetros do pergunte na função SI410TstMv
               aMvParNoVld := { 1,;   //Cotacão Referência
               	               3}  //Fornecedor (validação em tela ou gatilhada pelo contr. referência)
               	               //13 } //Condição de Pagamento (Se informado contr. de referencia, neste item do contrato pode estar vazia a cond. pagto) //NCF - 16/09/2016 - Validar cond. pagto
               aValidMvPar := SI410TstMv(13,aMvParNoVld,"EICEAI0002")
               If !aValidMvPar[1]
                  MsgInfo(/*STR0022*/ aValidMvPar[2] ,STR0010)  //"Campos obrigatórios não preenchidos." ### "Aviso"
               Else
                  Exit
               EndIf
            EndIf
         //Else
         //  Break
         EndIf
      EndDo

      If lCotacao
         cCotaRef   := mv_par01
      Else
         cContRef   := mv_par01
      EndIf
      //cForn      := LEFT(mv_par02,TamSX3("A2_COD")[1])//mv_par03 //wfs - separadas as informações código e descrição do fornecedor
      cForn      := mv_par02
      cLoja      := mv_par03
      cMoedaInt  := mv_par05
      cImport    := mv_par06
      cComprador := mv_par07
      cAgente    := mv_par08
      cViaTrans  := mv_par09
      cOrigem    := mv_par10
      cDestino   := mv_par11
      cIncoterm  := mv_par12
      cCondPag   := mv_par13
      If lCotacao
         cNumPo     := mv_par14
      EndIf

      cQuery := " SELECT SW1.W1_FILIAL, SW1.W1_SI_NUM, SW1.W1_COD_I, SW1.W1_REG, SW1.W1_C3_NUM, SW1.W1_CC, SW1.W1_FABR, SW1.W1_FABLOJ, SW1.W1_FORN, SW1.W1_FORLOJ, SW1.W1_DTENTR_, SW1.W1_QTDE, SW1.W1_SALDO_Q, SW1.W1_PRECO, SW1.W1_PO_NUM, SW1.W1_CONDPG, SW0.W0_REFER1, SW0.W0_MOEDA, SW0.W0_COMPRA, SB1.B1_POSIPI "
      If lCotacao
         cQuery += ", SWT.WT_NR_CONC, SWT.WT_NUMERP "
      EndIf
      cQuery += " FROM " + RetSqlName("SW1") + " SW1 "
      cQuery += " INNER JOIN " + RetSqlName("SW0") + " SW0 "
      cQuery += " ON SW1.W1_FILIAL = SW0.W0_FILIAL AND SW1.W1_SI_NUM = SW0.W0__NUM "
      If lCotacao
         cQuery += " INNER JOIN " + RetSqlName("SWT") + " SWT "
         cQuery += " ON SW1.W1_FILIAL = SWT.WT_FILIAL AND SW1.W1_SI_NUM = SWT.WT_SI_NUM "
      EndIf
      cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
      cQuery += " ON SB1.B1_COD = SW1.W1_COD_I "
      cQuery += " WHERE SW1.D_E_L_E_T_ <> '*' AND SW0.D_E_L_E_T_ <> '*' AND "
      cQuery += " SW1.W1_FILIAL = '" + xFilial ("SW1") + "' AND "
      If !lCotacao
         cQuery += " SW1.W1_FORN = '" + cForn + "' AND SW1.W1_FORLOJ = '" + cLoja +  "' AND " + filtroContr(cMoedaInt, cComprador, cCondPag) + " AND "
      EndIf
      //cQuery += " SW1.W1_MOEDA = '" + cMoedaInt + "' AND "
      //cQuery += " SW1.W1_PRECO = '" + nValor + "' AND "
      //cQuery += " SW0.W0_COMPRA = '" + cComprador + "' AND "
      If lCotacao
         cQuery += " SWT.D_E_L_E_T_ <> '*' AND SW1.W1_NR_CONC <> '' AND SW1.W1_STATUS = 'D' AND SWT.WT_STATUS = '3' AND "
         aIndices := {"WT_NUMERP","WT_NR_CONC","W1_SI_NUM"}
      Else
         cQuery += " SW0.W0_REFER1 <> '' AND SW1.W1_STATUS = 'G' AND "
         aIndices := {"W1_SI_NUM","W0_REFER1","W1_C3_NUM", "W1_COD_I", "W1_PO_NUM"}
      EndIf
      cQuery += " SB1.D_E_L_E_T_ <> '*' "

      If Select("WKSI") # 0
         WKSI->(DbCloseArea())
      EndIf

      EasyWkQuery(cQuery,"WKSI",aIndices)
      TCSetField("WKSI", "W1_DTENTR_", "D")

      aItens := {}

      WKSI->(DbGoTop())
      If WKSI->(Bof()) .AND. WKSI->(Eof())
         MsgInfo(STR0023,STR0010)  //"Não há registros válidos para seleção." ### "Aviso"
         Break
      EndIf

      /* comentado por WFS
      //consulta padrão AVI002
      M->W2_FORN:= cForn
      M->W3_COD_I:= WKSI->W1_COD_I */
      If lCotacao

         bMarca := {|oBrowse| If((nPos := aScan(aItens,WKSI->(Recno())))==0, (Aadd(aItens,WKSI->(Recno())), WKSI->W1_PO_NUM := cNumPo), (aDel(aItens,nPos), aSize(aItens, Len(aItens)-1), WKSI->W1_PO_NUM := "")) }
         bMarcaTodos := {|oBrowse| If(!Empty(aItens),aItens:={},aItens := MarkAllItens(cNumPo)),oBrowse:Refresh(.T.)}

         WKSI->(DbSetOrder(2))
         If WKSI->(DbSeek(cCotaRef))
            If Empty(WKSI->W1_FABR) .OR. Empty(WKSI->W1_FABLOJ)
               /*wfs - sugerir o primeiro registro que contenha o fabricante
               WKSI->W1_FABR := Posicione("SA5",1,xFilial("SA5")+AvKey(WKSI->W1_FORN,"A5_FORNECE")+AvKey(WKSI->W1_FORLOJ,"A5_LOJA")+AvKey(WKSI->W1_COD_I,"A5_PRODUTO"),"A5_FABR")
               WKSI->W1_FABLOJ := Posicione("SA5",1,xFilial("SA5")+AvKey(WKSI->W1_FORN,"A5_FORNECE")+AvKey(WKSI->W1_FORLOJ,"A5_LOJA")+AvKey(WKSI->W1_COD_I,"A5_PRODUTO"),"A5_FALOJA")*/
               If SA5->(DBSeek(xFilial() + AvKey(WKSI->W1_FORN, "A5_FORNECE") + AvKey(WKSI->W1_FORLOJ, "A5_LOJA") + AvKey(WKSI->W1_COD_I, "A5_PRODUTO")))
                  While SA5->(!Eof()) .And. WKSI->W1_FORN == SA5->A5_FORNECE .And.;
                        WKSI->W1_FORLOJ == SA5->A5_LOJA .And. WKSI->W1_COD_I == SA5->A5_PRODUTO

                     If !Empty(SA5->A5_FABR)
                        WKSI->W1_FABR  := SA5->A5_FABR
                        WKSI->W1_FABLOJ:= SA5->A5_FALOJA
                        Exit
                     EndIf

                     SA5->(DBSkip())
                  EndDo
               EndIf
            EndIf
            Aadd(aItens,WKSI->(Recno()))
            WKSI->W1_PO_NUM := cNumPo
         EndIf
         WKSI->(DbGoTop())

         aCampos := {"W1_SI_NUM","W1_COD_I","WT_NR_CONC","WT_NUMERP","W1_FABR","W1_FABLOJ"}
         cTitulo := STR0025  //"Itens de Cotações Aprovadas"
      Else

         bMarca := {|oBrowse| If((nPos := aScan(aItens,WKSI->(Recno())))==0, ;
                                  MarkGroupItens(1,aItens,WKSI->W0_REFER1,WKSI->W1_PO_NUM), ;
                                  MarkGroupItens(2,aItens,WKSI->W0_REFER1,WKSI->W1_PO_NUM) ) }
         bMarcaTodos := {|oBrowse| If(!Empty(aItens),aItens:={},aItens := MarkAllItens(cNumPo)),oBrowse:Refresh(.T.)}

         WKSI->(DbSetOrder(3))
         WKSI->(DbGoTop())
         Do While WKSI->(!Eof())
            If Empty(WKSI->W1_FABR) .OR. Empty(WKSI->W1_FABLOJ)
               /*wfs - sugerir o primeiro registro que contenha o fabricante
               WKSI->W1_FABR := Posicione("SA5",1,xFilial("SA5")+AvKey(WKSI->W1_FORN,"A5_FORNECE")+AvKey(WKSI->W1_FORLOJ,"A5_LOJA")+AvKey(WKSI->W1_COD_I,"A5_PRODUTO"),"A5_FABR")
               WKSI->W1_FABLOJ := Posicione("SA5",1,xFilial("SA5")+AvKey(WKSI->W1_FORN,"A5_FORNECE")+AvKey(WKSI->W1_FORLOJ,"A5_LOJA")+AvKey(WKSI->W1_COD_I,"A5_PRODUTO"),"A5_FALOJA")*/
               If SA5->(DBSeek(xFilial() + AvKey(WKSI->W1_FORN, "A5_FORNECE") + AvKey(WKSI->W1_FORLOJ, "A5_LOJA") + AvKey(WKSI->W1_COD_I, "A5_PRODUTO")))
                  While SA5->(!Eof()) .And. WKSI->W1_FORN == SA5->A5_FORNECE .And.;
                        WKSI->W1_FORLOJ == SA5->A5_LOJA .And. WKSI->W1_COD_I == SA5->A5_PRODUTO

                     If !Empty(SA5->A5_FABR)
                        WKSI->W1_FABR  := SA5->A5_FABR
                        WKSI->W1_FABLOJ:= SA5->A5_FALOJA
                        Exit
                     EndIf

                     SA5->(DBSkip())
                  EndDo
               EndIf
            EndIf
            If EasyGParam("MV_NRPO") == "S"              //NCF - 19/09/2016 - Incicializar com "." para execução automática
               WKSI->W1_PO_NUM := AvKey(".","W2_PO_NUM")
            EndIf
            Aadd(aItens,WKSI->(Recno()))
            WKSI->(DbSkip())
         EndDo
         WKSI->(DbGoTop())
         aCampos := {/*"W0_REFER1",*/"W1_C3_NUM","W1_SI_NUM","W1_COD_I","W1_FABR","W1_FABLOJ","B1_POSIPI", "W0_COMPRA", "W0_MOEDA", "W1_CONDPG"}
         cTitulo := STR0026 //"Itens de Contratos / Cotações do ERP"
         If EasyGParam("MV_NRPO") <> "S"
            aadd(aCampos,"W1_PO_NUM")
         EndIf
      EndIf

     /* AAdd(aSeekFWBrw, {AvSx3("W1_SI_NUM", AV_TITULO)    , {{"", AvSx3("W1_SI_NUM", AV_TIPO)    , AvSx3("W1_SI_NUM", AV_TAMANHO)    , AvSx3("W1_SI_NUM", AV_DECIMAL)    , AvSx3("W1_SI_NUM"    , AV_TITULO)}}})
     AAdd(aSeekFWBrw, {AvSx3("W1_C3_NUM", AV_TITULO)    , {{"", AvSx3("W1_C3_NUM", AV_TIPO)    , AvSx3("W1_C3_NUM", AV_TAMANHO)    , AvSx3("W1_C3_NUM", AV_DECIMAL)    , AvSx3("W1_C3_NUM"    , AV_TITULO)}}}) */

     If lCotacao
        AAdd(aSeekFWBrw, {AvSx3("W1_SI_NUM" , AV_TITULO)    , {{"", AvSx3("W1_SI_NUM" , AV_TIPO)    , AvSx3("W1_SI_NUM" , AV_TAMANHO)    , AvSx3("W1_SI_NUM" , AV_DECIMAL)    , AvSx3("W1_SI_NUM"     , AV_TITULO)}}, 1})
        AAdd(aSeekFWBrw, {AvSx3("WT_NUMERP" , AV_TITULO)    , {{"", AvSx3("WT_NUMERP" , AV_TIPO)    , AvSx3("WT_NUMERP" , AV_TAMANHO)    , AvSx3("WT_NUMERP" , AV_DECIMAL)    , AvSx3("WT_NUMERP"     , AV_TITULO)}}, 2})
        AAdd(aSeekFWBrw, {AvSx3("WT_NR_CONC", AV_TITULO)    , {{"", AvSx3("WT_NR_CONC", AV_TIPO)    , AvSx3("WT_NR_CONC", AV_TAMANHO)    , AvSx3("WT_NR_CONC", AV_DECIMAL)    , AvSx3("WT_NR_CONC"    , AV_TITULO)}}, 3})
        /* filtro */
        AAdd(aFilter, {"W1_PO_NUM" , AvSx3("W1_PO_NUM", AV_TITULO), AvSx3("W1_PO_NUM", AV_TIPO)     , AvSx3("W1_PO_NUM", AV_TAMANHO)     , AvSx3("W1_PO_NUM", AV_DECIMAL), AvSx3("W1_PO_NUM", AV_PICTURE)})
        AAdd(aFilter, {"WT_NUMERP" , AvSx3("WT_NUMERP", AV_TITULO), AvSx3("WT_NUMERP", AV_TIPO)     , AvSx3("WT_NUMERP", AV_TAMANHO)     , AvSx3("WT_NUMERP", AV_DECIMAL), AvSx3("WT_NUMERP", AV_PICTURE)})
        AAdd(aFilter, {"WT_NR_CONC", AvSx3("WT_NR_CONC",AV_TITULO), AvSx3("WT_NR_CONC",AV_TIPO)     , AvSx3("WT_NR_CONC",AV_TAMANHO)     , AvSx3("WT_NR_CONC",AV_DECIMAL), AvSx3("WT_NR_CONC",AV_PICTURE)})
        AAdd(aFilter, {"W1_FORN"   , AvSx3("W1_FORN"   ,AV_TITULO), AvSx3("W1_FORN"   ,AV_TIPO)     , AvSx3("W1_FORN"   ,AV_TAMANHO)     , AvSx3("W1_FORN"   ,AV_DECIMAL), AvSx3("W1_FORN"   ,AV_PICTURE)})

     Else
        /* pesquisa */
        AAdd(aSeekFWBrw, {AvSx3("W1_PO_NUM", AV_TITULO)    , {{"", AvSx3("W1_PO_NUM", AV_TIPO)    , AvSx3("W1_PO_NUM", AV_TAMANHO)    , AvSx3("W1_PO_NUM", AV_DECIMAL)    , AvSx3("W1_PO_NUM"    , AV_TITULO)}}, 1})
        AAdd(aSeekFWBrw, {AvSx3("W1_SI_NUM", AV_TITULO)    , {{"", AvSx3("W1_SI_NUM", AV_TIPO)    , AvSx3("W1_SI_NUM", AV_TAMANHO)    , AvSx3("W1_SI_NUM", AV_DECIMAL)    , AvSx3("W1_SI_NUM"    , AV_TITULO)}}, 2})
        AAdd(aSeekFWBrw, {AvSx3("W0_REFER1", AV_TITULO)    , {{"", AvSx3("W0_REFER1", AV_TIPO)    , AvSx3("W0_REFER1", AV_TAMANHO)    , AvSx3("W0_REFER1", AV_DECIMAL)    , AvSx3("W0_REFER1"    , AV_TITULO)}}, 3})
        AAdd(aSeekFWBrw, {AvSx3("W1_C3_NUM", AV_TITULO)    , {{"", AvSx3("W1_C3_NUM", AV_TIPO)    , AvSx3("W1_C3_NUM", AV_TAMANHO)    , AvSx3("W1_C3_NUM", AV_DECIMAL)    , AvSx3("W1_C3_NUM"    , AV_TITULO)}}, 4})
        AAdd(aSeekFWBrw, {AvSx3("W1_COD_I" , AV_TITULO)    , {{"", AvSx3("W1_COD_I" , AV_TIPO)    , AvSx3("W1_COD_I" , AV_TAMANHO)    , AvSx3("W1_COD_I" , AV_DECIMAL)    , AvSx3("W1_COD_I"     , AV_TITULO)}}, 5})
        /* filtro */
        AAdd(aFilter, {"W1_SI_NUM", AvSx3("W1_SI_NUM", AV_TITULO), AvSx3("W1_SI_NUM", AV_TIPO)     , AvSx3("W1_SI_NUM", AV_TAMANHO)     , AvSx3("W1_SI_NUM", AV_DECIMAL), AvSx3("W1_SI_NUM", AV_PICTURE)})
        AAdd(aFilter, {"W0_REFER1", AvSx3("W0_REFER1", AV_TITULO), AvSx3("W0_REFER1", AV_TIPO)     , AvSx3("W0_REFER1", AV_TAMANHO)     , AvSx3("W0_REFER1", AV_DECIMAL), AvSx3("W0_REFER1", AV_PICTURE)})
        AAdd(aFilter, {"W1_C3_NUM", AvSx3("W1_C3_NUM", AV_TITULO), AvSx3("W1_C3_NUM", AV_TIPO)     , AvSx3("W1_C3_NUM", AV_TAMANHO)     , AvSx3("W1_C3_NUM", AV_DECIMAL), AvSx3("W1_C3_NUM", AV_PICTURE)})
        AAdd(aFilter, {"W1_COD_I" , AvSx3("W1_COD_I", AV_TITULO) , AvSx3("W1_COD_I", AV_TIPO)      , AvSx3("W1_COD_I", AV_TAMANHO)      , AvSx3("W1_COD_I" , AV_DECIMAL), AvSx3("W1_COD_I" , AV_PICTURE)})
        AAdd(aFilter, {"W1_FORN"   , AvSx3("W1_FORN"   ,AV_TITULO), AvSx3("W1_FORN"   ,AV_TIPO)     , AvSx3("W1_FORN"   ,AV_TAMANHO)     , AvSx3("W1_FORN"   ,AV_DECIMAL), AvSx3("W1_FORN"   ,AV_PICTURE)})

     EndIf

     Aadd(aButtons,{"EDIT",{|| SI410SetPO(lCotacao), oBrowse:Refresh() },STR0033               })  //"Edição de Dados"

     DEFINE MSDIALOG oDlg TITLE cTitulo FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

         DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "WKSI" OF oDlg

            oBrowse:SetDescription(cTitulo)

            //If lCotacao
               ADD MARKCOLUMN oColumn DATA { || If(aScan(aItens, WKSI->(Recno())) == 0, 'LBNO', 'LBOK') } DOUBLECLICK {|x| eval(bMarca,x), x:Refresh(.T.)  }  HEADERCLICK bMarcaTodos OF oBrowse
            //EndIf
            For nInc := 1 To Len(aCampos)
               If aCampos[nInc] == "W1_PO_NUM" .OR. aCampos[nInc] == "W1_FABR" .OR. aCampos[nInc] == "W1_FABLOJ" .OR. aCampos[nInc] == "B1_POSIPI"
                  oBrowse:AddColumn({AvSx3(aCampos[nInc], AV_TITULO), &("{ ||" + aCampos[nInc] + " }"), AvSx3(aCampos[nInc], AV_TIPO),,, AvSx3(aCampos[nInc], AV_TAMANHO), AvSx3(aCampos[nInc], AV_DECIMAL), .T., {|| SI410VALID("GRID_PO")}, .F., {|| SI410SetPO(lCotacao), oBrowse:Refresh(.T.)}, WKSI->W1_PO_NUM })
               Else
                  ADD COLUMN oColumn DATA &("{ ||" + aCampos[nInc] + " }") TITLE AvSx3(aCampos[nInc], AV_TITULO) SIZE AvSx3(aCampos[nInc], AV_TAMANHO) OF oBrowse
               EndIf
            Next
            WKSI->(DbGoTop())

            /* pesquisa */
            oBrowse:SetSeek(, aSeekFWBrw)

            /* filtro */
            oBrowse:lDbfFilter:= .T.
            oBrowse:SetUseFilter()
            oBrowse:SetFieldFilter(aFilter)

            //oBrowse:DisableReport()
            oBrowse:Refresh(.T.)

         ACTIVATE FWBROWSE oBrowse

         oDlg:lMaximized := .T.

      ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, bOk, bCancel,,aButtons) CENTERED

      If nAcao == 0 .OR. Len(aItens) == 0
         Break
      EndIf

      If !MsgYesNo(STR0021,STR0010)  //"Confirma a geração do P.O.?" ### "Aviso"
         Break
      EndIf

      If !lCotacao // Somente para Contratos
         //If EasyGParam("MV_NRPO") <> "S"
            //aItens := {}
            //WKSI->(DbGoTop())
            For i := 1 To Len(aItens)//Do While WKSI->(!Eof())
               WKSI->(DbGoTo(aItens[i]))
               If Empty(WKSI->W1_FABR) .OR. Empty(WKSI->W1_FABLOJ)
                  WKSI->W1_FABR := Posicione("SA5",1,xFilial("SA5")+AvKey(WKSI->W1_FORN,"A5_FORNECE")+AvKey(WKSI->W1_FORLOJ,"A5_LOJA")+AvKey(WKSI->W1_COD_I,"A5_PRODUTO"),"A5_FABR")
                  WKSI->W1_FABLOJ := Posicione("SA5",1,xFilial("SA5")+AvKey(WKSI->W1_FORN,"A5_FORNECE")+AvKey(WKSI->W1_FORLOJ,"A5_LOJA")+AvKey(WKSI->W1_COD_I,"A5_PRODUTO"),"A5_FALOJA")
               EndIf

               If (nPosX := aScan( aGeraPOs, {|x| x[1] == WKSI->W1_PO_NUM .And. x[2] == WKSI->W0_REFER1 } )) == 0
                  aAdd(aGeraPOs,{ WKSI->W1_PO_NUM  ,   WKSI->W0_REFER1  ,   {WKSI->(Recno())} })
               Else
                  If (nPosY := aScan(aGeraPOs[nPosX][3],WKSI->(Recno())) ) == 0
                     aAdd(aGeraPOs[nPosX][3],WKSI->(Recno()) )
                  EndIf
               EndIf
               //Aadd(aItens,WKSI->(Recno()))
               //WKSI->(DbSkip())
            next i//EndDo
         /*Else
            WKSI->(DbGoTop())
            Do While WKSI->(!Eof())
               If Empty(WKSI->W1_FABR) .OR. Empty(WKSI->W1_FABLOJ)
                  WKSI->W1_FABR := Posicione("SA5",1,xFilial("SA5")+AvKey(WKSI->W1_FORN,"A5_FORNECE")+AvKey(WKSI->W1_FORLOJ,"A5_LOJA")+AvKey(WKSI->W1_COD_I,"A5_PRODUTO"),"A5_FABR")
                  WKSI->W1_FABLOJ := Posicione("SA5",1,xFilial("SA5")+AvKey(WKSI->W1_FORN,"A5_FORNECE")+AvKey(WKSI->W1_FORLOJ,"A5_LOJA")+AvKey(WKSI->W1_COD_I,"A5_PRODUTO"),"A5_FALOJA")
               EndIf
               Aadd(aItens,WKSI->(Recno()))
               WKSI->(DbSkip())
            EndDo
         EndIf
         WKSI->(DbGoTop())*/
      EndIf

      If lCotacao
         Processa({|| SI410PO(aItens,lCotacao) } , STR0027)  //"Gerando Purchase Order ..."
      Else
         For i:=1 To Len (aGeraPOs)
            Processa({|| SI410PO(aGeraPOs[i][3],lCotacao) } , STR0027)  //"Gerando Purchase Order ..."
         Next i
      EndIf

   EndIf
End Sequence

Return

*--------------------------------*
Static Function MarkAllItens(cPO)
*--------------------------------*
Local aItens := {}
WKSI->(DbGoTop())
While WKSI->(!Eof())
   aAdd(aItens, WKSI->(Recno()))
   WKSI->W1_PO_NUM := cPO
   WKSI->(DbSkip())
EndDo
WKSI->(DbGoTop())
Return aItens

/* revisão
wfs - jul/2017: retornar o número do pedido do ERP no campo virtual. */
*---------------------------*
Function SI410Relacao(cCampo)
*---------------------------*
Local cRet := "", aOrd := SaveOrd({"SW0","SW2","SW3"})

SW0->(DbSetOrder(1))
SW0->(DbSeek(xFilial("SW0")+SW1->W1_CC+SW1->W1_SI_NUM))

SW2->(DBSetOrder(1))
SW3->(DbSetOrder(4))

Do Case
   Case cCampo == "W1_MOEDA"
      cRet := SW0->W0_MOEDA
   Case cCampo == "W1_REFER1"
      cRet := SW0->W0_REFER1
   Case cCampo == "W1_PEDERP"
      If SW3->(DbSeek(xFilial("SW3")+SW1->W1_CC+SW1->W1_SI_NUM)) .And. SW2->(DBSeek(xFilial() + SW3->W3_PO_NUM))
         //retorna o número do purchase order e o número do pedido do ERP (Logix)
         cRet:= AllTrim(SW3->W3_PO_NUM) + " / " + SW2->W2_PO_SIGA
      Else
         //Se não possui purchase order, tenta localizar o pedido logix existente para o agrupador, caso a solicitação tenha como origem um contrato
         cRet:= BuscaPedido(SW0->W0_REFER1)
      EndIf
End Case

RestOrd(aOrd,.T.)
Return cRet

/*
Função     : BuscaPedido
Objetivo   : Retornar o número do primeiro pedido ERP existente para o agrupador
Parâmetros : número do agrupador
Retorno    : número do pedido do ERP
Autor      : WFS
Data/Hora  : jul/2017
*/
Static Function BuscaPedido(cAgrupador)
Local cPedido:= ""
Local cQuery

Begin Sequence
   
   If Empty(cAgrupador)
      //se não possuir agrupador, não tem retorno
      Break 
   EndIf

   cQuery:= "select distinct W3_PO_NUM from " + RetSqlName("SW3") + " W3 " +;
               "Inner Join " + RetSqlName("SW0") + " W0 " +;
                  "on W3.W3_SI_NUM = W0.W0__NUM " +;
               "Where W0.W0_REFER1 = '" + cAgrupador + "' And W3.W3_FILIAL = '" + SW3->(xFilial()) + "'"
               
   If TcSrvType() <> "AS/400"
      cQuery += " And W3.D_E_L_E_T_ <> '*' And W0.D_E_L_E_T_ <> '*'"
   EndIf

   cQuery += " Order by W3.W3_PO_NUM"

   cQuery := ChangeQuery(cQuery)
   TcQuery cQuery Alias "PEDERP" New

   PEDERP->(DBGoTop())
   If PEDERP->(!Eof())
      SW2->(DBSeek(xFilial() + PEDERP->W3_PO_NUM))
      cPedido:= "- / " + SW2->W2_PO_SIGA
   EndIf
   
   PEDERP->(DBCloseArea())

End Sequence

Return cPedido

/* revisão
wfs - abr/2017: revisão das variáveis após separação das perguntas, para contrato e cotação. */
*--------------------------------------------------------*
Function SI410VALID(cCampo,cPO,cAgrup,cFabr,cLoja,aItens)
*--------------------------------------------------------*
Local lRet := .T., aOrd := SaveOrd({"SW2","SA2","SYD"}), i
Local cMsgErr := "" //NCF - 12/09/2016
Do Case
   Case cCampo == "CONTRATO"
      //If Empty(mv_par03) .OR. Empty(mv_par04)
      If SW1->W1_C3_NUM <> AvKey(mv_par01,"W1_C3_NUM")
         SW1->(DbSetOrder(5))
         SW1->(DbSeek(xFilial("SW1")+AvKey(mv_par01,"W1_C3_NUM")))
      EndIf

      SW0->(DbSetOrder(1))
      SW0->(DbSeek(xFilial("SW0")+SW1->W1_CC+SW1->W1_SI_NUM))

      mv_par02 := SW1->W1_FORN
      mv_par03 := SW1->W1_FORLOJ
      mv_par04 := Posicione("SA2",1,xFilial("SA2") + SW1->W1_FORN + SW1->W1_FORLOJ, "A2_NREDUZ")
      mv_par05 := SW0->W0_MOEDA

      //mv_par13 := SW1->W1_CONDPG  //NCF - 16/09/2016 - Considerar Condição informada no Pergunte
      mv_par13 := SW1->W1_CONDPG //AAF 24/02/2017 - Deve gatilhar a condicao de pagamento do contrato no pergunte. Alterado para não chamar esta validacao novamente para permitir as alterações no pergunte.
      mv_par07 := SW0->W0_COMPRA
      //EndIf
   Case cCampo == "COTACAO"
      If Empty(mv_par02) .OR. Empty(mv_par03) .OR. Empty(mv_par05) .OR. Empty(mv_par06) .OR. Empty(mv_par07) .OR. Empty(mv_par08) .OR.;
         Empty(mv_par10) .OR. Empty(mv_par11) .OR. Empty(mv_par12) .OR. Empty(mv_par13)
         SWT->(DbSetOrder(6))
         SWT->(DbSeek(xFilial("SWT")+AvKey(mv_par01,"WT_NUMERP")))

         SWR->(DbSetOrder(1))
         SWR->(DbSeek(xFilial("SWR")+SWT->WT_NR_CONC))

         mv_par02 := SWT->WT_FORN
         mv_par03 := SWT->WT_FORLOJ
         mv_par04 := Posicione("SA2", 1, xFilial("SA2") + SWT->WT_FORN + SWT->WT_FORLOJ, "A2_NREDUZ")
         mv_par05 := SWT->WT_MOEDA
         mv_par06 := SWR->WR_IMPOR
         mv_par07 := SWR->WR_COMPRA
         //mv_par08 := AGENTE
         mv_par09 := SWR->WR_VIA
         mv_par10 := SWT->WT_ORIGEM
         mv_par11 := SWR->WR_DESTINO
         mv_par12 := SWT->WT_INCOTER
         mv_par13 := SWT->WT_COD_PAG
      EndIf
   Case cCampo == "PO"
       If ValType(cPO) <> "C"
          cPO := mv_par14
       EndIf
       If EasyGParam("MV_NRPO") <> "S" .AND. !Empty(cPO)
          SW2->(DbSetOrder(1))
          If SW2->(DbSeek(xFilial("SW2")+AvKey(cPO,"W2_PO_NUM")))
             MsgInfo(STR0031,STR0010)  //"O número informado para geração de Purchase Order já existente. Informar um número válido." ### "Aviso"
             lRet := .F.
          EndIf
          If !Empty(cAgrup) .AND. WKSI->(!Bof()) .AND. WKSI->(!Eof())
             nRecWKSI := WKSI->(Recno())
             WKSI->(DbGoTop())
             Do While WKSI->(!Eof())
                If !Empty(WKSI->W1_PO_NUM) .AND. WKSI->W1_PO_NUM == cPO .AND. WKSI->W0_REFER1 <> cAgrup
                   MsgInfo(STR0031,STR0010)  //"O número informado para geração de Purchase Order já existente. Informar um número válido." ### "Aviso"
                   lRet := .F.
                   Exit
                EndIf
                WKSI->(DbSkip())
             EndDo
             WKSI->(DbGoTo(nRecWKSI))
          EndIf
       EndIf
   Case cCampo == "FABR"
       SA2->(DbSetOrder(1))
       If !SA2->(DbSeek(xFilial("SA2")+AvKey(cFabr,"A2_COD")+If(!Empty(cLoja),AvKey(cLoja,"A2_LOJA"),"")))
          MsgInfo(STR0035,STR0010)  //"Registro informado não é um Fabricante. Informe um registro válido" ### "Aviso"
          lRet := .F.
       EndIf
       If Left(SA2->A2_ID_FBFN,1,10) <> "1" .AND. Left(SA2->A2_ID_FBFN,1,10) <> "3"
          MsgInfo(STR0035,STR0010)  //"Registro informado não é um Fabricante. Informe um registro válido" ### "Aviso"
          lRet := .F.
       EndIf
   Case cCampo == "NCM"
       SYD->(DbSetOrder(1))
       If !SYD->(DbSeek(xFilial("SYD")+AvKey(WKSI->B1_POSIPI,"YD_TEC")))
          MsgInfo(STR0037,STR0010)  //"NCM inválida. Informe um registro válido" ### "Aviso"
          lRet := .F.
       EndIf
   Case cCampo == "PO400FILSIAGRP"
      //if Vazio() .OR. ExistCpo('SW0',AvKey('99999','W1_CC')+MV_PAR02) //wfs - corrigido o mv_par referente ao número da S.I.
      if Vazio() .OR. ExistCpo('SW0',AvKey('99999','W1_CC')+MV_PAR03)
         //mv_par10 := SI410GtAgp(SW1->W1_SI_NUM)
         mv_par10 := SI410GtAgp(MV_PAR03)
         lRet := .T.
      Else
         lRet := .F.
      EndIf
   Case cCampo == "FORNECEDOR"
        //If ExistCPO("SA2", LEFT(mv_par02,TamSX3("A2_COD")[1]))
        If ExistCPO("SA2", mv_par02)
           //mv_par02 := LEFT(mv_par02,TamSX3("A2_COD")[1]) +" - "+ Alltrim(Posicione("SA2",1,xFilial("SA2") + LEFT(mv_par02,TamSX3("A2_COD")[1]) + IF(!Empty(mv_par03), mv_par03, ""),"A2_NREDUZ"))
           mv_par04 := Posicione("SA2", 1, xFilial("SA2") + mv_par02 + If(!Empty(mv_par03), mv_par03, ""), "A2_NREDUZ")
           lRet := .T.
        EndIf
   Case cCampo == "TUDO"
       For i := 1 To Len(aItens)
         WKSI->(DbGoTo(aItens[i]))
         If (EasyGParam("MV_NRPO") <> "S" .AND. Empty(WKSI->W1_PO_NUM)) //.OR. Empty(WKSI->W1_FABR) .OR. Empty(WKSI->W1_FABLOJ) .OR. Empty(WKSI->B1_POSIPI)
            cMsgErr := "Nro. do P.O não preenchido no item da solicitação!"
            lRet    := .F.
         ElseIf Empty(WKSI->W1_FABR)
            cMsgErr := "Cód. Fabricante não preenchido no item da solicitação!"
            lRet    := .F.
         ElseIf Empty(WKSI->W1_FABLOJ)
            cMsgErr := "Cód. de Loja do Fabricante não preenchido no item da solicitação!"
            lRet    := .F.
         ElseIf Empty(WKSI->B1_POSIPI)
            cMsgErr := "Cód. da n.c.m não preenchido no item da solicitação!"
            lRet    := .F.
         EndIf

         If !lRet
            MsgInfo(cMsgErr/*STR0022*/,STR0010)  //"Campos obrigatórios não preenchidos." ### "Aviso"
            Exit
         EndIf

       Next i
       WKSI->(DbGoTop())
End Case
      
If EasyEntryPoint("EICSI410")
    xlRet := ExecBlock("EICSI410",.F.,.F.,{"SI410VALID",cCampo})
    If ValType(xlRet) = "L"
        lRet := xlRet
    EndIf
EndIf

RestOrd(aOrd,.T.)
Return lRet

*----------------------------------*
Function SI410PO(aItens,lCotacao)
*----------------------------------*
Local aCab := {}, aDet := {}, i := 0, lNumPOAuto := EasyGParam("MV_NRPO") == "S", cNumPOE := "", cRefAgrup := ""
Local aOrd := SaveOrd({"SW0","SW1","SWT","SWR","SA5"})
Local c2CotaRef   := cCotaRef  , c2ContRef := cContRef, c2Forn := cForn, c2Loja := cLoja, c2Moeda := cMoedaInt, n2Valor := nValor, c2Import := cImport
Local c2Comprador := cComprador, c2Agente := cAgente, c2ViaTrans, c2Origem, c2Destino, c2Incoterm := cIncoterm, c2CondPag := cCondPag, c2NumPo := cNumPo
Local dDataEntrega, dDataEmbarque

Private lMsErroAuto := .f.

ProcRegua(Len(aItens))

c2ViaTrans:= AvKey(cViaTrans, "W2_TIPO_EM")
c2Origem  := AvKey(cOrigem  , "W2_ORIGEM")
c2Destino := AvKey(cDestino , "W2_DEST")

If lCotacao  // Tratamento para Cotação
   For i := 1 To Len(aItens)
      WKSI->(DbGoTo(aItens[i]))

      //wfs - quando a data de entrega for menor que a data base, assume a data base do sistema para a geração do P.O.
      If WKSI->W1_DTENTR_ < dDataBase
         dDataEntrega:= dDataBase
      Else
         dDataEntrega:= WKSI->W1_DTENTR_
      EndIf
      //wfs - recalcula a data de embarque, considerando o leadtime e a nova data de entrega
      dDataEmbarque:= CalcDataEmbarque(dDataEntrega, c2ViaTrans,c2Origem,c2Destino)

      If i == 1
         aadd(aCab,{"W2_FILIAL" , xFilial("SW2")                , NIL})
         aadd(aCab,{"W2_PO_NUM" , If(lNumPOAuto,"",AvKey(cNumPo,"W2_PO_NUM")), NIL})
         aadd(aCab,{"W2_PO_DT"  , dDataBase                     , NIL})
         aadd(aCab,{"W2_IMPCO"  , "2"                           , NIL})
         aadd(aCab,{"W2_FORN"   , AvKey(c2Forn,"W2_FORN")        , NIL})
         aadd(aCab,{"W2_FORLOJ" , AvKey(c2Loja,"W2_FORLOJ")      , NIL})
         aadd(aCab,{"W2_MOEDA"  , AvKey(c2Moeda,"W2_MOEDA")      , NIL})
         aadd(aCab,{"W2_AGENTE" , AvKey(c2Agente,"W2_AGENTE")    , NIL})
         aadd(aCab,{"W2_TIPO_EM", c2ViaTrans                     , NIL})
         aadd(aCab,{"W2_ORIGEM" , c2Origem                       , NIL})
         aadd(aCab,{"W2_DEST"   , c2Destino                      , NIL})
         aadd(aCab,{"W2_COND_PA", AvKey(c2CondPag,"W2_COND_PA")  , NIL})

         If Posicione("SY6",1,xFilial("SY6")+AvKey(c2CondPag,"Y6_COD"),"Y6_COM_LC") == "1" //NCF - 03/10/2016
            aadd(aCab,{"W2_E_LC", "1"  , NIL})
         EndIf

         aadd(aCab,{"W2_COMPRA" , AvKey(c2Comprador,"W2_COMPRA") , NIL})
         aadd(aCab,{"W2_INCOTER", AvKey(c2Incoterm,"W2_INCOTER") , NIL})
         aadd(aCab,{"W2_IMPORT" , AvKey(c2Import,"W2_IMPORT")    , NIL})
         aadd(aCab,{"W2_CONTR"  , "2"                           , NIL})
      EndIf

      aDetalhe := {}
      aadd(aDetalhe,{"W3_FILIAL"  , xFilial("SW3")           , NIL})
      aadd(aDetalhe,{"W3_CC"      , WKSI->W1_CC              , NIL})
      aadd(aDetalhe,{"W3_SI_NUM"  , WKSI->W1_SI_NUM          , NIL})
      aadd(aDetalhe,{"W3_COD_I"   , WKSI->W1_COD_I           , NIL})
      aadd(aDetalhe,{"W3_FABR"    , WKSI->W1_FABR            , NIL})
      aadd(aDetalhe,{"W3_FABLOJ"  , WKSI->W1_FABLOJ          , NIL})
      aadd(aDetalhe,{"W3_QTDE"    , WKSI->W1_QTDE            , NIL})
      aadd(aDetalhe,{"W3_SALDO_Q" , WKSI->W1_SALDO_Q         , NIL})
      aadd(aDetalhe,{"W3_PRECO"   , WKSI->W1_PRECO           , NIL})
      aadd(aDetalhe,{"W3_PO_NUM"  , AvKey(cNumPo,"W3_PO_NUM"), NIL})
      aadd(aDetalhe,{"W3_FORN"    , AvKey(cForn,"W3_FORN")   , NIL})
      aadd(aDetalhe,{"W3_FORLOJ"  , AvKey(cLoja,"W3_FORLOJ") , NIL})
      aadd(aDetalhe,{"W3_CC"      , WKSI->W1_CC              , NIL})
      aadd(aDetalhe,{"W3_SI_NUM"  , WKSI->W1_SI_NUM          , NIL})
      aadd(aDetalhe,{"W3_DT_EMB"  , dDataEmbarque            , NIL})
      aadd(aDetalhe,{"W3_DT_ENTR" , dDataEntrega             , NIL})
      aadd(aDetalhe,{"W3_REG"     , WKSI->W1_REG             , NIL})
      aadd(aDetalhe,{"W3_TEC"     , WKSI->B1_POSIPI          , NIL})

      aadd(aDet, aDetalhe)
   Next i

   If Len(aCab) # 0 .AND. Len(aDet) # 0
      MSExecAuto({|| EICPO400(,aCab,aDet,3)})

      If lMSErroAuto
         MostraErro()
         MsgAlert(STR0030,STR0010)  // "Purchase Order não gerado." ### "Aviso"
         Return .F.
      EndIf

      MsgInfo(STR0028 + ENTER + STR0029 + AvKey(cNumPo,"W3_PO_NUM"),STR0010)  // "Purchase Order gerado com sucesso!" ### "Número P.O.: " ### "Aviso"
   Else
      MsgAlert(STR0030,STR0010)  // "Purchase Order não gerado." ### "Aviso"
   EndIf

Else    // Tratamento para Contrato

   For i := 1 To Len(aItens)+1

      If i > Len(aItens) /*WKSI->(EasyRecCount())*/
         If Len(aCab) # 0 .AND. Len(aDet) # 0
            MSExecAuto({|| EICPO400(,aCab,aDet,3)})

            If lMSErroAuto
               MostraErro()
               MsgAlert(STR0030,STR0010)  // "Purchase Order não gerado." ### "Aviso"
               Return .F.
            EndIf

            MsgInfo(STR0028 + ENTER + STR0029 + If( EasyGParam("MV_NRPO",,"N")=="N", AvKey(aCab[2][2],"W3_PO_NUM"), SW3->W3_PO_NUM ),STR0010)  // "Purchase Order gerado com sucesso!" ### "Número P.O.: " ### "Aviso"
         EndIf
         Exit
      Else
         WKSI->(DbGoTo(aItens[i]))
         If !lNumPOAuto .And. Empty(WKSI->W1_PO_NUM)
            Loop
         ElseIf If(!lNumPOAuto, cNumPOE <> AvKey(WKSI->W1_PO_NUM,"W2_PO_NUM") , cRefAgrup <> WKSI->W0_REFER1 ) //NCF - 19/09/2016
            /*
            If Len(aCab) # 0 .AND. Len(aDet) # 0
               MSExecAuto({|| EICPO400(,aCab,aDet,3)})

               If lMSErroAuto
                  MostraErro()
                  MsgAlert(STR0030,STR0010)  // "Purchase Order não gerado." ### "Aviso"
                  Return .F.
               EndIf

               MsgInfo(STR0028 + ENTER + STR0029 + If( EasyGParam("MV_NRPO",,"N")=="N", AvKey(aCab[2][2],"W3_PO_NUM"), SW3->W3_PO_NUM ) ,STR0010)  // "Purchase Order gerado com sucesso!" ### "Número P.O.: " ### "Aviso"
            EndIf
            */
            aCab := {}
            aDet := {}

            aadd(aCab,{"W2_FILIAL" , xFilial("SW2")                , NIL})
            aadd(aCab,{"W2_PO_NUM" , If(lNumPOAuto,".",AvKey(WKSI->W1_PO_NUM,"W2_PO_NUM")), NIL})
            If lNumPOAuto                                                                                       //NCF - 20/09/2016
               aadd(aCab,{"W2_PO_SIGA" , "."/*Alltrim( Substr( WKSI->W0_REFER1, At("|",WKSI->W0_REFER1)+1 ) )*/ , NIL})
            EndIf
            aadd(aCab,{"W2_PO_DT"  , dDataBase                     , NIL})
            aadd(aCab,{"W2_IMPCO"  , "2"                           , NIL})
            aadd(aCab,{"W2_FORN"   , AvKey(c2Forn,"W2_FORN")        , NIL})
            aadd(aCab,{"W2_FORLOJ" , AvKey(c2Loja,"W2_FORLOJ")      , NIL})
            aadd(aCab,{"W2_MOEDA"  , AvKey(c2Moeda,"W2_MOEDA")      , NIL})
            aadd(aCab,{"W2_AGENTE" , AvKey(c2Agente,"W2_AGENTE")    , NIL})
            aadd(aCab,{"W2_TIPO_EM", c2ViaTrans                     , NIL})
            aadd(aCab,{"W2_ORIGEM" , c2Origem                       , NIL})
            aadd(aCab,{"W2_DEST"   , c2Destino                      , NIL})
            aadd(aCab,{"W2_COND_PA", AvKey(c2CondPag,"W2_COND_PA")  , NIL})

            If Posicione("SY6",1,xFilial("SY6")+AvKey(c2CondPag,"Y6_COD"),"Y6_COM_LC") == "1" //NCF - 03/10/2016
               aadd(aCab,{"W2_E_LC", "1"  , NIL})
            EndIf

            aadd(aCab,{"W2_COMPRA" , AvKey(c2Comprador,"W2_COMPRA") , NIL})
            aadd(aCab,{"W2_INCOTER", AvKey(c2Incoterm,"W2_INCOTER") , NIL})
            aadd(aCab,{"W2_IMPORT" , AvKey(c2Import,"W2_IMPORT")    , NIL})
            aadd(aCab,{"W2_CONTR"  , "1"                            , NIL})
            cNumPOE := AvKey(WKSI->W1_PO_NUM,"W2_PO_NUM")
            cRefAgrup := WKSI->W0_REFER1
         EndIf

         aDetalhe := {}
         //wfs - quando a data de entrega for menor que a data base, assume a data base do sistema para a geração do P.O.
         If WKSI->W1_DTENTR_ < dDataBase
            dDataEntrega:= dDataBase
         Else
            dDataEntrega:= WKSI->W1_DTENTR_
         EndIf
         //wfs - recalcula a data de embarque, considerando o leadtime e a nova data de entrega
         dDataEmbarque:= CalcDataEmbarque(dDataEntrega, c2ViaTrans,c2Origem,c2Destino)

         aadd(aDetalhe,{"W3_FILIAL"  , xFilial("SW3")           , NIL})
         aadd(aDetalhe,{"W3_CC"      , WKSI->W1_CC              , NIL})
         aadd(aDetalhe,{"W3_SI_NUM"  , WKSI->W1_SI_NUM          , NIL})
         aadd(aDetalhe,{"W3_COD_I"   , WKSI->W1_COD_I           , NIL})
         aadd(aDetalhe,{"W3_FABR"    , WKSI->W1_FABR            , NIL})
         aadd(aDetalhe,{"W3_FABLOJ"  , WKSI->W1_FABLOJ          , NIL})
         aadd(aDetalhe,{"W3_QTDE"    , WKSI->W1_QTDE            , NIL})
         aadd(aDetalhe,{"W3_SALDO_Q" , WKSI->W1_SALDO_Q         , NIL})
         aadd(aDetalhe,{"W3_PRECO"   , WKSI->W1_PRECO           , NIL})
         aadd(aDetalhe,{"W3_PO_NUM"  , AvKey(WKSI->W1_PO_NUM,"W3_PO_NUM"), NIL})
         aadd(aDetalhe,{"W3_FORN"    , AvKey(cForn,"W3_FORN")   , NIL})
         aadd(aDetalhe,{"W3_FORLOJ"  , AvKey(cLoja,"W3_FORLOJ") , NIL})
         aadd(aDetalhe,{"W3_CC"      , WKSI->W1_CC              , NIL})
         aadd(aDetalhe,{"W3_SI_NUM"  , WKSI->W1_SI_NUM          , NIL})
         aadd(aDetalhe,{"W3_REG"     , WKSI->W1_REG             , NIL})
         aadd(aDetalhe,{"W3_DT_EMB"  , dDataEmbarque            , NIL})
         aadd(aDetalhe,{"W3_DT_ENTR" , dDataEntrega             , NIL})
         aadd(aDetalhe,{"W3_TEC"     , WKSI->B1_POSIPI          , NIL})

         aadd(aDet, aDetalhe)
      EndIf
   Next i

EndIf

RestOrd(aOrd,.T.)
Return

*----------------------------------*
Static Function SI410SetPO(lCotacao)
*----------------------------------*
Local oDlg, nOp := 0, cPO := "", cAgrup := ""
Local nRecWKSI :=  WKSI->(Recno())           //NCF - 19/09/2016 - reposicionar registro

//consulta padrão AVI002
M->W2_FORN:= cForn
M->W2_FORLOJ:= cLoja
M->W3_COD_I:= WKSI->W1_COD_I

DEFINE MSDIALOG oDlg TITLE STR0033 FROM 0,0 TO If(lCotacao,180,210),300 OF oMainWnd PIXEL  //"Edição de Dados"

   If !lCotacao
      @ 49,10 SAY STR0032 PIXEL OF oDlg //"Número de P.O.:"
      @ 48,50 MSGET WKSI->W1_PO_NUM SIZE 100,10 VALID SI410VALID("PO",WKSI->W1_PO_NUM,WKSI->W0_REFER1) WHEN (EasyGParam("MV_NRPO",,"N") == "N") PIXEL OF oDlg

      @ 69,10 SAY STR0034 PIXEL OF oDlg //"Fabricante:"
      @ 68,50 MSGET WKSI->W1_FABR   SIZE 30,10 F3 "AVI002" VALID /*ExistChav("SA2",WKSI->W1_FABR+WKSI->W1_FABLOJ) .AND.*/ SI410VALID("FABR",,,WKSI->W1_FABR,WKSI->W1_FABLOJ) PIXEL OF oDlg
      @ 68,90 MSGET WKSI->W1_FABLOJ SIZE 30,10 VALID /*ExistChav("SA2",WKSI->W1_FABR+WKSI->W1_FABLOJ) .AND.*/ SI410VALID("FABR",,,WKSI->W1_FABR,WKSI->W1_FABLOJ) PIXEL OF oDlg

      @ 89,10 SAY STR0036 PIXEL OF oDlg //"N.C.M."
      @ 88,50 MSGET WKSI->B1_POSIPI SIZE 50,10 F3 "SYD1" PICTURE AvSx3("B1_POSIPI",AV_PICTURE) VALID SI410VALID("NCM") PIXEL OF oDlg
   Else
      @ 49,10 SAY STR0034 PIXEL OF oDlg //"Fabricante:"
      @ 49,50 MSGET WKSI->W1_FABR   SIZE 30,10 F3 "AVI002" VALID /*ExistChav("SA2",WKSI->W1_FABR+WKSI->W1_FABLOJ) .AND.*/ SI410VALID("FABR",,,WKSI->W1_FABR,WKSI->W1_FABLOJ) PIXEL OF oDlg
      @ 49,90 MSGET WKSI->W1_FABLOJ SIZE 30,10 VALID /*ExistChav("SA2",WKSI->W1_FABR+WKSI->W1_FABLOJ) .AND.*/ SI410VALID("FABR",,,WKSI->W1_FABR,WKSI->W1_FABLOJ) PIXEL OF oDlg

      @ 69,10 SAY STR0036 PIXEL OF oDlg //"N.C.M."
      @ 68,50 MSGET WKSI->B1_POSIPI SIZE 50,10 F3 "SYD1" PICTURE AvSx3("B1_POSIPI",AV_PICTURE) VALID SI410VALID("NCM") PIXEL OF oDlg
   EndIf

ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, {|| nOp := 1, oDlg:End()}, {|| nOp := 0, oDlg:End()}) CENTERED

If nOp == 0
   WKSI->W1_PO_NUM := ""
   //WKSI->W1_FABR   := ""    //NCF - 19/09/2016 - Não apagar informações
   //WKSI->W1_FABLOJ := ""
   //WKSI->(DbGoTop())
ElseIf nOp == 1
   cPO    := WKSI->W1_PO_NUM
   cAgrup := WKSI->W0_REFER1

   WKSI->(DbSetOrder(3))  //"W0_REFER1"
   WKSI->(DbSeek(AvKey(cAgrup,"W0_REFER1")))
   Do While WKSI->(!Eof()) .AND. WKSI->W0_REFER1 == AvKey(cAgrup,"W0_REFER1")
      WKSI->W1_PO_NUM := cPO
      WKSI->(DbSkip())
   EndDo
   //WKSI->(DbGoTop())
EndIf

WKSI->(DbGoTo(nRecWKSI))

Return .T.

*---------------------------*
Function SI410F3()
*---------------------------*
Local lRet := .T., nInc
Local oDlg, oBrowse
Local bOk:= {|| lRet:= .T., oDlg:End()}
Local bCancel:= {|| lRet:= .F., oDlg:End()}
Local aCampos:= {"W1_C3_NUM", "W1_FORN", "A2_NREDUZ"}
Local cQuery := ""

   If Select("WK_SW1F3") # 0
      WK_SW1F3->(DbCloseArea())
   EndIf

   //cQuery += " SELECT DISTINCT W1_C3_NUM, W1_FORN FROM " + RetSqlName("SW1") + " SW1 "
   //cQuery += " WHERE SW1.D_E_L_E_T_ <> '*' AND SW1.W1_STATUS = 'G' AND SW1.W1_C3_NUM <> '' "

   cQuery += " SELECT DISTINCT W1_C3_NUM, W1_FORN, A2_NREDUZ "  //NCF - 04/10/2016 - Trazer também a descrição do fornecedor
   cQuery += " FROM " + RetSqlName("SW1") + " SW1"
   cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2"
   cQuery += " ON SW1.W1_FORN = SA2.A2_COD"
   cQuery += " AND SW1.W1_FORLOJ = SA2.A2_LOJA"
   cQuery += " Where SW1.W1_FILIAL = '" + SW1->(xFilial()) + "'"
   If TcSrvType() <> "AS/400"
      cQuery += " AND SW1.D_E_L_E_T_ <>'*'"
   EndIf
   cQuery += " AND SW1.W1_STATUS = 'G' AND SW1.W1_C3_NUM <> ''"

   cQuery:= ChangeQuery(cQuery)

   EasyWkQuery(cQuery,"WK_SW1F3",{"W1_C3_NUM"})

   If WK_SW1F3->(Bof()) .AND. WK_SW1F3->(Eof())
      bOk := bCancel
   Else
      WK_SW1F3->(DbSetOrder(1))
      WK_SW1F3->(DbGoTop())
   EndIf

   Define MsDialog oDlg Title STR0039 From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM /** 0.5*/, DLG_COL_FIM /** 0.5*/ Of oMainWnd Pixel  //"Seleção de Contratos e/ou Cotações do ERP"

      Define FWBROWSE oBrowse DATA TABLE ALIAS "WK_SW1F3" LINE BEGIN 1 OF oDlg
         For nInc := 1 To Len(aCampos)
             ADD COLUMN oColumn DATA &("{ ||" + aCampos[nInc] + " }") TITLE AvSx3(aCampos[nInc], AV_TITULO) PICTURE AvSx3(aCampos[nInc], AV_PICTURE) SIZE AvSx3(aCampos[nInc], AV_TAMANHO) DOUBLECLICK bOk OF oBrowse
         Next
         oBrowse:Refresh(.T.)
      Activate FWBROWSE oBrowse

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel)

	If lRet
	   SW1->(DbSetOrder(5))  //"W1_FILIAL+W1_C3_NUM+W1_POSICAO+STR(W1_SEQ, 2, 0)"
	   SW1->(DbSeek(xFilial("SW1")+WK_SW1F3->W1_C3_NUM))
	   Do While SW1->(!Eof()) .And. SW1->W1_C3_NUM == WK_SW1F3->W1_C3_NUM //NCF - 13/09/2016 - Posicionar no contrato de mesmo fornecedor selecionado
	      If SW1->W1_FORN <> WK_SW1F3->W1_FORN
	         SW1->(DbSkip())
	         Loop
	      Else
	         Exit
	      EndIf
	   EndDo
	EndIf

    //If Select("WK_SW1F3") # 0
       WK_SW1F3->(DbCloseArea())
    //EndIf

Return lRet

/*
Função     : SI410TstMv
Objetivo   : Validar parâmetros de pergunte não informados
Parâmetros : nQtdMv_Par - Quantidade de Parâmetros a avaliar
             aParNoVer  - Parametros na sequencia que não serão avaliados
             cChvPergunt - Chave do Pergunte para retornar o título do parâmetro
                           no arquivo SX1.
Retorno    : aRet, onde:
                   aRet[1] - Retorna T se todos os parâmetros verificados
                             estiverem informados e F caso um deles não esteja.
                   aRet[2] - Mensagem informando o parâemtro ou título do parâmetro
                             que não foi informado.
Autor      : Nilson César C. Filho - NCF
Data/Hora  : 01/09/2016 :: 13:00
*/
Function SI410TstMv(nQtdMv_Par,aParNoVer,cChvPergunt)

Local aRet         := {.T.,""}
Local lRet         := .T.
Local cMsgRet      := ""
Local cTstMcrStr   := ""
Local nIter        := 1
Default nQtdMv_Par := 1
Default aParNoVer  := {}
Default cChvPergunt:= ""

aOrdSX1 := SaveOrd("SX1")
SX1->(DbSetOrder(1))
For nIter:= 1 To nQtdMv_Par
   If aScan(aParnoVer, nIter) == 0
      cTstMcrStr := "mv_par"+(If(nIter<10,"0",""))+cValtochar(nIter)
      If Empty(&(cTstMcrStr))
         If !Empty(cChvPergunt)
            If SX1->(DbSeek( cChvPergunt + If(nIter<10,"0","") + cValtochar(nIter) ))
               cMsgRet += "Parâmetro '"+Alltrim(SX1->X1_PERGUNT)+"' não informado!" + CHR(13)+CHR(10)
            Else
               cMsgRet += "Parâmetro '"+cTstMcrStr+"' não informado!" + CHR(13)+CHR(10)
            EndIf
         Else
            cMsgRet += "Parâmetro '"+cTstMcrStr+"' não informado!" + CHR(13)+CHR(10)
         EndIf
         lRet := .F.
      EndIf
   EndIf
Next nIter

RestOrd(aOrdSX1,.T.)
aRet := {lRet,cMsgRet}

Return aRet


//NCF - 26/09/2016
Function SI410GtAgp(cSiNum)

Local lExist   := .F.
Local cRet     := ""
Local aOrdSW0  := {}
Default cSiNum := ""

lExist := SW0->(FieldPos("W0_REFER1")) > 0

If lExist .And. !Empty(cSiNum)
   aOrdSW0 := SaveOrd("SW0")
   SW0->(DbSetOrder(1))
   If SW0->(DbSeek(xFilial("SW0")+Avkey("99999","W0__CC")+Avkey(cSiNum,"W0__NUM") ))
      cRet := SW0->W0_REFER1
   EndIf
   RestOrd(aOrdSW0,.T.)
Endif

Return cRet



*-------------------------------------------------------*
Static Function MarkGroupItens(nopc,aItens,cAgrup,cPO)
*-------------------------------------------------------*
Local nRecno   := WKSI->(Recno())
Default aItens := {}
Default cPo    := ""
Default cAgrup := AvKey("","W0_REFER1")
default nOpc   := 0

if nOpc <> 0
   WKSI->(DbGoTop())

   While WKSI->(!Eof())
      If WKSI->W0_REFER1 == cAgrup
         if nOpc == 1
            aAdd(aItens, WKSI->(Recno()))
            WKSI->W1_PO_NUM := cPO
         else
            If (nPos := aScan(aItens,WKSI->(Recno()))) > 0
               aDel(aItens,nPos)
               aSize(aItens, Len(aItens)-1)
               WKSI->W1_PO_NUM := ""
            EndIf
         endif
      EndIf
      WKSI->(DbSkip())
   EndDo

   WKSI->(DbGoTo(nRecno))
Endif

Return aItens

/*
Função     : CalcDataEmbarque
Objetivo   : Retornar a previsão de embarque, considerando a data de entrega prevista, transito e
             prazo para desembaraço
Parâmetros : 1. data de entrega prevista
             2. via de transporte
             3. origem
             4. destino
Retorno    : data de embarque prevista
Autor      : WFS
Data/Hora  : Mai/2017
*/
Static Function CalcDataEmbarque(dDataEntrega, cVia, cOrigem, cDestino)
Local aOrd:= SaveOrd({"SY9", "SYR"})
Local dDataEmbarque
Local nTrTimeExt, nTrTimeInt, nLtDesembaraco

Begin Sequence

    SY9->(DBSetOrder(2)) //Y9_FILIAL+Y9_SIGLA
    SYR->(DBSetOrder(1)) //YR_FILIAL+YR_VIA+YR_ORIGEM+YR_DESTINO+YR_TIPTRAN

    //LeadTime de transito internacional
    SYR->(MSSeek(xFilial() + cVia + cOrigem + cDestino))
    nTrTimeExt:= SYR->YR_TRANS_T

    //LeadTime de transporte interno e desembaraço. Caso não exista, assume o parâmetro
    nTrTimeInt:= 0
    nLtDesembaraco:= 0
    If SY9->(MSSeek(xFilial() + cDestino))
        nTrTimeInt:= SY9->Y9_LT_TRA
        nLtDesembaraco:= SY9->Y9_LT_DES
    Else
        nLtDesembaraco:= EasyGParam("MV_LT_DESE")
    EndIf

    dDataEmbarque:= dDataEntrega - nTrTimeExt - nLtDesembaraco - nTrTimeInt
    If dDataEmbarque < dDataBase
      dDataEmbarque:= dDataBase
    EndIf


End Sequence

RestOrd(aOrd, .T.)
Return dDataEmbarque
