#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'TMSAC13.ch'

/*/-----------------------------------------------------------
{Protheus.doc} TMSAC13()
Configurador TMS X FreteBras

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSAC13()
Local oBrowse   := Nil				// Recebe o  Browse          

Private  aRotina   := MenuDef()		// Recebe as rotinas do menu.

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DM1")			    // Alias da tabela utilizada
oBrowse:SetMenuDef("TMSAC13")		// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription( STR0001 + " " + STR0002 )		//"Configurador Fretbras"
oBrowse:Activate()

Return

/*/-----------------------------------------------------------
{Protheus.doc} menudef()
Menu da rotina

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0008  ACTION "AxPesqui"        	OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSAC13" 	OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSAC13" 	OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSAC13" 	OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE STR0007  ACTION "VIEWDEF.TMSAC13" 	OPERATION 5 ACCESS 0 // "Excluir"
ADD OPTION aRotina TITLE STR0009  ACTION "TMSAC13Con()" 	OPERATION 6 ACCESS 0 // "Testar Conexão"

Return(aRotina)  

/*/-----------------------------------------------------------
{Protheus.doc} ModelDef()
Modelo de dados

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()
Local oModel	:= Nil		// Objeto do Model
Local oStruDM1	:= Nil		// Recebe a Estrutura da tabela DLU
Local bCommit 	:= { |oModel| CommitMdl(oModel) }
Local bPosValid := { |oModel| PosVldMdl(oModel) }

oStruDM1:= FWFormStruct( 1, "DM1" )

oModel := MPFormModel():New( "TMSAC13",,bPosValid, bCommit , /*bCancel*/ ) 
oModel:AddFields( 'MdFieldDM1',, oStruDM1,,,/*Carga*/ ) 
oModel:GetModel( 'MdFieldDM1' ):SetDescription( STR0001 + " " + STR0002  ) 	//"Configurador Fretebras"
oModel:SetPrimaryKey({"DM1_FILIAL" , "DM1_ID"})       
oModel:SetActivate( )
     
Return oModel 

/*/-----------------------------------------------------------
{Protheus.doc} ViewDef()
Criação da View

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()     
Local oModel	:= Nil		// Objeto do Model 
Local oStruDM1	:= Nil		// Recebe a Estrutura da tabela DM1
Local oView					// Recebe o objeto da View

oModel   := FwLoadModel("TMSAC13")
oStruDM1 := FWFormStruct( 2, "DM1" )

oView := FwFormView():New()
oView:SetModel(oModel)     

oView:AddField('VwFieldDM1', oStruDM1 , 'MdFieldDM1')   

oView:CreateHorizontalBox('CABECALHO', 100)  
oView:SetOwnerView('VwFieldDM1','CABECALHO')

Return oView

/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Pós-validação do modelo de dados

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
Local lRet			:= .T. 
Local aAreaDM1      := DM1->(GetArea())

DM1->(dbSetorder(2))
If FwFldGet("DM1_MSBLQL") == "2" .And. DM1->(MsSeek(xFilial("DM1") + "2" ))

    While DM1->DM1_FILIAL + DM1->DM1_MSBLQL == xFilial("DM1") + "2" 
        
        If DM1->DM1_ID <> FwFldGet("DM1_ID")      
            lRet    := .F. 
            Help("",1,"TMSAC130000001") //-- Não é permitido mais de um ID ativos. 
            Exit
        EndIf

        DM1->(dbSkip())
    EndDo

EndIf

RestArea(aAreaDM1)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} CommitMdl()
Commit do modelo de dados

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function CommitMdl(oModel)
Local lRet	:= .T. 

lRet	:= FwFormCommit(oModel)

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSAFretBr()
Indica se a integração com fretebras está habilitada

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSAFretBr()
Local lRet      := .F. 
Local oFreteBr  := Nil 

If TableInDic("DM1")

    DM1->(dbSetorder(2))
    If DM1->( dbSeek(xFilial("DM1") + "2" ) ) 
        If DM1->(ColumnPos("DM1_IDTOTV")) > 0 
            If !Empty(DM1->DM1_IDTOTV)
                lRet        := .T. 
                oFreteBr    := TMSBCAFreteBras():New()
                lRet        := oFreteBr:GetStatusApp()
            EndIf 
        EndIf 
    EndIf
EndIf


Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSAC13Con()
Verifica se a conexão está ativa

@author Caio Murakami   
@since 02/06/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSAC13Con()
Local oFrete    := Nil 
Local lRet      := .F. 

If DM1->DM1_MSBLQL == "2" .And. TMSAFretBr()

    oFrete  := TMSBCAFreteBras():New()
    cToken  := oFrete:GetAccessToken() //objeto:nomedométodo() 

    If !Empty(cToken)
        lRet    := .T. 
    EndIf

    FwFreeObj( oFrete )
EndIf

If lRet
    MsgInfo("Token: " + SubStr(cToken,1,30) )
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} QtdFrete()
Verifica se a conexão está ativa

@author Caio Murakami   
@since 17/09/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function QtdFrete()
Local aArea     := GetArea()
Local nQtde     := 0 
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

cQuery  := " SELECT COUNT(*) QTDFRETE "
cQuery  += " FROM " + RetSQLName("DM2") + " DM2 "
cQuery  += " WHERE DM2_FILIAL   = '" + xFilial("DM2") + "' "
cQuery  += " AND DM2_IDFRT      <> '' "
 
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery ), cAliasQry, .F., .T. )

While (cAliasQry)->( !Eof() )
    nQtde   := (cAliasQry)->QTDFRETE
    (cAliasQry)->(dbSkip())
EndDo 

(cAliasQry)->(dbCloseArea())

RestArea( aArea )
Return nQtde

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSAC13Leg
Mostra Legenda Dos Status da FreteBras
@author Caio Murakami
@since  13/01/2020
@type function
@version P12
/*/
//-------------------------------------------------------------------
Function TMSAC13Leg( cAlias, nModulo , nOpc , lRetArr  )

