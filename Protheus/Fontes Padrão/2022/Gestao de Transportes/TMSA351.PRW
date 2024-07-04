#include "shell.ch"
#include "TMSA351.ch"
#include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
/*
-----------------------------------------------------------
{Protheus.doc} TMSA351()
Consulta Operações de Chegada em Cliente (DLT)

Uso: SIGATMS

@sample
//TMSA351()

@author Katia Tiemi
@since 28/02/2019
@version 1.0
-----------------------------------------------------------
*/
Function TMSA351()

Local oBrowse     := Nil
Local cAtvChgCli  := SuperGetMv('MV_ATVCHGC',,'') //-- Atividade de Chegada em Cliente

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DTW")
oBrowse:SetFilterDefault( "DTW_ATIVID ==  " + "'" + cAtvChgCli + "' .And. DTW_IDDTW <> '' "  )  
oBrowse:SetDescription(STR0003) //Operação
oBrowse:Activate()

Return

/*
-----------------------------------------------------------
{Protheus.doc} TMSA351()
Definição do Modelo

Uso: TMSA351

@sample
//ModelDef()

@author Katia 
@since 28/02/2019
@version 1.0
-----------------------------------------------------------
*/
Static Function ModelDef()

Local oModel	:= Nil
Local oStruDTW	:= FWFormStruct(1,'DTW')
Local oStruDLT	:= FWFormStruct(1,"DLT") 

oModel:= MpFormMOdel():New("TMSA351",  /*bPreValid*/ , /*bPosValid*/ , /*bCommit*/ ,/*bCancel*/ )
oModel:AddFields("MdFieldDTW",Nil,oStruDTW,/*prevalid*/,,/*bCarga*/)
oModel:SetDescription(STR0005) 	 //Chegada em Cliente

oModel:AddGrid( "MdGridDLT", "MdFieldDTW", oStruDLT )
	
oModel:SetRelation( "MdGridDLT", { { "DLT_FILIAL", "xFilial( 'DLT' )" }, { "DLT_FILORI", "DTW_FILORI" }, { "DLT_VIAGEM", "DTW_VIAGEM" }, { "DLT_IDDTW", "DTW_IDDTW" } }, DLT->( IndexKey( 1 ) ) )

If !IsInCallStack("TMSMdlAuto")   //Rotina Automatica
	oModel:GetModel( "MdFieldDTW"):SetOnlyView(.T.)
	oModel:GetModel( "MdFieldDTW"):SetOnlyQuery (.T.)
    oModel:GetModel( "MdGridDLT" ):SetNoInsertLine( .T. )
    oModel:GetModel( "MdGridDLT" ):SetNoDeleteLine( .T. )                                                                         
EndIf    

oModel:SetPrimaryKey({'DTW_FILIAL','DTW_FILORI','DTW_VIAGEM','DTW_IDDTW'})

Return ( oModel )                   

/*
-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSA351

@sample
//ViewDef()

@author Katia
@since 28/02/2019
@version 1.0
-----------------------------------------------------------
*/
Static Function ViewDef()

Local oModel 	:= FwLoadModel("TMSA351")
Local oView 	:= Nil
Local oStruDTW  := FWFormStruct(2, "DTW") 
Local oStruDLT  := FwFormStruct(2, "DLT")

oView:= FwFormView():New()
oView:SetModel(oModel)

oStruDLT:RemoveField( "DLT_FILORI" )
oStruDLT:RemoveField( "DLT_VIAGEM" )
oStruDLT:RemoveField( "DLT_IDDTW" )
oStruDTW:RemoveField( "DTW_IDDTW" )

oView:SetViewAction("ASKONCANCELSHOW",{||.F.}) 
oView:SetCloseOnOk({|| .T. })

oView:CreateHorizontalBox( "Tela" , 020 )
oView:CreateHorizontalBox( "Grid" , 080 )

oView:AddField('VwFieldDTW', oStruDTW , 'MdFieldDTW') 
oView:SetOwnerView("VwFieldDTW","Tela")

oView:AddGrid( "VwGridDLT", oStruDLT, "MdGridDLT" )
oView:SetOwnerView( "VwGridDLT"		, "Grid"	)

oView:AddIncrementView( "VwGridDLT", "DLT_ITEM" )
oView:EnableTitleView( "VwGridDLT" , STR0004)  //Documentos da Operação

