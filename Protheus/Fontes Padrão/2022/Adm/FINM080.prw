#INCLUDE 'FINM080.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "Tbiconn.CH"
#INCLUDE "Fileio.ch"

Static __aBrowse    As Array
Static __cDirect    As Character
Static __cArq       As Character
Static __nHdl       As Numeric
Static __nTotReg    As Numeric

//-------------------------------------------------------------------
/*/{Protheus.doc} FINM080
Validador de inconsistências nas tabelas SE5 e FK's

@author silva.wagner
@since 12/07/2019
@version P12
/*/
//-------------------------------------------------------------------
Function FINM080()

Local oPanel    As Object    
Local oNewPag   As Object
Local oStepWiz  As Object
Local lErro     As Logical

__aBrowse	 := {}
__cDirect    := ""
__nHdl       := 0
__cArq       := ""
lErro        := .F.
oPanel       := Nil
  
oStepWiz := FWWizardControl():New( /*oObjPai*/, { 600, 850 } )	// Instancia a classe FWWizardControl
oStepWiz:ActiveUISteps()

//----------------------
// Pagina 1
//----------------------
oNewPag := oStepWiz:AddStep("1") //Altera a descrição do step
oNewPag:SetStepDescription( STR0001 )//Define o bloco de construção
oNewPag:SetConstruction({|oPanel|cria_pg1(oPanel)})//Define o bloco ao clicar no botão Próximo
oNewPag:SetNextAction({||valida_pg1()})//Define o bloco ao clicar no botão Cancelar
oNewPag:SetCancelAction({||.T.})

//----------------------
// Pagina 2
//----------------------
oNewPag := oStepWiz:AddStep("2", {|oPanel|cria_pg2(oPanel,@lErro)})
oNewPag:SetStepDescription(STR0002)
oNewPag:SetNextAction({||!lErro})
oNewPag:SetCancelAction({||.T.})
oNewPag:SetPrevWhen({||.F.})
oNewPag:SetCancelWhen({||lErro})

//----------------------
// Pagina 3
//----------------------
oNewPag := oStepWiz:AddStep("3", {|oPanel|cria_pn3(oPanel)})
oNewPag:SetStepDescription(STR0003)
oNewPag:SetNextAction({||.T.})
oNewPag:SetPrevWhen({||.F.})
oNewPag:SetCancelWhen({||.F.})

//----------------------
// Pagina 4
//----------------------
oNewPag := oStepWiz:AddStep("4", {|oPanel|cria_pn4(oPanel)})
oNewPag:SetStepDescription(STR0004)
oNewPag:SetNextAction({||valida_pg4()})
oNewPag:SetCancelAction({||Alert(STR0005), .T.})
oNewPag:SetCancelWhen({||.F.})

oStepWiz:Activate()

oStepWiz:Destroy()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pg1
Construção do Painel 1

@author silva.wagner
@since 12/07/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function cria_pg1(oPanel As Object)

Local oFont		As Object
Local oFont1	As Object
Local oSay      As Object

Default oPanel  := Nil

oFont 	:= TFont():New( ,, -20, .T., .T.,,,,, )
oFont1 	:= TFont():New( ,, -15, .T., .T.,,,,, )
oSay:= TSay():New(10,10, { || STR0001  }, oPanel,,oFont,,,, .T., CLR_BLUE, )
oSay:= TSay():New(50,10,{||STR0006},oPanel,,oFont1,,,,.T.,,,400,40)
oSay:= TSay():New(70,10,{||STR0007},oPanel,,oFont1,,,,.T.,,,400,40)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} valida_pg1
Validação do painel 1

@author silva.wagner
@since 12/07/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function valida_pg1() As Logical

Local lRet As Logical

lRet := .T.

If !MSGYESNO(STR0008 , STR0009)
    lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pg2
Construção do Painel 2

@author silva.wagner
@since 12/07/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function cria_pg2(oPanel As Object,lErro As Logical) 
    
Local oFont	    As Object
Local oFont1	As Object
Local oSay      As Object
Local lRet      As Logical
Local lExit     As Logical
Local cCopyArq  As Character

