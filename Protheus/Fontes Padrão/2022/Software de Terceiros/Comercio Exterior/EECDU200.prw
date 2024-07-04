#INCLUDE 'TOTVS.CH'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#Include 'AVERAGE.ch'

/*/{Protheus.doc} EECDU200
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
Function EECDU200()
 
Local aArea       := GetArea()
Local aAreaEEC    := EEC->(GetArea())
Local aRotOld     := aClone(aRotina)
Local bMark       := {|| xBMark() }
Local bInit   	  := {|| xMarkinit() }

Private oMarkBrow,oDlgMrk,oDU200
Private cTitulo   := "Gerar DUE em lote"

aRotina   := MenuDef()

   aAlias 		:= DU200QRY()
   cAliasMrk	:= aAlias[1]
   aColumns 	:= aAlias[2]

If !(cAliasMrk)->(Eof())

	oMarkBrow:= FWMarkBrowse():New()
    oMarkBrow:SetOwner(oDlgMrk)
	oMarkBrow:SetDescription( cTitulo )
	oMarkBrow:SetAlias( cAliasMrk )
	oMarkBrow:SetFieldMark( "EEC_OK" )
	oMarkBrow:SetMark( "W1" , cAliasMrk , "EEC_OK" )
    
    oMarkBrow:SetColumns(aColumns)
    oMarkBrow:SetWalkThru(.F.)
	oMarkBrow:SetAmbiente(.F.) 
	oMarkBrow:DisableReport(.T.)
    oMarkBrow:SetAllMark(bMark)
    oMarkBrow:SetIniWindow( bInit )
	oMarkBrow:Activate()
Else
   Help(" ",1,"RECNO")
EndIf

If oDU200 <> Nil
	oDU200:Delete()
	oDU200 := Nil
Endif

restarea(aAreaEEC)
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
Local cAliasEEC := oMarkBrow:Alias()
Local cLast := ""
Local lSai := .F.
Local nQtd := 0
Local lMarca := ! oMarkBrow:IsMark()

oMarkBrow:GoBottom()
cLast := (cAliasEEC)->EEC_FILORI + (cAliasEEC)->EEC_PREEMB
oMarkBrow:GoTop()

While ! lSai
    if lMarca .and. ! oMarkBrow:IsMark()
        oMarkBrow:MarkRec()
    elseif  ! lMarca .and. oMarkBrow:IsMark()
        oMarkBrow:MarkRec()
    EndIf

    if cLast == (cAliasEEC)->EEC_FILORI + (cAliasEEC)->EEC_PREEMB
        lSai := .T.
    End
    oMarkBrow:GoDown(1)
    //lMarca := oMarkBrow:IsMark()
EndDo

oMarkBrow:Refresh(.T.)

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
Local cAliasEEC := oMarkBrow:Alias()
Local cLast := ""
Local lSai := .F.
Local nQtd := 0

oMarkBrow:GoBottom()
cLast := (cAliasEEC)->EEC_FILORI + (cAliasEEC)->EEC_PREEMB
oMarkBrow:GoTop()

While ! lSai
    if ! oMarkBrow:IsMark()
        oMarkBrow:MarkRec()
    EndIf
    if cLast == (cAliasEEC)->EEC_FILORI + (cAliasEEC)->EEC_PREEMB
        lSai := .T.
    End
    oMarkBrow:GoDown(1)
EndDo

oMarkBrow:Refresh(.T.)

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

    ADD OPTION aRot TITLE 'Gerar DUE' ACTION 'GerDUE()' OPERATION MODEL_OPERATION_INSERT ACCESS 0

Return aRot

/*---------------------------------------------------------------------*
 | Func:  GerDUE                                                       |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Chama função que percorre o mark browse para gerar as DUEs   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function GerDUE()
Local nK := CountReg()

If nK > 0 
    If MsgYesNo( "Deseja continuar a gerar DUE para os processos selecionados?" , cTitulo )
        Processa( {|| xGerDUE(nK) }, cTitulo )
        oMarkBrow:Refresh(.T.)
    EndIf
EndIf

Return .F.
/*---------------------------------------------------------------------*
 | Func:  xGerDUE                                                      |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Rotina que percorre o mark browse gerando as DUEs            |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function xGerDUE(nT)
Local aAreaEEC := EEC->(GetArea())
Local aAreaEK0 := EK0->(GetArea())
Local nQ            := 1
Local nW            := 1
Local aBuffer       := {}
Local aProces       := {}
Local aSend         := {}
Local cAliasEEC     := oMarkBrow:Alias()
Local cMsgStop      := ""

Private cMsgCpoDUE  := ""

    (cAliasEEC)->( dbgotop() )
    (cAliasEEC)->( dbeval( {|| iif( !empty((cAliasEEC)->EEC_OK) , aadd( aProces , { (cAliasEEC)->(recno()) } ) , ) } ) )
    (cAliasEEC)->( dbgotop() )

    ProcRegua( nT )
    for nQ := 1 to len(aProces)

        (cAliasEEC)->( DbGoto( aProces[nQ][1] ) )
        EEC->( DbGoto( (cAliasEEC)->RECNO ) )
        incproc( "Gerando DUE: " + alltrim(EEC->EEC_PREEMB) )

        //Atualizar o status para verificar inconsistências impeditivas de geração do arquivo
        DU400GrvStatus()

        If !Empty(cMsgCpoDUE)

            cMsgStop   += replicate("-",60) + CRLF + cMsgCpoDUE
            cMsgCpoDUE := ""
                        
        Else

            If EEC->EEC_STTDUE $ '2|3|4'

                EECDU100GRV( 1, EEC->EEC_FILIAL, EEC->EEC_PREEMB, "" , Alltrim(__cUserID) , dDataBase, "" )
                aadd( aSend , { (cAliasEEC)->RECNO , EK0->( recno() ) } )

                //Atualizar o status para verificar inconsistências impeditivas de geração do arquivo
                DU400GrvStatus()

            EndIf

        EndIf

        iF  (cAliasEEC)->(MsRLock())
            (cAliasEEC)->(DBDelete())
            (cAliasEEC)->(MsUnlock())
        EndIf

    Next

    oMarkBrow:Refresh()

    //Exibe mensagem em caso de validação de status encontrados em processos que não são processados
    If ! Empty(cMsgStop)
        AVGetSvLog(cTitulo,cMsgStop,{7,15})
    EndIf

    If len(aSend) > 0
        If MsgYesNo( "Deseja realizar uma transmissão de DUE em lote?" , cTitulo )
            ProcRegua( Len(aSend) )
            for nW := 1 to len(aSend)
                
                EEC->( DbGoto( aSend[nW][1] ) )
                EK0->( DbGoto( aSend[nW][2] ) )

                IncProc( "Lendo XML: " + alltrim(EEC->EEC_PREEMB) )

                cBuffer := EasyExecAHU("DUE3")
                cBuffer := EncodeUTF8(cBuffer)
                cBuffer := StrTran(cBuffer,"&","e")
                aadd( aBuffer , {cBuffer , EK0->EK0_FILIAL + EK0->EK0_PROCES , aSend[nW][1] , aSend[nW][2] } )
                
            Next
        EndIf
        
        if len(aBuffer) > 0

            IncProc( "Transmitindo lote DUE")
            GerXMLDue(aBuffer)
            ProcRegua( Len(aBuffer) )
            for nW := 1 to len(aBuffer)
            
                EEC->( DbGoto( aBuffer[nW][3] ) )
                EK0->( DbGoto( aBuffer[nW][4] ) )

                IncProc( "Atualizando: " + alltrim(EEC->EEC_PREEMB) )

                //Atualizar o status para verificar inconsistências impeditivas de geração do arquivo
                DU400GrvStatus()

            Next
        EndIf
    EndIf

restarea(aAreaEEC)
restarea(aAreaEK0)

Return .T.
/*---------------------------------------------------------------------*
 | Func:  CountReg                                                     |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Conta os registros selecionados no mark browse               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function CountReg()
Local cAliasEEC := oMarkBrow:Alias()
Local nQtd := 0

(cAliasEEC)->( dbgotop() )
(cAliasEEC)->( dbeval( {|| iif( !empty((cAliasEEC)->EEC_OK) , nQtd++ , ) } ) )
(cAliasEEC)->( dbgotop() )

Return nQtd
/*---------------------------------------------------------------------*
 | Func:  DU200QRY                                                     |
 | Autor: Miguel Gontijo                                               |
 | Data:  22/05/2018                                                   |
 | Desc:  Seleciona os processos com status 2 - aguardando geração e   |
 | monta tabela temporária a ser usada no mark browse                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function DU200QRY()
Local aArea			:= GetArea()			
Local aStru			:= EEC->(DBSTRUCT())	//Estrutura da Tabela
Local aColumns		:= {}					   //Array com as colunas a serem apresentadas

Local nX			:= 0					
Local cArqTrab		:= "WK_EEC"
Local cQuery		:= ""

cQuery += "SELECT '  ' EEC_OK, EEC_FILIAL EEC_FILORI, EEC.*, "
cQuery += " R_E_C_N_O_ RECNO "
cQuery += " FROM "+	RetSqlName("EEC") + " EEC " 
cQuery += " WHERE (EEC_STTDUE = '2' OR EEC_STTDUE = '4') "
cQuery += " AND EEC_FILIAL = '"+xFilial("EEC")+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY "+ SqlOrder(EEC->(IndexKey()))

Aadd(aStru, {"EEC_FILORI","C", avsx3("EEC_FILIAL",AV_TAMANHO) ,0})
Aadd(aStru, {"EEC_OK","C",2,0})
Aadd(aStru, {"RECNO","N",10,0})

If oDU200 <> Nil
	oDU200:Delete()
	oDU200 := Nil
Endif

//------------------
//Criação da tabela temporaria
//------------------
EasyWkQuery(cQuery,cArqTrab,{ "EEC_FILORI+EEC_PREEMB" },aStru)

DbSetOrder(0) // Fica na ordem da query

//Define as colunas a serem apresentadas na markbrowse
For nX := 1 To Len(aStru)
	If	! aStru[nX][1] $ "EEC_FILORI|EEC_OK|RECNO|EEC_GENERI|EEC_OBS|EEC_MARCAC|EEC_MRCOIC|EEC_VMINGE|EEC_OBSFOR|EEC_OBSSIT|EEC_OBSTRA|EEC_OBSDIS|EEC_JUSRET|EEC_OBSPED|EEC_VMDCOF"
		AAdd(aColumns,FWBrwColumn():New())
        if aStru[nX][1] == "EEC_FILIAL"
    		aColumns[Len(aColumns)]:SetData( &("{|| EEC_FILORI }") )
        else
    		aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
        endif
        aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1]))
		aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
		aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
        aColumns[Len(aColumns)]:SetPicture(PesqPict("EEC",aStru[nX][1]))
	EndIf 	
Next nX

RestArea(aArea)

Return({cArqTrab,aColumns})