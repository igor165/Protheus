#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FISR153B.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} FISR202

Relatorio de conferencia Apuração do ICMS Presumido e Efetivo.

@return	Nil

@author ricardo.cavalcante
@since 09/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISR153B()

Local oReport
Local aArea     := GetArea()
Local aFil		:= GetFilial( .F. )
Private cPerg   := ""


If TRepInUse() //Verifica se relatorios personalizaveis esta disponivel
    If Pergunte("FSR153B",.T.)
        // Tratativa para verificar se o UPDDISTR foi executado e o pergunte foi atualizado, porem na versão 12.1.17 o valtype do parametro é C e na Versão 12.1.23 é numerico
        // Dessa forma estamos verificando as 2 situações.
        If (valtype(MV_PAR01) == "C" .and. Len(MV_PAR01) ==  1)  .or. (valtype(MV_PAR01) == "N" .and. (MV_PAR01 == 1 .or. MV_PAR01 == 2))           
            aFil    := GetFilial( .T. )
            oReport := ReportDef(@aFil)
            oReport :PrintDialog()
        Else
            MsgStop(STR0019) //STR0019 //"Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias."
        EndIf

      
	Endif
Else
	Alert(STR0001)  
Endif

RestArea(aArea)	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Impressao do relatorio


@author ricardo.cavalcante
@since 09/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef(aFil)

Local	oReport
Local	oSecDad
Local   c_PULA	:= Chr(13)+Chr(10)
Local   oFunTot1    := Nil
Local   oFunTot2    := Nil
Local   oFunTot3    := Nil
Local   oFunTot4    := Nil
Local   cNomeEmp    := ""
Local   cCNPJEmp    := ""
Local   cNmFil      := ""

Local	cQuery		:= GetNextAlias()

Local 	cTitRel		:= STR0002


oReport := TReport():New("FISR153B",cTitRel,"FISR153B",{|oReport| ReportPrint(oReport,oSecDad,cQuery,@aFil)},cTitRel)


oReport:SetCustomText( {|| GeraCabec(oReport, @cNomeEmp, @cNmFil, @cCNPJEmp ) } ) // Cabeçalho customizado
oReport:lParamPage := .F.
oReport:SetTotalInLine(.F.)
oReport:lHeaderVisible := .T.
oReport:SetLandScape(.T.)
oReport:HideParamPage()
oReport:oPage:SetPaperSize(9) //Folha A4
oReport:SetLineHeight(40)

