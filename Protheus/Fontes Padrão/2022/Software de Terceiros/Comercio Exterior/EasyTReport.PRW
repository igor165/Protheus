#INCLUDE "Average.ch"
#INCLUDE "TOPCONN.CH"

/*============================================================*
Classe    : EasyTReport
Parametro : -
Retorno   : -
Objetivo  : Imprimir Relatórios gerados pela ferramenta Protheus Report
By        : Allan Oliveira Monteiro
Data      : 09/02/2012
Revisão   :
Obs       : -
*=============================================================*/

Function EasyTReport()
Return Nil

********************************
Class EasyTReport From AvObject
********************************

   Data oReport
   Data cNameFunc
   Data oXML
   Data cBreak

   Method New(oXML,cName,lShowMsg)           //Metodo Inicializador
   Method XmlToTrReport()                    //Metodo instância TREPORT
   Method XmlToTrSection(oXMLSec,oParent)    //Metodo instância TRSECTION
   Method XmlToTrCell(oXMLCell,oSecao)       //Metodo instância TRCELL
   Method ValidXml()                         //Verifica se objeto oXML é xml valido
   Method PrintReport()                      //Impressao do Relatório
   Method XmlRelation(oSecao,oXMLSec)        //Metodo para contruir a Relação das Tabelas
   Method XmlUserFilter(oSecao,oXMLSec)      //Monta o filtro especificado no Xml
   Method XmlSectionRelation(oSecao,oXMLSec) //Executa o Filtro e a Relaçao no Xml
   Method XmlVerifNode(oXMLSec,cNode)        //Verifica se o Nó passa existe no Xml
   Method EasyConvExp(cAlias,cExp,lAlias)    //Converte expressão em String
   Method XmlToTrBreak(oSecao)               //Methodo instância TRBREAK
   Method RetOReport()                       //Retorna Objeto oReport


End Class



*------------------------------------------*
Method New(cName,lShowMsg) Class EasyTReport
*------------------------------------------*
Default lShowMsg := .T.

   //Herança
   _Super:New()

   //Inicializador
   Self:cNameFunc := cName

   //metodo da Classe AvObjet para indicar a Classe
   Self:SetClassName("EasyTReport")

   //Valida o XML
   If Self:ValidXml()
      //Cria instancia do TREPORT
      Self:XmlToTrReport()
   EndIf

   //Imprime os Erros/Warnings
   If lShowMsg
      Self:ShowErrors(.T.)
   EndIf

Return Self

*-------------------------------------*
Method PrintReport() Class EasyTReport
*-------------------------------------*

If !Self:lError

   If Pergunte( Self:oReport:uParam) .Or. Empty( Self:oReport:uParam)//FSY - 23/11/2012 - Alterado para aceitar relatorio sem o pergunte que é chamado no XRP.
      Self:oReport:PrintDialog()
   EndIf

EndIf

Return