Default lErro   := .F.
Default oPanel  := Nil

oFont 	:= TFont():New( ,, -20, .T., .T.,,,,, )
oFont1 	:= TFont():New( ,, -15, .T., .T.,,,,, )
lRet    := .T.
lExit   := .F.
cCopyArq := ''

// Chamada da função que irá analisar os registros.
Processa( {||ValSE5xFKS(@lRet,@lErro,@lExit) }, STR0010 )  

oSay:= TSay():New(10,10, {|| STR0001  }, oPanel,,oFont,,,, .T., CLR_BLUE, ) 

cCopyArq := Substr(__cArq,19,42)

If !lErro
    If lRet
        oSay:= TSay():New(40,10,{||STR0011 + cCopyArq + STR0012},oPanel,,oFont1,,,,.T.,,,400,40)
        oSay:= TSay():New(60,10,{||STR0013},oPanel,,oFont1,,,,.T.,,,400,40)
    ElseIf !lExit
        oSay:= TSay():New(40,10,{||STR0014},oPanel,,oFont1,,,,.T.,,,400,40)
    Endif
Else
    oSay:= TSay():New(40,10,{||STR0015},oPanel,,oFont1,,,,.T.,,,400,40)
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pg3
Construção do Painel 3

@author silva.wagner
@since 12/07/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function cria_pn3(oPanel As Object)

Local nEspLarg  As Numeric
Local nEspLin   As Numeric 
Local oFont	    As Object
Local oFont1    As Object
Local oSay      As Object

Default oPanel  := Nil

nEspLarg := 05
nEspLin  := 30

oFont  := TFont():New( ,, -20, .T., .T.,,,,, )
oFont1 := TFont():New( ,, -15, .T., .T.,,,,, )
oSay := TSay():New(10,10, {||STR0001}, oPanel,,oFont,,,, .T.,CLR_BLUE) 
oSay := TSay():New(65,10, {||STR0052}, oPanel,,oFont1,,,,.T.,CLR_BLACK)  
oSay := TSay():New(110,10,{||STR0053}, oPanel,,oFont1,,,,.T.,CLR_BLACK) 

//Data e Hora 
@ 005+nEspLin,005+nEspLarg say (STR0016) SIZE 60, 10 OF oPanel PIXEL
@ 005+nEspLin,070+nEspLarg say (STR0017) SIZE 40, 10 OF oPanel PIXEL
@ 005+nEspLin,115+nEspLarg say (STR0048) SIZE 60, 10 OF oPanel PIXEL
@ 005+nEspLin,180+nEspLarg say (STR0049) SIZE 40, 10 OF oPanel PIXEL
@ 015+nEspLin,005+nEspLarg MSGET __aBrowse[1][1]  SIZE 60, 10  OF oPanel PIXEL Picture "@!"  WHEN .F.
@ 015+nEspLin,070+nEspLarg MSGET __aBrowse[1][2]  SIZE 40, 10  OF oPanel PIXEL Picture "@!"  WHEN .F.
@ 015+nEspLin,115+nEspLarg MSGET __aBrowse[1][10] SIZE 60, 10  OF oPanel PIXEL Picture "@!"  WHEN .F.
@ 015+nEspLin,180+nEspLarg MSGET __aBrowse[1][11] SIZE 40, 10  OF oPanel PIXEL Picture "@!"  WHEN .F.
// Campos tabela SE5
@ 050+nEspLin,005+nEspLarg say (STR0021) SIZE 80, 10  OF oPanel PIXEL
@ 050+nEspLin,090+nEspLarg say (STR0019) SIZE 80, 10  OF oPanel PIXEL
@ 050+nEspLin,180+nEspLarg say (STR0020) SIZE 80, 10  OF oPanel PIXEL
@ 050+nEspLin,270+nEspLarg say (STR0018) SIZE 120,10  OF oPanel PIXEL
@ 060+nEspLin,005+nEspLarg MSGET __aBrowse[1][3]  SIZE 80, 10  OF oPanel PIXEL Picture "@!"  WHEN .F.
@ 060+nEspLin,090+nEspLarg MSGET __aBrowse[1][4]  SIZE 80, 10  OF oPanel PIXEL Picture "@!"  WHEN .F.
@ 060+nEspLin,180+nEspLarg MSGET __aBrowse[1][5]  SIZE 80, 10  OF oPanel PIXEL Picture "@!"  WHEN .F.
@ 060+nEspLin,270+nEspLarg MSGET __aBrowse[1][6]  SIZE 120,10  OF oPanel PIXEL Picture "@!"  WHEN .F.
// Campos tabela FKS
@ 095+nEspLin,005+nEspLarg say (STR0022) SIZE 80, 10 OF oPanel PIXEL
@ 095+nEspLin,090+nEspLarg say (STR0023) SIZE 80, 10 OF oPanel PIXEL
@ 095+nEspLin,180+nEspLarg say (STR0024) SIZE 80, 10 OF oPanel PIXEL
@ 105+nEspLin,005+nEspLarg MSGET __aBrowse[1][7]  SIZE 80, 10 OF oPanel PIXEL Picture "@!"  WHEN .F.
@ 105+nEspLin,090+nEspLarg MSGET __aBrowse[1][8]  SIZE 80, 10 OF oPanel PIXEL Picture "@!"  WHEN .F.
@ 105+nEspLin,180+nEspLarg MSGET __aBrowse[1][9]  SIZE 80, 10 OF oPanel PIXEL Picture "@!"  WHEN .F.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pg4
Construção do Painel 4

