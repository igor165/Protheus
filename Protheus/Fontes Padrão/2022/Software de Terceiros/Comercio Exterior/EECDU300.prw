#INCLUDE 'TOTVS.CH'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'

/*/{Protheus.doc} EECDU300
   (rotina para gerar DUE em lote)
   @type  Function
   @author Miguel Prado Gontijo
   @since 22/05/2018
   @version 1
   @param param, param_type, param_descr
   @return returno,return_type, return_description
   @example
   (examples)
   #@see (lINCLUDEinks_or_references) 'TOTVS.CH'
   /*/
Function EECDU300()
 
Local aArea       := GetArea()
Local aAreaEK0    := EK0->(GetArea())
Local aRotOld     := aClone(aRotina)
Local bMark       := {|| xBMark() }
Local bInit   	  := {|| xMarkinit() }

Private oMarkBrw,oDlgMrk,oDU300
Private cTitulo   := "Transmitir DUE em lote"

aRotina   := MenuDef()

   aAlias 		:= DU300QRY()	
   cAliasMrk	:= aAlias[1]
   aColumns 	:= aAlias[2]

If !(cAliasMrk)->(Eof())

	oMarkBrw:= FWMarkBrowse():New()
    oMarkBrw:SetOwner(oDlgMrk)
	oMarkBrw:SetDescription( cTitulo )
	oMarkBrw:SetAlias( cAliasMrk )
	oMarkBrw:SetFieldMark( "EK0_OK" )
	oMarkBrw:SetMark( "W1" , cAliasMrk , "EK0_OK" )
    
    oMarkBrw:SetColumns(aColumns)
    oMarkBrw:SetWalkThru(.F.)
	oMarkBrw:SetAmbiente(.F.) 
	oMarkBrw:DisableReport(.T.)
    oMarkBrw:SetInvert(.F.)
    oMarkBrw:SetAllMark(bMark)
    oMarkBrw:SetIniWindow( bInit )
	oMarkBrw:Activate()
Else
   Help(" ",1,"RECNO")
EndIf

If oDU300 <> Nil
	oDU300:Delete()
	oDU300 := Nil
Endif

restarea(aAreaEK0)
restarea(aArea)
aRotina := aClone(aRotOld)

