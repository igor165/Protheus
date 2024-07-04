#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM047.CH"

Static lIntTaf 		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 2 )
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

Function GPEM047()

    Local aButtons  := {}
    Local aSays     := {}
    Local cMsg      := ""
    Local lContinua := .F.
    Local nOpcA     := 0

    Private aCodFol     := {}
    Private aLog        := {}
    Private aTitle      := {}
    Private cPerg       := "GPM047"
    Private lPpeAtiv    := .F.
    Private cVersEnvio	:= ""
    Private cVersGPE	:= ""

    //Se não existir o grupo de perguntas, aborta o processamento
    If !fVldSX1()
        cMsg := OemToAnsi( STR0001 ) + CRLF//"Para executar essa rotina é obrigatório possuir atualização para"
        cMsg += OemToAnsi( STR0002 ) + CRLF//"criação do grupo de perguntas GPM047." 
        cMsg += OemToAnsi( STR0003 + "http://tdn.totvs.com/x/wa9DHQ" )//"Verifique a documentação em: "
        MsgInfo( cMsg )
        Return()
    EndIf

    If FindFunction("fVersEsoc")
        fVersEsoc( "S2306", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE )
    EndIf

    If FindFunction("ESocMsgVer") .And. lIntTaf .And. !lMiddleware .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
        //# "Atenção! # A versão do leiaute GPE é XXX e a do TAF é XXXX, sendo assim, estão divergentes. A rotina será encerrada"
        ESocMsgVer(.T., /*cEvento*/, cVersGPE, cVersEnvio)
        Return()
    EndIf

    RCA->( dbSetOrder(1) )
    If RCA->( dbSeek( xFilial("RCA") + "P_LPPEATIV" ) )
        lPpeAtiv := (AllTrim(RCA->RCA_CONTEU) == ".T.")
    EndIf

    If lPpeAtiv .And. (RGE->(ColumnPos("RGE_COD")) == 0 .Or. RGE->(ColumnPos("RGE_SALRED")) == 0 .Or. RGE->(ColumnPos("RGE_PERC")) == 0)
        fAlertRGE()
        Return()
    EndIf

    aAdd(aSays,OemToAnsi( STR0004 ))//"Este programa tem como objetivo efetuar o envio dos eventos S-2206/S-2306"
    aAdd(aSays,OemToAnsi( STR0005 ))//"em lote, conforme filtro desejado."

    aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
    aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
    aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

    //Abre a tela de processamento
    FormBatch( STR0006, aSays, aButtons )//"Geração S-2206/S-2306 em lote"

    //Efetua o processamento de geração
    If nOpcA == 1
        If !lMiddleware
            Aadd( aTitle, OemToAnsi( STR0007 ) )//"Funcionários enviados ao TAF:"
        Else
            Aadd( aTitle, OemToAnsi( STR0015 ) )//"Funcionários enviados ao Middleware:"
        EndIf
        Aadd( aLog, {} )
        ProcGpe( {|lEnd| fProcessa()},,,.T. )
        fMakeLog(aLog,aTitle,,,"GPEM047",OemToAnsi(STR0008),"M","P",,.F.)//"Log de Ocorrências"
    EndIf

Return