Local aLegenda := {}

Default cAlias  := ""
Default nModulo := 32
Default nOpc    := 3
Default lRetArr := .F. 

Aadd(aLegenda,{"BR_BRANCO"	        , STR0010 })    //-- FreteBras - "Não há oferta de carga"   
Aadd(aLegenda,{"BR_VERDE"	        , STR0012 })    //-- FreteBras Oferta de carga ativa
Aadd(aLegenda,{"BR_LARANJA"	        , STR0011 })    //-- FreteBras "Oferta de carga expirada há mais de 7 dias" 
Aadd(aLegenda,{"BR_AZUL"	        , STR0013 })    //-- FreteBras Oferta de carga encerrada

If Len(aLegenda) > 0 .And. !lRetArr
    BrwLegenda( STR0002 , STR0002 , aLegenda )  //-- Fretebras
EndIf
				
Return Iif( lRetArr,aLegenda,.T. )


//-----------------------------------------------------------------
/*/{Protheus.doc} TMSAC13St()
Função para obter o status da integração da FreteBras

@author Caio Murakami
@since 13/01/2020
@type function
@version 1.0
/*/
//--------------------------------------------------------------------
Function TMSAC13St( cFilOri , cViagem  , cTipoRet )
Local aArea     := GetArea()
Local xRet      := "" 
Local cQuery    := ""
Local cAliasQry := ""

Static _oStatDm2    

Default cFilOri     := DTQ->DTQ_FILORI
Default cViagem     := DTQ->DTQ_VIAGEM
Default cTipoRet    := "1" //-- 1=Cor;2=Números

xRet    := Iif(cTipoRet == "1" , "BR_BRANCO" , 1 ) //-- Não possui integração

If _oStatDm2 == Nil
    _oStatDm2   := FWPreparedStatement():New()

    cQuery  := " SELECT MAX(DM2.R_E_C_N_O_) DM2RECNO "
    cQuery  += " FROM " + RetSQLName("DM2") + " DM2 "
    cQuery  += " WHERE DM2_FILIAL   = ? "
    cQuery  += " AND DM2_FILORI     = ? "
    cQuery  += " AND DM2_VIAGEM     = ? "    
    cQuery  += " AND DM2.D_E_L_E_T_ = '' "

    cQuery      := ChangeQuery(cQuery)    
    _oStatDm2:SetQuery(cQuery)    

EndIf

_oStatDm2:SetString(1,xFilial("DM2"))
_oStatDm2:SetString(2,cFilOri)
_oStatDm2:SetString(3,cViagem)

cQuery  := _oStatDm2:GetFixQuery() //-- Retorna querie do objeto

cAliasQry   := GetNextAlias()
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

TcSetField(cAliasQry,"R_E_C_N_O_"  ,"N",10,0)

While (cAliasQry)->(!Eof() )
    DM2->( dbGoTo((cAliasQry)->DM2RECNO) )

    If DM2->DM2_STATUS == "1" //-- Em Aberto
        If dDataBase - DM2->DM2_DTFRT > 7  
            xRet    := Iif(cTipoRet == "1" , "BR_LARANJA" , 3 ) //-- Expirado
        Else 
            xRet    := Iif(cTipoRet == "1" , "BR_VERDE" , 2 ) //-- Ativa
        EndIf 
    ElseIf DM2->DM2_STATUS == "2" //-- Encerrado
        xRet    := Iif(cTipoRet == "1" , "BR_AZUL" , 4 ) //-- Encerrado
    EndIf 
    
    (cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea())


RestArea(aArea)
Return xRet