@author silva.wagner
@since 12/07/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function cria_pn4(oPanel As Object)

Local oFont    As Object
Local oFont1   As Object
Local oFont2   As Object
Local oSay     As object

Default oPanel  := Nil

oFont 	:= TFont():New( ,, -20, .T., .T.,,,,, )
oFont1 	:= TFont():New( ,, -15, .T., .T.,,,,, )
oFont2 	:= TFont():New( ,, -15, .T., .T.,,,,, )

oSay:= TSay():New(10,10, {||STR0001},oPanel,,oFont,,,, .T., CLR_BLUE)

If __nTotReg > 0
    oSay:= TSay():New(40,10, {||STR0025},oPanel,,oFont1,,,,.T.,,,400,40) 
else
    oSay:= TSay():New(40,10, {||STR0027},oPanel,,oFont1,,,,.T.,,,400,40) 
Endif    

oSay:= TSay():New(150,10,{||STR0026},oPanel,,oFont2,,,,.T.,,,300,20)

@ 170,10 SAY oSay PROMPT "<u>" + STR0028 + "</u>" SIZE 400,040 COLORS CLR_BLUE,CLR_WHITE FONT oFont2 OF oPanel HTML PIXEL

oSay:bLClicked := {|| ShellExecute("open",STR0028,"","",1) }

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} valida_pg4
Validação do Painel 4

@author silva.wagner
@since 12/07/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function valida_pg4() As Logical 

Local cCamArq   As Character  //variavel do caminho do arquivo
Local cType     As Character
Local cCopyArq  As Character
Local lCopy     As Logical
Local lExist    As Logical
Local lRet      As Logical

cCamArq     := ""       
cType       := 'Teste' + "(*.Log) |*.Log|"
cCopyArq    := "" 
lCopy       := .F.
lExist      := .F.
lRet        := .F.   

If __nHdl > 0
    lRet := MSGYESNO(STR0029 , STR0009 )
    FClose(__nHdl)

    If lRet
        cCamArq := cGetFile(cType ,STR0030,0,,.F.,GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)

        If !Empty(cCamArq)
            lExist := EXISTDIR(cCamArq) 

            If !lExist
                If MakeDir(cCamArq) <> 0
                    Help(" ",1,"NOMAKEDIR")
                    oStepWiz:Destroy()
                    Return
                EndIF
            Endif

            cCopyArq := Substr(__cArq,19,42)

            lCopy := _CopyFile(__cArq, cCamArq+cCopyArq)

            If lCopy
                MSGINFO(STR0031 + cCamArq+cCopyArq , STR0009 )
            Else
                MSGINFO(STR0032 + __cArq , STR0009 )
            EndIf
        Endif
    Endif
Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ValSE5xFKS
Validação de inconsistencia entre as tabelas SE5 e FK

