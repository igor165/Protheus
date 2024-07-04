#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISR022.CH"
#INCLUDE "REPORT.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ FISR022  ³ Autor ³ Graziele Paro         ³ Data ³ 22/03/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³Demonstrativo das Aquisições Interestaduais realizadas no     ³±± 
±±³			 |período com Antecipação Tributária do ICMS                    ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS 		                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function Fisr022()
Local oReport
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.) 
    
If lVerpesssen .And. TRepInUse()		//	verifica se relatorios personalizaveis esta disponivel	
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Interface de impressao                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport	:= ReportDef()
		oReport:PrintDialog()
Endif  

Return    
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ReportDef ³ Autor ³ Graziele Paro         ³ Data ³ 22/03/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Definicao do componente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                

Static Function ReportDef()
Local oReport
Local oRelat
Local oNomes 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("FISR022",STR0001,"FISR022", {|oReport| ReportPrint(oReport)},STR0001)
oReport:oPage:nPaperSize:= 9
oReport:SetTotalInLine(.F.)
oReport:SetLandscape() 
Pergunte("FISR022",.F.) 
aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}
Aadd(aHelpPor,"Informar se a geração do relatório")
Aadd(aHelpPor,"deverá ser pela data de emissão com 'Sim' ")
Aadd(aHelpPor,"ou pela data de entrada com 'Não'. ")
If FindFunction("ENGSX1117")
	EngSX1117("FISR022", "04", "Considera data de Emissão ?", "Considera data de Emissão ?", "Considera data de Emissão ?", "mv_ch0", "C", 1, 0, 2,"C", "","","","","mv_par4", "Nao", "No", "No", "","Sim", "Si", "Yes", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)
ElseIf FindFunction("ENGSX1116")
	EngSX1116("FISR022", "04", "Considera data de Emissão ?", "Considera data de Emissão ?", "Considera data de Emissão ?", "mv_ch0", "C", 1, 0, 2,"C", "","","","","mv_par4", "Nao", "No", "No", "","Sim", "Si", "Yes", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpPor, aHelpPor)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
   
//Secao Relatorio                 
oRelat:=TRSection():New(oReport,STR0001,{"REL"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)    //Método construtor da classe TRSection
oRelat:SetPageBreak(.T.)  //Define se salta a página na quebra de seção         
oRelat:SetTotalInLine(.F.)  

TRCell():New(oRelat,"DENTRADA"	,"REL",STR0004,/*cPicture*/,25,/*lPixel*/,/*{|| code-block de impressao }*/) //"Data Entrada"
TRCell():New(oRelat,"DEMISSAO" ,"REL",STR0005,/*cPicture*/,25,/*lPixel*/,/*{|| code-block de impressao }*/) //"Data Emissao"
TRCell():New(oRelat,"NFISCAL"  ,"REL",STR0006,/*cPicture*/,25,/*lPixel*/,/*{|| code-block de impressao }*/) //"Nota Fiscal"
TRCell():New(oRelat,"ESTADO"   ,"REL",STR0007,/*cPicture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/) //"Estado"
TRCell():New(oRelat,"CODFOR"	,"REL",STR0008,/*cPicture*/,25,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oRelat,"RAZAOFOR"	,"REL",STR0009,/*cPicture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Razao Social"
TRCell():New(oRelat,"CNPJ" 	    ,"REL",STR0010,"@R 99.999.999/9999-99",35,/*lPixel*/,/*{|| code-block de impressao }*/) //"CNPJ"  
TRCell():New(oRelat,"INSCRICAO"	,"REL",STR0011,"@!",35,/*lPixel*/,/*{|| code-block de impressao }*/) //"Inscricao Estadual"   
TRCell():New(oRelat,"CFOP" 	    ,"REL",STR0012,/*cPicture*/,08,/*lPixel*/,/*{|| code-block de impressao }*/) //"CFOP"       
TRCell():New(oRelat,"VCONTABIL","REL",STR0013,"@E 99,999,999,999.99",23,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Contabil"      
TRCell():New(oRelat,"VICMSANT" 	,"REL",STR0014,"@E 99,999,999,999.99",23,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor ICMS antecipado"  

Return(oReport)     
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Graziele Paro          ³ Data ³22/03/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport)
Local oRelat	:= oReport:Section(1) 
Local oBreakEs   := ""

SelRel()
REL->(dbSetOrder(2))                     
oReport:SkipLine(10) 

//Totalizadores
If mv_par03 == 1 // define se deve ou nao ser agrupado por fornecedor
	oBreakEs  := TRBreak():New(oRelat,oRelat:Cell("ESTADO"),STR0015,.F.) // "Total Estado "      
	TRFunction():New(oRelat:Cell("VICMSANT"),Nil,"SUM",oBreakEs,"","@E 999,999,999.99",/*uFormula*/,.F.,.T.,.F.)
Else
	oBreakFil := TRBreak():New(oRelat,oRelat:Cell("CODFOR"),STR0016,.F.) // "Total Fornecedor   
	oBreakEs  := TRBreak():New(oRelat,oRelat:Cell("ESTADO"),STR0015,.F.) // "Total Estado "      
	TRFunction():New(oRelat:Cell("VICMSANT"),Nil,"SUM",oBreakEs,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.,.F.)       
	TRFunction():New(oRelat:Cell("VICMSANT"),Nil,"SUM",oBreakFil,"","@E 999,999,999.99",/*uFormula*/,.F.,.T.,.F.)      
EndIf 
 
oRelat:Print()    
REL->(DbCloseArea())
FErase(cArqRel+GetDBExtension())
FErase(cArqRel+IndexExt())

Return         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SelRel	    ³Autor ³ Graziele Paro        ³Data³22/03/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleciona dados para emissao do relatorio 		          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function SelRel()    
Local aCampos 	:= {}                    
Local lTop	 	:= .F.   
Local cAliasSF3	:= "SF3"     
Local cAliasSA2 := "SA2"    
Local cArqInd	:= ""
Local nMes 		:=mv_par01   
Local nAno 		:=mv_par02
Local dInicial	:= LastDay(CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nAno,4,0)),1)
Local dFinal 	:= LastDay(CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nAno,4,0)),2)