*--------------------------------------*
Method ValidXml() Class EasyTReport
*--------------------------------------*
Local lRet := .T.
Local cError   := ""
Local cWarning := ""
Local cAPH     := "H_"+Self:cNameFunc+"()"


    If FindFunction(cAPH)
       Self:oXML      := &(cAPH)
    Else
       Self:Error("A função " + cAPH + ".APH responsavel pela impressão do Relatório não está no Repositório Atual. Não será possivel a impressão do Relatório.")
       lRet := .F.
    EndIf

    //Converte o arquivo recebido em objeto XML
    If ValType(Self:oXML) <> "O" .And. ValType(Self:oXML) <> "U"
       Self:oXML := XmlParser( Self:oXML, "_", @cError , @cWarning )
    EndIf

    //Set nos Erros Encontrados
    If ValType(Self:oXML) <> "O"
	   Self:Error("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
       lRet := .F.
    Endif


Return lRet

*-------------------------------------------*
Method XmlToTrReport() Class EasyTReport
*-------------------------------------------*
Local aSecoes := {}
Local oXMLSec , oParent
Local nPos := 0
Local cSecao, i, cParent


                               //cReport         ,cTitle                          ,uParam                             ,bAction                              ,cDescription                        ,lLandscape,uTotalText ,lTotalInLine,cPageTText,lPageTInLine,lTPageBreak,nColSpace
Self:oReport := TREport():New(Self:cNameFunc     ,Self:oXML:_TREPORT:_cTitle:TEXT ,Self:oXML:_TREPORT:_cPergunte:TEXT ,{|oReport| __PRPrint(oReport)}       ,Self:oXML:_TREPORT:_cTitle:TEXT     ,          ,           ,            ,          ,            ,           ,&(Self:oXML:_TREPORT:_nColSpace:TEXT)  )

/**************** INICIO ATRIBUTOS/METODOS CLASSE TREPORT  ****************/

//Origem

//Define se os totalizadores serão impressos em linha ou coluna.
Self:oReport:SetTotalInLine(.F.)

//Define os parâmetros que serão utilizados pelo usuário.
Self:oReport:SetParam(Self:oXML:_TREPORT:_cPergunte:TEXT)

//Carrega os filtros
Pergunte( Self:oReport:uParam,.F.)

//Define a altura da linha na impressão.
Self:oReport:SetLineHeight(&(Self:oXML:_TREPORT:_nLineHeight:TEXT))

//Define a margem à esquerda do relatório.
Self:oReport:SetLeftMargin(&(Self:oXML:_TREPORT:_nLeftMargin:TEXT))

//Define o número da página atual
Self:oReport:oPage:SetPageNumber(&(Self:oXML:_TREPORT:_nPageIni:TEXT))

//Fonte definida para impressão do relatório.
Self:oReport:cFontBody := Self:oXML:_TREPORT:_cFontBody:TEXT

//Tamanho da fonte definida para impressão do relatório.
Self:oReport:nFontBody := &(Self:oXML:_TREPORT:_cFontSize:TEXT)

//Aponta que as Informações serão impressas em negrito.
Self:oReport:lBold := &(Self:oXML:_TREPORT:_lBold:TEXT)

//Aponta que as Informações serão impressas sublinhadas.
Self:oReport:lUnderLine := &(Self:oXML:_TREPORT:_lUnderLine:TEXT)

//Habilita a impressão do cabeçalho.
Self:oReport:lHeaderVisible := &(Self:oXML:_TREPORT:_lHeaderVisible:TEXT)

//Habilita a impressão do rodapé.
Self:oReport:lFooterVisible := &(Self:oXML:_TREPORT:_lFooterVisible:TEXT)

//Existe parâmetros para impressão.
Self:oReport:lParamPage := &(Self:oXML:_TREPORT:_lParamPage:TEXT)

/**************** FIM  ATRIBUTOS/METODOS CLASSE TREPORT  ****************/

For i := 1 To XmlChildCount(Self:oXML:_TREPORT:_aSection )
   oXMLSec := XmlGetchild( Self:oXML:_TREPORT:_aSection  , i)

   cSecao := Left(oXMLSec:REALNAME,Len(oXMLSec:REALNAME)-2)

   If (nPos := aScan(aSecoes,{|X| AllTrim(X[1]) == AllTrim(cSecao)}))  > 0
      oParent := aSecoes[nPos][2]
   Else
      oParent := Self:oReport
   EndIf

   aAdd(aSecoes,{oXMLSec:REALNAME,Self:XmlToTrSection(oXMLSec,oParent)})
Next


Return


*----------------------------------------------------------------*
Method XmlToTrSection(oXMLSec,oParent) Class EasyTReport
*----------------------------------------------------------------*
Local oSecao, i
Local cTabela   := ""
Local cPrefixoD := ""
Local cTabPrinc := ""
Local cTabAux   := ""
Local aTabelas := {}
//Local aOrder   := {}
Local aCell    := {}
Local lPassou  := .F.

cTabela := oXMLSec:_cTabela:TEXT
While !Empty(cTabela) .And. AllTrim(cTabela) <> ";"
   cTabAux := SUBSTR(cTabela ,1,AT(";",cTabela )-1)
   If !lPassou
      cTabPrinc  := cTabAux
      cPrefixoD  := Upper(IF(Left(cTabPrinc,1) == "S",Right(cTabPrinc,2),Right(cTabPrinc,3)))
      lPassou    := .T.
   EndIf
   If !Empty(cTabAux)
      AADD(aTabelas,cTabAux)
   Else
      cTabela := ""
   EndIf
   cTabela  := SUBSTR(cTabela,AT(";",cTabela)+1,LEN(cTabela) - AT(";",cTabela)+1)
EndDo

//Variavel que adiciona as quebras
Self:cBreak := ""

                        //oParent,cTitle              ,uTable  ,aOrder  ,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage                   ,lHeaderBreak                  ,lPageBreak                  ,lLineBreak                   ,nLeftMargin                  ,lLineStyle                    ,nColSpace                   ,lAutoSize                   ,cCharSeparator,nLinesBefore                  ,nCols                  ,nClrBack                  ,nClrFore                  ,nPercentage
oSecao := TRSECTION():New(oParent,oXMLSec:_cTitle:TEXT,aTabelas,        ,          ,          ,          ,            ,&(oXMLSec:_lHeaderPage:TEXT)  ,&(oXMLSec:_lHeaderBreak:TEXT) ,&(oXMLSec:_lPageBreak:TEXT) ,&(oXMLSec:_lLineBreak:TEXT)  ,&(oXMLSec:_nLeftMargin:TEXT) ,&(oXMLSec:_lLineStyle:TEXT)   ,&(oXMLSec:_nColSpace:TEXT)  ,&(oXMLSec:_lAutoSize:TEXT)  ,              ,&(oXMLSec:_nLinesBefore:TEXT) ,&(oXMLSec:_nCols:TEXT) ,&(oXMLSec:_nClrBack:TEXT) ,&(oXMLSec:_nClrFore:TEXT) ,            )
/**************** INICIO ATRIBUTOS/METODOS CLASSE TRSECTION  ****************/

//Define se os totalizadores serão impressos em linha ou coluna.
oSecao:SetTotalInLine(.F.)

//Define o texto que será impresso antes da impressão dos totalizadores.
oSecao:SetTotalText(SUBSTR(oXMLSec:_cTitle:TEXT,1,30))

//Aponta que a seção será impressa na personalização do usuário
oSecao:lUserVisible := &(oXMLSec:_lUserVisible:TEXT)        `

//Habilita a impressão do cabeçalho.
oSecao:lHeaderVisible := &(oXMLSec:_lHeaderVisible:TEXT)

//Define a altura da linha na impressão.
oSecao:SetLineHeight(&(oXMLSec:_nLineHeight:TEXT))

//Define que imprime cabeçalho das células na quebra de seção.
oSecao:SetHeaderSection(&(oXMLSec:_lHeaderSection:TEXT))

//Define as bordas da célula.
oSecao:SetBorder(oXMLSec:_cBorderCell:TEXT)

//Define as bordas da célula. Cabeçalho
oSecao:SetBorder(oXMLSec:_cBorderHCell:TEXT,,,.T.)

//Permite efetuar tratamentos antes da impressão do registro da seção.
oSecao:OnPrintLine(&("{|| If("+cTabPrinc+"->"+cPrefixoD+'_FILIAL' +" $ '"+ xFilial(cTabPrinc) +"|', .T., .F.)}"))


/**************** FIM  ATRIBUTOS/METODOS CLASSE TRSECTION  ****************/


If Self:XmlVerifNode(oXMLSec,"_ACELL")

   If valtype(oXMLSec:_acell) <> "A"
      aCell := {oXMLSec:_acell}
   Else
      aCell := oXMLSec:_acell
   EndIf

EndIf

For i := 1 To len(aCell)
   Self:XmlToTrCell(aCell[i],oSecao)
Next

//Adiciona TRBreak Caso exista quebra
If !Empty(Self:cBreak)
   Self:XmlToTrBreak(oSecao)
EndIf

//Verifica se o Nó "_ARELATION" Existe no XML
If Self:XmlVerifNode(oXMLSec,"_ARELATION")
   //Monta a Relação das tabelas na seçao
   Self:XmlRelation(oSecao,oXMLSec)
EndIf


//Verifica se o Nó "_AUSERFILTER" Existe no XML
If Self:XmlVerifNode(oXMLSec,"_AUSERFILTER")
   //Monta o filtro especificado no Xml
   Self:XmlUserFilter(oSecao,oXMLSec)
EndIf


//Verifica se o Nó "_ASECTIONRELATION" Existe no XML
If Self:XmlVerifNode(oXMLSec,"_ASECTIONRELATION")
   //Executa o Filtro e a Relaçao no Xml
   Self:XmlSectionRelation(oSecao,oXMLSec)
EndIf

//Carrega índices do Dicionário de Índices (SIX) como ordem da seção.
oSecao:LoadOrder()//FSY - 29/10/2013

If aScan(aTabelas,{|x| x == "EDD"}) > 0
   oSecao:lIdxOrder  := .T.
   oSecao:nIdxOrder  := 2
   oSecao:nOrder     := 2
   oOrder            := TRORDER():New(oSecao,"EDD","Hawb","EDD")
   oOrder:nOrder := 2
   oSecao:AddOrder(oOrder)
EndIf

Return oSecao

*----------------------------------------------------*
Method XmlToTrCell(oXMLCell,oSecao) Class EasyTReport
*----------------------------------------------------*
Local oCell
Local oFunction
Local aOperacao := {"COUNT","ONPRINT","SUM","AVERAGE","MIN","MAX"}
Local cTitle

cTitle:= StrTran(StrTran(oXMLCell:_cTitle:TEXT, Chr(09), ""), Chr(10), "")

                    //oParent,cName               ,cAlias                  ,cTitle                ,cPicture                ,nSize                   ,lPixel   ,bBlock,cAlign,lLineBreak                   ,cHeaderAlign,lCellBreak,nColSpace,lAutoSize                   ,nClrBack                    ,nClrFore                   ,lBold
oCell := TRCELL():New(oSecao ,oXMLCell:_cName:TEXT,oXMLCell:_cAlias:TEXT   ,cTitle                ,oXMLCell:_cPicture:TEXT ,&(oXMLCell:_nSize:TEXT) ,         ,      ,      ,&(oXMLCell:_lLineBreak:TEXT) ,            ,          ,         ,&(oXMLCell:_lAutoSize:TEXT) ,&(oXMLCell:_nClrBack:TEXT)  ,&(oXMLCell:_nClrFore:TEXT) ,       )

/**************** INICIO ATRIBUTOS/METODOS CLASSE TRCELL  ****************/

//Define se os totalizadores serão impressos em linha ou coluna.
oCell:SetTotalInLine(.F.)

//
oSecao:Cell(oXMLCell:_cName:TEXT):SetHeaderSize(&(oXMLCell:_lHeaderSize:TEXT))

//Alinhamento da célula. 1-Esquerda, 2-Center ou 3-Direita.
oCell:nAlign := &(oXMLCell:_nAlign:TEXT)

//Alinhamento do cabeçalho 1-Esquerda, 2-Center ou 3-Direita.
oCell:nHeaderAlign := &(oXMLCell:_nHeaderAlign:TEXT)

//Ordem de impressão da célula.
oCell:cOrder := oXMLCell:_cOrder:TEXT

//Tipo da célula. 1-Celula, 2-Formula, 3-Acumulador ou 4-Célula de usuário.
oCell:nType := &(oXMLCell:_nType:TEXT)

//Fórmula para impressão da célula.
oCell:cFormula := StrTran(oXMLCell:_cFormula:TEXT, "/CRLF/", CHR(13)+CHR(10),,)

//Fórmula em forma de expressão ADVPL.
oCell:cRealFormula := StrTran(oXMLCell:_cRealFormula:TEXT, "/CRLF/", CHR(13)+CHR(10),,)

//Tipo de acumulador: "MIN" - Menor valor, "MAX" - Maior valor, "SUM" - Soma, "COUNT" - Contador ou "AVERAGE" - Média.
oCell:cUserFunction := oXMLCell:_cUserFunction:TEXT

//Aponta que a seção será impressa.
oSecao:Cell(oXMLCell:_cName:TEXT):lVisible := &(oXMLCell:_lVisible:TEXT)

//Totalizador de Campo
If Val(oXMLCell:_nTotal:TEXT) > 1
    oFunction := TRFunction():New(oCell,,aOperacao[Val(oXMLCell:_nTotal:TEXT)-1],,,,,.T.,.T.,.F.,oSecao,,,)
EndIf

//Verifica se tem quebra de pagina
If &(oXMLCell:_lBreak:TEXT) .And. ValType(oCell:uPrint) <> "U"
   If !Empty(Self:cBreak)
      Self:cBreak += "+"
   EndIf
   If oXMLCell:_cTipo:TEXT == "N"
      Self:cBreak += AllTrim(Str(oCell:uPrint))
   ElseIf oXMLCell:_cTipo:TEXT == "C"
      Self:cBreak += oCell:uPrint
   EndIf
EndIf

//Define as bordas da célula.
oCell:SetBorder(oXMLCell:_cBorderCell:TEXT)

//Define as bordas da célula.Cabeçalho
oCell:SetBorder(oXMLCell:_cBorderHCell:TEXT,,,.T.)

/**************** FIM  ATRIBUTOS/METODOS CLASSE TRCELL  ****************/

Return


*---------------------------------------------------*
Method XmlRelation(oSecao,oXMLSec) Class EasyTReport
*---------------------------------------------------*
Local aRelation := {}
Local i
Local cAliasTab := "" , cPrefixo := "" , cAliasMain := "" , cRelationMain := "" , cRelationTab := "", cChaveRel := ""

//Converte objeto de relação em Array
If ValType(oXMLSec:_ARELATION) <> "A"
   aRelation := {oXMLSec:_ARELATION}
Else
   aRelation := oXMLSec:_ARELATION
EndIf

For i:= 1 To Len(aRelation)

   //Tabela Relacionada (Pai)
   cAliasTab := UPPER(aRelation[i]:_cAlias:TEXT )
   //Campos de Relação (Filha)
   cRelationMain := UPPER(aRelation[i]:_cRelationMain:TEXT)
   //Campos de Relação (Pai)
   cRelationTab := UPPER(aRelation[i]:_cRelationTab:TEXT)

   //Pega a Tabela Principal (Pai)
   If At("_",cRelationMain) == 4
      cAliasMain := SUBSTR(cRelationMain,1,At("_",cRelationMain)-1)
   Else
      cAliasMain := "S" + SUBSTR(cRelationMain,1,At("_",cRelationMain)-1)
   EndIf

   //Pega o prefixo da tabela para inicializar os nomes dos campos
   cPrefixo := Upper(IF(Left(cAliasTab,1) == "S",Right(cAliasTab,2),Right(cAliasTab,3)))

   //Chave de campos de Relação
   cChaveRel := cAliasMain + "->(" + cRelationMain + ")"

   nOrder := 0
   lFilter:= .T.

   SIX->(dbSetOrder(1))
   SIX->(dbSeek(cAliasTab))
   While SIX->(!Eof()) .And. SIX->INDICE == cAliasTab
      nOrder += 1
      If ( Upper(cPrefixo+'_FILIAL+'+cRelationTab) $ Upper(RTrim(SIX->CHAVE)) )
         If AT("_FILIAL",cRelationMain) == 0
            cChaveRel := "xFilial('" +cAliasTab+"')+" + cAliasMain + "->(" + cRelationMain + ")"
         EndIf
         lFilter := .F.
      ElseIf Upper(cRelationTab) $ SubStr(Upper(RTrim(SIX->CHAVE)),1,Len(cRelationTab))
         lFilter := .F.
      EndIf
      If !lFilter
         Exit
      EndIf
      SIX->(dbSkip())
   EndDo

   //Adiciona a Relação das Tabelas
   oSecao:AddTblRel(cAliasMain,cAliasTab,cRelationMain,cRelationTab)

   //Filtro
   If lFilter
      oSecao:SetFilter('',cRelationTab,,cAliasTab)
      cChaveRel := Self:EasyConvExp(cAliasMain,cRelationMain,.T.)
   EndIf

   //Posiciona a Tabela
   TRPosition():New(oSecao,cAliasTab,If(lFilter,(cAliasTab)->(IndexOrd()),nOrder),&("{||"+ cChaveRel +"}") )

Next i


Return


*-----------------------------------------------------*
Method XmlUserFilter(oSecao,oXMLSec) Class EasyTReport
*-----------------------------------------------------*
Local aUserFilter := {} , aDadosFilter := Array(5)
Local cFilter := ""
Local i

//Converte objeto de relação em Array
If ValType(oXMLSec:_AUSERFILTER) <> "A"
   aUserFilter := {oXMLSec:_AUSERFILTER}
Else
   aUserFilter := oXMLSec:_AUSERFILTER
EndIf


For i := 1 To Len (aUserFilter)

   //Converte expressoes do filtro em expressoes ADVPL
   cFilter := UPPER(StrTran(aUserFilter[i]:_cADVPL:TEXT, "#+#", ">",,) )
   cFilter := StrTran(cFilter, "#-#", "<",,)

   //Adiciona o Alias da Tabela a ser Filtrada
   aDadosFilter[1] := UPPER(aUserFilter[i]:_cTable:TEXT)
   //Filtro
   aDadosFilter[2] := cFilter

   aDadosFilter[3] := aUserFilter[i]:_cSQL:TEXT //AAF 16/02/2017 - Necessário carregar o filtro SQL, mesmo que esteja em branco.
   If !Empty(aDadosFilter[1]) .and. !Empty(aDadosFilter[2])
      If At('->', aDadosFilter[2]) == 0
	     Aadd(oSecao:aUserFilter,aDadosFilter)
	  EndIf
   oSecao:bLineCondition := &("{|| "+cFilter+"}")
   EndIf

Next i

Return

*------------------------------------------------------------------*
Method XmlSectionRelation(oSecao,oXMLSec) Class EasyTReport
*-------------------------------------------------------------------*
Local aSectionRelation := {}
Local cAliasTab := "" , cRelationMain := "", cAliasMain := "", cRelationTab := "" , cPreTab := "", cPreMain := "" , cChaveTab := "", cChaveMain := ""
Local i
Local lFilter
Local nOrder

//Converte objeto de relação em Array
If ValType(oXMLSec:_ASECTIONRELATION) <> "A"
   aSectionRelation := {oXMLSec:_ASECTIONRELATION}
Else
   aSectionRelation := oXMLSec:_ASECTIONRELATION
EndIf

For i:= 1 To Len(aSectionRelation)

   cRelationMain := UPPER(aSectionRelation[i]:_cRelationMain:TEXT)

   //Pega a Tabela Principal (Pai)
   If At("_",cRelationMain) == 4
      cAliasMain := SUBSTR(cRelationMain,1,At("_",cRelationMain)-1)
   Else
      cAliasMain := "S" + SUBSTR(cRelationMain,1,At("_",cRelationMain)-1)
   EndIf

   //Alias Tabela (Pai)
   cAliasTab := UPPER(aSectionRelation[i]:_cAlias:TEXT)
   //Campos Relação Tabela (Pai)
   cRelationTab := UPPER(aSectionRelation[i]:_cRelationTab:TEXT)


   //Pega o prefixo da tabela para inicializar os nomes dos campos
   cPreTab  := Upper(IF(Left(cAliasTab,1) == "S",Right(cAliasTab,2),Right(cAliasTab,3)))
   cPreMain := Upper(IF(Left(cAliasMain,1) == "S",Right(cAliasMain,2),Right(cAliasMain,3)))

   //Adiciona as Chaves para filtros
   cChaveTab  := cAliasTab +"->("+ cRelationTab  + ")"
   cChaveMain := cAliasMain+"->("+ cRelationMain + ")"

   nOrder := 0
   lFilter := .T.

   SIX->(dbSetOrder(1))
   SIX->(dbSeek(cAliasMain))
   While SIX->(!Eof()) .And. SIX->INDICE == cAliasMain
      nOrder += 1
	  If ( Upper(cPreMain + '_FILIAL+'+ cRelationMain) $ Upper(SIX->CHAVE) )
	     If AT("_FILIAL",cRelationTab) == 0
            cChaveTab    := cAliasTab +"->("+ cPreTab +"_FILIAL+" + cRelationTab  + ")"
         EndIf
         If AT("_FILIAL",cRelationMain) == 0
            cChaveMain   := cAliasMain+"->("+ cPreMain+"_FILIAL+" + cRelationMain + ")"
         EndIf
		 lFilter := .F.
      ElseIf Upper(cRelationMain) $ SubStr(Upper(RTrim(SIX->CHAVE)),1,Len(cRelationMain))
		 lFilter := .F.
      EndIf
	  If !lFilter
	     Exit
      EndIf
   SIX->(dbSkip())
   EndDo

   If lFilter
      oSecao:SetFilter('',cRelationMain,,cAliasMain)
   EndIf
   oSecao:SetRelation(&("{||"+cChaveTab+"}"),cAliasMain,If(lFilter,(cAliasMain)->(IndexOrd()),nOrder),.T.)
   oSecao:SetParentFilter(&("{|cParam|"+ AllTrim(cChaveMain) + " == cParam}"),&("{||"+AllTrim(cChaveTab)+"}"))


Next i

Return

*---------------------------------------------------*
Method XmlVerifNode(oXMLSec,cNode) Class EasyTReport
*---------------------------------------------------*
Local lRet := .F.
Local oNode

oNode := XmlChildEx(oXMLSec, UPPER(cNode))

lRet :=  ValType(oNode) <> "U"

Return  lRet



*--------------------------------------------------------*
Method EasyConvExp(cAlias,cExp,lAlias) Class EasyTReport
*--------------------------------------------------------*
Local i
Local nPos
Local aExp := StrTokArr(cExp,"+")
Local aStru:= (cAlias)->(DbStruct())
Local cRet := ""

For i := 1 To Len(aExp)
	aExp[i] := Upper(AllTrim(aExp[i]))
	nPos := Ascan(aStru,{|x| x[1] == aExp[i]})
	If nPos == 0
		If ! "'" $ aExp[i]
			UserException("Invalid field "+aExp[i]+" found in expression "+AllTrim(cExp)+" for table "+cAlias)
		EndIf
	Else
		If lAlias
			aExp[i] := cAlias+"->"+aExp[i]
		EndIf
		If aStru[nPos][2] == "D"
			aExp[i] := "DTOS("+aExp[i]+")"
		ElseIf aStru[nPos][2] == "N"
			aExp[i] := "STR("+aExp[i]+","+AllTrim(Str(aStru[i][3]))+","+AllTrim(Str(aStru[i][4]))+")"
		EndIf
	EndIf

	cRet += aExp[i]
	If i <> Len(aExp)
		cRet += "+"
	EndIf
Next
Return cRet

*------------------------------------------*
Method XmlToTrBreak(oSecao) Class EasyTReport
*------------------------------------------*
Local i
Local oBreak

For i := 1 To Len(oSecao:aFunction)
   oBreak := TRBreak():New(oSecao,{ || Self:cBreak},'Sub-Total',.F.)
   oSecao:aFunction[i]:SetBreak(oBreak)
Next

Return

*------------------------------------*
Method RetOReport() Class EasyTReport
*------------------------------------*
Return Self:oReport