@author Jose.Gavetti
@since 12/07/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ValSE5xFKS(lRet,lErro,lExit)

Local cfiltro       As Character
Local cAlias 		As Character
Local cQuery 		As Character
Local cTime		    As Character
Local cTimeFim		As Character
Local cMensagem     As Character
Local cDir          As Character
Local cLinha        As Character  
Local cData         As Character  
Local cDtFonte      As Character
Local cDia          As Character
Local cMes          As Character
Local cAno          As Character
Local cDtFim        As Character
Local cRecno        As Character
Local nQtdIdOri     As Numeric
Local nQtdTabOri    As Numeric
Local nQtdMovfk     As Numeric
Local nQtdIdTab     As Numeric
Local nQtdIdMov     As Numeric
Local nQtdTabMov    As Numeric
Local nQtdTot       As Numeric
Local nI            As Numeric
Local nQtdFk1       As Numeric
Local nQtdFk6       As Numeric
Local nQtdFkA       As Numeric
Local lExist        As Logical
Local lFirst        As Logical
Local aData         As Array

Default lRet  := .T.
Default lErro := .F.
Default lExit := .F.

cfiltro       := ""
cAlias 		  := ""
cQuery 		  := ""
cTime		  := Time()
cTimeFim      := ""
cMensagem     := ""
cDir          := "valse5xfk"
cLinha        := ""   
cData         := ""
cDtFonte      := ""
cDia          := ""
cMes          := ""
cAno          := ""
cDtFim        := ""
cRecno        := ""
nQtdIdOri     := 0
nQtdTabOri    := 0
nQtdMovfk     := 0
nQtdIdTab     := 0
nQtdIdMov     := 0
nQtdTabMov    := 0
nQtdTot       := 0
nI            := 0
nQtdFk1       := 0
nQtdFk6       := 0
nQtdFkA       := 0
lExist        := .F. 
lFirst        := .T. 
aData         := {}  

aData := GetAPOInfo("FINM080.PRW") //Data do RPO
cDtFonte:=  DTOC(aData[4])

cMensagem  +=  GetSrvProfString("StartPath", "\undefined")
__cDirect  :=  cMensagem + cDir

lExist := EXISTDIR(__cDirect) //Verifica se os Diretorios cadastrados existem

If !lExist
    If MakeDir(cDir) <> 0
        Help(" ",1,"NOMAKEDIR")
        lErro := .T.
        lRet  := .F.
        Return
    EndIF
Endif

__cArq := Upper(Alltrim(__cDirect)) + STR0033 + dTos(dDataBase) + "_" + StrTran(Time(),":","") + STR0034

__nHdl := FCreate(__cArq)

If __nHdl == -1
    MsgAlert(STR0011 + __cArq + STR0035, STR0009)
    lErro := .T.
    lRet  := .F.
    Return
Endif

cData:=  DTOC(dDataBase)

cLinha := STR0050 + STR0051 + cDtFonte + Chr(13) + Chr(10)
VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

cLinha := Chr(13) + Chr(10)
VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

cLinha :=  STR0016  + " " + cData + " " + STR0017 +" "+ cTime + Chr(13) + Chr(10)
VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

cLinha := Chr(13) + Chr(10)
VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

If lErro
    Return
Endif

