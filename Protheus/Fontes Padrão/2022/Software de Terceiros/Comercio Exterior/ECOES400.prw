#INCLUDE "ECOES400.ch"
#Include "AVERAGE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ECOES400.PRW º Autor ³ EMERSON         º Data ³  05/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Programa de Visualização de Processos Estornados.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAECO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*-----------------------*
Function ECOES401()
*-----------------------*
ECOES400("Imp")
Return .T.

*-----------------------*
Function ECOES402()
*-----------------------*
ECOES400("Exp")
Return .T.

*------------------------*
Function ECOES400(cParam)
*------------------------*
Local cFiltro
Private cTipo:= cParam, cAlias:= "ECE", aFixos:= {}
Private cCadastro := STR0004 //"Processos Estornados"
Private lInverte:= .F.,cMarca:= GetMark(),aTELA[0][0],aGETS[0]
private cTPMODU := ""
private lTemTPMODU
private bTPMODUECE
Private aRotina := MenuDef(ProcName(1))

SX3->(DBSetOrder(2))
lTemTPMODU := SX3->(DbSeek("ECE_TPMODU"))
SX3->(DBSetOrder(1))

If lTemTPMODU
   If cTipo == "Imp"  // Nick 18/10/06
     cTPMODU := 'IMPORT'
     bTPMODUECE := {|| .T.}
   Else
     cTPMODU:='EXPORT'
     bTPMODUECE := {|| ECE->ECE_TPMODU = 'EXPORT' }      
   Endif
Else
   bTPMODUECE := {|| .T. }      
EndIf

If cTipo=="Imp"
   aFixos:={{AVSX3("ECE_HAWB" ,5)    ,"ECE_HAWB"    },;
            { AVSX3("ECE_FORN" ,5)   ,"ECE_FORN"    },;
            { AVSX3("ECE_INVOIC" ,5) ,"ECE_INVOIC"  },;
            { AVSX3("ECE_DI_NUM" ,5) ,"ECE_DI_NUM"  },;
            { AVSX3("ECE_DT_LAN" ,5) ,"ECE_DT_LAN"  },;
            { AVSX3("ECE_CTA_DB" ,5) ,"ECE_CTA_DB"  },;
            { AVSX3("ECE_CTA_CR" ,5) ,"ECE_CTA_CR"  },;
            { AVSX3("ECE_VALOR" ,5)  ,"ECE_VALOR"  },;
            { AVSX3("ECE_OBS" ,5)    ,"ECE_OBS"  },;
            { AVSX3("ECE_IDENTC" ,5) ,"ECE_IDENTC"  },;
            { AVSX3("ECE_HOUSE" ,5)  ,"ECE_HOUSE"  },;
            { AVSX3("ECE_ID_CAM" ,5) ,"ECE_ID_CAM"  },;
            { AVSX3("ECE_LINK" ,5)   ,"ECE_LINK"  },;
            { AVSX3("ECE_NR_CON" ,5) ,"ECE_NR_CON" },;
            { AVSX3("ECE_CDBEST" ,5) ,"ECE_CDBEST" },;
            { AVSX3("ECE_CCREST" ,5) ,"ECE_CCREST" },;
            { AVSX3("ECE_DT_EST" ,5) ,"ECE_DT_EST" },;
            { AVSX3("ECE_MOE_FO" ,5) ,"ECE_MOE_FO" },;
            { AVSX3("ECE_COD_HI" ,5) ,"ECE_COD_HI" },;
            { AVSX3("ECE_COM_HI" ,5) ,"ECE_COM_HI" },;
            { AVSX3("ECE_SEQ" ,5)    ,"ECE_SEQ" },;
            { AVSX3("ECE_VL_MOE" ,5) ,"ECE_VL_MOE" },;
            { AVSX3("ECE_TX_ATU" ,5) ,"ECE_TX_ATU" },;
            { AVSX3("ECE_TX_ANT" ,5) ,"ECE_TX_ANT" },;
            { AVSX3("ECE_CONTRA" ,5) ,"ECE_CONTRA" }}