//Criando tabela temporaria
aCampos:={{"DENTRADA"     ,"D",08,0},;
{"DEMISSAO"    	,"D",08,0},;
{"NFISCAL"      ,"C",09,0},; 
{"SERIE"        ,"C",03,0},;
{"LOJA"         ,"C",02,0},; 
{"FILIAL"       ,"C",02,0},; 
{"ESTADO"     	,"C",02,0},;
{"CODFOR"      	,"C",06,0},;
{"RAZAOFOR"     ,"C",30,2},;
{"CNPJ"         ,"C",14,0},;
{"INSCRICAO"    ,"C",18,0},;
{"CFOP"      	,"C",05,0},;
{"VCONTABIL"    ,"N",14,2},;
{"VICMSANT"     ,"N",14,2}} 

//Indices
If Select("REL")>0
	dbSelectArea("REL")
	REL->(DbCloseArea())
EndIf

cArqTemp := CriaTrab(aCampos)
dbUseArea(.T.,,cArqTemp,"REL",.T.,.F.)
cArqInd  := CriaTrab(NIL,.F.)
IndRegua("REL",cArqInd,"CODFOR+LOJA+NFISCAL+SERIE+CFOP")
cArqInd2  := CriaTrab(NIL,.F.)
IndRegua("REL",cArqInd2,"ESTADO")    
dbClearIndex()
dbSelectArea("REL")
dbSetIndex(cArqInd+OrdBagExt())
dbSetIndex(cArqInd2+OrdBagExt())
dbSetOrder(2)
aAdd(aCampos,{cArqTemp,"REL"})

dbSelectArea("SF3")
SF3->(dbSetOrder(4))   
dbSelectArea("SA2")
SA2->(dbSetOrder(1))   