For nI := 1 to 7

    Do Case
        Case nI == 1
                cFiltro = " E5_IDORIG = ' ' AND E5_TABORI = ' ' AND E5_MOVFKS !=  'S' AND "
        Case nI == 2
                cFiltro = " E5_IDORIG = ' ' AND E5_TABORI != ' ' AND E5_MOVFKS =  'S' AND "
        Case nI == 3
                cFiltro = " E5_IDORIG != ' ' AND E5_TABORI = ' ' AND E5_MOVFKS =  'S' AND "
        Case nI == 4
                cFiltro = " E5_IDORIG != ' ' AND E5_TABORI != ' ' AND E5_MOVFKS !=  'S' AND "
    EndCase

    cAlias 		:= GetNextAlias()

    If (nI == 1) .Or. (nI == 2) .Or. (nI == 3) .Or. (nI == 4)
        cQuery := "SELECT R_E_C_N_O_  RECNO  " 
        cQuery += " FROM " + RetSqlName( "SE5" )+ " SE5 "
        cQuery += " WHERE " + cFiltro + " "
        cQuery += " E5_SITUACA NOT IN ('C')  AND "
        cQuery += " D_E_L_E_T_ = ' '" 
        cQuery += 	"GROUP BY R_E_C_N_O_"
    ElseiF nI == 5 // FK1 sem chave de relacinamento com a FK7
        cQuery += "SELECT R_E_C_N_O_  RECNO ,FK1_IDDOC "
        cQuery += " FROM " + RetSqlName( "FK1" )+ " FK1 "
        cQuery += " WHERE FK1_IDDOC NOT IN( "
        cQuery += " SELECT FK7.FK7_IDDOC FROM " + RetSqlName("FK7") + " FK7 )" 
        cQuery += " AND FK1_TPDOC = 'ES'  "
        cQuery += " AND FK1.D_E_L_E_T_ = ' ' "
    ElseiF nI == 6 // FK6 sem chave de relacinamento com a FK1
        cQuery += "SELECT R_E_C_N_O_  RECNO ,FK6_IDORIG "
        cQuery += " FROM " + RetSqlName( "FK6" )+ " FK6 "
        cQuery += " WHERE FK6_IDORIG NOT IN( "
        cQuery += " SELECT FK1.FK1_IDFK1 FROM " + RetSqlName("FK1") + " FK1 )" 
        cQuery += " AND FK6.D_E_L_E_T_ = ' ' "
    ElseiF nI == 7 // FK5 sem chave de relacinamento com a FKA
        cQuery += "SELECT R_E_C_N_O_  RECNO ,FK5_IDMOV "
        cQuery += " FROM " + RetSqlName( "FK5" )+ " FK5 "
        cQuery += " WHERE FK5_IDMOV NOT IN( "
        cQuery += " SELECT FKA.FKA_IDORIG FROM " + RetSqlName("FKA") + " FKA )" 
        cQuery += " AND FK5.D_E_L_E_T_ = ' ' "
    Endif

    cQuery := ChangeQuery(cQuery)

    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)

    (cAlias)->(dbGoTop())

    Do Case
    Case nI == 1

        While !(cAlias)->(Eof())

            If lFirst
                cLinha := STR0036 + Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)
                lFirst := .F.
            EndIf

            cLinha := STR0038 + cValToChar((cAlias)->RECNO) + Chr(13) + Chr(10)
            VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

            If lErro
                Return
            Endif

            dbSelectArea(cAlias)
            nQtdTot++
            (cAlias)->(Dbskip())

        EndDo
            (cAlias)->(dbCloseArea())
            cQuery := ""

    Case nI == 2

        lFirst := .T.
        While !(cAlias)->(Eof())

            If lFirst

                cLinha := Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

                cLinha := STR0039 + Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)
                lFirst := .F.
            EndIf

            cLinha := STR0038 + cValToChar((cAlias)->RECNO) + Chr(13) + Chr(10)
            VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

            If lErro
                Return
            Endif

            dbSelectArea(cAlias)
            nQtdIdOri++
            (cAlias)->(Dbskip())

        EndDo
        (cAlias)->(dbCloseArea())
        cQuery := ""

    Case nI == 3

        lFirst := .T.
        While !(cAlias)->(Eof())

            If lFirst

                cLinha := Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

                cLinha := STR0040 + Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)
                lFirst := .F.
            EndIf

            cLinha := STR0038 + cValToChar((cAlias)->RECNO) + Chr(13) + Chr(10)
            VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

            If lErro
                Return
            Endif

            dbSelectArea(cAlias)
            nQtdTabOri++
            (cAlias)->(Dbskip())

        EndDo
        (cAlias)->(dbCloseArea())
        cQuery := ""

    Case nI == 4

        lFirst := .T.
        While !(cAlias)->(Eof())

            If lFirst

                cLinha := Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

                cLinha := STR0041 + Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)
                lFirst := .F.
            EndIf

            cLinha := STR0038 + cValToChar((cAlias)->RECNO) +  Chr(13) + Chr(10)
            VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

            If lErro
                Return
            Endif

            dbSelectArea(cAlias)
            nQtdMovfk++
            (cAlias)->(Dbskip())

        EndDo
        (cAlias)->(dbCloseArea())
        cQuery := ""

    Case nI == 5
    
        lFirst := .T.
        While !(cAlias)->(Eof())

            If lFirst

                cLinha := Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

                cLinha := STR0042 + Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)
                lFirst := .F.
            EndIf

            cRecno := PadR((cAlias)->RECNO,10)

            cLinha := STR0038 + cRecno + '| ' + STR0043 + ((cAlias)->FK1_IDDOC) + Chr(13) + Chr(10)
            VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

            If lErro
                Return
            Endif

            dbSelectArea(cAlias)
            nQtdFK1++
            (cAlias)->(Dbskip())

        EndDo
        (cAlias)->(dbCloseArea())
        cQuery := ""

    Case nI == 6

        lFirst := .T.
        While !(cAlias)->(Eof())

            If lFirst

                cLinha := Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

                cLinha := STR0044 + Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)
                lFirst := .F.
            EndIf

            cRecno := PadR((cAlias)->RECNO,10)

            cLinha := STR0038 + cRecno + '| ' + STR0045 + ((cAlias)->FK6_IDORIG) + Chr(13) + Chr(10)
            VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

            If lErro
                Return
            Endif

            dbSelectArea(cAlias)
            nQtdFK6++
            (cAlias)->(Dbskip())

        EndDo
        (cAlias)->(dbCloseArea())
        cQuery := ""

    Case nI == 7
    
        lFirst := .T.
        While !(cAlias)->(Eof())

            If lFirst

                cLinha := Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

                cLinha := STR0046 + Chr(13) + Chr(10)
                VldGrvArq(__nHdl,cLinha,__cArq,@lErro)
                lFirst := .F.
            EndIf

            cRecno := PadR((cAlias)->RECNO,10)

            cLinha := STR0038 + cRecno + '| ' + STR0047 + ((cAlias)->FK5_IDMOV) + Chr(13) + Chr(10)
            VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

            If lErro
                Return
            Endif

            dbSelectArea(cAlias)
            nQtdFKA++
            (cAlias)->(Dbskip())

        EndDo
        (cAlias)->(dbCloseArea())
        cQuery := ""

    EndCase