/*/{Protheus.doc} fProcessa
Função que efetua o envio do evento S-2206/S-2306
/*/
Static Function fProcessa()

    Local cAliasQry := GetNextAlias()
    Local cCateg	:= fCatTrabEFD("TCV") + "|" + fCatTrabEFD("TSV") //'101*102*103*104*105*106*111*301*302*303*306*307*309'+'201*202*305*308*401*410*701*711*712*721*722*723*731*734*738*741*751*761*771*781*901*902*903'
    Local cCategCV	:= fCatTrabEFD("TCV")
    Local cCPF      := ""
    Local cFilOld   := cFilAnt
    Local cMsgErro  := ""
    Local cStatus	:= ""
    Local cVers2206 := ""
    Local cVers2306 := ""
    Local cVersGPE	:= ""
    Local cWhere    := ""
    Local lMp936    := .F.

    Local aInfoC	:= {}
    Local cChaveMid	:= ""
    Local cNrInsc	:= ""
    Local cTpInsc	:= ""
    Local lAdmPubl	:= .F.
    Local dDtRGE    := dDataBase
    Local cDtRGE    := ""
    Local lMatTSV	:= SRA->(ColumnPos("RA_DESCEP")) > 0
    Local lGeraMat  := .F.
    Local cTitle  	:= OemToAnsi(STR0041)
    Local oDlg		:= NIL
    Local nRadio    := 1
    Local aItens 	:= {}
    Local lRetif    := .F.
    Local dDtRetif  := dDataBase
    Local lRet      := .T.
    Local bOK1		:= {||lRet := .T., oDlg:End()}  
    Local bFecha 	:= {||lRet := .F., oDlg:End()}  
    Local cStat2206 := ""	
    Local cStat2306 := ""
    Local dDtEfet   := Ctod("")

    If FindFunction("fVersEsoc")
        fVersEsoc( "S2206", .F., /*aRetGPE*/, /*aRetTAF*/, @cVers2206, @cVersGPE )
    EndIf

    If FindFunction("fVersEsoc")
        fVersEsoc( "S2306", .F., /*aRetGPE*/, /*aRetTAF*/, @cVers2306, @cVersGPE )
    EndIf

    Define MsDialog oDlg FROM 0,0 TO 190,570 TITLE cTitle Pixel

    @ 10,10 Say OemToAnsi(STR0042) SIZE 200,12 OF oDlg PIXEL // "Selecione o tipo de Alteração Contratual em Lote que deseja gerar:"

    aItens   := { OemToAnsi(STR0043), OemToAnsi(STR0044), OemToAnsi(STR0045) }
  
    If lPpeAtiv
        @ 025,010 RADIO oRadio VAR nRadio ITEMS aItens[1],aItens[2] , aItens[3] 3D SIZE 270,012 
    Else
        @ 025,010 RADIO oRadio VAR nRadio ITEMS aItens[1],aItens[2]  3D SIZE 270,012
    Endif
    
    TButton():New( 70,175, "&" + OemToAnsi(STR0046),NIL, bOK1	, 45 , 012 , NIL , NIL , NIL , .T. )	// "Confirmar"
    TButton():New( 70,225,OemToAnsi(STR0027),NIL, bFecha	, 45 , 012 , NIL , NIL , NIL , .T. )	// "Cancelar"
    
    ACTIVATE MSDIALOG oDlg CENTERED

    If !lRet
        Return
    Endif

    If nRadio == 3
        lMp936 := .T.
    ElseIf nRadio == 2
        lRetif := .T.
    EndIf    

    Pergunte( cPerg, .F. )
    MakeSqlExpr( cPerg )

    //Filial
    If !Empty(mv_par01)
        cWhere += mv_par01
    EndIf

    //Centro de Custo
    If !Empty(mv_par02)
        cWhere += Iif(!Empty(cWhere)," AND ","")
        cWhere += mv_par02
    EndIf

    //Matricula
    If !Empty(mv_par03)
        cWhere += Iif(!Empty(cWhere)," AND ","")
        cWhere += mv_par03
    EndIf

    //Nome
    If !Empty(mv_par04)
        cWhere += Iif(!Empty(cWhere)," AND ","")
        cWhere += mv_par04
    EndIf

    //Situações
    If !Empty(mv_par05)
        cWhere += Iif(!Empty(cWhere)," AND ","")
        cWhere += "SRA.RA_SITFOLH IN (" + fSqlIn(StrTran(mv_par05,'*'),1) + ")"
    EndIf

    If lMp936
        If !Empty(cWhere)
            cWhere += " AND "
        EndIf
        
        dDtRGE := fRetDtRGE()
        cDtRGE := dTos(dDtRGE)
        cWhere += "EXISTS (SELECT RGE_MAT FROM " + RetSqlName('RGE') + " RGE WHERE RGE.RGE_FILIAL = SRA.RA_FILIAL AND RGE.RGE_MAT = SRA.RA_MAT AND RGE.RGE_DATAIN <= '" + dToS(dDtRGE) + "'" 
        
        // Verifica se o campo RGE_DTALT existe no dicionário, se existir é incluído na query
        If RGE->(ColumnPos("RGE_DTALT")) == 0
            cWhere += "AND RGE.RGE_DATAFI >= '" + dToS(dDtRGE) + "' "
            cWhere += "AND RGE.RGE_PPE = '1' AND RGE.RGE_COD != '  ' AND RGE.D_E_L_E_T_ = ' ') 
        Else
            cWhere += "AND ((RGE.RGE_DATAFI >= '" + dToS(dDtRGE) + "' AND RGE.RGE_STATUS IN (' ','0','3')) OR RGE.RGE_DTALT >= '" + dToS(dDtRGE) + "' AND RGE.RGE_STATUS IN (' ','0','3','4')) "
            cWhere += "AND RGE.RGE_PPE = '1' AND RGE.RGE_COD != '  ' AND RGE.RGE_STATUS != '2' AND RGE.D_E_L_E_T_ = ' ') 
        EndIf

    EndIf

    If lRetif
        fRetDtRet(@dDtRetif,@dDtEfet)
    Endif

    If !Empty(cWhere)
        cWhere += " AND "
    EndIf

    //Prepara a variável para uso no BeginSql
    cWhere := "%" + cWhere + "%"

    //Processa a query e cria a tabela temporária com os resultados
    BeginSql alias cAliasQry
        SELECT SRA.RA_FILIAL, SRA.RA_MAT
        FROM %table:SRA% SRA
        WHERE %exp:cWhere% 
                SRA.%notDel%
        ORDER BY SRA.RA_FILIAL, SRA.RA_MAT
    EndSql 

    While (cAliasQry)->( !EoF() )
    
        //Ordena a tabela SRA pela ordem 1 - RA_FILIAL+RA_MAT
        SRA->( dbSetOrder(1) )
        //Posiciona na tabela SRA
        SRA->( dbSeek( (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT ) )
        cFilAnt := SRA->RA_FILIAL
        aErros  := {}
        cMsgErro:= ""

        If SRA->RA_CATEFD $ cCategCV
            If !lMiddleware
                cCPF 	:= AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
                //VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO
                cStatus := TAFGetStat( "S-2200", cCPF )//ADMISSAO POR CADASTRO
            Else
                fPosFil( cEmpAnt, SRA->RA_FILIAL )
                aInfoC   := fXMLInfos()
                If LEN(aInfoC) >= 4
                    cTpInsc  := aInfoC[1]
                    lAdmPubl := aInfoC[4]
                    cNrInsc  := aInfoC[2]
                Else
                    cTpInsc  := ""
                    lAdmPubl := .F.
                    cNrInsc  := "0"
                EndIf
                cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
                cStatus 	:= "-1"			
                //RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
                GetInfRJE( 2, cChaveMid, @cStatus )
            EndIf
        Else
            lGeraMat :=  If(lMatTSV .And. SRA->RA_DESCEP == "1", .T., lGeraMat) 
            If !lMiddleware
				If cVers2306 >= "9.0"
					cCPF := AllTrim( SRA->RA_CIC ) + ";" + Iif(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA) 
				Else
                    cCPF    := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + dToS( SRA->RA_ADMISSA )
				EndIf
                //VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO
                cStatus := TAFGetStat( "S-2300", cCPF )
            Else
				If cVers2306 >= "9.0" .And. lGeraMat
					cCPF := AllTrim( SRA->RA_CODUNIC)
				Else
					cCPF    := AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )
				EndIf

                fPosFil( cEmpAnt, SRA->RA_FILIAL )
                aInfoC   := fXMLInfos()
                If LEN(aInfoC) >= 4
                    cTpInsc  := aInfoC[1]
                    lAdmPubl := aInfoC[4]
                    cNrInsc  := aInfoC[2]
                Else
                    cTpInsc  := ""
                    lAdmPubl := .F.
                    cNrInsc  := "0"
                EndIf
                cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, fTamRJEKey(), " ")
                cStatus 	:= "-1"			
                //RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
                GetInfRJE( 2, cChaveMid, @cStatus )
            EndIf      
        EndIf

        If cStatus  == "4"
            RegToMemory("SRA",.F.,.T.,.F.)
            If SRA->RA_CATEFD $ cCategCV
                If lRetif
                    If Empty(dDtEfet)
                       cStat2206:= TAFGetStat( "S-2206", cCPF+";"+DtoS(dDtRetif)+";"+ Space(Len(DtoS(dDtRetif)))+";", cEmpAnt, SRA->RA_FILIAL)
                    Else
                        cStat2206:= TAFGetStat( "S-2206", cCPF+";"+DtoS(dDtRetif)+";"+ DtoS(dDtEfet)+";", cEmpAnt, SRA->RA_FILIAL)
                    Endif
                    If cStat2206 <> "4"
                        aAdd( aLog[1], STR0009 + (cAliasQry)->RA_FILIAL + STR0010 + (cAliasQry)->RA_MAT + STR0051 )//"Filial: "##"  -  Matrícula: "##"  -  não foi enviado pois o evento não foi transmitido ao RET."
                        //Pula para o próximo registro
                        (cAliasQry)->( dbSkip() )
                        Loop
                    Endif
                Endif 
                If !fInt2206("SRA", Nil, 3, "S2206", Nil, If(lRetif .And. !Empty(dDtEfet),Dtos(dDtEfet),Nil), Nil, Nil, Nil, Nil, cVers2206, Nil, If(lRetif,dDtRetif,Nil), Nil, Nil, @aErros, .F.,If(lRetif, .T.,.F.),,,,,, cDtRGE)
                    If Len( aErros ) > 0
                        aAdd( aLog[1], STR0009 + (cAliasQry)->RA_FILIAL + STR0010 + (cAliasQry)->RA_MAT + "  -  S-2206" + STR0011 )//"Filial: "##"  -  Matrícula: "##"  -  não foi enviado devido ao(s) erro(s) abaixo:"
                        FeSoc2Err( aErros[1], @cMsgErro , Iif( aErros[1] != '000026',1,2 ) )
                        FrmTexto(@cMsgErro)
                        aErros[1] := cMsgErro
                        aAdd( aLog[1], cMsgErro )
                    Else
                        If !lMiddleware
                            aAdd( aLog[1], STR0009 + (cAliasQry)->RA_FILIAL + STR0010 + (cAliasQry)->RA_MAT + "  -  S-2206" + STR0012 )//"Filial: "##"  -  Matrícula: "##"  -  não foi enviado devido a um erro no TAF."
                        Else
                            aAdd( aLog[1], STR0009 + (cAliasQry)->RA_FILIAL + STR0010 + (cAliasQry)->RA_MAT + "  -  S-2206" + STR0016 )//"Filial: "##"  -  Matrícula: "##"  -  não foi enviado devido a um erro no Middleware."
                        EndIf
                    EndIf                
                Else
                    aAdd( aLog[1], STR0009 + (cAliasQry)->RA_FILIAL + STR0010 + (cAliasQry)->RA_MAT + "  -  S-2206" + STR0013 )//"Filial: "##"  -  Matrícula: "##"  -  enviado com sucesso."
                EndIf
            Else
                If lRetif
                    lGeraMat :=  If(lMatTSV .And. SRA->RA_DESCEP == "1", .T., lGeraMat)  
                    If cVers2306 >= "9.0"
                        cCPF := AllTrim( SRA->RA_CIC ) + ";" + Iif(lGeraMat, SRA->RA_CODUNIC, "")   //  S.1 o índice na T0F é o 6 => T0F_FILIAL, T0F_CPF, T0F_MATTSV, T0F_DTALT, T0F_ATIVO, R_E_C_N_O_, D_E_L_E_T_
                    Else
                        cCPF := AllTrim( SRA->RA_CIC ) //  2.5 o índice na T0F é o 3 => T0F_FILIAL, T0F_CPF, T0F_DTALT, T0F_ATIVO, R_E_C_N_O_, D_E_L_E_T_
                    EndIf      
                    cStat2306:= TAFGetStat( "S-2306", cCPF+";"+DtoS(dDtRetif)+";"+ Space(Len(DtoS(dDtRetif)))+";", cEmpAnt, SRA->RA_FILIAL)
                    If cStat2306 <> "4"
                        aAdd( aLog[1], STR0009 + (cAliasQry)->RA_FILIAL + STR0010 + (cAliasQry)->RA_MAT + STR0051 )//"Filial: "##"  -  Matrícula: "##"  -  não foi enviado pois o evento não foi transmitido ao RET."
                        //Pula para o próximo registro
                        (cAliasQry)->( dbSkip() )
                        Loop
                    Endif
                Endif    
                If !fInt2306New("SRA", Nil, 3, "S2306", Nil, Nil, cVers2306, Nil, Nil, Nil, If(lRetif,dDtRetif,Nil), If(lRetif,.T.,.F.), @aErros, .F.)
                    If Len( aErros ) > 0
                        aAdd( aLog[1], STR0009 + (cAliasQry)->RA_FILIAL + STR0010 + (cAliasQry)->RA_MAT + "  -  S-2306" + STR0011 )//"Filial: "##"  -  Matrícula: "##"  -  não foi enviado devido ao(s) erro(s) abaixo:"
                        FeSoc2Err( aErros[1], @cMsgErro , Iif( aErros[1] != '000026',1,2 ) )
                        FrmTexto(@cMsgErro)
                        aErros[1] := cMsgErro
                        aAdd( aLog[1], cMsgErro )
                    Else
                        If !lMiddleware
                            aAdd( aLog[1], STR0009 + (cAliasQry)->RA_FILIAL + STR0010 + (cAliasQry)->RA_MAT + "  -  S-2306" + STR0012 )//"Filial: "##"  -  Matrícula: "##"  -  não foi enviado devido a um erro no TAF."
                        Else
                            aAdd( aLog[1], STR0009 + (cAliasQry)->RA_FILIAL + STR0010 + (cAliasQry)->RA_MAT + "  -  S-2306" + STR0016 )//"Filial: "##"  -  Matrícula: "##"  -  não foi enviado devido a um erro no Middleware."
                        EndIf
                    EndIf                
                Else
                    aAdd( aLog[1], STR0009 + (cAliasQry)->RA_FILIAL + STR0010 + (cAliasQry)->RA_MAT + "  -  S-2306" + STR0013 )//"Filial: "##"  -  Matrícula: "##"  -  enviado com sucesso."
                EndIf
            EndIf
        Else
            //Adiciona no log de ocorrências
            aAdd( aLog[1], STR0009 + (cAliasQry)->RA_FILIAL + STR0010 + (cAliasQry)->RA_MAT + STR0014 )//"Filial: "##"  -  Matrícula: "##"  -  não foi enviado pois funcionário não foi transmitido ao RET."
        EndIf
        
        //Pula para o próximo registro
        (cAliasQry)->( dbSkip() )
    EndDo

    //Fecha a tabela temporária da query
    (cAliasQry)->( dbCloseArea() )

