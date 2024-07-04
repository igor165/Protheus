#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FISA215.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA214
Função para geração do arquivo para a prefeitura de Niteroi de 
serviços prestados/tomados.
/*/
//-------------------------------------------------------------------

Function FISA215() 
Local lLGPD  		:= FindFunction("Verpesssen") .And. Verpesssen()
Private lAutomato   := IiF(IsBlind(),.T.,.F.)

If !lAutomato .And. lLGPD
    If Pergunte('FISA215',.T.,STR0001 )  //"Parâmetros de geração do arquivo"
        FwMsgRun(,{|oSay| ProcArq(oSay) },STR0002,"")	  //"Processando do arquivo"
    EndIf
Else
    ProcArq()
EndIf
Return
/*/{Protheus.doc} ProcArq
Rotina que chama as funções de cada registro
/*/
//-------------------------------------------------------------------
Static Function ProcArq(oSay)
Local cAlias        := GetNextAlias()
Local nHandle       := 0 
Local lHtml         := .F.
Local cArquivo      := ""
Local dDataEmisDe   := MV_PAR01
Local dDataEmisAte  := MV_PAR02
Local cNFiscalDe    := MV_PAR03
Local cNFiscaAte    := MV_PAR04
Local cSerieDe      := MV_PAR05
Local cSerieAte     := MV_PAR06
Local cCodSerDe     := MV_PAR07
Local cCodSerAte    := MV_PAR08
Local cDiretorio    := AllTrim(MV_PAR09)
Local cNomeArq      := AllTrim(MV_PAR10)
Local nGeraMovto    := MV_PAR11
Local cInsMun       := PadL(AllTrim(SuperGetMv("MV_NFEINSC")),15,"0")
Local cWhere        := ""
Local cLib
Local nRetType      := 0
Local cReg10        := ""
Local cReg90        := ""
Local cTipoCont     := Iif(SM0->M0_TPINSC = 2 ,"2",Iif(SM0->M0_TPINSC = 3, "1"," ") )
Local cCnpjPrest    := PadL(SM0->M0_CGC,14,"0")
Local cCodISS       := ""
Private cQuebra     := CHR(13)+CHR(10)
Private cLinha      := ""
Private nValDC := nValDI := 0
Private ntotlin := nTotval := nTotvalded := 0    
Private cReg20  := cReg30 := cReg40 := ""
Private cNota := cSerien := cFor := cReg := cCont := ""
Private dDatEmis := Date()

If Empty(dDataEmisDe) .Or. Empty(dDataEmisAte)
    MsgInfo("            Impossível prosseguir!!!"+CRLF+;
            "Necessario informar data ínicio e data fim.")
    Return
Endif
If Empty(cDiretorio)
        MsgInfo("    Impossível prosseguir!!!"+CRLF+;
            "Necessario informar diretório.")
    Return
Endif
If Empty(cNomeArq)
        MsgInfo("       Impossível prosseguir!!!"+CRLF+; 
            "Necessario informar nome do arquivo.")
    Return
Endif
If Empty(cNFiscaAte)
    cNFiscaAte := "ZZZZZZZZZ"
Endif
If Empty(cSerieAte)
    cSerieAte := "ZZZ"
Endif
If Empty(cCodSerAte)
    cCodSerAte := "ZZZZ"
Endif

SF2->(DbSetOrder(2))
SF1->(DbSetOrder(2))

nRetType := GetRemoteType(@cLib)
If nRetType == 5 //"HTML" $ cLib
    lHtml := .T.
EndIf
AtualizaMsg( oSay, STR0003 )  //"Selecionando os registros"
If nGeraMovto == 1
    cWhere := "SF3.F3_CFO < '5'"    
ElseIf nGeraMovto == 2
    cWhere := "SF3.F3_CFO >= '5'"
Else 
    cWhere := "SF3.F3_CFO > '1'"
EndIf
cWhere := "%" + cWhere + "%"
BeginSql Alias cAlias
    COLUMN F3_EMISSAO AS DATE
    COLUMN F3_DTCANC  AS DATE

    SELECT  SF3.F3_ESPECIE,
            SF3.F3_NFISCAL,
            SF3.F3_EMISSAO,
            SF3.F3_ALIQICM,
            SF3.F3_BASEICM,
            SF3.F3_ICMSRET,
            SF3.F3_VALCONT,
            SF3.F3_DTCANC,
            SF3.F3_ISENICM,
            SF3.F3_OUTRICM,
            SF3.F3_CODISS,
            SF3.F3_ISSSUB,
            SF3.F3_ISSMAT,
            SF3.F3_NFELETR,
            SF3.F3_VALICM,
            SF3.F3_RECISS,
            SF3.F3_ENTRADA,
            SF3.F3_SERIE,
            SF3.F3_CLIEFOR,
            SF3.F3_TIPO,
            SF3.F3_CNAE,
            SF3.F3_CFO,

            ISNULL(SF1.F1_VALCOFI, SF2.F2_VALCOFI) VALCOFI,
            ISNULL(SF1.F1_VALIRF, SF2.F2_VALIRRF) VALIRRF,
            ISNULL(SF1.F1_VALCSLL, SF2.F2_VALCSLL) VALCSLL,
            ISNULL(SF1.F1_INSS, SF2.F2_VALINSS) VALINSS,
            ISNULL(SF1.F1_VALPIS, SF2.F2_VALPIS) VALPIS,
            ISNULL(SF1.F1_DESCONT, SF2.F2_DESCONT) DESCONT,         
            
            ISNULL(SA1.A1_PESSOA, SA2.A2_TIPO) TIPO,
            ISNULL(SA1.A1_NOME, SA2.A2_NOME) NOME,
            ISNULL(SA1.A1_CGC, SA2.A2_CGC) CNPJ,
            ISNULL(SA1.A1_CGC, SA2.A2_CGC) CNPJ,
            ISNULL(SA1.A1_END, SA2.A2_END) ENDERECO,
            ISNULL(SA1.A1_COMPLEM, SA2.A2_COMPLEM) COMPLEMENTO,
            ISNULL(SA1.A1_BAIRRO, SA2.A2_BAIRRO) BAIRRO,
            ISNULL(SA1.A1_MUN, SA2.A2_MUN) MUNICIPIO,
            ISNULL(SA1.A1_EST, SA2.A2_EST) ESTADO,
            ISNULL(SA1.A1_CEP, SA2.A2_CEP) CEP,
            ISNULL(SA1.A1_TEL, SA2.A2_TEL) TELEFONE,
            ISNULL(SA1.A1_FAX, SA2.A2_FAX) FAX,
            ISNULL(SA1.A1_COD_MUN, SA2.A2_COD_MUN) CODMUN,
            ISNULL(SA1.A1_PAIS, SA2.A2_PAIS) PAIS,
            ISNULL(SA1.A1_SIMPNAC, SA2.A2_SIMPNAC) SIMPNAC,
            ISNULL(SA1.A1_TPJ, SA2.A2_TPJ) TPJ,
            ISNULL(SA1.A1_INCULT, SA2.A2_INCULT) INCULT,
            ISNULL(SA1.A1_EMAIL, SA2.A2_EMAIL) EMAIL,
            ISNULL(SA1.A1_INSCRM, SA2.A2_INSCRM) INSCRM,
            ISNULL(SA1.A1_INSCR, SA2.A2_INSCR) INSCR,
            SA1.A1_NIF,
            SA1.A1_TIPO,
            SA2.A2_SIMPNAC,
            ISNULL(SD1.D1_ABATISS,SD2.D2_ABATISS) ABATISS,
            ISNULL(SD2.D2_TES,SD1.D1_TES)TES

    FROM 	%TABLE:SF3% SF3
    LEFT JOIN %TABLE:SF2% SF2 ON(SF2.F2_FILIAL = %xFilial:SF2% AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR AND SF2.F2_LOJA = SF3.F3_LOJA AND SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE = SF3.F3_SERIE AND SF2.F2_ESPECIE = SF3.F3_ESPECIE AND SF2.%NOTDEL%) 
    LEFT JOIN %table:SD2% SD2 ON(SD2.D2_FILIAL  = %xFilial:SD2% AND SD2.D2_DOC = SF3.F3_NFISCAL AND SD2.D2_SERIE = SF3.F3_SERIE AND SD2.D2_CLIENTE = SF3.F3_CLIEFOR AND SD2.D2_LOJA = SF3.F3_LOJA AND SD2.%NotDel%)
    LEFT JOIN %TABLE:SA2% SA2 ON(SA2.A2_FILIAL = %xFilial:SA2% AND SA2.A2_COD = SF3.F3_CLIEFOR AND SA2.A2_LOJA = SF3.F3_LOJA AND SF3.F3_CFO < '5' AND SF3.F3_TIPO NOT IN ('D','B') AND SA2.%NOTDEL%)    
    LEFT JOIN %TABLE:SF1% SF1 ON(SF1.F1_FILIAL = %xFilial:SF1% AND SF1.F1_FORNECE = SF3.F3_CLIEFOR AND SF1.F1_LOJA = SF3.F3_LOJA AND SF1.F1_DOC = SF3.F3_NFISCAL AND SF1.F1_SERIE = SF3.F3_SERIE AND SF1.F1_ESPECIE = SF3.F3_ESPECIE AND SF1.%NOTDEL%) 
    LEFT JOIN %table:SD1% SD1 ON(SD1.D1_FILIAL  = %xFilial:SD1% AND SD1.D1_DOC = SF3.F3_NFISCAL AND SD1.D1_SERIE = SF3.F3_SERIE AND SD1.D1_FORNECE = SF3.F3_CLIEFOR AND SD1.D1_LOJA = SF3.F3_LOJA AND SD1.%NotDel%)
    LEFT JOIN %TABLE:SA1% SA1 ON(SA1.A1_FILIAL = %xFilial:SA1% AND SA1.A1_COD = SF3.F3_CLIEFOR AND SA1.A1_LOJA = SF3.F3_LOJA AND SF3.F3_CFO >= '5' AND SF3.F3_TIPO NOT IN ('D','B') AND SA1.%NOTDEL%)
   
    WHERE   SF3.F3_FILIAL=%XFILIAL:SF3%     
    AND     SF3.F3_EMISSAO BETWEEN %EXP:dDataEmisDe% AND %EXP:dDataEmisAte%   
    AND     SF3.F3_NFISCAL BETWEEN %EXP:cNFiscalDe% AND %EXP:cNFiscaAte%
    AND     SF3.F3_SERIE   BETWEEN %EXP:cSerieDe% AND %EXP:cSerieAte%
    AND     SF3.F3_CODISS <> ' '
    AND     %Exp:cWhere%
    AND     SF3.%NOTDEL%    
EndSql

DbSelectArea(cAlias)
AtualizaMsg( oSay, STR0004)  //"Gerando arquivo texto"
SC5->(dbSetOrder(1))//C5_FILIAL, C5_NUM
SX5->(dbSetOrder(1))
SC6->(dbSetOrder(4))//C6_FILIAL, C6_NOTA, C6_SERIE
SE1->(dbSetOrder(2))//E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
SD1->(dbSetOrder(1))//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
SD2->(dbSetOrder(3))//D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
//Cria o arquivo texto para gravação dos registros.
CriaArq(lHtml, @nHandle, @cArquivo, cDiretorio, cNomeArq)
//Registro 10 - Identificação do Documento Fiscal 
cReg10 :=   "10"               +;
            "003"              +;
            cTipoCont          +;
            cCnpjPrest         +;
            cInsMun            +;
            DTOS(dDataEmisDe)  +;
            DTOS(dDataEmisAte) +;
            cQuebra           
cLinha := cReg10

While !(cAlias)->(Eof())
    cCodISS := (cAlias)->F3_CODISS
    If Empty(AllTrim( cCodISS ))
        (cAlias)->(dbSkip())
        Loop
    EndIf
    If !empty(cCodSerDe) .OR. !empty(cCodSerAte)
        If  !(cCodIss >=  cCodSerDe .And.  cCodIss <= cCodSerAte)
            (cAlias)->(dbSkip())
            Loop
        EndIf
    Endif
    SF4->(MsSeek(xFilial("SF4")+(cAlias)->TES))
    GeraLinha(nHandle, cAlias)   
    (cAlias)->(dbSkip())
EndDo

If Empty(cReg20) .And. Empty(cReg30) .And. Empty(cReg40)
    MsgInfo("Nenhum registro Encontrado!!")
    FechaArq(lHtml, nHandle, cArquivo)
    Return Nil
endif

//Registro 90 - Rodapé
cReg90 :=   "90"                    +;
            STRZERO(ntotlin,8)      +;   
            GER_NUM(nTotval,16,2)   +;            
            GER_NUM(nTotvalded,16,2)+;            
            nValDC                  +;
            nValDI                  +;            
            cQuebra
cLinha += cReg90

FWrite(nHAndle,cLinha)
(cAlias)->(dbCloseArea())
AtualizaMsg( oSay, STR0005 )  //"Processamento Concluído"
//Fecha o arquivo gerado.
FechaArq(lHtml, nHandle, cArquivo)

If !lAutomato
    Alert(STR0005) //"Processamento Concluído"
EndIf
Return					
/*/{Protheus.doc} CriaArq
Rotina para criar o arquivo texto.
/*/
//-------------------------------------------------------------------
Static Function CriaArq(lHtml, nHandle, cArquivo, cDiretorio, cNomeArq)
If Substr(cDiretorio,Len(cDiretorio), 1) != "\"
	cDiretorio += "\"
EndIf
If lHtml
    cDirDest := GetSrvProfString("startpath","")
Else
    cDirDest := cDiretorio
EndIf
cArquivo := cDirDest+cNomeArq
nHandle := fCreate(cArquivo)
If nHandle = -1 .And. !lAutomato
    Alert(STR0006 + Str(Ferror())) //'Erro ao criar arquivo:'
EndIf
Return
/*/{Protheus.doc} FechaArq
Rotina para fechar o arquivo texto.
/*/
//-------------------------------------------------------------------
Static Function FechaArq(lHtml, nHandle, cArquivo)
nRet := 0
FClose(nHandle)
If lHtml
    nRet := CPYS2TW(cArquivo,.T.)
    If nRet == 0
        FErase (cArquivo)
    EndIf
EndIf
Return
//-------------------------------------------------------------------
Static Function AtualizaMsg(oSay,cMsg)
    If !lAutomato
        oSay:cCaption := (cMsg)
        ProcessMessages()
    EndIf
Return
//-------------------------------------------------------------------
Static Function GER_NUM(PVALOR,PTAM,PDEC)
PVALOR := STRZERO(PVALOR,PTAM,PDEC)
LEFT(PVALOR,PTAM-3)
RIGHT(PVALOR,2)
Return ( LEFT(PVALOR,PTAM-3) + RIGHT(PVALOR,2) )
//-------------------------------------------------------------------
/*/{Protheus.doc} GeraLinha
Rotina para gerar as linhas do arquivo texto.
/*/
//-------------------------------------------------------------------
Static Function GeraLinha(nHandle, cAlias)
Local nTipDescr     := SuperGetMv("MV_NFESERV")
Local cEspecie      := SuperGetMv("MV_NFECONJ")
Local nRetIrr       := SuperGetMv("MV_VLRETIR",,0) 
Local cNumDoc       := PadL(AllTrim((cAlias)->F3_NFISCAL),15,'0') 
Local dDataEmis     := DtoS((cAlias)->F3_EMISSAO)
Local cSerie        := PadR(ALLTRIM((cAlias)->F3_SERIE),5," ")
Local cTipoTomad    := ""
Local cCnpjTomad    := ""
Local nAlqIss       := GER_NUM((cAlias)->F3_ALIQICM,6,2)
Local nIssAbat      := (cAlias)->ABATISS
Local cNome         := PadR((cAlias)->NOME,115," ")  
Local nVirgula      := Rat(",",(cAlias)->ENDERECO)
Local cEndereco     := PadR(SubStr((cAlias)->ENDERECO, 1, nVirgula-1), 128)
Local cNumEnd       := AllTrim(Substr((cAlias)->ENDERECO, At(",",(cAlias)->ENDERECO)+1, Len(AllTrim((cAlias)->ENDERECO))))
Local nNumEnd       := PadR(cNumEnd,10,' ') 
Local cCompEnd      := PadR((cAlias)->COMPLEMENTO, 60, ' ') 
Local cBairro       := PadR((cAlias)->BAIRRO, 72,' ')
Local cMunicipio    := PadR((cAlias)->MUNICIPIO, 50,' ')  
Local cEstado       := PadR((cAlias)->ESTADO, 2,' ') 
Local cCEP          := PadL(AllTrim((cAlias)->CEP), 8,'0') 
Local cTelefone     := PadR((cAlias)->TELEFONE, 11,' ') 
Local cTipEspecie   := Iif(Empty(cEspecie),"0","1")
Local cStatus       := Iif(Empty((cAlias)->F3_DTCANC),"1","2")
Local cInscMt       := Space(15)
Local cInscEst      := Space(15)
Local cLogra        := ""
Local cPais         := Iif (!Empty((cAlias)->PAIS), "0"+(cAlias)->PAIS," ")
Local cNif          := PadL((cAlias)->A1_NIF, 40,'0') 
Local cMail         := PadR((cAlias)->EMAIL, 80,' ') 
Local cLocPrest     := NFePstServ(cMunicipio,cEstado,"NITEROI/NITERÓI","RJ",(cAlias)->F3_DTCANC,SF4->F4_ISSST,(cAlias)->F3_ISENICM + (cAlias)->F3_OUTRICM)
Local nTipExServ    := " " 
local cInsTom       := PadL('',15,"0")
Local cOpSimples    := Iif((cAlias)->SIMPNAC = "2", "0",Iif(SF4->F4_ISSST = "8" ,"3","1"))
Local nIncult       := Iif( (cAlias)->INCULT = "1", "1","0")
Local cCodSFed      := PadR("", 4," ") 
Local cCodSMun      := PadR(Alltrim((cAlias)->F3_CNAE), 7," ") 
Local cCodser       := PadR("", 20," ") 
Local cCodPrd       := ""
Local nValserv      := Iif(cLocPrest == "C",Replicate("0",15),GER_NUM( (cAlias)->F3_VALCONT,16,2 ))
Local nValded       := Iif(cLocPrest == "C" .And. Empty((cAlias)->F3_NFELETR),Replicate("0",15),GER_NUM((cAlias)->F3_ISSSUB+(cAlias)->F3_ISSMAT + (nIssAbat * 100),16,2) )
Local nValCof       := GER_NUM( (cAlias)->VALCOFI,16,2)
Local nValCsll      := GER_NUM( (cAlias)->VALCSLL,16,2)
Local nValInss      := GER_NUM( (cAlias)->VALINSS,16,2)
Local nRetIrpj      := GER_NUM(IIF((cAlias)->VALIRRF > nRetIrr,(cAlias)->VALIRRF ,0),16,2)
Local nValpis       := GER_NUM((cAlias)->VALPIS,16,2)
Local nValIss       := GER_NUM((cAlias)->F3_VALICM,16,2)
Local cIssRet       := Iif((cAlias)->F3_RECISS $ "N|2| ", "1", "0")
Local dDatCom       := ""
Local cDescri       := ""
Local cDescri1      := ExistBlock("MTDESCRNFE")
Local cDescri2      := Iif(cDescri1,Execblock("MTDESCRNFE",.F.,.F.,{(cAlias)->F3_NFISCAL,(cAlias)->F3_SERIE,(cAlias)->F3_CLIEFOR,SF3->F3_LOJA}),"")
Local cDados        := ""
Local cEnd          := ""
Local cTipo         := Iif((cAlias)->F3_TIPO = "D","05","01")
Local cRegEsTri     := Iif(Empty(SF4->F4_REGESP),"00",SF4->F4_REGESP)
Local cCidInSer     := Iif(SF4->F4_ISSST = "1", Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,UfCodIBGE(SM0->M0_ESTENT)+SM0->M0_CODMUN,PadL(SM0->M0_CODMUN,7,"0")), PadL(UfCodIBGE(cEstado)+(cAlias)->CODMUN,7,"0"))
Local cCidpres      := IIf(cLocPrest$"I",Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,UfCodIBGE(SM0->M0_ESTENT)+SM0->M0_CODMUN,PadL(SM0->M0_CODMUN,7,"0")),Iif(cLocPrest$"T",Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,UfCodIBGE(SM0->M0_ESTENT)+SM0->M0_CODMUN,PadL(SM0->M0_CODMUN,7,"0")),PadL(UfCodIBGE(cEstado)+(cAlias)->CODMUN,7,"0")))
local cTipTri       := Iif(SF4->F4_REGESP = "00","00", Iif(SF4->F4_REGESP = "04","04","02") )
Local cObra         := ""
                 
nValDC      := Iif(SF4->F4_DESCOND=="1",GER_NUM((cAlias)->DESCONT,16,2),Replicate("0",15))
nValDI      := Iif(SF4->F4_DESCOND<>"1",GER_NUM((cAlias)->DESCONT,16,2),Replicate("0",15))                 
nTotval     += (cAlias)->F3_VALCONT
nTotvalded  += (cAlias)->F3_ISSSUB+(cAlias)->F3_ISSMAT + (nIssAbat * 100)

SC6->(dbSeek(xFilial("SC6")+(cAlias)->F3_NFISCAL + (cAlias)->F3_SERIE))
SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM))
SE1->(MsSeek(xFilial("SE1")+(cAlias)->F3_CLIEFOR+SF3->F3_LOJA+(cAlias)->F3_SERIE+(cAlias)->F3_NFISCAL))

//VALIDAÇÃO PARA PEGAR O CÓDIGO DO SERVICO\PRODUTO PELA TABELA DE DOCS, 
//PARA CONSEGUIR BUSCAR A INFORMAÇÃO NA TABELA DE ALIQUOTA DE ISS.
If Left((cAlias)->F3_CFO,1) < '5'
    SD1->(MsSeek(xFilial("SD1")+(cAlias)->F3_NFISCAL + (cAlias)->F3_SERIE+ (cAlias)->F3_CLIEFOR+SF3->F3_LOJA))
    cCodPrd:= SD1->D1_COD
Else
    SD2->(MsSeek(xFilial("SD2")+(cAlias)->F3_NFISCAL + (cAlias)->F3_SERIE + (cAlias)->F3_CLIEFOR+SF3->F3_LOJA))
    cCodPrd:= SD2->D2_COD
EndIf


fRetServ(cCodPrd,cEstado,(cAlias)->CODMUN,(cAlias)->F3_CLIEFOR,@cCodser,@cCodSFed)


dDatCom     := Iif(cIssRet == "0",(cAlias)->F3_ENTRADA,Iif(!Empty(DTOS(SE1->E1_VENCTO)),DTOS(SE1->E1_VENCTO),(cAlias)->F3_ENTRADA) )
nTipDescr   := Iif(nTipDescr != "1" .OR. Empty(nTipDescr),"2","1")
Iif(nTipDescr == "1",cDescri := SC5->C5_MENNOTA,.T.)
// Descricao dos servicos pelo codigo do servico - F3_CODISS
Iif(Empty(cDescri),SX5->(dbSeek(xFilial("SX5")+"60"+(cAlias)->F3_CODISS)),.T.)
cDescri := Iif(Empty(cDescri),SX5->X5_DESCRI,cDescri)
cDescri := Iif(cLocPrest == "C" .And. Empty((cAlias)->F3_NFELETR),"",cDescri)
cDescri := Iif(!Empty(cDescri2),cDescri2,cDescri)
cCnpjTomad  := PadL(Alltrim((cAlias)->CNPJ),14,"0")
cInscEst    := PadL(Alltrim((cAlias)->INSCR),15,"0")

If (cAlias)->MUNICIPIO $ "NITEROI/NITERÓI" .OR. (cAlias)->CODMUN == "03302"
    cInscMt := PadR(AllTrim((cAlias)->INSCRM),15," ")
    cInsTom := PadL(AllTrim((cAlias)->INSCRM),15,"0")
Endif

If (SF4->F4_ISSST = "3")
    nTipExServ := "03"
ElseIf (SF4->F4_ISSST = "5")    
    nTipExServ := "06"
ElseIf (SF4->F4_ISSST = "6")    
    nTipExServ := "07"
ElseIf (SF4->F4_ISSST = "4")    
    nTipExServ := "05"    
ElseIf (SF4->F4_ISSST = "1")    
    nTipExServ := "01"
ElseIf (SF4->F4_ISSST = "2")    
    nTipExServ := "02"
Else    
    nTipExServ := "01"
Endif    

If ((cAlias)->TIPO = "F" .AND. Empty((cAlias)->A1_NIF) )
    cTipoTomad  := "1"
ElseIf ((cAlias)->TIPO = "J" .AND. Empty((cAlias)->A1_NIF)) 
    cTipoTomad  := "2"
ElseIf (!Empty((cAlias)->A1_NIF))    
    cTipoTomad  := "4"
Else    
    cTipoTomad  := "3"
Endif   
cObra  := PadR(SC5->C5_OBRA,15," ") 
cDados := Iif(cTipoTomad != "4",cCnpjTomad + cInscMt + cInscEst, cNif + "0000")
cEnd   := Iif(cPais = "0105" .OR. cPais = " ",cLogra + cEndereco + nNumEnd + cCompEnd + cBairro + cMunicipio + cEstado + cCEP + cTelefone,cPais + cEndereco + Replicate("0",212) )

If cNota == (cAlias)->F3_NFISCAL .And. cSerien == (cAlias)->F3_SERIE .And. cFor == (cAlias)->NOME .And. dDatEmis = (cAlias)->F3_EMISSAO .And. cCont == cReg
   Return Nil
Endif
cNota := (cAlias)->F3_NFISCAL
cSerien := (cAlias)->F3_SERIE 
cFor := (cAlias)->NOME
dDatEmis := (cAlias)->F3_EMISSAO 
cCont := cReg

 If Left((cAlias)->F3_CFO,1) >= '5' .And. !(cAlias)->F3_ESPECIE = "CF"
    //Registro 20 – Identificação dos serviços relacionados ao Documentos Fiscal
    cReg20 :=   "20"                 +;      //01
                cTipEspecie          +;      //02
                cSerie               +;      //03
                cNumDoc              +;      //04
                dDataEmis            +;      //05
                cStatus              +;      //06
                cTipoTomad           +;      //07
                cDados               +;      //08 
                cNome                +;      //09
                cEnd                 +;      //10
                cMail                +;      //11
                nTipExServ           +;      //12
cCidInSer + cCidpres + Space(38)     +;      //13
                cRegEsTri            +;      //14
                cOpSimples           +;      //15
                nIncult              +;      //16
                cCodSFed             +;      //17
                cCodSMun             +;      //18
                Replicate("0",9)     +;      //19
                Space(4)             +;      //20
                nAlqIss              +;      //21
                nValserv             +;      //22
                nValded              +;      //23
                nValDC               +;      //24
                nValDI               +;      //25
                nValCof              +;      //26
                nValCsll             +;      //27
                nValInss             +;      //28
                nRetIrpj             +;      //29
                nValpis              +;      //30
                Replicate("0",15)    +;      //31
                nValIss              +;      //32
                cIssRet              +;      //33
                dDatCom              +;      //34
                cObra                +;      //35
                Space(15)            +;      //36
                Space(5)             +;      //37
                Replicate("0",15)    +;      //38
                Space(30)            +;      //39
                cDescri              +;      //40                       
                cQuebra
                ntotlin += 1
                cReg := "cReg20"
    cLinha  += cReg20                     
Endif
If Left((cAlias)->F3_CFO,1) >= '5' .And. (cAlias)->F3_ESPECIE = "CF"
    //Registro 30 – Identificação da pessoa relacionada ao Documento Fiscal
    cReg30 :=   "30"                +;          //01
                "2"                 +;          //02
                cSerie              +;          //03
                cNumDoc             +;          //04
                dDataEmis           +;          //05
                cStatus             +;          //06
                cTipoTomad          +;          //07
                cCnpjTomad          +;          //08
                cOpSimples          +;          //09
                cCodSFed            +;          //10
                cCodser             +;          //11
                nAlqIss             +;          //12
                nValserv            +;          //13
                nValded             +;          //14
                Space(30)           +;          //15
                nValIss             +;          //16
                cIssRet             +;          //17
                dDatCom             +;          //18
                Space(5)            +;          //19
                Replicate("0",15)   +;          //20
                Space(30)           +;          //21
                cDescri             +;          //22
                cQuebra    
                ntotlin += 1  
                cReg := "cReg30"           
    cLinha  += cReg30                        
Endif
If Left((cAlias)->F3_CFO,1) < '5'
    //Registro 40 – Informações sobre o plano de contas da empresa
    cReg40 :=   "40"                +;          //01
                cTipo               +;          //02
                cSerie              +;          //03
                cNumDoc             +;          //04
                dDataEmis           +;          //05
                cStatus             +;          //06
                cTipoTomad          +;          //07
                cCnpjTomad          +;          //08
                cInsTom             +;          //09
                cInscEst            +;          //10
                cNome               +;          //11
                cLogra              +;          //12
                cEndereco           +;          //13
                nNumEnd             +;          //14
                cCompEnd            +;          //15
                cBairro             +;          //16
                cMunicipio          +;          //17
                cEstado             +;          //18
                cCEP                +;          //19
                cTelefone           +;          //20
                cMail               +;          //21
                nTipExServ          +;          //22
                cTipTri             +;          //23
                cCidInSer           +;          //24
                Space(45)           +;          //25
                cOpSimples          +;          //26
                cCodSFed            +;          //27
                cCodser             +;          //28
                nAlqIss             +;          //29
                nValserv            +;          //30
                nValded             +;          //31
                Space(30)           +;          //32
                nValIss             +;          //33
                cIssRet             +;          //34
                dDatCom             +;          //35
                cObra               +;          //36
                Space(15)           +;          //37
                cDescri             +;          //38
                cQuebra                 
                ntotlin += 1
                cReg := "cReg40"
    cLinha  += cReg40     
Endif          
Return 

/*/{Protheus.doc} fRetServ
BUSCA O CÓDIGO DO SERVIÇO DO PRIMEIRO PRODUTO\SERVIÇO DA NOTA FISCAL DE SERVIÇO
@type function
@version 
@author eduardo.vicente
@since 26/10/2020
@param cCodPrd, character, Codigo do Produto\Servico
@param cUf, character, Estado
@param cMun, character, Código do Municipio
@param cCodForn, character, Codigo do Cliente\Fornecedor
@return cCodSMun,character, Código do Serviço Municipal
/*/
Static Function fRetServ(cCodPrd,cUf,cMun,cCodForn,cCodser,cCodSFed)

Local   cConsulta   := ""
Local   cAliasQry   := ""
Local   lMVISSXMUN  := SuperGetMv("MV_ISSXMUN")
Local   lRet        := ""
Default cCodPrd     := ""
Default cUf         := ""
Default cMun        := ""
Default cCodForn    := ""
 
//CHECAGEM INICIAL PARA BUSCAR DA TABELA CE1 - ALIQUOTA DE ISS POR MUNICIPIO 
If lMVISSXMUN 

    cAliasQry := GetNextAlias()

    cConsulta := "SELECT CE1_CODISS,CE1_RMUISS,CE1_CPRISS,CE1_CTOISS FROM "+RetSqlName("CE1")
    cConsulta += " WHERE CE1_FILIAL = '" + xFilial("CE1")            + "'" + CRLF
    cConsulta += "   AND CE1_PROISS = '" + ALLTRIM(cCodPrd)          + "'" + CRLF
    cConsulta += "   AND CE1_ESTISS = '" + ALLTRIM(cUf)              + "'" + CRLF
    cConsulta += "   AND CE1_CMUISS = '" + ALLTRIM(cMun)             + "'" + CRLF
    cConsulta += "   AND CE1_FORISS = '" + ALLTRIM(cCodForn)         + "'" + CRLF
    cConsulta += "   AND D_E_L_E_T_ = ' ' "

    cConsulta := ChangeQuery( cConsulta )

    dbUseArea( .T., "TOPCONN", TcGenQry(,,cConsulta), cAliasQry, .F., .T. )

    If !( cAliasQRY )->( Eof())
        cCodSFed    := PadR(Alltrim(StrTran(( cAliasQRY )->CE1_CODISS,".","")), 4," ") 
        cCodser     := PadR(Alltrim(StrTran(( cAliasQRY )->CE1_CTOISS,".","")), 20," ")
    EndIf

    ( cAliasQRY )->( dbCloseArea() )
EndIf

Return lRet
//-------------------------------------------------------------------