return
/*---------------------------------------------------------------------*
 | Func:  xBMark                                                     |
 | Autor: Miguel Gontijo                                               |
 | Data:  22/05/2018                                                   |
 | Desc:  Seleciona os processos com status 2 - aguardando geração e   |
 | monta tabela temporária a ser usada no mark browse                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function xBMark()
Local cAliasEK0 := oMarkBrw:Alias()
Local cLast := ""
Local lSai := .F.
Local nQtd := 0
Local lMarca := ! oMarkBrw:IsMark()

oMarkBrw:GoBottom()
cLast := (cAliasEK0)->EK0_FILIAL + (cAliasEK0)->EK0_PROCES
oMarkBrw:GoTop()

While ! lSai
    if lMarca .and. ! oMarkBrw:IsMark()
        oMarkBrw:MarkRec()
    elseif  ! lMarca .and. oMarkBrw:IsMark()
        oMarkBrw:MarkRec()
    EndIf

    if cLast == (cAliasEK0)->EK0_FILIAL + (cAliasEK0)->EK0_PROCES
        lSai := .T.
    End
    oMarkBrw:GoDown(1)
    //lMarca := oMarkBrw:IsMark()
EndDo

oMarkBrw:Refresh(.T.)

Return
/*---------------------------------------------------------------------*
 | Func:  xMarkinit                                                     |
 | Autor: Miguel Gontijo                                               |
 | Data:  22/05/2018                                                   |
 | Desc:  Seleciona os processos com status 2 - aguardando geração e   |
 | monta tabela temporária a ser usada no mark browse                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function xMarkinit()
Local cAliasEK0 := oMarkBrw:Alias()
Local cLast := ""
Local lSai := .F.
Local nQtd := 0

oMarkBrw:GoBottom()
cLast := (cAliasEK0)->EK0_FILIAL + (cAliasEK0)->EK0_PROCES
oMarkBrw:GoTop()

While ! lSai
    if ! oMarkBrw:IsMark()
        oMarkBrw:MarkRec()
    EndIf
    if cLast == (cAliasEK0)->EK0_FILIAL + (cAliasEK0)->EK0_PROCES
        lSai := .T.
    End
    oMarkBrw:GoDown(1)
EndDo

oMarkBrw:Refresh(.T.)

Return
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Miguel Gontijo                                               |
 | Data:  22/05/2018                                                   |
 | Desc:  Menu com as rotinas                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
    Local aRot := {}

    ADD OPTION aRot TITLE 'Transmissão DUE' ACTION 'TransDUE()' OPERATION MODEL_OPERATION_INSERT ACCESS 0

Return aRot

/*---------------------------------------------------------------------*
 | Func:  GerDUE                                                       |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Chama função que percorre o mark browse para gerar as DUEs   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function TransDUE()

Local nR := CountReg()

    if nR > 0
        If MsgYesNo( "Deseja continuar para a transmissão em lote de DUE?" , cTitulo )
            Processa( {|| xTraDUE(nR) }, cTitulo )
            oMarkBrw:Refresh(.T.)
        EndIf
    Endif

Return .F.
/*---------------------------------------------------------------------*
 | Func:  xGerDUE                                                      |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Rotina que percorre o mark browse gerando as DUEs            |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function xTraDUE(nR)
Local aAreaEEC := EEC->(GetArea())
Local aAreaEK0 := EK0->(GetArea())
Local cAliasEK0 := oMarkBrw:Alias()
Local aBuffer   := {}
Local aProces   := {}
Local nQ        := 1
Local nW        := 1

(cAliasEK0)->(dbgotop())
(cAliasEK0)->(dbeval({|| iif( !empty((cAliasEK0)->EK0_OK) , aadd(aProces,{(cAliasEK0)->(recno())}) , )}))
(cAliasEK0)->(dbgotop())

    procregua( nR )
    For nQ := 1 to len(aProces)

        (cAliasEK0)->(dbgoto(aProces[nQ][1]))
        EK0->( DbGoto( (cAliasEK0)->RECNOEK0 ) )
        EEC->( DbGoto( (cAliasEK0)->RECNOEEC ) )

        incproc( "Lendo XML: " + Alltrim(EEC->EEC_PREEMB) )

        cBuffer := EasyExecAHU("DUE3")
        cBuffer := EncodeUTF8(cBuffer)
        cBuffer := StrTran(cBuffer,"&","e")
        aadd( aBuffer , {cBuffer , (cAliasEK0)->EK0_FILIAL + (cAliasEK0)->EK0_PROCES , (cAliasEK0)->RECNOEEC , (cAliasEK0)->RECNOEK0 } ) // recno da tabela temporaria

        iF (cAliasEK0)->(MsRLock())
            (cAliasEK0)->(DBDelete())
            (cAliasEK0)->(MsUnlock())
        EndIf

    Next
    
    oMarkBrw:Refresh()

    if len(aBuffer) > 0

        IncProc( "Transmitindo lote DUE")
        GerXMLDue(aBuffer)
        ProcRegua( Len(aBuffer) )
        For nW := 1 to len(aBuffer)

            EEC->( DbGoto( aBuffer[nW][3] ) )
            EK0->( DbGoto( aBuffer[nW][4] ) )

            IncProc( "Atualizando: " + alltrim(EEC->EEC_PREEMB) )

            //Atualizar o status para verificar inconsistências impeditivas de geração do arquivo
            DU400GrvStatus()
       
        Next
    EndIf

restarea(aAreaEEC)
restarea(aAreaEK0)

Return
/*---------------------------------------------------------------------*
 | Func:  CountReg                                                     |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Conta os registros selecionados no mark browse               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function CountReg()
Local cAliasEK0 := oMarkBrw:Alias()
Local nQtd := 0

(cAliasEK0)->( dbgotop() )
(cAliasEK0)->( dbeval( {|| iif( !empty( (cAliasEK0)->EK0_OK ) , nQtd++ , ) } ) )
(cAliasEK0)->( dbgotop() )

Return nQtd
/*---------------------------------------------------------------------*
 | Func:  DU300QRY                                                     |
 | Autor: Miguel Gontijo                                               |
 | Data:  22/05/2018                                                   |
 | Desc:  Seleciona os processos com status 2 - aguardando geração e   |
 | monta tabela temporária a ser usada no mark browse                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function DU300QRY()
Local aArea			:= GetArea()			
Local aStru			:= EK0->(DBSTRUCT())	//Estrutura da Tabela
Local aColumns		:= {}					   //Array com as colunas a serem apresentadas

Local nX			:= 0					
Local cArqTrab		:= ""					
Local cQuery		:= ""

/* //NCF - 28/06/2021 - Refeita a query para se adequar aos bancos homologados pela TOTVS (MSSQL,ORACLE,POSTGRESS) validado por ESP Query Analizer
cQuery += "SELECT 'w1' EK0_OK, K.* "
cQuery += ", K.R_E_C_N_O_ RECNOEK0 "
cQuery += ", C.R_E_C_N_O_ RECNOEEC "
cQuery += " FROM "+	RetSqlName("EEC") +" C "
cQuery += " INNER JOIN "+	RetSqlName("EK0") +" K "
cQuery += " ON  K.EK0_FILIAL = C.EEC_FILIAL "
cQuery += " AND K.EK0_PROCES = C.EEC_PREEMB "
cQuery += " AND K.D_E_L_E_T_ <> '*' "
cQuery += " WHERE C.D_E_L_E_T_ <> '*' "
cQuery += " AND K.EK0_FILIAL = '"+xFilial("EK0")+"' "
cQuery += " AND K.EK0_STATUS IN ('1') "
cQuery += " AND K.EK0_FILIAL+K.EK0_PROCES+K.EK0_NUMSEQ = (SELECT K1.EK0_FILIAL+K1.EK0_PROCES+MAX(K1.EK0_NUMSEQ) FROM "+	RetSqlName("EK0") +" K1 WHERE K1.EK0_FILIAL=K.EK0_FILIAL AND K1.EK0_PROCES=K.EK0_PROCES AND K1.EK0_STATUS IN ('1') AND K1.D_E_L_E_T_ <> '*' GROUP BY K1.EK0_FILIAL,K1.EK0_PROCES) "
cQuery += " AND C.EEC_STTDUE = '3' "
cQuery += " ORDER BY "+ SqlOrder(EK0->(IndexKey()))
*/
//NCF - 28/06/2021 - Revisão de query
cQuery += " SELECT     'w1' EK0_OK, K.EK0_FILIAL, K.EK0_PROCES, K.EK0_NUMSEQ, K.EK0_STATUS, K.EK0_DATA, K.EK0_RETIFI, K.EK0_USER, K.R_E_C_N_O_ RECNOEK0 , C.R_E_C_N_O_ RECNOEEC "
cQuery += " FROM "      + RetSqlName("EEC") +" C "
cQuery += " INNER JOIN "+ RetSqlName("EK0") +" K "
cQuery += " ON         K.EK0_FILIAL = C.EEC_FILIAL"
cQuery += " AND        K.EK0_PROCES = C.EEC_PREEMB"
cQuery += " AND        K.D_E_L_E_T_ = ' '"
cQuery += " AND        C.D_E_L_E_T_ = ' '"
cQuery += " AND        K.EK0_STATUS IN ('1')"
cQuery += " AND        C.EEC_STTDUE = '3'"
cQuery += " AND        C.EEC_FILIAL = '"+xFilial("EEC")+"' "
cQuery += " ORDER BY "+ SqlOrder(EK0->(IndexKey()))