oView:SetViewProperty("VwGridDLT", "ENABLENEWGRID")
oView:SetViewProperty("VwGridDLT", "GRIDFILTER", {.T.}) 
oView:SetViewProperty("VwGridDLT", "GRIDSEEK", {.T.}) 
Return(oView)

/*
-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  

Uso: TMSA351

@sample
//MenuDef()

@author Katia
@since 28/02/2019
@version 1.0
-----------------------------------------------------------
*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0001 	ACTION "PesqBrw"          OPERATION 1 ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE STR0002 	ACTION "VIEWDEF.TMSA351" OPERATION 2 ACCESS 0  //"Visualizar"

Return ( aRotina )

/*
-----------------------------------------------------------
{Protheus.doc} TMSA351Vis()
Chamada atraves da opção aRotina do fonte TMSA144 

Uso: TMSA144, TMSA350

@sample
//MenuDef()

@author Katia
@since 28/02/2019
@version 1.0
-----------------------------------------------------------
*/
Function TMSA351Vis()
Local aArea       := GetArea()
Local cAtvChgCli  := SuperGetMv('MV_ATVCHGC',,'') //-- Atividade de Chegada em Cliente
Local cAtvChgApo  := SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio

CheckHLP('PTMSA35103', {'Opção disponivel somente para Operação',' de Chegada em Cliente ou Chegada no',' Ponto de Apoio.'},{''},{''},.T.)

If DTW->DTW_ATIVID == cAtvChgCli .OR. DTW->DTW_ATIVID == cAtvChgApo
    FWExecView (, "TMSA351" , 1 , ,{|| .T. }, , , , , , , )
Else
    Help ( " ", 1, "TMSA35103" )
EndIf    

RestArea(aArea)    
Return .T.    

//-------------------------------------------------------------------
/*/{Protheus.doc} TM351VldEC
Função para validar o estorno da Operação da Chegada em Cliente 
gerada na Viagem em Transito

Uso: TMSA350

@author Katia
@since 26/02/2019
@version 1.0	
/*/
//-------------------------------------------------------------------
Function TM351VldEC(cFilOri,cViagem,cIdDTW)
Local lRet      := .T.
Local aArea     := GetArea()
Local nRet      := 0
Local lColeta   := .F.   //No estorno nao considerar o Documento de Coleta

//--- Verifica se existem documentos incluidos na viagem em Transito (2-Emissao)
nRet:= TM351DocVT(cFilOri,cViagem,cIdDTW,'2', ,lColeta) 
If nRet > 0
    //O estorno da Chegada em Cliente só será permitido se os Documentos emitidos nessa operação, estiverem cancelados.
    Help(' ', 1, 'TMSA35101') 
    lRet:= .F.
Else
    nRet := TM351LotVg(cFilOri, cViagem)
    If nRet > 0
    	CheckHLP('PTMSA35102', {'O estorno da Chegada em Cliente só',' será permitido se os lotes vinculados',' na viagem forem excluídos. '},{''},{''},.T.)
        Help ( " ", 1, "TMSA35102" )  
        lRet := .F.
    EndIf
EndIf 

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TM351DocVT
Função para verificar se existem Documentos incluidos na Viagem em Transito
para uma determinada Operação da Viagem.