oSecDad := TRSection():New(oReport,cTitRel,{cQuery},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSecDad:lHeaderVisible := .F.
oSecDad:SetHeaderSection(.T.)
oSecDad:SetHeaderPage(.F.)//Se estiver ativo (.T.) o cabeçalho não aparece as bordas das células
oSecDad:SetPageBreak(.T.)
oSecDad:SetLinesBefore(1)

TRCell():New(oSecDad,"F2_FILIAL"	,cQuery,STR0003 ,PesqPict("SF2","F2_FILIAL")    ,TamSx3("F2_FILIAL")[1]  	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER"	,,"CENTER",,,.T.,,,) //STR0013 //"Filial"
TRCell():New(oSecDad,"F2_EMISSAO"	,cQuery,STR0004 ,PesqPict("SF2","F2_EMISSAO")   ,TamSx3("F2_EMISSAO")[1]+2  ,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER"	,,"CENTER",,,.T.,,,) //STR0002 //"Data da Operação ou prestação"
TRCell():New(oSecDad,"F2_DOC"	    ,cQuery,STR0005 ,PesqPict("SF2","F2_DOC")       ,TamSx3("F2_DOC")[1]     	,/*lPixel*/,/*{|| code-block de impressao }*/,			,,"CENTER",,,.T.,,,) //STR0003 //"Número(s) do(s) documento(s) fiscal(is) "
TRCell():New(oSecDad,"F2_VALBRUT"	,cQuery,STR0006 ,PesqPict("SF2","F2_VALBRUT")   ,TamSx3("F2_VALBRUT")[1]   	,/*lPixel*/,/*{|| code-block de impressao }*/,			,,"CENTER",,,.T.,,,) //STR0004 //"Valor total"
TRCell():New(oSecDad,"QTDPARC"	    ,cQuery,STR0007 ,PesqPict("SE1","E1_PARCELA")   ,TamSx3("E1_PARCELA")[1]+6	,/*lPixel*/,/*{|| code-block de impressao }*/,			,,"CENTER",,,.T.,,,) //STR0005 //"Quantidade de parcelas"
TRCell():New(oSecDad,"PARCELA"	    ,cQuery,STR0008 ,PesqPict("SE1","E1_PARCELA")   ,TamSx3("E1_PARCELA")[1]+6	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER"	,,"CENTER",,,.T.,,,) //STR0006 //"Número da parcela"
TRCell():New(oSecDad,"VLTITULO"	    ,cQuery,STR0009 ,PesqPict("SE1","E1_VALOR")	    ,TamSx3("E1_VALOR")[1] 		,/*lPixel*/,/*{|| code-block de impressao }*/,			,,"CENTER",,,.T.,,,) //STR0007 //"Valor da parcela"
TRCell():New(oSecDad,"VENCIMENTO"	,cQuery,STR0010 ,PesqPict("SE1","E1_VENCTO")    ,TamSx3("E1_VENCTO")[1]+2 	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER"	,,"CENTER",,,.T.,,,) //STR0008 //"Data do vencimento"
TRCell():New(oSecDad,"BAIXA"	    ,cQuery,STR0011 ,PesqPict("FK1","FK1_DATA")     ,TamSx3("FK1_DATA")[1]+2   	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER"	,,"CENTER",,,.T.,,,) //STR0009 //"Data do recebimento"
TRCell():New(oSecDad,"VLPAGTO"	    ,cQuery,STR0012 ,PesqPict("FK1","FK1_VALOR")    ,TamSx3("FK1_VALOR")[1]  	,/*lPixel*/,/*{|| code-block de impressao }*/,			,,"CENTER",,,.T.,,,) //STR0010 //"Valor pago"
TRCell():New(oSecDad,"SALDO"	    ,cQuery,STR0013 ,PesqPict("SE1","E1_SALDO")     ,TamSx3("E1_SALDO")[1]    	,/*lPixel*/,/*{|| code-block de impressao }*/,			,,"CENTER",,,.T.,,,) //STR0011 //"Saldo a receber"
TRCell():New(oSecDad,"PARCIAL"	    ,cQuery,""      ,"!@"                           ,3                         	,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER"	,,"CENTER",,,.T.,,,) //STR0009 //"Data do recebimento"
TRCell():New(oSecDad,"INCOBRAVEL"	,cQuery,STR0014 ,PesqPict("SE1","E1_VALOR")     ,TamSx3("E1_VALOR")[1]    	,/*lPixel*/,/*{|| code-block de impressao }*/,			,,"CENTER",,,.T.,,,) //STR0012 //"Valor considerado incobrável"
TRCell():New(oSecDad,"SALDOMIN"	    ,cQuery,STR0015 ,"!@"                           ,TamSx3("E1_VALOR")[1]    	,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT"	,,"CENTER",,,.T.,,,) //STR0012 //"Valor considerado incobrável"

//Bordas Cabeçalho Esquerda
oSecDad:Cell("F2_FILIAL"):SetBorder(3,1,,.T.) 

//Bordas Cabeçalho Superior
oSecDad:Cell("F2_FILIAL"):SetBorder(1,1,,.T.) 
oSecDad:Cell("F2_EMISSAO"):SetBorder(1,1,,.T.) 
oSecDad:Cell("F2_DOC"):SetBorder(1,1,,.T.) 
oSecDad:Cell("F2_VALBRUT"):SetBorder(1,1,,.T.) 
oSecDad:Cell("QTDPARC"):SetBorder(1,1,,.T.) 
oSecDad:Cell("PARCELA"):SetBorder(1,1,,.T.) 
oSecDad:Cell("VLTITULO"):SetBorder(1,1,,.T.)
oSecDad:Cell("VENCIMENTO"):SetBorder(1,1,,.T.) 
oSecDad:Cell("BAIXA"):SetBorder(1,1,,.T.) 
oSecDad:Cell("VLPAGTO"):SetBorder(1,1,,.T.) 
oSecDad:Cell("SALDO"):SetBorder(1,1,,.T.) 
oSecDad:Cell("PARCIAL"):SetBorder(1,1,,.T.) 
oSecDad:Cell("INCOBRAVEL"):SetBorder(1,1,,.T.) 
oSecDad:Cell("SALDOMIN"):SetBorder(1,1,,.T.)

//Bordas Cabeçalho Direita
oSecDad:Cell("F2_FILIAL"):SetBorder(4,1,,.T.) 
oSecDad:Cell("F2_EMISSAO"):SetBorder(4,1,,.T.) 
oSecDad:Cell("F2_DOC"):SetBorder(4,1,,.T.) 
oSecDad:Cell("F2_VALBRUT"):SetBorder(4,1,,.T.) 
oSecDad:Cell("QTDPARC"):SetBorder(4,1,,.T.) 
oSecDad:Cell("PARCELA"):SetBorder(4,1,,.T.) 
oSecDad:Cell("VLTITULO"):SetBorder(4,1,,.T.)
oSecDad:Cell("VENCIMENTO"):SetBorder(4,1,,.T.)
oSecDad:Cell("BAIXA"):SetBorder(4,1,,.T.) 
oSecDad:Cell("VLPAGTO"):SetBorder(4,1,,.T.) 
//oSecDad:Cell("SALDO"):SetBorder(4,1,,.T.) 
oSecDad:Cell("PARCIAL"):SetBorder(4,1,,.T.) 
oSecDad:Cell("INCOBRAVEL"):SetBorder(4,1,,.T.) 
oSecDad:Cell("SALDOMIN"):SetBorder(4,1,,.T.)

//Bordas Cabeçalho Inferior
oSecDad:Cell("F2_FILIAL"):SetBorder(2,1,,.T.) 
oSecDad:Cell("F2_EMISSAO"):SetBorder(2,1,,.T.) 
oSecDad:Cell("F2_DOC"):SetBorder(2,1,,.T.) 
oSecDad:Cell("F2_VALBRUT"):SetBorder(2,1,,.T.) 
oSecDad:Cell("QTDPARC"):SetBorder(2,1,,.T.) 
oSecDad:Cell("PARCELA"):SetBorder(2,1,,.T.) 
oSecDad:Cell("VLTITULO"):SetBorder(2,1,,.T.)
oSecDad:Cell("VENCIMENTO"):SetBorder(2,1,,.T.)
oSecDad:Cell("BAIXA"):SetBorder(2,1,,.T.) 
oSecDad:Cell("VLPAGTO"):SetBorder(2,1,,.T.) 
oSecDad:Cell("SALDO"):SetBorder(2,1,,.T.) 
oSecDad:Cell("PARCIAL"):SetBorder(2,1,,.T.)  
oSecDad:Cell("INCOBRAVEL"):SetBorder(2,1,,.T.) 
oSecDad:Cell("SALDOMIN"):SetBorder(2,1,,.T.)



//Borda Linhas Esquerda
oSecDad:Cell("F2_FILIAL"):SetBorder(3,1,,.F.) 
//Bordas Linhas Direita
oSecDad:Cell("F2_FILIAL"):SetBorder(4,1,,.F.) 
oSecDad:Cell("F2_EMISSAO"):SetBorder(4,1,,.F.) 
oSecDad:Cell("F2_DOC"):SetBorder(4,1,,.F.)
oSecDad:Cell("F2_VALBRUT"):SetBorder(4,1,,.F.)
oSecDad:Cell("QTDPARC"):SetBorder(4,1,,.F.)
oSecDad:Cell("PARCELA"):SetBorder(4,1,,.F.)
oSecDad:Cell("VLTITULO"):SetBorder(4,1,,.F.)
oSecDad:Cell("VENCIMENTO"):SetBorder(4,1,,.F.)
oSecDad:Cell("BAIXA"):SetBorder(4,1,,.F.)
oSecDad:Cell("VLPAGTO"):SetBorder(4,1,,.F.)
//oSecDad:Cell("SALDO"):SetBorder(4,1,,.F.)
oSecDad:Cell("PARCIAL"):SetBorder(4,1,,.F.) 
oSecDad:Cell("INCOBRAVEL"):SetBorder(4,1,,.F.)
oSecDad:Cell("SALDOMIN"):SetBorder(4,1,,.F.) 

//Totalizadores
	oFunTot1 := TRFunction():New(oSecDad:Cell("SALDOMIN"),,"SUM",,,PesqPict("SE1","E1_VALOR"))
	oFunTot1:SetEndReport(.T.)
	
Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressao do relatorio

@return Nil

@author ricardo.cavalcante
@since 09/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,oSecDad,cQuery,aFil)

//Local aArea   := GetArea()
Local cSelect	    := ""
Local cFrom         := ""
Local cInner        := ""
Local cWhere        := ""
Local cOrder        := ""
Local oRegCxSimpTB 
Local cNomeTB       := RegCxSimp(@oRegCxSimpTB,@aFil)// retorna o nome da tabela
Local dInRegCx      := SuperGetMV("MV_DTMREG",.F.,cToD("//"))//Data de Início do regime de caixa

  
//Pegando as seções do relatório
oSecDad := oReport:Section(1)

cSelect := "SF2.F2_FILIAL,SF2.F2_EMISSAO,SF2.F2_DOC,SF2.F2_VALBRUT,FIN.QTDPARC,FIN.PARCELA,FIN.VLTITULO,FIN.VENCIMENTO,FIN.BAIXA,FIN.VLPAGTO,FIN.SALDO,FIN.INCOBRAVEL,"
cSelect += "(SELECT MIN(SALDO) FROM "+ cNomeTB+" WHERE NUMERO = FIN.NUMERO AND PARCELA = FIN.PARCELA AND VLTITULO = FIN.VLTITULO ) AS SALDOMIN,"
cSelect += "(SELECT COUNT(SALDO) FROM "+ cNomeTB+" WHERE NUMERO = FIN.NUMERO AND PARCELA = FIN.PARCELA AND VLTITULO = FIN.VLTITULO ) AS SALDONUM"
cFrom   := RetSqlName("SF2") + " SF2 "
cInner  := cNomeTB + " FIN ON( SF2.F2_FILIAL = FIN.FILIAL AND SF2.F2_DOC = FIN.NUMERO AND SF2.F2_CLIENTE = FIN.CLIENTE AND SF2.F2_LOJA = FIN.LOJA ) "
cWhere  := "SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "

If !Empty(dInRegCx)

    cWhere  += "SF2.F2_EMISSAO >= '" + DtoS(dInRegCx) + "' AND "
EndIf

cWhere  += "SF2.D_E_L_E_T_ = ' ' " 
cOrder  := "SF2.F2_FILIAL, SF2.F2_EMISSAO, SF2.F2_DOC, FIN.PARCELA  "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cInner  := "%" + cInner  + "%"
cWhere  := "%" + cWhere  + "%"
cOrder	:= '%' + cOrder  + '%'

oSecDad:BeginQuery()

BeginSql Alias cQuery
    
    COLUMN F2_EMISSAO   AS DATE
    COLUMN VENCIMENTO   AS DATE
    COLUMN BAIXA        AS DATE
    	
    SELECT %Exp:cSelect%
	FROM   %Exp:cFrom% 
	INNER JOIN %Exp:cInner% 
	WHERE  %Exp:cWhere%
    Order by %Exp:cOrder%
EndSQL

oSecDad:EndQuery()
oReport:SetMeter((cQuery)->(RecCount()))
oSecDad:Init()
While !oReport:Cancel() .And. !(cQuery)->(Eof())
    
	If (cQuery)->SALDONUM > 1
        
        oSecDad:Cell("PARCIAL"):SetValue("(*)")
    Else

        oSecDad:Cell("PARCIAL"):SetValue("")
    Endif
    
    If (cQuery)->SALDOMIN <> (cQuery)->SALDO

        //Se não for o saldo atual do título deixa o campo em branco, para títulos com baixa parcial
        oSecDad:Cell("SALDOMIN"):SeTPicture("!@")
        oSecDad:Cell("SALDOMIN"):SetValue("")
         //Imprimindo a linha atual
   	    oSecDad:PrintLine()
    Else    

        //Se for o saldo atual do título, imprime o saldo para todos títulos e na ultima baixa para títulos com baixa parcial 
        oSecDad:Cell("SALDOMIN"):SeTPicture(PesqPict("SE1","E1_VALOR"))
        oSecDad:Cell("SALDOMIN"):SetValue((cQuery)->SALDOMIN)
         //Imprimindo a linha atual
   	    oSecDad:PrintLine()
         // imprime linha para fechar esse título  
        oReport:ThinLine()
    EndIf 
     
    
    //oReport:ThinLine()			
	(cQuery)->(dbSkip())
	oReport:IncMeter()
    
EndDo

    
(cQuery)->(dbCloseArea())
oSecDad:Finish()
oReport:Say(oReport:Row()+150,10,STR0016)
oReport:Say(oReport:Row()+100,10,STR0017)  
oSecDad:SetPageBreak(.T.)

//---------------------------------
//Exclui a tabela 
//---------------------------------
oRegCxSimpTB:Delete() 
Return

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 

Funcão para criar e retornar a tabela para gravação do Financeiro com as informaçõ de títulos em aberto do Regime de Caixa do SImples Ncaional.


@Author	ricardo.cavalcante
@since	09/04/2019
/*/
//-----------------------------------------------------------------------------------------------------

Function RegCxSimp(oRegCxSimpTB,aFil)

Local aArea         := GetArea()
Local cAlias        := GetNextAlias()
Local aCampos	    := {}
Local aTam     	    := {}
Local cNome         := ''
Local nPos          := ''
Local aFilial       := {}


//-------------------
//Criação do objeto
//-------------------
oRegCxSimpTB := FWTemporaryTable():New(cAlias)

//--------------------------
//Monta os campos da tabela
//--------------------------
aCampos := {}
aTam:=TamSX3("E1_FILIAL")
AADD(aCampos,{"FILIAL"      ,   "C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_PREFIXO")
AADD(aCampos,{"PREFIXO"     ,   "C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_NUM")
AADD(aCampos,{"NUMERO"      ,   "C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_PARCELA")
AADD(aCampos,{"PARCELA"     ,   "C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_TIPO")
AADD(aCampos,{"TIPO"        ,   "C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_CLIENTE")
AADD(aCampos,{"CLIENTE"     ,   "C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_LOJA")
AADD(aCampos,{"LOJA"        ,   "C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_EMISSAO")
AADD(aCampos,{"EMISSAO"     ,   "D",8,0})
aTam:=TamSX3("E1_VENCTO")
AADD(aCampos,{"VENCIMENTO"  ,   "D",8,0})
aTam:=TamSX3("E1_VALOR")
AADD(aCampos,{"VLTITULO"    ,   "N",aTam[1],aTam[2]})
aTam:=TamSX3("FK1_DATA")
AADD(aCampos,{"BAIXA"       ,   "D",8,0})
aTam:=TamSX3("E1_SALDO")
AADD(aCampos,{"SALDO"       ,   "N",aTam[1],aTam[2]})
aTam:=TamSX3("FK1_VALOR")
AADD(aCampos,{"VLPAGTO"     ,   "N",aTam[1],aTam[2]})
aTam:=TamSX3("E1_VALOR")
AADD(aCampos,{"INCOBRAVEL"  ,   "N",aTam[1],aTam[2]})
aTam:=TamSX3("E1_PARCELA")
AADD(aCampos,{"QTDPARC"     ,   "N",3,0})
aTam:=TamSX3("E1_ORIGEM")
AADD(aCampos,{"ORIGEM"      ,   "C",aTam[1],aTam[2]})
aTam:=TamSX3("FK1_SEQ")
AADD(aCampos,{"SEQBAIXA"    ,   "C",aTam[1],aTam[2]})

oRegCxSimpTB:SetFields( aCampos )
oRegCxSimpTB:AddIndex("indice1", {"FILIAL", "PREFIXO" } )

//------------------
//Criação da tabela
//------------------
oRegCxSimpTB:Create()

cNome := oRegCxSimpTB:GetRealName()
RestArea(aArea)

For nPos:=1 to Len(aFil)

    AADD(aFilial,cValToChar(aFil[nPos][2])) 
            
Next       


FinCxSimp(cAlias,aFilial) //Gerar dados na tabela RegCxSimpTB

Return (cNome)

//------------------------------------------------------------------
/*/{Protheus.doc} GetFilial

Função que fará tratamento das filiais selecionadas pelo usuário, e que 
serão consideradas na apuração

@author ricardo.cavalcante
@since 11/04/2019
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function GetFilial( lPergunta )

Local aFil	:= {}
Local aSM0	:= {}
Local aAreaSM0	:= {}
Local nFil	:= 0


//lpergunrta indica se deverá ser exibda a tela para o usuário selecionar quais filiais deverão ser processadas
//Se lPergunta estiver .F., a função retornará todas as filiais da empresa sem exibir a tela para usuário.
If lPergunta

	If mv_par01 == 1
		//chama função para usuário escolher filial
		aFil:= MatFilCalc( .T. )
		If len(aFil) ==0
			MsgAlert(STR0018)
		EndiF
	EndIF

Else
	
	aFil:= MatFilCalc( .F. )

EndIF

IF lPergunta .AND. mv_par01 <> 1
	//Adiciona filial logada para realizar o processamento
	AADD(aFil,{.T.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_CGC})
EndIF

IF  Len(aFil) > 0

	aAreaSM0 := SM0->(GetArea())
	DbSelectArea("SM0")
	//--------------------------------------------------------
	//Irá preencher aSM0 somente com as filiais selecionadas
	//pelo cliente
	//--------------------------------------------------------

	SM0->(DbGoTop())
	If SM0->(MsSeek(cEmpAnt))
		Do While !SM0->(Eof())
			nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
			If nFil > 0 .And. (aFil[nFil][1] .OR. !lPergunta) .AND. cEmpAnt == SM0->M0_CODIGO
				Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
			EndIf
			SM0->(dbSkip())
		Enddo
	EndIf

	SM0->(RestArea(aAreaSM0))
EndIF

Return  aSM0

/*/{Protheus.doc} GeraCabec
//Cabecalho customizado do report
@author ricardo.cavalcante
@since 22/04/2019
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function GeraCabec(oReport, cNmEmp , cNmFilial, cCNPJEmp)
    Local aCabec := {}
    Local cChar     := CHR(160)  // caracter dummy para alinhamento do cabeçalho

    If SM0->(Eof())
        SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
    Endif

    cNmEmp      := AllTrim( SM0->M0_NOME )
    cNmFilial   := AllTrim( SM0->M0_FILIAL )
    cCNPJEmp    := AllTrim( SM0->M0_CGC )

    // Linha 1
    AADD(aCabec, "__LOGOEMP__") // Esquerda

    // Linha 2 
    AADD(aCabec, cChar) //Esquerda
    aCabec[2] += Space(9) // Meio
    aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

    // Linha 3
    AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
    aCabec[3] += Space(9) + oReport:cRealTitle // Meio
    aCabec[3] += Space(9) + "Dt.Ref:" +": " + Dtoc(dDataBase)   // Direita //"Dt.Ref:"

    // Linha 4
    AADD(aCabec, RptHora + oReport:cTime) //Esquerda
    aCabec[4] += Space(9) // Meio
    aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

    // Linha 5
    AADD(aCabec, "Epresa : " + cNmEmp) //Esquerda //"Empresa"
    aCabec[5] += Space(9) // Meio

    // Linha 6
    AADD(aCabec, "CNPJ   : " + cCNPJEmp) //Esquerda //"Empresa"
    aCabec[5] += Space(9) // Meio

Return aCabec