Else
   aFixos:={{AVSX3("ECE_PREEMB" ,5)  ,"ECE_PREEMB"  },;
            { AVSX3("ECE_INVEXP" ,5) ,"ECE_INVEXP"  },;
            { AVSX3("ECE_DT_LAN" ,5) ,"ECE_DT_LAN"  },;
            { AVSX3("ECE_CTA_DB" ,5) ,"ECE_CTA_DB"  },;
            { AVSX3("ECE_CTA_CR" ,5) ,"ECE_CTA_CR"  },;
            { AVSX3("ECE_VALOR" ,5)  ,"ECE_VALOR"  },;
            { AVSX3("ECE_OBS" ,5)    ,"ECE_OBS"  },;
            { AVSX3("ECE_IDENTC" ,5) ,"ECE_IDENTC"  },;
            { AVSX3("ECE_HOUSE" ,5)  ,"ECE_HOUSE"  },;
            { AVSX3("ECE_ID_CAM" ,5) ,"ECE_ID_CAM"  },;
            { AVSX3("ECE_LINK" ,5)   ,"ECE_LINK"  },;
            { AVSX3("ECE_NR_CON" ,5) ,"ECE_NR_CON" },;
            { AVSX3("ECE_CDBEST" ,5) ,"ECE_CDBEST" },;
            { AVSX3("ECE_CCREST" ,5) ,"ECE_CCREST" },;
            { AVSX3("ECE_DT_EST" ,5) ,"ECE_DT_EST" },;
            { AVSX3("ECE_MOE_FO" ,5) ,"ECE_MOE_FO" },;
            { AVSX3("ECE_COD_HI" ,5) ,"ECE_COD_HI" },;
            { AVSX3("ECE_COM_HI" ,5) ,"ECE_COM_HI" },;
            { AVSX3("ECE_SEQ" ,5)    ,"ECE_SEQ" },;
            { AVSX3("ECE_VL_MOE" ,5) ,"ECE_VL_MOE" },;
            { AVSX3("ECE_TX_ATU" ,5) ,"ECE_TX_ATU" },;
            { AVSX3("ECE_TX_ANT" ,5) ,"ECE_TX_ANT" },;
            { AVSX3("ECE_CONTRA" ,5) ,"ECE_CONTRA" }}
Endif

ECE->(DbSetOrder(1))

//ECE->(DbSetFilter({|| If(cTipo == "Imp", !Empty(ECE->ECE_HAWB), !Empty(ECE->ECE_PREEMB)) },;
//"If(cTipo == 'Imp', !Empty(ECE->ECE_HAWB), !Empty(ECE->ECE_PREEMB))"))

cFiltro := If(cTipo == 'Imp', "ECE_HAWB <> '" + Space(AvSx3("ECE_HAWB", AV_TAMANHO)) + "'", "ECE_PREEMB <> '" + Space(AvSx3("ECE_PREEMB", AV_TAMANHO)) + "'")

mBrowse( 06, 01, 22, 75, "ECE",,,,,,,,,,,,,,cFiltro)

//Set Filter To

ECE->(DbSetOrder(1))

RETURN .T.

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 01/02/07 - 15:39
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina  := { {STR0001    ,"AxPesqui"    ,0,1},;   //"Pesquisar"
                    {STR0002    ,"ECOES400GER" ,0,2}}    //"Visualizar"
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))
                
// P.E. utilizado para adicionar itens no Menu da mBrowse                    
If cOrigem $ "ECOES401"
   If EasyEntryPoint("CES401MNU")
	  aRotAdic := ExecBlock("CES401MNU",.f.,.f.)
   EndIf                            
ElseIf cOrigem $ "ECOES402"
   If EasyEntryPoint("CES402MNU")
	  aRotAdic := ExecBlock("CES402MNU",.f.,.f.)
   EndIf                              
EndIf

If ValType(aRotAdic) == "A"
   AEval(aRotAdic,{|x| AAdd(aRotina,x)})
EndIf
   
Return aRotina

*-----------------------------------------*
FUNCTION ECOES400GER(cAlias,nReg,nOpc)
*-----------------------------------------*
Local bVal_Ok, nInc

bVal_OK:={||oDlg:End()}
bCancel := {||nOp:=0,oDlg:End()}

If cTipo == "Imp"
   aMostraECE:= {"ECE_HAWB","ECE_FORN","ECE_INVOIC","ECE_DI_NUM","ECE_DT_LAN","ECE_CTA_DB",;
                 "ECE_CTA_CR","ECE_VALOR","ECE_OBS","ECE_IDENTC","ECE_HOUSE","ECE_ID_CAM","ECE_LINK",;
                 "ECE_NR_CON,ECE_CDBEST","ECE_CCREST","ECE_DT_EST","ECE_MOE_FO","ECE_COD_HI",;
                 "ECE_COM_HI","ECE_SEQ","ECE_VL_MOE","ECE_TX_ATU","ECE_TX_ANT","ECE_CONTRA","ECE_TP_EVE"}
Else
   aMostraECE:= {"ECE_PREEMB","ECE_INVEXP","ECE_DT_LAN","ECE_CTA_DB","ECE_CTA_CR","ECE_VALOR",;
                 "ECE_OBS","ECE_IDENTC","ECE_HOUSE","ECE_ID_CAM","ECE_LINK","ECE_NR_CON,ECE_CDBEST",;
                 "ECE_CCREST","ECE_DT_EST","ECE_MOE_FO","ECE_COD_HI","ECE_COM_HI","ECE_SEQ",;
                 "ECE_VL_MOE","ECE_TX_ATU","ECE_TX_ANT","ECE_CONTRA","ECE_TP_EVE"}
Endif

dbSelectArea(cAlias)
For nInc := 1 TO (cAlias)->(FCount())
   M->&(FIELDNAME(nInc)) := FieldGet(nInc)
Next nInc

oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlg TITLE cCadastro ;
    FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
    OF oMainWnd PIXEL

    EnChoice(cAlias, nReg, nOpc, , , ,aMostraECE, {15,1,((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) , (oDlg:nClientWidth-2)/2}, , 3 )

    ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||Eval(bVal_OK)},{||Eval(bCancel)},,)

Return .T.