@author Katia
@since 26/02/2019
@version 1.0	
/*/
//-------------------------------------------------------------------
Function TM351DocVT(cFilOri,cViagem,cIdDTW,cOrigem,nDLTRecno,lColeta)
Local cQuery    := ""
Local cAliasDLT	:= GetNextAlias()
Local nRet      := 0

Default cFilOri    := ""
Default cViagem    := ""
Default cIdDTW     := ""
Default cOrigem    := ""
Default nDLTRecno  := 0
Default lColeta    := .T.  //Considera os documentos de coleta

cQuery := " SELECT COUNT(*) NREG FROM " + RetSqlName("DLT" ) + " DLT "
//-- DTW
cQuery += " INNER JOIN " + RetSqlName("DTW" ) + " DTW "
cQuery += "  ON DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
cQuery += " AND DTW.DTW_FILORI = DLT.DLT_FILORI "
cQuery += " AND DTW.DTW_VIAGEM = DLT.DLT_VIAGEM "
cQuery += " AND DTW.DTW_IDDTW = DLT.DLT_IDDTW "
cQuery += " AND DTW.D_E_L_E_T_='' "
//-- DLT
cQuery += " WHERE DLT.DLT_FILIAL = '" + xFilial("DLT") + "' "
cQuery += " AND DLT.DLT_FILORI = '" + cFilOri + "' "
cQuery += " AND DLT.DLT_VIAGEM = '" + cViagem + "' "
cQuery += " AND DLT.DLT_IDDTW = '" + cIdDTW + "' "
If !lColeta //Não considera Documentos de Coleta
    cQuery += " AND DLT.DLT_SERIE <> 'COL' "  
EndIf

If !Empty(cOrigem)
    cQuery += " AND DLT.DLT_ORIGEM = '" + cOrigem + "' "   
EndIf    
//-- Nao considera o registro informado
If nDLTRecno > 0
    cQuery += " AND DLT.R_E_C_N_O_ <> " + Str(nDLTRecno)  
EndIf
cQuery += " AND DLT.D_E_L_E_T_='' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDLT,.F.,.T.)
If (cAliasDLT)->(!Eof()) 
    nRet:= (cAliasDLT)->NREG
EndIf  
(cAliasDLT)->(DbCloseArea())

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TM351LotVg
Função para verificar se existem lotes vinculados na viagem.

@author arume.alexandre
@since 05/08/2019
@version 1.0	
/*/
//-------------------------------------------------------------------
Function TM351LotVg(cFilOri, cViagem)

    Local nRet      := 0
    Local cQuery    := ""
    Local cAlias    := GetNextAlias()

    cQuery := "SELECT COUNT(1) AS TOTAL "
    cQuery += "FROM " + RetSqlName("DTP") + " DTP "
    cQuery += "WHERE DTP.DTP_FILIAL = '" + xFilial("DTP") 	+ "' "
    cQuery += "AND DTP.DTP_FILORI = '" + cFilOri			+ "' "
    cQuery += "AND DTP.DTP_VIAGEM = '" + cViagem			+ "' "
    cQuery += "AND DTP.DTP_STATUS NOT IN ('1','2') " //-- Em Aberto, Digitado
    cQuery += "AND DTP.D_E_L_E_T_ = ' '"
    
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., 'TOPCONN', TCGENQRY(,,cQuery), cAlias, .F., .T.)
    If (cAlias)->(!Eof())
        nRet := (cAlias)->TOTAL
    EndIf
    
    (cAlias)->(DbCloseArea())

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsa351DLT
// Função responsável por receber os dados para preparar a gravação da DLT
@author  Rafael Souza
@since   25/02/2019
@param aDLT, array
/*/
//-------------------------------------------------------------------
Function Tmsa351DLT(aCab, nOpc, cFilOri, cViagem, cIdDTW, cFilDoc, cDoc, cSerie, cOrigem, cOpeDoc, lGerApt)
 
Local aItens	:= {}
Local aArea		:= GetArea()
Local aAreaDTW	:= DTW->( GetArea() )

Default cFilOri     := ""
Default	cViagem	    := ""
Default cIdDTW	    := ""
Default cFilDoc	    := ""
Default cDoc	    := ""
Default cSerie	    := ""
Default cOrigem     := "" //-- 1= Fechamento / 2= Viagem em Trânsito
Default cOpeDoc	    := "" //-- 1= Entrega / 2= Emissão / 3= Coleta
Default aCab	    := {}
Default nOpc	    := 3
Default lGerApt     := .F.

DTW->(DbSetOrder(9))
If DTW->(dbSeek(xFilial("DTW") + cFilOri + cViagem + cIdDTW))

	Aadd( aItens , {} )
	Aadd( aItens[Len(aItens)]	, { 'DLT_FILIAL'	, xFilial("DLT")		, Nil } )
	Aadd( aItens[Len(aItens)]	, { 'DLT_FILORI'	, cFilOri				, Nil } )
	Aadd( aItens[Len(aItens)]	, { 'DLT_VIAGEM'	, cViagem				, Nil } )
	Aadd( aItens[Len(aItens)]	, { 'DLT_IDDTW'		, cIdDTW				, Nil } )
	Aadd( aItens[Len(aItens)]	, { 'DLT_FILDOC'	, cFilDoc				, Nil } )
	Aadd( aItens[Len(aItens)]	, { 'DLT_DOC'		, cDoc					, Nil } )
	Aadd( aItens[Len(aItens)]	, { 'DLT_SERIE'		, cSerie				, Nil } )
	Aadd( aItens[Len(aItens)]	, { 'DLT_ORIGEM'	, cOrigem				, Nil } ) 
	Aadd( aItens[Len(aItens)]	, { 'DLT_OPEDOC'	, cOpeDoc				, Nil } )
	Aadd( aItens[Len(aItens)]	, { 'DLT_DATGER'	, dDataBase				, Nil } )
	Aadd( aItens[Len(aItens)]	, { 'DLT_HORGER'	, StrTran(Left(Time(),5),':','')	, Nil } )
    Aadd( aItens[Len(aItens)]	, { 'DLT_GERAPT'	, lGerApt				, Nil } )

	If len(aItens) > 0
		DLT->(DbSetOrder(1))
		If !DLT->(MsSeek(xFilial("DLT") + cFilOri + cViagem + cIdDTW + cFilDoc + cDoc + cSerie )) .And. !Empty(cDoc)
			TMSMdlAuto( aCab , aItens , nOpc , "TMSA351" , "MdFieldDTW" , "MdGridDLT" , "DTW" , "DLT" , .T. ) 
		EndIf 
    EndIf
EndIf

//Limpa o array
aSize(aCab,0)
aSize(aItens,0)

RestArea( aArea )
RestArea( aAreaDTW )
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Tm351IdDTW
// Função responsável por identificar o ultimo ID da DTW 
@author  Rafael Souza
@since   25/02/2019
@param cFilOri,cViagem,nAcao(1=Busca último identificador do DTW / 2=Busca o maior RECNO)
/*/
//-------------------------------------------------------------------
Function Tm351IdDTW(cFilOri,cViagem,nAcao)

