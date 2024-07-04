#include "PROTHEUS.CH"
#include "PLSMGER.CH"

Static objCENFUNLGP := CENFUNLGP():New()

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLSR618  ?Autor ?Ricardo Berti          ?Data ?30.09.08 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao ?Lista Totais de Usuarios por Grupo/Empresa e por tipo      Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   ?PLSR618                                                    Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠?Uso      ?Generico                                                   Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSR618()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁInterface de impressao                                                ?
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oReport:= ReportDef()
	oReport:PrintDialog()
Else
	PlsR618R3()
EndIf
                                               
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ?
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠?
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠?
╠╠ЁPrograma  ?ReportDefЁAutor  ?Ricardo Berti         ЁData  ?0/09/2008Ё╠?
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠?
╠╠ЁDescri┤┘o ЁA funcao estatica ReportDef devera ser criada para todos os Ё╠?
╠╠?         Ёrelatorios que poderao ser agendados pelo usuario.          Ё╠?
╠╠?         ?                                                           Ё╠?
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠?
╠╠ЁRetorno   ?oExpO1: Objeto do relatorio                                Ё╠?
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠?
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠?
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ?
/*/
Static Function ReportDef()

//Local aOrdem	:= {"Grupo/Empresa + Contrato + Sub-Contrato","Contrato + Sub-Contrato"} // ORDEM 2 NAO FUNCIONA NO R3
Local aOrdem	:= {"Grupo/Empresa + Contrato + Sub-Contrato"}
Local cPerg		:= "PLR618"
Local cTitle	:= "Relatorio de Totais de Usuarios por Grupo/Empresa e por Tipo" // "Relatorio de Totais de Usuarios por Grupo/Empresa e por Tipo"
Local oReport 
Local oSection1 
Local oSection2 
Local oCell         
Local oBreak
Local cAliasBA1 := GetNextAlias()
Local pQuant	:= "@E 9999999"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Variaveis utilizadas para parametros                         ?
//?mv_par01    Tipo Pessoa                                      ?
//?mv_par02    Dt.Ini                               		     ?
//?mv_par03    Dt.Final                                    	 ?
//?mv_par04    Op. de                                       	 ?
//?mv_par05    Op. Ate                                      	 ?
//?mv_par06    Grupo De                            			 ?
//?mv_par07    Grupo Ate                            			 ?
//?mv_par08    Contrato De                            			 ?
//?mv_par09    Contrato Ate                            		 ?
//?mv_par10    SubContrato De                            		 ?
//?mv_par11    SubContrato Ate                            		 ?
//?mv_par12    Imprime totalizador                           	 ?
//?mv_par13    Imprime Grupo/Empresa                            ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCriacao do componente de impressao                                      ?
//?                                                                       ?
//ЁTReport():New                                                           ?
//ЁExpC1 : Nome do relatorio                                               ?
//ЁExpC2 : Titulo                                                          ?
//ЁExpC3 : Pergunte                                                        ?
//ЁExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ?
//ЁExpC5 : Descricao                                                       ?
//?                                                                       ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oReport:=TReport():New("PLSR618",cTitle,cPerg, {|oReport| ReportPrint(oReport,cAliasBA1)},"Este relatorio ira emitir totais de usuarios por Grupo/Empresa e por Tipo")//"Este relatorio ira emitir totais de usuarios por Grupo/Empresa e por Tipo"
oReport:SetTotalInLine(.F.)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCriacao da secao utilizada pelo relatorio                               ?
//?                                                                       ?
//ЁTRSection():New                                                         ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCriacao da celulas da secao do relatorio                                ?
//?                                                                       ?
//ЁTRCell():New                                                            ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

oSection1:= TRSection():New(oReport,"Grupo/Empresa",{"BA1",cAliasBA1},aOrdem)
oSection1:SetHeaderSection(.F.)

TRCell():New(oSection1,"GRUPOEMP","   "," "/*Titulo*/,"@X",45,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:SetNoFilter("BA1")
oSection1:SetReadOnly(.T.)

oSection2:= TRSection():New(oSection1,"Usuarios",{"BA1",cAliasBA1},/*aOrdem*/)
oSection2:SetHeaderPage()
oReport:SetTotalInLine(.F.)
oSection1:SetEditCell(.F.)

TRCell():New(oSection2,"BA1CODEMP"	,"BA1","Grupo"	,    , 6,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"CONTRATO"	,,"Contrato"	,	 ,16,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"SUBCONTR"	,,"SubContrato"	,	 ,13,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"BQCDESC"	,,"Descricao"	,	 ,58,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TOTBL"		,,"Tot.c/Bloq."	,pQuant,,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"ANTES"		,,"Antes"		,pQuant,,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"EXCL"		,,"Excl."		,pQuant,,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"INCL"		,,"Incl."		,pQuant,,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TIT"		,,"Tit."		,pQuant,,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"DEP"		,,"Dep."		,pQuant,,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"EFETIVO"	,,"Efetivo"		,pQuant,,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)