Aadd(aStru, {"EK0_OK","C",2,0})
Aadd(aStru, {"RECNOEK0","N",10,0})
Aadd(aStru, {"RECNOEEC","N",10,0})

If oDU300 <> Nil
	oDU300:Delete()
	oDU300 := Nil
Endif

//------------------
//Criação da tabela temporaria
//------------------
cArqTrab := GetNextAlias()
oDU300 := FWTemporaryTable():New( cArqTrab )  
oDU300:SetFields(aStru) 
oDU300:AddIndex("1", { "EK0_FILIAL","EK0_PROCES" })
oDU300:Create()  

// Cria arquivo temporario
Processa({||SqlToTrb(cQuery, aStru, cArqTrab)})
DbSetOrder(0) // Fica na ordem da query

//Define as colunas a serem apresentadas na markbrowse
For nX := 1 To Len(aStru)
	If	! aStru[nX][1] $ "EK0_TRANSM|EK0_RECEBI|EK0_MESAGE|EK0_OK|RECNOEK0|RECNOEEC"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1])) 
		aColumns[Len(aColumns)]:SetSize(aStru[nX][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
      aColumns[Len(aColumns)]:SetPicture(PesqPict("EK0",aStru[nX][1]))
	EndIf 	
Next nX 

RestArea(aArea)

Return({cArqTrab,aColumns})