Local cQueryDTW := ""
Local cAliasNew := ""
Local cIdDTW    := ""
Local xRet      := ""

Default cFilOri := ""
Default cViagem := ""
Default nAcao   := 1

cAliasNew 	:= GetNextAlias()
cQueryDTW	:= "  SELECT "
If nAcao == 1
	cQueryDTW += "MAX(DTW_IDDTW) MAXIDDTW "
Else
	cQueryDTW += "MAX(DTW.R_E_C_N_O_) ULTDTW "
EndIf
cQueryDTW	+= "  FROM  " + RetSqlName("DTW") + " DTW "
cQueryDTW	+= "  WHERE DTW.DTW_FILIAL = '"+ FwxFilial("DTW") +"' "
cQueryDTW	+= "  AND DTW.DTW_FILORI = '"+ cFilOri +"' "
cQueryDTW	+= "  AND DTW.DTW_VIAGEM = '"+ cViagem +"' "
cQueryDTW	+= "  AND DTW.D_E_L_E_T_ = ' '"

cQueryDTW := ChangeQuery(cQueryDTW)
dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQueryDTW),cAliasNew,.T.,.T.)

If (cAliasNew)->(!Eof())
	If nAcao == 1
	    cIdDTW := (cAliasNew)->MAXIDDTW
	Else
		xRet   := (cAliasNew)->ULTDTW
	EndIf
EndIf

(cAliasNew)->(dbCloseArea())

If nAcao == 1
	cIdDTW  := Soma1(cIdDTW)
	xRet    := cIdDTW
EndIf

Return xRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} TM351DocSq
Função responsável por retornar os documentos incluídos a partir de um IDDTW.

@author arume.alexandre
@since 06/03/2019
@version 1.0	
/*/
//-------------------------------------------------------------------
Function TM351DocSq(cFilOri, cViagem, cIdDTW)

	Local aRet		:= {}
	Local aAreaDLT	:= {}

	Default cFilOri := ""
	Default cViagem := ""
	Default cIdDTW 	:= ""

	If !Empty(cFilOri) .AND. !Empty(cViagem) .AND. !Empty(cIdDTW)
		cIdDTW := StrZero(Val(cIdDTW)-1, Len(DTW->DTW_IDDTW))
		If !Empty(cIdDTW)
			aAreaDLT := DLT->(GetArea())
			DLT->(dbSetOrder(1)) //DLT_FILIAL+DLT_FILORI+DLT_VIAGEM+DLT_IDDTW+DLT_FILDOC+DLT_DOC+DLT_SERIE
			DLT->(MsSeek(xFilial("DLT")+cFilOri+cViagem+cIdDTW))
			While DLT->(!Eof()) .AND. xFilial("DLT")+cFilOri+cViagem+cIdDTW == xFilial("DLT")+DLT->(DLT_FILORI+DLT_VIAGEM+DLT_IDDTW)
				If DLT->DLT_ORIGEM == "2" .AND. DLT->DLT_OPEDOC == "2" .AND. aScan(aRet, {|x| x[1]+x[2]+x[3] == DLT->DLT_FILDOC+DLT->DLT_DOC+DLT->DLT_SERIE}) == 0 // 2-Viagem em Transito
					aAdd(aRet, {DLT->DLT_FILDOC, DLT->DLT_DOC, DLT->DLT_SERIE})
				EndIf
				DLT->(dbSkip())
			EndDo
			RestArea(aAreaDLT)
		EndIf
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA351Exc
Função para excluir os documentos da DLT

Uso: TMSA200

@author Katia
@since 28/02/2019
@version 1.0	
/*/
//-------------------------------------------------------------------
Function TMSA351Exc(cFilDoc,cDoc,cSerie,cFilOri,cViagem)
Local cQuery     := ""
Local cAliasQry  := ""
Local aArea      := GetArea()
Local aAreaDLT   := {}
Local nRet       := 0
Local cIdDTWIni  := ""
Local cIdDTWFim  := ""
Local cAtvSaiCli := SuperGetMv('MV_ATVSAIC',,'')//-- Atividade de Saída do cliente
Local cAtvChgCli := SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente

Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""
Default cFilOri:= ""
Default cViagem:= ""