Return

/*/{Protheus.doc} fVldSX1
Função que valida a existência das perguntas que serão utilizadas na rotina
/*/
Static Function fVldSX1()

Local aAreaSX1  := SX1->( GetArea() )
Local lRet      := .F.

SX1->( dbSetOrder(1) )
lRet := SX1->( dbSeek(cPerg) )

RestArea(aAreaSX1)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fAlertRGE
Função para exibição de alerta e link para o TDN com orientação sobre atualização da RGE
@author Allyson Mesashi
@since 16/04/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fAlertRGE()
Local oButton1
Local oButton2
Local oCheckBo1
Local lCheckBo1 	:= .F.
Local oGroup1
Local oPanel1
Local oSay1
Local cSession		:= "AlertaGPEM047_"
Local lChkMsg 		:= fwGetProfString(cSession,"MSG_GPEM047_" + cUserName,'',.T.) == ""
Local oDlg

If lChkMsg
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0017) FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL //"Atualização de dicionário"

		@ 000, 000 MSPANEL oPanel1 SIZE 300, 150 OF oDlg COLORS 0, 16777215 RAISED
		@ 005, 012 GROUP oGroup1 TO 055, 237 PROMPT OemToAnsi(STR0018) OF oPanel1 COLOR 0, 16777215 PIXEL //"Atenção"
		@ 020, 017 SAY oSay1 PROMPT OemToAnsi(STR0021) SIZE 215, 035 OF oPanel1 COLORS 0, 16777215 PIXEL //'Ao habilitar o mnemônico P_LPPEATIV, é necessário a criação de alguns campos na tabela RGE. Clique em "Abrir Link" para consultar a documentação no TDN'
		@ 080, 012 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT OEMToAnsi(STR0019) SIZE 067, 008 OF oPanel1 COLORS 0, 16777215 PIXEL //"Não exibir novamente"
		@ 070, 160 BUTTON oButton1 PROMPT STR0020 SIZE 037, 012 OF oPanel1 PIXEL//"Abrir Link"
		@ 070, 200 BUTTON oButton2 PROMPT "OK" SIZE 037, 012 OF oPanel1 PIXEL

		oButton1:bLClicked := {|| ShellExecute("open","https://tdn.totvs.com/x/UVKPI","","",1) }
		oButton2:bLClicked := {|| oDlg:End() }

	ACTIVATE MSDIALOG oDlg CENTERED

	If lCheckBo1
		fwWriteProfString(cSession, "MSG_GPEM047_" + cUserName, 'CHECKED', .T.)
	EndIf	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fAlertRGE