Next nI

cTimeFim:= Time()
cDtFim:=  DTOC(dDataBase)

cLinha := Chr(13) + Chr(10)
VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

cLinha := STR0048  + cDtFim + " " + STR0049 +" "+ cTimeFim + Chr(13) + Chr(10)
VldGrvArq(__nHdl,cLinha,__cArq,@lErro)

If lErro
    Return
Endif

FClose(__nHdl)

__nTotReg := (nQtdTot + nQtdIdOri + nQtdTabOri + nQtdMovfk + nQtdFK1 + nQtdFK6 + nQtdFKA)

// Vetor com elementos do Browse
__aBrowse := {{cData,cTime,nQtdTot,nQtdIdOri,nQtdTabOri,nQtdMovfk,nQtdFK1,nQtdFK6,nQtdFKA,cDtFim,cTimeFim}}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldGrvArq
Valida a gravação da linha no arquivo.

@author Jose.Gavetti
@since  14/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function VldGrvArq(__nHdl As Numeric , cLinha As Character, __cArq As Character, lErro As Logical )

Default __nHdl := 0 
Default __cArq := ""
Default cLinha := ""
Default lErro := .F.

If FWrite(__nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
    If !MsgAlert(STR0037, STR0009)
        lErro := .T.
        FClose(__nHdl)
        Ferase(__cArq)
        Return
    EndIf
Endif    

Return