cAliasQry := GetNextAlias()
cQuery := " SELECT R_E_C_N_O_ DLT_RECNO "
cQuery += "   FROM " + RetSqlName("DLT") + " DLT "
cQuery += "  WHERE DLT.DLT_FILIAL = '" + xFilial('DLT') + "' "
cQuery += "    AND DLT.DLT_FILDOC = '" + cFilDoc + "' "
cQuery += "    AND DLT.DLT_DOC    = '" + cDoc + "' "
cQuery += "    AND DLT.DLT_SERIE  = '" + cSerie + "' "
cQuery += "    AND DLT.DLT_FILORI  = '" + cFilOri + "' "
cQuery += "    AND DLT.DLT_VIAGEM  = '" + cViagem + "' "
cQuery += "    AND DLT.D_E_L_E_T_ = ' ' "
cQuery += "    ORDER BY DLT.DLT_FILORI, DLT.DLT_VIAGEM, DLT.DLT_IDDTW DESC "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
While (cAliasQry)->(!Eof())
    DLT->(MsGoto((cAliasQry)->DLT_RECNO))

    //-- Nao existindo outro documento vinculado no DLT_IDDTW, podera excluir o registro da DTW
    aAreaDLT:= DLT->(GetArea())
    nRet:= 0
    nRet:= TM351DocVT(DLT->DLT_FILORI, DLT->DLT_VIAGEM, DLT->DLT_IDDTW, ,DLT->(RECNO()) )
    RestArea(aAreaDLT)

    If nRet == 0
        //Exclui a Operação de Chegada de Cliente e Saida de Cliente
        cIdDTWIni:= DLT->DLT_IDDTW     //-- Chegada Cliente
        cIdDTWFim:= Soma1(cIdDTWIni)   //-- Saida Cliente  -  'Par' da Chegada do Cliente

        If !Empty(cIdDTWIni) .And. !Empty(cIdDTWFim)
            DTW->(DbSetOrder(9))
            DTW->(DbSeek( xFilial("DTW") + DLT->(DLT_FILORI + DLT_VIAGEM) + cIdDTWIni ))
            While DTW->(!Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM) == xFilial('DTW')+DLT->(DLT_FILORI + DLT_VIAGEM)
                If (DTW->DTW_IDDTW >= cIdDTWIni .And. DTW->DTW_IDDTW <= cIdDTWFim) .And. !Empty(DTW->DTW_CODCLI)
                    lContinua:= .F.

                    If DTW->DTW_IDDTW == cIdDTWIni .And. DTW->DTW_ATIVID == cAtvChgCli 
                        lContinua:= .T.
                    ElseIf DTW->DTW_IDDTW == cIdDTWFim .And. DTW->DTW_ATIVID == cAtvSaiCli 
                        lContinua:= .T.
                    EndIf

                    If lContinua
                        RecLock('DTW',.F.)
                        DTW->(DbDelete())
                        MsUnLock()
                    EndIf    
                EndIf   
                DTW->(dbSkip())
            EndDo
        EndIf    
    EndIf
	
	RecLock('DLT',.F.)
	DLT->(DbDelete())
	MsUnLock()

	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

RestArea(aArea)
Return .T.