Função para exibição de alerta e link para o TDN com orientação sobre atualização da RGE
@author Allyson Mesashi
@since 16/04/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fRetDtRGE()

    Local oDlgDtRGE
    Local oGrpPsq
    Local oGrpInstr
    Local oSayDtRGE
    Local oGetDtRGE
    Local oBtnOk
    Local dDataPesq := dDataBase
    Local oInstr1
    Local oInstr2
    Local oInstr3
    Local oInstr4
    Local oInstr5
    Local oInstr6
    Local oInstr7

    // DEFINICAO DO DIALOG E TODOS OS SEUS COMPONENTES.
	Define MsDialog oDlgDtRGE Title OemToAnsi(STR0023) FROM 013, 010 To 030, 069 OF GetWndDefault() STYLE DS_MODALFRAME

    // GRUPO DE DATA
    oGrpPsq     := TGroup():New(004, 005, 034, 096, OemToAnsi(STR0024), oDlgDtRGE,,, .T., .F.)
    oSayDtRGE   := TSay():New(018, 009, { || OemToAnsi(STR0025)}, oGrpPsq,,,.F.,.F.,.F.,.T.,,,016,008)
    oGetDtRGE   := TGet():New(016, 025, { |u| If(PCount() == 0, dDataPesq, dDataPesq := u)}, oGrpPsq, 060, 008, '@D',,,,,,, .T., OemToAnsi(STR0026),,,,,, .F.,, ""	, "dDataPesq",,,, .T.)
    oBtnOk      := TButton():New(022, 097, OemToAnsi(STR0028), oDlgDtRGE, {|| Iif(!Empty(dDataPesq), oDlgDtRGE:End(), Help( ,, OemToAnsi(STR0018),, + CRLF + OemToAnsi(STR0029), 1, 0))}, 037, 012,,,, .T.,, "",,,, .F.)

    // GRUPO DE INSTRUÇÕES
    oGrpInstr   := TGroup():New(035, 005, 120, 230, OemToAnsi(STR0037), oDlgDtRGE,,, .T.,.F.)
    oInstr1     := TSay():New(046, 009, {|| OemToAnsi(STR0030)}, oGrpInstr,,, .F., .F., .F., .T.,,, 230, 008)
    oInstr2     := TSay():New(056, 009, {|| OemToAnsi(STR0031)}, oGrpInstr,,, .F., .F., .F., .T.,,, 230, 008)
    oInstr3     := TSay():New(066, 009, {|| OemToAnsi(STR0032)}, oGrpInstr,,, .F., .F., .F., .T.,,, 230, 008)
    oInstr4     := TSay():New(076, 009, {|| OemToAnsi(STR0033)}, oGrpInstr,,, .F., .F., .F., .T.,,, 230, 008)
    oInstr5     := TSay():New(086, 009, {|| OemToAnsi(STR0034)}, oGrpInstr,,, .F., .F., .F., .T.,,, 230, 008)
    oInstr6     := TSay():New(096, 009, {|| OemToAnsi(STR0035)}, oGrpInstr,,, .F., .F., .F., .T.,,, 230, 008)
    oInstr7     := TSay():New(106, 009, {|| OemToAnsi(STR0036)}, oGrpInstr,,, .F., .F., .F., .T.,,, 230, 008)

    // IMPEDE QUE FECHE A TELA USANDO O ESC
    oDlgDtRGE:lEscClose := .F.

    // CARREGA A DIALOG
    oDlgDtRGE:Activate(,,, .T.)