/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ?
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠?
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠?
╠╠ЁPrograma  ЁReportPrin?Autor ?Ricardo Berti         ЁData  ?0/09/2008Ё╠?
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠?
╠╠ЁDescricao ?Lista Totais de Usuarios por Grupo/Empresa e por tipo      Ё╠?
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠?
╠╠ЁRetorno   ЁNenhum                                                      Ё╠?
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠?
╠╠ЁParametrosЁExpO1: Objeto Report do RelatСrio                           Ё╠?
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠?
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠?
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ?
/*/
Static Function ReportPrint(oReport,cAliasBA1)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local aStrucBA1	:= ''
Local cFilUsrBA1:= ''
Local cName		:= ''
Local cSelect	:= ''
Local cSelectUsr:= ''
Local cOrderBy	:= ''
Local cWhere 	:= ''
Local nOrdem    := oReport:Section(1):GetOrder() 
Local cOperad  
Local cGrupEmp
Local cContrat
Local cSubCon  
Local nQtdTit     := 0
Local nQtdDep     := 0
Local nQtdUsu     := 0
Local nQtdTotGer  := 0
Local nQtdAnt     := 0
Local nQtdInc     := 0
Local nQtdExc     := 0                              
Local lGrupEmp	  := .F.
Local nQtdTotTit  := 0
Local nQtdTotDep  := 0
Local nQtdTotUsu  := 0
Local nQtdTotAnt  := 0
Local nQtdTotInc  := 0
Local nQtdTotExc  := 0
Local nQtdTotTot  := 0
Local nX		  := 0

cOrderBy := "%"
If nOrdem == 1
	cOrderBy += "BA1_CODINT,BA1_CODEMP,BA1_CONEMP,BA1_VERCON,BA1_SUBCON,BA1_VERSUB"
Elseif nOrdem == 2
	cOrderBy += "BA1_CODINT,BA1_CONEMP,BA1_VERCON,BA1_SUBCON,BA1_VERSUB"
Endif                          
cOrderBy += "%"

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?
//ЁEsta rotina foi escrita para adicionar no select os campos         ?
//Ёusados no filtro do usuario, quando houver. A rotina acrescenta    ?
//Ёsomente os campos que forem adicionados ao filtro testando         ?
//Ёse os mesmos ja' existem no select.								  ?
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд?   	
cSelect := "BA1_CODINT,BA1_CODEMP,BA1_CONEMP,BA1_SUBCON,BA1_VERCON,BA1_VERSUB,BA1_FILIAL,"+;
	       "BA1_MATRIC,BA1_TIPREG,BA1_NOMUSR,BA1_TIPUSU,BA1_DATINC,BA1_DATBLO"
cFilUsrBA1:= oSection1:GetAdvplExp()  // Obtem filtro do usuario
cSelectUsr := "%"   
If !Empty(cFilUsrBA1)
    aStrucBA1 := BA1->(dbStruct())
	For nX := 1 To BA1->(FCount())
		cName := BA1->(FieldName(nX))
	 	If AllTrim( cName ) $ cFilUsrBA1
      		If aStrucBA1[nX,2] <> "M"
      			If !cName $ cSelect .And. !cName $ cSelectUsr
	        		cSelectUsr += ","+cName
	          	Endif
	       	EndIf
		EndIf
	Next
Endif
cSelectUsr += "%"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFiltragem do relatorio                                                  ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cWhere := '%'
If mv_par01 == 2 // Pessoa Juridica
  cWhere += " AND BA1_CONEMP >= '"+mv_par08+"'" 
  cWhere += " AND BA1_CONEMP <= '"+mv_par09+"'" 
  cWhere += " AND BA1_SUBCON >= '"+mv_par10+"'" 
  cWhere += " AND BA1_SUBCON <= '"+mv_par11+"'" 
  cWhere += " AND BA1_CONEMP <> ''"   
  cWhere += " AND BA1_SUBCON <> ''"     
Elseif mv_par01 == 1 // Pessoa Fisica
  cWhere += " AND BA1_CONEMP = ''"   
  cWhere += " AND BA1_SUBCON = ''"   
Elseif mv_par01 == 3 // Ambas
  cWhere += " AND BA1_CONEMP >= '"+mv_par08+"'" 
  cWhere += " AND BA1_CONEMP <= '"+mv_par09+"'" 
  cWhere += " AND BA1_SUBCON >= '"+mv_par10+"'" 
  cWhere += " AND BA1_SUBCON <= '"+mv_par11+"'" 
Endif                                                  
cWhere += '%'
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁTransforma parametros Range em expressao SQL                            ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
MakeSqlExpr(oReport:uParam)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁQuery do relatorio da secao 1                                           ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oReport:Section(1):BeginQuery()	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁTransforma parametros Range em expressao SQL                            ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
MakeSqlExpr(oReport:uParam)

BeginSql Alias cAliasBA1

	SELECT BA1_CODINT,BA1_CODEMP,BA1_CONEMP,BA1_SUBCON,BA1_VERCON,BA1_VERSUB,BA1_FILIAL,
	       BA1_MATRIC,BA1_TIPREG,BA1_NOMUSR,BA1_TIPUSU,BA1_DATINC,BA1_DATBLO
  		   %Exp:cSelectUsr%

		FROM %table:BA1% BA1
    	
  		    WHERE	BA1_FILIAL = %xFilial:BA1%
			AND BA1_CODINT >= %Exp:mv_par04%
			AND BA1_CODINT <= %Exp:mv_par05% 
			AND BA1_CODEMP >= %Exp:mv_par06% 
			AND BA1_CODEMP <= %Exp:mv_par07% 
			AND BA1_DATINC <= %Exp:Dtos(mv_par03)%
			AND BA1.%NotDel% 
  		    %Exp:cWhere%

		ORDER BY %Exp:cOrderBy%
	
EndSql 
oSection1:EndQuery()
oSection2:SetParentQuery()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Inicio da impressao do Relatorio                                         ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oReport:SetMeter(BA1->(LastRec()))
dbSelectArea(cAliasBA1)

oSection1:Init()

While !oReport:Cancel() .And. !(cAliasBA1)->(Eof()) .And. ;
	(cAliasBA1)->BA1_FILIAL == xFilial("BA1")

	oReport:IncMeter()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //?Verifica se foi abortada a impressao...                            ?
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If oReport:Cancel()
		Exit
	EndIf

	BG9->(DbSetOrder(1))// BG9_CODINT + BG9_CODIGO + BG9_TIPO
    lGrupEmp := BG9->(DbSeek(xFilial("BG9")+(cAliasBA1)->(BA1_CODINT+BA1_CODEMP)))

	If mv_par13 == 1
		If lGrupEmp
			oSection1:Cell("GRUPOEMP"):SetValue((cAliasBA1)->BA1_CODINT+"."+(cAliasBA1)->BA1_CODEMP+" - "+;
						Alltrim(BG9->BG9_DESCRI)+" - "+If(BG9->BG9_TIPO=="2","Pessoa Juridica","Pessoa Fisica"))
			oReport:ThinLine() 
			oSection1:PrintLine()
			oReport:ThinLine() 
   	    Else
			oReport:PrintText("Nao existe Grupo-Empresa: "+;
							(cAliasBA1)->(BA1_CODINT+BA1_CODEMP)+". Verifique.",oReport:Row()+1,10)
			oReport:ThinLine() 
		Endif
	Endif

    oSection2:Init()
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //?Atribuo valor as variaveis de controle...                                ?
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    cOperad  := (cAliasBA1)->BA1_CODINT
    cGrupEmp := (cAliasBA1)->BA1_CODEMP
    nAc := 0

	While !oReport:Cancel() .And. !(cAliasBA1)->(Eof()) .And. (cAliasBA1)->BA1_FILIAL == xFilial("BA1") .And.;
		(cAliasBA1)->BA1_CODINT+(cAliasBA1)->BA1_CODEMP == cOperad+cGrupEmp

        cContrat := (cAliasBA1)->(BA1_CONEMP+BA1_VERCON)
        //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        //?Posiciono no Contrato, se for pessoa juridica...                   ?
        //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ! Empty(cContrat)// Pessoa Juridica
            BT5->(DbSetOrder(1))// BT5_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO
            If ! BT5->(DbSeek(xFilial("BT5")+(cAliasBA1)->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))
				oReport:PrintText("Nao existe Contrato: "+;
				(cAliasBA1)->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)+". Verifique.",oReport:Row()+1,10)
				oReport:ThinLine() 
            Endif
			oSection2:Cell("BQCDESC"):SetValue(BQC->BQC_DESCRI)
        Endif

		While !oReport:Cancel() .And. !(cAliasBA1)->(Eof()) .And. (cAliasBA1)->BA1_FILIAL == xFilial("BA1") .And.;
			(cAliasBA1)->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON) == cOperad+cGrupEmp+cContrat

            cSubCon  := (cAliasBA1)->(BA1_SUBCON+BA1_VERSUB)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //?Posiciono no Sub-Contrato, se for pessoa juridica...                     ?
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If ! Empty(cContrat)// Pessoa Juridica
               BQC->(DbSetOrder(1))// BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
               If ! BQC->(DbSeek(xFilial("BQC")+(cAliasBA1)->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
					oReport:PrintText("Nao existe Sub-Contrato: "+;
					(cAliasBA1)->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)+". Verifique.",oReport:Row()+1,10)
               Endif
            Endif

			While !oReport:Cancel() .And. !(cAliasBA1)->(Eof()) .And. (cAliasBA1)->BA1_FILIAL == xFilial("BA1") .And.;
				(cAliasBA1)->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB) == ;
				cOperad+cGrupEmp+cContrat+cSubCon

               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //?Atribuo valores aos totalizadores...                                     ?
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               // Total de Inclusoes
               If Dtos((cAliasBA1)->BA1_DATINC) >= Dtos(mv_par02) .And. Dtos((cAliasBA1)->BA1_DATINC) <= Dtos(mv_par03)
                  nQtdInc ++ 
               Endif
               // Total de Exclusoes
               If Dtos((cAliasBA1)->BA1_DATBLO) >= Dtos(mv_par02) .And. Dtos((cAliasBA1)->BA1_DATBLO) <= Dtos(mv_par03)
                  nQtdExc ++
               Endif
               // Total de Usuarios Antes
               If  Dtos((cAliasBA1)->BA1_DATINC) < Dtos(mv_par02) .And. Empty((cAliasBA1)->BA1_DATBLO) .Or.;
                  (Dtos((cAliasBA1)->BA1_DATINC) < Dtos(mv_par02) .And. Dtos((cAliasBA1)->BA1_DATBLO) >= Dtos(mv_par02))
                  nQtdAnt ++
               Endif                     
               // Total de Usuarios Efetivos               
               If  Dtos((cAliasBA1)->BA1_DATINC) <= Dtos(mv_par03) .And. Empty((cAliasBA1)->BA1_DATBLO) .Or.;
                  (Dtos((cAliasBA1)->BA1_DATINC) <= Dtos(mv_par03) .And. Dtos((cAliasBA1)->BA1_DATBLO) > Dtos(mv_par03))
                  If (cAliasBA1)->BA1_TIPUSU == "T"
                     nQtdTit ++
                  Elseif (cAliasBA1)->BA1_TIPUSU $ "D,A"
                     nQtdDep ++
                  Endif
                  nQtdUsu ++
               Endif
               nQtdTotGer ++
               (cAliasBA1)->(DbSkip())
            EndDo           
    
			If !Empty(cContrat)
				oSection2:Cell("CONTRATO"):SetValue(Transform(cContrat,"@R XXXXXXXXXXXX-XXX"))
				oSection2:Cell("SUBCONTR"):SetValue(Transform(cSubCon,"@R XXXXXXXXX-XXX"))
				oSection2:Cell("BQCDESC"):SetValue(BQC->BQC_DESCRI)
			Else
				oSection2:Cell("CONTRATO"):SetValue('-')
				oSection2:Cell("SUBCONTR"):SetValue('-')
				oSection2:Cell("BQCDESC"):SetValue(Substr(BG9->BG9_DESCRI,1,40)+" - "+;
											If(BG9->BG9_TIPO=="2","Pessoa Juridica","Pessoa Fisica"))
			EndIf
			oSection2:Cell("BA1CODEMP"):SetValue(cGrupEmp)
			oSection2:Cell("TOTBL"):SetValue(nQtdTotGer)
			oSection2:Cell("ANTES"):SetValue(nQtdAnt)
			oSection2:Cell("EXCL"):SetValue(nQtdExc)
			oSection2:Cell("INCL"):SetValue(nQtdInc)
			oSection2:Cell("TIT"):SetValue(nQtdTit)
			oSection2:Cell("DEP"):SetValue(nQtdDep)
			oSection2:Cell("EFETIVO"):SetValue(nQtdUsu)

			oSection2:PrintLine()

            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //?Acumulo e zero totalizadores...                                          ?
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            nQtdTotTit  += nQtdTit
            nQtdTotDep  += nQtdDep
            nQtdTotUsu  += nQtdUsu
            nQtdTotAnt  += nQtdAnt
            nQtdTotInc  += nQtdInc
            nQtdTotExc  += nQtdExc
			nQtdTotTot  += nQtdTotGer
            nQtdTit     := 0
            nQtdDep     := 0
            nQtdUsu     := 0            
            nQtdAnt     := 0
            nQtdInc     := 0
            nQtdExc     := 0            
            nQtdTotGer  := 0
            nAc++
		Enddo   
	Enddo
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //?Imprime Total do Grupo/Empresa ...                                 ?
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If (! Empty(cContrat) .And. mv_par12 == 1) .Or.; // Imprime Total = SIM e Pessoa Juridica
    	(Empty(cContrat) .And. nAc > 1)				  //  ou Pessoa Fisica e + de 1 linha impressa
		oSection2:Cell("BA1CODEMP"):SetValue("Total")
		oSection2:Cell("CONTRATO"):SetValue(' ')
		oSection2:Cell("SUBCONTR"):SetValue(' ')
		oSection2:Cell("BQCDESC"):SetValue(' ')
		oSection2:Cell("TOTBL"):SetValue(nQtdTotTot)
		oSection2:Cell("ANTES"):SetValue(nQtdTotAnt)
		oSection2:Cell("EXCL"):SetValue(nQtdTotExc)
		oSection2:Cell("INCL"):SetValue(nQtdTotInc)
		oSection2:Cell("TIT"):SetValue(nQtdTotTit)
		oSection2:Cell("DEP"):SetValue(nQtdTotDep)
		oSection2:Cell("EFETIVO"):SetValue(nQtdTotUsu)

		oReport:ThinLine() 
		oSection2:PrintLine()
    Endif
	If mv_par12 == 1
		oReport:SkipLine() 
	EndIf	
    nQtdTotTit  := 0
    nQtdTotDep  := 0
    nQtdTotUsu  := 0             
    nQtdTotAnt  := 0
    nQtdTotInc  := 0
    nQtdTotExc  := 0
    nQtdTotTot  := 0
Enddo

oSection1:Finish()
(cAliasBA1)->(DbCloseArea())

Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLSR618R3?Autor ЁGuilherme Brunoro       ?Data ?21.01.03 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao ?Lista Totais de Usuarios por Grupo/Empresa e por tipo      Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   ?PLSR618                                                    Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠?Uso      ?Advanced Protheus                                          Ё╠╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠?Alteracoes desde sua construcao inicial                               Ё╠╠╠
╠╠цддддддддддбддддддбдддддддддддддбддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠?Data     ?BOPS ?Programador ?Breve Descricao                       Ё╠╠╠
╠╠цддддддддддеддддддедддддддддддддеддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠?16/03/04 ?     ?Brunoro     ?Inclusao do seguinte filtro na query: Ё╠╠╠
╠╠?         ?     ?            ?Elseif nTipPes == 3 // Ambas          Ё╠╠╠
╠╠?16/03/04 ?     ?Brunoro     ?Inclusao dos parametros :             Ё╠╠╠
╠╠?         ?     ?            ?cTotal  Imprime totalizador           Ё╠╠╠
╠╠?         ?     ?            ?cIniCab Inibe cabecalho grupo/empresa Ё╠╠╠
╠╠?16/03/04 ?     ?Brunoro     ?Alteracao das colunas do cabecalho    Ё╠╠╠
╠╠?         ?     ?            ?Coluna "Plano" -> foi retirada        Ё╠╠╠
╠╠?         ?     ?            ?Coluna "Grupo" -> foi incluida        Ё╠╠╠
╠╠?         ?     ?            ?Coluna "Tot.c/ bloq." -> foi incluida Ё╠╠╠
╠╠юддддддддддаддддддадддддддддддддаддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Define nome da funcao                                                    ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Function PLSR618R3()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Define variaveis padroes para todos os relatorios...                     ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE nQtdLin     := 58
PRIVATE nLimite     := 132     
PRIVATE cTamanho    := "M"     
PRIVATE cTitulo     := "Relatorio de Totais de Usuarios por Grupo/Empresa e por Tipo"
PRIVATE cDesc1      := "Este relatorio ira emitir totais de usuarios "
PRIVATE cDesc2      := "por Grupo/Empresa e por Tipo"
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA1"
PRIVATE cPerg       := "PLR618"
PRIVATE cRel        := "PLSR618"
PRIVATE nli         := 00   
PRIVATE m_pag       := 1    
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .T. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {"Grupo/Empresa + Contrato + Sub-Contrato","Contrato + Sub-Contrato"} 
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } 
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "Grupo Contrato         Sub-Contrato  Descricao                              Tot.c/ bloq.  Antes  Excl.  Incl.   Tit.   Dep. Efetivo"
PRIVATE cCabec2     := "" 
PRIVATE nColuna     := 00 
PRIVATE aLinha      := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Dados do parametro...                                                    ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE nTipPes     // (PF;PJ;Ambos)
PRIVATE cDatIni     // Data Referencia Inicial
PRIVATE cDatFin     // Data Referencia Final
PRIVATE cOpeDe      // Codigo da Operadora de
PRIVATE cOpeAte     // Codigo da Operadora ate 
PRIVATE cGrupoDe    // Codigo do Grupo/Empresa de
PRIVATE cGrupoAte   // Codigo do Grupo/Empresa ate
PRIVATE cContrDe    // Codigo do Contrato de
PRIVATE cContrAte   // Codigo do Contrato ate
PRIVATE cSbConDe    // Codigo do Sub-contrato de
PRIVATE cSbConAte   // Codigo do Sub-contrato ate
PRIVATE cTotal      // Imprime totalizador (sim/nao)
PRIVATE cIniCab     // Inibe cabecalho do grupo/empresa (sim/nao)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Testa ambiente do relatorio somente top...                               ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! PLSRelTop()
   Return
Endif    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Chama SetPrint (padrao)                                                  ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)

   aAlias := {"BA1","BG9","BQC"}
	objCENFUNLGP:setAlias(aAlias)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Verifica se foi cancelada a operacao (padrao)                            ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nLastKey  == 27 
   Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Acessa parametros do relatorio...                                        ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)
nTipPes    := mv_par01 
cDatIni    := mv_par02 
cDatFin    := mv_par03 
cOpeDe     := mv_par04 
cOpeAte    := mv_par05 
cGrupoDe   := mv_par06 
cGrupoAte  := mv_par07 
cContrDe   := mv_par08 
cContrAte  := mv_par09 
cSbConDe   := mv_par10
cSbConAte  := mv_par11 
cTotal     := mv_par12 
cIniCab    := mv_par13 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Configura impressora (padrao)                                            ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetDefault(aReturn,cAlias) 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Emite relat╒rio                                                          ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
MsAguarde({|| R618Imp() }, cTitulo, "", .T.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Fim da rotina                                                            ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   ?R618Imp  ?Autor ?Guilherme Brunoro     ?Data ?04.11.02 Ё╠?
╠╠цдддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  ?Imprime detalhe do relatorio...                            Ё╠?
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function R618Imp()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Define variaveis...                                                      ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cSQL
LOCAL nOrdSel       := aReturn[8] 
LOCAL lIniCab       := .T.
LOCAL lGrupEmp		:= .F.
PRIVATE cOperad  
PRIVATE cGrupEmp
PRIVATE cTipo
PRIVATE cContrat
PRIVATE cSubCon  
PRIVATE cMatric
PRIVATE pQuant      := "@E 999999"
PRIVATE nQtdTit     := 0
PRIVATE nQtdDep     := 0
PRIVATE nQtdUsu     := 0
PRIVATE nQtdTotGer  := 0
PRIVATE nQtdTotTit  := 0
PRIVATE nQtdTotDep  := 0
PRIVATE nQtdTotUsu  := 0
PRIVATE nQtdAnt     := 0
PRIVATE nQtdInc     := 0
PRIVATE nQtdExc     := 0                              
PRIVATE nQtdTotAnt  := 0
PRIVATE nQtdTotInc  := 0
PRIVATE nQtdTotExc  := 0
PRIVATE nQtdTotTot  := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Cadastro da Rede de Atendimento...                                       ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE cBA1Name := RetSQLName("BA1")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Exibe mensagem...                                                        ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
MsProcTxt(PLSTR0001) 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Faz filtro no arquivo de Usuarios...                                     ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT BA1_CODINT,BA1_CODEMP,BA1_CONEMP,BA1_SUBCON,BA1_VERCON,BA1_VERSUB,BA1_MATRIC,"
cSQL += "BA1_TIPREG,BA1_NOMUSR,BA1_TIPUSU,BA1_DATINC,BA1_DATBLO "
cSQL += "FROM "+cBA1Name+" "
cSQL += "WHERE "+cBA1Name+".D_E_L_E_T_ = '' AND "
cSQL += "BA1_FILIAL = '"+xFilial("BA1")+"' AND "
cSQL += "BA1_CODINT >= '"+cOpeDe+"' AND         "
cSQL += "BA1_CODINT <= '"+cOpeAte+"' AND        "
cSQL += "BA1_CODEMP >= '"+cGrupoDe+"' AND       " 
cSQL += "BA1_CODEMP <= '"+cGrupoAte+"' AND      "
cSQL += "BA1_DATINC <= '"+Dtos(cDatFin)+"'     "
If nTipPes == 2 // Pessoa Juridica
  cSQL += " AND BA1_CONEMP >= '"+cContrDe+"'    " 
  cSQL += " AND BA1_CONEMP <= '"+cContrAte+"'   " 
  cSQL += " AND BA1_SUBCON >= '"+cSbConDe+"'    " 
  cSQL += " AND BA1_SUBCON <= '"+cSbConAte+"'   " 
  cSQL += " AND BA1_CONEMP <> ''   "   
  cSQL += " AND BA1_SUBCON <> ''   "     
Elseif nTipPes == 1 // Pessoa Fisica
  cSQL += " AND BA1_CONEMP = ''   "   
  cSQL += " AND BA1_SUBCON = ''   "   
Elseif nTipPes == 3 // Ambas
  cSQL += " AND BA1_CONEMP >= '"+cContrDe+"'    " 
  cSQL += " AND BA1_CONEMP <= '"+cContrAte+"'   " 
  cSQL += " AND BA1_SUBCON >= '"+cSbConDe+"'    " 
  cSQL += " AND BA1_SUBCON <= '"+cSbConAte+"'   " 
Endif                                                  
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Se houver filtro executa parse para converter expressoes adv para SQL    ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! Empty(aReturn[7])
   cSQL += " AND (" + PLSParSQL(aReturn[7])+" ) "
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?De acordo com a ordem....                                                ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If      nOrdSel == 1 //codigo
      cSQL += "ORDER BY BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB"  
Elseif   nOrdSel == 2  //nome
      cSQL += "ORDER BY BA1_CODINT+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB"  
Endif                          

PLSQuery(cSQL,"BA1TRB")
BA1TRB->(DbGotop())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Inicio da impressao dos detalhes...                                      ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! BA1TRB->(Eof())
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //?Verifica se foi abortada a impressao...                            ?
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If Interrupcao(lAbortPrint)
         nLi ++
         @ nLi, nColuna pSay PLSTR0002
         Exit
      Endif                       
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //?Imprime cabecalho...                                                     ?
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If lIniCab 
	     R618Cabec()      
         lIniCab := .F.  
      Endif
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //?Posiciono e Imprime grupo/empresa...                               ?
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  BG9->(DbSetOrder(1))// BG9_CODINT + BG9_CODIGO + BG9_TIPO
      lGrupEmp := BG9->(DbSeek(xFilial("BG9")+BA1TRB->(BA1_CODINT+BA1_CODEMP)))	  
      If cIniCab == 1
         If ! lGrupEmp
		      @ ++nLi, nColuna pSay "Nao existe Grupo-Empresa: "+;
                                    objCENFUNLGP:verCamNPR("BA1_CODINT",BA1TRB->BA1_CODINT)+;
                                    objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1TRB->BA1_CODEMP)+". Verifique."
   	     Else
	          @ ++nLi, nColuna pSay  objCENFUNLGP:verCamNPR("BA1_CODINT",BA1TRB->BA1_CODINT)+"."+;
                                    objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1TRB->BA1_CODEMP)+" - "+;
                                    objCENFUNLGP:verCamNPR("BG9_DESCRI",Alltrim(BG9->BG9_DESCRI))+" - "+;    	                         //IIF(!Empty(BA1TRB->(BA1_CONEMP+BA1_VERCON)),"Pessoa Juridica","Pessoa Fisica") //Brunoro;
       		                      IIF(BG9->BG9_TIPO=="2","Pessoa Juridica","Pessoa Fisica")                             
	          @ ++nLi,nColuna pSay Replicate("=",nLimite)
         Endif
      Endif
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //?Atribuo valor as variaveis de controle...                                ?
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      cOperad  := BA1TRB->BA1_CODINT
      cGrupEmp := BA1TRB->BA1_CODEMP
      cContrat := BA1TRB->(BA1_CONEMP+BA1_VERCON)
      cSubCon  := BA1TRB->(BA1_SUBCON+BA1_VERSUB)
	   cTipo    := BG9->BG9_TIPO

      While ! BA1TRB->(Eof()) .And. BA1TRB->(BA1_CODINT+BA1_CODEMP) == cOperad+cGrupEmp
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //?Posiciono no Contrato, se for pessoa juridica...                   ?
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         If ! Empty(cContrat)// Pessoa Juridica
            BT5->(DbSetOrder(1))// BT5_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO
            If ! BT5->(DbSeek(xFilial("BT5")+BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))
               @ ++nLi, nColuna pSay "Nao existe Contrato: "+;
                                       objCENFUNLGP:verCamNPR("BA1_CODINT",BA1TRB->BA1_CODINT)+;
                                       objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1TRB->BA1_CODEMP)+;
                                       objCENFUNLGP:verCamNPR("BA1_CONEMP",BA1TRB->BA1_CONEMP)+;
                                       objCENFUNLGP:verCamNPR("BA1_VERCON",BA1TRB->BA1_VERCON)+". Verifique."
            Endif
         Endif
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //?Atribuo valor as variaveis de controle...                                ?
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         cOperad  := BA1TRB->BA1_CODINT
         cGrupEmp := BA1TRB->BA1_CODEMP
         cContrat := BA1TRB->(BA1_CONEMP+BA1_VERCON)
         cSubCon  := BA1TRB->(BA1_SUBCON+BA1_VERSUB)

         While ! BA1TRB->(Eof()) .And. BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON) == cOperad+cGrupEmp+cContrat
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //?Posiciono no Sub-Contrato, se for pessoa juridica...                     ?
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If ! Empty(cContrat)// Pessoa Juridica
               BQC->(DbSetOrder(1))// BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
               If ! BQC->(DbSeek(xFilial("BQC")+BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
                  @ ++nLi, nColuna pSay "Nao existe Sub-Contrato: "+;
                                          objCENFUNLGP:verCamNPR("BA1_CODINT",BA1TRB->BA1_CODINT)+;
                                          objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1TRB->BA1_CODEMP)+;
                                          objCENFUNLGP:verCamNPR("BA1_CONEMP",BA1TRB->BA1_CONEMP)+;
                                          objCENFUNLGP:verCamNPR("BA1_VERCON",BA1TRB->BA1_VERCON)+;
                                          objCENFUNLGP:verCamNPR("BA1_SUBCON",BA1TRB->BA1_SUBCON)+;
                                          objCENFUNLGP:verCamNPR("BA1_VERSUB",BA1TRB->BA1_VERSUB)+". Verifique."
               Endif
            Endif
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //?Atribuo valor as variaveis de controle...                                ?
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            cOperad  := BA1TRB->BA1_CODINT
            cGrupEmp := BA1TRB->BA1_CODEMP
            cContrat := BA1TRB->(BA1_CONEMP+BA1_VERCON)
            cSubCon  := BA1TRB->(BA1_SUBCON+BA1_VERSUB)

            While ! BA1TRB->(Eof()) .And. BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+;
                                                      BA1_VERSUB) == cOperad+cGrupEmp+cContrat+cSubCon
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //?Exibe mensagem...                                                  ?
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               MsProcTXT("Usuario: "+	objCENFUNLGP:verCamNPR("BA1_CODINT",BA1TRB->BA1_CODINT)+"."+;
										objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1TRB->BA1_CODEMP)+"."+;
										objCENFUNLGP:verCamNPR("BA1_CONEMP",BA1TRB->BA1_CONEMP)+"."+;
										objCENFUNLGP:verCamNPR("BA1_SUBCON",BA1TRB->BA1_SUBCON)+"...")
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //?Atribuo valor as variaveis de controle...                                ?
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               // Total de Inclusoes
               If Dtos(BA1TRB->BA1_DATINC) >= Dtos(cDatIni) .And. Dtos(BA1TRB->BA1_DATINC) <= Dtos(cDatFin)
                  nQtdInc ++ 
               Endif
               // Total de Exclusoes
               If Dtos(BA1TRB->BA1_DATBLO) >= Dtos(cDatIni) .And. Dtos(BA1TRB->BA1_DATBLO) <= Dtos(cDatFin)
                  nQtdExc ++
               Endif
               // Total de Usuarios Antes
               If  Dtos(BA1TRB->BA1_DATINC) < Dtos(cDatIni) .And. Empty(BA1TRB->BA1_DATBLO) .Or.;
                  (Dtos(BA1TRB->BA1_DATINC) < Dtos(cDatIni) .And. Dtos(BA1TRB->BA1_DATBLO) >= Dtos(cDatIni))                  
                  nQtdAnt ++
               Endif                     
               // Total de Usuarios Efetivos               
               If  Dtos(BA1TRB->BA1_DATINC) <= Dtos(cDatFin) .And. Empty(BA1TRB->BA1_DATBLO) .Or.;
                  (Dtos(BA1TRB->BA1_DATINC) <= Dtos(cDatFin) .And. Dtos(BA1TRB->BA1_DATBLO) > Dtos(cDatFin))
                  If BA1TRB->BA1_TIPUSU == "T"
                     nQtdTit ++
                  Elseif BA1TRB->BA1_TIPUSU $ "D,A"
                     nQtdDep ++
                  Endif
                  nQtdUsu ++
               Endif
               
               nQtdTotGer ++
               cOperad  := BA1TRB->BA1_CODINT
               cGrupEmp := BA1TRB->BA1_CODEMP
               cContrat := BA1TRB->(BA1_CONEMP+BA1_VERCON)
               cSubCon  := BA1TRB->(BA1_SUBCON+BA1_VERSUB)
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //?Atribuo valores aos totalizadores...                                     ?
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               BA1TRB->(DbSkip())
            Enddo
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //?verifica proxima pagina...                                         ?
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If nLi > nQtdLin
               R618Cabec()
            Endif 
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //?Imprimo Sub-contrato...                                                  ?
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If ! Empty(cContrat)// Pessoa Juridica            
            @ ++nLi, nColuna pSay   objCENFUNLGP:verCamNPR("BA1_CODEMP",cGrupEmp)+Space(2)+;
                                    objCENFUNLGP:verCamNPR("BA1_CONEMP",objCENFUNLGP:verCamNPR("BA1_VERCON",Substr(cContrat,1,12)))+"-"+;
                                    objCENFUNLGP:verCamNPR("BA1_CONEMP",objCENFUNLGP:verCamNPR("BA1_VERCON",Substr(cContrat,13,3)))+Space(1)+;
                                    objCENFUNLGP:verCamNPR("BA1_SUBCON",objCENFUNLGP:verCamNPR("BA1_VERSUB",Substr(cSubCon,1,9)))+"-"+;
                                    objCENFUNLGP:verCamNPR("BA1_SUBCON",objCENFUNLGP:verCamNPR("BA1_VERSUB",Substr(cSubCon,10,3)))+Space(1)+;
                                    objCENFUNLGP:verCamNPR("BQC_DESCRI",Substr(BQC->BQC_DESCRI,1,40))+Space(1)+;
                                    Transform(nQtdTotGer,pQuant)+Space(2)+;
                                    Transform(nQtdAnt,pQuant)+Space(1)+;
                                    Transform(nQtdExc,pQuant)+Space(1)+;
                                    Transform(nQtdInc,pQuant)+Space(1)+;
                                    Transform(nQtdTit,pQuant)+Space(1)+;
                                    Transform(nQtdDep,pQuant)+Space(2)+;
                                    Transform(nQtdUsu,pQuant)
            Endif
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //?Zero totalizadores...                                                    ?
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            nQtdTotTit  := nQtdTotTit + nQtdTit
            nQtdTotDep  := nQtdTotDep + nQtdDep
            nQtdTotUsu  := nQtdTotUsu + nQtdUsu
            nQtdTotAnt  := nQtdTotAnt + nQtdAnt
            nQtdTotInc  := nQtdTotInc + nQtdInc
            nQtdTotExc  := nQtdTotExc + nQtdExc
			nQtdTotTot  := nQtdTotTot + nQtdTotGer
            nQtdTit     := 0
            nQtdDep     := 0
            nQtdUsu     := 0            
            nQtdAnt     := 0
            nQtdInc     := 0
            nQtdExc     := 0            
            nQtdTotGer  := 0
         Enddo   
      Enddo
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //?Imprime Total do Grupo/Empresa ...                                 ?
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If ! Empty(cContrat) .And. cTotal == 1 // Pessoa Juridica            
         @ ++nLi,nColuna pSay Replicate("-",nLimite)
         @ ++nLi, nColuna pSay "Total:"+Space(72)+Transform(nQtdTotTot,pQuant)+Space(02)+Transform(nQtdTotAnt,pQuant)+Space(01)+;
                             Transform(nQtdTotExc,pQuant)+Space(01)+Transform(nQtdTotInc,pQuant)+Space(01)+;
                             Transform(nQtdTotTit,pQuant)+Space(01)+Transform(nQtdTotDep,pQuant)+Space(02)+;
                             Transform(nQtdTotUsu,pQuant)
      Endif
      If Empty(cContrat) // Pessoa Fisica
 	     @ ++nLi, nColuna pSay cGrupEmp+Space(2)+Substr(BG9->BG9_DESCRI,1,40)+" - "+;
       		                 IIF(BG9->BG9_TIPO=="2","Pessoa Juridica","Pessoa Fisica")+;
 	                         Space(16)+Transform(nQtdTotTot,pQuant)+Space(02)+Transform(nQtdTotAnt,pQuant)+Space(01)+;
                             Transform(nQtdTotExc,pQuant)+Space(01)+Transform(nQtdTotInc,pQuant)+Space(01)+;
                             Transform(nQtdTotTit,pQuant)+Space(01)+Transform(nQtdTotDep,pQuant)+Space(02)+;
                             Transform(nQtdTotUsu,pQuant)
      Endif
      If cIniCab == 1
	     nLi ++
    	 @ ++nLi,nColuna pSay Replicate("=",nLimite)   // Brunoro                          
      Endif
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //?Zero totalizadores...                                                    ?
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      nQtdTotTit  := 0
      nQtdTotDep  := 0
      nQtdTotUsu  := 0             
      nQtdTotAnt  := 0
      nQtdTotInc  := 0
      nQtdTotExc  := 0
      nQtdTotTot  := 0
Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Imprime rodape do relatorio...                                     ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Roda(0,space(10),cTamanho)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Fecha arquivo...                                                   ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA1TRB->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Libera impressao                                                         ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  aReturn[5] == 1 
    Set Printer To
    Ourspool(cRel)
End
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Fim do Relat╒rio                                                         ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   ?R618Cabec ?Autor ?Guilherme Brunoro    ?Data ?04.11.02 Ё╠?
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  ?Imprime Cabecalho                                          Ё╠?
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function R618Cabec()      
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Imprime cabecalho...                                                     ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//?Fim da Rotina...                                                         ?
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return                                                                       