#IFDEF TOP
    If (TcSrvType ()<>"AS/400")	  
     lTop	:= .T.
     cAliasSF3		:=	GetNextAlias()
    if mv_par04 == 1
    	BeginSql Alias cAliasSF3    
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_EMISSAO AS DATE    
			
			SELECT SA2.A2_COD,
					SA2.A2_LOJA,
					SA2.A2_NOME,
					SA2.A2_NREDUZ,
					SA2.A2_EST,
					SA2.A2_CGC,
					SA2.A2_INSCR,
					SF3.F3_ENTRADA,
					SF3.F3_NFISCAL,
					SF3.F3_SERIE,
					SF3.F3_CLIEFOR,
					SF3.F3_LOJA,
					SF3.F3_CFO,
					SF3.F3_ESTADO,
					SF3.F3_EMISSAO,
					SF3.F3_FILIAL,
					SF3.F3_VALANTI,
					SF3.F3_VALCONT				
      	    FROM 
					%TABLE:SF3% SF3
					INNER JOIN %TABLE:SA2% SA2 ON(SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA AND SA2.%NOTDEL%)
			WHERE 
					SF3.F3_FILIAL=%XFILIAL:SF3% 
					AND SA2.A2_FILIAL=%XFILIAL:SA2%  
				   	AND SF3.F3_VALANTI >0
				   	AND SF3.%NOTDEL%
					AND SF3.F3_DTCANC = %Exp:Dtos(Ctod(''))%
					AND SF3.F3_ENTRADA >= %EXP:DTOS(dInicial)% 
					AND SF3.F3_ENTRADA <= %EXP:DTOS(dFinal)% 
			ORDER BY SA2.A2_EST,SA2.A2_COD
     EndSql 
	 DbSelectArea (cAliasSF3)
     (cAliasSF3)->(DbGoTop())
   elseif mv_par04 == 2
   		BeginSql Alias cAliasSF3    
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_EMISSAO AS DATE    
			
			SELECT SA2.A2_COD,
					SA2.A2_LOJA,
					SA2.A2_NOME,
					SA2.A2_NREDUZ,
					SA2.A2_EST,
					SA2.A2_CGC,
					SA2.A2_INSCR,
					SF3.F3_ENTRADA,
					SF3.F3_NFISCAL,
					SF3.F3_SERIE,
					SF3.F3_CLIEFOR,
					SF3.F3_LOJA,
					SF3.F3_CFO,
					SF3.F3_ESTADO,
					SF3.F3_EMISSAO,
					SF3.F3_FILIAL,
					SF3.F3_VALANTI,
					SF3.F3_VALCONT				
      	    FROM 
					%TABLE:SF3% SF3
					INNER JOIN %TABLE:SA2% SA2 ON(SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA AND SA2.%NOTDEL%)
			WHERE 
					SF3.F3_FILIAL=%XFILIAL:SF3% 
					AND SA2.A2_FILIAL=%XFILIAL:SA2%  
				   	AND SF3.F3_VALANTI >0
				   	AND SF3.%NOTDEL%
					AND SF3.F3_DTCANC = %Exp:Dtos(Ctod(''))%
					AND SF3.F3_EMISSAO >= %EXP:DTOS(dInicial)% 
					AND SF3.F3_EMISSAO <= %EXP:DTOS(dFinal)% 
			ORDER BY SA2.A2_EST,SA2.A2_COD
     EndSql 
	 DbSelectArea (cAliasSF3)
     (cAliasSF3)->(DbGoTop())
   
   Endif
Else
#ENDIF       
         cIndex	:= CriaTrab(NIL,.F.)
         cFiltro	:= 'F3_FILIAL=="'+xFilial ("SF3")+'".And.' 
         cFiltro += 'F3_VALANTI >0 .And. '   
         cFiltro += 'DTOS (F3_DTCANC)>="'+DTOS(dInicial)+'" .And. '
         cFiltro += 'DTOS (F3_ENTRADA)>="'+DTOS(dInicial)+'" .And. ' 
         cFiltro += 'DTOS (F3_ENTRADA)<="'+DTOS(dFinal)+'"'                        
         
	    IndRegua (cAliasSF3, cIndex, SF3->(IndexKey ()),, cFiltro)
	    nIndex := RetIndex(cAliasSF3)

		#IFNDEF TOP
			DbSetIndex (cIndex+OrdBagExt ())
		#ENDIF
		DbSelectArea (cAliasSF3)
	    DbSetOrder (nIndex+1)        
#IFDEF TOP
	Endif
#ENDIF         

If lTop
	cAliasSA2	:= cAliasSF3				 				 
EndIf
 
DbSelectArea (cAliasSF3)
(cAliasSF3)->(DbGoTop())
	While (cAliasSF3)->(!EOF())
		IF !lTop  
		   (cAliasSF2)->(MsSeek(xFilial("SF2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))   
		ENDIF 
		DbSelectArea ("REL")
		REL->(dbSetOrder(1))
		IF !REL->(MsSeek((cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CFO)) //passar a sf3
			    Reclock("REL",.T.)                  
				REL->DENTRADA		:= (cAliasSF3)->F3_ENTRADA
				REL->DEMISSAO		:= (cAliasSF3)->F3_EMISSAO
				REL->NFISCAL		:= (cAliasSF3)->F3_NFISCAL 
				REL->SERIE			:= (cAliasSF3)->F3_SERIE
				REL->LOJA			:= (cAliasSF3)->F3_LOJA
				REL->ESTADO			:= (cAliasSA2)->A2_EST
				REL->CODFOR	   		:= (cAliasSA2)->A2_COD
				REL->RAZAOFOR		:= (cAliasSA2)->A2_NOME
				REL->CNPJ			:= (cAliasSA2)->A2_CGC
				REL->INSCRICAO		:= (cAliasSA2)->A2_INSCR 
				REL->CFOP			:= (cAliasSF3)->F3_CFO
				REL->VCONTABIL		:= (cAliasSF3)->F3_VALCONT
				REL->VICMSANT		:= (cAliasSF3)->F3_VALANTI   
				MsUnLock()	
		Else
			    Reclock("REL",.F.)
				REL->VCONTABIL		+= (cAliasSF3)->F3_VALCONT
				REL->VICMSANT		+= (cAliasSF3)->F3_VALANTI   		
				MsUnLock()
		EndIf		
		(cAliasSF3)->(dbSkip()) 
 	EndDo
 	(cAliasSF3)->(DbCloseArea())
return 