Return dDataPesq


//-------------------------------------------------------------------
/*/{Protheus.doc} fAlertRGE
Função para exibição de alerta e link para o TDN com orientação sobre atualização da RGE
@author Silvia Taguti
@since 08/06/2021
@version 1
/*/
//-------------------------------------------------------------------
Static Function fRetDtRet(dDataPesq, dDataEf )

    Local oDlgDtRef
    Local oGrpPsq
    Local oGrpInstr
    Local oSayDtRef
    Local oGetDtRef
    Local oBtnOk
    Local oInstr1
    Local oInstr2
    Local oInstr3
    Local oGrpEfe
    Local oSayDtEfe
    Local oGetDtEfe
    Local oGrpInstr1
    Local oInstr4
    Local oInstr5

    Default dDataEf := CTOD("")
    Default  dDataPesq := dDataBase

    // DEFINICAO DO DIALOG E TODOS OS SEUS COMPONENTES.
	Define MsDialog oDlgDtRef Title OemToAnsi(STR0023) FROM 008, 010 To 040, 080 OF GetWndDefault() STYLE DS_MODALFRAME

    // GRUPO DE DATA
    oGrpPsq     := TGroup():New(004, 005, 034, 096, OemToAnsi(STR0024), oDlgDtRef,,, .T., .F.)
    oSayDtRef   := TSay():New(018, 009, { || OemToAnsi(STR0025)}, oGrpPsq,,,.F.,.F.,.F.,.T.,,,016,008)
    oGetDtRef   := TGet():New(016, 025, { |u| If(PCount() == 0, dDataPesq, dDataPesq := u)}, oGrpPsq, 060, 008, '@D',,,,,,, .T., OemToAnsi(STR0047),,,,,, .F.,, ""	, "dDataPesq",,,, .T.)
    oBtnOk      := TButton():New(022, 097, OemToAnsi(STR0028), oDlgDtRef, {|| Iif(!Empty(dDataPesq), oDlgDtRef:End(), Help( ,, OemToAnsi(STR0018),, + CRLF + OemToAnsi(STR0029), 1, 0))}, 037, 012,,,, .T.,, "",,,, .F.)

    // GRUPO DE INSTRUÇÕES
    oGrpInstr   := TGroup():New(035, 005, 090, 230, OemToAnsi(STR0037), oDlgDtRef,,, .T.,.F.)
    oInstr1     := TSay():New(046, 009, {|| OemToAnsi(STR0048)}, oGrpInstr,,, .F., .F., .F., .T.,,, 230, 008)
    oInstr2     := TSay():New(056, 009, {|| OemToAnsi(STR0049)}, oGrpInstr,,, .F., .F., .F., .T.,,, 230, 008)
    oInstr3     := TSay():New(066, 009, {|| OemToAnsi(STR0050)}, oGrpInstr,,, .F., .F., .F., .T.,,, 230, 008)


    // GRUPO DE DATA ALTERAÇÃO SALARIAL 
    oGrpEfe     := TGroup():New(095, 005, 125, 110, OemToAnsi(STR0055), oDlgDtRef,,, .T., .F.)
    oSayDtEfe   := TSay():New(110, 009, { || OemToAnsi(STR0025)}, oGrpEfe,,,.F.,.F.,.F.,.T.,,,120,009)
    oGetDtEfe   := TGet():New(108, 025, { |u| If(PCount() == 0, dDataEf, dDataEf := u)}, oGrpEfe, 070, 008, '@D',,,,,,, .T., OemToAnsi(STR0047),,,,,, .F.,, ""	, "dDataEf",,,, .T.)

    // GRUPO DE INSTRUÇÕES
    oGrpInstr1   := TGroup():New(130, 005, 180, 230, OemToAnsi(STR0054), oDlgDtRef,,, .T.,.F.)                  //"Instruções Data Efetiva"
    oInstr4     := TSay():New(146, 009, {|| OemToAnsi(STR0052)}, oGrpInstr1,,, .F., .F., .F., .T.,,, 230, 008)
    oInstr5     := TSay():New(156, 009, {|| OemToAnsi(STR0053)}, oGrpInstr1,,, .F., .F., .F., .T.,,, 230, 008)

    // IMPEDE QUE FECHE A TELA USANDO O ESC
    oDlgDtRef:lEscClose := .F.

    // CARREGA A DIALOG
    oDlgDtRef:Activate(,,, .T.)

Return dDataPesq
